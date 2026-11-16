extends "res://tests/suite_base.gd"
## Suíte da frente monstros: regras de dano, impacto de objetos materializados, boneco de
## treino e alvos voadores.

const DAMAGE := preload("res://assets/data/damage_rules.tres")


func run() -> void:
	_test_damage_rules()
	_test_projectile_momentum()
	await _test_damage_consistency()
	await _test_flying_targets()
	await _test_dummy_fire_and_reset()
	await _test_health_and_respawn()
	await _test_combat_bot()


# Vida, renascer e invencibilidade (design/gdd/combat-bot.md).
func _test_health_and_respawn() -> void:
	print("\n--- Vida e renascer ---")
	var arena := await _load_arena("psionic")
	var player: Player = arena.player
	var health := player.get_node_or_null("Health") as Health
	_check(health != null, "jogador tem vida")
	if health == null:
		await _unload(arena)
		return
	var expected := DAMAGE.base_health * pow(player.stats.mult(Attributes.Kind.VITALITY), DAMAGE.health_exponent)
	_check(is_equal_approx(health.max_health, expected), "vida máxima %.0f (Vitalidade)" % health.max_health)

	# Um dardo de outro personagem acerta o jogador e tira vida.
	var dart := KineticDartProjectile.new()
	dart.mass = 0.007
	dart.power = 2.2
	arena.add_child(dart)
	dart.global_position = player.get_center() + Vector3(0, 0, -3)
	dart.launch(Vector3(0, 0, 60), Vector3.ZERO)
	await _frames(10)
	_check(health.current < health.max_health, "dardo tira vida do jogador (%.1f de %.0f)" % [health.current, health.max_health])

	# Andar contra uma caixa parada não machuca.
	var before := health.current
	var crate := _nearest_crate(arena, player)
	player.global_position = crate.global_position + Vector3(0, -0.3, 1.5)
	await _walk_toward(player, crate.global_position, 40)
	_check(is_equal_approx(health.current, before), "andar contra caixa parada não machuca")

	# Vida em 0: renasce no início com vida cheia e fica invencível por 0,5 s.
	player.global_position = Vector3(5, 0.05, 0)
	await _frames(3)
	var respawned := [false]
	health.respawned.connect(func() -> void: respawned[0] = true)
	health.take_damage("Teste", health.current + 10.0)
	_check(respawned[0] and is_equal_approx(health.current, health.max_health), "vida em 0: renasce com vida cheia")
	_check(player.global_position.distance_to(arena.SPAWN) < 0.5, "renasce no ponto inicial")
	_check(health.is_invulnerable(), "invencível logo após renascer")
	health.take_damage("Teste", 30.0)
	_check(is_equal_approx(health.current, health.max_health), "dano durante a invencibilidade é ignorado")
	await _frames(int(DAMAGE.respawn_invulnerability * 60.0) + 3)
	_check(not health.is_invulnerable(), "invencibilidade acaba em %.1f s" % DAMAGE.respawn_invulnerability)
	health.take_damage("Teste", 30.0)
	_check(health.current < health.max_health, "depois da invencibilidade, volta a tomar dano")
	await _unload(arena)


# Bot Psiônico agressivo: F6 chama e some, ataca, morre e renasce (design/gdd/combat-bot.md).
func _test_combat_bot() -> void:
	print("\n--- Bot psiônico (F6) ---")
	var arena := await _load_arena("mage")
	var player: Player = arena.player
	var health := player.get_node("Health") as Health
	_check(InputMap.has_action("spawn_bot"), "F6 registrado")
	_press_key(KEY_F6)
	await _frames(5)
	var bot: PsionicBot = arena.combat_bot
	_check(is_instance_valid(bot), "F6 chama o bot")
	if not is_instance_valid(bot):
		await _unload(arena)
		return
	_check(bot.class_data.id == &"psionic" and bot.class_data.attributes.intelligence == GameState.find_class("psionic").attributes.intelligence, "bot usa os atributos do Psiônico")

	# Agressivo: em alguns segundos já acertou o jogador.
	var start_health := health.current
	var hit_time := -1.0
	for frame in 480:
		await _frames(1)
		if health.current < start_health or health.is_invulnerable():
			hit_time = frame / 60.0
			break
	_check(hit_time >= 0.0, "bot ataca e acerta o jogador (em %.1f s)" % hit_time)
	_check(bot.get_mana() < bot.stats.max_mana, "bot gasta Mana nos disparos")

	# O jogador acerta o bot; vida em 0 faz o bot renascer no ponto dele.
	var bot_health := bot.health
	bot.register_hit("Teste", 200.0)
	_check(bot_health.current < bot_health.max_health, "golpe tira vida do bot")
	bot.global_position = bot.spawn_point + Vector3(6, 0, 0)
	await _frames(2)
	bot_health.take_damage("Teste", bot_health.current + 5.0)
	_check(is_equal_approx(bot_health.current, bot_health.max_health) and bot_health.is_invulnerable(), "bot renasce com vida cheia e invencível")
	_check(bot.global_position.distance_to(bot.spawn_point) < 0.5, "bot renasce no ponto dele")

	_press_key(KEY_F6)
	await _frames(5)
	_check(not is_instance_valid(bot), "F6 de novo faz o bot sumir")
	await _unload(arena)


func _test_damage_rules() -> void:
	_check(DAMAGE.impact_damage(DAMAGE.impulse_threshold * 0.5) == 0.0, "esbarrão abaixo do limiar não dá dano")
	_check(is_equal_approx(DAMAGE.impact_damage(110.0), (110.0 - DAMAGE.impulse_threshold) * DAMAGE.damage_per_impulse), "fórmula de dano físico")
	_check(is_equal_approx(DAMAGE.heat_damage(50.0), 50.0 * DAMAGE.damage_per_heat), "fórmula de dano de fogo")


func _test_dummy_fire_and_reset() -> void:
	print("\n--- Boneco: fogo próximo e reset ---")
	var arena := await _load_arena("mage")
	var dummy: TrainingDummy = arena.dummy
	var crate := _nearest_crate(arena, arena.player)
	crate.freeze = true
	crate.global_position = dummy.global_position + Vector3(0.7, 0.3, 0)
	crate.ignite()
	await _frames(60)
	_check(dummy.fire_damage > 0.0, "caixa em chamas ao lado causa dano de fogo (%.1f)" % dummy.fire_damage)
	crate.queue_free()
	await _frames(10)
	var damage := dummy.combo_damage
	await _frames(int(DAMAGE.combo_reset_time * 60.0) + 30)
	_check(damage > 0.0 and dummy.combo_damage == 0.0, "boneco zera após %.0f s sem dano" % DAMAGE.combo_reset_time)
	await _unload(arena)


# Objetos materializados: massa x velocidade relativa (design/gdd/damage-and-testing.md).
func _test_projectile_momentum() -> void:
	print("\n--- Impacto de objetos materializados ---")
	var dart := KineticDartProjectile.new()
	dart.mass = 0.01
	dart.launch(Vector3(0, 0, -30), Vector3.ZERO)
	var base := dart.impact_impulse()
	_check(is_equal_approx(base, 0.01 * 30.0 * DAMAGE.materialized_scale), "10 g a 30 m/s = %.0f N·s de impacto" % base)
	dart.launch(Vector3(0, 0, -30), Vector3(0, 0, -7))
	_check(is_equal_approx(dart.impact_impulse(), base * 37.0 / 30.0), "correr na direção do tiro soma velocidade (%.0f N·s)" % dart.impact_impulse())
	dart.launch(Vector3(0, 0, -30), Vector3(0, 0, 7))
	_check(is_equal_approx(dart.impact_impulse(), base * 23.0 / 30.0), "recuar tira velocidade (%.0f N·s)" % dart.impact_impulse())
	dart.free()


# Regressão (3º playtest): o dano não pode depender da distância nem do ponto do corpo
# atingido; só o movimento real conta, e cair de 4 m pesa mais que um pulo baixo.
func _test_damage_consistency() -> void:
	print("\n--- Dano: distância, ponto de impacto e movimento ---")
	for id in ["mage", "psionic"]:
		var arena := await _load_arena(id)
		var player: Player = arena.player
		var dummy: TrainingDummy = arena.dummy
		player.debug_infinite_resources = true
		player.debug_no_cooldowns = true
		var base := dummy.global_position
		var distances: Array[float] = []
		for distance in [3.0, 8.0, 20.0]:
			distances.append(await _shot(player, dummy, base + Vector3(0, 0.05, distance), base + Vector3.UP * 1.2, Vector3.ZERO))
		print("  %s por distância (3, 8, 20 m): %s" % [id, distances])
		_check(_spread(distances) < 0.05, "%s: distância não muda o dano (%s)" % [id, distances])
		var heights: Array[float] = []
		for height in [0.5, 1.2, 1.9]:
			heights.append(await _shot(player, dummy, base + Vector3(0, 0.05, 8.0), base + Vector3.UP * height, Vector3.ZERO))
		print("  %s por ponto do corpo (0,5; 1,2; 1,9 m): %s" % [id, heights])
		_check(_spread(heights) < 0.05, "%s: ponto do corpo não muda o dano (%s)" % [id, heights])
		var still: float = await _shot(player, dummy, base + Vector3(0, 0.05, 8.0), base + Vector3.UP * 1.2, Vector3.ZERO, true)
		var hop: float = await _shot(player, dummy, base + Vector3(0, 0.7, 4.0), base + Vector3.UP * 1.2, Vector3(0, 4, 0), true)
		# Mira na cabeça: quem cai também puxa o tiro para baixo.
		var fall: float = await _shot(player, dummy, base + Vector3(0, 1.0, 4.0), base + Vector3.UP * 1.9, Vector3(0, -8.9, 0), true)
		print("  %s impulso parado / pulo / queda de 4 m: %.1f / %.1f / %.1f" % [id, still, hop, fall])
		_check(fall > hop, "%s: cair de 4 m pesa mais que um pulo baixo (%.1f x %.1f)" % [id, fall, hop])
		_check(hop < still * 1.1, "%s: pulo baixo quase não muda o tiro (%.1f x %.1f)" % [id, hop, still])
		await _unload(arena)


## Dispara com carga cheia e devolve o dano total (ou o impulso, se `impulse_only`).
func _shot(player: Player, dummy: TrainingDummy, from: Vector3, target: Vector3, moving: Vector3, impulse_only := false) -> float:
	dummy.reset()
	player.global_position = from
	await _frames(2)
	player.global_position = from
	player.face_point(target)
	player.velocity = moving
	player.use_ability(Player.SLOT_PRIMARY, 1.0)
	for i in 90:
		await _frames(1)
		if dummy.hit_count > 0:
			break
	await _frames(3)
	return dummy.last_impulse if impulse_only else dummy.combo_damage


## Diferença entre o maior e o menor valor, como fração do maior.
func _spread(values: Array[float]) -> float:
	return (values.max() - values.min()) / maxf(values.max(), 0.001)


func _test_flying_targets() -> void:
	print("\n--- Alvos voadores (F7) ---")
	var arena := await _load_arena("psionic")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	_check(InputMap.has_action("spawn_targets"), "F7 registrado")
	_press_key(KEY_F7)
	await _frames(5)
	_check(arena.flying_targets.size() == arena.TARGET_ORBITS.size(), "F7 cria %d alvos" % arena.flying_targets.size())
	var target: FlyingTarget = arena.flying_targets[0]
	var from := target.global_position
	await _frames(20)
	_check(target.global_position.distance_to(from) > 0.5 and target.global_position.y > 1.5, "alvo voa em movimento")
	_check(target.get_motion_velocity().length() > 1.0, "alvo informa a própria velocidade (%.1f m/s)" % target.get_motion_velocity().length())
	for i in 3:
		arena.spawn_flying_targets()
	await _frames(2)
	var alive := 0
	for t in arena.flying_targets:
		if is_instance_valid(t):
			alive += 1
	_check(alive <= arena.MAX_TARGETS, "nunca mais que %d alvos (%d)" % [arena.MAX_TARGETS, alive])

	# Dardo cheio acerta um alvo parado de propósito; o dano entra no combo do boneco.
	var shot: FlyingTarget = arena.flying_targets.back()
	shot.orbit_speed = 0.0
	await _frames(5)
	player.global_position = Vector3(shot.global_position.x, 0.05, shot.global_position.z) + Vector3(0, 0, 6)
	await _frames(5)
	dummy.reset()
	player.debug_infinite_resources = true
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(62)
	player.face_point(shot.global_position)
	await _frames(1)
	player.request_action(Player.ACTION_PRIMARY_RELEASE)
	await _frames(25)
	_check(shot.hit_count > 0 and dummy.combo_damage > 10.0, "dardo acerta o alvo voador (%.1f de dano no combo)" % dummy.combo_damage)
	await _unload(arena)

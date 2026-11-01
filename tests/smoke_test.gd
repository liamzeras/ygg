extends Node
## Teste de fumaça: carrega a arena com cada classe, usa as habilidades e o pulo duplo,
## pega/arremessa uma caixa, testa fogo, explosão, dano no boneco (inclusive de fogo
## próximo e o reset de 5 s), o editor de atributos e as fórmulas de atributos.
## Rodar: ver tests/README.md. Sai com código 0 (passou) ou 1 (falhou).

const ARENA := preload("res://src/levels/test_arena.tscn")
const RULES := preload("res://assets/data/attribute_rules.tres")
const DAMAGE := preload("res://assets/data/damage_rules.tres")

var _failures: Array[String] = []
var _checks := 0
var _sprint_speeds: Array[float] = []
var _throw_speeds := {}


func _ready() -> void:
	_test_attribute_curve()
	_test_damage_rules()
	for id in ["knight", "mage", "psionic"]:
		await _test_class(id)
	_check(_sprint_speeds.size() == 3 and _sprint_speeds.all(func(s: float) -> bool: return is_equal_approx(s, _sprint_speeds[0])), "velocidade de corrida igual entre classes")
	_check(_throw_speeds.get("psionic", 0.0) > _throw_speeds.get("mage", 0.0), "Telecinese Acelerada arremessa mais rápido que as mãos do Elementalista (%.1f x %.1f m/s)" % [_throw_speeds.get("psionic", 0.0), _throw_speeds.get("mage", 0.0)])
	await _test_psionic()
	await _test_elementalist()
	await _test_steps()
	_test_projectile_momentum()
	await _test_damage_consistency()
	await _test_progression()
	await _test_stair_auto_climb()
	await _test_stair_rhythm()
	await _test_dash()
	await _test_flying_targets()
	await _test_dummy_fire_and_reset()
	print("\n=== SMOKE TEST: %d verificações, %d falhas ===" % [_checks, _failures.size()])
	for failure in _failures:
		print("  FALHOU: " + failure)
	get_tree().quit(1 if _failures.size() > 0 else 0)


func _test_attribute_curve() -> void:
	var human := RULES.human
	var at_cap := Attributes.new()
	for kind: Attributes.Kind in Attributes.Kind.values():
		_check(is_equal_approx(RULES.multiplier(human, kind), 1.0), "humano = 1x em %s" % Attributes.NAMES[kind])
	at_cap.strength = RULES.cap
	at_cap.dexterity = RULES.cap
	_check(is_equal_approx(RULES.multiplier(at_cap, Attributes.Kind.STRENGTH), RULES.multiplier_at_cap), "Força no teto = %sx" % RULES.multiplier_at_cap)
	_check(is_equal_approx(RULES.multiplier(at_cap, Attributes.Kind.DEXTERITY), RULES.multiplier_at_cap), "Destreza no teto = %sx" % RULES.multiplier_at_cap)


func _test_damage_rules() -> void:
	_check(DAMAGE.impact_damage(DAMAGE.impulse_threshold * 0.5) == 0.0, "esbarrão abaixo do limiar não dá dano")
	_check(is_equal_approx(DAMAGE.impact_damage(110.0), (110.0 - DAMAGE.impulse_threshold) * DAMAGE.damage_per_impulse), "fórmula de dano físico")
	_check(is_equal_approx(DAMAGE.heat_damage(50.0), 50.0 * DAMAGE.damage_per_heat), "fórmula de dano de fogo")


func _test_class(id: String) -> void:
	print("\n--- Classe: %s ---" % id)
	var arena := await _load_arena(id)
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	_check(player != null, "%s: jogador criado" % id)
	_check(player.is_on_floor(), "%s: jogador no chão" % id)
	_sprint_speeds.append(player.stats.sprint_speed)
	print("  stats: carga %.0f kg, pulo %.2f m, corrida %.1f m/s, vigor %.0f, mana %.0f" % [
		player.stats.carry_mass, player.stats.jump_height, player.stats.sprint_speed, player.stats.max_stamina, player.stats.max_mana])

	# Habilidade principal de perto do boneco (alcance do Golpe de Escudo é curto).
	player.global_position = dummy.global_position + Vector3(0, 0.05, 1.8)
	await _frames(10)
	player.face_point(dummy.global_position + Vector3.UP * 1.2)
	await _frames(2)
	var primary := player.get_ability(Player.SLOT_PRIMARY)
	var before: float = player.get_pool(primary.cost_pool)
	player.request_action(Player.SLOT_PRIMARY)
	if primary.is_chargeable():
		await _frames(2)
		player.request_action(Player.ACTION_PRIMARY_RELEASE)
	await _frames(45)
	_check(player.get_pool(primary.cost_pool) < before, "%s: principal gastou %s" % [id, Player.POOL_NAMES[primary.cost_pool]])
	_check(dummy.combo_damage > 0.0, "%s: boneco tomou dano (%.1f, DPS %.1f)" % [id, dummy.combo_damage, dummy.get_dps()])

	# Especial e mobilidade (se a classe tiver).
	if id == "knight":
		player.request_action(Player.SLOT_SPECIAL)
		await _frames(3)
		_check(player.is_guarding(), "knight: Postura de Muralha ativa")
	if player.get_ability(Player.SLOT_MOBILITY):
		# Mira o chão atrás (longe do boneco): o Pilar de Pedra precisa de chão firme.
		player.face_point(player.get_aim_origin() - player.get_flat_forward() * 4.0 + Vector3.DOWN * 1.6)
		await _frames(2)
		player.request_action(Player.SLOT_MOBILITY)
		await _frames(3)
		_check(player.get_cooldown(Player.SLOT_MOBILITY) > 0.0, "%s: mobilidade usada" % id)
	await _frames(90)

	# Quem não tem Flutuar cai normalmente segurando Espaço.
	if player.get_ability(Player.SLOT_FLOAT) == null:
		player.global_position = player.global_position + Vector3.UP * 10.0
		player.velocity = Vector3.ZERO
		player.force_jump_held = true
		await _frames(40)
		_check(not player.is_floating() and player.velocity.y < -3.0, "%s: segurar Espaço no ar não flutua (queda %.1f m/s)" % [id, player.velocity.y])
		player.force_jump_held = false

	# Pulo duplo: um só por salto, gasta Vigor.
	player.respawn()
	await _frames(20)
	var ground_y := player.global_position.y
	player.request_action(Player.ACTION_JUMP)
	await _frames(12)
	_check(not player.is_on_floor(), "%s: pulou" % id)
	var stamina: float = player.get_pool(Player.Pool.STAMINA)
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	_check(player.velocity.y > 3.0 and player.get_pool(Player.Pool.STAMINA) < stamina, "%s: pulo duplo funcionou e gastou Vigor (subida %.1f m/s)" % [id, player.velocity.y])
	var vy := player.velocity.y
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	_check(player.velocity.y < vy, "%s: terceiro pulo bloqueado" % id)
	var peak := await _peak_until_landing(player)
	_check(peak - ground_y <= 2.02, "%s: pulo duplo chega a no máximo 2 m (%.2f m)" % [id, peak - ground_y])
	_check(player.is_air_jump_available(), "%s: pulo duplo recarregou ao tocar o chão" % id)

	# Pulo simples: teto de 1 m mesmo com Agilidade e Inteligência no máximo.
	player.set_attribute(Attributes.Kind.AGILITY, RULES.cap)
	player.set_attribute(Attributes.Kind.INTELLIGENCE, RULES.cap)
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	peak = await _peak_until_landing(player)
	_check(peak - ground_y <= 1.05, "%s: pulo com atributos no teto chega a no máximo 1 m (%.2f m)" % [id, peak - ground_y])
	player.request_action(Player.ACTION_JUMP)
	await _frames(12)
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	peak = await _peak_until_landing(player)
	_check(peak - ground_y <= 2.02, "%s: pulo duplo com atributos no teto chega a no máximo 2 m (%.2f m)" % [id, peak - ground_y])
	player.reset_attributes()

	# Pegar e arremessar uma caixa (mãos para o cavaleiro, telecinese para o mago).
	var crate := _nearest_crate(arena, player)
	_check(crate != null, "%s: achou uma caixa" % id)
	if crate:
		player.global_position = crate.global_position + Vector3(0, -0.3, 1.6)
		await _frames(10)
		player.face_point(crate.global_position)
		await _frames(3)
		player.request_action(Player.SLOT_SPECIAL if player.get_ability(Player.SLOT_SPECIAL) is TelekinesisAbility else Player.ACTION_GRAB)
		await _frames(20)
		_check(player.held_body == crate, "%s: segurou a caixa" % id)
		player.face_point(player.get_aim_origin() + player.get_flat_forward() * 5.0)
		await _frames(20)
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(2)
		print("  velocidade da caixa: %.1f m/s (massa %.1f kg)" % [crate.linear_velocity.length(), crate.mass])
		_throw_speeds[id] = crate.linear_velocity.length()
		_check(player.held_body == null and crate.linear_velocity.length() > 2.0, "%s: arremessou a caixa" % id)

	# Editor de testes: atributos ao vivo.
	var carry := player.stats.carry_mass
	player.set_attribute(Attributes.Kind.STRENGTH, RULES.cap)
	_check(is_equal_approx(player.stats.carry_mass, RULES.carry_mass * RULES.multiplier_at_cap), "%s: Força 150 = carga %.0f kg" % [id, player.stats.carry_mass])
	player.set_attribute(Attributes.Kind.AGILITY, RULES.cap)
	_check(is_equal_approx(player.stats.sprint_speed, RULES.sprint_speed), "%s: Agilidade não muda a corrida" % id)
	_check(is_equal_approx(player.stats.jump_height, RULES.jump_height), "%s: Agilidade não muda o pulo" % id)
	_check(is_equal_approx(player.stats.attack_speed, pow(RULES.multiplier_at_cap, RULES.attack_speed_exponent)), "%s: Agilidade 150 = ataque %.2fx mais rápido" % [id, player.stats.attack_speed])
	player.reset_attributes()
	_check(is_equal_approx(player.stats.carry_mass, carry), "%s: atributos voltam ao padrão da classe" % id)
	_check(GameState.find_class(id).attributes.strength != RULES.cap, "%s: editor não altera o arquivo da classe" % id)

	# Barril explode.
	var barrel := _first_prop(arena, "explosive")
	if barrel:
		barrel.explode()
		await _frames(3)
		_check(not is_instance_valid(barrel), "%s: barril explodiu" % id)

	await _unload(arena)


func _test_dummy_fire_and_reset() -> void:
	print("\n--- Boneco: fogo próximo e reset ---")
	var arena := await _load_arena("knight")
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


# Critérios de aceite de design/gdd/mage-psionic.md.
func _test_psionic() -> void:
	print("\n--- Psiônico: dardo, campo lento, flutuar ---")
	var arena := await _load_arena("psionic")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var dart := player.get_ability(Player.SLOT_PRIMARY) as KineticDartAbility
	var field_ability := player.get_ability(Player.SLOT_MOBILITY) as SlowFieldAbility
	var mana := Player.Pool.MANA

	# Dardo: clique rápido e carga cheia.
	player.global_position = dummy.global_position + Vector3(0, 0.05, 1.8)
	await _frames(10)
	player.face_point(dummy.global_position + Vector3.UP * 1.2)
	await _frames(2)
	for test in [["clique", 1, dart.min_cost, 3.0, 6.0], ["carga cheia", 70, dart.cost, 14.0, 20.0]]:
		dummy.reset()
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(test[1])
		# Mede logo antes/depois de soltar (a Mana regenera durante a carga).
		var before := player.get_pool(mana)
		player.request_action(Player.ACTION_PRIMARY_RELEASE)
		await _frames(1)
		var spent := before - player.get_pool(mana)
		await _frames(30)
		# Clique de 1 quadro já tem ~3% de carga: tolerância de 0,6 de Mana.
		_check(absf(spent - test[2]) < 0.6, "dardo %s gastou %.1f de Mana (esperado %.0f)" % [test[0], spent, test[2]])
		_check(dummy.combo_damage >= test[3] and dummy.combo_damage <= test[4], "dardo %s: dano %.1f (entre %.0f e %.0f)" % [test[0], dummy.combo_damage, test[3], test[4]])

	# Tremor depois de segurar demais; F cancela a carga sem gastar.
	var before_cancel := player.get_pool(mana)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(160)
	var expected_tremor := dart.tremor_degrees / player.stats.mult(Attributes.Kind.DEXTERITY)
	_check(is_equal_approx(player.get_charge_tremor(), expected_tremor), "mira treme %.2f° após segurar demais" % player.get_charge_tremor())
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(2)
	_check(not player.is_charging() and player.get_pool(mana) >= before_cancel - 0.01, "F cancela a carga sem gastar Mana")

	# Dardo não aquece: 5 acertos numa caixa presa no lugar.
	var crate := _nearest_crate(arena, player)
	crate.freeze = true
	player.global_position = crate.global_position + Vector3(0, -0.3, 3.0)
	await _frames(10)
	for i in 5:
		player.face_point(crate.global_position)
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(1)
		player.request_action(Player.ACTION_PRIMARY_RELEASE)
		await _frames(20)
	_check(crate.heat == 0.0 and not crate.burning, "5 dardos não aquecem a caixa (calor %.1f)" % crate.heat)

	# Campo Lento: freia a caixa, não afeta o jogador, dura o tempo calculado.
	crate.freeze = false
	await _frames(30)
	player.face_point(crate.global_position)
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(2)
	var field := field_ability.get_active_field()
	_check(field != null, "Campo Lento criado na mira")
	var elapsed_frames := 2
	var top_speed := 0.0
	crate.linear_velocity = Vector3(8, 0, 0)
	for i in 20:
		await _frames(1)
		elapsed_frames += 1
		top_speed = maxf(top_speed, crate.linear_velocity.length())
	_check(top_speed <= 1.55, "caixa no campo não passa de 1,5 m/s (máx %.2f)" % top_speed)
	player.apply_knockback(Vector3(0, 0, 600))
	await _frames(2)
	elapsed_frames += 2
	_check(Vector2(player.velocity.x, player.velocity.z).length() > 3.0, "campo não freia o jogador (%.1f m/s)" % Vector2(player.velocity.x, player.velocity.z).length())
	while field_ability.get_active_field() != null and elapsed_frames < 600:
		await _frames(1)
		elapsed_frames += 1
	var lasted := elapsed_frames / 60.0
	_check(absf(lasted - field_ability.duration(player)) <= 0.1, "campo durou %.2f s (esperado %.2f)" % [lasted, field_ability.duration(player)])

	# Flutuar: queda limitada, drena Mana; sem Mana, cai normal.
	player.respawn()
	await _frames(5)
	player.global_position = player.global_position + Vector3.UP * 10.0
	player.velocity = Vector3.ZERO
	var mana_before_float := player.get_pool(mana)
	player.force_jump_held = true
	await _frames(40)
	_check(player.is_floating() and player.velocity.y >= -1.55, "flutuando, queda %.2f m/s" % player.velocity.y)
	_check(player.get_pool(mana) < mana_before_float, "flutuar drena Mana")
	player.spend(mana, 9999.0)
	await _frames(25)
	_check(not player.is_floating() and player.velocity.y < -2.0, "sem Mana o flutuar desliga (queda %.1f m/s)" % player.velocity.y)
	player.force_jump_held = false
	await _unload(arena)


# Critérios de aceite de design/gdd/mage-elementalist.md.
func _test_elementalist() -> void:
	print("\n--- Elementalista: bola de fogo, pilar, lamaçal ---")
	var arena := await _load_arena("mage")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var fireball := player.get_ability(Player.SLOT_PRIMARY) as FireballAbility
	var pillar_ability := player.get_ability(Player.SLOT_MOBILITY) as StonePillarAbility
	var mud := player.get_ability(Player.SLOT_SPECIAL) as MudAbility
	var mana := Player.Pool.MANA

	# Bola de Fogo: clique x carga cheia.
	player.global_position = dummy.global_position + Vector3(0, 0.05, 1.8)
	await _frames(10)
	player.face_point(dummy.global_position + Vector3.UP * 1.2)
	await _frames(2)
	var damages := []
	for test in [["clique", 1, fireball.min_cost], ["carga cheia", 60, fireball.cost]]:
		dummy.reset()
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(test[1])
		var before := player.get_pool(mana)
		player.request_action(Player.ACTION_PRIMARY_RELEASE)
		await _frames(1)
		var spent := before - player.get_pool(mana)
		await _frames(40)
		damages.append(dummy.combo_damage)
		_check(absf(spent - test[2]) < 0.8, "bola de fogo %s gastou %.1f de Mana (esperado %.0f)" % [test[0], spent, test[2]])
	_check(damages[1] > damages[0] and damages[0] > 0.0, "carga cheia dá mais dano (%.1f x %.1f)" % [damages[1], damages[0]])

	# Pilar mirado no céu: não nasce e não gasta Mana.
	player.respawn()
	await _frames(10)
	player.face_point(player.get_aim_origin() + Vector3(0, 10, 3))
	var before_sky := player.get_pool(mana)
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(3)
	_check(pillar_ability.get_active_pillars().is_empty() and player.get_pool(mana) >= before_sky - 0.01, "pilar no céu não nasce nem gasta Mana")

	# Escada sob o jogador: 3 degraus de 1, 2 e 3 m; o do meio no ponto mirado; sobe junto.
	player.debug_no_cooldowns = true
	player.debug_infinite_resources = true
	var aimed := player.global_position + player.get_flat_forward()
	player.face_point(aimed)
	var aim_direction := player.get_flat_forward()
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(40)
	var pillars := pillar_ability.get_active_pillars()
	_check(pillars.size() == 3, "escada tem 3 pilares (%d)" % pillars.size())
	if pillars.size() == 3:
		for i in 3:
			_check(absf(pillars[i].get_top_height() - pillar_ability.step_heights[i]) < 0.1, "degrau %d chega a %.2f m" % [i + 1, pillars[i].get_top_height()])
		var middle := pillars[1].global_position
		_check(Vector2(middle.x - aimed.x, middle.z - aimed.z).length() < 0.15, "pilar do meio nasce no ponto mirado")
		var along := (pillars[2].global_position - pillars[0].global_position).normalized()
		along.y = 0.0
		_check(along.normalized().dot(aim_direction) > 0.99, "o degrau mais alto fica mais longe de quem lança")
		_check(absf(player.global_position.y - pillars[0].get_top_height()) < 0.1, "jogador sobe junto com o 1º degrau (pés %.2f)" % player.global_position.y)
	for pillar in pillar_ability.get_active_pillars():
		pillar.sink()
	await _frames(50)
	player.respawn()
	await _frames(10)

	# Caixa em cima do pilar do meio: arremessada para cima.
	var crate := _nearest_crate(arena, player)
	crate.global_position = Vector3(3, 0.4, 16)
	crate.linear_velocity = Vector3.ZERO
	await _frames(40)
	player.face_point(crate.global_position)
	player.request_action(Player.SLOT_MOBILITY)
	var launch := 0.0
	for i in 30:
		await _frames(1)
		launch = maxf(launch, crate.linear_velocity.y)
	_check(launch > 4.0, "caixa em cima do pilar é arremessada (%.1f m/s para cima)" % launch)

	# Nova escada derruba a anterior.
	player.face_point(player.get_aim_origin() + Vector3(-4, -1.6, 4))
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(2)
	_check(pillar_ability.get_active_pillars().size() == 3, "só uma escada por vez (%d pilares)" % pillar_ability.get_active_pillars().size())

	# Pilar some depois de subir + durar + afundar (a escada nova, criada há 2 quadros).
	var last: StonePillar = pillar_ability.get_active_pillars().back()
	var lifespan := pillar_ability.rise_time + pillar_ability.lifetime + pillar_ability.sink_time
	var frames_alive := 2
	while is_instance_valid(last) and frames_alive < 900:
		await _frames(1)
		frames_alive += 1
	_check(absf(frames_alive / 60.0 - lifespan) < 0.15, "pilar durou %.2f s (esperado %.2f)" % [frames_alive / 60.0, lifespan])

	# Pedra subindo acerta o boneco: dano vem da massa e da velocidade do pilar.
	dummy.reset()
	player.global_position = dummy.global_position + Vector3(0, 0.05, 4)
	await _frames(5)
	player.face_point(dummy.global_position + Vector3(0, 0, 1))
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(30)
	_check(dummy.combo_damage > 25.0, "degrau mais alto subindo acerta o boneco (%.1f de dano)" % dummy.combo_damage)
	for pillar in pillar_ability.get_active_pillars():
		pillar.sink()
	await _frames(50)

	# Lamaçal: freia objeto, apaga fogo, deixa o jogador lento.
	player.respawn()
	await _frames(10)
	player.face_point(player.get_aim_origin() + player.get_flat_forward() * 5.0 + Vector3.DOWN * 1.6)
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(3)
	var patch := mud.get_active_patch()
	_check(patch != null, "lamaçal criado no chão mirado")
	if patch:
		crate = _nearest_crate(arena, player)
		crate.global_position = patch.global_position + Vector3(0, 0.4, 0)
		crate.linear_velocity = Vector3(6, 0, 0)
		await _frames(60)
		_check(crate.linear_velocity.length() < 1.0, "caixa a 6 m/s para na lama (%.2f m/s após 1 s)" % crate.linear_velocity.length())
		crate.ignite()
		await _frames(5)
		_check(not crate.burning, "caixa em chamas apaga na lama")
		player.global_position = patch.global_position + Vector3(0, 0.05, 1.0)
		await _walk_toward(player, patch.global_position + Vector3(0, 1.6, -10), 25)
		_check(is_equal_approx(player.get_speed_factor(), mud.character_speed), "jogador na lama anda a %.0f%% da velocidade" % (player.get_speed_factor() * 100.0))
		player.global_position = patch.global_position + Vector3(0, 0.05, 1.5)
		player.face_point(patch.global_position + Vector3(0, 1.6, -10))
		Input.action_press("move_forward")
		await _frames(20)
		var mud_speed := Vector2(player.velocity.x, player.velocity.z).length()
		Input.action_release("move_forward")
		_check(absf(mud_speed - player.stats.walk_speed * mud.character_speed) < 0.2, "velocidade real na lama %.2f m/s (esperado %.2f)" % [mud_speed, player.stats.walk_speed * mud.character_speed])
		player.global_position = patch.global_position + Vector3(0, 0.05, 6.0)
		await _frames(5)
		_check(is_equal_approx(player.get_speed_factor(), 1.0), "fora da lama a velocidade volta ao normal")
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


# Regra 2 dos atributos: nível 1 a 99, com pontos suficientes para 99/99/50/15.
func _test_progression() -> void:
	print("\n--- Progressão: níveis e pontos ---")
	_check(RULES.total_points() == 259, "total de pontos = %d (99 + 99 + 50 + 15, começando de 1)" % RULES.total_points())
	_check(RULES.points_at_level(1) == 0 and RULES.points_at_level(99) == 259, "nível 1 tem 0 pontos e o 99 tem todos")
	var lowest := 999
	var highest := 0
	var sum := 0
	for level in range(2, 100):
		var gained := RULES.points_gained_at(level)
		sum += gained
		lowest = mini(lowest, gained)
		highest = maxi(highest, gained)
	_check(sum == 259 and lowest >= 1, "ganho por nível varia de %d a %d e soma %d" % [lowest, highest, sum])
	print("  pontos acumulados: nível 2 = %d, 10 = %d, 27 = %d, 50 = %d, 75 = %d" % [RULES.points_at_level(2), RULES.points_at_level(10), RULES.points_at_level(27), RULES.points_at_level(50), RULES.points_at_level(75)])

	var build := Attributes.new()
	for kind: Attributes.Kind in Attributes.Kind.values():
		build.set_value(kind, 1.0)
	_check(RULES.is_legal_build(build, 1), "nível 1 com tudo em 1 é válido")
	build.strength = 99.0
	build.intelligence = 99.0
	build.agility = 50.0
	build.vitality = 15.0
	_check(RULES.is_legal_build(build, 99) and RULES.spent_points(build) == 259, "nível 99 paga exatamente 99/99/50/15")
	build.dexterity = 2.0
	_check(not RULES.is_legal_build(build, 99), "um ponto a mais não cabe")
	build.dexterity = 1.0
	build.strength = 100.0
	build.intelligence = 98.0
	_check(not RULES.is_legal_build(build, 99), "nenhum atributo passa de 99 com pontos")
	for data in GameState.CLASSES:
		var level := RULES.level_for_build(data.attributes)
		_check(RULES.is_legal_build(data.attributes, level), "%s é uma build válida no nível %d" % [data.display_name, level])

	# Subir de nível e gastar pontos no jogador; o editor volta ao nível 1.
	var arena := await _load_arena("knight")
	var player: Player = arena.player
	var editor: Node = arena.get_node("DebugEditor")
	editor._apply_level_one()
	_check(player.level == 1 and player.get_free_points() == 0, "nível 1 sem pontos livres")
	_check(not player.raise_attribute(Attributes.Kind.STRENGTH), "sem pontos, não sobe atributo")
	player.level_up()
	var free := player.get_free_points()
	_check(free == RULES.points_gained_at(2), "subir para o nível 2 dá %d pontos" % free)
	_check(player.raise_attribute(Attributes.Kind.STRENGTH) and player.get_free_points() == free - 1, "gastar ponto sobe o atributo")
	editor._apply_level_max()
	var attrs := player.class_data.attributes
	_check(player.level == 99 and player.get_free_points() == 0 and RULES.is_legal_build(attrs, 99), "preset do nível 99 é válido")
	_check(not player.level_up(), "não passa do nível 99")
	await _unload(arena)


# Degraus da Escada de Pedra: W sobe sozinho; sem W, não (design/gdd/mage-elementalist.md).
func _test_stair_auto_climb() -> void:
	print("\n--- Escada de Pedra: subir com W ---")
	var arena := await _load_arena("mage")
	var player: Player = arena.player
	var pillar_ability := player.get_ability(Player.SLOT_MOBILITY) as StonePillarAbility
	player.debug_infinite_resources = true
	player.debug_no_cooldowns = true
	player.global_position = Vector3(20, 0.05, 25)
	await _frames(5)
	player.face_point(Vector3(20, 0, 21))
	await _frames(1)
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(35)
	_check(pillar_ability.get_active_pillars().size() == 3, "escada criada para o teste")
	# De costas para a escada, andando de ré até encostar: não sobe.
	player.global_position = Vector3(20, 0.05, 23.3)
	player.face_point(Vector3(20, 1.6, 40))
	Input.action_press("move_back")
	await _frames(30)
	Input.action_release("move_back")
	_check(player.global_position.y < 0.1, "de ré encostado no degrau, não sobe (y %.2f)" % player.global_position.y)
	# De frente, com W: sobe os 3 degraus.
	player.face_point(Vector3(20, 3.6, 0))
	var peak := 0.0
	Input.action_press("move_forward")
	for i in 70:
		await _frames(1)
		peak = maxf(peak, player.global_position.y)
	Input.action_release("move_forward")
	_check(peak > 2.5, "segurando W sobe até o topo (%.2f m)" % peak)
	await _unload(arena)


# Regressão: subir escada com ritmo regular, sem perder velocidade nem dar tranco na câmera.
func _test_stair_rhythm() -> void:
	print("\n--- Ritmo da subida ---")
	var arena := await _load_arena("knight")
	var player: Player = arena.player
	# Mais longe que o pé da escada, para chegar já na velocidade de andar.
	player.global_position = Vector3(-20, 0.05, 17)
	player.face_point(Vector3(-20, 1.6, -10))
	await _frames(5)
	Input.action_press("move_forward")
	var last_y := player.global_position.y
	var last_z := player.global_position.z
	var last_camera := player.get_aim_origin().y
	var last_step := -1
	var intervals: Array[float] = []
	var speeds: Array[float] = []
	var max_camera_jump := 0.0
	for i in 120:
		await _frames(1)
		var y := player.global_position.y
		if y > 1.95:
			break
		if y - last_y > 0.05:
			if last_step >= 0:
				intervals.append(i - last_step)
			last_step = i
		if last_step >= 0:
			speeds.append(absf(player.global_position.z - last_z) * 60.0)
			max_camera_jump = maxf(max_camera_jump, player.get_aim_origin().y - last_camera)
		last_y = y
		last_z = player.global_position.z
		last_camera = player.get_aim_origin().y
	Input.action_release("move_forward")
	print("  quadros entre degraus: %s" % [intervals])
	print("  avanço máx/mín: %.2f / %.2f m/s; maior salto da câmera num quadro: %.3f m" % [speeds.max(), speeds.min(), max_camera_jump])
	_check(intervals.size() >= 7 and intervals.max() - intervals.min() <= 1.0, "intervalo entre degraus regular (%s quadros)" % [intervals])
	_check(speeds.max() <= player.stats.walk_speed * 1.15 and speeds.min() >= player.stats.walk_speed * 0.8, "velocidade constante na escada (%.2f a %.2f m/s)" % [speeds.min(), speeds.max()])
	_check(max_camera_jump < 0.09, "câmera sobe sem tranco (máx %.3f m por quadro)" % max_camera_jump)
	await _unload(arena)


func _test_dash() -> void:
	print("\n--- Dash (Ctrl) ---")
	var arena := await _load_arena("knight")
	var player: Player = arena.player
	var dash := player.get_ability(Player.SLOT_DASH) as DashAbility
	_check(InputMap.has_action("dash") and dash != null, "dash existe para a classe")
	for id in GameState.CLASSES:
		_check(id.dash_ability != null, "%s tem dash" % id.display_name)

	# Parado: vai para a frente.
	player.respawn()
	await _frames(10)
	var forward := player.get_flat_forward()
	var start := player.global_position
	var stamina := player.get_pool(Player.Pool.STAMINA)
	_press_key(KEY_CTRL)
	await _frames(2)
	_check(stamina - player.get_pool(Player.Pool.STAMINA) > dash.cost - 1.0, "tecla Ctrl faz o dash e gasta Vigor")
	_check(player.get_cooldown(Player.SLOT_DASH) > 0.0, "dash entra em recarga")
	await _frames(58)
	var moved := player.global_position - start
	_check(moved.dot(forward) > 2.5 and moved.dot(forward) < 4.5, "dash parado anda %.2f m para a frente" % moved.dot(forward))


	# Com direção: vai para o lado apertado.
	await _frames(30)
	var right := forward.cross(Vector3.UP).normalized()
	start = player.global_position
	Input.action_press("move_right")
	await _frames(2)
	start = player.global_position
	player.request_action(Player.SLOT_DASH)
	await _frames(12)
	Input.action_release("move_right")
	moved = player.global_position - start
	_check(moved.dot(right) > 2.0 and absf(moved.dot(forward)) < 0.3, "Ctrl + direita vai para a direita (%.2f m)" % moved.dot(right))

	# Não atravessa parede: bloco de teste à frente (torre de 3 m, x = -38).
	await _frames(70)
	player.global_position = Vector3(-38, 0.05, -17.5)
	await _frames(5)
	player.face_point(Vector3(-38, 1.6, -30))
	await _frames(2)
	player.request_action(Player.SLOT_DASH)
	await _frames(30)
	_check(player.global_position.z > -18.6, "dash não atravessa a parede (z %.2f; parede em -18,5)" % player.global_position.z)
	_check(Vector2(player.velocity.x, player.velocity.z).length() <= player.stats.sprint_speed, "dash não deixa velocidade sobrando")

	# Arremesso herda o movimento de quem arremessa.
	var crate := _nearest_crate(arena, player)
	crate.global_position = player.get_aim_origin() + Vector3(0, 0, 1.5)
	player.hold(crate, {"telekinetic": false, "distance": 1.5, "stiffness": 10.0, "throw_speed": 5.0, "carry_mass": 1000.0, "drain": 0.0})
	player.face_point(player.get_aim_origin() + Vector3(0, 0, 10))
	await _frames(3)
	player.velocity = Vector3(0, 0, 7)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(1)
	_check(crate.linear_velocity.z > 10.0, "arremesso correndo soma o movimento (%.1f m/s)" % crate.linear_velocity.z)
	await _unload(arena)


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


## Altura máxima atingida até tocar o chão (no máximo 3 s).
func _peak_until_landing(player: Player) -> float:
	var peak := player.global_position.y
	for i in 180:
		await _frames(1)
		peak = maxf(peak, player.global_position.y)
		if player.is_on_floor() and player.velocity.y <= 0.0:
			break
	await _frames(5)
	return peak


## Anda para frente (tecla W simulada) por `frames` quadros, olhando para `target`.
func _walk_toward(player: Player, target: Vector3, frames: int) -> void:
	player.face_point(target)
	Input.action_press("move_forward")
	await _frames(frames)
	Input.action_release("move_forward")
	await _frames(10)


# Degraus: até 0,4 m sobe só andando; 0,5 m exige pulo; a escada de 0,2 m chega a 2 m.
func _test_steps() -> void:
	print("\n--- Degraus: subir andando ---")
	var arena := await _load_arena("knight")
	var player: Player = arena.player
	var rules: AttributeRules = player.rules
	# Fileira de alturas em x = -10: 0,4 m em z = 3, 0,5 m em z = 0.
	player.global_position = Vector3(-10, 0.05, 6)
	await _frames(5)
	await _walk_toward(player, Vector3(-10, 1.6, -30), 40)
	_check(player.is_on_floor() and absf(player.global_position.y - rules.step_height) < 0.05, "sobe degrau de %.1f m só andando (y %.2f)" % [rules.step_height, player.global_position.y])
	player.global_position = Vector3(-10, 0.05, 2.6)
	await _frames(5)
	await _walk_toward(player, Vector3(-10, 1.6, -30), 40)
	_check(player.global_position.y < 0.1, "degrau de 0,5 m bloqueia sem pular (y %.2f)" % player.global_position.y)
	# Escada até a plataforma de 2 m (x = -20).
	player.global_position = Vector3(-20, 0.05, 15)
	await _frames(5)
	player.face_point(Vector3(-20, 3.6, 0))
	var stair_top := 0.0
	Input.action_press("move_forward")
	for i in 90:
		await _frames(1)
		stair_top = maxf(stair_top, player.global_position.y)
	Input.action_release("move_forward")
	await _frames(10)
	_check(stair_top > 1.9, "escada de 0,2 m chega à plataforma de 2 m (topo %.2f m)" % stair_top)
	# Rampa de 30° (x = -30, z = -2) continua subindo normal com o corpo cilíndrico.
	player.global_position = Vector3(-30, 0.05, 4)
	await _frames(5)
	await _walk_toward(player, Vector3(-30, 3.6, -10), 70)
	_check(player.global_position.y > 1.0, "sobe a rampa de 30° andando (y %.2f)" % player.global_position.y)

	await _unload(arena)


func _load_arena(id: String) -> Node3D:
	GameState.selected_class = GameState.find_class(id)
	var arena: Node3D = ARENA.instantiate()
	add_child(arena)
	await _frames(40)
	return arena


func _unload(arena: Node) -> void:
	await _frames(30)
	arena.queue_free()
	get_tree().paused = false
	await _frames(3)


func _nearest_crate(arena: Node, player: Player) -> PhysicsProp:
	var best: PhysicsProp
	for node in arena.get_children():
		if node is PhysicsProp and node.material_data.flammable and not node.material_data.explosive and not node.burning:
			if best == null or node.global_position.distance_to(player.global_position) < best.global_position.distance_to(player.global_position):
				best = node
	return best


func _first_prop(arena: Node, material_file: String) -> PhysicsProp:
	for node in arena.get_children():
		if node is PhysicsProp and node.material_data.resource_path.ends_with(material_file + ".tres"):
			return node
	return null


func _check(condition: bool, label: String) -> void:
	_checks += 1
	print(("  ok    " if condition else "  FALHA ") + label)
	if not condition:
		_failures.append(label)


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


## Simula apertar e soltar uma tecla física, passando pelo caminho real de entrada do jogo.
func _press_key(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()

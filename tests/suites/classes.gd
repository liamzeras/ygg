extends "res://tests/suite_base.gd"
## Suíte da frente classes: percurso completo de cada classe (habilidades, pulo, pegar e
## arremessar, editor de atributos), Gravidade, Fogo, Terra, atributos e progressão.

const RULES := preload("res://assets/data/attribute_rules.tres")

var _sprint_speeds: Array[float] = []
var _throw_speeds := {}


func run() -> void:
	_test_attribute_curve()
	for id in ["fire", "earth", "gravity", "psionic"]:
		await _test_class(id)
	_check(_sprint_speeds.size() == GameState.CLASSES.size() + GameState.HIDDEN_CLASSES.size() and _sprint_speeds.all(func(s: float) -> bool: return is_equal_approx(s, _sprint_speeds[0])), "velocidade de corrida igual entre classes")
	_check(_throw_speeds.get("psionic", 0.0) > _throw_speeds.get("fire", 0.0), "Telecinese Acelerada arremessa mais rápido que as mãos do Mago do Fogo (%.1f x %.1f m/s)" % [_throw_speeds.get("psionic", 0.0), _throw_speeds.get("fire", 0.0)])
	await _test_psionic()
	await _test_fire()
	await _test_earth()
	await _test_progression()
	await _test_stair_auto_climb()
	await _test_earth_strikes()
	await _test_earthquake()
	await _test_fire_kit()
	await _test_gravity_kit()


func _test_attribute_curve() -> void:
	var human := RULES.human
	var at_cap := Attributes.new()
	for kind: Attributes.Kind in Attributes.Kind.values():
		_check(is_equal_approx(RULES.multiplier(human, kind), 1.0), "humano = 1x em %s" % Attributes.NAMES[kind])
	at_cap.strength = RULES.cap
	at_cap.dexterity = RULES.cap
	_check(is_equal_approx(RULES.multiplier(at_cap, Attributes.Kind.STRENGTH), RULES.multiplier_at_cap), "Força no teto = %sx" % RULES.multiplier_at_cap)
	_check(is_equal_approx(RULES.multiplier(at_cap, Attributes.Kind.DEXTERITY), RULES.multiplier_at_cap), "Destreza no teto = %sx" % RULES.multiplier_at_cap)


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

	# Habilidade principal de perto do boneco.
	player.global_position = dummy.global_position + Vector3(0, 0.05, 1.8)
	await _frames(10)
	player.face_point(dummy.global_position + Vector3.UP * 1.2)
	await _frames(2)
	var primary := player.get_ability(Player.SLOT_PRIMARY)
	if primary:
		var before: float = player.get_pool(primary.cost_pool)
		player.request_action(Player.SLOT_PRIMARY)
		if primary.is_chargeable():
			await _frames(2)
			player.request_action(Player.ACTION_PRIMARY_RELEASE)
		await _frames(45)
		_check(player.get_pool(primary.cost_pool) < before, "%s: principal gastou %s" % [id, Player.POOL_NAMES[primary.cost_pool]])
		_check(dummy.combo_damage > 0.0, "%s: boneco tomou dano (%.1f, DPS %.1f)" % [id, dummy.combo_damage, dummy.get_dps()])
	else:
		# Botão esquerdo vazio (a Terra ainda não tem ataque): não gasta nada nem dá erro.
		var mana_before := player.get_pool(Player.Pool.MANA)
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(45)
		_check(not player.is_charging() and player.get_pool(Player.Pool.MANA) >= mana_before - 0.01 and dummy.combo_damage == 0.0, "%s: botão esquerdo vazio não faz nada" % id)

	# Mobilidade (se a classe tiver).
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

	# Pegar e arremessar uma caixa (mãos para Fogo e Terra, telecinese para a Gravidade).
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
		player.request_action(Player.ACTION_GRAB)
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


# Critérios de aceite de design/gdd/mage-elementalist.md (parte do Fogo).
func _test_fire() -> void:
	print("\n--- Fogo: bola de fogo ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var fireball := player.get_ability(Player.SLOT_PRIMARY) as FireballAbility
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
	await _unload(arena)


# Critérios de aceite de design/gdd/mage-elementalist.md (parte da Terra).
func _test_earth() -> void:
	print("\n--- Terra: pilar, lamaçal ---")
	var arena := await _load_arena("earth")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var pillar_ability := player.get_ability(Player.SLOT_MOBILITY) as StonePillarAbility
	var mud := player.get_ability(Player.SLOT_UTILITY) as MudAbility
	var mana := Player.Pool.MANA

	# Pilar mirado no céu: não nasce e não gasta Mana.
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
	player.request_action(Player.SLOT_UTILITY)
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
	var arena := await _load_arena("fire")
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
	var arena := await _load_arena("earth")
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



# Soco e Chute de Pedra (design/gdd/mage-earth.md, critérios 1 a 4).
func _test_earth_strikes() -> void:
	print("\n--- Terra: soco e chute de pedra ---")
	var arena := await _load_arena("earth")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var punch := player.get_ability(Player.SLOT_PRIMARY) as StoneStrikeAbility
	var kick := player.get_ability(Player.SLOT_SECONDARY) as StoneStrikeAbility
	_check(punch != null and kick != null, "Terra tem soco no botão esquerdo e chute no direito")
	if punch == null or kick == null:
		await _unload(arena)
		return
	player.debug_infinite_resources = true
	player.debug_no_cooldowns = true
	var dummy_home := dummy.global_position
	var site := Vector3(40, 0, 40)
	var ahead := site + Vector3(0, 0, -1.2)

	# Pedra e madeira no alto de um pedestal: a pedra recebe o dobro da quantidade de movimento.
	var momenta: Array[float] = []
	for material: PropMaterial in [arena.STONE, arena.WOOD]:
		var pedestal: StaticBody3D = arena._static_box(ahead + Vector3(0, 0.45, 0), Vector3(0.5, 0.9, 0.5), null)
		var block: PhysicsProp = arena._prop(material, PhysicsProp.Form.BOX, Vector3(0.4, 0.4, 0.4), ahead + Vector3(0, 1.11, 0))
		_place(player, site)
		await _frames(30)
		await _strike(player, site, Player.SLOT_PRIMARY)
		momenta.append(-block.linear_velocity.z * block.mass)
		block.queue_free()
		pedestal.queue_free()
		await _frames(3)
	var ratio := momenta[0] / maxf(momenta[1], 0.001)
	_check(momenta[1] > 0.0 and absf(ratio - punch.earth_multiplier) < 0.3, "soco dá %.1fx mais impulso na pedra que na madeira (%.0f x %.0f N·s)" % [ratio, momenta[0], momenta[1]])

	# Caixa no chão: o soco passa por cima, o chute acerta.
	var crate: PhysicsProp = arena._prop(arena.WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), ahead + Vector3(0, 0.31, 0))
	_place(player, site)
	await _frames(30)
	await _strike(player, site, Player.SLOT_PRIMARY)
	await _frames(3)
	_check(crate.linear_velocity.length() < 0.2, "soco não atinge caixa no chão (%.2f m/s)" % crate.linear_velocity.length())
	await _strike(player, site, Player.SLOT_SECONDARY)
	_check(crate.linear_velocity.length() > 1.0, "chute atinge caixa no chão (%.1f m/s)" % crate.linear_velocity.length())
	crate.queue_free()
	await _frames(3)

	# Boneco: soco e chute acertam.
	dummy.global_position = Vector3(ahead.x, 0.0, ahead.z)
	dummy.reset()
	await _strike(player, site, Player.SLOT_PRIMARY)
	var plain := dummy.combo_damage
	_check(plain > 0.0, "soco acerta o boneco (%.1f de dano)" % plain)
	dummy.reset()
	await _strike(player, site, Player.SLOT_SECONDARY)
	_check(dummy.combo_damage > 0.0, "chute acerta o boneco (%.1f de dano)" % dummy.combo_damage)
	dummy.global_position = dummy_home
	await _frames(3)

	# Socar o ar sem revestimento não lança pedregulho.
	var pebbles := _pebble_count()
	await _strike(player, site, Player.SLOT_PRIMARY)
	_check(_pebble_count() == pebbles and not punch.is_coated(player), "soco no ar sem revestimento não lança pedregulho")

	# Socar a parede reveste as mãos (não os pés).
	var wall: StaticBody3D = arena._static_box(ahead + Vector3(0, 1.2, -0.3), Vector3(2, 2.4, 0.3), null)
	await _frames(2)
	await _strike(player, site, Player.SLOT_PRIMARY)
	_check(punch.is_coated(player) and punch.get_status_text(player) != "", "soco na parede reveste as mãos (%s)" % punch.get_status_text(player))
	_check(not kick.is_coated(player), "revestir as mãos não reveste os pés")

	# Revestido, o soco no boneco dá mais dano.
	dummy.global_position = Vector3(ahead.x, 0.0, ahead.z + 0.3)
	dummy.reset()
	await _strike(player, site, Player.SLOT_PRIMARY)
	_check(dummy.combo_damage > plain, "revestido, o soco dá mais dano (%.1f x %.1f)" % [dummy.combo_damage, plain])
	dummy.global_position = dummy_home
	wall.queue_free()
	await _frames(3)

	# Revestido, socar o ar lança um pedregulho.
	pebbles = _pebble_count()
	await _strike(player, site, Player.SLOT_PRIMARY)
	var thrown := _pebble_count() - pebbles
	_check(thrown == 1, "revestido, soco no ar lança 1 pedregulho (%d)" % thrown)
	await _unload(arena)


# Terremoto (design/gdd/mage-earth.md, critérios 5 a 7).
func _test_earthquake() -> void:
	print("\n--- Terra: terremoto ---")
	var arena := await _load_arena("earth")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var quake := player.get_ability(Player.SLOT_SPECIAL) as EarthquakeAbility
	_check(quake != null, "Terra tem Terremoto no F")
	if quake == null:
		await _unload(arena)
		return
	_check(is_equal_approx(quake.side_for_level(99, 99), 9.0), "nível 99 = 9 x 9 m")
	var share := pow(quake.side_for_level(50, 99), 2) / 81.0
	_check(absf(share - 50.0 / 99.0) < 0.001, "nível 50 = %.1f%% da área máxima" % (share * 100.0))
	player.debug_infinite_resources = true
	player.debug_no_cooldowns = true
	player.set_level(99)
	var site := Vector3(40, 0, 40)
	dummy.global_position = site + Vector3(0, 0, -2)
	dummy.reset()
	var crate: PhysicsProp = arena._prop(arena.WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), site + Vector3(2, 0.31, -1.5))
	_place(player, site + Vector3(0, 0, 1))
	await _frames(30)
	var health := player.get_node("Health") as Health
	var hp := health.current
	player.face_point(site + Vector3(0, 0, -1.5))
	await _frames(2)
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(3)
	var zone := quake.get_active_zone()
	_check(zone != null, "terremoto criado no chão mirado")
	if zone == null:
		await _unload(arena)
		return
	_check(crate.linear_velocity.y > 3.0, "caixa na área é jogada para cima (%.1f m/s)" % crate.linear_velocity.y)
	_check(dummy.combo_damage > 10.0, "boneco na área toma dano (%.1f)" % dummy.combo_damage)
	_check(health.current >= hp, "quem lançou não toma dano")
	await _frames(30)
	var pillars := zone.get_pillars()
	_check(pillars.size() == 81, "nível 99: 9 x 9 colunas (%d)" % pillars.size())
	var lowest := INF
	var highest := 0.0
	var spikes := 0
	for pillar in pillars:
		lowest = minf(lowest, pillar.get_top_height() - site.y)
		highest = maxf(highest, pillar.get_top_height() - site.y)
		if pillar.width < 0.99:
			spikes += 1
	_check(lowest >= quake.min_height - 0.02 and highest <= quake.max_height + 0.02, "relevo entre %.2f e %.2f m" % [lowest, highest])
	_check(spikes >= 1, "tem estalagmites (%d)" % spikes)
	var boulders := []
	boulders.assign(zone.get_boulders())
	_check(not boulders.is_empty(), "tem pedregulhos soltos (%d)" % boulders.size())
	await _frames(int((quake.lifetime + quake.sink_time) * 60.0) + 30)
	_check(not is_instance_valid(zone) and _all_freed(boulders), "relevo e pedregulhos somem depois de %.0f s" % quake.lifetime)

	# Nível 1: uma coluna só.
	player.set_level(1)
	player.respawn()
	await _frames(10)
	player.face_point(player.get_aim_origin() + player.get_flat_forward() * 4.0 + Vector3.DOWN * 1.6)
	await _frames(2)
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(3)
	var small := quake.get_active_zone()
	_check(small != null and small.get_pillars().size() == 1, "nível 1: uma coluna só")
	crate.queue_free()
	await _unload(arena)


func _place(player: Player, at: Vector3) -> void:
	player.global_position = at + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO


## Golpeia da posição `site`, olhando para −z na altura do peito.
func _strike(player: Player, site: Vector3, slot: StringName) -> void:
	_place(player, site)
	player.face_point(site + Vector3(0, 1.4, -10))
	await _frames(2)
	player.request_action(slot)
	await _frames(2)


func _pebble_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group(&"physics_props"):
		if node is PhysicsProp and (node as PhysicsProp).display_name == "Pedregulho":
			count += 1
	return count


func _all_freed(list: Array) -> bool:
	for item: Variant in list:
		if is_instance_valid(item):
			return false
	return true


# Kit do Mago do Fogo (design/gdd/mage-fire.md, critérios 1 a 7).
func _test_fire_kit() -> void:
	print("\n--- Fogo: jatos, fogo-fátuo, lava, almôndega ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var fireball := player.get_ability(Player.SLOT_PRIMARY) as FireballAbility
	var wisp := player.get_ability(Player.SLOT_SECONDARY) as FireWispAbility
	var lava := player.get_ability(Player.SLOT_MOBILITY) as LavaFloorAbility
	var shield := player.get_ability(Player.SLOT_SPECIAL) as FireShieldAbility
	var jets := player.get_ability(Player.SLOT_UTILITY) as JetFlightAbility
	_check(wisp != null and lava != null and shield != null and jets != null, "Fogo tem Fogo-Fátuo, Chão de Lava, Almôndega e Jatos")
	if wisp == null or lava == null or shield == null or jets == null:
		await _unload(arena)
		return
	player.debug_infinite_resources = true
	player.debug_no_cooldowns = true
	var dummy_home := dummy.global_position
	var health := player.get_node("Health") as Health
	var site := Vector3(40, 0, 40)

	# Jatos de Fogo: voo, subida, pairar, impulso e fim no tempo da fórmula.
	player.set_level(99)
	_check(is_equal_approx(jets.duration(player), jets.max_duration), "nível 99: voo de %.0f s" % jets.duration(player))
	player.set_level(20)
	var flight := jets.duration(player)
	_place(player, site)
	player.face_point(site + Vector3(0, 1.6, -10))
	await _frames(10)
	player.request_action(Player.SLOT_UTILITY)
	await _frames(2)
	var flown := 2
	_check(player.is_flying(), "Ctrl liga o voo")
	player.force_jump_held = true
	await _frames(40)
	flown += 40
	_check(player.global_position.y > 2.0, "voando, segurar Espaço sobe (%.1f m)" % player.global_position.y)
	player.force_jump_held = false
	await _frames(25)
	var hover := player.global_position.y
	await _frames(20)
	flown += 45
	_check(absf(player.global_position.y - hover) < 0.3, "parado no ar, paira (variou %.2f m)" % absf(player.global_position.y - hover))
	player.debug_infinite_resources = false
	var mana := player.get_pool(Player.Pool.MANA)
	player.request_action(Player.SLOT_UTILITY)
	await _frames(2)
	flown += 2
	var boost := -player.velocity.z
	_check(boost > 10.0 and player.get_pool(Player.Pool.MANA) < mana, "Ctrl de novo dá impulso na mira e gasta Mana (%.1f m/s)" % boost)
	player.debug_infinite_resources = true
	while player.is_flying() and flown < 900:
		await _frames(1)
		flown += 1
	_check(absf(flown / 60.0 - flight) < 0.15, "voo durou %.2f s (esperado %.2f no nível 20)" % [flown / 60.0, flight])
	await _frames(20)
	_check(player.velocity.y < -1.0 or player.is_on_floor(), "depois do voo, cai")
	player.respawn()
	await _frames(10)

	# Fogo-Fátuo: não some sozinho.
	_place(player, site)
	player.face_point(site + Vector3(0, 40, -10))
	await _frames(3)
	player.request_action(Player.SLOT_SECONDARY)
	await _frames(620)
	var lost := _first_of(arena, "FireWispProjectile")
	_check(lost != null, "Fogo-Fátuo continua no ar depois de 10 s")
	if lost:
		lost.queue_free()

	# No boneco: queima por 10 s com dano de fogo.
	dummy.global_position = site + Vector3(0, 0, -4)
	dummy.reset()
	player.face_point(dummy.global_position + Vector3.UP * 1.2)
	await _frames(3)
	player.request_action(Player.SLOT_SECONDARY)
	var waited := 0
	while BurnEffect.of(dummy) == null and waited < 180:
		await _frames(1)
		waited += 1
	var burn := BurnEffect.of(dummy)
	_check(burn != null and _first_of(arena, "FireWispProjectile") == null, "Fogo-Fátuo some ao bater e põe o boneco em chamas")
	await _frames(300)
	_check(dummy.fire_damage > 0.0 and BurnEffect.of(dummy) != null, "boneco ainda queima depois de 5 s (%.1f de dano de fogo)" % dummy.fire_damage)
	await _frames(330)
	_check(BurnEffect.of(dummy) == null, "queimadura acaba depois de %.0f s" % wisp.burn_duration)
	dummy.global_position = dummy_home

	# Num bloco de pedra: em chamas mesmo sem ser inflamável.
	var stone: PhysicsProp = arena._prop(arena.STONE, PhysicsProp.Form.BOX, Vector3(0.8, 0.8, 0.8), site + Vector3(0, 0.41, -3))
	await _frames(30)
	player.face_point(stone.global_position)
	await _frames(3)
	player.request_action(Player.SLOT_SECONDARY)
	waited = 0
	while BurnEffect.of(stone) == null and waited < 180:
		await _frames(1)
		waited += 1
	_check(BurnEffect.of(stone) != null and not stone.material_data.flammable, "Fogo-Fátuo deixa em chamas um bloco de pedra")
	stone.queue_free()
	await _frames(3)

	# Chão de Lava: tamanho e duração pelo nível, dano e fogo.
	player.set_level(99)
	_check(is_equal_approx(lava.side(player), lava.max_side) and is_equal_approx(lava.duration(player), lava.max_duration), "nível 99: lava de %.0f x %.0f m por %.0f s" % [lava.side(player), lava.side(player), lava.duration(player)])
	player.set_level(30)
	dummy.global_position = site + Vector3(0, 0, -3)
	dummy.reset()
	var crate: PhysicsProp = arena._prop(arena.WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), site + Vector3(1.5, 0.31, -3))
	_place(player, site + Vector3(0, 0, 4))
	await _frames(30)
	var hp := health.current
	player.face_point(site + Vector3(0, 0, -2))
	await _frames(3)
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(3)
	var pool := lava.get_active_pool()
	_check(pool != null and is_equal_approx(pool.side, lava.side(player)), "lava criada no chão mirado com %.1f m de lado (nível 30)" % lava.side(player))
	await _frames(120)
	_check(dummy.fire_damage > 5.0, "lava causa dano de fogo no boneco (%.1f em 2 s)" % dummy.fire_damage)
	_check(crate.burning, "lava acende caixa de madeira")
	_check(health.current >= hp, "fora da lava, quem lançou não se queima")
	await _frames(int(lava.duration(player) * 60.0) - 123 + 15)
	_check(lava.get_active_pool() == null, "lava some depois de %.1f s (nível 30)" % lava.duration(player))
	crate.queue_free()
	dummy.global_position = dummy_home
	await _frames(3)

	# Almôndega de Fogo: consome dardo e bola de fogo que chegam; a do mago sai.
	_place(player, site)
	player.face_point(site + Vector3(0, 1.6, -10))
	await _frames(5)
	hp = health.current
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(2)
	var ball := shield.get_active_shield()
	_check(ball != null, "F cria a Almôndega em volta do mago")
	if ball:
		var dart := KineticDartProjectile.new()
		dart.mass = 0.007
		arena.add_child(dart)
		dart.global_position = site + Vector3(0.2, 1.2, -8)
		dart.launch(Vector3(0, 0, 40), Vector3.ZERO)
		var enemy_ball := FireballProjectile.new()
		enemy_ball.ability = fireball
		enemy_ball.mass = 0.01
		enemy_ball.heat = 60.0
		arena.add_child(enemy_ball)
		enemy_ball.global_position = site + Vector3(-0.2, 1.2, -8)
		enemy_ball.launch(Vector3(0, 0, 25), Vector3.ZERO)
		await _frames(40)
		_check(ball.consumed == 2, "Almôndega consome o dardo e a bola de fogo (%d)" % ball.consumed)
		_check(health.current >= hp, "com a Almôndega, o mago não toma dano")
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(2)
		player.request_action(Player.ACTION_PRIMARY_RELEASE)
		await _frames(8)
		# A Bola de Fogo nasce na cena atual, que no teste não é a arena.
		var own := _first_of(get_tree().current_scene, "FireballProjectile") as Node3D
		if own == null:
			own = _first_of(arena, "FireballProjectile") as Node3D
		_check(ball.consumed == 2 and own != null and own.global_position.distance_to(ball.global_position) > shield.radius, "a Bola de Fogo do próprio mago sai da Almôndega")
	await _unload(arena)


## Primeiro filho de `parent` cujo script tem o `class_name` pedido, ou null.
func _first_of(parent: Node, type_name: String) -> Node:
	for node in parent.get_children():
		var script := node.get_script() as Script
		if script and script.get_global_name() == type_name and not node.is_queued_for_deletion():
			return node
	return null


# Kit do Mago da Gravidade (design/gdd/mage-gravity.md, critérios 1 a 8).
func _test_gravity_kit() -> void:
	print("\n--- Gravidade: push-pull, mibune, sonhos, gravidash, zona nula ---")
	var ids: Array[String] = []
	for data in GameState.CLASSES:
		ids.append(String(data.id))
	_check(ids == ["fire", "earth", "gravity"], "menu mostra Fogo, Terra e Gravidade (%s)" % [ids])
	_check(GameState.find_class("psionic") != null, "ficha do Psiônico continua existindo para o bot")
	var arena := await _load_arena("gravity")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var push := player.get_ability(Player.SLOT_PRIMARY) as PushPullAbility
	var mibune := player.get_ability(Player.SLOT_SECONDARY) as MibuneAbility
	var dream := player.get_ability(Player.SLOT_MOBILITY) as DreamGravityAbility
	var null_zone := player.get_ability(Player.SLOT_SPECIAL) as NullZoneAbility
	var dash := player.get_ability(Player.SLOT_UTILITY) as GravidashAbility
	_check(push != null and mibune != null and dream != null and null_zone != null and dash != null, "Gravidade tem Push-Pull, Mibune, Gravidade dos Sonhos, Zona Nula e Gravidash")
	if push == null or mibune == null or dream == null or null_zone == null or dash == null:
		await _unload(arena)
		return
	player.debug_infinite_resources = true
	player.debug_no_cooldowns = true
	var dummy_home := dummy.global_position
	var site := Vector3(40, 0, 40)
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)

	# Push-Pull: perto empurra, longe puxa.
	var near: PhysicsProp = arena._prop(wood, box, size, site + Vector3(0, 0.31, -2))
	_place(player, site)
	await _frames(30)
	player.face_point(near.global_position)
	await _frames(2)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(2)
	_check(push.last_action == &"push" and near.linear_velocity.z < -1.0, "Push-Pull empurra a caixa a 2 m (%.1f m/s)" % near.linear_velocity.z)
	near.queue_free()
	var far: PhysicsProp = arena._prop(wood, box, size, site + Vector3(0, 0.31, -8))
	await _frames(30)
	player.face_point(far.global_position)
	await _frames(2)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(2)
	_check(push.last_action == &"pull" and far.linear_velocity.z > 0.5, "Push-Pull puxa a caixa a 8 m (%.1f m/s)" % far.linear_velocity.z)
	far.queue_free()
	await _frames(3)

	# Rebate um dardo fraco; um forte demais passa.
	player.face_point(site + Vector3(0, 1.6, -10))
	await _frames(2)
	var weak := KineticDartProjectile.new()
	weak.mass = 0.004
	arena.add_child(weak)
	weak.global_position = site + Vector3(0.9, 1.5, -6)
	weak.launch(Vector3(0, 0, 20), Vector3.ZERO)
	await _frames(3)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(2)
	_check(push.last_deflected == 1 and is_instance_valid(weak) and weak.linear_velocity.z < 0.0, "Push-Pull rebate um dardo fraco")
	if is_instance_valid(weak):
		weak.queue_free()
	var strong := KineticDartProjectile.new()
	strong.mass = 1.0
	arena.add_child(strong)
	strong.global_position = site + Vector3(0.9, 1.5, -6)
	strong.launch(Vector3(0, 0, 20), Vector3.ZERO)
	await _frames(3)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(2)
	_check(push.last_deflected == 0, "Push-Pull não rebate um projétil forte demais")
	if is_instance_valid(strong):
		strong.queue_free()
	await _frames(3)

	# Mibune: puxa a caixa, não puxa quem lançou, é arremessado e some.
	var pulled: PhysicsProp = arena._prop(wood, box, size, site + Vector3(1.5, 0.31, -6))
	_place(player, site)
	await _frames(30)
	player.face_point(site + Vector3(0, 1.6, -10))
	await _frames(2)
	player.request_action(Player.SLOT_SECONDARY)
	await _frames(3)
	var hole := mibune.get_active()
	_check(hole != null, "Mibune criado à frente")
	if hole:
		var before := pulled.global_position.distance_to(hole.global_position)
		await _frames(30)
		var after := pulled.global_position.distance_to(hole.global_position)
		_check(after < before - 0.3, "Mibune puxa a caixa próxima (de %.1f para %.1f m)" % [before, after])
		_check(player.global_position.distance_to(site) < 0.3, "Mibune não puxa quem lançou")
		player.request_action(Player.SLOT_SECONDARY)
		await _frames(2)
		_check(hole.thrown and hole.velocity.length() > 15.0, "segunda conjuração arremessa o Mibune (%.0f m/s)" % hole.velocity.length())
		await _frames(int(mibune.lifetime * 60.0))
		_check(mibune.get_active() == null, "Mibune some depois de %.0f s" % mibune.lifetime)
	pulled.queue_free()
	await _frames(3)

	# Gravidade dos Sonhos: o mago pula mais alto; um adversário fica lento e pesado.
	player.set_level(99)
	_check(is_equal_approx(dream.side(player), dream.max_side), "nível 99: Gravidade dos Sonhos de 9 x 9 m")
	_place(player, site)
	await _frames(20)
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	var plain_jump := await _peak_until_landing(player) - site.y
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(3)
	var zone := dream.get_active_zone()
	_check(zone != null and is_equal_approx(player.get_effect(Player.EFFECT_HASTE), 1.0 + dream.strength), "na zona, o mago recarrega %.0f%% mais rápido" % (dream.strength * 100.0))
	player.request_action(Player.ACTION_JUMP)
	await _frames(2)
	var dream_jump := await _peak_until_landing(player) - site.y
	_check(dream_jump > plain_jump * 1.2, "na zona, o mago pula mais alto (%.2f x %.2f m)" % [dream_jump, plain_jump])
	if zone:
		zone.queue_free()
	await _frames(3)
	_check(is_equal_approx(player.get_effect(Player.EFFECT_JUMP), 1.0), "fim da zona devolve o pulo normal")
	# Zona de outro mago (sem `caster`): o jogador é o adversário.
	var enemy_zone := DreamGravityZone.new()
	enemy_zone.side = 6.0
	enemy_zone.strength = dream.strength
	arena.add_child(enemy_zone)
	enemy_zone.global_position = site
	await _frames(3)
	_check(is_equal_approx(player.get_speed_factor(), 1.0 - dream.strength) and is_equal_approx(player.get_effect(Player.EFFECT_WEIGHT), 1.0 + dream.strength), "adversário na zona fica mais lento e pesado")
	enemy_zone.queue_free()
	await _frames(3)

	# Gravidash: duas vezes, a terceira espera a recarga; leva a caixa junto; com Espaço, sobe.
	player.debug_no_cooldowns = false
	var carried: PhysicsProp = arena._prop(wood, box, size, site + Vector3(1.2, 0.31, 0))
	_place(player, site)
	await _frames(30)
	player.face_point(site + Vector3(0, 1.6, -10))
	await _frames(2)
	var start := player.global_position
	player.request_action(Player.SLOT_UTILITY)
	await _frames(1)
	_check(carried.linear_velocity.z < -5.0, "Gravidash leva junto a caixa ao lado (%.1f m/s)" % carried.linear_velocity.z)
	await _frames(15)
	var first := start.z - player.global_position.z
	_check(first > 2.5, "Gravidash anda %.1f m para a frente" % first)
	_check(dash.charges_left(player) == 1, "sobra um segundo Gravidash antes da recarga")
	start = player.global_position
	player.request_action(Player.SLOT_UTILITY)
	await _frames(16)
	var second := start.z - player.global_position.z
	_check(second > 2.5, "segundo Gravidash sai em seguida (%.1f m)" % second)
	start = player.global_position
	player.request_action(Player.SLOT_UTILITY)
	await _frames(16)
	_check(start.z - player.global_position.z < 0.5 and player.get_cooldown(Player.SLOT_UTILITY) > 0.0, "terceiro Gravidash espera a recarga")
	carried.queue_free()
	player.debug_no_cooldowns = true
	_place(player, site)
	await _frames(int(dash.cooldown * 60.0))
	player.force_jump_held = true
	player.request_action(Player.SLOT_UTILITY)
	await _frames(12)
	player.force_jump_held = false
	_check(player.global_position.y > 1.5, "Gravidash com Espaço sobe (%.1f m)" % player.global_position.y)
	await _frames(90)

	# Zona Nula: gasta a Mana, troca o kit, apaga projéteis, agarrar dá golpe de graça.
	player.debug_infinite_resources = false
	player.refund(Player.Pool.MANA, 9999.0)
	player.refund(Player.Pool.STAMINA, 9999.0)
	dummy.global_position = site + Vector3(0, 0, -1.2)
	dummy.reset()
	_place(player, site)
	await _frames(10)
	player.face_point(site + Vector3(0, 1.4, -10))
	await _frames(2)
	player.request_action(Player.SLOT_SPECIAL)
	await _frames(3)
	var nothing := null_zone.get_active_zone()
	_check(nothing != null and player.get_pool(Player.Pool.MANA) < 1.0, "Zona Nula criada e a Mana zerou (%.1f)" % player.get_pool(Player.Pool.MANA))
	var left_punch := player.get_ability(Player.SLOT_PRIMARY)
	_check(player.is_ability_locked() and left_punch == null_zone.punch_left and player.get_ability(Player.SLOT_SPECIAL) == null and player.get_ability(Player.SLOT_AIR_JUMP) == null, "dentro da zona, o kit vira socos e chutes")
	if nothing:
		var dart := KineticDartProjectile.new()
		dart.mass = 0.005
		arena.add_child(dart)
		dart.global_position = site + Vector3(1.5, 1.2, -2)
		dart.launch(Vector3(0, 0, 2), Vector3.ZERO)
		await _frames(3)
		_check(not is_instance_valid(dart) and nothing.erased >= 1, "projétil dentro da Zona Nula some")
	var stamina := player.get_pool(Player.Pool.STAMINA)
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(3)
	_check(dummy.combo_damage > 0.0 and player.get_pool(Player.Pool.STAMINA) < stamina, "soco na zona acerta o boneco e gasta Vigor (%.1f de dano)" % dummy.combo_damage)
	var grab := null_zone.grab as BrawlGrabAbility
	player.request_action(Player.ACTION_GRAB)
	await _frames(2)
	_check(grab.last_target == dummy, "E agarra quem está à frente")
	stamina = player.get_pool(Player.Pool.STAMINA)
	dummy.reset()
	player.request_action(Player.SLOT_SECONDARY)
	await _frames(2)
	_check(dummy.combo_damage > 0.0 and absf(player.get_pool(Player.Pool.STAMINA) - stamina) < 0.5, "depois de agarrar, o golpe sai de graça")
	player.global_position = site + Vector3(20, 0.05, 0)
	await _frames(3)
	_check(not player.is_ability_locked() and player.get_ability(Player.SLOT_PRIMARY) == push, "fora da zona, o kit normal volta")
	dummy.global_position = dummy_home
	await _unload(arena)

extends "res://tests/suite_base.gd"
## Suíte da frente classes: percurso completo de cada classe (habilidades, pulo, pegar e
## arremessar, editor de atributos), Psiônico, Elementalista, atributos e progressão.

const RULES := preload("res://assets/data/attribute_rules.tres")

var _sprint_speeds: Array[float] = []
var _throw_speeds := {}


func run() -> void:
	_test_attribute_curve()
	for id in ["knight", "mage", "psionic"]:
		await _test_class(id)
	_check(_sprint_speeds.size() == 3 and _sprint_speeds.all(func(s: float) -> bool: return is_equal_approx(s, _sprint_speeds[0])), "velocidade de corrida igual entre classes")
	_check(_throw_speeds.get("psionic", 0.0) > _throw_speeds.get("mage", 0.0), "Telecinese Acelerada arremessa mais rápido que as mãos do Elementalista (%.1f x %.1f m/s)" % [_throw_speeds.get("psionic", 0.0), _throw_speeds.get("mage", 0.0)])
	await _test_psionic()
	await _test_elementalist()
	await _test_progression()
	await _test_stair_auto_climb()


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


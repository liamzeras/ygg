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
	_check(_throw_speeds.get("psionic", 0.0) > _throw_speeds.get("mage", 0.0), "Telecinese Acelerada arremessa mais rápido (%.1f x %.1f m/s)" % [_throw_speeds.get("psionic", 0.0), _throw_speeds.get("mage", 0.0)])
	await _test_psionic()
	await _test_steps()
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
	_check(peak - ground_y <= 1.05, "%s: pulo com Agilidade 150 chega a no máximo 1 m (%.2f m)" % [id, peak - ground_y])
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
	await _walk_toward(player, Vector3(-20, 3.6, 0), 150)
	_check(player.global_position.y > 1.9, "escada de 0,2 m chega à plataforma de 2 m (y %.2f)" % player.global_position.y)
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

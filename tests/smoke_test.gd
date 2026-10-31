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


func _ready() -> void:
	_test_attribute_curve()
	_test_damage_rules()
	for id in ["knight", "mage"]:
		await _test_class(id)
	_check(_sprint_speeds.size() == 2 and is_equal_approx(_sprint_speeds[0], _sprint_speeds[1]), "velocidade de corrida igual entre classes")
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

	# Pulo duplo: um só por salto, gasta Vigor.
	player.respawn()
	await _frames(20)
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
	await _frames(120)
	_check(player.is_air_jump_available(), "%s: pulo duplo recarregou ao tocar o chão" % id)

	# Pegar e arremessar uma caixa (mãos para o cavaleiro, telecinese para o mago).
	var crate := _nearest_crate(arena, player)
	_check(crate != null, "%s: achou uma caixa" % id)
	if crate:
		player.global_position = crate.global_position + Vector3(0, -0.3, 1.6)
		await _frames(10)
		player.face_point(crate.global_position)
		await _frames(3)
		player.request_action(Player.SLOT_SPECIAL if id == "mage" else Player.ACTION_GRAB)
		await _frames(20)
		_check(player.held_body == crate, "%s: segurou a caixa" % id)
		player.face_point(player.get_aim_origin() + player.get_flat_forward() * 5.0)
		await _frames(20)
		player.request_action(Player.SLOT_PRIMARY)
		await _frames(2)
		print("  velocidade da caixa: %.1f m/s (massa %.1f kg)" % [crate.linear_velocity.length(), crate.mass])
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

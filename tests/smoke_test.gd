extends Node
## Teste de fumaça: carrega a arena com cada classe, usa as 3 habilidades,
## pega/arremessa uma caixa, testa fogo e explosão, e confere as fórmulas de atributos.
## Rodar: ver tests/README.md. Sai com código 0 (passou) ou 1 (falhou).

const ARENA := preload("res://src/levels/test_arena.tscn")
const RULES := preload("res://assets/data/attribute_rules.tres")

var _failures: Array[String] = []
var _checks := 0


func _ready() -> void:
	_test_attribute_curve()
	for id in ["knight", "mage"]:
		await _test_class(id)
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


func _test_class(id: String) -> void:
	print("\n--- Classe: %s ---" % id)
	GameState.selected_class = GameState.find_class(id)
	var arena: Node3D = ARENA.instantiate()
	add_child(arena)
	await _frames(40)
	var player: Player = arena.player
	_check(player != null, "%s: jogador criado" % id)
	_check(player.is_on_floor(), "%s: jogador no chão" % id)
	print("  stats: carga %.0f kg, pulo %.2f m, corrida %.1f m/s, recurso %.0f" % [
		player.stats.carry_mass, player.stats.jump_height, player.stats.sprint_speed, player.stats.max_resource])

	# Habilidade principal, de perto do boneco (alcance do Golpe de Escudo é curto).
	player.global_position = arena.dummy.global_position + Vector3(0, 0.05, 1.8)
	await _frames(10)
	player.face_point(arena.dummy.global_position + Vector3.UP * 1.2)
	await _frames(2)
	var before := player.resource
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(45)
	_check(player.resource < before, "%s: principal gastou recurso" % id)
	_check(arena.dummy.hit_count > 0 or arena.dummy.total_heat > 0.0, "%s: boneco registrou o golpe" % id)

	# Especial.
	if id == "knight":
		player.request_action(Player.SLOT_SPECIAL)
		await _frames(3)
		_check(player.is_guarding(), "knight: Postura de Muralha ativa")
	# Mobilidade.
	player.request_action(Player.SLOT_MOBILITY)
	await _frames(3)
	_check(player.get_cooldown(Player.SLOT_MOBILITY) > 0.0, "%s: mobilidade usada" % id)
	await _frames(90)

	# Pegar e arremessar uma caixa (mãos para o cavaleiro, telecinese para o mago).
	var crate := _nearest_crate(arena, player)
	_check(crate != null, "%s: achou uma caixa" % id)
	if crate:
		player.respawn()
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

	# Fogo e explosão.
	var wood := _nearest_crate(arena, player)
	if wood:
		wood.add_heat(1000.0)
		_check(wood.burning, "%s: madeira pegou fogo" % id)
	var barrel := _first_prop(arena, "explosive")
	if barrel:
		barrel.explode()
		await _frames(3)
		_check(not is_instance_valid(barrel), "%s: barril explodiu" % id)

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

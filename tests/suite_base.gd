extends Node
## Base de toda suíte do teste de fumaça: guarda o resultado e oferece os auxiliares comuns.
## Cada arquivo em tests/suites/ estende este script e implementa run(). Ver tests/README.md.

const ARENA := preload("res://src/levels/test_arena.tscn")

## Quantas verificações esta suíte fez.
var checks := 0
## Texto de cada verificação que falhou.
var failures: Array[String] = []


## Roda os testes da suíte. Cada suíte substitui esta função.
func run() -> void:
	pass


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
	checks += 1
	print(("  ok    " if condition else "  FALHA ") + label)
	if not condition:
		failures.append(label)


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

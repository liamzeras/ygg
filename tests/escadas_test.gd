extends Node
## Regressão da subida de escadas: ritmo regular, sem perder velocidade nem dar tranco na câmera.
## Arquivo próprio enquanto o teste de fumaça é dividido em suítes; depois vai para a suíte de gameplay.
## Rodar: Godot --headless --path . res://tests/escadas_test.tscn. Sai com código 0 (passou) ou 1 (falhou).

const ARENA := preload("res://src/levels/test_arena.tscn")

var _failures := 0
var _checks := 0


func _ready() -> void:
	GameState.selected_class = GameState.find_class("knight")
	var arena: Node3D = ARENA.instantiate()
	add_child(arena)
	await _frames(40)
	var player: Player = arena.player

	# Mais longe que o pé da escada (x = -20), para chegar já na velocidade de andar.
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
	print("\n=== ESCADAS: %d verificações, %d falhas ===" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	print(("  ok    " if condition else "  FALHA ") + label)
	if not condition:
		_failures += 1


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

extends "res://tests/suite_base.gd"
## Suíte da frente gameplay: corpo do jogador (degraus, rampa, dash e arremesso em movimento).


func run() -> void:
	await _test_steps()
	await _test_stair_rhythm()
	await _test_dash()


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


# Regressão: subir escada com ritmo regular, sem perder velocidade nem dar tranco na câmera.
func _test_stair_rhythm() -> void:
	print("\n--- Ritmo da subida ---")
	var arena := await _load_arena("knight")
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

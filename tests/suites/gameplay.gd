extends "res://tests/suite_base.gd"
## Suíte da frente gameplay: corpo do jogador (degraus, rampa, dash e arremesso em movimento).


func run() -> void:
	await _test_steps()
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
	await _walk_toward(player, Vector3(-20, 3.6, 0), 150)
	_check(player.global_position.y > 1.9, "escada de 0,2 m chega à plataforma de 2 m (y %.2f)" % player.global_position.y)
	# Rampa de 30° (x = -30, z = -2) continua subindo normal com o corpo cilíndrico.
	player.global_position = Vector3(-30, 0.05, 4)
	await _frames(5)
	await _walk_toward(player, Vector3(-30, 3.6, -10), 70)
	_check(player.global_position.y > 1.0, "sobe a rampa de 30° andando (y %.2f)" % player.global_position.y)

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

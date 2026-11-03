extends "res://tests/suite_base.gd"
## Suíte da frente gameplay: corpo do jogador (degraus, rampa, dash e arremesso em movimento).


func run() -> void:
	await _test_steps()
	await _test_stair_rhythm()
	await _test_explosion_occlusion()
	await _test_fire_spread()
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
	var camera_trace := CameraTrace.new(player)
	add_child(camera_trace)
	var last_step := -1
	var intervals: Array[float] = []
	var speeds: Array[float] = []
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
		last_y = y
		last_z = player.global_position.z
	Input.action_release("move_forward")
	camera_trace.queue_free()
	var max_camera_rise := camera_trace.max_rise(1.0 / Engine.physics_ticks_per_second)
	print("  quadros entre degraus: %s" % [intervals])
	print("  avanço máx/mín: %.2f / %.2f m/s; câmera: máx %.3f m em 1/60 s, %.3f m por quadro desenhado (%d quadros)" % [speeds.max(), speeds.min(), max_camera_rise, camera_trace.max_frame_rise(), camera_trace.times.size()])
	_check(intervals.size() >= 7 and intervals.max() - intervals.min() <= 1.0, "intervalo entre degraus regular (%s quadros)" % [intervals])
	_check(speeds.max() <= player.stats.walk_speed * 1.15 and speeds.min() >= player.stats.walk_speed * 0.8, "velocidade constante na escada (%.2f a %.2f m/s)" % [speeds.min(), speeds.max()])
	_check(max_camera_rise < 0.09, "câmera sobe sem tranco (máx %.3f m em 1/60 s)" % max_camera_rise)
	await _unload(arena)


# Grava a altura da câmera a cada quadro desenhado, depois do _process do jogador.
# A câmera anda em _process, e sem janela cabem 2 ou 3 quadros em cada tick de física: comparar tick
# com tick mediria ora 14 ms, ora 21 ms de subida. Por isso a medida usa uma janela de tempo fixa.
class CameraTrace extends Node:
	var times: Array[float] = []
	var heights: Array[float] = []
	var _player: Player

	func _init(player: Player) -> void:
		_player = player
		process_priority = 1000

	func _process(delta: float) -> void:
		times.append((times.back() if not times.is_empty() else 0.0) + delta)
		heights.append(_player.get_aim_origin().y)

	## Maior subida da câmera em qualquer intervalo de `window` segundos (interpola entre quadros).
	func max_rise(window: float) -> float:
		var best := 0.0
		var j := 0
		for i in range(1, times.size()):
			var start_time := times[i] - window
			if start_time < times[0]:
				continue
			while times[j + 1] < start_time:
				j += 1
			var start := lerpf(heights[j], heights[j + 1], inverse_lerp(times[j], times[j + 1], start_time))
			best = maxf(best, heights[i] - start)
		return best

	## Maior subida entre dois quadros desenhados seguidos.
	func max_frame_rise() -> float:
		var best := 0.0
		for i in range(1, heights.size()):
			best = maxf(best, heights[i] - heights[i - 1])
		return best


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


# Parede e pilar protegem de explosões; caixa solta e o próprio chão, não
# (design/gdd/physics-magic-system.md).
func _test_explosion_occlusion() -> void:
	print("\n--- Explosão: paredes protegem ---")
	var arena := await _load_arena("knight")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var factor: float = Explosion.DAMAGE.blocked_explosion_factor
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	# Dois lugares iguais, longe de tudo: um com parede entre a explosão e o alvo, outro sem.
	var open_site := Vector3(35, 0.5, -40)
	var walled_site := Vector3(35, 0.5, -25)
	arena._static_box(walled_site + Vector3(0, 1, 0.75), Vector3(4, 3, 0.3), null)
	var target := Vector3(0, -0.19, 1.5)

	var open_crate: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	var walled_crate: PhysicsProp = arena._prop(wood, box, size, walled_site + target)
	await _frames(20)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 50.0)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 50.0)
	await _frames(2)
	print("  caixa: calor %.1f sem parede, %.1f com parede; velocidade %.1f e %.1f m/s" % [open_crate.heat, walled_crate.heat, open_crate.linear_velocity.length(), walled_crate.linear_velocity.length()])
	_check(open_crate.heat > 15.0 and walled_crate.heat <= open_crate.heat * factor * 1.1, "parede corta o calor da explosão")
	_check(walled_crate.linear_velocity.length() < open_crate.linear_velocity.length() * 0.4, "parede corta o empurrão da explosão")
	open_crate.queue_free()
	walled_crate.queue_free()
	await _frames(3)

	# Boneco e jogador: a origem deles fica nos pés, mas o raio mira o centro do corpo.
	dummy.global_position = open_site + Vector3(0, -0.5, 1.5)
	await _frames(3)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 0.0)
	var open_damage := dummy.combo_damage
	dummy.reset()
	dummy.global_position = walled_site + Vector3(0, -0.5, 1.5)
	await _frames(3)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 0.0)
	_check(open_damage > 5.0 and dummy.combo_damage < open_damage * 0.3, "boneco atrás da parede quase não toma dano (%.1f x %.1f)" % [dummy.combo_damage, open_damage])
	dummy.global_position = Vector3(0, 0, 3)
	await _frames(3)
	var knockback: Array[float] = []
	for site: Vector3 in [open_site, walled_site]:
		player.global_position = site + Vector3(0, -0.45, 1.5)
		player.velocity = Vector3.ZERO
		await _frames(2)
		player.velocity = Vector3.ZERO
		Explosion.detonate(arena, site, 3.0, 400.0, 0.0)
		knockback.append(player.velocity.length())
		await _frames(2)
	_check(knockback[0] > 1.0 and knockback[1] < knockback[0] * 0.4, "jogador atrás da parede é pouco empurrado (%.1f x %.1f m/s)" % [knockback[1], knockback[0]])
	player.respawn()
	await _frames(3)

	# Pilar também é cobertura.
	var pillar_site := Vector3(45, 0.5, -40)
	var pillar := StonePillar.new()
	pillar.height = 3.0
	arena.add_child(pillar)
	pillar.start(Vector3(45, 0, -39.25), Vector3.FORWARD)
	await _frames(40)
	var covered: PhysicsProp = arena._prop(wood, box, size, pillar_site + target)
	await _frames(20)
	Explosion.detonate(arena, pillar_site, 3.0, 200.0, 50.0)
	_check(covered.heat < 10.0, "pilar protege (calor %.1f)" % covered.heat)
	covered.queue_free()
	pillar.queue_free()
	await _frames(3)

	# Caixa solta no caminho não vira escudo.
	var behind: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	var shield: PhysicsProp = arena._prop(wood, box, size, open_site + Vector3(0, -0.19, 0.7))
	await _frames(20)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 50.0)
	_check(behind.heat > 15.0, "caixa solta no caminho não protege (calor %.1f)" % behind.heat)
	behind.queue_free()
	shield.queue_free()
	await _frames(3)

	# Explosão rente ao chão não se bloqueia nele.
	var near_floor: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	await _frames(20)
	Explosion.detonate(arena, Vector3(open_site.x, 0.0, open_site.z), 3.0, 200.0, 50.0)
	_check(near_floor.heat > 15.0, "explosão rente ao chão não se bloqueia nele (calor %.1f)" % near_floor.heat)
	near_floor.queue_free()
	await _frames(3)

	# Acerto direto ignora a parede.
	var hit_crate: PhysicsProp = arena._prop(wood, box, size, walled_site + target)
	await _frames(20)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 50.0, [], Color.WHITE, hit_crate)
	_check(is_equal_approx(hit_crate.heat, 50.0), "acerto direto ignora a parede (calor %.1f)" % hit_crate.heat)
	await _unload(arena)


# Mede a distância real em que o fogo pula entre caixas de madeira, e a pirâmide inteira.
func _test_fire_spread() -> void:
	print("\n--- Contágio de fogo: medição ---")
	var arena := await _load_arena("knight")
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var distances: Array[float] = [0.5, 0.62, 0.7, 0.85, 0.93, 1.1, 1.3]
	var neighbors: Array[PhysicsProp] = []
	var sources: Array[PhysicsProp] = []
	for i in distances.size():
		var base := Vector3(35, 0.31, -45 + i * 5.0)
		var source: PhysicsProp = arena._prop(wood, box, size, base)
		var neighbor: PhysicsProp = arena._prop(wood, box, size, base + Vector3(distances[i], 0, 0))
		source.freeze = true
		neighbor.freeze = true
		sources.append(source)
		neighbors.append(neighbor)
	# Três caixas em chamas a 0,9 m da mesma vizinha: o calor soma.
	var center := Vector3(45, 0.31, -30)
	var surrounded: PhysicsProp = arena._prop(wood, box, size, center)
	surrounded.freeze = true
	for direction: Vector3 in [Vector3(0.9, 0, 0), Vector3(-0.9, 0, 0), Vector3(0, 0, 0.9)]:
		var source: PhysicsProp = arena._prop(wood, box, size, center + direction)
		source.freeze = true
		sources.append(source)
	# Pirâmide da arena (x de 11 a 13, z = -2), acesa por uma caixa da base.
	var pyramid: Array[PhysicsProp] = []
	for node in arena.get_children():
		if node is PhysicsProp and node.material_data == wood and absf(node.global_position.z + 2.0) < 0.1 and node.global_position.x < 14.0:
			pyramid.append(node)
	await _frames(20)
	for source in sources:
		source.ignite()
	pyramid[0].ignite()

	var ignition_time := {}
	var pyramid_lit := {}
	var pyramid_full := -1.0
	var watched: Array[PhysicsProp] = neighbors.duplicate()
	watched.append(surrounded)
	for frame in 1200:
		await _frames(1)
		for crate in watched:
			if is_instance_valid(crate) and crate.burning and not ignition_time.has(crate):
				ignition_time[crate] = frame / 60.0
		for crate in pyramid:
			if not pyramid_lit.has(crate) and (not is_instance_valid(crate) or crate.burning):
				pyramid_lit[crate] = true
		if pyramid_full < 0.0 and pyramid_lit.size() == pyramid.size():
			pyramid_full = frame / 60.0
	for i in distances.size():
		var time: float = ignition_time.get(neighbors[i], -1.0)
		print("  %.2f m entre centros: %s" % [distances[i], "acende em %.1f s" % time if time >= 0.0 else "não acende"])
	print("  3 em chamas a 0,90 m: acende em %.1f s" % ignition_time.get(surrounded, -1.0))
	print("  pirâmide: %d de %d acesas; todas em %.1f s" % [pyramid_lit.size(), pyramid.size(), pyramid_full])
	_check(ignition_time.has(neighbors[0]), "caixa a 0,5 m acende a vizinha")
	_check(not ignition_time.has(neighbors[5]), "caixa a 1,1 m não acende a vizinha")
	_check(ignition_time.has(surrounded), "três caixas a 0,9 m somam calor e acendem")
	await _unload(arena)

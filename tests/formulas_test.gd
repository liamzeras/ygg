extends Node
## Compara fórmulas da pesquisa do Sábio (design/sabio/pesquisa/resultado-formulas.md) com o motor real:
## calcula o previsto, mede na simulação e mostra a diferença. Usa o tempo real da física (60 Hz).
## Rodar: ... --headless --path . res://tests/formulas_test.tscn
## Sai com código 1 se alguma medição divergir do previsto.

const WOOD := preload("res://assets/data/materials/wood.tres")
const METAL := preload("res://assets/data/materials/metal.tres")
const STONE := preload("res://assets/data/materials/stone.tres")
const EXPLOSIVE := preload("res://assets/data/materials/explosive.tres")
const LAB_PROP := "res://src/gameplay/lab/lab_prop.gd"
const LAB_WET := "res://src/gameplay/lab/modules/lab_wet_status.gd"
const LANE := 40.0
const DT := 1.0 / 60.0

class HitSink:
	extends StaticBody3D
	var impulses: Array[float] = []
	func register_hit(_source: String, impulse: float) -> void:
		impulses.append(impulse)

var _world: Node3D
var _lane := 0
var _divergences := 0
var _gravity := 9.8


func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	print("gravidade=%.2f passo=%.4f s" % [_gravity, DT])
	await _test_mass()
	await _test_ignition()
	await _test_wet()
	await _test_mud_and_brazier()
	await _test_contagion()
	await _test_pyramid()
	await _test_friction()
	await _test_mud_drag()
	await _test_explosion()
	await _test_impact()
	await _test_detonation_speed()
	await _test_ballistics()
	await _test_tunneling()
	print("\n=== FORMULAS: %d divergências ===" % _divergences)
	get_tree().quit(1 if _divergences > 0 else 0)


func _test_mass() -> void:
	print("\n# Massa = volume x densidade; quadrado-cubo")
	await _reset()
	var a := _prop(WOOD, Vector3.ONE * 0.6, Vector3(0, 2, 0))
	var b := _prop(METAL, Vector3.ONE * 0.5, Vector3(3, 2, 0))
	var c := _prop(STONE, Vector3.ONE * 0.6, Vector3(6, 2, 0))
	var d := _prop(STONE, Vector3.ONE * 1.2, Vector3(9, 2, 0))
	_compare("caixa de madeira 0,6 m (kg)", 19.44, a.mass, 0.01)
	_compare("caixa de metal 0,5 m (kg)", 75.0, b.mass, 0.01)
	_compare("dobrar o lado multiplica a massa por", 8.0, d.mass / c.mass, 0.001)


func _test_ignition() -> void:
	print("\n# Tempo para acender: ignition_heat / (calor_por_s - heat_decay)")
	await _reset()
	var wood := await _prop_in_zone(WOOD, 80.0)
	var powder := await _prop_in_zone(EXPLOSIVE, 80.0)
	var times := await _ignition_times([wood, powder], 5.0)
	_compare("madeira no braseiro (s)", 100.0 / (80.0 - 15.0), times[0], 0.1)
	_compare("pólvora no braseiro (s)", 60.0 / (80.0 - 10.0), times[1], 0.1)


func _test_wet() -> void:
	print("\n# Molhado: tabela previu 4 s; a secagem por calor não entrou naquela conta")
	if not ResourceLoader.exists(LAB_PROP):
		print("pulado: laboratório removido")
		return
	await _reset()
	var prop: PhysicsProp = load(LAB_PROP).new()
	_setup_prop(prop, WOOD, Vector3.ONE * 0.6, _lane_point())
	prop.gravity_scale = 0.0
	_world.add_child(prop)
	_zone_at(prop.global_position, 80.0)
	var status: Node = load(LAB_WET).new()
	status.set("prop", prop)
	status.set("time_left", 15.0)
	status.set("heat_factor", 0.5)
	status.set("dry_per_heat", 0.1)
	prop.add_child(status)
	var time: float = (await _ignition_times([prop], 8.0))[0]
	print("MEDIDO Molhada: %.2f s; a conta da tabela, sem secagem, dava %.2f s" % [time, 100.0 / (40.0 - 15.0)])
	var wet_time := 15.0 / (1.0 + 40.0 * 0.1)
	var with_drying := wet_time + (100.0 - wet_time * 25.0) / (80.0 - 15.0)
	_compare("caixa Molhada, conta com secagem (s)", with_drying, time, 0.15)


func _test_mud_and_brazier() -> void:
	print("\n# Lama + braseiro sem o módulo: ciclo de acender e apagar")
	await _reset()
	var prop := _prop(WOOD, Vector3.ONE * 0.6, _lane_point())
	prop.gravity_scale = 0.0
	_zone_at(prop.global_position, 80.0)
	var mud := MudPatch.new()
	mud.radius = 3.0
	mud.duration = 30.0
	_world.add_child(mud)
	mud.global_position = prop.global_position + Vector3.DOWN * 0.5
	var ignitions: Array[float] = []
	var frames := [0]
	prop.ignited.connect(func() -> void: ignitions.append(frames[0] * DT))
	for i in 900:
		frames[0] = i
		await get_tree().physics_frame
	_compare("primeira ignição na lama (s)", 100.0 / (80.0 - 15.0 - 50.0), ignitions[0] if ignitions.size() > 0 else -1.0, 0.3)
	_compare("ignições em 15 s (ciclo)", 2.0, float(ignitions.size()), 0.0)


func _test_contagion() -> void:
	print("\n# Contágio: r = n x 45 x (1 - d/1,4) - 15; acende se 100/r < 10 s. d entre centros.")
	await _reset()
	var cases := [[0.5, 1], [0.6, 1], [0.62, 1], [0.65, 1], [0.8, 1], [1.0, 2], [1.05, 2], [1.2, 2], [0.8, 3]]
	var targets: Array[PhysicsProp] = []
	var sources: Array[PhysicsProp] = []
	for c: Array in cases:
		var center := _lane_point()
		var target := _prop(WOOD, Vector3.ONE * 0.2, center)
		target.freeze = true
		targets.append(target)
		for n in int(c[1]):
			var angle := TAU * n / float(c[1])
			var source := _prop(WOOD, Vector3.ONE * 0.2, center + Vector3(cos(angle), 0, sin(angle)) * float(c[0]))
			source.freeze = true
			sources.append(source)
	await _frames(2)
	for source in sources:
		source.ignite()
	var times := await _ignition_times(targets, 10.2)
	for i in cases.size():
		var d: float = cases[i][0]
		var n: int = cases[i][1]
		var rate := n * 45.0 * (1.0 - d / 1.4) - 15.0
		# A fonte queima por 10 s: depois disso, some.
		var predicted := 100.0 / rate if rate > 0.0 and 100.0 / rate < 10.0 else -1.0
		_compare("d=%.2f m com %d em chamas (s; -1 = não acende)" % [d, n], predicted, times[i], 0.25)


func _test_pyramid() -> void:
	print("\n# Critério aberto do GDD: pirâmide de madeira queima em menos de 20 s")
	# Mesma montagem de test_arena.gd. Índices: 0 = canto da base, 1 = meio da base, 9 = topo.
	for start: int in [0, 1, 9]:
		await _reset()
		var base := _lane_point()
		base.y = 0.0
		_floor_at(base, 0.7)
		var boxes: Array[PhysicsProp] = []
		for row in 4:
			for i in 4 - row:
				var x := (i - (3 - row) / 2.0) * 0.62
				boxes.append(_prop(WOOD, Vector3.ONE * 0.6, base + Vector3(x, 0.31 + row * 0.61, 0)))
		await _frames(60)
		boxes[start].ignite()
		var times := await _ignition_times(boxes, 40.0)
		var lit := times.filter(func(t: float) -> bool: return t >= 0.0)
		var slowest: float = lit.max() if lit.size() > 0 else -1.0
		print("MEDIDO pirâmide, acendendo a caixa %d: %d de %d acesas; última em %.1f s" % [start, lit.size(), boxes.size(), slowest])
		if start == 9:
			# Do topo, as vizinhas estão a 0,68 m: 45 x (1 - 0,68/1,4) - 15 = 8/s, ou 80 de calor em 10 s. Não basta.
			_compare("do topo, o fogo não desce (caixas acesas)", 1.0, float(lit.size()), 0.0)
		else:
			_compare("todas acesas em menos de 20 s, a partir da caixa %d (1 = sim)" % start, 1.0, 1.0 if lit.size() == boxes.size() and slowest < 20.0 else 0.0, 0.0)


func _test_friction() -> void:
	print("\n# Atrito + amortecimento padrão: d = v/c - (μg/c²) x ln(1 + c x v/(μg)); sem rough, μ = menor do par")
	var c_damp := float(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
	print("amortecimento padrão do projeto: %.2f" % c_damp)
	var cases := [[0.4, 1.0, 0.5], [0.4, 1.0, 1.0], [0.4, 0.2, 0.5], [0.05, 1.0, 0.5], [0.02, 1.0, 0.5], [0.7, 1.0, 0.8]]
	for c: Array in cases:
		await _reset()
		var start := _lane_point()
		start.y = 0.0
		_floor_at(start, c[1])
		var material := PropMaterial.new()
		material.density = 600.0
		material.friction = c[0]
		var size: float = c[2]
		var prop := _prop(material, Vector3.ONE * size, start + Vector3(-15, size / 2.0 + 0.01, 0))
		await _frames(20)
		var from := prop.global_position
		var speed := 3.0
		prop.linear_velocity = Vector3(speed, 0, 0)
		var limit := 900
		await _frames(2)
		while prop.linear_velocity.length() > 0.02 and limit > 0:
			limit -= 1
			await get_tree().physics_frame
		var mu: float = minf(c[0], c[1])
		var decel := mu * _gravity
		var predicted := speed / c_damp - decel / (c_damp * c_damp) * log(1.0 + c_damp * speed / decel)
		var measured := prop.global_position.distance_to(from)
		_compare("μ prop %.2f, chão %.2f, massa %.0f kg: parada (m; sem amortecer daria %.2f)" % [c[0], c[1], prop.mass, speed * speed / (2.0 * decel)], predicted, measured, 0.05 * predicted)


func _test_mud_drag() -> void:
	print("\n# Lamaçal: v = v0 x e^(-(3 + amortecimento) x t)")
	await _reset()
	var prop := _prop(WOOD, Vector3.ONE * 0.3, _lane_point())
	prop.gravity_scale = 0.0
	var mud := MudPatch.new()
	mud.radius = 20.0
	mud.duration = 20.0
	_world.add_child(mud)
	mud.global_position = prop.global_position + Vector3.DOWN * 0.5
	await _frames(5)
	prop.linear_velocity = Vector3(6, 0, 0)
	await _frames(60)
	_compare("6 m/s depois de 1 s (m/s)", 6.0 * exp(-3.1), prop.linear_velocity.length(), 0.03)


func _test_explosion() -> void:
	print("\n# Explosão: velocidade = impulso x (1 - d/R) / massa")
	await _reset()
	var origin := _lane_point()
	var props: Array[PhysicsProp] = []
	var distances := [1.0, 2.5, 4.0]
	for i in distances.size():
		var angle := TAU * i / 3.0
		var prop := _prop(WOOD, Vector3.ONE * 0.2, origin + Vector3(cos(angle), 0, sin(angle)) * float(distances[i]))
		prop.gravity_scale = 0.0
		props.append(prop)
	await _frames(3)
	Explosion.detonate(_world, origin, 5.0, 10.0, 0.0)
	await _frames(2)
	for i in distances.size():
		var predicted: float = 10.0 * (1.0 - distances[i] / 5.0) / props[i].mass
		_compare("d=%.1f m (m/s)" % distances[i], predicted, props[i].linear_velocity.length(), predicted * 0.1)

	print("# Parede entre a explosão e o objeto: cada caso roda com e sem parede")
	for with_wall: bool in [false, true]:
		await _reset()
		var center := _lane_point()
		var behind := _prop(WOOD, Vector3.ONE * 0.2, center + Vector3(2.5, 0, 0))
		behind.gravity_scale = 0.0
		if with_wall:
			_wall(center + Vector3(1.2, 0, 0), Vector3(0.3, 6, 6))
		await _frames(3)
		Explosion.detonate(_world, center, 5.0, 10.0, 0.0)
		for frame in 3:
			await get_tree().physics_frame
			print("MEDIDO parede=%s quadro %d: v=%.2f m/s pos=%s massa=%.2f" % [with_wall, frame + 1, behind.linear_velocity.length(), behind.global_position - center, behind.mass])


func _test_impact() -> void:
	print("\n# Impacto no alvo = massa x velocidade relativa")
	await _reset()
	var start := _lane_point()
	var sink := HitSink.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 3, 3)
	shape.shape = box
	sink.add_child(shape)
	_world.add_child(sink)
	sink.global_position = start + Vector3(3, 0, 0)
	var prop := _prop(WOOD, Vector3.ONE * 0.6, start)
	prop.gravity_scale = 0.0
	await _frames(3)
	prop.linear_velocity = Vector3(5, 0, 0)
	await _frames(60)
	# O amortecimento tira 0,1 m/s por metro nos 2,45 m até a parede.
	_compare("caixa de 19,44 kg a 5 m/s (N·s)", 19.44 * (5.0 - 0.1 * 2.45), sink.impulses[0] if sink.impulses.size() > 0 else -1.0, 2.0)


func _test_detonation_speed() -> void:
	print("\n# Pólvora detona por impacto a partir de 9 m/s")
	for speed: float in [8.0, 10.0]:
		await _reset()
		var start := _lane_point()
		_wall(start + Vector3(3, 0, 0), Vector3(0.5, 3, 3))
		var barrel := _prop(EXPLOSIVE, Vector3.ONE * 0.4, start)
		barrel.gravity_scale = 0.0
		await _frames(3)
		barrel.linear_velocity = Vector3(speed, 0, 0)
		await _frames(60)
		_compare("%.0f m/s explodiu (1 = sim)" % speed, 1.0 if speed >= 9.0 else 0.0, 0.0 if is_instance_valid(barrel) else 1.0, 0.0)


func _test_ballistics() -> void:
	print("\n# Arco da Bola de Fogo: gravidade 20%, sem arrasto")
	await _reset()
	var body := RigidBody3D.new()
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.1
	shape.shape = sphere
	body.add_child(shape)
	body.gravity_scale = 0.2
	body.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	body.linear_damp = 0.0
	_world.add_child(body)
	var start := _lane_point() + Vector3(-15, 25, 0)
	body.global_position = start
	body.linear_velocity = Vector3(16, 0, 0)
	await _frames(120)
	var moved := body.global_position - start
	_compare("alcance em 2 s (m)", 32.0, moved.x, 0.2)
	_compare("queda em 2 s (m)", 0.5 * _gravity * 0.2 * 4.0, -moved.y, 0.1)


func _test_tunneling() -> void:
	print("\n# Tunelamento: atravessa quando v x dt > espessura; CCD impede")
	var cases := [[80.0, false], [80.0, true], [37.0, false], [37.0, true], [5.0, false]]
	for c: Array in cases:
		var crossed := await _count_crossings(c[0], c[1])
		print("MEDIDO %.0f m/s (%.2f m por passo), parede 0,1 m, CCD %s: atravessou %d de 10" % [c[0], c[0] * DT, "sim" if c[1] else "não", crossed])
		if c[1] or c[0] == 5.0:
			_compare("%.0f m/s CCD %s atravessou" % [c[0], "sim" if c[1] else "não"], 0.0, float(crossed), 0.0)


func _count_crossings(speed: float, ccd: bool) -> int:
	await _reset()
	var bodies: Array[RigidBody3D] = []
	var walls_x: Array[float] = []
	for i in 10:
		var start := _lane_point()
		_wall(start + Vector3(3, 0, 0), Vector3(0.1, 3, 3))
		var body := RigidBody3D.new()
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.05
		shape.shape = sphere
		body.add_child(shape)
		body.gravity_scale = 0.0
		body.continuous_cd = ccd
		_world.add_child(body)
		# Fases diferentes: cada corpo chega à parede num ponto diferente do passo.
		body.global_position = start + Vector3(speed * DT * i / 10.0, 0, 0)
		body.linear_velocity = Vector3(speed, 0, 0)
		bodies.append(body)
		walls_x.append(start.x + 3.0)
	await _frames(minf(ceil(4.0 / speed / DT), 90.0) as int + 4)
	var crossed := 0
	for i in 10:
		if bodies[i].global_position.x > walls_x[i] + 0.1:
			crossed += 1
	return crossed


# --- Ajudantes ----------------------------------------------------------------

func _reset() -> void:
	if is_instance_valid(_world):
		_world.free()
	_world = Node3D.new()
	add_child(_world)
	_lane = 0
	await get_tree().physics_frame


func _lane_point() -> Vector3:
	_lane += 1
	return Vector3(_lane * LANE, 5.0, 0.0)


func _setup_prop(prop: PhysicsProp, material: PropMaterial, size: Vector3, pos: Vector3) -> void:
	prop.material_data = material
	prop.shape_kind = PhysicsProp.Form.BOX
	prop.size = size
	prop.position = pos


func _prop(material: PropMaterial, size: Vector3, pos: Vector3) -> PhysicsProp:
	var prop := PhysicsProp.new()
	_setup_prop(prop, material, size, pos)
	_world.add_child(prop)
	return prop


func _prop_in_zone(material: PropMaterial, heat: float) -> PhysicsProp:
	var prop := _prop(material, Vector3.ONE * 0.6, _lane_point())
	prop.gravity_scale = 0.0
	_zone_at(prop.global_position, heat)
	return prop


func _zone_at(pos: Vector3, heat: float) -> void:
	var zone := HeatZone.new()
	zone.heat_per_second = heat
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3.ONE * 2.0
	collision.shape = box
	zone.add_child(collision)
	_world.add_child(zone)
	zone.global_position = pos


func _floor_at(center: Vector3, friction: float) -> void:
	var body := _wall(center + Vector3(0, -0.5, 0), Vector3(36, 1, 10))
	var material := PhysicsMaterial.new()
	material.friction = friction
	body.physics_material_override = material


func _wall(pos: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collision.shape = box
	body.add_child(collision)
	_world.add_child(body)
	body.global_position = pos
	return body


## Segundos até cada objeto pegar fogo; -1 se não pegou no limite.
func _ignition_times(props: Array, limit: float) -> Array[float]:
	var times: Array[float] = []
	times.resize(props.size())
	times.fill(-1.0)
	for frame in int(limit / DT):
		await get_tree().physics_frame
		var pending := false
		for i in props.size():
			if times[i] >= 0.0:
				continue
			if is_instance_valid(props[i]) and props[i].burning:
				times[i] = (frame + 1) * DT
			else:
				pending = true
		if not pending:
			break
	return times


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func _compare(label: String, predicted: float, measured: float, tolerance: float) -> void:
	var ok := absf(predicted - measured) <= tolerance
	if not ok:
		_divergences += 1
	print("%s %s | previsto %.3f | medido %.3f" % ["BATE    " if ok else "DIVERGE ", label, predicted, measured])

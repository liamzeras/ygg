class_name Fx
extends RefCounted
## Efeitos visuais genéricos gerados por código (placeholder até termos arte).
## Desempenho (production/perf/diagnostico-2026-11-17.md, item 2): malhas, materiais e
## degradês são criados uma vez e reaproveitados entre todos os efeitos. O visual é o mesmo.

## Malhas das partículas por raio (o material é um só, compartilhado).
static var _meshes := {}
static var _particle_material: StandardMaterial3D
## Degradês por par de cores.
static var _gradients := {}


## Fogo contínuo para anexar a um objeto em chamas.
static func make_fire(radius: float) -> Node3D:
	var root := Node3D.new()
	root.name = "Fire"
	var particles := CPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 0.8
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = maxf(radius, 0.1)
	particles.direction = Vector3.UP
	particles.spread = 15.0
	particles.gravity = Vector3(0, 3, 0)
	particles.initial_velocity_min = 0.3
	particles.initial_velocity_max = 1.0
	particles.scale_amount_min = 0.6
	particles.scale_amount_max = 1.3
	particles.mesh = _particle_mesh(0.12)
	particles.color_ramp = _gradient(Color(1, 0.85, 0.3, 1), Color(0.8, 0.15, 0.02, 0))
	root.add_child(particles)
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.55, 0.2)
	light.light_energy = 1.5
	light.omni_range = 3.0 + radius * 2.0
	light.position.y = radius
	root.add_child(light)
	return root


## Partículas leves sob os pés enquanto flutua. Começa desligada (`emitting = false`).
static func make_float_wisps() -> CPUParticles3D:
	var particles := CPUParticles3D.new()
	particles.name = "FloatWisps"
	particles.emitting = false
	particles.amount = 20
	particles.lifetime = 0.7
	particles.local_coords = false
	particles.position = Vector3(0, 0.05, 0)
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	particles.emission_ring_axis = Vector3.UP
	particles.emission_ring_radius = 0.45
	particles.emission_ring_inner_radius = 0.2
	particles.emission_ring_height = 0.05
	particles.direction = Vector3.DOWN
	particles.spread = 25.0
	particles.gravity = Vector3.ZERO
	particles.initial_velocity_min = 0.4
	particles.initial_velocity_max = 0.9
	particles.mesh = _particle_mesh(0.035)
	particles.color_ramp = _gradient(Color(0.6, 0.95, 1.0, 0.8), Color(0.4, 0.8, 1.0, 0))
	return particles


## Explosão rápida de partículas com flash de luz. Some sozinha.
static func burst(parent: Node, at: Vector3, color: Color, radius: float) -> void:
	if parent == null:
		return
	var root := Node3D.new()
	root.name = "Burst"
	parent.add_child(root)
	root.global_position = at

	var particles := CPUParticles3D.new()
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 40
	particles.lifetime = 0.6
	particles.direction = Vector3.UP
	particles.spread = 180.0
	particles.gravity = Vector3(0, -4, 0)
	particles.initial_velocity_min = radius * 2.0
	particles.initial_velocity_max = radius * 4.0
	particles.damping_min = radius * 3.0
	particles.damping_max = radius * 5.0
	particles.mesh = _particle_mesh(0.1 + radius * 0.03)
	particles.color_ramp = _gradient(color, Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0))
	root.add_child(particles)
	particles.emitting = true

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 4.0
	light.omni_range = radius * 2.5
	root.add_child(light)
	light.create_tween().tween_property(light, "light_energy", 0.0, 0.35)

	root.get_tree().create_timer(1.2).timeout.connect(root.queue_free)


## Esfera de partícula do raio pedido, criada uma vez por raio (arredondado a 1 mm).
static func _particle_mesh(radius: float) -> Mesh:
	var key := snappedf(radius, 0.001)
	if _meshes.has(key):
		return _meshes[key]
	if _particle_material == null:
		_particle_material = StandardMaterial3D.new()
		_particle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_particle_material.vertex_color_use_as_albedo = true
		_particle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mesh := SphereMesh.new()
	mesh.radius = key
	mesh.height = key * 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	mesh.material = _particle_material
	_meshes[key] = mesh
	return mesh


## Degradê entre duas cores, criado uma vez por par.
static func _gradient(from: Color, to: Color) -> Gradient:
	var key := "%s|%s" % [from.to_html(), to.to_html()]
	if _gradients.has(key):
		return _gradients[key]
	var gradient := Gradient.new()
	gradient.set_color(0, from)
	gradient.set_color(1, to)
	_gradients[key] = gradient
	return gradient

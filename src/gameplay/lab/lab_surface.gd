class_name LabSurface
extends Area3D
## Base das superfícies do laboratório: área no chão com tempo de vida, disco visível e,
## opcionalmente, atrito próprio para os objetos em cima. Recebe calor de explosões por um
## corpo invisível numa camada que não colide com nada.

const DEPTH := 1.2
const HEAT_LAYER := 1 << 19

var radius := 2.5
var duration := 8.0
var color := Color.WHITE
## Atrito dos objetos em cima. Negativo = não muda.
var surface_friction := -1.0

var _time_left := 0.0
var _friction_backup := {}


func _ready() -> void:
	_time_left = duration
	monitorable = false
	collision_layer = 0
	add_to_group(&"lab_surfaces")
	add_to_group(&"heat_receivers")
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = DEPTH
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = DEPTH / 2.0 - 0.1
	add_child(collision)

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.04
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.2
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.02
	add_child(mesh_instance)

	var heat_body := LabHeatBody.new()
	heat_body.receiver = self
	heat_body.collision_layer = HEAT_LAYER
	heat_body.collision_mask = 0
	var heat_shape := CollisionShape3D.new()
	var heat_cylinder := CylinderShape3D.new()
	heat_cylinder.radius = radius
	heat_cylinder.height = 0.2
	heat_shape.shape = heat_cylinder
	heat_body.add_child(heat_shape)
	add_child(heat_body)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	for body in get_overlapping_bodies():
		_affect(body, delta)


func _exit_tree() -> void:
	for body: RigidBody3D in _friction_backup:
		if is_instance_valid(body) and body.physics_material_override:
			body.physics_material_override.friction = _friction_backup[body]
	_friction_backup.clear()


func add_heat(_amount: float) -> void:
	pass


## Distância até a borda da mancha, para o fogo de objetos próximos alcançar a superfície.
func surface_distance(point: Vector3) -> float:
	var flat := Vector2(point.x - global_position.x, point.z - global_position.z)
	return maxf(flat.length() - radius, 0.0)


func contains(point: Vector3) -> bool:
	return surface_distance(point) <= 0.0


func _affect(_body: Node3D, _delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	var rigid := body as RigidBody3D
	if surface_friction < 0.0 or rigid == null or rigid.physics_material_override == null:
		return
	_friction_backup[rigid] = rigid.physics_material_override.friction
	rigid.physics_material_override.friction = surface_friction


func _on_body_exited(body: Node) -> void:
	var rigid := body as RigidBody3D
	if rigid and _friction_backup.has(rigid):
		if rigid.physics_material_override:
			rigid.physics_material_override.friction = _friction_backup[rigid]
		_friction_backup.erase(rigid)

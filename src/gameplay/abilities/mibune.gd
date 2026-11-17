class_name Mibune
extends Node3D
## Mini buraco negro (ver MibuneAbility). Puxa para o centro os objetos soltos e personagens
## dentro do raio, menos quem lançou. Depois de arremessado, anda em linha reta e atravessa
## paredes. Some no fim de `lifetime`.

const CORE_COLOR := Color(0.02, 0.0, 0.05)
const HALO_COLOR := Color(0.5, 0.3, 0.9, 0.18)

var radius := 5.0
var pull_acceleration := 30.0
var lifetime := 5.0
var caster: CollisionObject3D
var velocity := Vector3.ZERO
var thrown := false

var _time := 0.0
var _shape: SphereShape3D


func _ready() -> void:
	_shape = SphereShape3D.new()
	_shape.radius = radius
	add_child(_sphere(0.35, CORE_COLOR, false))
	add_child(_sphere(0.8, HALO_COLOR, true))


func throw(new_velocity: Vector3) -> void:
	velocity = new_velocity
	thrown = true


func time_left() -> float:
	return maxf(lifetime - _time, 0.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= lifetime:
		queue_free()
		return
	global_position += velocity * delta
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _shape
	query.transform = Transform3D(Basis.IDENTITY, global_position)
	if caster:
		query.exclude = [caster.get_rid()]
	for result in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var body: Object = result.collider
		if not body is Node3D:
			continue
		var offset := global_position - DamageRules.center_of(body as Node3D)
		var distance := offset.length()
		if distance < 0.05:
			continue
		var pull := offset / distance * pull_acceleration * clampf(1.0 - distance / radius, 0.0, 1.0) * delta
		if body is RigidBody3D and not (body as RigidBody3D).freeze:
			(body as RigidBody3D).linear_velocity += pull
		elif body is CharacterBody3D:
			(body as CharacterBody3D).velocity += pull


func _sphere(size: float, color: Color, transparent: bool) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if transparent:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	return instance

class_name FireShield
extends Node3D
## Bola da Almôndega de Fogo (ver FireShieldAbility). Filha do mago, centrada no corpo dele.
## A cada quadro de física, consome projéteis mágicos e para objetos soltos que entram na
## esfera vindo na direção do centro.

const COLOR := Color(1.0, 0.45, 0.1, 0.25)

var radius := 1.8
var duration := 3.0
var min_prop_speed := 4.0
var prop_heat := 60.0
var owner_body: CollisionObject3D
## Quantos projéteis já consumiu e quantos objetos parou (para testes e para o HUD).
var consumed := 0
var stopped := 0

var _time := 0.0
var _shape: SphereShape3D


func _ready() -> void:
	_shape = SphereShape3D.new()
	_shape.radius = radius
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = COLOR
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)


func time_left() -> float:
	return maxf(duration - _time, 0.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _shape
	query.transform = Transform3D(Basis.IDENTITY, global_position)
	if owner_body:
		query.exclude = [owner_body.get_rid()]
	for result in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var body := result.collider as RigidBody3D
		if body == null or body.is_queued_for_deletion():
			continue
		var toward := (global_position - body.global_position).normalized()
		var closing := body.linear_velocity.dot(toward)
		if body is MaterializedProjectile:
			# Só o que vem na direção do mago: os projéteis dele mesmo se afastam e passam.
			if closing > 0.0:
				consumed += 1
				Fx.burst(get_tree().current_scene, body.global_position, COLOR, 0.4)
				body.queue_free()
		elif closing > min_prop_speed and not body.freeze:
			stopped += 1
			body.linear_velocity = Vector3.ZERO
			if body.has_method("add_heat"):
				body.add_heat(prop_heat)

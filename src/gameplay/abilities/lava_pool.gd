class_name LavaPool
extends Area3D
## Poça do Chão de Lava (ver LavaFloorAbility). A origem fica no centro, rente ao chão.
## Aquece por segundo tudo que estiver em cima e some depois de `duration` s.

const COLOR := Color(1.0, 0.35, 0.05)
## Altura (m) acima do chão em que a lava ainda queima.
const HEIGHT := 1.0

var side := 3.0
var duration := 5.0
var heat_per_second := 60.0

var _time := 0.0


func _ready() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(side, HEIGHT, side)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = HEIGHT / 2.0
	add_child(collision)

	var mesh := BoxMesh.new()
	mesh.size = Vector3(side, 0.06, side)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLOR
	mat.emission_enabled = true
	mat.emission = COLOR
	mat.emission_energy_multiplier = 1.5
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.03
	add_child(mesh_instance)


func time_left() -> float:
	return maxf(duration - _time, 0.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	for body in get_overlapping_bodies():
		var receiver := BurnEffect.heat_receiver_of(body)
		if receiver:
			receiver.add_heat(heat_per_second * delta)

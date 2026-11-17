class_name LavaPool
extends HeatZone
## Poça do Chão de Lava (ver LavaFloorAbility). A origem fica no centro, rente ao chão.
## É uma zona de calor do mundo (HeatZone): aquece por segundo tudo que estiver em cima, menos o dono
## do calor (`heat_owner`, quem a lançou: o mago nunca se queima com o próprio fogo, e o que ela acende
## também não o queima), e para de aquecer se uma zona sem ar (lama) a cobrir. Some depois de `duration` s.

const COLOR := Color(1.0, 0.35, 0.05)
## Altura (m) acima do chão em que a lava ainda queima.
const HEIGHT := 1.0

var side := 3.0
var duration := 5.0
## Quem lançou (para a cor do rival da mesma classe). O dono do calor é `heat_owner`.
var caster: Node

var _time := 0.0


func _ready() -> void:
	super()
	var shape := BoxShape3D.new()
	shape.size = Vector3(side, HEIGHT, side)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = HEIGHT / 2.0
	add_child(collision)

	var mesh := BoxMesh.new()
	mesh.size = Vector3(side, 0.06, side)
	var mat := StandardMaterial3D.new()
	var color := CasterLook.tint(COLOR, caster)
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
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
	# Lei do Fogo: coberta por uma zona sem ar, a lava não aquece.
	if air_here() <= 0.0:
		return
	var heat := heat_per_second * delta
	var owner_node := heat_owner if is_instance_valid(heat_owner) else null
	for body in get_overlapping_bodies():
		var receiver := BurnEffect.heat_receiver_of(body)
		if receiver and not PhysicsProp.is_heat_owner(receiver, owner_node):
			PhysicsProp.give_heat(receiver, heat, owner_node)

class_name SlowField
extends Area3D
## Bolha do Campo Lento (design/gdd/mage-psionic.md). Corpos rígidos dentro dela (props,
## projéteis) não passam de `max_speed` e caem com gravidade reduzida. É um freio: não
## devolve a velocidade ao sair. Personagens (CharacterBody3D) não são afetados.

const COLOR := Color(0.45, 0.85, 1.0)
const ALPHA := 0.12

var radius := 3.0
var duration := 4.0
var max_speed := 1.5
var gravity_factor := 0.1

var _time_left := 0.0
var _material: StandardMaterial3D


func _ready() -> void:
	_time_left = duration
	monitoring = true
	monitorable = false
	collision_layer = 0
	gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity")) * gravity_factor

	var shape := SphereShape3D.new()
	shape.radius = radius
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material.albedo_color = Color(COLOR, ALPHA)
	mesh.material = _material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)


func get_time_left() -> float:
	return _time_left


func _physics_process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	for body in get_overlapping_bodies():
		var rigid := body as RigidBody3D
		if rigid == null or rigid.freeze:
			continue
		if rigid.linear_velocity.length() > max_speed:
			rigid.linear_velocity = rigid.linear_velocity.normalized() * max_speed
	# Some suavemente no último meio segundo.
	_material.albedo_color.a = ALPHA * clampf(_time_left / 0.5, 0.0, 1.0)

class_name LabArsonist
extends CharacterBody3D
## Incendiário de demonstração. Estados e transições:
##   SEEK  -> LIGHT  ao chegar perto de um barril     | SEEK  -> FLEE ao não achar barril
##   LIGHT -> FLEE   quando o barril pega fogo        | LIGHT -> SEEK se o barril sumir
##   FLEE  -> fim    depois de flee_time              (some da arena)

enum State { SEEK, LIGHT, FLEE }

const HEIGHT := 1.5
const RADIUS := 0.3

var module: LabArsonistModule
var state := State.SEEK

var _barrel: PhysicsProp
var _flee_left := 0.0
var _flee_direction := Vector3.BACK


func _ready() -> void:
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = HEIGHT / 2.0
	add_child(collision)

	var mesh := CapsuleMesh.new()
	mesh.radius = RADIUS
	mesh.height = HEIGHT
	var material := StandardMaterial3D.new()
	material.albedo_color = module.color
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = HEIGHT / 2.0
	add_child(mesh_instance)

	var label := Label3D.new()
	label.text = "Incendiário"
	label.position.y = HEIGHT + 0.3
	label.pixel_size = 0.006
	label.font_size = 48
	label.outline_size = 10
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


## Explosões empurram o Incendiário como qualquer personagem.
func apply_knockback(impulse: Vector3) -> void:
	velocity += impulse / module.body_mass


func _physics_process(delta: float) -> void:
	match state:
		State.SEEK:
			_seek()
		State.LIGHT:
			_light(delta)
		State.FLEE:
			_flee(delta)
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
	move_and_slide()


func _seek() -> void:
	_barrel = _nearest_barrel()
	if _barrel == null:
		_start_flee()
		return
	var offset := _barrel.global_position - global_position
	offset.y = 0.0
	if offset.length() <= module.light_range:
		state = State.LIGHT
		_walk(Vector3.ZERO)
	else:
		_walk(offset.normalized())


func _light(delta: float) -> void:
	if not is_instance_valid(_barrel):
		state = State.SEEK
		return
	_barrel.add_heat(module.light_heat * delta)
	if _barrel.burning:
		_flee_direction = (global_position - _barrel.global_position) * Vector3(1, 0, 1)
		_start_flee()


func _flee(delta: float) -> void:
	_flee_left -= delta
	_walk(_flee_direction.normalized())
	if _flee_left <= 0.0:
		queue_free()


func _start_flee() -> void:
	state = State.FLEE
	_flee_left = module.flee_time


func _walk(direction: Vector3) -> void:
	velocity.x = direction.x * module.move_speed
	velocity.z = direction.z * module.move_speed


func _nearest_barrel() -> PhysicsProp:
	var best: PhysicsProp = null
	var best_distance := INF
	for node in get_tree().get_nodes_in_group(&"physics_props"):
		var prop := node as PhysicsProp
		if not prop.material_data.explosive or prop.burning:
			continue
		var distance := prop.global_position.distance_to(global_position)
		if distance < best_distance:
			best = prop
			best_distance = distance
	return best

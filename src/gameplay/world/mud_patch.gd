class_name MudPatch
extends Area3D
## Lamaçal (design/gdd/mage-elementalist.md). Zona sem ar do mundo (grupo "air_zones",
## design/gdd/physics-magic-system.md): objetos dentro perdem velocidade e calor
## (em chamas, apagam). Personagens andam mais devagar enquanto estão dentro.
## A origem fica no chão, no centro da mancha.

const COLOR := Color(0.32, 0.22, 0.13)
## Altura da área que conta como "dentro da lama" (m).
const DEPTH := 1.2

var radius := 2.5
var duration := 6.0
var drag := 3.0
var cooling := 50.0
var character_speed := 0.5
## Lei do Fogo: lama é zona sem ar (apaga, impede o calor de entrar, abafa a lava e o braseiro).
var air_factor := 0.0

var _time_left := 0.0
var _material: StandardMaterial3D
var _slowed: Array[Node] = []


func _ready() -> void:
	_time_left = duration
	add_to_group(&"air_zones")
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
	_material = StandardMaterial3D.new()
	_material.albedo_color = COLOR
	_material.roughness = 0.35
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = _material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.02
	add_child(mesh_instance)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func get_time_left() -> float:
	return _time_left


func _physics_process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	var factor := exp(-drag * delta)
	for body in get_overlapping_bodies():
		BurnEffect.extinguish_on(body)
		var rigid := body as RigidBody3D
		if rigid == null or rigid.freeze:
			continue
		rigid.linear_velocity *= factor
		rigid.angular_velocity *= factor
		if rigid is PhysicsProp:
			# Sem ar: o próprio objeto se apaga e para de receber calor (lei do mundo).
			(rigid as PhysicsProp).apply_air(air_factor)
			(rigid as PhysicsProp).cool(cooling * delta)
	_material.albedo_color.a = clampf(_time_left / 0.5, 0.0, 1.0)


func _exit_tree() -> void:
	for node in _slowed:
		if is_instance_valid(node):
			node.clear_speed_effect(self)
	_slowed.clear()


func _on_body_entered(body: Node) -> void:
	if body.has_method("set_speed_effect"):
		body.set_speed_effect(self, character_speed)
		_slowed.append(body)


func _on_body_exited(body: Node) -> void:
	if body.has_method("clear_speed_effect"):
		body.clear_speed_effect(self)
		_slowed.erase(body)

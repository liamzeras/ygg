class_name Mibune
extends Node3D
## Mini buraco negro (ver MibuneAbility, design/gdd/mage-gravity.md).
## Lei da Gravidade: é uma área de gravidade do mundo (Area3D com gravidade apontando para o
## centro, somada à do lugar), então todo objeto solto dentro do raio cai para ele, e o peso
## dele (PhysicsProp.get_weight) muda junto. Monstros recebem o mesmo puxão aplicado aqui; magos
## (inclusive quem lançou) não: o corpo de um mago só muda pelas próprias habilidades (ver CasterLook). Depois de disparado, anda em linha reta
## e atravessa paredes. Some no fim de `lifetime`.

const CORE_COLOR := Color(0.02, 0.0, 0.05)
const HALO_COLOR := Color(0.5, 0.3, 0.9, 0.18)

## Materiais compartilhados: [núcleo, halo] normais e do rival da mesma classe.
static var _materials := {}

var radius := 5.0
## Puxão (m/s²) em direção ao centro, igual em todo o raio.
var pull_acceleration := 30.0
var lifetime := 5.0
var caster: Node3D
var velocity := Vector3.ZERO
var thrown := false

var _time := 0.0
var _area: Area3D


func _ready() -> void:
	_area = Area3D.new()
	_area.monitorable = false
	_area.collision_layer = 0
	_area.gravity_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	_area.gravity_point = true
	_area.gravity_point_center = Vector3.ZERO
	_area.gravity_point_unit_distance = 0.0
	_area.gravity = pull_acceleration
	var shape := SphereShape3D.new()
	shape.radius = radius
	var collision := CollisionShape3D.new()
	collision.shape = shape
	_area.add_child(collision)
	add_child(_area)
	var rival := CasterLook.is_rival_same_class(caster)
	add_child(_sphere(0.35, _material(false, rival)))
	add_child(_sphere(0.8, _material(true, rival)))


## Dispara a partir de `from` (logo à frente de quem lançou) com `new_velocity`.
func fire(from: Vector3, new_velocity: Vector3) -> void:
	global_position = from
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
	for node in get_tree().get_nodes_in_group(&"characters"):
		var body := node as CharacterBody3D
		if body == null or body == caster or CasterLook.is_mage(body):
			continue
		var offset := global_position - DamageRules.center_of(body)
		var distance := offset.length()
		if distance < 0.05 or distance > radius:
			continue
		body.velocity += offset / distance * pull_acceleration * delta


func _sphere(size: float, mat: StandardMaterial3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh.material = mat
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	return instance


## Materiais compartilhados entre todos os Mibunes (evita criar e compilar um novo a cada uso).
static func _material(halo: bool, rival: bool) -> StandardMaterial3D:
	var key := int(halo) + 2 * int(rival)
	if _materials.has(key):
		return _materials[key]
	var color := HALO_COLOR if halo else CORE_COLOR
	if rival:
		color = color.darkened(CasterLook.RIVAL_DARKEN)
		color.a = (HALO_COLOR if halo else CORE_COLOR).a
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if halo:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_materials[key] = mat
	return mat

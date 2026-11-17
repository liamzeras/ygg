class_name Mibune
extends Node3D
## Mini buraco negro (ver MibuneAbility, design/gdd/mage-gravity.md).
## Lei da Gravidade: é uma área de gravidade do mundo (Area3D com gravidade apontando para o
## centro, somada à do lugar), então todo objeto solto dentro do raio cai para ele, e o peso
## dele (PhysicsProp.get_weight) muda junto. Monstros recebem o mesmo puxão aplicado aqui; magos
## (inclusive quem lançou) não: o corpo de um mago só muda pelas próprias habilidades (ver CasterLook).
## Disparado, anda em linha reta. Ao bater em algo que não seja objeto solto (parede, chão, pilar,
## personagem), para, fere quem está no raio `impact_radius` (menos quem lançou), racha construções
## da Terra e some depois de `impact_linger` s (Liam, 2026-11-17). Sem bater, some no fim de `lifetime`.

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
## Impacto do Mibune disparado: raio (m), impulso de dano (N·s) e quanto tempo fica depois.
var impact_radius := 2.0
var impact_impulse := 200.0
var impact_linger := 0.4
## Já bateu em algo (para testes e para parar de andar).
var impacted := false

const SOURCE_NAME := "Mibune"

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
	if thrown and not impacted:
		_advance(delta)
	for node in get_tree().get_nodes_in_group(&"characters"):
		var body := node as CharacterBody3D
		if body == null or body == caster or CasterLook.is_mage(body):
			continue
		var offset := global_position - DamageRules.center_of(body)
		var distance := offset.length()
		if distance < 0.05 or distance > radius:
			continue
		body.velocity += offset / distance * pull_acceleration * delta


## Anda o trecho do quadro; se bater em algo que não seja objeto solto, para ali e explode.
func _advance(delta: float) -> void:
	var step := velocity * delta
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + step)
	var exclude: Array[RID] = []
	if caster is CollisionObject3D:
		exclude.append((caster as CollisionObject3D).get_rid())
	for attempt in 4:
		query.exclude = exclude
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break
		# Objetos soltos são puxados, não param o Mibune.
		if hit.collider is RigidBody3D:
			exclude.append(hit.rid)
			continue
		global_position = hit.position as Vector3
		_impact()
		return
	global_position += step


## Para, fere e racha o que está no raio e some logo depois.
func _impact() -> void:
	impacted = true
	velocity = Vector3.ZERO
	lifetime = minf(lifetime, _time + impact_linger)
	var shape := SphereShape3D.new()
	shape.radius = impact_radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, global_position)
	if caster is CollisionObject3D:
		query.exclude = [(caster as CollisionObject3D).get_rid()]
	var done: Array[Object] = []
	for result in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var target: Object = result.collider
		if done.has(target) or not target is Node3D:
			continue
		done.append(target)
		var node := target as Node3D
		var falloff := clampf(1.0 - DamageRules.distance_to(node, global_position) / impact_radius, 0.2, 1.0)
		var impulse := impact_impulse * falloff
		var away := DamageRules.center_of(node) - global_position
		var direction := away.normalized() if away.length() > 0.01 else velocity.normalized()
		var receiver := DamageRules.receiver_of(node)
		if receiver and not DamageRules.is_invulnerable(node):
			receiver.register_hit(SOURCE_NAME, impulse)
		# Objetos e construções: empurrão e Quebrável (PhysicsProp.take_hit, StonePillar.take_hit).
		if node.has_method("take_hit"):
			node.take_hit(direction * impulse, global_position)
	Fx.burst(get_parent(), global_position, HALO_COLOR, impact_radius)


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

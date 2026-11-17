class_name FireWispProjectile
extends MaterializedProjectile
## Projétil do Fogo-Fátuo (ver FireWispAbility). Não tem tempo de vida: só some ao bater.

const RADIUS := 0.2
const COLOR := Color(0.55, 0.9, 1.0)

var ability: FireWispAbility
## Quem lançou (para a cor do rival da mesma classe).
var caster: Node3D

var _origin := Vector3.ZERO
var _done := false


func _ready() -> void:
	gravity_scale = 0.0
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 1
	_origin = global_position

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _shared_mesh(CasterLook.is_rival_same_class(caster))
	add_child(mesh_instance)

	var shape := SphereShape3D.new()
	shape.radius = RADIUS
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	add_child(Fx.make_fire(RADIUS))
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	super(delta)
	if _origin == Vector3.ZERO:
		_origin = global_position
	if global_position.distance_to(_origin) > ability.max_distance:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _done:
		return
	_done = true
	# Mexer na árvore dentro do callback de colisão não é seguro.
	_burn.call_deferred(body)


func _burn(body: Node) -> void:
	if is_instance_valid(body) and body is Node3D:
		var target := body as Node3D
		# Corpos pequenos queimam no centro; paredes e chão, onde o fátuo bateu.
		var at := DamageRules.center_of(target) if (target is RigidBody3D or DamageRules.receiver_of(target)) else global_position
		BurnEffect.attach(target, at, ability.burn_duration, ability.burn_heat_per_second * power, caster)
		if target.has_method("ignite"):
			if target.get_method_argument_count(&"ignite") >= 1:
				target.ignite(caster)
			else:
				target.ignite()
	Fx.burst(get_parent(), global_position, COLOR, 0.5)
	queue_free()


## Malha e material criados uma vez (normal e do rival) e reaproveitados por todos os fátuos.
static var _meshes := {}


static func _shared_mesh(rival: bool) -> Mesh:
	if _meshes.has(rival):
		return _meshes[rival]
	var mesh := SphereMesh.new()
	mesh.radius = RADIUS
	mesh.height = RADIUS * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = COLOR.darkened(CasterLook.RIVAL_DARKEN) if rival else COLOR
	mesh.material = mat
	_meshes[rival] = mesh
	return mesh

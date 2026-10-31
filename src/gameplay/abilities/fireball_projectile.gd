class_name FireballProjectile
extends RigidBody3D
## Projétil da Bola de Fogo. Valores vêm de `ability` (FireballAbility).

const RADIUS := 0.15

var ability: FireballAbility
var impulse := 0.0
var heat := 0.0

var _life := 0.0
var _done := false
var _direct_hit: Node


func _ready() -> void:
	gravity_scale = ability.gravity_scale
	mass = 0.5
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 1
	_life = ability.lifetime

	var mesh := SphereMesh.new()
	mesh.radius = RADIUS
	mesh.height = RADIUS * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 0.6, 0.15)
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	var shape := SphereShape3D.new()
	shape.radius = RADIUS
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	add_child(Fx.make_fire(RADIUS))
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		_detonate()


func _on_body_entered(body: Node) -> void:
	_direct_hit = body
	_detonate.call_deferred()


func _detonate() -> void:
	if _done:
		return
	_done = true
	if is_instance_valid(_direct_hit) and _direct_hit.has_method("add_heat"):
		_direct_hit.add_heat(heat)
	Explosion.detonate(self, global_position, ability.blast_radius, impulse, heat, [get_rid()])
	queue_free()

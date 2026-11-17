class_name FireballProjectile
extends MaterializedProjectile
## Projétil da Bola de Fogo. Valores vêm de `ability` (FireballAbility). O calor não depende
## da velocidade; o empurrão e o dano de impacto sim (ver MaterializedProjectile).

const RADIUS := 0.15

var ability: FireballAbility
## Quem lançou: a explosão não o atinge (o mago nunca se machuca com o próprio fogo).
var caster: CollisionObject3D
var heat := 0.0
var blast_radius := 1.6

var _life := 0.0
var _done := false
var _direct_hit: Node
var _impulse := -1.0


func _ready() -> void:
	gravity_scale = ability.gravity_scale
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 1
	_life = ability.lifetime

	var mesh := SphereMesh.new()
	mesh.radius = RADIUS
	mesh.height = RADIUS * 2.0
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = CasterLook.tint(Color(1, 0.6, 0.15), caster)
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
	super(delta)
	_life -= delta
	if _life <= 0.0:
		_detonate()


func _on_body_entered(body: Node) -> void:
	_direct_hit = body
	_impulse = impact_impulse(body)
	_detonate.call_deferred()


func _detonate() -> void:
	if _done:
		return
	_done = true
	# Sem alvo (tempo acabou), explode com a velocidade que tinha.
	var impulse := _impulse if _impulse >= 0.0 else impact_impulse()
	var direct := _direct_hit as Node3D if is_instance_valid(_direct_hit) else null
	var exclude: Array[RID] = [get_rid()]
	if is_instance_valid(caster):
		exclude.append(caster.get_rid())
	Explosion.detonate(self, global_position, blast_radius, impulse, heat, exclude, Color(1, 0.6, 0.2), direct, ability.display_name)
	queue_free()

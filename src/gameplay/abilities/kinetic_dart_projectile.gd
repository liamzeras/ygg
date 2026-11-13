class_name KineticDartProjectile
extends MaterializedProjectile
## Projétil do Dardo Cinético. Ao bater, aplica o impulso na direção do voo.
## Impulso calculado em MaterializedProjectile: um dardo freado pelo Campo Lento bate fraco.

const COLOR := Color(0.55, 0.95, 1.0)

var source_name := "Dardo Cinético"
var lifetime := 4.0

var _done := false
var _visual: Node3D


func _ready() -> void:
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 1
	can_sleep = false

	_visual = Node3D.new()
	add_child(_visual)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.4)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = COLOR
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	_visual.add_child(mesh_instance)
	var light := OmniLight3D.new()
	light.light_color = COLOR
	light.light_energy = 0.8
	light.omni_range = 1.5
	add_child(light)

	var shape := SphereShape3D.new()
	shape.radius = 0.06
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)


func launch(spell_velocity: Vector3, caster_velocity: Vector3) -> void:
	super(spell_velocity, caster_velocity)
	_orient()


func _physics_process(delta: float) -> void:
	super(delta)
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	_orient()


func _orient() -> void:
	var speed := _flight_velocity.length()
	if _visual and speed > 0.05:
		var direction := _flight_velocity / speed
		if absf(direction.dot(Vector3.UP)) < 0.99:
			_visual.global_basis = Basis.looking_at(direction, Vector3.UP)


func _on_body_entered(body: Node) -> void:
	if _done:
		return
	_done = true
	# Velocidade e direção de antes do choque (a colisão já mudou linear_velocity).
	_hit.call_deferred(body, impact_impulse(body), _flight_velocity.normalized())


func _hit(body: Node, strength: float, direction: Vector3) -> void:
	if is_instance_valid(body) and not DamageRules.is_invulnerable(body):
		if body is RigidBody3D:
			(body as RigidBody3D).apply_central_impulse(direction * strength)
		elif body.has_method("apply_knockback"):
			body.apply_knockback(direction * strength)
		var receiver := DamageRules.receiver_of(body)
		if receiver:
			receiver.register_hit(source_name, strength)
	Fx.burst(get_tree().current_scene, global_position, COLOR, 0.3)
	queue_free()

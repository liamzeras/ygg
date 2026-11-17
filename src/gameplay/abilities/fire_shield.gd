class_name FireShield
extends Node3D
## Bola da Almôndega de Fogo (ver FireShieldAbility, design/gdd/mage-fire.md). Filha do mago,
## centrada no corpo dele. Enquanto dura:
## - absorve o dano que vem de fora: consome projéteis mágicos e para objetos arremessados que
##   entram vindo na direção do centro, e o mago não recebe dano;
## - queima quem está dentro (personagens, boneco, objetos), menos o mago.

const COLOR := Color(1.0, 0.45, 0.1, 0.25)

var radius := 1.8
var duration := 3.0
var min_prop_speed := 4.0
var prop_heat := 60.0
## Calor por segundo em quem está dentro da bola (menos o mago).
var inside_heat_per_second := 40.0
var owner_body: CollisionObject3D
## Quantos projéteis já consumiu e quantos objetos parou (para testes e para o HUD).
var consumed := 0
var stopped := 0

var _time := 0.0
var _shape: SphereShape3D
var _query: PhysicsShapeQueryParameters3D


func _ready() -> void:
	_shape = SphereShape3D.new()
	_shape.radius = radius
	_query = PhysicsShapeQueryParameters3D.new()
	_query.shape = _shape
	if owner_body:
		_query.exclude = [owner_body.get_rid()]
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = CasterLook.tint(COLOR, owner_body)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)


func time_left() -> float:
	return maxf(duration - _time, 0.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	_guard_owner(delta)
	_query.transform = Transform3D(Basis.IDENTITY, global_position)
	var inside_heat := inside_heat_per_second * delta
	for result in get_world_3d().direct_space_state.intersect_shape(_query, 32):
		var node := result.collider as Node3D
		if node == null or node.is_queued_for_deletion():
			continue
		var body := node as RigidBody3D
		if body:
			var toward := (global_position - body.global_position).normalized()
			var closing := body.linear_velocity.dot(toward)
			if body is MaterializedProjectile:
				# Só o que vem na direção do mago: os projéteis dele mesmo se afastam e passam.
				if closing > 0.0:
					consumed += 1
					Fx.burst(get_tree().current_scene, body.global_position, COLOR, 0.4)
					body.queue_free()
				continue
			if closing > min_prop_speed and not body.freeze:
				stopped += 1
				body.linear_velocity = Vector3.ZERO
				if body.has_method("add_heat"):
					PhysicsProp.give_heat(body, prop_heat, owner_body)
		# Quem está dentro queima.
		var receiver := BurnEffect.heat_receiver_of(node)
		if receiver and not PhysicsProp.is_heat_owner(receiver, owner_body):
			PhysicsProp.give_heat(receiver, inside_heat, owner_body)


## O mago não recebe dano enquanto a bola durar.
## PROVISÓRIO: usa a invencibilidade da vida (Health, frente monstros) até existir um filtro
## de dano por origem ("de fora / de dentro"); pedido registrado no relatório da frente classes.
func _guard_owner(delta: float) -> void:
	if owner_body == null:
		return
	var health := owner_body.get_node_or_null("Health")
	if health and "_invulnerable_time" in health:
		health.set("_invulnerable_time", maxf(float(health.get("_invulnerable_time")), delta * 2.0))

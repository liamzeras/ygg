class_name Explosion
extends RefCounted
## Onda de choque: empurra corpos, aquece materiais e arremessa o jogador.
## Fórmulas em design/gdd/physics-magic-system.md (seção Explosões).
## Chamar sempre fora do callback de colisão (use call_deferred) ou em _physics_process.
##
## `direct` é quem levou o acerto direto: recebe tudo, sem queda por distância. Os demais
## perdem força conforme a distância até a superfície do corpo, não até a origem do nó.
## Parede ou pilar entre a explosão e o corpo protege; objetos soltos, personagens e o boneco, não.

## Fração do impulso redirecionada para cima, para os objetos "pularem".
const UPWARD_BIAS := 0.4
## Altura (m) do início do raio de oclusão: explosões rente ao chão não podem se bloquear nele.
const OCCLUSION_LIFT := 0.1
## Corpos soltos atravessados no máximo por um raio de oclusão.
const OCCLUSION_MAX_PASSES := 8
const DAMAGE: DamageRules = preload("res://assets/data/damage_rules.tres")


static func detonate(context: Node3D, origin: Vector3, radius: float, impulse: float, heat: float,
		exclude: Array[RID] = [], color := Color(1, 0.6, 0.2), direct: Node3D = null, direct_source := "Explosão") -> void:
	var space := context.get_world_3d().direct_space_state
	var shape := SphereShape3D.new()
	shape.radius = radius
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis.IDENTITY, origin)
	params.exclude = exclude

	if direct:
		_affect(direct, origin, impulse, heat, direct_source)
	for hit in space.intersect_shape(params, 64):
		var body := hit["collider"] as Node3D
		if body == null or body == direct or not _can_be_affected(body):
			continue
		var falloff := clampf(1.0 - DamageRules.distance_to(body, origin) / radius, 0.0, 1.0)
		if _is_shielded(space, origin, body, exclude):
			falloff *= DAMAGE.blocked_explosion_factor
		_affect(body, origin, impulse * falloff, heat * falloff, "Explosão")

	Fx.burst(context.get_tree().current_scene, origin, color, radius)


static func _affect(body: Node3D, origin: Vector3, impulse: float, heat: float, source: String) -> void:
	var offset := body.global_position - origin
	var distance := offset.length()
	var direction := offset / distance if distance > 0.01 else Vector3.UP
	direction = (direction + Vector3.UP * UPWARD_BIAS).normalized()
	if DamageRules.is_invulnerable(body):
		return
	var receiver := DamageRules.receiver_of(body)
	if body is RigidBody3D:
		(body as RigidBody3D).apply_central_impulse(direction * impulse)
	elif body.has_method("apply_knockback"):
		body.apply_knockback(direction * impulse)
	if receiver:
		receiver.register_hit(source, impulse)
	if heat > 0.0 and receiver and receiver.has_method("add_heat"):
		receiver.add_heat(heat)
	elif heat > 0.0 and body.has_method("add_heat"):
		body.add_heat(heat)


static func _can_be_affected(body: Node3D) -> bool:
	return body is RigidBody3D or body.has_method("apply_knockback") or body.has_method("register_hit") or body.has_method("add_heat")


## true se houver parede ou pilar no caminho até o centro do corpo. Um raio só: quem está
## meio exposto conta como protegido, porque o centro dele está coberto.
static func _is_shielded(space: PhysicsDirectSpaceState3D, origin: Vector3, body: Node3D, exclude: Array[RID]) -> bool:
	var ignored: Array[RID] = exclude.duplicate()
	ignored.append((body as CollisionObject3D).get_rid())
	var query := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * OCCLUSION_LIFT, DamageRules.center_of(body))
	for pass_index in OCCLUSION_MAX_PASSES:
		query.exclude = ignored
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			return false
		if not (hit.collider is RigidBody3D or hit.collider is CharacterBody3D or hit.collider.has_method("register_hit")):
			return true
		ignored.append(hit.rid)
	return false

class_name Explosion
extends RefCounted
## Onda de choque: empurra corpos, aquece materiais e arremessa o jogador.
## Fórmulas em design/gdd/physics-magic-system.md (seção Explosões).
## Chamar sempre fora do callback de colisão (use call_deferred) ou em _physics_process.
##
## `direct` é quem levou o acerto direto: recebe tudo, sem queda por distância. Os demais
## perdem força conforme a distância até a superfície do corpo, não até a origem do nó.

## Fração do impulso redirecionada para cima, para os objetos "pularem".
const UPWARD_BIAS := 0.4


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
		if body == null or body == direct:
			continue
		var falloff := clampf(1.0 - DamageRules.distance_to(body, origin) / radius, 0.0, 1.0)
		_affect(body, origin, impulse * falloff, heat * falloff, "Explosão")

	Fx.burst(context.get_tree().current_scene, origin, color, radius)


static func _affect(body: Node3D, origin: Vector3, impulse: float, heat: float, source: String) -> void:
	var offset := body.global_position - origin
	var distance := offset.length()
	var direction := offset / distance if distance > 0.01 else Vector3.UP
	direction = (direction + Vector3.UP * UPWARD_BIAS).normalized()
	if body is RigidBody3D:
		(body as RigidBody3D).apply_central_impulse(direction * impulse)
	elif body.has_method("apply_knockback"):
		body.apply_knockback(direction * impulse)
	if body.has_method("register_hit"):
		body.register_hit(source, impulse)
	if heat > 0.0 and body.has_method("add_heat"):
		body.add_heat(heat)

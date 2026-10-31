class_name ShieldBashAbility
extends Ability
## Cavaleiro — Golpe de Escudo: empurra tudo num cone à frente.
## Impulso = impulso-base x mult(Força). Objetos leves voam, pesados mal se mexem.

@export var reach := 2.5
@export var half_angle_degrees := 50.0
## Impulso (N·s) com Força humana. Técnica treinada: ~2x um empurrão comum.
@export var base_impulse := 120.0
## Quanto do empurrão vai para cima (0 = só horizontal).
@export var lift := 0.3
@export var shake := 0.35


func activate(player: Player) -> void:
	var origin := player.get_aim_origin()
	var direction := player.get_aim_direction()
	var push_direction := (direction + Vector3.UP * lift).normalized()
	var min_dot := cos(deg_to_rad(half_angle_degrees))
	var impulse := base_impulse * power(player)

	var shape := SphereShape3D.new()
	shape.radius = reach
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis.IDENTITY, origin)
	params.exclude = [player.get_rid()]

	for hit in player.get_world_3d().direct_space_state.intersect_shape(params, 32):
		var body := hit["collider"] as Node3D
		if body == null:
			continue
		var offset := body.global_position - origin
		var distance := offset.length()
		if distance > 0.01 and offset.normalized().dot(direction) < min_dot:
			continue
		var falloff := 1.0 - 0.5 * clampf(distance / reach, 0.0, 1.0)
		if body is RigidBody3D:
			(body as RigidBody3D).apply_central_impulse(push_direction * impulse * falloff)
		if body.has_method("register_hit"):
			body.register_hit(display_name, impulse * falloff)

	player.add_shake(shake)
	Fx.burst(player.get_tree().current_scene, origin + direction * 1.2, Color(0.7, 0.85, 1.0), 0.6)

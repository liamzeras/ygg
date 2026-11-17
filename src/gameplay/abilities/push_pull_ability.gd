class_name PushPullAbility
extends Ability
## Gravidade — Push-Pull (design/gdd/mage-gravity.md): age no objeto ou personagem na mira.
## Perto (até `push_distance`) empurra na direção da mira; longe, puxa para o mago.
## Também rebate projéteis mágicos à frente que vêm na direção do mago, se o impulso do
## Push-Pull for maior ou igual ao que o projétil causaria.
## Impulso = base_impulse x mult(atributo).

@export var reach := 15.0
@export var push_distance := 4.0
@export var base_impulse := 120.0
## Área à frente (m) onde projéteis são rebatidos.
@export var deflect_width := 2.0
@export var deflect_depth := 8.0

## Resultado do último uso, para testes e feedback: &"push", &"pull" ou &"".
var last_action := &""
var last_deflected := 0


func impulse(player: Player) -> float:
	return base_impulse * power(player)


func activate(player: Player) -> void:
	last_action = &""
	last_deflected = _deflect(player)
	var aim := player.get_aim_direction()
	var origin := player.get_aim_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + aim * reach)
	query.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var target: Object = hit.collider
	var pushing := origin.distance_to(hit.position) <= push_distance
	var direction := aim
	if not pushing:
		direction = (player.get_center() - (hit.position as Vector3)).normalized()
	var force := impulse(player)
	var receiver := DamageRules.receiver_of(target as Node)
	if target is RigidBody3D and not (target as RigidBody3D).freeze:
		(target as RigidBody3D).apply_central_impulse(direction * force)
	elif target.has_method("apply_knockback"):
		target.apply_knockback(direction * force)
	elif receiver == null:
		return
	# Só o empurrão machuca; o puxão apenas move.
	if pushing and receiver and not DamageRules.is_invulnerable(target as Node):
		receiver.register_hit(display_name, force)
	last_action = &"push" if pushing else &"pull"
	Fx.burst(player.get_parent(), hit.position, Color(0.6, 0.45, 1.0), 0.4)
	player.add_shake(0.1)


## Rebate para a mira os projéteis à frente que vêm na direção do mago. Devolve quantos.
func _deflect(player: Player) -> int:
	var aim := player.get_aim_direction()
	var box := BoxShape3D.new()
	box.size = Vector3(deflect_width, deflect_width, deflect_depth)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	var center := player.get_aim_origin() + aim * deflect_depth / 2.0
	var up := Vector3.UP if absf(aim.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
	query.transform = Transform3D(Basis.looking_at(aim, up), center)
	query.exclude = [player.get_rid()]
	var count := 0
	var force := impulse(player)
	for result in player.get_world_3d().direct_space_state.intersect_shape(query, 32):
		var projectile := result.collider as MaterializedProjectile
		if projectile == null or projectile.is_queued_for_deletion():
			continue
		var toward := (player.get_center() - projectile.global_position).normalized()
		if projectile.linear_velocity.dot(toward) <= 0.0:
			continue
		if force >= projectile.impact_impulse(player):
			projectile.launch(aim * projectile.linear_velocity.length(), Vector3.ZERO)
			count += 1
	return count

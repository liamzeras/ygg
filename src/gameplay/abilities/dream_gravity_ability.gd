class_name DreamGravityAbility
extends Ability
## Gravidade — Gravidade dos Sonhos (design/gdd/mage-gravity.md): zona fixa em volta do mago.
## Adversários dentro ficam mais lentos e pesados; o mago, dentro, pula mais alto e tem
## recargas mais curtas, tudo na mesma proporção (`strength`).
## Área = max_side² x nível / nível máximo. Uma por vez.

@export var max_side := 9.0
@export var duration := 6.0
@export_range(0.0, 0.9) var strength := 0.4

var _active: DreamGravityZone


func side(player: Player) -> float:
	return sqrt(max_side * max_side * level_share(player))


func get_active_zone() -> DreamGravityZone:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	if is_instance_valid(_active):
		_active.queue_free()
	var zone := DreamGravityZone.new()
	zone.side = side(player)
	zone.duration = duration
	zone.strength = strength
	zone.caster = player
	player.get_parent().add_child(zone)
	zone.global_transform = Transform3D(Basis.looking_at(player.get_flat_forward(), Vector3.UP), player.global_position)
	_active = zone

class_name BrawlGrabAbility
extends Ability
## Gravidade — Agarrar, dentro da Zona Nula (design/gdd/mage-gravity.md): segura por
## `hold_time` s o personagem à frente, que fica parado. Nesse tempo, o próximo golpe do mago
## sai de graça (ver StoneStrikeAbility.FREE_STRIKE_META).

@export var reach := 1.6
@export var width := 0.9
@export var hold_time := 0.3

## Último personagem agarrado (para testes).
var last_target: Node3D


func activate(player: Player) -> void:
	last_target = _find_target(player)
	if last_target == null:
		return
	player.set_meta(StoneStrikeAbility.FREE_STRIKE_META, StoneStrikeAbility.now() + hold_time)
	if last_target.has_method("set_speed_effect"):
		last_target.set_speed_effect(self, 0.0)
		player.get_tree().create_timer(hold_time).timeout.connect(last_target.clear_speed_effect.bind(self))
	player.add_shake(0.15)


## Personagem ou boneco mais próximo à frente, ou null.
func _find_target(player: Player) -> Node3D:
	var box := BoxShape3D.new()
	box.size = Vector3(width, Player.BODY_HEIGHT, reach)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	var forward := player.get_flat_forward()
	var center := player.global_position + Vector3.UP * Player.BODY_HEIGHT / 2.0 + forward * (Player.BODY_RADIUS + reach / 2.0)
	query.transform = Transform3D(Basis.looking_at(forward, Vector3.UP), center)
	query.exclude = [player.get_rid()]
	var best: Node3D = null
	var best_distance := INF
	for result in player.get_world_3d().direct_space_state.intersect_shape(query, 16):
		var body := result.collider as Node3D
		if body == null or DamageRules.receiver_of(body) == null:
			continue
		var d := body.global_position.distance_to(player.global_position)
		if d < best_distance:
			best = body
			best_distance = d
	return best

class_name SlowFieldAbility
extends Ability
## Psiônico — Campo Lento (design/gdd/mage-psionic.md): bolha no ponto mirado onde nada
## passa de `max_speed_inside`. Não afeta o próprio jogador. Só um campo por vez.
## duração = base_duration x raiz(mult(Inteligência)).

@export var radius := 3.0
@export var base_duration := 2.5
@export var reach := 15.0
@export var max_speed_inside := 1.5
## Gravidade dentro da bolha (fração da normal).
@export_range(0.0, 1.0) var gravity_factor := 0.1

var _active: SlowField


func duration(player: Player) -> float:
	return base_duration * sqrt(power(player))


func get_active_field() -> SlowField:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	if is_instance_valid(_active):
		_active.queue_free()
	var origin := player.get_aim_origin()
	var target := origin + player.get_aim_direction() * reach
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var field := SlowField.new()
	field.radius = radius
	field.duration = duration(player)
	field.max_speed = max_speed_inside
	field.gravity_factor = gravity_factor
	player.get_tree().current_scene.add_child(field)
	field.global_position = hit.position if hit else target
	_active = field

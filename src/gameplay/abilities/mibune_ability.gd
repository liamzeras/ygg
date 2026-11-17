class_name MibuneAbility
extends Ability
## Gravidade — Mibune, o mini buraco negro (design/gdd/mage-gravity.md). A primeira conjuração
## cria o Mibune no ponto mirado; ele puxa objetos e personagens próximos, menos quem lançou.
## Com ele ativo, conjurar de novo o arremessa na direção da mira.

## Distância (m) em que nasce se não houver nada na mira.
@export var spawn_distance := 8.0
@export var radius := 5.0
## Puxão (m/s²) no centro; cai a zero na borda do raio. Escala com mult(atributo).
@export var pull_acceleration := 30.0
@export var throw_speed := 25.0
@export var lifetime := 5.0

var _active: Mibune


func get_active() -> Mibune:
	return _active if is_instance_valid(_active) else null


## Com um Mibune parado no ar, usar de novo é o arremesso: sem custo nem recarga.
func toggles_off(_player: Player) -> bool:
	return is_instance_valid(_active) and not _active.thrown


func activate(player: Player) -> void:
	var aim := player.get_aim_direction()
	if is_instance_valid(_active) and not _active.thrown:
		_active.throw(aim * throw_speed)
		player.add_shake(0.2)
		return
	if is_instance_valid(_active):
		_active.queue_free()
	var origin := player.get_aim_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + aim * spawn_distance)
	query.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var point: Vector3 = origin + aim * spawn_distance
	if not hit.is_empty():
		point = (hit.position as Vector3) - aim * 0.5
	var hole := Mibune.new()
	hole.radius = radius
	hole.pull_acceleration = pull_acceleration * power(player)
	hole.lifetime = lifetime
	hole.caster = player
	player.get_parent().add_child(hole)
	hole.global_position = point
	_active = hole

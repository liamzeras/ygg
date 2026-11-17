class_name MibuneAbility
extends Ability
## Gravidade — Mibune, o mini buraco negro (design/gdd/mage-gravity.md).
## 1ª conjuração: surge no ponto mirado e puxa objetos e personagens próximos (menos quem lançou).
## 2ª conjuração (sem custo nem recarga): sai da frente de quem lançou e dispara rápido na
## direção da mira, como um projétil. Ao bater, fere quem está perto e some logo depois.

## Distância (m) em que nasce se não houver nada na mira.
@export var spawn_distance := 8.0
@export var radius := 5.0
## Puxão (m/s²) em direção ao centro. Escala com mult(atributo).
@export var pull_acceleration := 30.0
@export var throw_speed := 35.0
## Distância (m) à frente da mira de onde o Mibune sai ao ser disparado.
@export var launch_offset := 1.2
@export var lifetime := 5.0
## Disparado, ao bater em parede, chão, pilar ou personagem: raio (m) e impulso de dano (N·s,
## x mult(atributo)) do impacto, e por quanto tempo (s) ainda fica antes de sumir.
@export var impact_radius := 2.0
@export var impact_impulse := 200.0
@export var impact_linger := 0.4

var _active: Mibune


func get_active() -> Mibune:
	return _active if is_instance_valid(_active) else null


## Com um Mibune parado no ar, usar de novo é o disparo: sem custo nem recarga.
func toggles_off(_player: Player) -> bool:
	return is_instance_valid(_active) and not _active.thrown


func activate(player: Player) -> void:
	var aim := player.get_aim_direction()
	var origin := player.get_aim_origin()
	if is_instance_valid(_active) and not _active.thrown:
		_active.fire(origin + aim * launch_offset, aim * throw_speed)
		player.add_shake(0.2)
		return
	if is_instance_valid(_active):
		_active.queue_free()
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
	hole.impact_radius = impact_radius
	hole.impact_impulse = impact_impulse * power(player)
	hole.impact_linger = impact_linger
	hole.caster = player
	player.get_parent().add_child(hole)
	hole.global_position = point
	_active = hole

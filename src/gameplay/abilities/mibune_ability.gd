class_name MibuneAbility
extends Ability
## Gravidade — Mibune, o mini buraco negro (design/gdd/mage-gravity.md).
## 1ª conjuração: se forma `spawn_offset` m à frente do corpo de quem lançou, na altura do peito, e
## puxa os objetos e monstros próximos ali (magos não). 2ª conjuração (sem custo nem recarga): sai
## `spawn_offset` m à frente da mira e dispara rápido na direção da mira, como um projétil. Ao bater, fere quem está perto e some logo depois.

## Distância (m) à frente do corpo de quem lançou onde o Mibune se forma, e à frente da mira de onde
## ele sai ao ser disparado (Liam, 2026-11-17: 0,3 m).
@export var spawn_offset := 0.3
@export var radius := 5.0
## Puxão (m/s²) em direção ao centro. Escala com mult(atributo).
@export var pull_acceleration := 30.0
@export var throw_speed := 35.0
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
		_active.fire(origin + aim * spawn_offset, aim * throw_speed)
		player.add_shake(0.2)
		return
	if is_instance_valid(_active):
		_active.queue_free()
	var point := spawn_point(player)
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


## Onde o Mibune se forma: `spawn_offset` m à frente do corpo de quem lançou, na altura do peito.
func spawn_point(player: Player) -> Vector3:
	var chest := player.global_position + Vector3.UP * Player.BODY_HEIGHT / 2.0
	return chest + player.get_flat_forward() * (Player.BODY_RADIUS + spawn_offset)

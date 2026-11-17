class_name JetFlightAbility
extends Ability
## Fogo — Jatos de Fogo (design/gdd/mage-fire.md): a primeira ativação liga o voo (ver
## Player.start_flight); com o voo ligado, ativar de novo dá um impulso na direção da mira.
## Duração do voo = max_duration x nível / nível máximo.

@export var max_duration := 15.0
@export var fly_speed := 9.0
@export var boost_speed := 20.0
## Mana de cada impulso (o custo normal paga só a primeira ativação).
@export var boost_cost := 10.0

const COLOR := Color(1.0, 0.55, 0.15)


func duration(player: Player) -> float:
	return max_duration * level_share(player)


## Com o voo ligado, usar de novo é o impulso: sem a recarga nem o custo da ativação.
func toggles_off(player: Player) -> bool:
	return player.is_flying()


func get_status_text(player: Player) -> String:
	return "Voo %.0fs" % ceilf(player.get_flight_time()) if player.is_flying() else ""


func activate(player: Player) -> void:
	if player.is_flying():
		_boost(player)
		return
	var time := duration(player)
	player.start_flight(time, fly_speed)
	var fire := Fx.make_fire(0.3)
	player.add_child(fire)
	fire.position = Vector3(0, 0.1, 0)
	player.get_tree().create_timer(time).timeout.connect(fire.queue_free)
	Fx.burst(player.get_parent(), player.global_position, COLOR, 0.6)


func _boost(player: Player) -> void:
	if player.get_pool(Player.Pool.MANA) < boost_cost and not player.debug_infinite_resources:
		player.action_failed.emit("%s insuficiente" % Player.POOL_NAMES[Player.Pool.MANA])
		return
	player.spend(Player.Pool.MANA, boost_cost)
	player.velocity = player.get_aim_direction() * boost_speed
	Fx.burst(player.get_parent(), player.global_position, COLOR, 0.8)
	player.add_shake(0.2)

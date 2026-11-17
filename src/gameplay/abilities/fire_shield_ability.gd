class_name FireShieldAbility
extends Ability
## Fogo — Almôndega de Fogo (design/gdd/mage-fire.md): bola de fogo em volta do mago por
## `duration` s. Projéteis mágicos que entram vindo na direção dele são consumidos; objetos
## soltos que chegam rápido são parados e aquecidos.

@export var radius := 1.8
@export var duration := 3.0
## Velocidade mínima (m/s) de aproximação para um objeto solto contar como arremessado.
@export var min_prop_speed := 4.0
## Calor passado ao objeto parado.
@export var prop_heat := 60.0

var _active: FireShield


func get_active_shield() -> FireShield:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	if is_instance_valid(_active):
		_active.queue_free()
	var shield := FireShield.new()
	shield.radius = radius
	shield.duration = duration
	shield.min_prop_speed = min_prop_speed
	shield.prop_heat = prop_heat * power(player)
	shield.owner_body = player
	player.add_child(shield)
	shield.position = Vector3.UP * Player.BODY_HEIGHT / 2.0
	_active = shield

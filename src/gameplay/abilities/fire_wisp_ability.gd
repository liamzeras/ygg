class_name FireWispAbility
extends Ability
## Fogo — Fogo-Fátuo (design/gdd/mage-fire.md): bola de fogo lenta, reta e sem gravidade,
## que só some ao bater em algo. O que ela toca queima por `burn_duration` s, seja qual for
## o material. Calor por segundo = burn_heat_per_second x mult(atributo).

@export var speed := 6.0
@export var mass := 0.01
@export var burn_duration := 10.0
@export var burn_heat_per_second := 20.0
## Distância (m) de onde nasceu em que um fátuo perdido é apagado.
@export var max_distance := 300.0


func activate(player: Player) -> void:
	var direction := player.get_aim_direction()
	var wisp := FireWispProjectile.new()
	wisp.ability = self
	wisp.mass = mass
	wisp.power = power(player)
	player.get_parent().add_child(wisp)
	wisp.global_position = player.get_aim_origin() + direction * 0.7
	wisp.launch(direction * speed, Vector3.ZERO)
	wisp.add_collision_exception_with(player)

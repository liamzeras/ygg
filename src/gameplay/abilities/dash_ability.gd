class_name DashAbility
extends Ability
## Dash curto (todas as classes, Ctrl): arrancada na direção do movimento, ou para a frente
## se parado. Igual para todos: velocidade de movimento não depende de atributo.
## Move pela colisão normal do personagem, então nunca atravessa paredes.
## Impacto = massa do personagem x velocidade x transferência.

@export var distance := 3.0
@export var duration := 0.2
## Fração da quantidade de movimento passada a quem for atingido.
@export_range(0.0, 1.0) var momentum_transfer := 0.1


func activate(player: Player) -> void:
	var direction := player.get_move_direction().normalized()
	if direction == Vector3.ZERO:
		direction = player.get_flat_forward()
	var speed := distance / duration
	var impact := player.class_data.body_mass * speed * momentum_transfer
	player.start_dash(direction * speed, duration, impact, display_name)
	player.add_shake(0.08)

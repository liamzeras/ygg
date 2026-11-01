class_name ChargeAbility
extends Ability
## Cavaleiro — Investida: arrancada no chão que atropela objetos no caminho.
## Velocidade = base x raiz(mult(Força)): arrancada vem das pernas (Agilidade não entra).
## Impacto = massa do cavaleiro x velocidade x fração transferida (quantidade de movimento).

@export var base_speed := 9.0
@export var duration := 0.4
## Fração da quantidade de movimento do cavaleiro passada a cada objeto atingido.
@export_range(0.0, 1.0) var momentum_transfer := 0.4


func get_block_reason(player: Player) -> String:
	return "" if player.is_on_floor() else "Precisa estar no chão"


func activate(player: Player) -> void:
	var speed := base_speed * sqrt(power(player))
	var impact := player.class_data.body_mass * speed * momentum_transfer
	player.start_dash(player.get_flat_forward() * speed, duration, impact, display_name)
	player.add_shake(0.15)

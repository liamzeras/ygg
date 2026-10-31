class_name GuardAbility
extends Ability
## Cavaleiro — Postura de Muralha: ergue o escudo e finca os pés por alguns segundos.
## Reduz empurrões e explosões recebidos, mas deixa o cavaleiro lento.
## Duração = base x mult(Vitalidade)^0.5.

@export var base_duration := 2.5
## Fração do empurrão ignorada (0.85 = recebe só 15%).
@export_range(0.0, 1.0) var knockback_reduction := 0.85
## Multiplicador de velocidade enquanto em guarda.
@export_range(0.0, 1.0) var move_speed_factor := 0.45


func activate(player: Player) -> void:
	player.start_guard(base_duration * sqrt(power(player)), knockback_reduction, move_speed_factor)
	player.add_shake(0.1)

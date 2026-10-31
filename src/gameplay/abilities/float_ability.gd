class_name FloatAbility
extends Ability
## Psiônico — Flutuar (design/gdd/mage-psionic.md): segurando Espaço enquanto cai,
## a queda fica limitada e o controle no ar fica igual ao do chão. Drena Mana.
## `cost` = Mana mínima para começar. dreno = base_drain / raiz(mult(Inteligência)).

@export var max_fall_speed := 1.5
@export var base_drain := 15.0


func drain_per_second(player: Player) -> float:
	return base_drain / sqrt(power(player))

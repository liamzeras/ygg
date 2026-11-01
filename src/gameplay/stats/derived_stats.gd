class_name DerivedStats
extends RefCounted
## Valores físicos já calculados a partir dos atributos (ver AttributeRules.derive).

var multipliers := {}
var carry_mass := 0.0
var throw_speed := 0.0
var push_force := 0.0
var walk_speed := 0.0
var sprint_speed := 0.0
var jump_height := 0.0
## Velocidade de ataque (1.0 = humano). Divide a recarga e o tempo de carga do botão esquerdo.
var attack_speed := 1.0
var hold_stiffness := 0.0
var max_stamina := 0.0
var stamina_regen := 0.0
var max_mana := 0.0
var mana_regen := 0.0


## Multiplicador do atributo em relação a um humano comum (1.0 = humano).
func mult(kind: Attributes.Kind) -> float:
	return multipliers.get(kind, 1.0)

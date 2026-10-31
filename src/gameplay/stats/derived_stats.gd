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
var hold_stiffness := 0.0
var max_resource := 0.0
var resource_regen := 0.0


## Multiplicador do atributo em relação a um humano comum (1.0 = humano).
func mult(kind: Attributes.Kind) -> float:
	return multipliers.get(kind, 1.0)

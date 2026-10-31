class_name Attributes
extends Resource
## Os seis atributos de um personagem. Referência humana (adulto em forma, ~1,80 m):
## FOR 20, AGI 12, VIT 15, DES 7, INT 11, SOR 5. Teto com bônus: ~150.
## Ver design/gdd/attributes.md.

enum Kind { STRENGTH, AGILITY, VITALITY, DEXTERITY, INTELLIGENCE, LUCK }

const NAMES := {
	Kind.STRENGTH: "Força",
	Kind.AGILITY: "Agilidade",
	Kind.VITALITY: "Vitalidade",
	Kind.DEXTERITY: "Destreza",
	Kind.INTELLIGENCE: "Inteligência",
	Kind.LUCK: "Sorte",
}

@export_range(1, 150) var strength := 20.0
@export_range(1, 150) var agility := 12.0
@export_range(1, 150) var vitality := 15.0
@export_range(1, 150) var dexterity := 7.0
@export_range(1, 150) var intelligence := 11.0
@export_range(1, 150) var luck := 5.0


func get_value(kind: Kind) -> float:
	match kind:
		Kind.STRENGTH: return strength
		Kind.AGILITY: return agility
		Kind.VITALITY: return vitality
		Kind.DEXTERITY: return dexterity
		Kind.INTELLIGENCE: return intelligence
		_: return luck


func set_value(kind: Kind, value: float) -> void:
	match kind:
		Kind.STRENGTH: strength = value
		Kind.AGILITY: agility = value
		Kind.VITALITY: vitality = value
		Kind.DEXTERITY: dexterity = value
		Kind.INTELLIGENCE: intelligence = value
		_: luck = value

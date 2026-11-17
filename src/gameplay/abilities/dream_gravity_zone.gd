class_name DreamGravityZone
extends GravityZone
## Zona da Gravidade dos Sonhos (ver DreamGravityAbility). Quem lançou ganha pulo e pressa;
## os outros personagens ficam mais lentos e pesados, na mesma proporção.

var strength := 0.4


func _on_enter(character: Node3D) -> void:
	if character == caster:
		if character.has_method("set_effect"):
			character.set_effect(Player.EFFECT_JUMP, self, 1.0 + strength)
			character.set_effect(Player.EFFECT_HASTE, self, 1.0 + strength)
		return
	if character.has_method("set_speed_effect"):
		character.set_speed_effect(self, 1.0 - strength)
	if character.has_method("set_effect"):
		character.set_effect(Player.EFFECT_WEIGHT, self, 1.0 + strength)


func _on_exit(character: Node3D) -> void:
	if character.has_method("clear_speed_effect"):
		character.clear_speed_effect(self)
	if character.has_method("clear_effect"):
		for kind: StringName in [Player.EFFECT_JUMP, Player.EFFECT_HASTE, Player.EFFECT_WEIGHT]:
			character.clear_effect(kind, self)

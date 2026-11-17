class_name DreamGravityZone
extends GravityZone
## Zona da Gravidade dos Sonhos (ver DreamGravityAbility). Quem lançou ganha pulo e pressa;
## os outros personagens ficam mais lentos e, se forem monstros, mais pesados (magos só mudam de
## peso pelas próprias habilidades), na mesma proporção.
## Lei da Gravidade: a zona também é uma área de gravidade do mundo (gravidade x (1 + strength)),
## então objetos soltos dentro dela pesam mais e caem mais rápido, para todos.

var strength := 0.4


func _ready() -> void:
	super()
	var area := Area3D.new()
	area.monitorable = false
	area.collision_layer = 0
	area.gravity_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	area.gravity_direction = Vector3.DOWN
	area.gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity")) * strength
	var shape := BoxShape3D.new()
	shape.size = Vector3(side, HEIGHT, side)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = HEIGHT / 2.0
	area.add_child(collision)
	add_child(area)


func _on_enter(character: Node3D) -> void:
	if character == caster:
		if character.has_method("set_effect"):
			character.set_effect(Player.EFFECT_JUMP, self, 1.0 + strength)
			character.set_effect(Player.EFFECT_HASTE, self, 1.0 + strength)
		return
	if character.has_method("set_speed_effect"):
		character.set_speed_effect(self, 1.0 - strength)
	# Peso: só monstros. O corpo de um mago só muda de peso pelas próprias habilidades (Liam, 2026-11-17).
	if character.has_method("set_effect") and not CasterLook.is_mage(character):
		character.set_effect(Player.EFFECT_WEIGHT, self, 1.0 + strength)


func _on_exit(character: Node3D) -> void:
	if character.has_method("clear_speed_effect"):
		character.clear_speed_effect(self)
	if character.has_method("clear_effect"):
		for kind: StringName in [Player.EFFECT_JUMP, Player.EFFECT_HASTE, Player.EFFECT_WEIGHT]:
			character.clear_effect(kind, self)

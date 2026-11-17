class_name NullZoneAbility
extends Ability
## Gravidade — Zona Nula (design/gdd/mage-gravity.md): gasta toda a Mana e cria uma zona fixa
## em volta do mago onde ninguém usa habilidades e projéteis mágicos somem. Quem lançou troca
## o kit pelos golpes daqui enquanto estiver dentro. `cost` é a Mana mínima para lançar.
## Área = max_side² x nível / nível máximo; duração fixa.

@export var max_side := 9.0
@export var duration := 8.0
@export_group("Golpes dentro da zona")
## Botão esquerdo e direito.
@export var punch_left: Ability
@export var punch_right: Ability
## Ctrl e Q.
@export var kick_left: Ability
@export var kick_right: Ability
## E.
@export var grab: Ability

var _active: NullZone


func side(player: Player) -> float:
	return sqrt(max_side * max_side * level_share(player))


func get_active_zone() -> NullZone:
	return _active if is_instance_valid(_active) else null


## Kit de quem lançou dentro da zona: {espaço: Ability}.
func brawl_kit() -> Dictionary:
	return {
		Player.SLOT_PRIMARY: punch_left,
		Player.SLOT_SECONDARY: punch_right,
		Player.SLOT_UTILITY: kick_left,
		Player.SLOT_MOBILITY: kick_right,
		Player.ACTION_GRAB: grab,
	}


func activate(player: Player) -> void:
	# O custo mínimo já foi cobrado; o resto da Mana vai junto.
	player.spend(Player.Pool.MANA, player.get_pool(Player.Pool.MANA))
	if is_instance_valid(_active):
		_active.queue_free()
	var zone := NullZone.new()
	zone.side = side(player)
	zone.duration = duration
	zone.caster = player
	zone.kit = brawl_kit()
	zone.color = Color(0.75, 0.75, 0.8, 0.22)
	player.get_parent().add_child(zone)
	zone.global_transform = Transform3D(Basis.looking_at(player.get_flat_forward(), Vector3.UP), player.global_position)
	_active = zone

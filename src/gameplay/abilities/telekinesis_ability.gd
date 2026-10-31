class_name TelekinesisAbility
extends Ability
## Mago — Telecinese: segura um objeto à distância e arremessa com o botão esquerdo.
## Por ser "mais surreal" que as mãos, é mais limitada: carrega menos peso que
## os braços de um cavaleiro, segura com menos firmeza e drena mana enquanto ativa.
## Carga = base x mult(Inteligência). Usar de novo solta o objeto.

@export var reach := 8.0
@export var base_carry_mass := 12.0
@export var mana_per_second := 8.0
@export var base_throw_speed := 6.0
@export var stiffness := 6.0
@export var hold_distance := 3.0
## Mana gasta ao arremessar (Telecinese Acelerada do Psiônico). 0 = de graça.
@export var throw_cost := 0.0


func toggles_off(player: Player) -> bool:
	return player.is_holding_telekinetically()


func get_block_reason(player: Player) -> String:
	var body := player.get_aimed_body(reach)
	if body == null:
		return "Nenhum objeto na mira"
	if body.mass > carry_mass(player):
		return "Pesado demais para a telecinese (%d kg)" % roundi(body.mass)
	return ""


func carry_mass(player: Player) -> float:
	return base_carry_mass * power(player)


func activate(player: Player) -> void:
	if player.is_holding_telekinetically():
		player.release_held()
		return
	var body := player.get_aimed_body(reach)
	player.hold(body, {
		"telekinetic": true,
		"distance": hold_distance,
		"stiffness": stiffness * sqrt(power(player)),
		"throw_speed": base_throw_speed * sqrt(power(player)),
		"carry_mass": carry_mass(player),
		"drain": mana_per_second,
		"throw_cost": throw_cost,
	})

class_name MudAbility
extends TerrainAbility
## Elementalista — Lamaçal (design/gdd/mage-elementalist.md): mancha de lama no chão mirado.
## Freia objetos, apaga fogo e deixa personagens (inclusive quem lançou) mais lentos.
## duração = base_duration x raiz(mult(Inteligência)). Só um por vez.

@export var radius := 2.5
@export var base_duration := 4.0
## Arrasto (por segundo) nos objetos: velocidade x e^(−drag x dt).
@export var drag := 3.0
## Calor retirado por segundo dos objetos na lama.
@export var cooling := 50.0
## Multiplicador da velocidade de personagens dentro da lama.
@export_range(0.1, 1.0) var character_speed := 0.5

var _active: MudPatch


func duration(player: Player) -> float:
	return base_duration * sqrt(power(player))


func get_active_patch() -> MudPatch:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	var ground := find_ground(player)
	if ground.is_empty():
		return
	if is_instance_valid(_active):
		_active.queue_free()
	var patch := MudPatch.new()
	patch.radius = radius
	patch.duration = duration(player)
	patch.drag = drag
	patch.cooling = cooling
	patch.character_speed = character_speed
	player.get_tree().current_scene.add_child(patch)
	patch.global_position = ground.position
	_active = patch

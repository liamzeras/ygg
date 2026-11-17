class_name EarthquakeAbility
extends TerrainAbility
## Terra — Terremoto (design/gdd/mage-earth.md): no chão mirado, ergue uma grade de colunas
## de pedra com alturas sorteadas, algumas estalagmites e pedregulhos soltos. Ao surgir, joga
## para cima e fere quem está na área (menos quem lançou). Some depois de `lifetime` s.
## Área = max_side² x nível / nível máximo (cresce em partes iguais por nível).

@export var max_side := 9.0
## Largura máxima de cada coluna (m).
@export var max_cell := 1.0
@export var min_height := 0.2
@export var max_height := 2.0
@export_range(0.0, 1.0) var stalagmite_chance := 0.15
## Largura da estalagmite em relação à coluna.
@export_range(0.1, 1.0) var stalagmite_width := 0.4
## Um pedregulho a cada tantas colunas (mínimo 1).
@export var cells_per_boulder := 8
@export var boulder_material: PropMaterial
@export var boulder_size := 0.4
@export var rise_time := 0.3
@export var lifetime := 5.0
@export var sink_time := 0.6
## Impulso de dano (N·s) em quem está na área. Escala com mult(atributo).
@export var base_damage_impulse := 250.0
## Empurrão para cima em personagens (N·s) e velocidade para cima em objetos (m/s).
@export var launch_impulse := 420.0
@export var launch_speed := 6.0
## Como as colunas quebram com socos e chutes de pedra.
@export var breaking: StoneBreakRules

var _active: EarthquakeZone


func side_for_level(level: int, max_level: int) -> float:
	return sqrt(max_side * max_side * clampf(float(level) / max_level, 0.0, 1.0))


func get_active_zone() -> EarthquakeZone:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	var ground := find_ground(player)
	if ground.is_empty():
		return
	if is_instance_valid(_active):
		_active.end()
	var zone := EarthquakeZone.new()
	zone.ability = self
	zone.caster = player
	zone.side = side_for_level(player.level, player.rules.max_level)
	zone.power = power(player)
	player.get_parent().add_child(zone)
	zone.start(ground.position, player.get_flat_forward())
	_active = zone

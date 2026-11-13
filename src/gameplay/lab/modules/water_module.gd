class_name LabWaterModule
extends LabModule
## Tecla: cria uma poça no ponto mirado. Quem toca fica Molhado
## (design/sabio/inspiracao/tabela-elementos-materiais.md).

@export var reach := 15.0
@export var radius := 2.5
@export var puddle_duration := 12.0
@export var color := Color(0.25, 0.5, 0.9, 0.55)
## Calor que a poça aguenta antes de evaporar.
@export var evaporation_heat := 200.0
@export_group("Molhado")
@export var wet_duration := 15.0
## Fração do calor que um objeto molhado recebe.
@export_range(0.25, 0.75) var heat_factor := 0.5
## Segundos de Molhado perdidos por ponto de calor recebido.
@export var dry_per_heat := 0.1


func is_usable() -> bool:
	return true


func use(player: Player) -> String:
	var point := controller.aim_ground(player, reach)
	if point == Vector3.INF:
		return "Precisa de chão"
	spawn_puddle(point)
	return ""


func spawn_puddle(point: Vector3) -> LabPuddle:
	var puddle := LabPuddle.new()
	puddle.module = self
	puddle.radius = radius
	puddle.duration = puddle_duration
	puddle.color = color
	controller.arena.add_child(puddle)
	puddle.global_position = point
	track(puddle)
	return puddle


## Deixa o objeto Molhado (ou renova) e apaga o fogo.
func wet(prop: LabProp) -> void:
	prop.extinguish()
	for child in prop.get_children():
		if child is LabWetStatus:
			(child as LabWetStatus).time_left = wet_duration
			return
	var status := LabWetStatus.new()
	status.prop = prop
	status.time_left = wet_duration
	status.heat_factor = heat_factor
	status.dry_per_heat = dry_per_heat
	prop.add_child(status)
	track(status)

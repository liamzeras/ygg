class_name LabOilModule
extends LabModule
## Tecla: cria uma mancha de óleo escorregadia que queima inteira ao pegar fogo.

@export var reach := 15.0
@export var radius := 2.5
@export var duration := 20.0
@export var color := Color(0.1, 0.08, 0.05, 0.75)
@export_range(0.0, 1.0) var surface_friction := 0.05
@export var ignition_heat := 15.0
@export var burn_time := 6.0
## Calor por segundo em quem está dentro da mancha em chamas.
@export var heat_per_second := 90.0


func is_usable() -> bool:
	return true


func use(player: Player) -> String:
	var point := controller.aim_ground(player, reach)
	if point == Vector3.INF:
		return "Precisa de chão"
	spawn_oil(point)
	return ""


func spawn_oil(point: Vector3) -> LabOil:
	var oil := LabOil.new()
	oil.module = self
	oil.radius = radius
	oil.duration = duration
	oil.color = color
	oil.surface_friction = surface_friction
	controller.arena.add_child(oil)
	oil.global_position = point
	track(oil)
	return oil

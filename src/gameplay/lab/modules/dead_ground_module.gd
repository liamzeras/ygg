class_name LabDeadGroundModule
extends LabModule
## Tecla: Terra Morta (ideia 5). Regra única: magia some, objeto continua. Apaga superfícies e
## campos mágicos e desfaz projéteis mágicos que entram. Não bloqueia o lançamento.

@export var reach := 15.0
@export var radius := 4.0
@export var duration := 15.0
@export var color := Color(0.25, 0.1, 0.3, 0.55)


func is_usable() -> bool:
	return true


func use(player: Player) -> String:
	var point := controller.aim_ground(player, reach)
	if point == Vector3.INF:
		return "Precisa de chão"
	spawn_zone(point)
	return ""


func spawn_zone(point: Vector3) -> LabDeadGround:
	var zone := LabDeadGround.new()
	zone.radius = radius
	zone.duration = duration
	zone.color = color
	controller.arena.add_child(zone)
	zone.global_position = point
	track(zone)
	return zone

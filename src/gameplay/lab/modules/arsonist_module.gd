class_name LabArsonistModule
extends LabModule
## Tecla: cria um Incendiário no ponto mirado (ideia 7). Ele acende o barril mais próximo e foge,
## ensinando a mecânica sem tutorial. Não é o sistema final de inimigos.

@export var reach := 15.0
@export var move_speed := 3.5
## Distância (m) em que alcança o barril.
@export var light_range := 1.2
## Calor por segundo aplicado ao barril.
@export var light_heat := 120.0
@export var flee_time := 4.0
## Massa (kg) usada nos empurrões.
@export var body_mass := 70.0
@export var color := Color(0.95, 0.45, 0.1)

var _active: LabArsonist


func is_usable() -> bool:
	return true


func use(player: Player) -> String:
	var point := controller.aim_ground(player, reach)
	if point == Vector3.INF:
		return "Precisa de chão"
	spawn(point)
	return ""


func spawn(point: Vector3) -> LabArsonist:
	if is_instance_valid(_active):
		_active.queue_free()
	_active = LabArsonist.new()
	_active.module = self
	controller.arena.add_child(_active)
	_active.global_position = point + Vector3.UP * 0.05
	track(_active)
	return _active

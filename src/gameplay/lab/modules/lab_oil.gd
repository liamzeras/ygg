class_name LabOil
extends LabSurface
## Óleo: escorrega; ao receber calor, a mancha inteira queima e aquece quem está dentro.

var module: LabOilModule
var burning := false

var _heat := 0.0


func add_heat(amount: float) -> void:
	if burning:
		return
	_heat += amount
	if _heat >= module.ignition_heat:
		_ignite()


func _affect(body: Node3D, delta: float) -> void:
	if burning and body.has_method("add_heat"):
		body.add_heat(module.heat_per_second * delta)


func _ignite() -> void:
	burning = true
	_time_left = module.burn_time
	add_child(Fx.make_fire(radius * 0.6))

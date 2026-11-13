class_name LabProp
extends PhysicsProp
## PhysicsProp que aceita os experimentos do Laboratório do Sábio sem mudar o código original:
## fatores de calor, travas de detonação e etiquetas de estado mostradas na mira.

signal heat_received(amount: float)

var _heat_factors := {}
var _detonation_locks := {}
var _tags := {}


func get_display_name() -> String:
	var base := super.get_display_name()
	return base if _tags.is_empty() else "%s (%s)" % [base, ", ".join(_tags.values())]


func add_heat(amount: float) -> void:
	var controller := get_tree().get_first_node_in_group(&"lab_controller") as LabController
	if controller:
		amount = controller.filter_heat(self, amount)
	for factor: float in _heat_factors.values():
		amount *= factor
	if amount <= 0.0:
		return
	heat_received.emit(amount)
	super.add_heat(amount)


func explode() -> void:
	if _detonation_locks.is_empty():
		super.explode()


## Aplica um estado: fator de calor recebido, trava de detonação e etiqueta na mira.
func set_state(id: StringName, tag: String, heat_factor := 1.0, lock_detonation := false) -> void:
	_tags[id] = tag
	_heat_factors[id] = heat_factor
	if lock_detonation:
		_detonation_locks[id] = true


func clear_state(id: StringName) -> void:
	_tags.erase(id)
	_heat_factors.erase(id)
	_detonation_locks.erase(id)


func has_state(id: StringName) -> bool:
	return _tags.has(id)


func get_visual_material() -> StandardMaterial3D:
	return _visual_material

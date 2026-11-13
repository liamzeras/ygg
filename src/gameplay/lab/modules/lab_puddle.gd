class_name LabPuddle
extends LabSurface
## Poça: molha quem está dentro. O calor a evapora aos poucos.

var module: LabWaterModule

var _heat := 0.0


func _ready() -> void:
	super._ready()
	add_to_group(&"lab_puddles")


func add_heat(amount: float) -> void:
	_heat += amount
	if _heat >= module.evaporation_heat:
		queue_free()


func _affect(body: Node3D, _delta: float) -> void:
	if body is LabProp:
		module.wet(body as LabProp)

class_name LabIce
extends LabSurface
## Gelo: objetos deslizam. O calor derrete a placa.

var module: LabFrostModule

var _heat := 0.0


func add_heat(amount: float) -> void:
	_heat += amount
	if _heat >= module.melt_heat:
		queue_free()

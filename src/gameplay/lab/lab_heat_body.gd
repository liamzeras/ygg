class_name LabHeatBody
extends StaticBody3D
## Corpo invisível que repassa o calor de explosões para uma superfície do laboratório.

var receiver: LabSurface


func add_heat(amount: float) -> void:
	receiver.add_heat(amount)


## Alvo do raio de cobertura das explosões: acima da mancha, para o chão não bloquear.
func get_center() -> Vector3:
	return receiver.global_position + Vector3.UP * LabSurface.DEPTH / 2.0


## A explosão mede até a borda da mancha, não até o centro.
func surface_distance(point: Vector3) -> float:
	return receiver.surface_distance(point)

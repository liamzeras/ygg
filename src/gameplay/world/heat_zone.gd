class_name HeatZone
extends Area3D
## Área que aquece continuamente tudo o que estiver dentro (ex.: braseiro).
## Permite que classes sem magia de fogo também usem o fogo do ambiente.

## Calor por segundo aplicado aos objetos dentro da área.
@export var heat_per_second := 80.0


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("add_heat"):
			body.add_heat(heat_per_second * delta)

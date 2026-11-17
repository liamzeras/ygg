class_name HeatZone
extends Area3D
## Zona de ambiente: calor e ar (design/gdd/physics-magic-system.md, lei do Fogo).
## Com calor, é uma fonte de fogo do ambiente (ex.: braseiro), que qualquer classe pode usar.
## Com `air_factor` 0, abafa: apaga o que queima dentro e impede o calor de entrar (lama, água).
## Uma fonte de calor dentro de uma zona sem ar também se apaga enquanto estiver lá.
## Outras áreas abafam do mesmo jeito se estiverem no grupo "air_zones" e tiverem `air_factor`.

## Calor por segundo aplicado aos objetos dentro da área.
@export var heat_per_second := 80.0
## Ar dentro da área: 1 = normal, 0 = sem ar. Acima de 1 fica reservado para o vento (Ar).
@export var air_factor := 1.0
## Quem conjurou a zona (ex.: o mago do Chão de Lava). Ele não se queima nela e vira o dono do
## calor do que ela acende. Vazio = fonte do ambiente, queima todo mundo.
var heat_owner: Node = null


func _ready() -> void:
	add_to_group(&"air_zones")


func _physics_process(delta: float) -> void:
	var heat := heat_per_second * delta if heat_per_second > 0.0 and air_here() > 0.0 else 0.0
	var owner_node := heat_owner if is_instance_valid(heat_owner) else null
	for body in get_overlapping_bodies():
		if air_factor != 1.0 and body.has_method("apply_air"):
			body.apply_air(air_factor)
		if heat > 0.0 and body.has_method("add_heat") and not PhysicsProp.is_heat_owner(body, owner_node):
			PhysicsProp.give_heat(body, heat, owner_node)


## Ar no lugar onde a zona está: o menor `air_factor` entre as zonas de ar que a cobrem.
func air_here() -> float:
	var air := 1.0
	for area in get_overlapping_areas():
		if area.is_in_group(&"air_zones") and "air_factor" in area:
			air = minf(air, float(area.get("air_factor")))
	return air

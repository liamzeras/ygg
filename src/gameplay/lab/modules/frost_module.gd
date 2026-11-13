class_name LabFrostModule
extends LabModule
## Tecla: rajada de frio no ponto mirado. Retira calor de objetos e transforma poças em gelo.
## Gelo só afeta objetos: o jogador depende de mudança futura em player.gd para escorregar.

@export var reach := 15.0
@export var blast_radius := 3.5
## Calor retirado de cada objeto na rajada.
@export var cooling := 150.0
@export var ice_duration := 20.0
@export_range(0.0, 0.2) var ice_friction := 0.02
@export var melt_heat := 60.0
@export var color := Color(0.75, 0.92, 1.0, 0.7)


func is_usable() -> bool:
	return true


func use(player: Player) -> String:
	var point := controller.aim_ground(player, reach)
	if point == Vector3.INF:
		return "Precisa de chão"
	blast(point)
	return ""


func blast(point: Vector3) -> void:
	var arena := controller.arena
	Fx.burst(arena, point, color, blast_radius)
	for body in arena.get_tree().get_nodes_in_group(&"physics_props"):
		var prop := body as PhysicsProp
		if prop.global_position.distance_to(point) <= blast_radius:
			prop.cool(cooling)
	for node in arena.get_tree().get_nodes_in_group(&"lab_puddles"):
		var puddle := node as LabSurface
		if puddle.surface_distance(point) <= blast_radius:
			_freeze(puddle)


func _freeze(puddle: LabSurface) -> void:
	var ice := LabIce.new()
	ice.module = self
	ice.radius = puddle.radius
	ice.duration = ice_duration
	ice.color = color
	ice.surface_friction = ice_friction
	controller.arena.add_child(ice)
	ice.global_position = puddle.global_position
	track(ice)
	puddle.queue_free()

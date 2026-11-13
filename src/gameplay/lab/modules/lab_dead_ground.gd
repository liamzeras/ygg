class_name LabDeadGround
extends LabSurface
## Terra Morta: tudo que é mágico dentro da área some; objetos físicos não mudam.


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	for node in get_parent().get_children():
		if node == self or node.is_queued_for_deletion():
			continue
		if node is MudPatch or node is SlowField or node is StonePillar or node is LabSurface:
			if contains((node as Node3D).global_position):
				node.queue_free()


func _affect(body: Node3D, _delta: float) -> void:
	if body is MaterializedProjectile:
		Fx.burst(get_parent(), body.global_position, color, 0.5)
		body.queue_free()

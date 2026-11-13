class_name LabMudFireModule
extends LabModule
## Passivo: corrige as lacunas 1 e 2 de design/sabio/inspiracao/tabela-elementos-materiais.md.
## Lama apaga o braseiro enquanto durar, e objetos dentro da lama ignoram calor.

var _patches: Array[MudPatch] = []
var _smothered := {}


func tick(_delta: float) -> void:
	_patches.clear()
	for node in controller.arena.get_children():
		if node is MudPatch and not node.is_queued_for_deletion():
			_patches.append(node)
	for node in controller.arena.get_children():
		if node is HeatZone:
			_set_smothered(node, _in_mud((node as HeatZone).global_position))


func filter_heat(prop: LabProp, amount: float) -> float:
	return 0.0 if _in_mud(prop.global_position, true) else amount


func on_disabled() -> void:
	super.on_disabled()
	_patches.clear()
	for zone: HeatZone in _smothered.keys():
		if is_instance_valid(zone):
			_set_smothered(zone, false)


func _in_mud(point: Vector3, check_height := false) -> bool:
	for patch in _patches:
		var offset := point - patch.global_position
		if Vector2(offset.x, offset.z).length() > patch.radius:
			continue
		if not check_height or offset.y <= MudPatch.DEPTH:
			return true
	return false


func _set_smothered(zone: HeatZone, value: bool) -> void:
	if _smothered.get(zone, false) == value:
		return
	_smothered[zone] = value
	zone.set_physics_process(not value)
	# O fogo visível do braseiro fica no bloco logo abaixo da zona de calor.
	for node in controller.arena.get_children():
		if node is StaticBody3D:
			var offset: Vector3 = (node as StaticBody3D).global_position - zone.global_position
			if Vector2(offset.x, offset.z).length() < 0.1:
				for child in node.get_children():
					if not child is MeshInstance3D and not child is CollisionShape3D:
						child.visible = not value

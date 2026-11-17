class_name GravityZone
extends Node3D
## Zona quadrada fixa no chão usada pelas magias de área da Gravidade
## (design/gdd/mage-gravity.md). A origem fica no centro, rente ao chão. Esta base cuida do
## tamanho, do tempo e de saber quem está dentro; as subclasses aplicam o efeito em
## `_on_enter`, `_on_exit` e `_tick`.

## Altura (m) da zona acima do chão.
const HEIGHT := 4.0

var side := 3.0
var duration := 6.0
var caster: Node3D
var color := Color(0.5, 0.3, 0.9, 0.2)

var _time := 0.0
var _inside: Array = []


func _ready() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(side, 0.04, side)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = CasterLook.tint(color, caster)
	mesh.material = mat
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position.y = 0.03
	add_child(instance)


func time_left() -> float:
	return maxf(duration - _time, 0.0)


func contains(point: Vector3) -> bool:
	var local := to_local(point)
	return absf(local.x) <= side / 2.0 and absf(local.z) <= side / 2.0 and local.y >= -0.5 and local.y <= HEIGHT


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	for node in get_tree().get_nodes_in_group(&"characters"):
		var character := node as Node3D
		if character == null:
			continue
		var inside := contains(character.global_position)
		if inside and not _inside.has(character):
			_inside.append(character)
			_on_enter(character)
		elif not inside and _inside.has(character):
			_inside.erase(character)
			_on_exit(character)
	_tick(delta)


func _exit_tree() -> void:
	for character: Variant in _inside:
		if is_instance_valid(character):
			_on_exit(character)
	_inside.clear()


func _on_enter(_character: Node3D) -> void:
	pass


func _on_exit(_character: Node3D) -> void:
	pass


func _tick(_delta: float) -> void:
	pass

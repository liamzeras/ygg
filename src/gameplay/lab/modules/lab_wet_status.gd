class_name LabWetStatus
extends Node
## Estado Molhado: menos calor recebido, pólvora não acende nem detona, visual escurecido.

const STATE := &"wet"
const TINT := 0.6

var prop: LabProp
var time_left := 15.0
var heat_factor := 0.5
var dry_per_heat := 0.1

var _original_color := Color.WHITE
var _original_roughness := 0.8


func _ready() -> void:
	var explosive := prop.material_data.explosive
	# Pólvora molhada não recebe calor nenhum.
	prop.set_state(STATE, "Molhado", 0.0 if explosive else heat_factor, explosive)
	prop.heat_received.connect(_on_heat)
	var visual := prop.get_visual_material()
	_original_color = visual.albedo_color
	_original_roughness = visual.roughness
	visual.albedo_color = _original_color * TINT
	visual.albedo_color.a = _original_color.a
	visual.roughness = 0.15


func _physics_process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		queue_free()


func _exit_tree() -> void:
	if not is_instance_valid(prop) or prop.is_queued_for_deletion():
		return
	prop.clear_state(STATE)
	var visual := prop.get_visual_material()
	visual.albedo_color = _original_color
	visual.roughness = _original_roughness


func _on_heat(amount: float) -> void:
	time_left -= amount * dry_per_heat

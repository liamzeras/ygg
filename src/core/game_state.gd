extends Node
## Autoload "GameState": classe escolhida e troca de cenas.

const MAIN_MENU := "res://src/ui/main_menu.tscn"
const CLASS_SELECT := "res://src/ui/class_select.tscn"
const ARENA := "res://src/levels/test_arena.tscn"

const CLASSES: Array[PlayerClassData] = [
	preload("res://assets/data/classes/fire.tres"),
	preload("res://assets/data/classes/earth.tres"),
	preload("res://assets/data/classes/gravity.tres"),
]

## Fichas que não aparecem no menu (o bot do F6 usa o Psiônico). `find_class` também as acha.
const HIDDEN_CLASSES: Array[PlayerClassData] = [
	preload("res://assets/data/classes/psionic.tres"),
]

var selected_class: PlayerClassData


func _ready() -> void:
	# Permite escolher a classe pela linha de comando (útil para testes):
	# Godot --path . res://src/levels/test_arena.tscn -- --class=fire
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--class="):
			selected_class = find_class(arg.trim_prefix("--class="))


func find_class(id: String) -> PlayerClassData:
	for data in CLASSES + HIDDEN_CLASSES:
		if String(data.id) == id:
			return data
	return null


func get_selected_class() -> PlayerClassData:
	return selected_class if selected_class else CLASSES[0]


func start_new_game(data: PlayerClassData) -> void:
	selected_class = data
	_change_scene(ARENA)


func open_class_select() -> void:
	_change_scene(CLASS_SELECT)


func go_to_main_menu() -> void:
	_change_scene(MAIN_MENU)


func reload_current() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _change_scene(path: String) -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(path)

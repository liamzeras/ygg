class_name InputBindings
extends RefCounted
## Registra as ações de controle do jogo no InputMap.
## Ficam em código (e não no project.godot) para facilitar a futura tela de remapeamento.

const KEYS := {
	"move_forward": [KEY_W, KEY_UP],
	"move_back": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE],
	"sprint": [KEY_SHIFT],
	"mobility": [KEY_Q],
	"special": [KEY_F],
	"dash": [KEY_CTRL],
	"spawn_targets": [KEY_F7],
	"debug_editor": [KEY_F2],
	"pause": [KEY_ESCAPE],
	"toggle_help": [KEY_F1],
	"reload_arena": [KEY_F5],
}

const MOUSE := {
	"primary": [MOUSE_BUTTON_LEFT],
	"grab": [MOUSE_BUTTON_RIGHT],
}

## Nomes amigáveis exibidos no HUD e na ajuda de controles.
const LABELS := {
	"move_forward": "W A S D",
	"jump": "Espaço",
	"sprint": "Shift",
	"primary": "Botão esq.",
	"grab": "Botão dir.",
	"mobility": "Q",
	"special": "F",
	"dash": "Ctrl",
	"spawn_targets": "F7",
	"air_jump": "Espaço 2x",
	"float": "Segurar Espaço",
	"debug_editor": "F2",
	"pause": "Esc",
	"toggle_help": "F1",
	"reload_arena": "F5",
}


static func register() -> void:
	for action: String in KEYS:
		_ensure_action(action)
		for key: Key in KEYS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
	for action: String in MOUSE:
		_ensure_action(action)
		for button: MouseButton in MOUSE[action]:
			var ev := InputEventMouseButton.new()
			ev.button_index = button
			InputMap.action_add_event(action, ev)


static func label(action: String) -> String:
	return LABELS.get(action, action)


static func _ensure_action(action: String) -> void:
	if InputMap.has_action(action):
		InputMap.action_erase_events(action)
	else:
		InputMap.add_action(action)

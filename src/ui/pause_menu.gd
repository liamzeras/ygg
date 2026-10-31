extends CanvasLayer
## Menu de pausa (Esc). Roda mesmo com o jogo pausado (process_mode = Always).

@onready var _root: Control = $Root
@onready var _resume: Button = $Root/Center/Panel/Box/ResumeButton
@onready var _reload: Button = $Root/Center/Panel/Box/ReloadButton
@onready var _settings_button: Button = $Root/Center/Panel/Box/SettingsButton
@onready var _menu: Button = $Root/Center/Panel/Box/MenuButton
@onready var _settings_menu: Control = $Root/SettingsMenu


func _ready() -> void:
	_root.hide()
	_resume.pressed.connect(set_paused.bind(false))
	_reload.pressed.connect(GameState.reload_current)
	_settings_button.pressed.connect(_settings_menu.open)
	_menu.pressed.connect(GameState.go_to_main_menu)
	_settings_menu.closed.connect(_settings_button.grab_focus)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not _settings_menu.visible:
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_root.visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	if paused:
		_resume.grab_focus()

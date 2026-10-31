extends Control
## Menu principal: Novo Jogo, Configurações e Sair.

@onready var _new_game: Button = $Center/Box/NewGameButton
@onready var _settings_button: Button = $Center/Box/SettingsButton
@onready var _quit: Button = $Center/Box/QuitButton
@onready var _version: Label = $Version
@onready var _settings_menu: Control = $SettingsMenu


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_version.text = "Ygg v%s  ·  protótipo" % ProjectSettings.get_setting("application/config/version", "0.0.0")
	_new_game.pressed.connect(GameState.open_class_select)
	_settings_button.pressed.connect(_settings_menu.open)
	_quit.pressed.connect(get_tree().quit)
	_settings_menu.closed.connect(_settings_button.grab_focus)
	_new_game.grab_focus()

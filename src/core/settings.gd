extends Node
## Autoload "Settings": guarda, aplica e salva as preferências do jogador
## em user://settings.cfg. Outros sistemas escutam o sinal `changed`.

signal changed

const PATH := "user://settings.cfg"
const SECTION := "settings"

const DEFAULTS := {
	"mouse_sensitivity": 0.2,
	"invert_y": false,
	"fov": 80.0,
	"camera_shake": true,
	"master_volume": 0.8,
	"fullscreen": false,
	"vsync": true,
	"show_fps": false,
}

var _values: Dictionary = DEFAULTS.duplicate()


func _ready() -> void:
	InputBindings.register()
	load_settings()
	apply()


func get_value(key: String) -> Variant:
	return _values.get(key, DEFAULTS.get(key))


func set_value(key: String, value: Variant) -> void:
	if _values.get(key) == value:
		return
	_values[key] = value
	apply()


func reset_to_defaults() -> void:
	_values = DEFAULTS.duplicate()
	apply()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for key: String in DEFAULTS:
		_values[key] = cfg.get_value(SECTION, key, DEFAULTS[key])


func save_settings() -> void:
	var cfg := ConfigFile.new()
	for key: String in _values:
		cfg.set_value(SECTION, key, _values[key])
	cfg.save(PATH)


func apply() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if get_value("fullscreen") else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if get_value("vsync") else DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(float(get_value("master_volume")), 0.0001)))
	changed.emit()

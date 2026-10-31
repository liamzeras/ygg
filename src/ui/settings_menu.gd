extends Control
## Tela de configurações. As linhas são geradas a partir de OPTIONS:
## para adicionar uma opção, inclua a chave em Settings.DEFAULTS e uma entrada aqui.

signal closed

const OPTIONS := [
	{"key": "mouse_sensitivity", "label": "Sensibilidade do mouse", "type": "slider", "min": 0.05, "max": 1.0, "step": 0.01, "format": "%.2f"},
	{"key": "invert_y", "label": "Inverter eixo vertical", "type": "toggle"},
	{"key": "fov", "label": "Campo de visão", "type": "slider", "min": 60.0, "max": 110.0, "step": 1.0, "format": "%d°"},
	{"key": "camera_shake", "label": "Tremor de câmera", "type": "toggle"},
	{"key": "master_volume", "label": "Volume geral", "type": "slider", "min": 0.0, "max": 1.0, "step": 0.05, "format": "percent"},
	{"key": "fullscreen", "label": "Tela cheia", "type": "toggle"},
	{"key": "vsync", "label": "V-Sync", "type": "toggle"},
	{"key": "show_fps", "label": "Mostrar FPS", "type": "toggle"},
]

@onready var _rows: VBoxContainer = $Center/Panel/Box/Rows
@onready var _back: Button = $Center/Panel/Box/Buttons/BackButton
@onready var _reset: Button = $Center/Panel/Box/Buttons/ResetButton


func _ready() -> void:
	_back.pressed.connect(close)
	_reset.pressed.connect(_on_reset)
	_build_rows()


func open() -> void:
	_build_rows()
	show()
	_back.grab_focus()


func close() -> void:
	Settings.save_settings()
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_reset() -> void:
	Settings.reset_to_defaults()
	_build_rows()


func _build_rows() -> void:
	for child in _rows.get_children():
		child.queue_free()
	for option: Dictionary in OPTIONS:
		_rows.add_child(_make_row(option))


func _make_row(option: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var label := Label.new()
	label.text = option["label"]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var key: String = option["key"]
	if option["type"] == "toggle":
		var toggle := CheckButton.new()
		toggle.button_pressed = Settings.get_value(key)
		toggle.toggled.connect(func(on: bool) -> void: Settings.set_value(key, on))
		row.add_child(toggle)
	else:
		var slider := HSlider.new()
		slider.min_value = option["min"]
		slider.max_value = option["max"]
		slider.step = option["step"]
		slider.value = Settings.get_value(key)
		slider.custom_minimum_size = Vector2(260, 24)
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var value_label := Label.new()
		value_label.custom_minimum_size = Vector2(64, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.text = _format(option, slider.value)
		slider.value_changed.connect(func(value: float) -> void:
			Settings.set_value(key, value)
			value_label.text = _format(option, value))
		row.add_child(slider)
		row.add_child(value_label)
	return row


func _format(option: Dictionary, value: float) -> String:
	var fmt: String = option.get("format", "%.2f")
	if fmt == "percent":
		return "%d%%" % roundi(value * 100.0)
	if fmt.contains("%d"):
		return fmt % roundi(value)
	return fmt % value

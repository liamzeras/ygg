extends CanvasLayer
## HUD em código: mira, barra de recurso, habilidades com recarga, dica de
## interação, avisos rápidos, ajuda de controles (F1) e FPS.
## Só escuta sinais do Player; nunca altera o gameplay.

const TOAST_TIME := 1.6
const TEXT := Color(0.9, 0.91, 0.94)
const MUTED := Color(0.6, 0.63, 0.7)
const READY := Color(0.55, 0.9, 0.55)

var _player: Player
var _root: Control
var _crosshair: ColorRect
var _hint: Label
var _toast: Label
var _toast_time := 0.0
var _class_label: Label
var _attr_label: Label
var _bar: ProgressBar
var _bar_label: Label
var _slot_status := {}
var _slot_box: VBoxContainer
var _help: PanelContainer
var _fps: Label
var _guard_label: Label


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = load("res://assets/ui/ygg_theme.tres")
	add_child(_root)
	_build_center()
	_build_status()
	_build_help()
	_fps = _label("", 16, MUTED)
	_fps.position = Vector2(16, 12)
	_root.add_child(_fps)
	_ignore_mouse(_root)


func bind_player(player: Player) -> void:
	_player = player
	var data := player.class_data
	_class_label.text = data.display_name
	_class_label.add_theme_color_override("font_color", data.color)
	var a := data.attributes
	_attr_label.text = "FOR %d  AGI %d  VIT %d  DES %d  INT %d  SOR %d" % [a.strength, a.agility, a.vitality, a.dexterity, a.intelligence, a.luck]
	var fill := StyleBoxFlat.new()
	fill.bg_color = data.resource_color
	fill.set_corner_radius_all(3)
	_bar.add_theme_stylebox_override("fill", fill)

	for slot in Player.SLOTS:
		var ability := player.get_ability(slot)
		if ability:
			_add_slot(slot, ability.display_name)
	player.resource_changed.connect(_on_resource_changed)
	player.hint_changed.connect(_on_hint_changed)
	player.action_failed.connect(_show_toast)
	_on_resource_changed(player.resource, player.stats.max_resource)
	_help.get_child(0).text = _help_text()


func _process(delta: float) -> void:
	_fps.visible = Settings.get_value("show_fps")
	if _fps.visible:
		_fps.text = "%d FPS" % Engine.get_frames_per_second()
	if _toast_time > 0.0:
		_toast_time -= delta
		_toast.modulate.a = clampf(_toast_time / 0.4, 0.0, 1.0)
	if _player == null:
		return
	for slot: StringName in _slot_status:
		var remaining := _player.get_cooldown(slot)
		var status: Label = _slot_status[slot]
		status.text = "%.1fs" % remaining if remaining > 0.0 else "Pronto"
		status.add_theme_color_override("font_color", MUTED if remaining > 0.0 else READY)
	_guard_label.visible = _player.is_guarding()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_help"):
		_help.visible = not _help.visible


func _on_resource_changed(current: float, maximum: float) -> void:
	_bar.max_value = maximum
	_bar.value = current
	_bar_label.text = "%s  %d / %d" % [_player.class_data.pool_name, roundi(current), roundi(maximum)]


func _on_hint_changed(text: String, can_interact: bool) -> void:
	_hint.text = text
	_crosshair.color = Color(1, 0.8, 0.35) if can_interact else Color(1, 1, 1, 0.85)
	var size := 10.0 if can_interact else 6.0
	_crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_crosshair.custom_minimum_size = Vector2(size, size)
	_crosshair.offset_left = -size / 2.0
	_crosshair.offset_top = -size / 2.0
	_crosshair.offset_right = size / 2.0
	_crosshair.offset_bottom = size / 2.0


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast_time = TOAST_TIME
	_toast.modulate.a = 1.0


func _build_center() -> void:
	_crosshair = ColorRect.new()
	_crosshair.color = Color(1, 1, 1, 0.85)
	_crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_crosshair.offset_left = -3
	_crosshair.offset_top = -3
	_crosshair.offset_right = 3
	_crosshair.offset_bottom = 3
	_root.add_child(_crosshair)

	_hint = _centered_label(28.0, 20, TEXT)
	_toast = _centered_label(64.0, 20, Color(1, 0.55, 0.45))
	_guard_label = _centered_label(-90.0, 22, Color(0.7, 0.85, 1.0))
	_guard_label.text = "EM GUARDA"
	_guard_label.visible = false


func _build_status() -> void:
	var left := VBoxContainer.new()
	left.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	left.offset_left = 24
	left.offset_top = -130
	left.offset_right = 460
	left.offset_bottom = -24
	left.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_root.add_child(left)
	_class_label = _label("", 28, TEXT)
	left.add_child(_class_label)
	_attr_label = _label("", 14, MUTED)
	left.add_child(_attr_label)
	_bar_label = _label("", 16, TEXT)
	left.add_child(_bar_label)
	_bar = ProgressBar.new()
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(300, 14)
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0, 0, 0, 0.5)
	background.set_corner_radius_all(3)
	_bar.add_theme_stylebox_override("background", background)
	left.add_child(_bar)

	_slot_box = VBoxContainer.new()
	_slot_box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_slot_box.offset_left = -380
	_slot_box.offset_top = -150
	_slot_box.offset_right = -24
	_slot_box.offset_bottom = -24
	_slot_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_slot_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_slot_box.alignment = BoxContainer.ALIGNMENT_END
	_root.add_child(_slot_box)


func _add_slot(slot: StringName, ability_name: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var key := _label("[%s]" % InputBindings.label(String(slot)), 16, MUTED)
	key.custom_minimum_size = Vector2(110, 0)
	key.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(key)
	var name_label := _label(ability_name, 18, TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var status := _label("Pronto", 16, READY)
	status.custom_minimum_size = Vector2(60, 0)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(status)
	_slot_box.add_child(row)
	_slot_status[slot] = status
	_ignore_mouse(row)


func _build_help() -> void:
	_help = PanelContainer.new()
	_help.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_help.offset_left = -360
	_help.offset_top = 16
	_help.offset_right = -16
	_help.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_help.modulate.a = 0.9
	_root.add_child(_help)
	_help.add_child(_label("", 16, TEXT))


func _help_text() -> String:
	var lines := ["CONTROLES  (F1 esconde)"]
	for pair in [["move_forward", "Andar"], ["jump", "Pular"], ["sprint", "Correr"], ["grab", "Pegar / soltar"],
			["primary", "Habilidade principal / arremessar"], ["mobility", "Mobilidade"], ["special", "Especial"],
			["reload_arena", "Recarregar arena"], ["pause", "Pausa"]]:
		lines.append("%s — %s" % [InputBindings.label(pair[0]), pair[1]])
	return "\n".join(lines)


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 4 if size >= 18 else 2)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	return label


func _centered_label(y_offset: float, size: int, color: Color) -> Label:
	var label := _label("", size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.offset_left = -400
	label.offset_right = 400
	label.offset_top = y_offset
	label.offset_bottom = y_offset + 30
	_root.add_child(label)
	return label


func _ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)

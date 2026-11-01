extends CanvasLayer
## HUD em código: mira, barra de recurso, habilidades com recarga, dica de
## interação, avisos rápidos, ajuda de controles (F1) e FPS.
## Só escuta sinais do Player; nunca altera o gameplay.

const TOAST_TIME := 1.6
const TEXT := Color(0.9, 0.91, 0.94)
const MUTED := Color(0.6, 0.63, 0.7)
const READY := Color(0.55, 0.9, 0.55)
const MANA_COLOR := Color(0.4, 0.55, 1.0)
## Sem pulo duplo, a tela escurece abaixo desta fração do Vigor.
const EXHAUSTED_FRACTION := 0.2
const VIGNETTE_SHADER := """
shader_type canvas_item;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec2 p = (SCREEN_UV - 0.5) * vec2(1.0, 0.8);
	float edge = smoothstep(0.22, 0.68, length(p));
	COLOR = vec4(0.03, 0.02, 0.06, edge * intensity * 0.7);
}
"""

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
var _float_label: Label
var _charge_bar: ProgressBar
var _vignette: ColorRect
var _exhaustion := 0.0
var _exhaustion_pulse := 0.0
var _breath := 0.0


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = load("res://assets/ui/ygg_theme.tres")
	add_child(_root)
	_vignette = ColorRect.new()
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shader := Shader.new()
	shader.code = VIGNETTE_SHADER
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	_vignette.material = shader_material
	_root.add_child(_vignette)
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
	_attr_label.text = "Nv %d  ·  FOR %d  AGI %d  VIT %d  DES %d  INT %d  SOR %d" % [_player.level, a.strength, a.agility, a.vitality, a.dexterity, a.intelligence, a.luck]
	var fill := StyleBoxFlat.new()
	fill.bg_color = MANA_COLOR
	fill.set_corner_radius_all(3)
	_bar.add_theme_stylebox_override("fill", fill)

	for slot in Player.SLOTS + [Player.SLOT_AIR_JUMP, Player.SLOT_FLOAT]:
		var ability := player.get_ability(slot)
		if ability:
			_add_slot(slot, ability.display_name)
	player.pool_changed.connect(_on_pool_changed)
	player.stats_changed.connect(_on_stats_changed)
	player.hint_changed.connect(_on_hint_changed)
	player.action_failed.connect(_on_action_failed)
	_on_pool_changed(Player.Pool.MANA, player.get_pool(Player.Pool.MANA), player.get_pool_max(Player.Pool.MANA))
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
		var status: Label = _slot_status[slot]
		var ok := true
		if slot == Player.SLOT_AIR_JUMP:
			var cost := _player.get_ability(slot).cost
			ok = _player.is_air_jump_available() and _player.get_pool(Player.Pool.STAMINA) >= cost
			status.text = "Pronto" if ok else ("Usado" if not _player.is_air_jump_available() else "Sem Vigor")
		elif slot == Player.SLOT_FLOAT:
			ok = _player.get_pool(Player.Pool.MANA) >= _player.get_ability(slot).cost
			status.text = "Ativo" if _player.is_floating() else ("Pronto" if ok else "Sem Mana")
		elif slot == Player.SLOT_PRIMARY and _player.is_charging():
			status.text = "%d%%" % roundi(_player.get_charge() * 100.0)
		else:
			var remaining := _player.get_cooldown(slot)
			ok = remaining <= 0.0
			status.text = "Pronto" if ok else "%.1fs" % remaining
		status.add_theme_color_override("font_color", READY if ok else MUTED)
	_guard_label.visible = _player.is_guarding()
	_float_label.visible = _player.is_floating()
	_update_charge_bar()
	_update_exhaustion(delta)


## Barra fina sob a mira enquanto carrega. Fica laranja quando a mira começa a tremer.
func _update_charge_bar() -> void:
	_charge_bar.visible = _player.is_charging()
	if not _charge_bar.visible:
		return
	_charge_bar.value = _player.get_charge()
	var fill := _charge_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if _player.get_charge_tremor() > 0.0:
		fill.bg_color = Color(1.0, 0.6, 0.3)
	elif _player.get_charge() >= 1.0:
		fill.bg_color = Color(0.85, 1.0, 1.0)
	else:
		fill.bg_color = _player.class_data.color


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_help"):
		_help.visible = not _help.visible


func _on_pool_changed(pool: Player.Pool, current: float, maximum: float) -> void:
	if pool != Player.Pool.MANA:
		return
	_bar.max_value = maximum
	_bar.value = current
	_bar_label.text = "Mana  %d / %d" % [roundi(current), roundi(maximum)]


func _on_stats_changed() -> void:
	var a := _player.class_data.attributes
	_attr_label.text = "Nv %d  ·  FOR %d  AGI %d  VIT %d  DES %d  INT %d  SOR %d" % [_player.level, a.strength, a.agility, a.vitality, a.dexterity, a.intelligence, a.luck]


func _on_action_failed(reason: String) -> void:
	_show_toast(reason)
	if reason.begins_with(Player.POOL_NAMES[Player.Pool.STAMINA]):
		_exhaustion_pulse = 1.0


## Vigor não tem barra: quando falta fôlego para correr/pular, as bordas da tela
## escurecem de leve e "respiram". Some assim que o Vigor volta.
func _update_exhaustion(delta: float) -> void:
	var stamina := _player.get_pool(Player.Pool.STAMINA)
	var jump := _player.get_ability(Player.SLOT_AIR_JUMP)
	var threshold := jump.cost if jump else _player.get_pool_max(Player.Pool.STAMINA) * EXHAUSTED_FRACTION
	var target := 1.0 if stamina < threshold else 0.0
	_exhaustion = move_toward(_exhaustion, target, delta * 2.0)
	_exhaustion_pulse = maxf(_exhaustion_pulse - delta * 2.5, 0.0)
	_breath += delta * 2.2
	var intensity := _exhaustion * (0.75 + 0.25 * sin(_breath)) + _exhaustion_pulse * 0.6
	(_vignette.material as ShaderMaterial).set_shader_parameter("intensity", clampf(intensity, 0.0, 1.0))


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
	_float_label = _centered_label(-90.0, 20, Color(0.6, 0.92, 1.0))
	_float_label.text = "flutuando"
	_float_label.visible = false

	_charge_bar = ProgressBar.new()
	_charge_bar.show_percentage = false
	_charge_bar.max_value = 1.0
	_charge_bar.step = 0.0
	_charge_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_charge_bar.offset_left = -40
	_charge_bar.offset_right = 40
	_charge_bar.offset_top = 14
	_charge_bar.offset_bottom = 19
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0, 0, 0, 0.5)
	_charge_bar.add_theme_stylebox_override("background", background)
	_charge_bar.add_theme_stylebox_override("fill", StyleBoxFlat.new())
	_charge_bar.visible = false
	_root.add_child(_charge_bar)


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
	var pairs := [["move_forward", "Andar"], ["jump", "Pular"], ["air_jump", "Pulo duplo (gasta Vigor)"]]
	if _player and _player.get_ability(Player.SLOT_FLOAT):
		pairs.append(["float", "Flutuar ao cair (gasta Mana)"])
	var primary := "Habilidade principal / arremessar"
	if _player and _player.get_ability(Player.SLOT_PRIMARY) and _player.get_ability(Player.SLOT_PRIMARY).is_chargeable():
		primary = "Segurar carrega, soltar dispara"
	for pair in pairs + [["sprint", "Correr"], ["dash", "Dash (com direção; padrão: frente)"], ["grab", "Pegar / soltar"],
			["primary", primary], ["mobility", "Mobilidade"], ["special", "Especial"],
			["reload_arena", "Recarregar arena"], ["debug_editor", "Editor de testes"], ["spawn_targets", "Alvos voadores"], ["pause", "Pausa"]]:
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

extends CanvasLayer
## Editor de testes in-game (F2). Muda atributos em tempo real para testar o que
## o personagem ainda não alcança, mostra os valores calculados e oferece trapaças
## de teste. Nada aqui é salvo: recarregar a arena volta tudo ao normal.
## Só chama a API pública do Player/boneco; não guarda estado de jogo.

const PANEL_WIDTH := 540.0
const TEXT := Color(0.9, 0.91, 0.94)
const MUTED := Color(0.6, 0.63, 0.7)
const ACCENT := Color(0.95, 0.8, 0.45)

var _player: Player
var _dummy: TrainingDummy
var _panel: PanelContainer
var _sliders := {}
var _value_labels := {}
var _derived: Label
var _infinite: CheckButton
var _no_cooldown: CheckButton
var _level_slider: HSlider
var _level_value: Label
var _points: Label


func _ready() -> void:
	layer = 5
	_panel = PanelContainer.new()
	_panel.theme = load("res://assets/ui/ygg_theme.tres")
	_panel.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	_panel.offset_left = 16
	_panel.offset_top = 16
	_panel.offset_right = 16 + PANEL_WIDTH
	_panel.offset_bottom = -16
	_panel.visible = false
	add_child(_panel)


func bind(player: Player, dummy: TrainingDummy) -> void:
	_player = player
	_dummy = dummy
	_build()
	player.stats_changed.connect(_refresh)
	_refresh()


func is_open() -> bool:
	return _panel.visible


func set_open(open: bool) -> void:
	_panel.visible = open
	if _player:
		_player.input_enabled = not open
	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_editor") and _player:
		set_open(not is_open())
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	# Ao voltar da pausa com o editor aberto, o mouse continua livre.
	if is_open() and not get_tree().paused and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _build() -> void:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	scroll.add_child(box)

	box.add_child(_text("EDITOR DE TESTES", 24, ACCENT))
	box.add_child(_text("F2 fecha · nada é salvo · F5 volta ao normal", 14, MUTED))

	box.add_child(_section("Atributos  (1 a 150 · humano comum = 1,0x)"))
	for kind: Attributes.Kind in Attributes.Kind.values():
		box.add_child(_attribute_row(kind))
	var presets := HBoxContainer.new()
	presets.add_theme_constant_override("separation", 8)
	presets.add_child(_button("Humano", _apply_human))
	presets.add_child(_button("Classe", _player.reset_attributes))
	presets.add_child(_button("Teto (150)", _apply_cap))
	box.add_child(presets)

	box.add_child(_section("Nível  (o slider acima é livre; aqui valem as regras)"))
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 8)
	level_row.add_child(_fixed_label("Nível", 110))
	_level_slider = HSlider.new()
	_level_slider.min_value = 1
	_level_slider.max_value = _player.rules.max_level
	_level_slider.step = 1
	_level_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_level_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_level_slider.value_changed.connect(func(value: float) -> void: _player.set_level(roundi(value)))
	level_row.add_child(_level_slider)
	_level_value = _fixed_label("", 100)
	_level_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_row.add_child(_level_value)
	box.add_child(level_row)
	_points = _text("", 16, TEXT)
	box.add_child(_points)
	var level_presets := HBoxContainer.new()
	level_presets.add_theme_constant_override("separation", 8)
	level_presets.add_child(_button("Nível 1 (tudo em 1)", _apply_level_one))
	level_presets.add_child(_button("Nível 99 (referência)", _apply_level_max))
	box.add_child(level_presets)

	box.add_child(_section("Valores calculados"))
	_derived = _text("", 16, TEXT)
	box.add_child(_derived)

	box.add_child(_section("Trapaças de teste"))
	_infinite = _check("Vigor e Mana infinitos", func(on: bool) -> void: _player.debug_infinite_resources = on)
	box.add_child(_infinite)
	_no_cooldown = _check("Sem recarga", func(on: bool) -> void: _player.debug_no_cooldowns = on)
	box.add_child(_no_cooldown)
	var time_row := HBoxContainer.new()
	time_row.add_child(_fixed_label("Velocidade do tempo", 190))
	var time_value := _fixed_label("100%", 60)
	var time_slider := HSlider.new()
	time_slider.min_value = 0.1
	time_slider.max_value = 1.0
	time_slider.step = 0.05
	time_slider.value = Engine.time_scale
	time_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	time_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	time_slider.value_changed.connect(func(value: float) -> void:
		Engine.time_scale = value
		time_value.text = "%d%%" % roundi(value * 100.0))
	time_row.add_child(time_slider)
	time_row.add_child(time_value)
	box.add_child(time_row)

	box.add_child(_section("Arena"))
	var arena_row := HBoxContainer.new()
	arena_row.add_theme_constant_override("separation", 8)
	arena_row.add_child(_button("Zerar boneco", _dummy.reset))
	arena_row.add_child(_button("Recarregar (F5)", GameState.reload_current))
	box.add_child(arena_row)


func _attribute_row(kind: Attributes.Kind) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_fixed_label(Attributes.NAMES[kind], 110))
	var slider := HSlider.new()
	slider.min_value = 1
	slider.max_value = _player.rules.cap
	slider.step = 1
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value = _player.class_data.attributes.get_value(kind)
	slider.value_changed.connect(func(value: float) -> void: _player.set_attribute(kind, value))
	row.add_child(slider)
	var value_label := _fixed_label("", 100)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)
	_sliders[kind] = slider
	_value_labels[kind] = value_label
	return row


func _refresh() -> void:
	if _derived == null:
		return
	var attrs := _player.class_data.attributes
	for kind: Attributes.Kind in _sliders:
		var value := attrs.get_value(kind)
		(_sliders[kind] as HSlider).set_value_no_signal(value)
		(_value_labels[kind] as Label).text = "%d  (%sx)" % [value, _decimal(_player.stats.mult(kind), 2)]
	var rules := _player.rules
	_level_slider.set_value_no_signal(_player.level)
	_level_value.text = "%d / %d" % [_player.level, rules.max_level]
	var free := _player.get_free_points()
	var status := "%d livres" % free if free >= 0 else "%d acima do nível (teste livre)" % -free
	_points.text = "Pontos: %d de %d  ·  %s  ·  próximo nível: +%d" % [
		rules.spent_points(attrs), rules.points_at_level(_player.level), status, rules.points_gained_at(_player.level + 1)]
	var s := _player.stats
	_derived.text = "\n".join([
		"Carga nas mãos: %s kg" % _decimal(s.carry_mass, 0),
		"Arremesso: %s m/s" % _decimal(s.throw_speed, 1),
		"Andar / correr: %s / %s m/s" % [_decimal(s.walk_speed, 1), _decimal(s.sprint_speed, 1)],
		"Pulo: %s m" % _decimal(s.jump_height, 2),
		"Velocidade de ataque: %sx" % _decimal(s.attack_speed, 2),
		"Vigor: %s  (+%s/s)" % [_decimal(s.max_stamina, 0), _decimal(s.stamina_regen, 1)],
		"Mana: %s  (+%s/s)" % [_decimal(s.max_mana, 0), _decimal(s.mana_regen, 1)],
	])


func _apply_human() -> void:
	for kind: Attributes.Kind in Attributes.Kind.values():
		_player.set_attribute(kind, _player.rules.human.get_value(kind))


func _apply_cap() -> void:
	for kind: Attributes.Kind in Attributes.Kind.values():
		_player.set_attribute(kind, _player.rules.cap)


func _apply_level_one() -> void:
	_player.set_level(1)
	for kind: Attributes.Kind in Attributes.Kind.values():
		_player.set_attribute(kind, _player.rules.start_value)


## Nível máximo com a build de referência: os valores vão para os atributos mais altos da classe.
func _apply_level_max() -> void:
	var rules := _player.rules
	var attrs := _player.class_data.attributes
	var kinds: Array = Attributes.Kind.values()
	kinds.sort_custom(func(a: int, b: int) -> bool: return attrs.get_value(a) > attrs.get_value(b))
	_player.set_level(rules.max_level)
	for i in kinds.size():
		var value: float = rules.reference_build[i] if i < rules.reference_build.size() else rules.start_value
		_player.set_attribute(kinds[i], value)


func _decimal(value: float, places: int) -> String:
	return String.num(value, places).replace(".", ",")


func _section(title: String) -> Control:
	var box := VBoxContainer.new()
	box.add_child(HSeparator.new())
	box.add_child(_text(title, 17, ACCENT))
	return box


func _text(content: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = content
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _fixed_label(content: String, width: float) -> Label:
	var label := _text(content, 16, TEXT)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.custom_minimum_size = Vector2(width, 0)
	return label


func _button(content: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = content
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(action)
	return button


func _check(content: String, action: Callable) -> CheckButton:
	var check := CheckButton.new()
	check.text = content
	check.add_theme_font_size_override("font_size", 16)
	check.toggled.connect(action)
	return check

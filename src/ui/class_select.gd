extends Control
## Escolha de classe. Os cartões são gerados a partir de GameState.CLASSES,
## então uma classe nova aparece aqui automaticamente.

const CARD_SIZE := Vector2(420, 560)

@onready var _cards: HBoxContainer = $Center/Box/Cards
@onready var _back: Button = $Center/Box/BackButton


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_back.pressed.connect(GameState.go_to_main_menu)
	var first_button: Button
	for data in GameState.CLASSES:
		var button := _add_card(data)
		if first_button == null:
			first_button = button
	if first_button:
		first_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameState.go_to_main_menu()


func _add_card(data: PlayerClassData) -> Button:
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_SIZE
	_cards.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)

	var title := Label.new()
	title.text = data.display_name
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", data.color)
	box.add_child(title)
	box.add_child(_text(data.role, 18, Color(0.65, 0.68, 0.75)))
	box.add_child(_text(data.description, 17))
	box.add_child(HSeparator.new())

	box.add_child(_text("Atributos", 18, data.color))
	box.add_child(_text(_attributes_line(data.attributes), 16))
	box.add_child(_text("Habilidades", 18, data.color))
	for entry in [["Botão esq.", data.primary_ability], ["Q", data.mobility_ability], ["F", data.special_ability]]:
		var ability: Ability = entry[1]
		if ability:
			box.add_child(_text("[%s] %s — %s" % [entry[0], ability.display_name, ability.description], 16))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	var button := Button.new()
	button.text = "Jogar de %s" % data.display_name
	button.custom_minimum_size = Vector2(0, 52)
	button.pressed.connect(GameState.start_new_game.bind(data))
	box.add_child(button)
	return button


func _attributes_line(attrs: Attributes) -> String:
	return "FOR %d · AGI %d · VIT %d · DES %d · INT %d · SOR %d" % [
		attrs.strength, attrs.agility, attrs.vitality, attrs.dexterity, attrs.intelligence, attrs.luck]


func _text(content: String, size: int, color := Color(0.85, 0.86, 0.9)) -> Label:
	var label := Label.new()
	label.text = content
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(CARD_SIZE.x - 60, 0)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

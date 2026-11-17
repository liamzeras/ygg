class_name CasterLook
## Quem conjurou uma magia (decisões do Liam, 2026-11-17; design/gdd/physics-magic-system.md):
## - Magos (jogador e bots com ficha de classe) só mudam de peso pelas próprias habilidades:
##   áreas de gravidade de magias mexem em objetos e monstros, nunca no corpo de um mago.
## - Magia de um rival da mesma classe do jogador aparece levemente mais escura, para o jogador
##   distinguir o próprio fogo do fogo de outro mago de fogo.

## Quanto escurece a magia do rival da mesma classe (apresentação, não regra de jogo).
const RIVAL_DARKEN := 0.3


## true se `node` é um mago (tem ficha de classe): o jogador ou um bot de classe.
static func is_mage(node: Object) -> bool:
	return node != null and is_instance_valid(node) and "class_data" in node and node.get("class_data") != null


## true se `caster` é outro mago da mesma classe do jogador.
static func is_rival_same_class(caster: Object) -> bool:
	if not is_mage(caster) or caster is Player:
		return false
	var mine := GameState.selected_class
	var theirs := caster.get("class_data") as PlayerClassData
	return mine != null and theirs != null and theirs.id == mine.id


## Cor da magia como o jogador deve vê-la: mais escura se vier de um rival da mesma classe.
static func tint(color: Color, caster: Object) -> Color:
	if not is_rival_same_class(caster):
		return color
	var darker := color.darkened(RIVAL_DARKEN)
	darker.a = color.a
	return darker

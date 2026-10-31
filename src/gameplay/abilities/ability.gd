class_name Ability
extends Resource
## Base de todas as habilidades. Cada subclasse implementa `activate`.
## O jogador controla custo e recarga; a habilidade só aplica o efeito no mundo.
## Os valores-base ficam no .tres da classe e são escalados pelo atributo
## `scaling_attribute` (multiplicador 1.0 = humano comum).

@export var display_name := ""
@export_multiline var description := ""
@export var cost := 20.0
@export var cooldown := 1.0
@export var scaling_attribute := Attributes.Kind.STRENGTH


## Multiplicador de potência vindo do atributo do jogador.
func power(player: Player) -> float:
	return player.stats.mult(scaling_attribute)


## true quando usar de novo apenas desliga o efeito (sem custo nem recarga).
func toggles_off(_player: Player) -> bool:
	return false


## Motivo para bloquear o uso (ex.: "Precisa estar no chão"), ou "" se pode usar.
func get_block_reason(_player: Player) -> String:
	return ""


func activate(_player: Player) -> void:
	pass

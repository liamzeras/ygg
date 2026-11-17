class_name BreakRules
extends Resource
## Limites globais dos pedaços do Quebrável (design/gdd/physics-magic-system.md, lei do Quebrável).
## Existem para que quebrar coisas não pese no quadro: poucos pedaços vivos, vida curta e
## física simplificada nos menores.

const PATH := "res://assets/data/materials/break_rules.tres"

## Máximo de pedaços vivos no mundo. Passou disso, os mais antigos somem primeiro.
@export var max_pieces := 40
## Segundos que um pedaço fica no mundo antes de sumir.
@export var piece_lifetime := 8.0
## Velocidade (m/s) com que os pedaços se afastam do centro, somada à do golpe.
@export var spread_speed := 1.5
## Pedaços com o maior lado abaixo disto (m) não recebem calor, não queimam e não avisam contato.
@export var small_piece_size := 0.25
## Camada de colisão dos pedaços (2 = só colidem com o resto do mundo, não entre si).
@export_flags_3d_physics var piece_layer := 2
## Com quais camadas os pedaços colidem.
@export_flags_3d_physics var piece_mask := 1


## Regras em uso (o arquivo fica em cache após a primeira leitura).
static func current() -> BreakRules:
	return load(PATH) as BreakRules

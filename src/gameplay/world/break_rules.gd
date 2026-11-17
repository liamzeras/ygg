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

@export_group("Limite por quadro")
## Explosões por quadro. As outras esperam o quadro seguinte (a cadeia atrasa poucos ms).
@export var max_explosions_per_frame := 1
## Efeitos de poeira (Fx.burst) de rachar, quebrar e virar cinzas por quadro. O resto não aparece.
@export var max_bursts_per_frame := 3

@export_group("Cenário (BreakableStructure)")
## Impulso (N·s) por estágio de qualquer estrutura do cenário, de qualquer tamanho. 420 = 6 socos de
## pedra sem revestimento (280 em concreto) ou 4 revestido (420): 4 estágios = 1680 N·s.
@export var structure_stage_impulse := 420.0
## Segundos até o que quebrou no cenário voltar inteiro (pedido do Liam: 30 s).
@export var rebuild_time := 30.0
## Se há alguém no lugar na hora de voltar, tenta de novo a cada isto (s).
@export var rebuild_retry := 0.5
## Massa máxima (kg) somada dos pedaços de uma estrutura (uma torre inteira pesaria toneladas).
@export var structure_piece_mass := 200.0
## Lado (m) do bloco de entulho que o chão e os muros da borda soltam no ponto do golpe.
@export var bedrock_chunk_size := 0.8

## Quanto de cada limite já foi gasto neste quadro.
static var _spent_tick := -1
static var _spent: Dictionary[StringName, int] = {}


## Regras em uso (o arquivo fica em cache após a primeira leitura).
static func current() -> BreakRules:
	if _current == null:
		_current = load(PATH) as BreakRules
	return _current


## Guardado na primeira leitura: quebrar e explodir perguntam isto centenas de vezes por quadro.
static var _current: BreakRules


## Gasta uma vaga do limite `kind` neste tick de física. false = o limite do tick acabou
## (quem pediu espera o próximo tick ou deixa de fazer, conforme o caso).
static func take_slot(kind: StringName, limit: int) -> bool:
	# Conta por quadro desenhado, não por tick: depois de um quadro lento o Godot roda vários
	# ticks seguidos para alcançar, e um limite por tick deixaria todos gastarem juntos.
	var tick := Engine.get_process_frames()
	if tick != _spent_tick:
		_spent_tick = tick
		_spent.clear()
	var used: int = _spent.get(kind, 0)
	if used >= limit:
		return false
	_spent[kind] = used + 1
	return true

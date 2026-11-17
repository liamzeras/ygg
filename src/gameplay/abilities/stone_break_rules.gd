class_name StoneBreakRules
extends Resource
## Como as construções da Terra (pilares da Escada e colunas do Terremoto) quebram quando levam
## soco ou chute de pedra (design/gdd/mage-earth.md, "Construções quebráveis").
## Estágios: 0 inteiro, 1 a 3 rachado (cada um solta uma lasca), 4 em pedaços (o pilar some e
## vira `chunk_count` blocos soltos). Estágios avançados por golpe = impulso / break_impulse.
## PROVISÓRIO: quando o mundo ganhar a propriedade "quebrável" (frente gameplay, physics_prop e
## materiais), os pilares passam a usar a dela; estes números viram o ponto de partida.

## Material de que a construção é feita: dá a massa (volume x densidade) e o tipo para a Terra.
@export var material: PropMaterial
## Impulso (N·s) que avança um estágio. 0 = não quebra.
@export var break_impulse := 120.0
## Blocos em que o pilar se desfaz no último estágio.
@export var chunk_count := 4
## Lado (m) da lasca que sai a cada estágio intermediário.
@export var chip_size := 0.3
## Fração do impulso do golpe passada aos pedaços.
@export_range(0.0, 1.0) var throw_share := 0.8
## Segundos até os pedaços sumirem.
@export var chunk_lifetime := 8.0

const LAST_STAGE := 4

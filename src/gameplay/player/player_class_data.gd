class_name PlayerClassData
extends Resource
## Definição de uma classe jogável. Os valores físicos saem dos atributos
## (ver AttributeRules); aqui ficam só identidade, atributos iniciais e habilidades.

@export var id: StringName
@export var display_name := ""
@export var role := ""
@export_multiline var description := ""
@export var color := Color.WHITE

@export var attributes: Attributes
## Massa do corpo + equipamento (kg): pesa em empurrões, explosões e na Investida.
@export var body_mass := 80.0

@export_group("Recursos")
## Todos têm Vigor (Vitalidade) e Mana (Inteligência).
## Segundos sem gastar antes de um recurso começar a regenerar.
@export var regen_delay := 0.8
## Vigor por segundo gasto ao correr.
@export var sprint_cost := 10.0

@export_group("Controle")
@export var acceleration := 10.0
@export_range(0.0, 1.0) var air_control := 0.3
## Alcance das mãos para pegar objetos (m).
@export var hand_range := 2.2
## Distância à frente da câmera onde o objeto segurado fica.
@export var hold_distance := 1.5

@export_group("Habilidades")
## Botão esquerdo.
@export var primary_ability: Ability
## Q.
@export var mobility_ability: Ability
## F.
@export var special_ability: Ability
## Espaço no ar (pulo duplo). Só um por salto; recarrega ao tocar o chão.
@export var air_jump_ability: Ability
## Ctrl: dash curto.
@export var dash_ability: Ability
## Segurar Espaço enquanto cai (só o Psiônico, por enquanto).
@export var float_ability: FloatAbility

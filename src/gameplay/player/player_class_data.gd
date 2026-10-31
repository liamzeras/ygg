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

@export_group("Recurso")
@export var pool_name := "Vigor"
@export var resource_color := Color(0.9, 0.75, 0.3)
## Atributo que define o tamanho e a regeneração do recurso.
@export var resource_attribute := Attributes.Kind.VITALITY
## Segundos sem gastar antes de começar a regenerar.
@export var regen_delay := 0.8
## Custo por segundo de correr.
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

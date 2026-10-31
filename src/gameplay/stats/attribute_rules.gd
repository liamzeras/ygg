class_name AttributeRules
extends Resource
## Regras que convertem atributos em números físicos. Uma instância só:
## assets/data/attribute_rules.tres. Fórmulas em design/gdd/attributes.md.
##
## Multiplicador de um atributo (1.0 = humano comum):
##   mult(v) = (v / humano) ^ alfa,   alfa = ln(mult_no_teto) / ln(teto / humano)
## Assim, no humano o mult é 1 e no teto é exatamente `multiplier_at_cap`,
## não importa se a referência humana do atributo é 7 ou 20.

@export var human: Attributes
@export var cap := 150.0
## Quantas vezes mais forte que um humano um atributo no teto deixa o personagem.
@export var multiplier_at_cap := 8.0

@export_group("Valores de um humano comum")
@export var carry_mass := 35.0          ## kg que segura e manipula com as mãos
@export var throw_speed := 9.0          ## m/s ao arremessar algo leve
@export var push_force := 300.0         ## N ao empurrar andando
@export var walk_speed := 4.5           ## m/s
@export var sprint_speed := 7.0         ## m/s
@export var jump_height := 0.6          ## m
@export var hold_stiffness := 10.0      ## firmeza ao segurar objetos (destreza)
@export var max_resource := 100.0       ## vigor ou mana
@export var resource_regen := 15.0      ## por segundo
## Impulso (N·s) de um empurrão forte de um humano. O boneco de testes compara com isto.
@export var human_shove_impulse := 60.0

@export_group("Expoentes (quanto o atributo pesa em cada valor)")
@export var speed_exponent := 0.5       ## velocidade ~ raiz da agilidade
@export var walk_exponent := 0.35
@export var jump_exponent := 1.0        ## altura do pulo ~ agilidade
@export var throw_exponent := 0.5       ## energia ~ força, velocidade ~ raiz
@export var resource_exponent := 0.5
@export var hold_exponent := 0.5


func multiplier(attributes: Attributes, kind: Attributes.Kind) -> float:
	var base := human.get_value(kind)
	var alpha := log(multiplier_at_cap) / log(cap / base)
	return pow(maxf(attributes.get_value(kind), 1.0) / base, alpha)


## Calcula todos os valores físicos do personagem a partir dos atributos.
func derive(attributes: Attributes, resource_attribute: Attributes.Kind) -> DerivedStats:
	var stats := DerivedStats.new()
	for kind: Attributes.Kind in Attributes.Kind.values():
		stats.multipliers[kind] = multiplier(attributes, kind)
	var strength := stats.mult(Attributes.Kind.STRENGTH)
	var agility := stats.mult(Attributes.Kind.AGILITY)
	var dexterity := stats.mult(Attributes.Kind.DEXTERITY)
	var resource := stats.mult(resource_attribute)

	stats.carry_mass = carry_mass * strength
	stats.throw_speed = throw_speed * pow(strength, throw_exponent)
	stats.push_force = push_force * strength
	stats.walk_speed = walk_speed * pow(agility, walk_exponent)
	stats.sprint_speed = sprint_speed * pow(agility, speed_exponent)
	stats.jump_height = jump_height * pow(agility, jump_exponent)
	stats.hold_stiffness = hold_stiffness * pow(dexterity, hold_exponent)
	stats.max_resource = max_resource * pow(resource, resource_exponent)
	stats.resource_regen = resource_regen * pow(resource, resource_exponent)
	return stats

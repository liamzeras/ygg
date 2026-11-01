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
## Velocidade de movimento é igual para todos: não depende de atributo.
## Só montarias e efeitos vão mudá-la (a definir).
@export var walk_speed := 4.5           ## m/s
@export var sprint_speed := 7.0         ## m/s
@export var jump_height := 0.85         ## m (igual para todos)
## Teto realista do pulo (m), mesmo com Agilidade alta. Mais alto só com habilidades.
@export var max_jump_height := 1.0
## Degrau que qualquer um sobe só andando, sem pular (m). Escada comum = 0,18 m.
@export var step_height := 0.4
@export var hold_stiffness := 10.0      ## firmeza ao segurar objetos (destreza)
@export var max_stamina := 100.0        ## Vigor (Vitalidade)
@export var stamina_regen := 15.0       ## Vigor por segundo
@export var max_mana := 100.0           ## Mana (Inteligência)
@export var mana_regen := 10.0          ## Mana por segundo
## Impulso (N·s) de um empurrão forte de um humano. O boneco de testes compara com isto.
@export var human_shove_impulse := 60.0

@export_group("Progressão (design/gdd/attributes.md)")
## Valor de cada atributo no nível 1.
@export var start_value := 1.0
## Teto com pontos de nível. De `base_cap` até `cap` só com bônus (ainda não existem).
@export var base_cap := 99.0
@export var max_level := 99
## Build de referência do nível máximo: define o total de pontos do jogo. Os atributos
## fora da lista ficam no valor inicial. Ex.: maximiza 2, e coloca 50 e 15 em outros 2.
@export var reference_build: Array[float] = [99.0, 99.0, 50.0, 15.0]
## Forma da curva de pontos por nível. 1 = igual em todo nível; menor que 1 = início mais rápido.
@export var level_curve := 0.8

@export_group("Expoentes (quanto o atributo pesa em cada valor)")
## Agilidade só afeta a velocidade de ataque (decisão do Liam, 2º playtest).
@export var attack_speed_exponent := 0.5  ## no teto (8x) ataca ~2,8x mais rápido
@export var throw_exponent := 0.5       ## energia ~ força, velocidade ~ raiz
@export var resource_exponent := 0.5
@export var hold_exponent := 0.5


func multiplier(attributes: Attributes, kind: Attributes.Kind) -> float:
	var base := human.get_value(kind)
	var alpha := log(multiplier_at_cap) / log(cap / base)
	return pow(maxf(attributes.get_value(kind), 1.0) / base, alpha)


## Calcula todos os valores físicos do personagem a partir dos atributos.
func derive(attributes: Attributes) -> DerivedStats:
	var stats := DerivedStats.new()
	for kind: Attributes.Kind in Attributes.Kind.values():
		stats.multipliers[kind] = multiplier(attributes, kind)
	var strength := stats.mult(Attributes.Kind.STRENGTH)
	var agility := stats.mult(Attributes.Kind.AGILITY)
	var dexterity := stats.mult(Attributes.Kind.DEXTERITY)
	var vitality := stats.mult(Attributes.Kind.VITALITY)
	var intelligence := stats.mult(Attributes.Kind.INTELLIGENCE)

	stats.carry_mass = carry_mass * strength
	stats.throw_speed = throw_speed * pow(strength, throw_exponent)
	stats.push_force = push_force * strength
	stats.walk_speed = walk_speed
	stats.sprint_speed = sprint_speed
	# Pulo igual para todos: nenhum atributo muda a altura (teto realista de 1 m).
	stats.jump_height = minf(jump_height, max_jump_height)
	stats.attack_speed = pow(agility, attack_speed_exponent)
	stats.hold_stiffness = hold_stiffness * pow(dexterity, hold_exponent)
	stats.max_stamina = max_stamina * pow(vitality, resource_exponent)
	stats.stamina_regen = stamina_regen * pow(vitality, resource_exponent)
	stats.max_mana = max_mana * pow(intelligence, resource_exponent)
	stats.mana_regen = mana_regen * pow(intelligence, resource_exponent)
	return stats


## Pontos que o personagem distribui até o nível máximo.
func total_points() -> int:
	var total := 0.0
	for value in reference_build:
		total += value - start_value
	return roundi(total)


## Pontos acumulados até `level`. Arredonda o acumulado (não o ganho de cada nível),
## então o total no nível máximo é sempre exato.
func points_at_level(level: int) -> int:
	var progress := float(clampi(level, 1, max_level) - 1) / float(max_level - 1)
	return roundi(total_points() * pow(progress, level_curve))


## Pontos ganhos ao chegar em `level` (0 no nível 1 e acima do máximo).
func points_gained_at(level: int) -> int:
	if level <= 1 or level > max_level:
		return 0
	return points_at_level(level) - points_at_level(level - 1)


## Pontos já gastos em uma build.
func spent_points(attributes: Attributes) -> int:
	var spent := 0.0
	for kind: Attributes.Kind in Attributes.Kind.values():
		spent += maxf(attributes.get_value(kind) - start_value, 0.0)
	return roundi(spent)


## Menor nível que paga uma build.
func level_for_build(attributes: Attributes) -> int:
	var spent := spent_points(attributes)
	for level in range(1, max_level + 1):
		if points_at_level(level) >= spent:
			return level
	return max_level


## true se a build cabe nos pontos do nível e nenhum atributo passa do teto base.
func is_legal_build(attributes: Attributes, level: int) -> bool:
	for kind: Attributes.Kind in Attributes.Kind.values():
		var value := attributes.get_value(kind)
		if value < start_value or value > base_cap:
			return false
	return spent_points(attributes) <= points_at_level(level)

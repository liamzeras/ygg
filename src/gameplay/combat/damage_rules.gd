class_name DamageRules
extends Resource
## Converte física em dano. Dano não é um número inventado por habilidade:
## sai do impulso (N·s) e do calor que o alvo recebe. Dados em assets/data/damage_rules.tres.
## Fórmulas em design/gdd/damage-and-testing.md.
##   dano_físico = max(impulso - limiar, 0) x dano_por_impulso
##   dano_fogo   = calor x dano_por_calor

## Impulso abaixo disto não machuca (esbarrar, empurrar de leve).
@export var impulse_threshold := 10.0
@export var damage_per_impulse := 0.1
@export var damage_per_heat := 0.1
## Segundos sem receber dano para o combo (e o boneco) zerar.
@export var combo_reset_time := 5.0


func impact_damage(impulse: float) -> float:
	return maxf(impulse - impulse_threshold, 0.0) * damage_per_impulse


func heat_damage(heat: float) -> float:
	return maxf(heat, 0.0) * damage_per_heat

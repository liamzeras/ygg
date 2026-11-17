class_name MaterializedProjectile
extends RigidBody3D
## Base dos objetos materializados e lançados por magia (design/gdd/damage-and-testing.md).
## Têm massa de verdade e o impacto sai da física:
##   impulso = massa x velocidade relativa ao alvo x escala mágica x mult(atributo)
## A velocidade de lançamento soma o movimento de quem lançou, então correr na direção
## do tiro bate mais forte e recuar bate mais fraco. Frear o projétil (Campo Lento) enfraquece.
## A distância não muda nada: só a velocidade no momento do impacto conta.

const DAMAGE: DamageRules = preload("res://assets/data/damage_rules.tres")

## Grupo com todos os projéteis materializados em voo (o bot procura ameaças nele).
const GROUP := &"materialized_projectiles"

## mult(atributo) de quem lançou.
var power := 1.0

var _flight_velocity := Vector3.ZERO


func _enter_tree() -> void:
	add_to_group(GROUP)


## Lança com a velocidade da magia somada ao movimento de quem lançou.
func launch(spell_velocity: Vector3, caster_velocity: Vector3) -> void:
	# Sem resistência do ar: o projétil não perde força com a distância.
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.0
	_flight_velocity = spell_velocity + caster_velocity
	linear_velocity = _flight_velocity


## Impulso (N·s) que o projétil aplica se bater agora em `target` (null = alvo parado).
func impact_impulse(target: Node = null) -> float:
	var relative := _flight_velocity - DamageRules.velocity_of(target)
	return DAMAGE.materialized_impulse(mass, relative.length()) * power


func _physics_process(_delta: float) -> void:
	# Guarda a velocidade de antes do choque: a colisão muda linear_velocity.
	_flight_velocity = linear_velocity

class_name BurnEffect
extends Node3D
## Queimadura forçada (Fogo-Fátuo, design/gdd/mage-fire.md): o alvo fica em chamas por
## `duration` s, seja qual for o material. Quem sabe receber calor (`add_heat` no próprio
## corpo ou no filho `Health`) recebe `heat_per_second`. Só uma por alvo: queimar de novo
## reinicia o tempo.

const NODE_NAME := "BurnEffect"

var duration := 10.0
var heat_per_second := 20.0

var _time := 0.0


## Põe `target` em chamas no ponto `at` (ou reinicia a queimadura que ele já tem).
static func attach(target: Node3D, at: Vector3, burn_duration: float, heat: float) -> BurnEffect:
	var effect := target.get_node_or_null(NODE_NAME) as BurnEffect
	if effect == null:
		effect = BurnEffect.new()
		effect.name = NODE_NAME
		target.add_child(effect)
		effect.add_child(Fx.make_fire(0.35))
	effect.global_position = at
	effect.duration = burn_duration
	effect.heat_per_second = heat
	effect._time = 0.0
	return effect


## Queimadura ativa em `target`, ou null.
static func of(target: Node) -> BurnEffect:
	return target.get_node_or_null(NODE_NAME) as BurnEffect if target else null


func time_left() -> float:
	return maxf(duration - _time, 0.0)


func _physics_process(delta: float) -> void:
	_time += delta
	if _time >= duration:
		queue_free()
		return
	var receiver := heat_receiver_of(get_parent())
	if receiver:
		receiver.add_heat(heat_per_second * delta)


## Quem recebe calor de um corpo: ele mesmo, se souber, ou o filho `Health` (jogador). Null se ninguém.
static func heat_receiver_of(node: Node) -> Node:
	if node == null:
		return null
	if node.has_method("add_heat"):
		return node
	var health := node.get_node_or_null("Health")
	return health if health and health.has_method("add_heat") else null

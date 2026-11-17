class_name BurnEffect
extends Node3D
## Queimadura forçada (Fogo-Fátuo, design/gdd/mage-fire.md): o alvo fica em chamas por
## `duration` s, seja qual for o material. Quem sabe receber calor (`add_heat` no próprio
## corpo ou no filho `Health`) recebe `heat_per_second`. Só uma por alvo: queimar de novo
## reinicia o tempo. Sem ar (lama), apaga: ver `extinguish_on` e MudPatch.

const NODE_NAME := "BurnEffect"

var duration := 10.0
var heat_per_second := 20.0
## Quem conjurou (dono do calor): não se queima com ela.
var heat_owner: Node

var _time := 0.0


## Põe `target` em chamas no ponto `at` (ou reinicia a queimadura que ele já tem).
static func attach(target: Node3D, at: Vector3, burn_duration: float, heat: float, owner_node: Node = null) -> BurnEffect:
	var effect := target.get_node_or_null(NODE_NAME) as BurnEffect
	if effect == null:
		effect = BurnEffect.new()
		effect.name = NODE_NAME
		target.add_child(effect)
		effect.add_child(Fx.make_fire(0.35))
	effect.global_position = at
	effect.duration = burn_duration
	effect.heat_per_second = heat
	effect.heat_owner = owner_node
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
	var target := get_parent()
	# Lei do Fogo: sem ar, a queimadura apaga (lama, e no futuro água).
	if target.has_method("get_air") and float(target.get_air()) <= 0.0:
		queue_free()
		return
	var receiver := heat_receiver_of(target)
	var owner_node := heat_owner if is_instance_valid(heat_owner) else null
	if receiver and not PhysicsProp.is_heat_owner(receiver, owner_node):
		PhysicsProp.give_heat(receiver, heat_per_second * delta, owner_node)


## Quem recebe calor de um corpo: ele mesmo, se souber, ou o filho `Health` (jogador). Null se ninguém.
static func heat_receiver_of(node: Node) -> Node:
	if node == null:
		return null
	if node.has_method("add_heat"):
		return node
	var health := node.get_node_or_null("Health")
	return health if health and health.has_method("add_heat") else null


## Apaga a queimadura de `target`, se houver (zona sem ar sobre um personagem).
static func extinguish_on(target: Node) -> void:
	var effect := of(target)
	if effect:
		effect.queue_free()

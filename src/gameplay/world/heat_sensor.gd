class_name HeatSensor
extends Area3D
## Sensor invisível de calor: uma esfera presa a quem espalha calor (objeto em chamas, pedra em
## brasa) que só entrega quem está dentro do alcance. Quem acha os vizinhos é a física do Godot, a
## cada passo, e não uma varredura de todos os que recebem calor no mundo (item 4 do diagnóstico de
## desempenho, production/perf/diagnostico-2026-11-17.md; pedido do Liam: de milhares de
## conferências por tick para 10 a 20 por fonte de calor).
##
## O alcance e a conta do calor não mudam: o sensor só devolve candidatos, e quem chama confere a
## distância como antes (DamageRules.distance_to). A esfera é um pouco maior que o raio
## (BreakRules.heat_sensor_margin) para não perder quem tem o ponto de referência perto da borda
## da própria colisão (a vida do jogador fica nos pés da cápsula).
##
## - Vida dentro de um personagem (sem colisão própria) é achada pelo corpo pai.
## - Quem a física não acha (superfície do laboratório, sem camada) fica numa lista curta, refeita
##   quando o grupo "heat_receivers" muda de tamanho ou a cada BreakRules.heat_loose_refresh s.
## - Logo depois de ligado, o sensor ainda não passou por um passo da física: nesses ticks ele
##   pergunta direto ao espaço (mais caro, mas só no começo), para o calor não atrasar um tick.

const GROUP := &"heat_receivers"
## Colisões devolvidas pela pergunta direta, no máximo.
const MAX_RESULTS := 64
## Passos da física até a lista de sobreposição do sensor valer.
const WARMUP_STEPS := 2

## Conferências (candidatos devolvidos) desde o último zerar, para testes e medição.
static var checks := 0

## Receptores sem colisão própria cujo corpo pai a física acha (vida dentro do personagem).
static var _attached: Dictionary = {}
## Receptores que a física não acha de jeito nenhum.
static var _loose: Array[Node] = []
static var _lists_count := -1
static var _lists_time := -INF

var _shape := SphereShape3D.new()
var _ready_frame := 0


## Sensor preso a `holder` (criado na primeira vez). Fica no mesmo lugar que ele.
static func of(holder: Node3D) -> HeatSensor:
	for child in holder.get_children():
		if child is HeatSensor:
			return child as HeatSensor
	var sensor := HeatSensor.new()
	holder.add_child(sensor)
	return sensor


func _init() -> void:
	name = &"HeatSensor"
	collision_layer = 0
	collision_mask = 0xFFFFFFFF
	monitorable = false
	monitoring = false
	var collision := CollisionShape3D.new()
	collision.shape = _shape
	add_child(collision)


## Quem recebe calor perto do dono do sensor (raio `radius` + margem), sem o próprio dono.
## Cada candidato devolvido conta uma conferência em `checks`.
func nearby(radius: float) -> Array[Node]:
	_shape.radius = radius + BreakRules.current().heat_sensor_margin
	if not monitoring:
		monitoring = true
		_ready_frame = Engine.get_physics_frames() + WARMUP_STEPS
	var holder := get_parent()
	var found: Array[Node] = []
	_refresh_lists(get_tree())
	# Cada corpo aparece uma vez (a lista do sensor não repete; a pergunta direta é filtrada).
	for body: Node in _bodies():
		if body == holder:
			continue
		if body.is_in_group(GROUP):
			found.append(body)
		if _attached.has(body):
			for child: Node in _attached[body]:
				if is_instance_valid(child) and child.is_in_group(GROUP):
					found.append(child)
	for node in _loose:
		if is_instance_valid(node) and node.is_inside_tree():
			found.append(node)
	checks += found.size()
	return found


## Desliga o sensor enquanto o dono não espalha calor (não pesa na física).
func sleep() -> void:
	if monitoring:
		monitoring = false


func _bodies() -> Array:
	if Engine.get_physics_frames() >= _ready_frame:
		return get_overlapping_bodies()
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = _shape
	params.transform = Transform3D(Basis.IDENTITY, global_position)
	params.collision_mask = collision_mask
	var holder := get_parent()
	if holder is CollisionObject3D:
		params.exclude = [(holder as CollisionObject3D).get_rid()]
	var bodies := []
	var seen := {}
	for hit in get_world_3d().direct_space_state.intersect_shape(params, MAX_RESULTS):
		if hit["collider"] != null and not seen.has(hit["collider"]):
			seen[hit["collider"]] = true
			bodies.append(hit["collider"])
	return bodies


## Refaz as listas de quem a física não acha sozinho, só quando o grupo muda ou de tempos em tempos.
static func _refresh_lists(tree: SceneTree) -> void:
	var count := tree.get_node_count_in_group(GROUP)
	var now := Time.get_ticks_msec() / 1000.0
	if count == _lists_count and now - _lists_time < BreakRules.current().heat_loose_refresh:
		return
	_lists_count = count
	_lists_time = now
	_attached.clear()
	_loose.clear()
	for node in tree.get_nodes_in_group(GROUP):
		if _sensed(node):
			continue
		var parent := node.get_parent()
		if _sensed(parent):
			if not _attached.has(parent):
				_attached[parent] = []
			(_attached[parent] as Array).append(node)
		else:
			_loose.append(node)


static func _sensed(node: Node) -> bool:
	return node is CollisionObject3D and (node as CollisionObject3D).collision_layer != 0

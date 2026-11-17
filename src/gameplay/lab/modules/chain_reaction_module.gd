class_name LabChainReactionModule
extends LabModule
## Passivo: maestria "Reação em cadeia" (design/sabio/inspiracao/maestrias.md). Quando uma
## Bola de Fogo explode, as outras Bolas de Fogo ainda no ar e a pólvora dentro do raio
## estouram em seguida, cada elo depois de `link_delay`. Pólvora que entrou na cadeia
## continua a cadeia. A cadeia não escolhe lado: quem estiver no raio também é atingido.

const WARNING_COLOR := Color(1, 0.95, 0.7)

## Segundos entre um elo e o próximo (o anel de aviso aparece nesse intervalo).
@export var link_delay := 0.1
## Multiplica o raio de cada explosão na busca pelo próximo elo.
@export var reach_factor := 1.0

## Bolas de Fogo já observadas, com o último ponto conhecido.
var _projectiles := {}
## Pólvora que entrou na cadeia e propaga quando explodir.
var _chained_props := {}
var _links := 0


func status_text() -> String:
	return "elos nesta sessão: %d" % _links


func tick(_delta: float) -> void:
	for node in controller.get_tree().current_scene.find_children("*", "FireballProjectile", true, false):
		var projectile := node as FireballProjectile
		if not _projectiles.has(projectile):
			_projectiles[projectile] = projectile.global_position
			projectile.tree_exiting.connect(_on_projectile_exiting.bind(projectile))
		else:
			_projectiles[projectile] = projectile.global_position


func on_disabled() -> void:
	super.on_disabled()
	_projectiles.clear()
	_chained_props.clear()


func _on_projectile_exiting(projectile: FireballProjectile) -> void:
	var origin: Vector3 = _projectiles.get(projectile, projectile.global_position)
	_projectiles.erase(projectile)
	if enabled:
		_propagate(origin, projectile.blast_radius, projectile)


func _on_prop_exploded(prop: PhysicsProp) -> void:
	if not _chained_props.has(prop):
		return
	_chained_props.erase(prop)
	if enabled:
		_propagate(prop.global_position, prop.material_data.explosion_radius, prop)


func _propagate(origin: Vector3, radius: float, source: Node) -> void:
	var reach := radius * reach_factor
	for node: FireballProjectile in _projectiles.keys():
		if node == source or not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.global_position.distance_to(origin) <= reach:
			_schedule(node)
	for node in controller.get_tree().get_nodes_in_group(&"physics_props"):
		var prop := node as PhysicsProp
		if prop == null or prop == source or not prop.material_data.explosive or _chained_props.has(prop):
			continue
		if DamageRules.distance_to(prop, origin) <= reach:
			_chained_props[prop] = true
			if not prop.exploded.is_connected(_on_prop_exploded):
				prop.exploded.connect(_on_prop_exploded.bind(prop))
			_schedule(prop)


## Mostra o anel de aviso e estoura o elo depois de `link_delay`.
func _schedule(target: Node3D) -> void:
	_links += 1
	Fx.burst(controller.get_tree().current_scene, target.global_position, WARNING_COLOR, 0.3)
	controller.get_tree().create_timer(link_delay, false, true).timeout.connect(_detonate.bind(target))


func _detonate(target: Node3D) -> void:
	if not enabled or not is_instance_valid(target) or target.is_queued_for_deletion():
		return
	if target is FireballProjectile:
		target.call("_detonate")
	elif target is PhysicsProp:
		(target as PhysicsProp).explode()

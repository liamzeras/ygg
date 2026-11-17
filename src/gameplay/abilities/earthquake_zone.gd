class_name EarthquakeZone
extends Node3D
## Área viva de um Terremoto (ver EarthquakeAbility e design/gdd/mage-earth.md). Cria as colunas
## (StonePillar) e os pedregulhos, aplica o golpe para cima uma vez e some depois do tempo.

var ability: EarthquakeAbility
var caster: Node3D
var side := 1.0
var power := 1.0

## Sem tipo de propósito: guardam objetos que podem já ter sido apagados.
var _pillars := []
var _boulders := []
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _ended := false


func get_pillars() -> Array[StonePillar]:
	var alive: Array[StonePillar] = []
	for pillar: Variant in _pillars:
		if is_instance_valid(pillar):
			alive.append(pillar)
	return alive


func get_boulders() -> Array[PhysicsProp]:
	var alive: Array[PhysicsProp] = []
	for boulder: Variant in _boulders:
		if is_instance_valid(boulder):
			alive.append(boulder)
	return alive


## Ergue o relevo centrado em `ground` (ponto do chão), alinhado com `forward`.
func start(ground: Vector3, forward: Vector3) -> void:
	_rng.randomize()
	global_transform = Transform3D(Basis.looking_at(forward, Vector3.UP), ground)
	var count := maxi(ceili(side / ability.max_cell - 0.001), 1)
	var cell := side / count
	var stalagmites := 0
	var cells: Array[Vector3] = []
	for i in count:
		for j in count:
			cells.append(Vector3((i + 0.5) * cell - side / 2.0, 0.0, (j + 0.5) * cell - side / 2.0))
	var boulders := maxi(cells.size() / maxi(ability.cells_per_boulder, 1), 1)
	for index in cells.size():
		var spike := _rng.randf() < ability.stalagmite_chance
		# No tamanho máximo, garante ao menos uma estalagmite (a última coluna).
		if index == cells.size() - 1 and stalagmites == 0 and cells.size() > 1:
			spike = true
		if spike:
			stalagmites += 1
		var height := _rng.randf_range(ability.min_height, ability.max_height)
		if spike:
			height = _rng.randf_range(lerpf(ability.min_height, ability.max_height, 0.6), ability.max_height)
		_pillars.append(_add_pillar(to_global(cells[index]), cell * (ability.stalagmite_width if spike else 1.0), height, spike))
	for k in boulders:
		var spot := cells[_rng.randi_range(0, cells.size() - 1)]
		_add_boulder(to_global(spot) + Vector3.UP * (ability.max_height + ability.boulder_size))
	Fx.burst(get_parent(), ground, StonePillar.COLOR, side * 0.6)
	_launch(ground)


## Afunda tudo agora (fim do tempo ou novo Terremoto).
func end() -> void:
	if _ended:
		return
	_ended = true
	for pillar in get_pillars():
		pillar.sink()
	for boulder in get_boulders():
		boulder.queue_free()


func _physics_process(delta: float) -> void:
	_time += delta
	if not _ended and _time >= ability.rise_time + ability.lifetime:
		end()
	if _ended and get_pillars().is_empty():
		queue_free()


func _add_pillar(ground: Vector3, width: float, height: float, spike: bool) -> StonePillar:
	var pillar := StonePillar.new()
	pillar.source_name = ability.display_name
	pillar.width = width
	pillar.height = height
	pillar.rise_time = ability.rise_time
	# O tempo de pé é controlado aqui (end), não pelo pilar.
	pillar.lifetime = ability.lifetime + 10.0
	pillar.sink_time = ability.sink_time
	pillar.impact_transfer = 0.0
	pillar.quiet = true
	pillar.material = ability.construct_material
	if ability.construct_material:
		pillar.pillar_mass = width * width * height * ability.construct_material.density
	pillar.caster = caster
	get_parent().add_child(pillar)
	pillar.start(ground, global_basis * Vector3.FORWARD)
	if spike:
		var tip := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = width * 0.7
		cone.height = width * 1.5
		cone.radial_segments = 8
		cone.rings = 1
		cone.material = StonePillar.stone_material(CasterLook.is_rival_same_class(caster))
		tip.mesh = cone
		tip.position.y = cone.height / 2.0
		pillar.add_child(tip)
	return pillar


func _add_boulder(at: Vector3) -> void:
	if ability.boulder_material == null:
		return
	var boulder := PhysicsProp.new()
	boulder.material_data = ability.boulder_material
	boulder.shape_kind = PhysicsProp.Form.SPHERE
	boulder.size = Vector3.ONE * ability.boulder_size
	boulder.display_name = "Pedregulho"
	get_parent().add_child(boulder)
	boulder.global_position = at
	_boulders.append(boulder)


## Golpe para cima, uma vez, em tudo que estiver na área (menos quem lançou).
func _launch(ground: Vector3) -> void:
	var box := BoxShape3D.new()
	box.size = Vector3(side, ability.max_height + 1.0, side)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	query.transform = Transform3D(global_basis, ground + Vector3.UP * box.size.y / 2.0)
	var exclude: Array[RID] = []
	if caster is CollisionObject3D:
		exclude.append((caster as CollisionObject3D).get_rid())
	query.exclude = exclude
	var done: Array[Object] = []
	for result in get_world_3d().direct_space_state.intersect_shape(query, 64):
		var target: Object = result.collider
		if done.has(target) or target is StonePillar or (target is PhysicsProp and _boulders.has(target as PhysicsProp)):
			continue
		done.append(target)
		var receiver := DamageRules.receiver_of(target as Node)
		if receiver and not DamageRules.is_invulnerable(target as Node):
			receiver.register_hit(ability.display_name, ability.base_damage_impulse * power)
		if target.has_method("apply_knockback"):
			target.apply_knockback(Vector3.UP * ability.launch_impulse * sqrt(power))
		elif target is RigidBody3D and not (target as RigidBody3D).freeze:
			var body := target as RigidBody3D
			body.linear_velocity.y = maxf(body.linear_velocity.y, ability.launch_speed * sqrt(power))

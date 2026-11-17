class_name StonePillar
extends AnimatableBody3D
## Pilar de pedra da Escada de Pedra (design/gdd/mage-elementalist.md). A origem fica no
## centro do topo. Sobe do chão, fica de pé `lifetime` s e afunda. Ao subir: carrega
## personagens em cima (elevador), passa a velocidade da subida para objetos soltos
## (catapulta) e acerta o que tem `register_hit` com massa x velocidade x transferência.

## O pilar rachou mais um estágio (ou se desfez, no último).
signal cracked(stage: int)

enum State { RISING, STANDING, SINKING }

const COLOR := Color(0.5, 0.47, 0.44)
## Folga (m) para considerar um personagem "em cima" do topo.
const RIDE_TOLERANCE := 0.3
## Raio do corpo dos personagens (m), para saber se estão sobre o pilar.
const CHARACTER_RADIUS := 0.35

var source_name := "Pilar de Pedra"
var width := 1.0
var height := 3.0
## Altura que o jogador sobe sozinho segurando W ao encostar aqui (ver Player._step_up).
var auto_climb_height := 0.0
var rise_time := 0.35
var lifetime := 8.0
var sink_time := 0.6
var pillar_mass := 1000.0
var impact_transfer := 0.05
## Sem poeira própria ao nascer (o Terremoto faz uma só para a área toda).
var quiet := false
## Quem ergueu (para a cor do rival da mesma classe).
var caster: Node3D
## Como quebra com socos e chutes (null = não quebra).
var breaking: StoneBreakRules
## Estágio de quebra: 0 inteiro ... StoneBreakRules.LAST_STAGE em pedaços.
var break_stage := 0

var _state := State.RISING
var _time := 0.0
var _ground := Vector3.ZERO
var _sink_from := 0.0
## Altura atual do topo acima do chão. Guardada aqui: com sync_to_physics, global_position
## só muda no quadro de física seguinte.
var _rise := 0.0
var _top_shape: BoxShape3D
var _hit_bodies: Array[Object] = []

## Material da pedra, o mesmo para todos os pilares (criar um por pilar custa e trava).
static var _shared_materials := {}
static var _cracked_materials: Array[StandardMaterial3D] = []

var _mesh_instance: MeshInstance3D


func _ready() -> void:
	sync_to_physics = true
	var shape := BoxShape3D.new()
	shape.size = Vector3(width, height, width)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = -height / 2.0
	add_child(collision)

	var mesh := BoxMesh.new()
	mesh.size = shape.size
	mesh.material = stone_material(CasterLook.is_rival_same_class(caster))
	var mesh_instance := MeshInstance3D.new()
	_mesh_instance = mesh_instance
	mesh_instance.mesh = mesh
	mesh_instance.position.y = -height / 2.0
	add_child(mesh_instance)

	_top_shape = BoxShape3D.new()
	_top_shape.size = Vector3(width, RIDE_TOLERANCE * 2.0, width)
	if breaking and breaking.material:
		set_meta(&"material_data", breaking.material)


## Posiciona o pilar enterrado no ponto do chão (topo rente ao chão), virado para
## `direction` (para os degraus ficarem alinhados), e começa a subir.
func start(ground_point: Vector3, direction: Vector3) -> void:
	_ground = ground_point
	global_transform = Transform3D(Basis.looking_at(direction, Vector3.UP), ground_point)
	if not quiet:
		Fx.burst(get_parent(), ground_point, COLOR, 0.6)


func get_top_height() -> float:
	return global_position.y


func is_sinking() -> bool:
	return _state == State.SINKING


func is_risen() -> bool:
	return _state == State.STANDING


## Afunda agora (nova escada lançada ou fim do tempo).
func sink() -> void:
	if _state == State.SINKING:
		return
	_state = State.SINKING
	_time = 0.0
	_sink_from = _rise


func _physics_process(delta: float) -> void:
	_time += delta
	var previous_rise := _rise
	match _state:
		State.RISING:
			_rise = height * clampf(_time / rise_time, 0.0, 1.0)
			if _time >= rise_time:
				_state = State.STANDING
				_time = 0.0
		State.STANDING:
			_rise = height
			if _time >= lifetime:
				sink()
		State.SINKING:
			_rise = _sink_from * (1.0 - clampf(_time / sink_time, 0.0, 1.0))
			if _time >= sink_time:
				queue_free()
				return
	# Parado de pé não se move: mover um corpo de física a cada quadro custa caro com muitos pilares.
	if _rise == previous_rise and _time > 0.0 and _state != State.RISING:
		return
	global_position = _ground + Vector3.UP * _rise
	if _rise > previous_rise:
		_lift_riders(_ground.y + previous_rise, _ground.y + _rise, (_rise - previous_rise) / delta)


func _lift_riders(previous_top: float, new_top: float, speed: float) -> void:
	var half := width / 2.0 + CHARACTER_RADIUS
	# Personagens: sobem junto e param no topo (sem arremesso).
	for node in get_tree().get_nodes_in_group(&"characters"):
		var character := node as CharacterBody3D
		var offset := to_local(character.global_position)
		if absf(offset.x) > half or absf(offset.z) > half:
			continue
		var feet := character.global_position.y
		if feet >= previous_top - RIDE_TOLERANCE and feet <= new_top + 0.05:
			character.global_position.y = new_top
			character.velocity.y = maxf(character.velocity.y, 0.0)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _top_shape
	var top := Vector3(_ground.x, new_top + RIDE_TOLERANCE * 0.5, _ground.z)
	query.transform = Transform3D(global_basis, top)
	query.exclude = [get_rid()]
	for result in get_world_3d().direct_space_state.intersect_shape(query, 16):
		var body := result.collider as RigidBody3D
		# Objetos soltos em cima: ganham a velocidade da subida (catapulta).
		if body and not body.freeze:
			body.linear_velocity.y = maxf(body.linear_velocity.y, speed)
		# Um golpe por alvo, na velocidade em que o pilar subia.
		var target: Object = result.collider
		if target.has_method("register_hit") and not _hit_bodies.has(target):
			_hit_bodies.append(target)
			target.register_hit(source_name, pillar_mass * speed * impact_transfer)


## Material compartilhado da pedra dos pilares (também usado nas pontas das estalagmites).
static func stone_material(rival := false) -> StandardMaterial3D:
	if not _shared_materials.has(rival):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = COLOR.darkened(CasterLook.RIVAL_DARKEN) if rival else COLOR
		mat.roughness = 1.0
		_shared_materials[rival] = mat
	return _shared_materials[rival]


## Soco ou chute de pedra acertou o pilar em `at`, na direção `direction`. Avança
## impulso / break_impulse estágios; nos intermediários solta uma lasca, no último se desfaz em
## blocos arremessados na direção do golpe. Devolve o estágio atual.
func take_strike(impulse: float, direction: Vector3, at: Vector3) -> int:
	if breaking == null or breaking.material == null or breaking.break_impulse <= 0.0 or is_sinking():
		return break_stage
	var stages := int(impulse / breaking.break_impulse)
	if stages < 1:
		return break_stage
	break_stage = mini(break_stage + stages, StoneBreakRules.LAST_STAGE)
	cracked.emit(break_stage)
	if break_stage >= StoneBreakRules.LAST_STAGE:
		_shatter(impulse, direction)
	else:
		_mesh_instance.material_override = _cracked_material(break_stage)
		# A lasca sai pelo lado oposto ao golpe, na altura em que ele acertou.
		var flat := Vector3(direction.x, 0.0, direction.z).normalized()
		var y := clampf(at.y, global_position.y - _rise + breaking.chip_size, global_position.y - breaking.chip_size / 2.0)
		var spot := Vector3(global_position.x, y, global_position.z) + flat * (width / 2.0 + breaking.chip_size)
		var chip := _spawn_chunk(Vector3.ONE * breaking.chip_size, spot)
		chip.apply_central_impulse(direction * impulse * breaking.throw_share / stages / 2.0)
	return break_stage


## Desfaz o pilar em blocos empilhados, todos arremessados na direção do golpe.
func _shatter(impulse: float, direction: Vector3) -> void:
	var count := maxi(breaking.chunk_count, 1)
	var piece_height := _rise / count
	if piece_height < 0.05:
		queue_free()
		return
	var piece := Vector3(width * 0.9, piece_height * 0.9, width * 0.9)
	for i in count:
		var center := global_position - global_basis.y * (piece_height * (i + 0.5))
		var chunk := _spawn_chunk(piece, center)
		chunk.apply_central_impulse(direction * impulse * breaking.throw_share / count)
	Fx.burst(get_parent(), global_position - Vector3.UP * _rise / 2.0, COLOR, width)
	queue_free()


func _spawn_chunk(size: Vector3, at: Vector3) -> PhysicsProp:
	var chunk := PhysicsProp.new()
	chunk.material_data = breaking.material
	chunk.shape_kind = PhysicsProp.Form.BOX
	chunk.size = size
	chunk.display_name = "Pedaço de pedra"
	get_parent().add_child(chunk)
	chunk.global_position = at
	chunk.get_tree().create_timer(breaking.chunk_lifetime).timeout.connect(chunk.queue_free)
	return chunk


## Pedra mais escura a cada estágio de rachadura (compartilhada entre os pilares).
static func _cracked_material(stage: int) -> StandardMaterial3D:
	while _cracked_materials.size() < StoneBreakRules.LAST_STAGE:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = COLOR.darkened(0.15 * (_cracked_materials.size() + 1))
		mat.roughness = 1.0
		_cracked_materials.append(mat)
	return _cracked_materials[clampi(stage - 1, 0, _cracked_materials.size() - 1)]

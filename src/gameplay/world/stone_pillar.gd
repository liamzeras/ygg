class_name StonePillar
extends AnimatableBody3D
## Pilar de pedra da Escada de Pedra (design/gdd/mage-elementalist.md). A origem fica no
## centro do topo. Sobe do chão, fica de pé `lifetime` s e afunda. Ao subir: carrega
## personagens em cima (elevador), passa a velocidade da subida para objetos soltos
## (catapulta) e acerta o que tem `register_hit` com massa x velocidade x transferência.

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

var _state := State.RISING
var _time := 0.0
var _ground := Vector3.ZERO
var _sink_from := 0.0
## Altura atual do topo acima do chão. Guardada aqui: com sync_to_physics, global_position
## só muda no quadro de física seguinte.
var _rise := 0.0
var _top_shape: BoxShape3D
var _hit_bodies: Array[Object] = []


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
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLOR
	mat.roughness = 1.0
	mesh.material = mat
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position.y = -height / 2.0
	add_child(mesh_instance)

	_top_shape = BoxShape3D.new()
	_top_shape.size = Vector3(width, RIDE_TOLERANCE * 2.0, width)


## Posiciona o pilar enterrado no ponto do chão (topo rente ao chão), virado para
## `direction` (para os degraus ficarem alinhados), e começa a subir.
func start(ground_point: Vector3, direction: Vector3) -> void:
	_ground = ground_point
	global_transform = Transform3D(Basis.looking_at(direction, Vector3.UP), ground_point)
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

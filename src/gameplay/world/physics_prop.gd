class_name PhysicsProp
extends RigidBody3D
## Objeto físico genérico feito de um material (madeira, metal, pedra...).
## Gera a própria malha e colisão a partir de `shape_kind` + `size`, calcula a massa
## pelo volume x densidade e implementa o sistema de calor/fogo/explosão.
## Regras em design/gdd/physics-magic-system.md, incluindo as leis do Fogo (ar e combustível,
## calor guardado) e da Gravidade (peso = massa x gravidade local).

signal ignited
signal burned_out
signal exploded
signal extinguished
## Avançou um estágio do Quebrável (1 a 3 = rachado; 4 = virou pedaços).
signal stage_changed(stage: int)
## Virou pedaços. `pieces` são os PhysicsProp novos (já no mundo).
signal shattered(pieces: Array)

enum Form { BOX, CYLINDER, SPHERE, CAPSULE }

## Cor final de um objeto quase totalmente queimado.
const CHARRED := Color(0.08, 0.06, 0.05)
## Cor de uma pedra ou metal no calor máximo (apresentação, não regra).
const RED_HOT := Color(0.95, 0.35, 0.1)
const KILL_HEIGHT := -50.0
## Quanto cada estágio de rachadura escurece a cor (apresentação, não regra).
const STAGE_SHADE := 0.14

@export var material_data: PropMaterial
@export var shape_kind := Form.BOX
## BOX: largura/altura/profundidade. CYLINDER/CAPSULE: x = diâmetro, y = altura. SPHERE: x = diâmetro.
@export var size := Vector3.ONE
## Nome mostrado na mira. Vazio = nome do material.
@export var display_name := ""

var heat := 0.0
## Quem conjurou o calor deste objeto (o mago). Ele não se queima com ele; os outros, sim.
var heat_owner: Node = null
var burning := false
var last_speed := 0.0
var last_velocity := Vector3.ZERO

var _burn_left := 0.0
var _fuse_left := -1.0
var _exploded := false
var _visual_material: StandardMaterial3D
var _fire: Node3D
var _base_mass := 1.0
## Ar disponível (1 = normal, 0 = abafado). Zonas renovam a cada tick; ver apply_air().
var _air := 1.0
var _air_frame := -10
## Pedaço de um objeto quebrado: não racha de novo, some sozinho (ver BreakRules).
var is_piece := false
## Dano acumulado do Quebrável (N·s) e estágio atual (0 inteiro .. 4 pedaços).
var _damage := 0.0
var _stage := 0
var _shattered := false
var _volume := 1.0
var _life_left := INF

## Pedaços vivos, do mais antigo ao mais novo (para o limite de BreakRules.max_pieces).
static var _alive_pieces: Array[PhysicsProp] = []


func _ready() -> void:
	if material_data == null:
		push_warning("%s sem material_data; usando padrão." % name)
		material_data = PropMaterial.new()
	add_to_group(&"physics_props")
	add_to_group(&"heat_receivers")
	_build()
	_base_mass = mass
	_burn_left = material_data.burn_time
	if is_piece and _is_small_piece():
		# Física simplificada: sem calor e sem aviso de contato.
		remove_from_group(&"heat_receivers")
		return
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func get_display_name() -> String:
	return display_name if display_name != "" else material_data.display_name


func _physics_process(delta: float) -> void:
	last_velocity = linear_velocity
	last_speed = linear_velocity.length()
	if global_position.y < KILL_HEIGHT:
		queue_free()
		return
	if is_piece:
		_life_left -= delta
		if _life_left <= 0.0:
			queue_free()
			return
	if _fuse_left >= 0.0:
		_fuse_left -= delta
		if _fuse_left <= 0.0:
			explode()
			return
	var air := get_air()
	if burning:
		# Lei do Fogo: sem ar apaga; com ar, consome combustível e aquece na proporção do ar.
		if air <= 0.0:
			extinguish()
			return
		_burn_left -= delta * air
		_spread_heat(material_data.fire_spread_radius, material_data.fire_spread_heat * air, delta)
		var burnt := 1.0 - clampf(_burn_left / material_data.burn_time, 0.0, 1.0)
		_visual_material.albedo_color = _surface_color().lerp(CHARRED, burnt)
		mass = _base_mass * lerpf(1.0, material_data.burnt_mass_fraction, burnt)
		if _burn_left <= 0.0:
			_burn_out()
	elif heat > 0.0:
		if material_data.stores_heat() and heat > material_data.radiate_threshold:
			_radiate(delta)
		heat = maxf(heat - material_data.heat_decay * delta, 0.0)
		if material_data.stores_heat():
			_visual_material.albedo_color = _surface_color().lerp(RED_HOT, heat / material_data.max_heat)


## Aquece o objeto. Inflamáveis pegam fogo ao passar de `ignition_heat`; pedra e metal guardam
## o calor até `max_heat`. Sem ar (dentro da lama, por exemplo), o calor não entra.
## `source` é quem conjurou o calor (o mago); ele passa a ser o dono do calor deste objeto e não se
## queima com ele. Sem `source`, o dono atual continua.
func add_heat(amount: float, source: Node = null) -> void:
	if burning or _exploded or amount <= 0.0 or get_air() <= 0.0:
		return
	if is_instance_valid(source):
		heat_owner = source
	if material_data.flammable:
		heat += amount
		if heat >= material_data.ignition_heat:
			ignite()
	elif material_data.stores_heat():
		heat = minf(heat + amount, material_data.max_heat)


## Zonas do mundo informam o ar no ponto onde o objeto está (0 = abafado, 1 = normal).
## Chamar a cada tick de física; no mesmo tick, vale o menor valor (sem ar vence).
func apply_air(factor: float) -> void:
	var frame := Engine.get_physics_frames()
	_air = minf(_air, factor) if frame == _air_frame else factor
	_air_frame = frame


## Ar atual. Sem zona renovando há mais de um tick, o ar volta a ser normal (1).
func get_air() -> float:
	return _air if Engine.get_physics_frames() - _air_frame <= 1 else 1.0


## Segundos de queima que ainda restam com ar normal (combustível).
func fuel_left() -> float:
	return _burn_left


## Lei da Gravidade: peso (N) = massa x gravidade local x escala de gravidade do corpo.
func get_weight() -> float:
	var state := PhysicsServer3D.body_get_direct_state(get_rid())
	var gravity := state.total_gravity if state else Vector3.DOWN * float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	return mass * gravity.length() * gravity_scale


## Acende. `source` (opcional) é quem conjurou o fogo: vira o dono do calor (ver add_heat).
func ignite(source: Node = null) -> void:
	if burning or not material_data.flammable or _burn_left <= 0.0 or get_air() <= 0.0:
		return
	if is_instance_valid(source):
		heat_owner = source
	burning = true
	_fire = Fx.make_fire(maxf(size.x, size.z) * 0.4)
	add_child(_fire)
	if material_data.explosive:
		_fuse_left = material_data.fuse_time
	ignited.emit()


## Apaga o fogo (ex.: Lamaçal). O que já queimou continua escurecido; o pavio para.
func extinguish() -> void:
	if not burning:
		return
	burning = false
	heat = 0.0
	_fuse_left = -1.0
	if is_instance_valid(_fire):
		_fire.queue_free()
	_fire = null
	extinguished.emit()


## Retira calor (ex.: lama molhada).
func cool(amount: float) -> void:
	heat = maxf(heat - amount, 0.0)


func explode() -> void:
	if _exploded:
		return
	_exploded = true
	exploded.emit()
	Explosion.detonate(self, global_position, material_data.explosion_radius,
			material_data.explosion_impulse, material_data.explosion_heat, [get_rid()])
	queue_free()


## Aquece quem recebe calor no raio (objetos, boneco e, no futuro, personagens) e devolve o total.
func _spread_heat(radius: float, heat_per_second: float, delta: float) -> float:
	var given := 0.0
	var owner_node := heat_owner if is_instance_valid(heat_owner) else null
	for node in get_tree().get_nodes_in_group(&"heat_receivers"):
		if node == self or is_heat_owner(node, owner_node):
			continue
		var distance := DamageRules.distance_to(node as Node3D, global_position)
		if distance < radius:
			var amount := heat_per_second * (1.0 - distance / radius) * delta
			give_heat(node, amount, owner_node)
			given += amount
	return given


## true se `receiver` é o dono do calor ou faz parte dele (a vida do mago é filha do corpo).
## Quem conjurou não se queima com o que criou (decisão do Liam, 2026-11-17).
static func is_heat_owner(receiver: Node, owner_node: Node) -> bool:
	if owner_node == null or receiver == null:
		return false
	return receiver == owner_node or owner_node.is_ancestor_of(receiver)


## Entrega calor passando o dono adiante para quem aceita (objetos), sem quebrar quem só
## recebe a quantidade (boneco, alvos, vida dos monstros).
static func give_heat(receiver: Node, amount: float, owner_node: Node = null) -> void:
	if owner_node != null and receiver.get_method_argument_count(&"add_heat") >= 2:
		receiver.add_heat(amount, owner_node)
	else:
		receiver.add_heat(amount)


## Pedra ou metal quente aquece os vizinhos e perde o que entrega (o calor não se multiplica).
func _radiate(delta: float) -> void:
	var excess := heat - material_data.radiate_threshold
	var given := _spread_heat(material_data.radiate_radius, excess * material_data.radiate_rate, delta)
	heat = maxf(heat - given, 0.0)


# --- Lei do Quebrável (design/gdd/physics-magic-system.md) ------------------------------

## Estágio atual: 0 inteiro, 1 a 3 rachado. (O estágio 4 não existe num objeto: ele já virou pedaços.)
func get_break_stage() -> int:
	return _stage


## Dano acumulado (N·s).
func get_break_damage() -> float:
	return _damage


## Impulso (N·s) que avança um estágio neste objeto: break_toughness x massa inteira.
func stage_impulse() -> float:
	return material_data.stage_impulse(_base_mass)


## Golpe do mundo: empurra o objeto com `impulse` (N·s, já na direção do golpe) e deixa o
## dano correspondente. Se quebrar, os pedaços saem na direção do golpe.
## `point` (global) opcional: onde o golpe acerta, para girar o objeto.
## É a interface que soco, chute, explosões e construções devem usar.
func take_hit(impulse: Vector3, point := Vector3.INF) -> void:
	if _shattered:
		return
	if point == Vector3.INF:
		apply_central_impulse(impulse)
	else:
		apply_impulse(impulse, point - global_position)
	add_damage(impulse.length(), impulse)


## Dano sem empurrão (ou com empurrão já aplicado por fora). `push` é o impulso do golpe,
## herdado pelos pedaços se este dano partir o objeto.
func add_damage(amount: float, push := Vector3.ZERO) -> void:
	if is_piece or _shattered or _exploded:
		return
	var damage := material_data.hit_damage(amount, _base_mass)
	if damage <= 0.0:
		return
	_damage += damage
	var stage := material_data.stage_for(_damage, _base_mass)
	if stage == _stage:
		return
	_stage = stage
	stage_changed.emit(stage)
	if stage >= PropMaterial.BREAK_STAGES:
		shatter(push)
		return
	if not burning:
		_visual_material.albedo_color = _surface_color()
	Fx.burst(get_tree().current_scene, global_position, _surface_color(), maxf(size.x, size.y) * 0.4)


## Parte o objeto em pedaços agora. Barril de pólvora explode em vez de partir.
## Devolve os pedaços criados (vazio se explodiu ou se já tinha quebrado).
func shatter(push := Vector3.ZERO) -> Array[PhysicsProp]:
	var none: Array[PhysicsProp] = []
	if _shattered or _exploded:
		return none
	if material_data.explosive:
		explode.call_deferred()
		return none
	_shattered = true
	if not is_inside_tree():
		return none
	# O objeto some neste quadro; tirá-lo da física evita que empurre os próprios pedaços.
	collision_layer = 0
	collision_mask = 0
	var velocity := linear_velocity + push / maxf(mass, 0.01)
	var pieces := spawn_pieces(get_parent(), global_transform, _piece_box(), material_data, mass, velocity)
	var burnt_left := _burn_left
	for piece in pieces:
		piece._base_mass = _base_mass * piece.mass / mass
		piece._burn_left = burnt_left
		if piece.is_in_group(&"heat_receivers"):
			piece.heat = heat
			piece.heat_owner = heat_owner
			if burning:
				piece.ignite()
		piece._visual_material.albedo_color = _visual_material.albedo_color
	if is_instance_valid(_fire):
		_fire.queue_free()
	burning = false
	Fx.burst(get_tree().current_scene, global_position, _surface_color(), maxf(size.x, size.y))
	shattered.emit(pieces)
	queue_free()
	return pieces


## Cria os pedaços de um objeto quebrado e devolve a lista. Serve também para construções que
## não são PhysicsProp (pilar de pedra): passe a transformação, a caixa (m), o material, a massa
## total e a velocidade inicial (velocidade do objeto + impulso do golpe / massa). Tire o corpo
## original da física (ou apague) no mesmo quadro. Cada pedaço recebe a massa proporcional ao
## volume, a velocidade dada + um afastamento do centro e respeita os limites de BreakRules.
static func spawn_pieces(parent: Node, xform: Transform3D, box: Vector3, material: PropMaterial,
		total_mass: float, velocity := Vector3.ZERO) -> Array[PhysicsProp]:
	var rules := BreakRules.current()
	var pieces: Array[PhysicsProp] = []
	if parent == null or material == null:
		return pieces
	var cells := split_box(box, material.break_pieces)
	var total_volume := box.x * box.y * box.z
	for cell in cells:
		var offset: Vector3 = cell[0]
		var cell_size: Vector3 = cell[1]
		var piece := PhysicsProp.new()
		piece.is_piece = true
		piece.material_data = material
		piece.shape_kind = Form.BOX
		piece.size = cell_size
		piece.display_name = "Pedaço"
		piece.collision_layer = rules.piece_layer
		piece.collision_mask = rules.piece_mask
		piece._life_left = rules.piece_lifetime
		parent.add_child(piece)
		piece.global_transform = Transform3D(xform.basis, xform * offset)
		piece.mass = maxf(total_mass * cell_size.x * cell_size.y * cell_size.z / total_volume, 0.05)
		piece._base_mass = piece.mass
		var outward := (xform.basis * offset).normalized()
		piece.linear_velocity = velocity + outward * rules.spread_speed
		_track_piece(piece, rules.max_pieces)
		pieces.append(piece)
	return pieces


## Divide uma caixa em `count` partes cortando sempre a maior parte pelo lado mais longo.
## Devolve [centro relativo, tamanho] de cada parte; a soma dos volumes é a da caixa.
static func split_box(box: Vector3, count: int) -> Array:
	var cells: Array = [[Vector3.ZERO, box]]
	while cells.size() < count:
		var biggest := 0
		for i in cells.size():
			var s: Vector3 = cells[i][1]
			var b: Vector3 = cells[biggest][1]
			if s.x * s.y * s.z > b.x * b.y * b.z:
				biggest = i
		var center: Vector3 = cells[biggest][0]
		var cell_size: Vector3 = cells[biggest][1]
		var axis := cell_size.max_axis_index()
		var half := cell_size
		half[axis] *= 0.5
		var shift := Vector3.ZERO
		shift[axis] = half[axis] * 0.5
		cells[biggest] = [center - shift, half]
		cells.append([center + shift, half])
	return cells


## Quantos pedaços estão vivos agora.
static func alive_piece_count() -> int:
	var alive: Array[PhysicsProp] = []
	for piece in _alive_pieces:
		if is_instance_valid(piece) and not piece.is_queued_for_deletion():
			alive.append(piece)
	_alive_pieces = alive
	return _alive_pieces.size()


static func _track_piece(piece: PhysicsProp, max_pieces: int) -> void:
	alive_piece_count()
	_alive_pieces.append(piece)
	while _alive_pieces.size() > max_pieces:
		_alive_pieces.pop_front().queue_free()


## Caixa com o mesmo volume do objeto e a proporção do contorno dele (pedaços são caixas).
func _piece_box() -> Vector3:
	var outline := size
	match shape_kind:
		Form.CYLINDER, Form.CAPSULE:
			outline = Vector3(size.x, size.y, size.x)
		Form.SPHERE:
			outline = Vector3.ONE * size.x
	var outline_volume := outline.x * outline.y * outline.z
	return outline * pow(_volume / outline_volume, 1.0 / 3.0) if outline_volume > 0.0 else outline


func _is_small_piece() -> bool:
	return maxf(size.x, maxf(size.y, size.z)) < BreakRules.current().small_piece_size


## Cor do material escurecida pelas rachaduras.
func _surface_color() -> Color:
	return material_data.color.darkened(STAGE_SHADE * _stage)


## Batida forte (queda, objeto arremessado) racha: dano = massa reduzida x (velocidade de
## aproximação - break_impact_speed). Roda fora do callback de colisão.
func _crack_on_impact(body: Node) -> void:
	if is_piece or _shattered or not material_data.breakable:
		return
	var other_velocity := (body as PhysicsProp).last_velocity if body is PhysicsProp else DamageRules.velocity_of(body)
	var relative := last_velocity - other_velocity
	var excess := relative.length() - material_data.break_impact_speed
	if excess <= 0.0:
		return
	var reduced_mass := mass
	if body is RigidBody3D:
		var other_mass := (body as RigidBody3D).mass
		reduced_mass = mass * other_mass / (mass + other_mass)
	add_damage.call_deferred(reduced_mass * excess)


func _burn_out() -> void:
	burned_out.emit()
	Fx.burst(get_tree().current_scene, global_position, Color(0.3, 0.3, 0.3), maxf(size.x, size.y))
	queue_free()


func _on_body_entered(body: Node) -> void:
	# Impacto pela velocidade de aproximação: bater num alvo que vem na sua direção dói mais.
	# Só conta se o objeto vinha mesmo na direção do alvo (> 2 m/s): quem anda contra uma
	# caixa parada não se machuca nela.
	var receiver := DamageRules.receiver_of(body)
	if receiver and body is Node3D:
		var toward := (DamageRules.center_of(body as Node3D) - global_position).normalized()
		var closing := (last_velocity - DamageRules.velocity_of(body)).dot(toward)
		if last_velocity.dot(toward) > 2.0 and closing > 2.0 and not DamageRules.is_invulnerable(body):
			receiver.register_hit(get_display_name(), mass * closing)
	_crack_on_impact(body)
	if not material_data.explosive or _exploded:
		return
	var impact := last_speed
	if body is PhysicsProp:
		impact = maxf(impact, (body as PhysicsProp).last_speed)
	if impact >= material_data.impact_detonation_speed:
		# Consultas de física não podem rodar dentro do callback de colisão.
		explode.call_deferred()


func _build() -> void:
	var mesh: PrimitiveMesh
	var shape: Shape3D
	var volume := 0.0
	match shape_kind:
		Form.BOX:
			var box_mesh := BoxMesh.new()
			box_mesh.size = size
			var box_shape := BoxShape3D.new()
			box_shape.size = size
			mesh = box_mesh
			shape = box_shape
			volume = size.x * size.y * size.z
		Form.CYLINDER:
			var radius := size.x * 0.5
			var cyl_mesh := CylinderMesh.new()
			cyl_mesh.top_radius = radius
			cyl_mesh.bottom_radius = radius
			cyl_mesh.height = size.y
			var cyl_shape := CylinderShape3D.new()
			cyl_shape.radius = radius
			cyl_shape.height = size.y
			mesh = cyl_mesh
			shape = cyl_shape
			volume = PI * radius * radius * size.y
		Form.SPHERE:
			var radius := size.x * 0.5
			var sphere_mesh := SphereMesh.new()
			sphere_mesh.radius = radius
			sphere_mesh.height = size.x
			var sphere_shape := SphereShape3D.new()
			sphere_shape.radius = radius
			mesh = sphere_mesh
			shape = sphere_shape
			volume = 4.0 / 3.0 * PI * pow(radius, 3)
		Form.CAPSULE:
			var radius := size.x * 0.5
			var cap_mesh := CapsuleMesh.new()
			cap_mesh.radius = radius
			cap_mesh.height = size.y
			var cap_shape := CapsuleShape3D.new()
			cap_shape.radius = radius
			cap_shape.height = size.y
			mesh = cap_mesh
			shape = cap_shape
			volume = PI * radius * radius * maxf(size.y - 2.0 * radius, 0.0) + 4.0 / 3.0 * PI * pow(radius, 3)

	_visual_material = StandardMaterial3D.new()
	_visual_material.albedo_color = material_data.color
	_visual_material.roughness = material_data.roughness
	_visual_material.metallic = material_data.metallic
	mesh.material = _visual_material

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	_volume = volume
	mass = maxf(volume * material_data.density, 0.5)
	var physics_material := PhysicsMaterial.new()
	physics_material.friction = material_data.friction
	physics_material.bounce = material_data.bounce
	physics_material_override = physics_material

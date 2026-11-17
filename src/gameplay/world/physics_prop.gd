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

enum Form { BOX, CYLINDER, SPHERE, CAPSULE }

## Cor final de um objeto quase totalmente queimado.
const CHARRED := Color(0.08, 0.06, 0.05)
## Cor de uma pedra ou metal no calor máximo (apresentação, não regra).
const RED_HOT := Color(0.95, 0.35, 0.1)
const KILL_HEIGHT := -50.0

@export var material_data: PropMaterial
@export var shape_kind := Form.BOX
## BOX: largura/altura/profundidade. CYLINDER/CAPSULE: x = diâmetro, y = altura. SPHERE: x = diâmetro.
@export var size := Vector3.ONE
## Nome mostrado na mira. Vazio = nome do material.
@export var display_name := ""

var heat := 0.0
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


func _ready() -> void:
	if material_data == null:
		push_warning("%s sem material_data; usando padrão." % name)
		material_data = PropMaterial.new()
	add_to_group(&"physics_props")
	add_to_group(&"heat_receivers")
	_build()
	_base_mass = mass
	_burn_left = material_data.burn_time
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
		_visual_material.albedo_color = material_data.color.lerp(CHARRED, burnt)
		mass = _base_mass * lerpf(1.0, material_data.burnt_mass_fraction, burnt)
		if _burn_left <= 0.0:
			_burn_out()
	elif heat > 0.0:
		if material_data.stores_heat() and heat > material_data.radiate_threshold:
			_radiate(delta)
		heat = maxf(heat - material_data.heat_decay * delta, 0.0)
		if material_data.stores_heat():
			_visual_material.albedo_color = material_data.color.lerp(RED_HOT, heat / material_data.max_heat)


## Aquece o objeto. Inflamáveis pegam fogo ao passar de `ignition_heat`; pedra e metal guardam
## o calor até `max_heat`. Sem ar (dentro da lama, por exemplo), o calor não entra.
func add_heat(amount: float) -> void:
	if burning or _exploded or amount <= 0.0 or get_air() <= 0.0:
		return
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


func ignite() -> void:
	if burning or not material_data.flammable or _burn_left <= 0.0 or get_air() <= 0.0:
		return
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
	for node in get_tree().get_nodes_in_group(&"heat_receivers"):
		if node == self:
			continue
		var distance := DamageRules.distance_to(node as Node3D, global_position)
		if distance < radius:
			var amount := heat_per_second * (1.0 - distance / radius) * delta
			node.add_heat(amount)
			given += amount
	return given


## Pedra ou metal quente aquece os vizinhos e perde o que entrega (o calor não se multiplica).
func _radiate(delta: float) -> void:
	var excess := heat - material_data.radiate_threshold
	var given := _spread_heat(material_data.radiate_radius, excess * material_data.radiate_rate, delta)
	heat = maxf(heat - given, 0.0)


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

	mass = maxf(volume * material_data.density, 0.5)
	var physics_material := PhysicsMaterial.new()
	physics_material.friction = material_data.friction
	physics_material.bounce = material_data.bounce
	physics_material_override = physics_material

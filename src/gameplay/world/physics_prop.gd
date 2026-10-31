class_name PhysicsProp
extends RigidBody3D
## Objeto físico genérico feito de um material (madeira, metal, pedra...).
## Gera a própria malha e colisão a partir de `shape_kind` + `size`, calcula a massa
## pelo volume x densidade e implementa o sistema de calor/fogo/explosão.
## Regras em design/gdd/physics-magic-system.md.

signal ignited
signal burned_out
signal exploded

enum Form { BOX, CYLINDER, SPHERE, CAPSULE }

## Cor final de um objeto quase totalmente queimado.
const CHARRED := Color(0.08, 0.06, 0.05)
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

var _burn_left := 0.0
var _fuse_left := -1.0
var _exploded := false
var _visual_material: StandardMaterial3D


func _ready() -> void:
	if material_data == null:
		push_warning("%s sem material_data; usando padrão." % name)
		material_data = PropMaterial.new()
	add_to_group(&"physics_props")
	_build()
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func get_display_name() -> String:
	return display_name if display_name != "" else material_data.display_name


func _physics_process(delta: float) -> void:
	last_speed = linear_velocity.length()
	if global_position.y < KILL_HEIGHT:
		queue_free()
		return
	if _fuse_left >= 0.0:
		_fuse_left -= delta
		if _fuse_left <= 0.0:
			explode()
			return
	if burning:
		_burn_left -= delta
		_spread_heat(delta)
		var burnt := 1.0 - clampf(_burn_left / material_data.burn_time, 0.0, 1.0)
		_visual_material.albedo_color = material_data.color.lerp(CHARRED, burnt)
		if _burn_left <= 0.0:
			_burn_out()
	elif heat > 0.0:
		heat = maxf(heat - material_data.heat_decay * delta, 0.0)


## Aquece o objeto. Materiais inflamáveis pegam fogo ao passar de `ignition_heat`.
func add_heat(amount: float) -> void:
	if not material_data.flammable or burning or _exploded:
		return
	heat += amount
	if heat >= material_data.ignition_heat:
		ignite()


func ignite() -> void:
	if burning or not material_data.flammable:
		return
	burning = true
	_burn_left = material_data.burn_time
	add_child(Fx.make_fire(maxf(size.x, size.z) * 0.4))
	if material_data.explosive:
		_fuse_left = material_data.fuse_time
	ignited.emit()


func explode() -> void:
	if _exploded:
		return
	_exploded = true
	exploded.emit()
	Explosion.detonate(self, global_position, material_data.explosion_radius,
			material_data.explosion_impulse, material_data.explosion_heat, [get_rid()])
	queue_free()


func _spread_heat(delta: float) -> void:
	var radius := material_data.fire_spread_radius
	for node in get_tree().get_nodes_in_group(&"physics_props"):
		if node == self:
			continue
		var distance := global_position.distance_to((node as Node3D).global_position)
		if distance < radius:
			node.add_heat(material_data.fire_spread_heat * (1.0 - distance / radius) * delta)


func _burn_out() -> void:
	burned_out.emit()
	Fx.burst(get_tree().current_scene, global_position, Color(0.3, 0.3, 0.3), maxf(size.x, size.y))
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("register_hit") and last_speed > 2.0:
		body.register_hit(get_display_name(), mass * last_speed)
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

class_name FlyingTarget
extends AnimatableBody3D
## Alvo voador de testes (F7, design/gdd/damage-and-testing.md). Orbita um ponto para testar
## projéteis contra algo em movimento. O dano vai para o combo do boneco de testes, que
## calcula tudo com as mesmas DamageRules, e aparece também aqui em cima do alvo.

const RADIUS := 0.35
const COLOR := Color(0.95, 0.35, 0.6)
const HIT_COLOR := Color(1, 1, 1)
const FLASH_TIME := 0.25
const LABEL_TIME := 1.5
## Massa (kg) para o empurrão dos golpes; a volta ao caminho é uma mola amortecida.
const MASS := 5.0
const KNOCK_DECAY := 3.0

## Quem recebe e soma o dano.
var dummy: TrainingDummy
var center := Vector3.ZERO
var orbit_radius := 5.0
## m/s ao longo da órbita. Negativo = sentido contrário.
var orbit_speed := 4.0
var bob_height := 0.5
var angle := 0.0
var hit_count := 0

var _time := 0.0
var _motion := Vector3.ZERO
var _knock := Vector3.ZERO
var _knock_velocity := Vector3.ZERO
var _material: StandardMaterial3D
var _label: Label3D
var _flash := 0.0
var _label_time := 0.0


func _ready() -> void:
	add_to_group(&"heat_receivers")
	sync_to_physics = false
	var shape := SphereShape3D.new()
	shape.radius = RADIUS
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

	var mesh := SphereMesh.new()
	mesh.radius = RADIUS
	mesh.height = RADIUS * 2.0
	_material = StandardMaterial3D.new()
	_material.albedo_color = COLOR
	mesh.material = _material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	_label = Label3D.new()
	_label.position.y = 0.8
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 48
	_label.pixel_size = 0.008
	_label.outline_size = 10
	_label.no_depth_test = true
	add_child(_label)
	global_position = _orbit_point()


## Velocidade atual: entra no cálculo do impacto relativo (ver DamageRules.velocity_of).
func get_motion_velocity() -> Vector3:
	return _motion


func surface_distance(point: Vector3) -> float:
	return maxf(global_position.distance_to(point) - RADIUS, 0.0)


func register_hit(source: String, impulse: float) -> void:
	hit_count += 1
	_show_damage(dummy.damage_rules.impact_damage(impulse))
	dummy.register_hit("Alvo: %s" % source, impulse)


func add_heat(amount: float) -> void:
	_show_damage(dummy.damage_rules.heat_damage(amount))
	dummy.add_heat(amount)


func apply_knockback(impulse: Vector3) -> void:
	_knock_velocity += impulse / MASS


func _physics_process(delta: float) -> void:
	_time += delta
	if orbit_radius > 0.0:
		angle += orbit_speed / orbit_radius * delta
	_knock_velocity = _knock_velocity.lerp(-_knock * KNOCK_DECAY, clampf(KNOCK_DECAY * delta, 0.0, 1.0))
	_knock += _knock_velocity * delta
	var next := _orbit_point() + _knock
	_motion = (next - global_position) / delta
	global_position = next


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash -= delta
		_material.albedo_color = COLOR.lerp(HIT_COLOR, clampf(_flash / FLASH_TIME, 0.0, 1.0))
	if _label_time > 0.0:
		_label_time -= delta
		_label.modulate.a = clampf(_label_time / 0.4, 0.0, 1.0)


func _orbit_point() -> Vector3:
	var bob := sin(_time * 1.5) * bob_height
	return center + Vector3(cos(angle) * orbit_radius, bob, sin(angle) * orbit_radius)


func _show_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	_flash = FLASH_TIME
	_label_time = LABEL_TIME
	_label.text = String.num(amount, 1).replace(".", ",")

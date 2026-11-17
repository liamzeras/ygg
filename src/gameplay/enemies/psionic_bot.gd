class_name PsionicBot
extends CharacterBody3D
## Bot Mago Psiônico agressivo (design/gdd/combat-bot.md). Usa o mesmo kit e os mesmos
## atributos do Psiônico jogável (assets/data/classes/psionic.tres): carrega e dispara Dardos
## Cinéticos com previsão do movimento do alvo, circula a meia distância, dá dash de esquiva e
## ergue Campo Lento contra projéteis que vêm nele. Gasta Mana e Vigor como o jogador.
## O comportamento (distâncias, ritmo, pontaria) fica em BotProfile.

const BODY_HEIGHT := 1.8
const BODY_RADIUS := 0.35
const EYE_HEIGHT := 1.62
const KILL_HEIGHT := -30.0
const SOURCE_NAME := "Psiônico (bot)"
const HIT_FLASH_TIME := 0.25

@export var class_data: PlayerClassData
@export var rules: AttributeRules
@export var profile: BotProfile

## Quem o bot ataca.
var target: Node3D
var health: Health
var stats: DerivedStats
var spawn_point := Vector3.ZERO

var _dart: KineticDartAbility
var _field: SlowFieldAbility
var _dash: DashAbility
var _mana := 0.0
var _stamina := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _rng := RandomNumberGenerator.new()
var _strafe_sign := 1.0
var _strafe_timer := 0.0
var _dash_timer := 0.0
var _dash_time := 0.0
var _dash_velocity := Vector3.ZERO
var _speed_effects := {}
var _charging := false
var _charge_goal := 0.0
var _charge_time := 0.0
var _shot_cooldown := 0.0
var _field_cooldown := 0.0
var _threat_timer := 0.0
var _visual: Node3D
var _orb: MeshInstance3D
var _label: Label3D
var _body_material: StandardMaterial3D
var _flash := 0.0

## Viseira e orbe são iguais em todos os bots: criados uma vez e reaproveitados.
static var _visor_mesh: BoxMesh
static var _orb_mesh: SphereMesh


func _ready() -> void:
	stats = rules.derive(class_data.attributes)
	_dart = class_data.primary_ability as KineticDartAbility
	_field = class_data.mobility_ability as SlowFieldAbility
	_dash = class_data.utility_ability as DashAbility
	_mana = stats.max_mana
	_stamina = stats.max_stamina
	spawn_point = global_position
	_rng.randomize()
	_dash_timer = _rng.randf_range(profile.dash_interval_min, profile.dash_interval_max)
	add_to_group(&"characters")
	_build()
	health = Health.new()
	health.name = "Health"
	add_child(health)
	health.setup(stats.mult(Attributes.Kind.VITALITY))
	health.changed.connect(func(_current: float, _maximum: float) -> void: _refresh_label())
	health.damaged.connect(func(_source: String, _amount: float) -> void: _flash = HIT_FLASH_TIME)
	_refresh_label()


# --- Mesma interface de dano do jogador e do boneco ---------------------------

func register_hit(source: String, impulse: float) -> void:
	health.register_hit(source, impulse)


func add_heat(amount: float) -> void:
	health.add_heat(amount)


## Efeito de terreno ou magia na velocidade (lama, Gravidade dos Sonhos). Vale o mais forte.
## Mesma interface do Player.
func set_speed_effect(source: Object, factor: float) -> void:
	_speed_effects[source] = factor


func clear_speed_effect(source: Object) -> void:
	_speed_effects.erase(source)


func get_speed_factor() -> float:
	var factor := 1.0
	for value: float in _speed_effects.values():
		factor = minf(factor, value)
	return factor


func apply_knockback(impulse: Vector3) -> void:
	if health.is_invulnerable():
		return
	velocity += impulse / class_data.body_mass


func get_center() -> Vector3:
	return global_position + Vector3.UP * BODY_HEIGHT / 2.0


func surface_distance(point: Vector3) -> float:
	return DamageRules.capsule_distance(global_position, BODY_HEIGHT, BODY_RADIUS, point)


func get_mana() -> float:
	return _mana


func is_charging() -> bool:
	return _charging


## Volta ao ponto de nascimento, com Mana e Vigor cheios (a vida é do Health).
func respawn() -> void:
	global_position = spawn_point
	velocity = Vector3.ZERO
	_charging = false
	_dash_time = 0.0
	_mana = stats.max_mana
	_stamina = stats.max_stamina


# --- Ciclo --------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_shot_cooldown = maxf(_shot_cooldown - delta, 0.0)
	_field_cooldown = maxf(_field_cooldown - delta, 0.0)
	_mana = minf(_mana + stats.mana_regen * delta, stats.max_mana)
	_stamina = minf(_stamina + stats.stamina_regen * delta, stats.max_stamina)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if global_position.y < KILL_HEIGHT:
		respawn()

	if is_instance_valid(target):
		var eye := global_position + Vector3.UP * EYE_HEIGHT
		var aim_point := DamageRules.center_of(target)
		var flat := aim_point - eye
		flat.y = 0.0
		var sees := _has_line_of_sight(eye, aim_point)
		if flat.length() > 0.01:
			rotation.y = atan2(-flat.x, -flat.z)
		_update_movement(delta, flat, sees)
		_update_attack(delta, eye, aim_point, sees)
		_react_to_threats(delta)
	else:
		_brake(delta)
	move_and_slide()


func _process(delta: float) -> void:
	_flash = maxf(_flash - delta, 0.0)
	_body_material.albedo_color = class_data.color.lerp(Color(1, 0.25, 0.2), clampf(_flash / HIT_FLASH_TIME, 0.0, 1.0))
	# Pisca enquanto está invencível.
	_visual.visible = not health.is_invulnerable() or fmod(health.get_invulnerable_time(), 0.1) < 0.05
	_orb.visible = _charging
	if _charging:
		var size := 0.4 + 1.2 * _current_charge()
		_orb.scale = Vector3.ONE * size


# --- Movimento ----------------------------------------------------------------

func _update_movement(delta: float, flat: Vector3, sees: bool) -> void:
	if _dash_time > 0.0:
		_dash_time -= delta
		velocity.x = _dash_velocity.x
		velocity.z = _dash_velocity.z
		if _dash_time <= 0.0:
			var horizontal := Vector2(velocity.x, velocity.z).limit_length(stats.sprint_speed)
			velocity.x = horizontal.x
			velocity.z = horizontal.y
		return

	_strafe_timer -= delta
	if _strafe_timer <= 0.0:
		_strafe_sign = -_strafe_sign if _rng.randf() < 0.7 else _strafe_sign
		_strafe_timer = _rng.randf_range(profile.strafe_switch_min, profile.strafe_switch_max)

	var distance := flat.length()
	var forward := flat / distance if distance > 0.01 else -global_basis.z
	var side := forward.cross(Vector3.UP) * _strafe_sign
	var wish: Vector3
	if not sees:
		# Sem visão (algo no caminho, como o boneco): contorna pelo lado em vez de empurrar o
		# obstáculo de frente. Bateu de lado também, troca de lado.
		if is_on_wall():
			_strafe_sign = -_strafe_sign
			side = -side
		wish = side + forward * 0.4
	elif distance > profile.preferred_range + 2.0:
		wish = forward + side * 0.3
	elif distance < profile.min_range:
		wish = -forward + side * 0.5
	else:
		wish = side + forward * clampf((distance - profile.preferred_range) / profile.preferred_range, -0.5, 0.5)
	wish = wish.normalized()

	var sprinting := distance > profile.sprint_range and _stamina > 0.0
	if sprinting:
		_stamina = maxf(_stamina - class_data.sprint_cost * delta, 0.0)
	var speed := (stats.sprint_speed if sprinting else stats.walk_speed) * get_speed_factor()
	var accel := class_data.acceleration * (1.0 if is_on_floor() else class_data.air_control)
	var horizontal := Vector2(velocity.x, velocity.z).lerp(Vector2(wish.x, wish.z) * speed, clampf(accel * delta, 0.0, 1.0))
	velocity.x = horizontal.x
	velocity.z = horizontal.y

	if not is_on_floor():
		return
	_dash_timer -= delta
	if _dash and sees and _dash_timer <= 0.0 and _stamina >= _dash.cost:
		_stamina -= _dash.cost
		_dash_velocity = side * _dash.distance / _dash.duration
		_dash_time = _dash.duration
		_dash_timer = _rng.randf_range(profile.dash_interval_min, profile.dash_interval_max)
	elif _rng.randf() < profile.jump_chance_per_second * delta:
		velocity.y = sqrt(2.0 * _gravity * stats.jump_height)


func _brake(delta: float) -> void:
	var horizontal := Vector2(velocity.x, velocity.z).lerp(Vector2.ZERO, clampf(class_data.acceleration * delta, 0.0, 1.0))
	velocity.x = horizontal.x
	velocity.z = horizontal.y


# --- Ataque: Dardo Cinético ---------------------------------------------------

func _update_attack(delta: float, eye: Vector3, aim_point: Vector3, sees: bool) -> void:
	if not _charging:
		if sees and _shot_cooldown <= 0.0 and _mana >= _dart.cost_at(0.0):
			_charging = true
			_charge_time = 0.0
			_charge_goal = minf(_rng.randf_range(profile.charge_min, profile.charge_max), _dart.max_charge_for(_mana))
		return
	if not sees:
		_charging = false
		return
	_charge_time += delta
	# No meio do dash, segura o disparo: a mira não acompanha uma arrancada de 15 m/s.
	if _current_charge() >= _charge_goal and _dash_time <= 0.0:
		_fire(eye, aim_point, _current_charge())


## O dardo herda o movimento de quem atira (MaterializedProjectile). Para ele seguir na direção
## `wanted`, o bot cancela a parte da própria velocidade que é de lado em relação ao tiro.
func _compensate_own_motion(wanted: Vector3, speed: float) -> Vector3:
	var sideways := velocity - wanted * velocity.dot(wanted)
	return (wanted * speed - sideways).normalized()


func _current_charge() -> float:
	var full_time := _dart.charge_time / stats.attack_speed
	return clampf(_charge_time / full_time, 0.0, 1.0) if full_time > 0.0 else 1.0


func _fire(eye: Vector3, aim_point: Vector3, charge: float) -> void:
	_charging = false
	var cost := _dart.cost_at(charge)
	if _mana < cost:
		return
	_mana -= cost
	var speed := lerpf(_dart.min_speed, _dart.max_speed, charge)
	# Antecipa o movimento do alvo pelo tempo de voo do dardo.
	var flight_time := eye.distance_to(aim_point) / speed
	var lead := aim_point + DamageRules.velocity_of(target) * flight_time * profile.lead_factor
	var direction := _compensate_own_motion((lead - eye).normalized(), speed)
	var error := deg_to_rad(profile.aim_error_degrees)
	direction = direction.rotated(Vector3.UP, _rng.randf_range(-error, error))
	var tilt_axis := direction.cross(Vector3.UP).normalized()
	if tilt_axis != Vector3.ZERO:
		direction = direction.rotated(tilt_axis, _rng.randf_range(-error, error))

	var dart := KineticDartProjectile.new()
	dart.source_name = SOURCE_NAME
	dart.mass = lerpf(_dart.min_mass, _dart.max_mass, charge)
	dart.power = stats.mult(_dart.scaling_attribute)
	dart.gravity_scale = _dart.gravity_scale
	dart.lifetime = _dart.lifetime
	dart.set_meta(&"caster", self)
	get_tree().current_scene.add_child(dart)
	dart.global_position = eye + direction * 0.6
	dart.launch(direction * speed, velocity)
	dart.add_collision_exception_with(self)
	_shot_cooldown = _dart.cooldown / stats.attack_speed + _rng.randf_range(profile.pause_min, profile.pause_max)


# --- Defesa: Campo Lento contra projéteis --------------------------------------

## Procura projéteis vindo no bot a cada `profile.threat_check_interval` s, só no grupo dos
## projéteis (production/perf/diagnostico-2026-11-17.md, item 6). Como antes, vale só o que está
## direto na cena principal.
func _react_to_threats(delta: float) -> void:
	_threat_timer -= delta
	if _threat_timer > 0.0:
		return
	_threat_timer = profile.threat_check_interval
	if _field == null or _field_cooldown > 0.0 or _mana < _field.cost:
		return
	var center := get_center()
	var scene := get_tree().current_scene
	for node in get_tree().get_nodes_in_group(MaterializedProjectile.GROUP):
		var projectile := node as MaterializedProjectile
		if projectile == null or projectile.get_parent() != scene or projectile.get_meta(&"caster", null) == self:
			continue
		var to_me := center - projectile.global_position
		var incoming := projectile.linear_velocity
		if to_me.length() > profile.threat_range or incoming.length() < 5.0:
			continue
		if incoming.normalized().dot(to_me.normalized()) < 0.9:
			continue
		var field := SlowField.new()
		field.radius = _field.radius
		field.duration = _field.base_duration * sqrt(stats.mult(_field.scaling_attribute))
		field.max_speed = _field.max_speed_inside
		field.gravity_factor = _field.gravity_factor
		get_tree().current_scene.add_child(field)
		field.global_position = projectile.global_position
		_mana -= _field.cost
		_field_cooldown = _field.cooldown
		return


func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var exclude: Array[RID] = [get_rid()]
	if target is CollisionObject3D:
		exclude.append((target as CollisionObject3D).get_rid())
	query.exclude = exclude
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	# Objetos soltos e personagens não bloqueiam a visão: só paredes e terreno.
	return hit.is_empty() or hit.collider is RigidBody3D or hit.collider is CharacterBody3D


# --- Visual (placeholder até termos arte) -------------------------------------

func _build() -> void:
	var shape := CylinderShape3D.new()
	shape.radius = BODY_RADIUS
	shape.height = BODY_HEIGHT
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = BODY_HEIGHT / 2.0
	add_child(collision)

	_visual = Node3D.new()
	add_child(_visual)
	_body_material = StandardMaterial3D.new()
	_body_material.albedo_color = class_data.color
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = BODY_RADIUS
	body_mesh.height = 1.45
	body_mesh.material = _body_material
	_add_mesh(body_mesh, Vector3(0, 0.73, 0))
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.17
	head_mesh.height = 0.34
	head_mesh.material = _body_material
	_add_mesh(head_mesh, Vector3(0, 1.62, 0))
	# Viseira escura: mostra para onde o bot está olhando.
	_add_mesh(_shared_visor_mesh(), Vector3(0, 1.65, -0.16))

	_orb = MeshInstance3D.new()
	_orb.mesh = _shared_orb_mesh()
	_orb.position = Vector3(0.28, 1.3, -0.45)
	_orb.visible = false
	add_child(_orb)

	_label = Label3D.new()
	_label.position.y = 2.25
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 40
	_label.pixel_size = 0.006
	_label.outline_size = 10
	_label.no_depth_test = true
	add_child(_label)


static func _shared_visor_mesh() -> BoxMesh:
	if _visor_mesh == null:
		_visor_mesh = BoxMesh.new()
		_visor_mesh.size = Vector3(0.24, 0.07, 0.06)
		var visor_material := StandardMaterial3D.new()
		visor_material.albedo_color = Color(0.05, 0.05, 0.08)
		_visor_mesh.material = visor_material
	return _visor_mesh


static func _shared_orb_mesh() -> SphereMesh:
	if _orb_mesh == null:
		_orb_mesh = SphereMesh.new()
		_orb_mesh.radius = 0.06
		_orb_mesh.height = 0.12
		var orb_material := StandardMaterial3D.new()
		orb_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb_material.albedo_color = KineticDartProjectile.COLOR
		_orb_mesh.material = orb_material
	return _orb_mesh


func _add_mesh(mesh: Mesh, at: Vector3) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	_visual.add_child(instance)


func _refresh_label() -> void:
	if _label == null or health == null:
		return
	_label.text = "%s\n%d / %d" % [SOURCE_NAME, ceili(health.current), roundi(health.max_health)]
	_label.modulate = Color(1, 1, 1).lerp(Color(1, 0.35, 0.3), 1.0 - health.current / health.max_health)

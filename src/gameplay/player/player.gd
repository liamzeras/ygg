class_name Player
extends CharacterBody3D
## Controle em primeira pessoa: movimento, câmera, pegar/arremessar objetos e habilidades.
## Os valores físicos vêm dos atributos da classe via AttributeRules (design/gdd/attributes.md).
## Ações do jogador são enfileiradas e executadas em _physics_process, onde
## consultas de física são seguras.

signal pool_changed(pool: Pool, current: float, maximum: float)
signal stats_changed
signal hint_changed(text: String, can_interact: bool)
signal action_failed(reason: String)
signal ability_used(slot: StringName)

## Vigor = esforço físico. Mana = magia. Todo personagem tem os dois.
enum Pool { STAMINA, MANA }

const POOL_NAMES := {Pool.STAMINA: "Vigor", Pool.MANA: "Mana"}
const SLOT_PRIMARY := &"primary"
const SLOT_MOBILITY := &"mobility"
const SLOT_SPECIAL := &"special"
const SLOT_AIR_JUMP := &"air_jump"
const ACTION_GRAB := &"grab"
const ACTION_JUMP := &"jump"
const SLOTS: Array[StringName] = [SLOT_PRIMARY, SLOT_MOBILITY, SLOT_SPECIAL]
const KILL_HEIGHT := -30.0
## Aumento do FOV ao correr (graus). Puramente visual.
const SPRINT_FOV_KICK := 6.0

@export var class_data: PlayerClassData
@export var rules: AttributeRules

var stats: DerivedStats
var held_body: RigidBody3D
## false enquanto um menu de depuração usa o mouse/teclado.
var input_enabled := true
## Trapaças do editor de testes.
var debug_infinite_resources := false
var debug_no_cooldowns := false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var _aim_ray: RayCast3D = $Head/Camera3D/AimRay
@onready var _hold_point: Marker3D = $Head/Camera3D/HoldPoint

var _pools := {Pool.STAMINA: 0.0, Pool.MANA: 0.0}
var _regen_wait := {Pool.STAMINA: 0.0, Pool.MANA: 0.0}
var _base_attributes: Attributes
var _pitch := 0.0
var _base_fov := 80.0
var _queued: Array[StringName] = []
var _cooldowns := {}
var _sprinting := false
var _wish := Vector3.ZERO
var _air_jump_used := false
var _hold := {}
var _dash_velocity := Vector3.ZERO
var _dash_time := 0.0
var _dash_impact := 0.0
var _dash_source := ""
var _dash_hits: Array[Object] = []
var _guard_time := 0.0
var _guard_reduction := 0.0
var _guard_speed := 1.0
var _shake := 0.0
var _hint := ""
var _spawn_point := Vector3.ZERO
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	if class_data == null:
		class_data = GameState.get_selected_class()
	if rules == null:
		rules = load("res://assets/data/attribute_rules.tres")
	# Cópia própria: o editor de testes mexe nos atributos sem alterar o .tres.
	class_data = class_data.duplicate(true)
	_base_attributes = class_data.attributes.duplicate()
	_recompute_stats()
	_pools[Pool.STAMINA] = stats.max_stamina
	_pools[Pool.MANA] = stats.max_mana
	_spawn_point = global_position
	_aim_ray.add_exception(self)
	Settings.changed.connect(_apply_settings)
	_apply_settings()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sensitivity: float = Settings.get_value("mouse_sensitivity")
		var invert := -1.0 if Settings.get_value("invert_y") else 1.0
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		_pitch = clampf(_pitch - event.relative.y * sensitivity * invert, -89.0, 89.0)
		head.rotation.x = deg_to_rad(_pitch)
	elif event.is_action_pressed("jump"):
		request_action(ACTION_JUMP)
	elif event.is_action_pressed("grab"):
		request_action(ACTION_GRAB)
	elif event.is_action_pressed("primary"):
		request_action(SLOT_PRIMARY)
	elif event.is_action_pressed("mobility"):
		request_action(SLOT_MOBILITY)
	elif event.is_action_pressed("special"):
		request_action(SLOT_SPECIAL)


## Enfileira uma ação (também usado pelos testes automatizados).
func request_action(action: StringName) -> void:
	_queued.append(action)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_air_jump_used = false
	_process_queue()
	_update_timers(delta)
	_move(delta)
	_update_held(delta)
	_update_pools(delta)
	_update_hint()
	if global_position.y < KILL_HEIGHT:
		respawn()


func _process(delta: float) -> void:
	var target_fov := _base_fov + (SPRINT_FOV_KICK if _sprinting else 0.0)
	camera.fov = lerpf(camera.fov, target_fov, 1.0 - exp(-8.0 * delta))
	_shake = maxf(_shake - delta * 1.5, 0.0)
	var amount := _shake * _shake if Settings.get_value("camera_shake") else 0.0
	camera.h_offset = randf_range(-1.0, 1.0) * amount * 0.15
	camera.v_offset = randf_range(-1.0, 1.0) * amount * 0.15


# --- API pública usada por habilidades, HUD, editor de testes e testes --------

func get_aim_origin() -> Vector3:
	return camera.global_position


func get_aim_direction() -> Vector3:
	return -camera.global_basis.z


func get_flat_forward() -> Vector3:
	var forward := -global_basis.z
	forward.y = 0.0
	return forward.normalized()


## Direção horizontal que o jogador está pedindo com WASD (zero se parado).
func get_move_direction() -> Vector3:
	return _wish


func get_ability(slot: StringName) -> Ability:
	match slot:
		SLOT_PRIMARY: return class_data.primary_ability
		SLOT_MOBILITY: return class_data.mobility_ability
		SLOT_SPECIAL: return class_data.special_ability
		SLOT_AIR_JUMP: return class_data.air_jump_ability
	return null


func get_cooldown(slot: StringName) -> float:
	return _cooldowns.get(slot, 0.0)



func get_pool(pool: Pool) -> float:
	return _pools[pool]


func get_pool_max(pool: Pool) -> float:
	return stats.max_stamina if pool == Pool.STAMINA else stats.max_mana


func is_air_jump_available() -> bool:
	return class_data.air_jump_ability != null and not _air_jump_used


func is_guarding() -> bool:
	return _guard_time > 0.0


func is_holding_telekinetically() -> bool:
	return is_instance_valid(held_body) and _hold.get("telekinetic", false)


## Corpo rígido na mira até `max_distance` metros, ou null.
func get_aimed_body(max_distance: float) -> RigidBody3D:
	if not _aim_ray.is_colliding():
		return null
	var body := _aim_ray.get_collider() as RigidBody3D
	if body == null or body.global_position.distance_to(get_aim_origin()) > max_distance:
		return null
	return body


## Muda um atributo em tempo real (editor de testes) e recalcula tudo.
func set_attribute(kind: Attributes.Kind, value: float) -> void:
	class_data.attributes.set_value(kind, value)
	_recompute_stats()


## Volta os atributos aos valores iniciais da classe.
func reset_attributes() -> void:
	class_data.attributes = _base_attributes.duplicate()
	_recompute_stats()


## Começa a segurar `body`. `profile`: telekinetic, distance, stiffness, throw_speed, carry_mass, drain.
func hold(body: RigidBody3D, profile: Dictionary) -> void:
	release_held()
	if body == null:
		return
	held_body = body
	_hold = profile
	_hold_point.position = Vector3(0, 0, -float(profile["distance"]))
	add_collision_exception_with(body)
	body.add_collision_exception_with(self)


func release_held() -> void:
	if is_instance_valid(held_body):
		remove_collision_exception_with(held_body)
		held_body.remove_collision_exception_with(self)
	held_body = null
	_hold = {}


## Tenta usar a habilidade do slot. Retorna true se ela foi ativada.
func use_ability(slot: StringName) -> bool:
	var ability := get_ability(slot)
	if ability == null:
		return false
	if ability.toggles_off(self):
		ability.activate(self)
		return true
	if get_cooldown(slot) > 0.0:
		action_failed.emit("Recarregando")
		return false
	if get_pool(ability.cost_pool) < ability.cost and not debug_infinite_resources:
		action_failed.emit("%s insuficiente" % POOL_NAMES[ability.cost_pool])
		return false
	var reason := ability.get_block_reason(self)
	if reason != "":
		action_failed.emit(reason)
		return false
	spend(ability.cost_pool, ability.cost)
	if not debug_no_cooldowns:
		_cooldowns[slot] = ability.cooldown
	ability.activate(self)
	ability_used.emit(slot)
	return true


func spend(pool: Pool, amount: float) -> void:
	if not debug_infinite_resources:
		_pools[pool] = maxf(_pools[pool] - amount, 0.0)
	_regen_wait[pool] = class_data.regen_delay


func start_dash(dash_velocity: Vector3, duration: float, impact: float, source: String) -> void:
	_dash_velocity = dash_velocity
	_dash_time = duration
	_dash_impact = impact
	_dash_source = source
	_dash_hits.clear()


func start_guard(duration: float, reduction: float, speed_factor: float) -> void:
	_guard_time = duration
	_guard_reduction = reduction
	_guard_speed = speed_factor


## Recebe um empurrão (N·s). A velocidade muda conforme a massa do personagem.
func apply_knockback(impulse: Vector3) -> void:
	if is_guarding():
		impulse *= 1.0 - _guard_reduction
	velocity += impulse / class_data.body_mass
	add_shake(clampf(impulse.length() / 400.0, 0.0, 0.6))


func add_shake(amount: float) -> void:
	_shake = minf(_shake + amount, 1.0)


## Vira a câmera para um ponto do mundo (usado pelos testes).
func face_point(point: Vector3) -> void:
	var to := point - get_aim_origin()
	rotation.y = atan2(-to.x, -to.z)
	_pitch = rad_to_deg(atan2(to.y, Vector2(to.x, to.z).length()))
	head.rotation.x = deg_to_rad(_pitch)


func respawn() -> void:
	release_held()
	global_position = _spawn_point
	velocity = Vector3.ZERO


# --- Interno ------------------------------------------------------------------

func _recompute_stats() -> void:
	stats = rules.derive(class_data.attributes)
	_pools[Pool.STAMINA] = minf(_pools[Pool.STAMINA], stats.max_stamina)
	_pools[Pool.MANA] = minf(_pools[Pool.MANA], stats.max_mana)
	stats_changed.emit()


func _apply_settings() -> void:
	_base_fov = float(Settings.get_value("fov"))


func _process_queue() -> void:
	for action in _queued:
		match action:
			ACTION_JUMP:
				_jump()
			ACTION_GRAB:
				_toggle_hands()
			SLOT_PRIMARY:
				if is_instance_valid(held_body):
					_throw()
				else:
					use_ability(SLOT_PRIMARY)
			_:
				use_ability(action)
	_queued.clear()


func _jump() -> void:
	if _dash_time > 0.0:
		return
	if is_on_floor():
		velocity.y = sqrt(2.0 * _gravity * stats.jump_height)
	elif is_air_jump_available() and use_ability(SLOT_AIR_JUMP):
		_air_jump_used = true


func _update_timers(delta: float) -> void:
	for slot in _cooldowns.keys():
		_cooldowns[slot] = maxf(_cooldowns[slot] - delta, 0.0)
	_guard_time = maxf(_guard_time - delta, 0.0)


func _move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") if input_enabled else Vector2.ZERO
	var wish := global_basis * Vector3(input.x, 0.0, input.y)
	wish.y = 0.0
	_wish = wish.normalized() * minf(input.length(), 1.0)
	var wants_sprint := input_enabled and Input.is_action_pressed("sprint")
	_sprinting = wants_sprint and input.length() > 0.1 and get_pool(Pool.STAMINA) > 0.0 and not is_guarding()

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity.x = _dash_velocity.x
		velocity.z = _dash_velocity.z
	else:
		var speed := stats.sprint_speed if _sprinting else stats.walk_speed
		if is_guarding():
			speed *= _guard_speed
		# No ar sem input, mantém o embalo (pulos não "freiam").
		if is_on_floor() or input.length() > 0.1:
			var accel := class_data.acceleration * (1.0 if is_on_floor() else class_data.air_control)
			var horizontal := Vector2(velocity.x, velocity.z).lerp(Vector2(_wish.x, _wish.z) * speed, clampf(accel * delta, 0.0, 1.0))
			velocity.x = horizontal.x
			velocity.z = horizontal.y

	move_and_slide()
	_push_bodies(delta)


func _push_bodies(delta: float) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if _dash_time > 0.0 and collider and not _dash_hits.has(collider):
			_dash_hits.append(collider)
			var direction := (_dash_velocity.normalized() + Vector3.UP * 0.3).normalized()
			if collider is RigidBody3D:
				(collider as RigidBody3D).apply_central_impulse(direction * _dash_impact)
			if collider.has_method("register_hit"):
				collider.register_hit(_dash_source, _dash_impact)
			add_shake(0.4)
			continue
		var body := collider as RigidBody3D
		if body == null or body == held_body or collision.get_normal().y > 0.7:
			continue
		var push := -collision.get_normal()
		push.y = 0.0
		body.apply_central_impulse(push.normalized() * stats.push_force * delta)


func _toggle_hands() -> void:
	if is_instance_valid(held_body):
		release_held()
		return
	var body := get_aimed_body(class_data.hand_range)
	if body == null:
		return
	if body.mass > stats.carry_mass:
		action_failed.emit("Pesado demais (%d kg)" % roundi(body.mass))
		return
	hold(body, {
		"telekinetic": false,
		"distance": class_data.hold_distance,
		"stiffness": stats.hold_stiffness,
		"throw_speed": stats.throw_speed,
		"carry_mass": stats.carry_mass,
		"drain": 0.0,
	})


func _throw() -> void:
	var body := held_body
	var throw_speed: float = _hold["throw_speed"]
	var carry: float = _hold["carry_mass"]
	release_held()
	# Objetos perto do limite de carga saem mais devagar.
	var mass_factor := clampf(1.0 - body.mass / (carry * 1.5), 0.3, 1.0)
	body.linear_velocity = get_aim_direction() * throw_speed * mass_factor + velocity * 0.5
	add_shake(0.1)


func _update_held(delta: float) -> void:
	if not is_instance_valid(held_body):
		if not _hold.is_empty():
			release_held()
		return
	var drain: float = _hold["drain"]
	if drain > 0.0:
		if get_pool(Pool.MANA) <= 0.0:
			release_held()
			action_failed.emit("Mana esgotada")
			return
		spend(Pool.MANA, drain * delta)
	var to_target := _hold_point.global_position - held_body.global_position
	if to_target.length() > float(_hold["distance"]) + 2.5:
		release_held()
		return
	held_body.linear_velocity = to_target * float(_hold["stiffness"])
	held_body.angular_velocity = held_body.angular_velocity.lerp(Vector3.ZERO, clampf(10.0 * delta, 0.0, 1.0))


func _update_pools(delta: float) -> void:
	if _sprinting and Vector2(velocity.x, velocity.z).length() > 0.5:
		spend(Pool.STAMINA, class_data.sprint_cost * delta)
	for pool: Pool in [Pool.STAMINA, Pool.MANA]:
		if _regen_wait[pool] > 0.0:
			_regen_wait[pool] -= delta
		else:
			var regen := stats.stamina_regen if pool == Pool.STAMINA else stats.mana_regen
			_pools[pool] = minf(_pools[pool] + regen * delta, get_pool_max(pool))
		pool_changed.emit(pool, _pools[pool], get_pool_max(pool))


func _update_hint() -> void:
	var text := ""
	var can_interact := false
	if is_instance_valid(held_body):
		text = "[%s] Arremessar   [%s] Soltar" % [InputBindings.label("primary"),
				InputBindings.label("special") if _hold.get("telekinetic", false) else InputBindings.label("grab")]
	else:
		var body := get_aimed_body(class_data.hand_range)
		if body:
			var label := String(body.call("get_display_name")) if body.has_method("get_display_name") else String(body.name)
			if body.mass > stats.carry_mass:
				text = "%s (%d kg) — pesado demais" % [label, roundi(body.mass)]
			else:
				text = "[%s] Pegar %s (%d kg)" % [InputBindings.label("grab"), label, roundi(body.mass)]
				can_interact = true
	if text != _hint:
		_hint = text
		hint_changed.emit(text, can_interact)

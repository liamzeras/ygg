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
signal floating_changed(active: bool)
## O kit mudou (trava da Zona Nula entrou ou saiu): o HUD refaz a lista de habilidades.
signal abilities_changed

## Vigor = esforço físico. Mana = magia. Todo personagem tem os dois.
enum Pool { STAMINA, MANA }

const POOL_NAMES := {Pool.STAMINA: "Vigor", Pool.MANA: "Mana"}
const SLOT_PRIMARY := &"primary"
const SLOT_MOBILITY := &"mobility"
const SLOT_SPECIAL := &"special"
## Botão direito.
const SLOT_SECONDARY := &"secondary"
## Ctrl (era o dash; o dash saiu de todas as classes por enquanto, design/gdd/mage-earth.md).
const SLOT_UTILITY := &"utility"
const SLOT_AIR_JUMP := &"air_jump"
const SLOT_FLOAT := &"float"
const ACTION_GRAB := &"grab"
const EFFECT_JUMP := &"jump"
const EFFECT_HASTE := &"haste"
const EFFECT_WEIGHT := &"weight"
const ACTION_JUMP := &"jump"
## Soltar o botão esquerdo: dispara uma habilidade carregável.
const ACTION_PRIMARY_RELEASE := &"primary_release"
const SLOTS: Array[StringName] = [SLOT_PRIMARY, SLOT_SECONDARY, SLOT_MOBILITY, SLOT_SPECIAL, SLOT_UTILITY]
const KILL_HEIGHT := -30.0
## Aumento do FOV ao correr (graus). Puramente visual.
const SPRINT_FOV_KICK := 6.0
## Folga extra (m) ao testar a subida de degraus. Não muda a altura máxima do degrau.
const STEP_CLEARANCE := 0.05
## Distância (m) além do passo do quadro em que já se procura o próximo degrau.
const STEP_LOOKAHEAD := 0.05
## Quanto (m) a borda do corpo precisa passar da quina para contar como apoiada.
const STEP_OVERLAP := 0.03
## Folga (m) acima do degrau ao subir, para a base do corpo não raspar na quina.
const STEP_SKIN := 0.005
## Tempo máximo (s) sem gravidade esperando chegar ao degrau, caso o jogador pare.
const STEP_HANG_MAX_TIME := 0.2
## Tamanho do corpo (igual à colisão em player.tscn).
const BODY_HEIGHT := 1.8
const BODY_RADIUS := 0.35

@export var class_data: PlayerClassData
@export var rules: AttributeRules

var stats: DerivedStats
var held_body: RigidBody3D
## false enquanto um menu de depuração usa o mouse/teclado. Desligar cancela a carga.
var input_enabled := true:
	set(value):
		input_enabled = value
		if not value:
			cancel_charge()
## Testes automatizados: finge que Espaço está pressionado (para o flutuar).
var force_jump_held := false
## Trapaças do editor de testes.
var debug_infinite_resources := false
var debug_no_cooldowns := false
## Nível do personagem (1 a rules.max_level). Define quantos pontos ele pode distribuir.
var level := 1

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var _aim_ray: RayCast3D = $Head/Camera3D/AimRay
@onready var _hold_point: Marker3D = $Head/Camera3D/HoldPoint

var _pools := {Pool.STAMINA: 0.0, Pool.MANA: 0.0}
var _regen_wait := {Pool.STAMINA: 0.0, Pool.MANA: 0.0}
var _base_attributes: Attributes
var _base_level := 1
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
var _shake := 0.0
var _charging := false
var _charge := 0.0
var _charge_hold := 0.0
var _tremor_phase := 0.0
var _flight_time := 0.0
var _flight_speed := 0.0
var _floating := false
var _float_blocked := false
var _float_fx: CPUParticles3D
var _takeoff_y := 0.0
var _speed_effects := {}
var _effects := {}
var _ability_locks := {}
var _dash_vertical := false
## Suaviza a câmera ao subir um degrau (o corpo sobe na hora, a visão acompanha).
var _step_offset := 0.0
var _step_offset_speed := 0.0
var _step_hang_distance := 0.0
var _step_hang_time := 0.0
@onready var _floor_snap_length := floor_snap_length
var _head_base_y := 0.0
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
	# Build de teste da classe: o menor nível que paga os atributos dela.
	_base_level = rules.level_for_build(_base_attributes)
	level = _base_level
	_recompute_stats()
	_pools[Pool.STAMINA] = stats.max_stamina
	_pools[Pool.MANA] = stats.max_mana
	_spawn_point = global_position
	_takeoff_y = global_position.y
	_head_base_y = head.position.y
	# Terreno (pilar, lama) encontra personagens por este grupo.
	add_to_group(&"characters")
	_aim_ray.add_exception(self)
	if class_data.float_ability:
		_float_fx = Fx.make_float_wisps()
		add_child(_float_fx)
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
	elif event.is_action_released("primary"):
		request_action(ACTION_PRIMARY_RELEASE)
	elif event.is_action_pressed("mobility"):
		request_action(SLOT_MOBILITY)
	elif event.is_action_pressed("secondary"):
		request_action(SLOT_SECONDARY)
	elif event.is_action_pressed("utility"):
		request_action(SLOT_UTILITY)
	elif event.is_action_pressed("special"):
		request_action(SLOT_SPECIAL)


## Enfileira uma ação (também usado pelos testes automatizados).
func request_action(action: StringName) -> void:
	_queued.append(action)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_air_jump_used = false
		_takeoff_y = global_position.y
	_process_queue()
	_update_timers(delta)
	_update_charge(delta)
	_update_float(delta)
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
	_update_step_camera(delta)
	head.position.y = _head_base_y + _step_offset
	var amount := _shake * _shake if Settings.get_value("camera_shake") else 0.0
	camera.h_offset = randf_range(-1.0, 1.0) * amount * 0.15
	camera.v_offset = randf_range(-1.0, 1.0) * amount * 0.15
	# Tremor da mira ao segurar a carga cheia por tempo demais (gira a câmera de verdade).
	var tremor := deg_to_rad(get_charge_tremor())
	if tremor > 0.0:
		_tremor_phase += delta
		camera.rotation = Vector3(
				sin(_tremor_phase * 6.1) * tremor + sin(_tremor_phase * 13.7) * tremor * 0.3,
				sin(_tremor_phase * 4.7) * tremor, 0.0)
	else:
		camera.rotation = camera.rotation.lerp(Vector3.ZERO, clampf(10.0 * delta, 0.0, 1.0))


func _notification(what: int) -> void:
	# Pausa no meio da carga: o "soltar" nunca chegaria, então cancela sem gastar.
	if what == NOTIFICATION_PAUSED:
		cancel_charge()


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
	# Com o kit travado (Zona Nula), só vale o que a trava oferece para este espaço.
	if not _ability_locks.is_empty():
		var overrides: Dictionary = _ability_locks.values().back()
		return overrides.get(slot) as Ability
	match slot:
		SLOT_PRIMARY: return class_data.primary_ability
		SLOT_MOBILITY: return class_data.mobility_ability
		SLOT_SPECIAL: return class_data.special_ability
		SLOT_SECONDARY: return class_data.secondary_ability
		SLOT_UTILITY: return class_data.utility_ability
		SLOT_AIR_JUMP: return class_data.air_jump_ability
		SLOT_FLOAT: return class_data.float_ability
	return null


func get_cooldown(slot: StringName) -> float:
	return _cooldowns.get(slot, 0.0)



func get_pool(pool: Pool) -> float:
	return _pools[pool]


func get_pool_max(pool: Pool) -> float:
	return stats.max_stamina if pool == Pool.STAMINA else stats.max_mana


func is_air_jump_available() -> bool:
	return class_data.air_jump_ability != null and not _air_jump_used


## Nenhuma classe tem postura de guarda desde que o Cavaleiro saiu (2026-11-16).
## Fica só porque o hud.gd ainda lê; remover junto com o rótulo "EM GUARDA" do HUD.
func is_guarding() -> bool:
	return false


func is_charging() -> bool:
	return _charging


## Carga atual da habilidade principal (0 a 1).
func get_charge() -> float:
	return _charge if _charging else 0.0


## Graus de tremor da mira agora (0 = firme). Destreza reduz.
func get_charge_tremor() -> float:
	if not _charging:
		return 0.0
	var ability := get_ability(SLOT_PRIMARY)
	if _charge_hold < get_charge_time() + ability.tremor_delay:
		return 0.0
	return ability.tremor_degrees / stats.mult(Attributes.Kind.DEXTERITY)


## Segundos até a carga cheia do botão esquerdo, já com a velocidade de ataque (Agilidade).
func get_charge_time() -> float:
	var ability := get_ability(SLOT_PRIMARY)
	return ability.charge_time / stats.attack_speed if ability else 0.0


## Interrompe a carga sem gastar nada.
func cancel_charge() -> void:
	_charging = false
	_charge = 0.0
	_charge_hold = 0.0


func is_floating() -> bool:
	return _floating


## Voo temporário (Jatos de Fogo, design/gdd/mage-fire.md): por `duration` s não há
## gravidade, o corpo anda para onde a câmera aponta a `speed` m/s e Espaço sobe.
func start_flight(duration: float, speed: float) -> void:
	_flight_time = duration
	_flight_speed = speed
	velocity.y = maxf(velocity.y, 0.0)


func stop_flight() -> void:
	_flight_time = 0.0


func is_flying() -> bool:
	return _flight_time > 0.0


## Segundos de voo restantes.
func get_flight_time() -> float:
	return _flight_time


## Efeito de terreno na velocidade de movimento (ex.: lama x0,5). Vale o mais forte.
func set_speed_effect(source: Object, factor: float) -> void:
	_speed_effects[source] = factor


func clear_speed_effect(source: Object) -> void:
	_speed_effects.erase(source)


## Multiplicador atual da velocidade de movimento (1 = normal).
func get_speed_factor() -> float:
	var factor := 1.0
	for value: float in _speed_effects.values():
		factor = minf(factor, value)
	return factor


## Efeitos temporários de outras fontes (ex.: Gravidade dos Sonhos). Tipos: EFFECT_JUMP
## (altura do pulo), EFFECT_HASTE (recargas mais curtas) e EFFECT_WEIGHT (gravidade).
## Fator 1 = normal; vale o mais forte de cada tipo.
func set_effect(kind: StringName, source: Object, factor: float) -> void:
	if not _effects.has(kind):
		_effects[kind] = {}
	_effects[kind][source] = factor


func clear_effect(kind: StringName, source: Object) -> void:
	if _effects.has(kind):
		_effects[kind].erase(source)


func get_effect(kind: StringName) -> float:
	var factor := 1.0
	for value: float in _effects.get(kind, {}).values():
		factor = maxf(factor, value)
	return factor


## Trava o kit (Zona Nula, design/gdd/mage-gravity.md): enquanto houver trava, cada espaço
## só tem a habilidade que `overrides` oferecer ({espaço: Ability}); vazio = nenhuma.
func set_ability_lock(source: Object, overrides: Dictionary) -> void:
	_ability_locks[source] = overrides
	cancel_charge()
	abilities_changed.emit()


func clear_ability_lock(source: Object) -> void:
	if _ability_locks.erase(source):
		abilities_changed.emit()


func is_ability_locked() -> bool:
	return not _ability_locks.is_empty()


## Altura (y) do último chão em que o jogador pisou. Base do teto do pulo duplo.
func get_takeoff_height() -> float:
	return _takeoff_y


## Gravidade do personagem (m/s²), sem efeitos de área.
func gravity_strength() -> float:
	return _gravity


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
	level = _base_level
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
## `charge` (0 a 1) só vale para habilidades carregáveis; -1 = sem carga.
func use_ability(slot: StringName, charge := -1.0) -> bool:
	var ability := get_ability(slot)
	if ability == null:
		return false
	if ability.toggles_off(self):
		ability.activate(self)
		return true
	var cost := ability.cost_at(maxf(charge, 0.0)) if charge >= 0.0 else ability.cost
	if not _can_start(slot, ability, cost):
		return false
	spend(ability.cost_pool, cost)
	if not debug_no_cooldowns:
		_cooldowns[slot] = ability.cooldown / ((stats.attack_speed if slot == SLOT_PRIMARY else 1.0) * get_effect(EFFECT_HASTE))
	if charge >= 0.0:
		ability.activate_charged(self, charge)
	else:
		ability.activate(self)
	ability_used.emit(slot)
	return true


func spend(pool: Pool, amount: float) -> void:
	if not debug_infinite_resources:
		_pools[pool] = maxf(_pools[pool] - amount, 0.0)
	_regen_wait[pool] = class_data.regen_delay


## Devolve recurso (ex.: golpe de graça), sem passar do máximo.
func refund(pool: Pool, amount: float) -> void:
	_pools[pool] = minf(_pools[pool] + amount, get_pool_max(pool))


## `vertical`: a arrancada também leva a componente vertical de `dash_velocity` (Gravidash).
func start_dash(dash_velocity: Vector3, duration: float, impact: float, source: String, vertical := false) -> void:
	_dash_vertical = vertical
	_dash_velocity = dash_velocity
	_dash_time = duration
	_dash_impact = impact
	_dash_source = source
	_dash_hits.clear()


## Pontos ainda não distribuídos (negativo = build de teste acima do que o nível paga).
func get_free_points() -> int:
	return rules.points_at_level(level) - rules.spent_points(class_data.attributes)


## Muda o nível sem mexer nos atributos: os pontos livres sobem ou descem junto.
func set_level(value: int) -> void:
	level = clampi(value, 1, rules.max_level)
	stats_changed.emit()


## Sobe um nível. Retorna false se já estiver no máximo.
func level_up() -> bool:
	if level >= rules.max_level:
		return false
	set_level(level + 1)
	return true


## Gasta um ponto livre em um atributo, respeitando o teto base.
func raise_attribute(kind: Attributes.Kind) -> bool:
	var value := class_data.attributes.get_value(kind)
	if get_free_points() <= 0 or value >= rules.base_cap:
		return false
	set_attribute(kind, value + 1.0)
	return true


## Distância de um ponto até a superfície do corpo (ver DamageRules.distance_to).
func surface_distance(point: Vector3) -> float:
	return DamageRules.capsule_distance(global_position, BODY_HEIGHT, BODY_RADIUS, point)


## Centro do corpo (a origem do nó fica nos pés).
func get_center() -> Vector3:
	return global_position + Vector3.UP * BODY_HEIGHT / 2.0


## Recebe um empurrão (N·s). A velocidade muda conforme a massa do personagem.
func apply_knockback(impulse: Vector3) -> void:
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
	stop_flight()
	global_position = _spawn_point
	_takeoff_y = _spawn_point.y
	velocity = Vector3.ZERO


# --- Interno ------------------------------------------------------------------

func _recompute_stats() -> void:
	stats = rules.derive(class_data.attributes)
	_pools[Pool.STAMINA] = minf(_pools[Pool.STAMINA], stats.max_stamina)
	_pools[Pool.MANA] = minf(_pools[Pool.MANA], stats.max_mana)
	stats_changed.emit()


func _apply_settings() -> void:
	_base_fov = float(Settings.get_value("fov"))


## Checa recarga, recurso e bloqueios; avisa o motivo se não puder.
func _can_start(slot: StringName, ability: Ability, cost: float) -> bool:
	if get_cooldown(slot) > 0.0:
		action_failed.emit("Recarregando")
		return false
	if get_pool(ability.cost_pool) < cost and not debug_infinite_resources:
		action_failed.emit("%s insuficiente" % POOL_NAMES[ability.cost_pool])
		return false
	var reason := ability.get_block_reason(self)
	if reason != "":
		action_failed.emit(reason)
		return false
	return true


func _process_queue() -> void:
	for action in _queued:
		match action:
			ACTION_JUMP:
				_jump()
			ACTION_GRAB:
				# E pega; segurando qualquer coisa, E arremessa.
				if is_instance_valid(held_body):
					_throw()
				elif get_ability(ACTION_GRAB):
					# Kit travado com um agarrar próprio (Zona Nula).
					use_ability(ACTION_GRAB)
				else:
					_grab()
			SLOT_PRIMARY:
				if is_instance_valid(held_body):
					# O botão esquerdo só arremessa o que a Telecinese segura; com as mãos, é o E.
					if _hold.get("telekinetic", false):
						_throw()
				elif get_ability(SLOT_PRIMARY) and get_ability(SLOT_PRIMARY).is_chargeable():
					_start_charge()
				else:
					use_ability(SLOT_PRIMARY)
			ACTION_PRIMARY_RELEASE:
				if _charging:
					var charge := _charge
					cancel_charge()
					use_ability(SLOT_PRIMARY, charge)
			_:
				if action == SLOT_SPECIAL:
					cancel_charge()
				use_ability(action)
	_queued.clear()


# Carga (design/gdd/mage-psionic.md, Dardo Cinético): começa ao apertar, sobe com o
# tempo até 1 e para no valor que o recurso paga. O custo é pago só ao soltar.
func _start_charge() -> void:
	var ability := get_ability(SLOT_PRIMARY)
	if not _can_start(SLOT_PRIMARY, ability, ability.cost_at(0.0)):
		return
	_charging = true
	_charge = 0.0
	_charge_hold = 0.0


func _update_charge(delta: float) -> void:
	if not _charging:
		return
	var ability := get_ability(SLOT_PRIMARY)
	var budget := INF if debug_infinite_resources else get_pool(ability.cost_pool)
	if budget < ability.cost_at(0.0):
		cancel_charge()
		action_failed.emit("%s insuficiente" % POOL_NAMES[ability.cost_pool])
		return
	_charge_hold += delta
	_charge = minf(minf(_charge_hold / get_charge_time(), 1.0), ability.max_charge_for(budget))


# Flutuar (design/gdd/mage-psionic.md): só descendo, segurando Espaço. Mana zerada
# encerra e exige soltar Espaço antes de tentar de novo.
func _update_float(delta: float) -> void:
	var ability := class_data.float_ability
	if ability == null:
		return
	var held := force_jump_held or (input_enabled and Input.is_action_pressed("jump"))
	if not held:
		_float_blocked = false
	var wants := held and not _float_blocked and not is_on_floor() and velocity.y <= 0.0 and _dash_time <= 0.0
	if wants and not _floating:
		if get_pool(Pool.MANA) < ability.cost and not debug_infinite_resources:
			_float_blocked = true
			action_failed.emit("%s insuficiente" % POOL_NAMES[Pool.MANA])
		else:
			_set_floating(true)
	elif _floating and not wants:
		_set_floating(false)
	if not _floating:
		return
	if get_pool(Pool.MANA) <= 0.0 and not debug_infinite_resources:
		_set_floating(false)
		_float_blocked = true
		action_failed.emit("Mana esgotada")
		return
	spend(Pool.MANA, ability.drain_per_second(self) * delta)


func _set_floating(active: bool) -> void:
	if _floating == active:
		return
	_floating = active
	if _float_fx:
		_float_fx.emitting = active
	floating_changed.emit(active)


func _jump() -> void:
	# Voando, Espaço é "subir" (ver _move_flying), não pulo.
	if _dash_time > 0.0 or is_flying():
		return
	if is_on_floor() or _step_hang_time > 0.0:
		_step_hang_time = 0.0
		velocity.y = sqrt(2.0 * _gravity * stats.jump_height * get_effect(EFFECT_JUMP))
	elif is_air_jump_available() and use_ability(SLOT_AIR_JUMP):
		_air_jump_used = true


func _update_timers(delta: float) -> void:
	for slot in _cooldowns.keys():
		_cooldowns[slot] = maxf(_cooldowns[slot] - delta, 0.0)


## Movimento durante o voo: sem gravidade, na direção da câmera (com inclinação); Espaço sobe.
func _move_flying(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") if input_enabled else Vector2.ZERO
	var wish := camera.global_basis * Vector3(input.x, 0.0, input.y)
	if force_jump_held or (input_enabled and Input.is_action_pressed("jump")):
		wish += Vector3.UP
	wish = wish.limit_length(1.0)
	_wish = Vector3(wish.x, 0.0, wish.z)
	_sprinting = false
	velocity = velocity.lerp(wish * _flight_speed * get_speed_factor(), clampf(class_data.acceleration * delta, 0.0, 1.0))
	move_and_slide()
	_push_bodies(delta)
	_flight_time = maxf(_flight_time - delta, 0.0)


func _move(delta: float) -> void:
	if is_flying():
		_move_flying(delta)
		return
	if not is_on_floor() and _step_hang_time <= 0.0:
		velocity.y -= _gravity * get_effect(EFFECT_WEIGHT) * delta
	if _floating:
		velocity.y = maxf(velocity.y, -class_data.float_ability.max_fall_speed)

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") if input_enabled else Vector2.ZERO
	var wish := global_basis * Vector3(input.x, 0.0, input.y)
	wish.y = 0.0
	_wish = wish.normalized() * minf(input.length(), 1.0)
	var wants_sprint := input_enabled and Input.is_action_pressed("sprint")
	_sprinting = wants_sprint and input.length() > 0.1 and get_pool(Pool.STAMINA) > 0.0

	if _dash_time > 0.0:
		velocity.x = _dash_velocity.x
		velocity.z = _dash_velocity.z
		if _dash_vertical:
			velocity.y = _dash_velocity.y
	else:
		var speed := stats.sprint_speed if _sprinting else stats.walk_speed
		speed *= get_speed_factor()
		# No ar sem input, mantém o embalo (pulos não "freiam").
		if is_on_floor() or input.length() > 0.1:
			var accel := class_data.acceleration * (1.0 if is_on_floor() or _floating or _step_hang_time > 0.0 else class_data.air_control)
			var horizontal := Vector2(velocity.x, velocity.z).lerp(Vector2(_wish.x, _wish.z) * speed, clampf(accel * delta, 0.0, 1.0))
			velocity.x = horizontal.x
			velocity.z = horizontal.y

	var was_dashing := _dash_time > 0.0
	var was_hanging := _step_hang_time > 0.0
	_step_up(delta)
	# Durante a subida, grudar no chão puxaria o corpo para dentro da quina do degrau.
	floor_snap_length = 0.0 if _step_hang_time > 0.0 else _floor_snap_length
	move_and_slide()
	_push_bodies(delta)
	if was_hanging:
		_step_hang_time -= delta
		_step_hang_distance -= get_position_delta().length()
		if is_on_floor() or _step_hang_distance <= 0.0:
			_step_hang_time = 0.0
			# Pousa já: caindo esses milímetros, o próximo degrau chegaria com o corpo fora do chão.
			floor_snap_length = _floor_snap_length
			apply_floor_snap()
	if was_dashing:
		_dash_time -= delta
		if _dash_time <= 0.0:
			_end_dash()


## Sobe degraus de até `rules.step_height` só andando (escadas, meio-fio, caixotes baixos),
## ou até `auto_climb_height` de quem tiver essa propriedade, segurando W.
## Testa: bloqueado à frente → sobe a altura do degrau → anda → desce até achar chão.
## Só sobe se encontrar chão firme (não uma parede ou rampa íngreme) no fim.
func _step_up(delta: float) -> void:
	if not is_on_floor() or velocity.y > 0.0:
		return
	var horizontal := Vector3(velocity.x, 0.0, velocity.z) * delta
	if horizontal.length() < 0.001:
		return
	# Sobe um pouco antes de encostar, para não perder velocidade batendo no degrau.
	var direction := horizontal.normalized()
	var probe := horizontal + direction * STEP_LOOKAHEAD
	var start := global_transform
	var blocker := KinematicCollision3D.new()
	if not test_move(start, probe, blocker):
		return
	# Objetos soltos são empurrados, não escalados.
	if blocker.get_collider() is RigidBody3D:
		return
	var max_step := rules.step_height
	# Degraus com subida automática (Escada de Pedra): sobem segurando para a frente.
	var climbable := blocker.get_collider()
	if "auto_climb_height" in climbable and input_enabled and Input.is_action_pressed("move_forward"):
		max_step = maxf(max_step, climbable.auto_climb_height)
	# Sobe um pouco além do degrau: na altura exata, a base do cilindro
	# raspa na quina e o teste de andar falharia.
	var up := Vector3.UP * (max_step + STEP_CLEARANCE)
	var ceiling := KinematicCollision3D.new()
	if test_move(start, up, ceiling) and ceiling.get_normal().y < -0.5:
		return
	var raised := start.translated(up)
	# Confere o pouso já com a borda do corpo sobre o degrau.
	var gap := blocker.get_travel().length()
	var over_step := direction * (gap + STEP_OVERLAP)
	if test_move(raised, over_step):
		return
	var landing := KinematicCollision3D.new()
	var moved := raised.translated(over_step)
	if not test_move(moved, -up, landing):
		return
	# A borda da base pode pousar na quina (normal inclinada); confere a superfície logo
	# depois da quina com um raio para baixo: só sobe se ali for chão, não rampa íngreme.
	if landing.get_normal().y <= 0.0:
		return
	var contact := landing.get_position() + direction * 0.03
	var ray := PhysicsRayQueryParameters3D.create(contact + Vector3.UP * 0.1, contact + Vector3.DOWN * 0.2)
	ray.exclude = [get_rid()]
	var surface := get_world_3d().direct_space_state.intersect_ray(ray)
	if surface.is_empty() or (surface.normal as Vector3).angle_to(Vector3.UP) > floor_max_angle:
		return
	# Só sobe: quem anda para a frente é move_and_slide. Somar o avanço aqui acelerava a cada degrau.
	var new_height := moved.origin.y + landing.get_travel().y + STEP_SKIN
	var rise := new_height - global_position.y
	if rise <= 0.01 + STEP_SKIN or rise > max_step + 0.01 + STEP_SKIN:
		return
	global_position.y = new_height
	# Até a borda do corpo chegar ao degrau, não há chão embaixo: sem gravidade nesse trecho,
	# ou o corpo cairia contra a parede do degrau e perderia o ritmo.
	_step_hang_distance = gap + STEP_OVERLAP
	_step_hang_time = STEP_HANG_MAX_TIME
	_step_offset -= rise


## Câmera acompanha os degraus com uma mola sem oscilação: degraus seguidos viram uma subida
## contínua, em vez de um tranco para cada um (mesma fórmula do SmoothDamp).
func _update_step_camera(delta: float) -> void:
	var omega := 2.0 / rules.step_camera_time
	var x := omega * delta
	var decay := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var pull := (_step_offset_speed + omega * _step_offset) * delta
	_step_offset_speed = (_step_offset_speed - omega * pull) * decay
	var next := (_step_offset + pull) * decay
	# Limite de velocidade: um degrau alto sobe por um instante, em vez de saltar de uma vez.
	_step_offset = move_toward(_step_offset, next, rules.step_camera_max_speed * delta)


## Acaba o dash: o excesso de velocidade some (senão, no ar, ele continuaria voando).
func _end_dash() -> void:
	_dash_time = 0.0
	if _dash_vertical:
		velocity.y = clampf(velocity.y, -stats.sprint_speed, stats.sprint_speed * 0.5)
		_dash_vertical = false
	var horizontal := Vector2(velocity.x, velocity.z).limit_length(stats.sprint_speed)
	velocity.x = horizontal.x
	velocity.z = horizontal.y


func _push_bodies(delta: float) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var is_floor_contact := collision.get_normal().y > 0.7
		if _dash_time > 0.0 and collider and not is_floor_contact and not _dash_hits.has(collider):
			_dash_hits.append(collider)
			var direction := (_dash_velocity.normalized() + Vector3.UP * 0.3).normalized()
			# De frente com algo que não cede: para o dash em vez de ficar forçando.
			if not collider is RigidBody3D and collision.get_normal().dot(_dash_velocity.normalized()) < -0.7:
				_end_dash()
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


func _grab() -> void:
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
	var throw_cost: float = _hold.get("throw_cost", 0.0)
	if throw_cost > 0.0:
		if get_pool(Pool.MANA) < throw_cost and not debug_infinite_resources:
			action_failed.emit("%s insuficiente" % POOL_NAMES[Pool.MANA])
			return
		spend(Pool.MANA, throw_cost)
	var body := held_body
	var throw_speed: float = _hold["throw_speed"]
	var carry: float = _hold["carry_mass"]
	release_held()
	# Objetos perto do limite de carga saem mais devagar.
	var mass_factor := clampf(1.0 - body.mass / (carry * 1.5), 0.3, 1.0)
	# O objeto já se movia junto com quem segura: herda todo o movimento.
	body.linear_velocity = get_aim_direction() * throw_speed * mass_factor + velocity
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
		if _hold.get("telekinetic", false):
			text = "[%s / %s] Arremessar   [%s] Soltar" % [InputBindings.label("primary"), InputBindings.label("grab"), InputBindings.label("special")]
		else:
			text = "[%s] Arremessar" % InputBindings.label("grab")
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

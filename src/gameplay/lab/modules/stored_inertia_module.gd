class_name LabStoredInertiaModule
extends LabModule
## Passivo: maestria "Inércia guardada" (design/sabio/inspiracao/maestrias.md), só a parte do
## Campo Lento. O Campo continua freando, mas guarda a velocidade com que cada corpo entrou e a
## devolve inteira quando o corpo sai ou o Campo acaba. Devolve, não soma. Guarda também o que
## é do inimigo. Enquanto guarda algo, drena Mana do jogador; sem Mana, solta tudo na hora.

const GLOW_COLOR := Color(0.55, 0.95, 1.0)

## Mana por segundo enquanto houver pelo menos um corpo guardado.
@export var mana_per_second := 4.0
## Segundos finais em que o Campo pisca, avisando que vai soltar.
@export var blink_time := 1.0
## Piscadas por segundo no aviso.
@export var blink_rate := 10.0

## Campo → {corpo: velocidade guardada}.
var _stored := {}
## Corpo → luz que marca a inércia guardada.
var _glows := {}
var _released := 0


func status_text() -> String:
	var count := 0
	for bodies: Dictionary in _stored.values():
		count += bodies.size()
	return "guardados agora: %d · soltos: %d" % [count, _released]


func tick(delta: float) -> void:
	for node in controller.get_tree().current_scene.find_children("*", "SlowField", true, false):
		var field := node as SlowField
		if not _stored.has(field):
			_watch(field)
	var storing := false
	for field: SlowField in _stored.keys():
		if not is_instance_valid(field):
			continue
		_blink(field)
		if not (_stored[field] as Dictionary).is_empty():
			storing = true
	if storing:
		_drain(delta)


func on_disabled() -> void:
	for field: SlowField in _stored.keys():
		_release_all(field)
	_stored.clear()
	super.on_disabled()


func _watch(field: SlowField) -> void:
	_stored[field] = {}
	field.body_entered.connect(_on_body_entered.bind(field))
	field.body_exited.connect(_on_body_exited.bind(field))
	field.tree_exiting.connect(_on_field_exiting.bind(field))


## Os sinais de área chegam antes do freio do Campo no mesmo quadro: a velocidade ainda é a de entrada.
func _on_body_entered(body: Node3D, field: SlowField) -> void:
	var rigid := body as RigidBody3D
	if not enabled or rigid == null or rigid.freeze:
		return
	var bodies: Dictionary = _stored[field]
	if bodies.has(rigid):
		return
	bodies[rigid] = rigid.linear_velocity
	var glow := OmniLight3D.new()
	glow.light_color = GLOW_COLOR
	glow.light_energy = 1.2
	glow.omni_range = 1.0
	rigid.add_child(glow)
	_glows[rigid] = glow


func _on_body_exited(body: Node3D, field: SlowField) -> void:
	if _stored.has(field):
		_release(body as RigidBody3D, field)


func _on_field_exiting(field: SlowField) -> void:
	_release_all(field)
	_stored.erase(field)


func _release_all(field: SlowField) -> void:
	if not _stored.has(field):
		return
	for body: RigidBody3D in (_stored[field] as Dictionary).keys():
		_release(body, field)


func _release(body: RigidBody3D, field: SlowField) -> void:
	var bodies: Dictionary = _stored[field]
	if body == null or not bodies.has(body):
		return
	var velocity: Vector3 = bodies[body]
	bodies.erase(body)
	var glow: Node = _glows.get(body)
	_glows.erase(body)
	if is_instance_valid(glow):
		glow.queue_free()
	if is_instance_valid(body) and not body.is_queued_for_deletion():
		body.linear_velocity = velocity
		_released += 1


func _drain(delta: float) -> void:
	var player: Player = controller.arena.get("player")
	if player == null:
		return
	if player.get_pool(Player.Pool.MANA) <= 0.0:
		for field: SlowField in _stored.keys():
			_release_all(field)
		player.action_failed.emit("Sem Mana: a inércia guardada foi solta")
		return
	player.spend(Player.Pool.MANA, mana_per_second * delta)


func _blink(field: SlowField) -> void:
	var left := field.get_time_left()
	field.visible = left > blink_time or int(left * blink_rate) % 2 == 0

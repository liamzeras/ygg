class_name GravidashAbility
extends Ability
## Gravidade — Gravidash (design/gdd/mage-gravity.md): arrancada curta na direção escolhida
## (movimento em relação à câmera; Espaço = para cima; parado = frente da câmera), levando
## junto os objetos soltos e empurrando os personagens próximos.
## Até `max_charges` usos por recarga: a recarga começa no primeiro e os outros precisam
## sair antes de ela acabar. Para baixo, por enquanto, só se move.

@export var distance := 4.0
@export var duration := 0.2
@export var max_charges := 2
## Raio (m) em volta do mago em que objetos e personagens são levados junto.
@export var carry_radius := 2.5
## Fração da velocidade da arrancada passada aos objetos soltos.
@export_range(0.0, 1.0) var carry_factor := 0.8
## Empurrão (N·s) nos personagens próximos.
@export var push_impulse := 150.0
@export_range(0.0, 1.0) var momentum_transfer := 0.1

const META_WINDOW := &"gravidash_window_until"
const META_USED := &"gravidash_used"


## Usos que ainda cabem nesta recarga (0 se a janela acabou ou os usos foram gastos).
func charges_left(player: Player) -> int:
	if _now() >= float(player.get_meta(META_WINDOW, 0.0)):
		return 0
	return maxi(max_charges - int(player.get_meta(META_USED, 0)), 0)


## Com uso sobrando dentro da recarga, o próximo sai sem nova recarga (o custo é cobrado aqui).
func toggles_off(player: Player) -> bool:
	return charges_left(player) > 0


func get_status_text(player: Player) -> String:
	var left := charges_left(player)
	return "+%d" % left if left > 0 else ""


## Direção da arrancada agora.
func direction(player: Player) -> Vector3:
	if player.force_jump_held or (player.input_enabled and Input.is_action_pressed("jump")):
		return Vector3.UP
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back") if player.input_enabled else Vector2.ZERO
	if input.length() < 0.1:
		return player.get_aim_direction()
	return (player.camera.global_basis * Vector3(input.x, 0.0, input.y)).normalized()


func activate(player: Player) -> void:
	if charges_left(player) > 0:
		# Uso extra: sem recarga nova, mas paga o custo.
		if player.get_pool(cost_pool) < cost and not player.debug_infinite_resources:
			player.action_failed.emit("%s insuficiente" % Player.POOL_NAMES[cost_pool])
			return
		player.spend(cost_pool, cost)
		player.set_meta(META_USED, int(player.get_meta(META_USED, 0)) + 1)
	else:
		player.set_meta(META_WINDOW, _now() + cooldown)
		player.set_meta(META_USED, 1)
	var way := direction(player)
	var speed := distance / duration
	player.start_dash(way * speed, duration, player.class_data.body_mass * speed * momentum_transfer, display_name, true)
	_carry(player, way * speed)
	Fx.burst(player.get_parent(), player.get_center(), Color(0.6, 0.45, 1.0), 0.6)
	player.add_shake(0.2)


func _carry(player: Player, dash_velocity: Vector3) -> void:
	var sphere := SphereShape3D.new()
	sphere.radius = carry_radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, player.get_center())
	query.exclude = [player.get_rid()]
	for result in player.get_world_3d().direct_space_state.intersect_shape(query, 32):
		var body: Object = result.collider
		if body is RigidBody3D and not (body as RigidBody3D).freeze:
			(body as RigidBody3D).linear_velocity = dash_velocity * carry_factor
		elif body.has_method("apply_knockback"):
			body.apply_knockback(dash_velocity.normalized() * push_impulse)


func _now() -> float:
	return float(Engine.get_physics_frames()) / Engine.physics_ticks_per_second

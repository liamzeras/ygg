class_name StoneStrikeAbility
extends Ability
## Terra — Soco de Pedra (botão esq.) e Chute de Pedra (botão dir.) (design/gdd/mage-earth.md).
## Golpe instantâneo à frente, só na faixa do corpo definida aqui: o soco da cintura para cima,
## o chute da cintura para baixo. Atinge o alvo mais próximo:
## - personagem ou boneco: dano pelo impulso e empurrão;
## - objeto solto: impulso (x2 se o material for de terra) pela lei do Quebrável (take_hit): voa,
##   conserva a energia, racha e, ao quebrar, os pedaços saem na direção do golpe;
## - construção da Terra (pilar, coluna): racha em estágios e solta pedaços na direção do golpe
##   (mesma lei do Quebrável, material earth_construct.tres); também reveste o membro, porque é pedra;
## - superfície fixa de terra ou pedra (PropMaterial.earth_workable): reveste o membro de pedra
##   por `coat_duration` s (mais alcance e impulso). Madeira e metal fixos não revestem.
## Revestido, golpear o ar arremessa um pedregulho de pedra.
## Impulso = base_impulse x mult(Força) x (earth_multiplier) x (coated_multiplier).

## Altura (m acima dos pés) onde a faixa do golpe começa e termina.
@export var band_bottom := 0.9
@export var band_top := 1.9
## Largura da área do golpe (m).
@export var width := 0.9
## Alcance à frente do corpo (m), sem e com revestimento.
@export var reach := 1.4
@export var coated_reach := 2.4
@export var base_impulse := 140.0
## Materiais que respondem mais à Terra (pedra, metal, concreto...).
@export var earth_materials: Array[Resource] = []
@export var earth_multiplier := 2.0
@export var coat_duration := 6.0
@export var coated_multiplier := 1.5
## Chave do revestimento: golpes com a mesma chave compartilham o revestimento (mãos, pés).
@export var coat_key := &"hands"
@export_group("Pedregulho")
@export var pebble_material: PropMaterial
@export var pebble_size := 0.25
@export var pebble_speed := 16.0
## Inclinação do arremesso (graus acima da horizontal). Só vale para o chute; o soco segue a mira.
@export var pebble_pitch := 8.0
@export var follow_aim := true
@export var pebble_lifetime := 5.0


## Marca no jogador: até quando o próximo golpe sai de graça (ver BrawlGrabAbility).
const FREE_STRIKE_META := &"free_strike_until"


func get_block_reason(player: Player) -> String:
	return "Mãos ocupadas" if is_instance_valid(player.held_body) else ""


## Segundos restantes do revestimento (0 = sem revestimento).
func coat_time_left(player: Player) -> float:
	var until: float = player.get_meta(_coat_meta(), 0.0)
	return maxf(until - _now(), 0.0)


func is_coated(player: Player) -> bool:
	return coat_time_left(player) > 0.0


## Texto extra para o HUD (tempo de revestimento).
func get_status_text(player: Player) -> String:
	var left := coat_time_left(player)
	return "Pedra %.0fs" % ceilf(left) if left > 0.0 else ""


func strike_impulse(player: Player, target: Object) -> float:
	var impulse := base_impulse * power(player)
	if is_coated(player):
		impulse *= coated_multiplier
	if target is Node and earth_materials.has(PropMaterial.of(target as Node)):
		impulse *= earth_multiplier
	return impulse


func activate(player: Player) -> void:
	# Golpe de graça (Agarrar da Zona Nula): devolve o custo que acabou de ser cobrado.
	if now() < float(player.get_meta(FREE_STRIKE_META, 0.0)):
		player.remove_meta(FREE_STRIKE_META)
		player.refund(cost_pool, cost)
	var coated := is_coated(player)
	var target := _find_target(player, coated_reach if coated else reach)
	var direction := _direction(player)
	if target == null:
		if coated:
			_throw_pebble(player, direction)
		return
	var impulse := strike_impulse(player, target)
	var receiver := DamageRules.receiver_of(target)
	if receiver:
		if not DamageRules.is_invulnerable(target):
			receiver.register_hit(display_name, impulse)
		if target.has_method("apply_knockback"):
			target.apply_knockback(direction * impulse)
		player.add_shake(0.25)
	elif target is PhysicsProp:
		# Lei do Quebrável: empurra, racha e, ao quebrar, os pedaços saem na direção do golpe.
		(target as PhysicsProp).take_hit(direction * impulse)
		player.add_shake(0.25)
	elif target is RigidBody3D:
		(target as RigidBody3D).apply_central_impulse(direction * impulse)
		player.add_shake(0.25)
	else:
		# Construção da Terra (pilar, coluna): racha e solta pedaços na direção do golpe.
		if target.has_method("take_hit"):
			target.take_hit(direction * impulse, _band_center(player, Player.BODY_RADIUS + reach))
		# Lei da Terra: só reveste o membro se a superfície for terra ou pedra.
		var material := PropMaterial.of(target as Node)
		if material and material.earth_workable:
			player.set_meta(_coat_meta(), _now() + coat_duration)
			Fx.burst(player.get_parent(), _band_center(player, 0.6), StonePillar.COLOR, 0.4)
		player.add_shake(0.35)


## Alvo dentro da área do golpe, ou null. Personagens e objetos soltos vêm antes de
## superfícies fixas (socar uma caixa encostada na parede acerta a caixa); entre iguais,
## o mais próximo do centro da faixa do golpe.
func _find_target(player: Player, distance: float) -> Object:
	var forward := player.get_flat_forward()
	var height := band_top - band_bottom
	var box := BoxShape3D.new()
	box.size = Vector3(width, height, distance)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	var center := _band_center(player, Player.BODY_RADIUS + distance / 2.0)
	query.transform = Transform3D(Basis.looking_at(forward, Vector3.UP), center)
	query.exclude = [player.get_rid()]
	var origin := _band_center(player, 0.0)
	var best: Object = null
	var best_score := INF
	for result in player.get_world_3d().direct_space_state.intersect_shape(query, 32):
		var collider: Object = result.collider
		if not collider is Node3D:
			continue
		var movable := collider is RigidBody3D or DamageRules.receiver_of(collider as Node) != null
		# Superfície fixa só ganha se não houver nada que se mova na área.
		var score := DamageRules.center_of(collider as Node3D).distance_to(origin) + (0.0 if movable else 1000.0)
		if score < best_score:
			best = collider
			best_score = score
	return best


func _band_center(player: Player, ahead: float) -> Vector3:
	return player.global_position + Vector3.UP * (band_bottom + band_top) / 2.0 + player.get_flat_forward() * ahead


func _direction(player: Player) -> Vector3:
	if follow_aim:
		return player.get_aim_direction()
	return player.get_flat_forward().rotated(player.get_flat_forward().cross(Vector3.UP).normalized(), deg_to_rad(pebble_pitch))


func _throw_pebble(player: Player, direction: Vector3) -> void:
	if pebble_material == null:
		return
	var pebble := PhysicsProp.new()
	pebble.material_data = pebble_material
	pebble.shape_kind = PhysicsProp.Form.SPHERE
	pebble.size = Vector3.ONE * pebble_size
	pebble.display_name = "Pedregulho"
	player.get_parent().add_child(pebble)
	pebble.global_position = _band_center(player, Player.BODY_RADIUS + pebble_size)
	pebble.linear_velocity = direction * pebble_speed * sqrt(power(player)) + player.velocity
	pebble.add_collision_exception_with(player)
	player.get_tree().create_timer(pebble_lifetime).timeout.connect(pebble.queue_free)


func _coat_meta() -> StringName:
	return StringName("stone_coat_%s" % coat_key)


## Relógio do jogo em segundos (quadros de física), o mesmo para todos os golpes.
static func now() -> float:
	return float(Engine.get_physics_frames()) / Engine.physics_ticks_per_second


func _now() -> float:
	return now()

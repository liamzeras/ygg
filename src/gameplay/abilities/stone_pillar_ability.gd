class_name StonePillarAbility
extends TerrainAbility
## Elementalista — Escada de Pedra (design/gdd/mage-elementalist.md): 3 pilares em linha,
## do mais baixo (perto de quem lança) ao mais alto. O do meio nasce no chão mirado.
## Elevador para quem está em cima, catapulta para objetos soltos, cobertura.
## Uma escada por vez: lançar outra derruba a anterior. Um pilar sem chão firme fica de fora.

@export var width := 1.0
## Altura de cada degrau (m), do mais próximo ao mais distante.
@export var step_heights: Array[float] = [0.85, 1.7, 2.55]
## Degrau que se sobe sozinho segurando W (m). 0 = só pulando.
@export var auto_climb_height := 0.9
## Qual degrau (índice em step_heights) nasce no ponto mirado.
@export var aimed_step := 1
@export var rise_time := 0.35
@export var lifetime := 8.0
@export var sink_time := 0.6
## Material dos pilares (pedra moldada, earth_construct.tres): dá a massa (volume x densidade) e a
## regra do Quebrável (soco, chute e Mibune racham e quebram).
@export var construct_material: PropMaterial
## Só sem `construct_material`: densidade (kg/m³) para a massa de cada pilar.
@export var stone_density := 350.0
## Fração da quantidade de movimento do pilar passada a quem ele acerta ao subir.
@export_range(0.0, 1.0) var impact_transfer := 0.05

var _pillars: Array[StonePillar] = []


## Pilares de pé (ou subindo) agora, do degrau mais baixo ao mais alto.
func get_active_pillars() -> Array[StonePillar]:
	var standing: Array[StonePillar] = []
	for pillar in _pillars:
		# Pilares que já afundaram foram liberados: checar antes de usar.
		if is_instance_valid(pillar) and not pillar.is_sinking():
			standing.append(pillar)
	_pillars = standing
	return _pillars


func activate(player: Player) -> void:
	var ground := find_ground(player)
	if ground.is_empty():
		return
	for old in get_active_pillars():
		old.sink()
	_pillars = []
	var direction := player.get_flat_forward()
	var center: Vector3 = ground.position
	for i in step_heights.size():
		var point := center + direction * width * (i - aimed_step)
		if i != aimed_step:
			var side := _side_ground(player, center, point)
			if side.is_empty():
				continue
			point = side.position
		_pillars.append(_spawn(player, point, direction, step_heights[i]))
	player.add_shake(0.2)


func _spawn(player: Player, point: Vector3, direction: Vector3, height: float) -> StonePillar:
	var pillar := StonePillar.new()
	pillar.source_name = display_name
	pillar.width = width
	pillar.height = height
	pillar.auto_climb_height = auto_climb_height
	pillar.rise_time = rise_time
	pillar.lifetime = lifetime
	pillar.sink_time = sink_time
	var density := construct_material.density if construct_material else stone_density
	pillar.pillar_mass = width * width * height * density
	pillar.material = construct_material
	pillar.caster = player
	pillar.impact_transfer = impact_transfer
	player.get_tree().current_scene.add_child(pillar)
	pillar.start(point, direction)
	return pillar


## Chão firme para um pilar lateral: sem parede no caminho e na mesma altura do mirado.
func _side_ground(player: Player, center: Vector3, point: Vector3) -> Dictionary:
	var lift := Vector3.UP * 0.5
	if not _cast(player, center + lift, point + lift).is_empty():
		return {}
	var hit := _cast(player, point + lift, point - lift)
	if hit.is_empty():
		return {}
	if (hit.normal as Vector3).angle_to(Vector3.UP) > deg_to_rad(max_slope):
		return {}
	return hit


## Raio que ignora objetos soltos, o boneco e o que se move (nada disso impede um pilar).
func _cast(player: Player, from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var exclude: Array[RID] = [player.get_rid()]
	for attempt in 8:
		query.exclude = exclude
		var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			return {}
		if _is_ground(hit.collider):
			return hit
		exclude.append(hit.rid)
	return {}

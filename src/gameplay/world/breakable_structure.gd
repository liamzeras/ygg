class_name BreakableStructure
extends StaticBody3D
## Estrutura fixa do cenário (parede, torre, degrau, rampa, chão) que segue a lei do Quebrável
## e se reconstrói sozinha. Regras em design/gdd/physics-magic-system.md ("Cenário quebrável").
##
## Recebe golpes por `take_hit(impulso, ponto)`, a mesma interface dos objetos soltos: soco,
## chute, Mibune e explosões já chamam isso. Cada estágio custa `BreakRules.structure_stage_impulse`
## x a dureza do material (`hardness`; concreto = 1). O tamanho não conta. No último estágio:
## - estrutura comum: some (sem colisão), solta pedaços e volta em `BreakRules.rebuild_time`;
## - estrutura de contenção (`bedrock`: chão e muros da borda): nunca perde a colisão, para
##   ninguém cair para fora do mundo; solta entulho no ponto do golpe, fica rachada e volta a
##   ficar inteira no mesmo tempo.

## Avançou um estágio (1 a 3 = rachado; 4 = quebrou).
signal stage_changed(stage: int)
## Quebrou. `pieces` são os pedaços soltos (PhysicsProp).
signal shattered(pieces: Array)
## Voltou inteira.
signal rebuilt

## Material da estrutura (massa dos pedaços, cor do entulho, calor, Terra).
@export var material_data: PropMaterial
## Tamanho da caixa (m).
@export var size := Vector3.ONE
## Chão e muros da borda: racham e soltam entulho, mas nunca perdem a colisão.
@export var bedrock := false
## Nome mostrado na mira.
@export var display_name := ""

var _damage := 0.0
var _stage := 0
var _broken := false
var _rebuild_left := -1.0
var _mesh_instance: MeshInstance3D
var _collision: CollisionShape3D
var _base_material: Material
var _cracked_material: StandardMaterial3D
var _layer := 1
var _mask := 1


## Monta a estrutura com malha e colisão em caixa. `visual` é o material de aparência (pode ser
## compartilhado por várias estruturas; a rachadura cria uma cópia só para esta).
static func create(box: Vector3, visual: Material, material: PropMaterial, is_bedrock := false) -> BreakableStructure:
	var structure := BreakableStructure.new()
	structure.size = box
	structure.material_data = material
	structure.bedrock = is_bedrock
	structure._base_material = visual
	return structure


func _ready() -> void:
	if material_data == null:
		material_data = load(PropMaterial.DEFAULT_GROUND_PATH) as PropMaterial
	set_meta(&"material_data", material_data)
	add_to_group(&"breakable_structures")
	var mesh := BoxMesh.new()
	mesh.size = size
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.mesh = mesh
	_mesh_instance.material_override = _base_material
	add_child(_mesh_instance)
	var shape := BoxShape3D.new()
	shape.size = size
	_collision = CollisionShape3D.new()
	_collision.shape = shape
	add_child(_collision)
	_layer = collision_layer
	_mask = collision_mask
	set_physics_process(false)


func get_display_name() -> String:
	return display_name if display_name != "" else material_data.display_name


## Estágio atual: 0 inteira, 1 a 3 rachada, 4 quebrada (esperando reconstruir).
func get_break_stage() -> int:
	return _stage


## true enquanto está quebrada (estrutura comum: sem colisão e invisível).
func is_broken() -> bool:
	return _broken


## Impulso (N·s) que avança um estágio: BreakRules.structure_stage_impulse x dureza do material.
func stage_impulse() -> float:
	return BreakRules.current().structure_stage_impulse * material_data.hardness


## Golpe do mundo (soco, chute, Mibune, explosão). `impulse` já vem na direção do golpe;
## `point` (global, opcional) é onde acertou: o entulho do chão sai dali.
func take_hit(impulse: Vector3, point := Vector3.INF) -> void:
	if _broken:
		return
	var amount := impulse.length()
	if amount < stage_impulse() * material_data.break_min_fraction or not material_data.breakable:
		return
	_damage += amount
	var stage := mini(int(_damage / stage_impulse()), PropMaterial.BREAK_STAGES)
	if stage == _stage:
		return
	_stage = stage
	stage_changed.emit(stage)
	var at := point if point != Vector3.INF else global_position
	if stage >= PropMaterial.BREAK_STAGES:
		_break(impulse, at)
		return
	_show_cracks()
	_dust(at, maxf(size.x, size.y) * 0.2)


## Ponto da caixa mais perto de `point` (global). Explosões acertam a estrutura ali.
func closest_point(point: Vector3) -> Vector3:
	var local := global_transform.affine_inverse() * point
	var half := size * 0.5
	return global_transform * local.clamp(-half, half)


## Distância de `point` até a superfície (0 dentro). DamageRules.distance_to usa isto, para uma
## parede de 100 m não contar como "longe" só porque o centro dela está longe.
func surface_distance(point: Vector3) -> float:
	return closest_point(point).distance_to(point)


## Segundos até voltar inteira (-1 se não está esperando).
func rebuild_time_left() -> float:
	return _rebuild_left


func _physics_process(delta: float) -> void:
	_rebuild_left -= delta
	if _rebuild_left > 0.0:
		return
	if _broken and _occupied():
		# Alguém está no lugar: tenta de novo daqui a pouco, sem prender nem esmagar ninguém.
		_rebuild_left = BreakRules.current().rebuild_retry
		return
	_rebuild()


func _break(impulse: Vector3, at: Vector3) -> void:
	var rules := BreakRules.current()
	var pieces: Array[PhysicsProp] = []
	if bedrock:
		# Contenção: a colisão fica; solta entulho de uma caixa pequena no ponto do golpe.
		var chunk := Vector3.ONE * rules.bedrock_chunk_size
		var chunk_mass := minf(chunk.x * chunk.y * chunk.z * material_data.density, rules.structure_piece_mass)
		var lift := Vector3.UP * (chunk.y * 0.5 + 0.05)
		pieces = PhysicsProp.spawn_pieces(get_parent(), Transform3D(Basis.IDENTITY, at + lift), chunk, material_data,
				chunk_mass, impulse / maxf(chunk_mass, 0.01))
		# Pode rachar e soltar entulho de novo; a cor rachada fica até a reconstrução.
		_damage = 0.0
		_stage = 0
	else:
		_broken = true
		visible = false
		collision_layer = 0
		collision_mask = 0
		_collision.set_deferred(&"disabled", true)
		var piece_mass := minf(size.x * size.y * size.z * material_data.density, rules.structure_piece_mass)
		pieces = PhysicsProp.spawn_pieces(get_parent(), global_transform, size, material_data, piece_mass,
				impulse / maxf(piece_mass, 0.01))
	_dust(at, maxf(size.x, size.y) * 0.5)
	_rebuild_left = rules.rebuild_time
	set_physics_process(true)
	shattered.emit(pieces)


## Volta inteira. Pedaços soltos que estiverem dentro do volume somem antes (eles atravessam o
## jogador e não são "alguém"); jogador, bots e objetos inteiros adiam a volta (ver _occupied).
func _rebuild() -> void:
	set_physics_process(false)
	_rebuild_left = -1.0
	_damage = 0.0
	_stage = 0
	_mesh_instance.material_override = _base_material
	if _broken:
		for piece in _overlapping(BreakRules.current().piece_layer):
			if piece is PhysicsProp and (piece as PhysicsProp).is_piece:
				(piece as PhysicsProp)._retire()
		_broken = false
		visible = true
		collision_layer = _layer
		collision_mask = _mask
		_collision.disabled = false
	rebuilt.emit()


## true se algo que não é pedaço solto (jogador, bot, caixa, barril) ocupa o volume.
func _occupied() -> bool:
	return not _overlapping(_layer | _mask | 1, true).is_empty()


## Corpos dentro do volume da estrutura nas camadas `mask`. `skip_pieces` ignora pedaços soltos.
func _overlapping(mask: int, skip_pieces := false) -> Array[Node]:
	var found: Array[Node] = []
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = _collision.shape
	params.transform = global_transform
	params.collision_mask = mask
	params.exclude = [get_rid()]
	for hit in get_world_3d().direct_space_state.intersect_shape(params, 16):
		var body := hit["collider"] as Node
		if body == null:
			continue
		if skip_pieces and body is PhysicsProp and (body as PhysicsProp).is_piece:
			continue
		# Chão, vizinhos e outras peças fixas encostam na caixa, mas não são "alguém no lugar".
		if body is StaticBody3D and not body is AnimatableBody3D:
			continue
		found.append(body)
	return found


## Rachaduras: escurece a cor (cópia do material só para esta estrutura).
func _show_cracks() -> void:
	var source := _base_material as StandardMaterial3D
	if source == null:
		return
	if _cracked_material == null:
		_cracked_material = source.duplicate() as StandardMaterial3D
	_cracked_material.albedo_color = source.albedo_color.darkened(PhysicsProp.STAGE_SHADE * _stage)
	_mesh_instance.material_override = _cracked_material


func _dust(at: Vector3, radius: float) -> void:
	if BreakRules.take_slot(&"burst", BreakRules.current().max_bursts_per_frame):
		Fx.burst(get_tree().current_scene, at, material_data.color, radius)

extends Node3D
## Arena de testes gerada por código: chão em grade de 1 m, pista de mobilidade
## (degraus medidos, vãos, rampas, torres), laboratório de materiais e o boneco de testes.
## Tudo com formas simples (placeholder) até termos arte.

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const RULES := preload("res://assets/data/attribute_rules.tres")
const DAMAGE_RULES := preload("res://assets/data/damage_rules.tres")
const WOOD := preload("res://assets/data/materials/wood.tres")
const METAL := preload("res://assets/data/materials/metal.tres")
const STONE := preload("res://assets/data/materials/stone.tres")
const EXPLOSIVE := preload("res://assets/data/materials/explosive.tres")

const SPAWN := Vector3(0, 0.05, 10)
const ARENA_HALF_SIZE := 50.0
## Escada da pista de vãos (altura e profundidade de cada degrau, em m).
const STAIR_RISE := 0.2
const STAIR_DEPTH := 0.35
## Alvos voadores (F7): cada pressão cria um lote com estas órbitas em volta do boneco:
## [raio (m), altura (m), velocidade (m/s; negativa = sentido contrário)].
const TARGET_ORBITS := [[4.0, 2.6, 3.0], [6.0, 3.8, -5.0], [8.0, 5.0, 7.0]]
const MAX_TARGETS := 9
## Onde o bot de combate (F6) nasce e renasce: longe do jogador, do outro lado do boneco.
const BOT_SPAWN := Vector3(-4, 0.05, -8)
const BOT_PROFILE := preload("res://assets/data/enemies/psionic_bot.tres")

var player: Player
var dummy: TrainingDummy
var flying_targets: Array[FlyingTarget] = []
var combat_bot: PsionicBot

@onready var _hud: CanvasLayer = $HUD

var _floor_material: StandardMaterial3D
var _block_material: StandardMaterial3D
var _accent_material: StandardMaterial3D


func _ready() -> void:
	_floor_material = _grid_material(Color(0.36, 0.38, 0.42), Color(0.3, 0.32, 0.36))
	_block_material = _grid_material(Color(0.55, 0.57, 0.62), Color(0.48, 0.5, 0.55))
	_accent_material = _grid_material(Color(0.75, 0.55, 0.3), Color(0.68, 0.48, 0.25))
	_build_environment()
	_build_bounds()
	_build_mobility_course()
	_build_material_lab()
	_build_dummy()
	_spawn_player()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_bot"):
		toggle_combat_bot()
	if event.is_action_pressed("spawn_targets"):
		spawn_flying_targets()
	if event.is_action_pressed("reload_arena"):
		GameState.reload_current()


## Cria um lote de alvos voadores em volta do boneco; acima do limite, somem os mais antigos.
func spawn_flying_targets() -> void:
	for orbit in TARGET_ORBITS:
		var target := FlyingTarget.new()
		target.dummy = dummy
		target.center = dummy.global_position + Vector3.UP * orbit[1]
		target.orbit_radius = orbit[0]
		target.orbit_speed = orbit[2]
		target.angle = randf() * TAU
		add_child(target)
		flying_targets.append(target)
	while flying_targets.size() > MAX_TARGETS:
		flying_targets.pop_front().queue_free()


## F6: chama o bot Psiônico agressivo; apertar de novo faz ele sumir.
func toggle_combat_bot() -> void:
	if is_instance_valid(combat_bot):
		combat_bot.queue_free()
		combat_bot = null
		return
	combat_bot = PsionicBot.new()
	combat_bot.class_data = GameState.find_class("psionic")
	combat_bot.rules = player.rules
	combat_bot.profile = BOT_PROFILE
	combat_bot.target = player
	combat_bot.position = BOT_SPAWN
	add_child(combat_bot)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.class_data = GameState.get_selected_class()
	player.position = SPAWN
	add_child(player)
	# Vida do jogador: componente filho, para não mexer em player.gd (design/gdd/combat-bot.md).
	var health := Health.new()
	health.name = "Health"
	player.add_child(health)
	health.setup(player.stats.mult(Attributes.Kind.VITALITY))
	player.stats_changed.connect(func() -> void: health.setup(player.stats.mult(Attributes.Kind.VITALITY)))
	_hud.bind_player(player)
	$DebugEditor.bind(player, dummy)


# --- Ambiente -----------------------------------------------------------------

func _build_environment() -> void:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.32, 0.47, 0.72)
	sky_material.sky_horizon_color = Color(0.68, 0.73, 0.8)
	sky_material.ground_horizon_color = Color(0.68, 0.73, 0.8)
	sky_material.ground_bottom_color = Color(0.2, 0.2, 0.22)
	var sky := Sky.new()
	sky.sky_material = sky_material
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.ssao_enabled = true
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)


func _build_bounds() -> void:
	var size := ARENA_HALF_SIZE * 2.0
	_static_box(Vector3(0, -0.5, 0), Vector3(size, 1, size), _floor_material, true)
	for side in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
		var wall_size := Vector3(1, 2, size) if side.x != 0 else Vector3(size, 2, 1)
		_static_box(side * (ARENA_HALF_SIZE + 0.5) + Vector3.UP, wall_size, _block_material, true)
	_sign(Vector3(0, 8.0, -14),"ARENA DE TESTES\n← Mobilidade      Materiais →", 0.012)


# --- Pista de mobilidade (oeste) ----------------------------------------------

func _build_mobility_course() -> void:
	# Degraus com altura medida: até rules.step_height (0,4 m) sobe andando; 1 m é o pulo
	# máximo e 2 m o máximo com pulo duplo. 2,5 m só com mobilidade futura.
	var heights := [0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5]
	for i in heights.size():
		var h: float = heights[i]
		var pos := Vector3(-10, h / 2.0, 9 - i * 3.0)
		_static_box(pos, Vector3(2, h, 2), _accent_material if h > 2.0 else _block_material)
		_sign(Vector3(-10, h + 0.6, 9 - i * 3.0), ("%.2f m" % h).replace(".", ","), 0.007)
	_sign(Vector3(-10, 3.2, 12), "ALTURA DE PULO\naté 0,4 m: só andando", 0.01)

	# Plataformas a 2 m com vãos crescentes: testam distância (Investida, Salto Arcano).
	var z := 8.0
	# Escada de verdade até a primeira plataforma: 9 degraus de 0,2 m, sobe só andando.
	for step in range(1, 10):
		var step_height := STAIR_RISE * step
		var step_z := z + 1.5 + (10 - step) * STAIR_DEPTH - STAIR_DEPTH / 2.0
		_static_box(Vector3(-20, step_height / 2.0, step_z), Vector3(3, step_height, STAIR_DEPTH), _block_material)
	_sign(Vector3(-20, 2.8, z + 5.0), "escada (degraus de 0,2 m)", 0.007)
	for gap in [0.0, 2.0, 3.0, 4.0, 5.0, 6.0]:
		z -= gap
		_static_box(Vector3(-20, 1.0, z), Vector3(3, 2, 3), _block_material)
		if gap > 0.0:
			_sign(Vector3(-20, 2.8, z + 1.5 + gap / 2.0), "vão %d m" % gap, 0.007)
		z -= 3.0
	_sign(Vector3(-20, 3.6, 11), "VÃOS (plataformas a 2 m)", 0.01)

	# Rampas de 15°, 30° e 45°.
	for i in 3:
		var angle := 15.0 * (i + 1)
		var ramp := _static_box(Vector3(-30, 3.0 * sin(deg_to_rad(angle)), 6 - i * 8.0), Vector3(3, 0.3, 6), _block_material)
		ramp.rotation_degrees.x = angle
		_sign(Vector3(-30, 3.6, 6 - i * 8.0), "rampa %d°" % angle, 0.007)

	# Torres altas: acima do teto do pulo duplo (2 m). Reservadas para mobilidade futura
	# e para testar o Flutuar descendo.
	for tower in [[Vector3(-38, 0, -20), 3.0], [Vector3(-38, 0, -24.5), 4.5], [Vector3(-38, 0, -29), 6.0]]:
		var h: float = tower[1]
		_static_box(tower[0] + Vector3(0, h / 2.0, 0), Vector3(3, h, 3), _accent_material)
		_sign(tower[0] + Vector3(0, h + 0.6, 0), ("torre %.1f m" % h).replace(".", ","), 0.007)
	# Escadaria até a torre de 6 m (leste dela), para subir andando e testar o Flutuar.
	var top := 6.0
	var steps := roundi(top / STAIR_RISE)
	for step in range(1, steps):
		var step_height := STAIR_RISE * step
		var step_x := -36.5 + (steps - step) * STAIR_DEPTH - STAIR_DEPTH / 2.0
		_static_box(Vector3(step_x, step_height / 2.0, -29), Vector3(STAIR_DEPTH, step_height, 2), _block_material)


# --- Laboratório de materiais (leste) -----------------------------------------

func _build_material_lab() -> void:
	_sign(Vector3(14, 3.2, 10), "LABORATÓRIO DE MATERIAIS", 0.01)

	# Caixas soltas perto do início para testar pegar e arremessar.
	for pos in [Vector3(3, 0.31, 8), Vector3(4, 0.31, 6.5), Vector3(-3, 0.31, 7)]:
		_prop(WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), pos)

	# Pirâmide de caixas de madeira.
	for row in 4:
		for i in 4 - row:
			var x := 12.0 + (i - (3 - row) / 2.0) * 0.62
			_prop(WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(x, 0.31 + row * 0.61, -2))
	_sign(Vector3(12, 3.4, -2), "madeira  · inflamável", 0.007)

	# Muro de caixas para atropelar com a Investida.
	for row in 3:
		for i in 6:
			_prop(WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(14 + i * 0.62, 0.31 + row * 0.61, 14))
	_sign(Vector3(15.5, 2.6, 14), "muro de caixas", 0.007)

	# Barris de pólvora: perto da pirâmide (reação em cadeia) e um isolado.
	for pos in [Vector3(10.5, 0.46, 1), Vector3(11.3, 0.46, 1.4), Vector3(19, 0.46, 6)]:
		_prop(EXPLOSIVE, PhysicsProp.Form.CYLINDER, Vector3(0.6, 0.9, 0.6), pos)
	_sign(Vector3(19, 2.2, 6), "pólvora  · explode", 0.007)

	# Metal: pesado, não queima.
	for i in 4:
		_prop(METAL, PhysicsProp.Form.BOX, Vector3(0.5, 0.5, 0.5), Vector3(20 + i * 0.8, 0.26, -8))
	_sign(Vector3(21.2, 2.0, -8), "metal  · pesado, não queima", 0.007)

	# Pedra: blocos médios e um bloco que ninguém levanta.
	for i in 3:
		_prop(STONE, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(26, 0.31, -2 + i * 1.0))
	_prop(STONE, PhysicsProp.Form.BOX, Vector3(1.2, 1.2, 1.2), Vector3(26, 0.61, -8), "Bloco de pedra grande")
	_prop(STONE, PhysicsProp.Form.SPHERE, Vector3(0.9, 0.9, 0.9), Vector3(28, 0.46, 2), "Pedra redonda")
	_sign(Vector3(26, 2.4, -2), "pedra  · muito pesada", 0.007)

	# Braseiro: fogo do ambiente, para quem não tem magia de fogo.
	var brazier_pos := Vector3(7, 0, 10)
	var base := _static_box(brazier_pos + Vector3(0, 0.4, 0), Vector3(1.0, 0.8, 1.0), _block_material)
	base.add_child(_fire_on_top())
	var zone := HeatZone.new()
	zone.position = brazier_pos + Vector3(0, 1.1, 0)
	var zone_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.4, 0.8, 1.4)
	zone_shape.shape = box
	zone.add_child(zone_shape)
	add_child(zone)
	_sign(brazier_pos + Vector3(0, 2.2, 0), "braseiro  · segure algo aqui", 0.007)


func _fire_on_top() -> Node3D:
	var fire := Fx.make_fire(0.35)
	fire.position.y = 0.5
	return fire


func _build_dummy() -> void:
	dummy = TrainingDummy.new()
	dummy.rules = RULES
	dummy.damage_rules = DAMAGE_RULES
	dummy.position = Vector3(0, 0, 3)
	add_child(dummy)


# --- Ajudantes ----------------------------------------------------------------

func _prop(material: PropMaterial, form: PhysicsProp.Form, size: Vector3, pos: Vector3, label := "") -> PhysicsProp:
	var prop := PhysicsProp.new()
	prop.material_data = material
	prop.shape_kind = form
	prop.size = size
	prop.display_name = label
	prop.position = pos
	add_child(prop)
	return prop


## Peça fixa do cenário. Tudo quebra e volta sozinho (BreakableStructure, concreto). `bedrock`:
## chão e muros da borda racham e soltam entulho, mas nunca perdem a colisão.
func _static_box(pos: Vector3, size: Vector3, material: Material, bedrock := false) -> StaticBody3D:
	var body := BreakableStructure.create(size, material, null, bedrock)
	body.position = pos
	add_child(body)
	return body


func _sign(pos: Vector3, text: String, pixel_size := 0.008) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.pixel_size = pixel_size
	label.font_size = 64
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	return label


## Textura xadrez de 1 m projetada no mundo: ajuda a medir distâncias a olho.
func _grid_material(a: Color, b: Color) -> StandardMaterial3D:
	var image := Image.create(2, 2, false, Image.FORMAT_RGB8)
	image.set_pixel(0, 0, a)
	image.set_pixel(1, 1, a)
	image.set_pixel(1, 0, b)
	image.set_pixel(0, 1, b)
	var material := StandardMaterial3D.new()
	material.albedo_texture = ImageTexture.create_from_image(image)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * 0.5
	material.roughness = 0.9
	return material

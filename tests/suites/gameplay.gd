extends "res://tests/suite_base.gd"
## Suíte da frente gameplay: corpo do jogador (degraus, rampa, explosões, fogo, pegar e arremessar).


func run() -> void:
	await _test_steps()
	await _test_stair_rhythm()
	await _test_stair_no_jolt()
	await _test_explosion_occlusion()
	await _test_fire_spread()
	await _test_grab_and_throw()
	await _test_fire_law()
	await _test_hot_stone()
	await _test_earth_law()
	await _test_gravity_law()
	await _test_heat_owner()
	await _test_break_law()
	await _test_break_inheritance()
	await _test_break_limits()


# Dono do calor: quem conjurou não se queima com o que criou; os outros, sim (decisão do Liam).
# Um bloco de pedra faz o papel do "mago" (qualquer receptor de calor serve; nenhuma habilidade).
func _test_heat_owner() -> void:
	print("\n--- Lei do Fogo: dono do calor ---")
	var arena := await _load_arena("fire")
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var caster: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(31.2, 0.31, 28))
	var other: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(32.8, 0.31, 28))
	var zone := _air_zone(arena, Vector3(32, 1, 28), Vector3(3, 2, 3), 100.0, 1.0)
	zone.heat_owner = caster
	await _frames(60)
	_check(caster.heat == 0.0 and other.heat > 50.0, "zona de calor não queima quem a conjurou (%.0f) e queima o outro (%.0f)" % [caster.heat, other.heat])
	zone.queue_free()

	var fire_caster: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(37.3, 0.31, 34))
	var bystander: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(38.7, 0.31, 34))
	var lit: PhysicsProp = arena._prop(arena.WOOD, box, size, Vector3(38, 0.31, 34))
	var next: PhysicsProp = arena._prop(arena.WOOD, box, size, Vector3(38, 0.31, 34.7))
	for prop in [fire_caster, bystander, lit, next]:
		prop.freeze = true
	await _frames(5)
	lit.ignite(fire_caster)
	await _frames(60)
	_check(fire_caster.heat == 0.0 and bystander.heat > 0.0, "fogo conjurado não aquece o conjurador (%.0f) e aquece quem está ao lado (%.1f)" % [fire_caster.heat, bystander.heat])
	_check(next.heat_owner == fire_caster, "o calor passado adiante continua sendo do conjurador (o fogo que ele criou se espalha sem queimá-lo)")
	await _unload(arena)


# Lei do Quebrável: golpe vira dano, dano vira estágio, o 4º estágio vira pedaços.
func _test_break_law() -> void:
	print("\n--- Lei do Quebrável: estágios e pedaços ---")
	var arena := await _load_arena("fire")
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var crate: PhysicsProp = arena._prop(wood, box, size, Vector3(32, 0.31, 28))
	await _frames(5)
	var per_stage := crate.stage_impulse()
	_check(absf(per_stage - wood.break_toughness * crate.mass) < 0.01, "impulso por estágio = resistência x massa (%.0f N·s)" % per_stage)
	var stages: Array[int] = []
	crate.stage_changed.connect(func(stage: int) -> void: stages.append(stage))
	crate.take_hit(Vector3.RIGHT * per_stage * (wood.break_min_fraction - 0.05))
	await _frames(2)
	_check(crate.get_break_stage() == 0 and crate.get_break_damage() == 0.0, "golpe fraco (abaixo de %.0f%% de um estágio) não deixa marca" % (wood.break_min_fraction * 100.0))
	for hit in 3:
		crate.take_hit(Vector3.RIGHT * per_stage * 1.01)
		await _frames(2)
	_check(crate.get_break_stage() == 3 and stages == [1, 2, 3], "três golpes de um estágio passam por 1, 2 e 3 (%s)" % [stages])
	var whole_mass := crate.mass
	var result := {"pieces": []}
	crate.shattered.connect(func(pieces: Array) -> void: result["pieces"] = pieces)
	crate.linear_velocity = Vector3.ZERO
	var push := Vector3.RIGHT * per_stage * 1.01
	crate.take_hit(push)
	await _frames(1)
	var pieces: Array = result["pieces"]
	_check(pieces.size() == wood.break_pieces and not is_instance_valid(crate), "o 4º estágio vira %d pedaços e o objeto inteiro some" % pieces.size())
	var mass_sum := 0.0
	var momentum := Vector3.ZERO
	for piece in pieces:
		mass_sum += piece.mass
		momentum += piece.mass * piece.linear_velocity
	_check(absf(mass_sum - whole_mass) < 0.05, "a massa dos pedaços soma a do objeto (%.2f de %.2f kg)" % [mass_sum, whole_mass])
	var mean_velocity := momentum / mass_sum
	var expected := push.length() / whole_mass
	_check(mean_velocity.x > expected * 0.6, "os pedaços saem na direção do golpe (%.1f m/s em x; golpe / massa = %.1f)" % [mean_velocity.x, expected])

	# Materiais diferentes: o mesmo golpe que racha madeira mal marca a pedra e não marca o metal.
	var stone: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(36, 0.31, 28))
	var metal: PhysicsProp = arena._prop(arena.METAL, box, size, Vector3(40, 0.31, 28))
	await _frames(3)
	var same_hit := per_stage * 1.01
	stone.take_hit(Vector3.RIGHT * same_hit)
	metal.take_hit(Vector3.RIGHT * same_hit)
	await _frames(2)
	_check(stone.get_break_stage() == 0 and stone.get_break_damage() > 0.0, "o mesmo golpe só arranha a pedra (%.0f de %.0f N·s por estágio)" % [stone.get_break_damage(), stone.stage_impulse()])
	_check(metal.get_break_damage() == 0.0, "e não marca o metal (abaixo do mínimo de %.0f N·s)" % (metal.stage_impulse() * arena.METAL.break_min_fraction))

	# Queda: de 20 m a madeira racha ao bater no chão; de 1 m não.
	var high: PhysicsProp = arena._prop(wood, box, size, Vector3(32, 20, 33))
	var low: PhysicsProp = arena._prop(wood, box, size, Vector3(36, 1.3, 33))
	await _frames(150)
	_check(not is_instance_valid(high) or high.get_break_stage() >= 1, "queda de 20 m racha a caixa (bate a ~%.0f m/s; racha acima de %.0f)" % [sqrt(2.0 * 9.8 * 19.7), wood.break_impact_speed])
	_check(is_instance_valid(low) and low.get_break_stage() == 0, "queda de 1 m não racha")

	# Explosão também é golpe: a caixa ao lado do barril vira pedaços.
	var near: PhysicsProp = arena._prop(wood, box, size, Vector3(40, 0.31, 38))
	var barrel: PhysicsProp = arena._prop(arena.EXPLOSIVE, PhysicsProp.Form.CYLINDER, Vector3(0.6, 0.9, 0.6), Vector3(41.2, 0.46, 38))
	await _frames(5)
	var near_result := {"broke": false}
	near.shattered.connect(func(_p: Array) -> void: near_result["broke"] = true)
	barrel.explode()
	await _frames(2)
	_check(near_result["broke"], "explosão a 1,2 m parte a caixa de madeira")
	await _unload(arena)


# Pedaços herdam calor, fogo e combustível; barril quebrado explode; construções usam a mesma lei.
func _test_break_inheritance() -> void:
	print("\n--- Lei do Quebrável: o que os pedaços herdam ---")
	var arena := await _load_arena("fire")
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var hot: PhysicsProp = arena._prop(arena.STONE, box, size, Vector3(32, 0.31, 40))
	var lit: PhysicsProp = arena._prop(arena.WOOD, box, size, Vector3(36, 0.31, 40))
	await _frames(5)
	hot.add_heat(300.0)
	lit.ignite()
	await _frames(60)
	var stone_heat := hot.heat
	var fuel := lit.fuel_left()
	var hot_pieces := hot.shatter()
	var lit_pieces := lit.shatter()
	var all_hot: bool = hot_pieces.size() == arena.STONE.break_pieces
	for piece in hot_pieces:
		all_hot = all_hot and absf(piece.heat - stone_heat) < 1.0
	_check(all_hot, "pedra quente vira %d pedaços com o mesmo calor (%.0f)" % [hot_pieces.size(), stone_heat])
	var all_lit: bool = not lit_pieces.is_empty()
	for piece in lit_pieces:
		all_lit = all_lit and piece.burning and absf(piece.fuel_left() - fuel) < 0.05
	_check(all_lit, "caixa queimando vira pedaços queimando com o combustível que sobrou (%.1f s)" % fuel)

	var barrel: PhysicsProp = arena._prop(arena.EXPLOSIVE, PhysicsProp.Form.CYLINDER, Vector3(0.6, 0.9, 0.6), Vector3(42, 0.46, 44))
	await _frames(3)
	var blew := {"yes": false}
	barrel.exploded.connect(func() -> void: blew["yes"] = true)
	var barrel_pieces := barrel.shatter()
	await _frames(2)
	_check(blew["yes"] and barrel_pieces.is_empty(), "barril de pólvora quebrado explode em vez de virar pedaços")

	# Interface para construções que não são PhysicsProp (pilar de pedra): mesma lei, mesmos pedaços.
	# Pilar de 1 x 3 x 1 m em pedra moldada (1050 kg); soco de pedra = 140 x 2 (Terra) = 280 N·s.
	var molded: PropMaterial = load("res://assets/data/materials/earth_construct.tres")
	var pillar_mass := 3.0 * molded.density
	var punch := 280.0
	var pillar_damage := 0.0
	var punches := 0
	while molded.stage_for(pillar_damage, pillar_mass) < PropMaterial.BREAK_STAGES and punches < 50:
		pillar_damage += molded.hit_damage(punch, pillar_mass)
		punches += 1
	_check(punches == 6, "pilar de pedra moldada (%.0f kg) vira pedaços no 6º soco de %.0f N·s (foram %d)" % [pillar_mass, punch, punches])
	_check(arena.STONE.hit_damage(punch, pillar_mass) == 0.0, "o mesmo pilar em pedra bruta nem marcaria (por isso a pedra moldada)")
	var pillar_pieces := PhysicsProp.spawn_pieces(arena, Transform3D(Basis.IDENTITY, Vector3(32, 1.6, 45)), Vector3(1, 3, 1), molded, pillar_mass, Vector3.FORWARD * 3.0)
	var pillar_sum := 0.0
	for piece in pillar_pieces:
		pillar_sum += piece.mass
	_check(pillar_pieces.size() == molded.break_pieces and absf(pillar_sum - pillar_mass) < 0.5, "spawn_pieces parte o pilar em %d pedaços (%.0f kg no total)" % [pillar_pieces.size(), pillar_sum])
	await _unload(arena)


# Desempenho: limite de pedaços vivos, vida curta, pedaços não colidem entre si; custo medido.
func _test_break_limits() -> void:
	print("\n--- Lei do Quebrável: limites e custo ---")
	var arena := await _load_arena("fire")
	var rules := BreakRules.current()
	var stone: PropMaterial = arena.STONE
	await _frames(5)
	var first := PhysicsProp.spawn_pieces(arena, Transform3D(Basis.IDENTITY, Vector3(34, 1, 30)), Vector3(0.6, 0.6, 0.6), stone, 75.0)
	_check(first[0].collision_layer & first[0].collision_mask == 0, "pedaços não colidem entre si (camada %d, máscara %d)" % [first[0].collision_layer, first[0].collision_mask])
	for batch in 12:
		PhysicsProp.spawn_pieces(arena, Transform3D(Basis.IDENTITY, Vector3(30 + batch, 1, 34)), Vector3(0.6, 0.6, 0.6), stone, 75.0)
	await _frames(1)
	_check(PhysicsProp.alive_piece_count() <= rules.max_pieces, "nunca passa de %d pedaços vivos (%d depois de 72 criados)" % [rules.max_pieces, PhysicsProp.alive_piece_count()])
	_check(not is_instance_valid(first[0]), "os pedaços mais antigos somem primeiro")
	var tiny := PhysicsProp.spawn_pieces(arena, Transform3D(Basis.IDENTITY, Vector3(42, 1, 30)), Vector3(0.3, 0.3, 0.3), stone, 10.0)
	_check(not tiny[0].is_in_group(&"heat_receivers") and not tiny[0].contact_monitor, "pedaços pequenos usam física simplificada (sem calor, sem contato)")

	# Vida curta: com 0,5 s de vida, somem em 40 quadros.
	var saved_life := rules.piece_lifetime
	rules.piece_lifetime = 0.5
	var short := PhysicsProp.spawn_pieces(arena, Transform3D(Basis.IDENTITY, Vector3(44, 1, 30)), Vector3(0.6, 0.6, 0.6), stone, 75.0)
	rules.piece_lifetime = saved_life
	await _frames(40)
	_check(not is_instance_valid(short[0]), "pedaços somem sozinhos ao fim do tempo de vida")

	# Custo: quanto leva partir uma caixa e quanto pesa a física com o máximo de pedaços.
	var crates: Array[PhysicsProp] = []
	for i in 10:
		crates.append(arena._prop(arena.WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(30 + i * 1.5, 0.31, 42)))
	await _frames(30)
	var before := await _physics_ms(60)
	var started := Time.get_ticks_usec()
	for crate in crates:
		crate.take_hit(Vector3.UP * crate.stage_impulse() * 4.1)
	var shatter_ms := float(Time.get_ticks_usec() - started) / 1000.0
	var after := await _physics_ms(60)
	print("  custo: partir 10 caixas (%d pedaços) levou %.2f ms; física %.2f ms/quadro antes, %.2f ms com os pedaços" % [PhysicsProp.alive_piece_count(), shatter_ms, before, after])
	_check(shatter_ms < 16.0, "partir 10 caixas de uma vez cabe em um quadro (%.2f ms < 16 ms)" % shatter_ms)
	_check(after - before < 2.0, "pedaços vivos somam menos de 2 ms por quadro na física (+%.2f ms)" % (after - before))
	await _unload(arena)


## Tempo médio (ms) do passo de física nos próximos `frames` quadros.
func _physics_ms(frames: int) -> float:
	var total := 0.0
	for frame in frames:
		await _frames(1)
		total += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	return total / frames


# --- Leis do mundo (physics-magic-system.md, "As leis da fatia") ---------------------------
# Nenhum teste abaixo usa habilidade: só objetos, zonas e consultas do mundo.

## Zona de ambiente em caixa (calor e ar), já dentro da arena.
func _air_zone(arena: Node3D, pos: Vector3, size: Vector3, heat: float, air: float) -> HeatZone:
	var zone := HeatZone.new()
	zone.heat_per_second = heat
	zone.air_factor = air
	zone.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	zone.add_child(shape)
	arena.add_child(zone)
	return zone


## Área de gravidade em caixa, que substitui a gravidade do lugar.
func _gravity_area(arena: Node3D, pos: Vector3, size: Vector3, gravity: float, direction: Vector3) -> Area3D:
	var area := Area3D.new()
	area.gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
	area.gravity = gravity
	area.gravity_direction = direction
	area.collision_mask = 0xFFFFFFFF
	area.position = pos
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	arena.add_child(area)
	return area


# Lei do Fogo: consome combustível e precisa de ar.
func _test_fire_law() -> void:
	print("\n--- Lei do Fogo: combustível e ar ---")
	var arena := await _load_arena("fire")
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	# Combustível: o que queimou não volta ao reacender, e o objeto fica mais leve.
	var fuel_crate: PhysicsProp = arena._prop(wood, box, size, Vector3(30, 0.31, 26))
	fuel_crate.freeze = true
	await _frames(5)
	var full_mass := fuel_crate.mass
	fuel_crate.ignite()
	await _frames(180)
	fuel_crate.extinguish()
	var fuel_after_burn := fuel_crate.fuel_left()
	_check(absf(fuel_after_burn - (wood.burn_time - 3.0)) < 0.2, "fogo consome combustível: 3 s queimando deixam %.1f s de %.0f" % [fuel_after_burn, wood.burn_time])
	_check(fuel_crate.mass < full_mass * 0.95, "queimar deixa o objeto mais leve (%.1f kg -> %.1f kg)" % [full_mass, fuel_crate.mass])
	fuel_crate.ignite()
	await _frames(2)
	_check(fuel_crate.burning and fuel_crate.fuel_left() <= fuel_after_burn, "reacender continua do combustível que sobrou (%.1f s)" % fuel_crate.fuel_left())
	fuel_crate.extinguish()

	# Sem ar: apaga o que queima, o calor não entra e não dá para acender.
	var smothered: PhysicsProp = arena._prop(wood, box, size, Vector3(30, 0.31, 30))
	smothered.freeze = true
	await _frames(5)
	smothered.ignite()
	_air_zone(arena, Vector3(30, 0.5, 30), Vector3(1.4, 1.2, 1.4), 0.0, 0.0)
	await _frames(5)
	_check(not smothered.burning, "zona sem ar apaga o fogo de quem está dentro")
	smothered.add_heat(500.0)
	smothered.ignite()
	await _frames(2)
	_check(not smothered.burning and smothered.heat == 0.0, "sem ar o calor não entra e o objeto não acende (calor %.0f)" % smothered.heat)

	# Braseiro abafado: uma ponta do braseiro dentro da zona sem ar apaga o braseiro inteiro.
	var near_choked: PhysicsProp = arena._prop(wood, box, size, Vector3(34.6, 0.31, 30))
	var near_free: PhysicsProp = arena._prop(wood, box, size, Vector3(34.6, 0.31, 34))
	near_choked.freeze = true
	near_free.freeze = true
	_air_zone(arena, Vector3(34, 0.5, 30), Vector3(2, 1, 2), 100.0, 1.0)
	_air_zone(arena, Vector3(34, 0.5, 34), Vector3(2, 1, 2), 100.0, 1.0)
	var choke := _air_zone(arena, Vector3(33.1, 0.5, 30), Vector3(0.4, 1, 0.4), 0.0, 0.0)
	await _frames(150)
	_check(near_free.burning, "braseiro com ar acende a madeira em 2,5 s")
	_check(not near_choked.burning and near_choked.heat == 0.0, "braseiro tocado por zona sem ar não aquece (calor %.0f)" % near_choked.heat)
	choke.queue_free()
	await _frames(150)
	_check(near_choked.burning, "sem a zona sem ar, o braseiro volta a aquecer e acende")
	await _unload(arena)


# Lei do Fogo, lado da pedra: pedra aquecida guarda calor e aquece quem está perto.
func _test_hot_stone() -> void:
	print("\n--- Lei do Fogo: pedra guarda calor ---")
	var arena := await _load_arena("fire")
	var stone_data: PropMaterial = arena.STONE
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var lone_stone: PhysicsProp = arena._prop(stone_data, box, size, Vector3(44, 0.31, 26))
	var lone_wood: PhysicsProp = arena._prop(arena.WOOD, box, size, Vector3(44, 0.31, 30))
	lone_stone.freeze = true
	lone_wood.freeze = true
	await _frames(5)
	lone_stone.add_heat(1000.0)
	_check(lone_stone.heat == stone_data.max_heat and not lone_stone.burning, "pedra esquenta até o máximo (%.0f) e não pega fogo" % lone_stone.heat)
	lone_stone.heat = 200.0
	lone_wood.add_heat(60.0)
	await _frames(300)
	_check(lone_stone.heat > 150.0, "pedra sozinha guarda o calor: 200 -> %.0f em 5 s" % lone_stone.heat)
	_check(lone_wood.heat == 0.0, "madeira perde o calor no mesmo tempo (%.0f)" % lone_wood.heat)

	# Pedra em brasa acende a madeira encostada, e perde o calor que entrega.
	var hot: PhysicsProp = arena._prop(stone_data, box, size, Vector3(40, 0.31, 26))
	var crate: PhysicsProp = arena._prop(arena.WOOD, box, size, Vector3(40.8, 0.31, 26))
	hot.freeze = true
	crate.freeze = true
	await _frames(5)
	hot.add_heat(1000.0)
	var lit_at := -1.0
	for frame in 300:
		await _frames(1)
		if crate.burning:
			lit_at = frame / 60.0
			break
	print("  madeira a 0,8 m da pedra em brasa acendeu em %.1f s; pedra ficou com %.0f de calor" % [lit_at, hot.heat])
	_check(lit_at > 0.0, "pedra em brasa acende madeira a 0,8 m sem chama nenhuma")
	_check(hot.heat < stone_data.max_heat * 0.8, "a pedra esfria ao entregar calor (%.0f)" % hot.heat)
	await _unload(arena)


# Lei da Terra: o mundo diz qual material há sob um ponto; só solo e pedra são da Terra.
func _test_earth_law() -> void:
	print("\n--- Lei da Terra: o chão que existe ali ---")
	var arena := await _load_arena("fire")
	var crate: PhysicsProp = arena._prop(arena.WOOD, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(38, 0.31, 36))
	var block: PhysicsProp = arena._prop(arena.STONE, PhysicsProp.Form.BOX, Vector3(0.6, 0.6, 0.6), Vector3(40, 0.31, 36))
	await _frames(20)
	var floor_material := PropMaterial.ground_under(arena, Vector3(36, 0.5, 36))
	_check(floor_material != null and floor_material.resource_path.ends_with("concrete.tres") and floor_material.earth_workable, "chão da arena é concreto e a Terra trabalha nele (%s)" % (floor_material.display_name if floor_material else "nada"))
	var on_crate := PropMaterial.ground_under(arena, Vector3(38, 1.0, 36))
	_check(on_crate == arena.WOOD and not on_crate.earth_workable, "em cima de uma caixa de madeira a Terra não tem com o que trabalhar")
	var on_stone := PropMaterial.ground_under(arena, Vector3(40, 1.0, 36))
	_check(on_stone == arena.STONE and on_stone.earth_workable, "em cima de um bloco de pedra a Terra trabalha")
	_check(PropMaterial.ground_under(arena, Vector3(36, 10, 36)) == null, "no ar, sem chão a 2 m, não há material para a Terra")
	_check(PropMaterial.of(block).earth_force_factor > PropMaterial.of(crate).earth_force_factor, "pedra responde mais forte à Terra que madeira (%.1fx contra %.1fx)" % [PropMaterial.of(block).earth_force_factor, PropMaterial.of(crate).earth_force_factor])
	await _unload(arena)


# Lei da Gravidade: muda peso e direção da queda de tudo que tem massa (objetos e monstros; o mago não, decisão do Liam).
func _test_gravity_law() -> void:
	print("\n--- Lei da Gravidade: peso e direção ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	var g := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	_gravity_area(arena, Vector3(30, 4, 42), Vector3(6, 8, 4), g * 3.0, Vector3.DOWN)
	_gravity_area(arena, Vector3(42, 4, 42), Vector3(6, 8, 4), g, Vector3.RIGHT)
	await _frames(5)
	var heavy: PhysicsProp = arena._prop(wood, box, size, Vector3(30, 5, 42))
	var normal: PhysicsProp = arena._prop(wood, box, size, Vector3(36, 5, 42))
	var sideways: PhysicsProp = arena._prop(wood, box, size, Vector3(40, 5, 42))
	await _frames(3)
	var ratio := heavy.get_weight() / normal.get_weight()
	_check(absf(ratio - 3.0) < 0.15, "gravidade 3x triplica o peso do mesmo objeto (%.2fx)" % ratio)
	await _frames(20)
	_check(heavy.global_position.y < normal.global_position.y - 0.5, "o objeto mais pesado cai mais rápido (y %.2f contra %.2f)" % [heavy.global_position.y, normal.global_position.y])
	_check(sideways.global_position.x > 40.3 and sideways.global_position.y > 4.8, "gravidade de lado faz o objeto 'cair' para o lado (x %.2f, y %.2f)" % [sideways.global_position.x, sideways.global_position.y])
	_check(heavy.mass == normal.mass, "a gravidade muda o peso, não a massa (nada é criado)")

	# O mago não obedece às áreas de gravidade (decisão do Liam, opção c): só às próprias habilidades.

	# Gravidade x Fogo: o mesmo barril de 2,5 m só detona (impacto >= 9 m/s) onde pesa 3x.
	var barrel_size := Vector3(0.6, 0.9, 0.6)
	_gravity_area(arena, Vector3(30, 4, 47), Vector3(4, 8, 4), g * 3.0, Vector3.DOWN)
	await _frames(5)
	var heavy_barrel: PhysicsProp = arena._prop(arena.EXPLOSIVE, PhysicsProp.Form.CYLINDER, barrel_size, Vector3(30, 2.95, 47))
	var normal_barrel: PhysicsProp = arena._prop(arena.EXPLOSIVE, PhysicsProp.Form.CYLINDER, barrel_size, Vector3(42, 2.95, 47))
	var blew := {"heavy": false, "normal": false}
	heavy_barrel.exploded.connect(func() -> void: blew["heavy"] = true)
	normal_barrel.exploded.connect(func() -> void: blew["normal"] = true)
	var top_speed := {"heavy": 0.0, "normal": 0.0}
	for frame in 90:
		await _frames(1)
		if is_instance_valid(heavy_barrel):
			top_speed["heavy"] = maxf(top_speed["heavy"], heavy_barrel.last_speed)
		if is_instance_valid(normal_barrel):
			top_speed["normal"] = maxf(top_speed["normal"], normal_barrel.last_speed)
	print("  velocidade de queda do barril: 3x %.1f m/s, normal %.1f m/s (detona a %.0f)" % [top_speed["heavy"], top_speed["normal"], arena.EXPLOSIVE.impact_detonation_speed])
	_check(blew["heavy"], "barril solto a 2,5 m na gravidade 3x explode ao bater no chão")
	_check(not blew["normal"] and is_instance_valid(normal_barrel), "o mesmo barril na gravidade normal não explode")
	await _unload(arena)


# Degraus: até 0,4 m sobe só andando; 0,5 m exige pulo; a escada de 0,2 m chega a 2 m.
func _test_steps() -> void:
	print("\n--- Degraus: subir andando ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	var rules: AttributeRules = player.rules
	# Fileira de alturas em x = -10: 0,4 m em z = 3, 0,5 m em z = 0.
	player.global_position = Vector3(-10, 0.05, 6)
	await _frames(5)
	await _walk_toward(player, Vector3(-10, 1.6, -30), 40)
	_check(player.is_on_floor() and absf(player.global_position.y - rules.step_height) < 0.05, "sobe degrau de %.1f m só andando (y %.2f)" % [rules.step_height, player.global_position.y])
	player.global_position = Vector3(-10, 0.05, 2.6)
	await _frames(5)
	await _walk_toward(player, Vector3(-10, 1.6, -30), 40)
	_check(player.global_position.y < 0.1, "degrau de 0,5 m bloqueia sem pular (y %.2f)" % player.global_position.y)
	# Escada até a plataforma de 2 m (x = -20).
	player.global_position = Vector3(-20, 0.05, 15)
	await _frames(5)
	player.face_point(Vector3(-20, 3.6, 0))
	var stair_top := 0.0
	Input.action_press("move_forward")
	for i in 90:
		await _frames(1)
		stair_top = maxf(stair_top, player.global_position.y)
	Input.action_release("move_forward")
	await _frames(10)
	_check(stair_top > 1.9, "escada de 0,2 m chega à plataforma de 2 m (topo %.2f m)" % stair_top)
	# Rampa de 30° (x = -30, z = -2) continua subindo normal com o corpo cilíndrico.
	player.global_position = Vector3(-30, 0.05, 4)
	await _frames(5)
	await _walk_toward(player, Vector3(-30, 3.6, -10), 70)
	_check(player.global_position.y > 1.0, "sobe a rampa de 30° andando (y %.2f)" % player.global_position.y)

	await _unload(arena)


# Regressão: subir escada com ritmo regular, sem perder velocidade nem dar tranco na câmera.
func _test_stair_rhythm() -> void:
	print("\n--- Ritmo da subida ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	# Mais longe que o pé da escada (x = -20), para chegar já na velocidade de andar.
	player.global_position = Vector3(-20, 0.05, 17)
	player.face_point(Vector3(-20, 1.6, -10))
	await _frames(5)
	Input.action_press("move_forward")
	var last_y := player.global_position.y
	var last_z := player.global_position.z
	var camera_trace := CameraTrace.new(player)
	add_child(camera_trace)
	var last_step := -1
	var intervals: Array[float] = []
	var speeds: Array[float] = []
	for i in 120:
		await _frames(1)
		var y := player.global_position.y
		if y > 1.95:
			break
		if y - last_y > 0.05:
			if last_step >= 0:
				intervals.append(i - last_step)
			last_step = i
		if last_step >= 0:
			speeds.append(absf(player.global_position.z - last_z) * 60.0)
		last_y = y
		last_z = player.global_position.z
	Input.action_release("move_forward")
	camera_trace.queue_free()
	var max_camera_rise := camera_trace.max_rise(1.0 / Engine.physics_ticks_per_second)
	print("  quadros entre degraus: %s" % [intervals])
	print("  avanço máx/mín: %.2f / %.2f m/s; câmera: máx %.3f m em 1/60 s, %.3f m por quadro desenhado (%d quadros)" % [speeds.max(), speeds.min(), max_camera_rise, camera_trace.max_frame_rise(), camera_trace.times.size()])
	_check(intervals.size() >= 7 and intervals.max() - intervals.min() <= 1.0, "intervalo entre degraus regular (%s quadros)" % [intervals])
	_check(speeds.max() <= player.stats.walk_speed * 1.15 and speeds.min() >= player.stats.walk_speed * 0.8, "velocidade constante na escada (%.2f a %.2f m/s)" % [speeds.min(), speeds.max()])
	_check(max_camera_rise < 0.09, "câmera sobe sem tranco (máx %.3f m em 1/60 s)" % max_camera_rise)
	await _unload(arena)


# Regressão: passar pela quina do degrau não dá solavanco nem engasgo, andando ou correndo.
# Pontos de partida em que o corpo era empurrado para cima ou parava contra o degrau seguinte.
func _test_stair_no_jolt() -> void:
	print("\n--- Escada sem solavanco ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	for start: Array in [[false, 17.111], [false, 17.185], [true, 17.111], [true, 17.333]]:
		var sprint: bool = start[0]
		var label := "%s de z = %.3f" % ["correndo" if sprint else "andando", start[1]]
		player.global_position = Vector3(-20, 0.05, start[1])
		player.velocity = Vector3.ZERO
		player.face_point(Vector3(-20, 1.6, -10))
		await _frames(10)
		if sprint:
			Input.action_press("sprint")
		Input.action_press("move_forward")
		# Espera chegar à velocidade máxima, ainda antes do primeiro degrau.
		await _frames(25)
		var camera_trace := CameraTrace.new(player)
		add_child(camera_trace)
		var last_z := player.global_position.z
		var min_speed := INF
		for i in 120:
			await _frames(1)
			if player.global_position.y > 1.95:
				break
			min_speed = minf(min_speed, absf(player.global_position.z - last_z) * 60.0)
			last_z = player.global_position.z
		Input.action_release("move_forward")
		Input.action_release("sprint")
		camera_trace.queue_free()
		var max_camera_rise := camera_trace.max_rise(1.0 / Engine.physics_ticks_per_second)
		var goal := player.stats.sprint_speed if sprint else player.stats.walk_speed
		_check(min_speed >= goal * 0.9, "%s não engasga na escada (mín %.2f de %.2f m/s)" % [label, min_speed, goal])
		_check(max_camera_rise < 0.085, "%s não dá solavanco (máx %.3f m em 1/60 s)" % [label, max_camera_rise])
		await _frames(15)
	await _unload(arena)


# Grava a altura da câmera a cada quadro desenhado, depois do _process do jogador.
# A câmera anda em _process, e sem janela cabem 2 ou 3 quadros em cada tick de física: comparar tick
# com tick mediria ora 14 ms, ora 21 ms de subida. Por isso a medida usa uma janela de tempo fixa.
class CameraTrace extends Node:
	var times: Array[float] = []
	var heights: Array[float] = []
	var _player: Player

	func _init(player: Player) -> void:
		_player = player
		process_priority = 1000

	func _process(delta: float) -> void:
		times.append((times.back() if not times.is_empty() else 0.0) + delta)
		heights.append(_player.get_aim_origin().y)

	## Maior subida da câmera em qualquer intervalo de `window` segundos (interpola entre quadros).
	func max_rise(window: float) -> float:
		var best := 0.0
		var j := 0
		for i in range(1, times.size()):
			var start_time := times[i] - window
			if start_time < times[0]:
				continue
			while times[j + 1] < start_time:
				j += 1
			var start := lerpf(heights[j], heights[j + 1], inverse_lerp(times[j], times[j + 1], start_time))
			best = maxf(best, heights[i] - start)
		return best

	## Maior subida entre dois quadros desenhados seguidos.
	func max_frame_rise() -> float:
		var best := 0.0
		for i in range(1, heights.size()):
			best = maxf(best, heights[i] - heights[i - 1])
		return best


# O dash saiu de todas as classes (design/gdd/mage-earth.md); E pega e arremessa em todas.
func _test_grab_and_throw() -> void:
	print("\n--- Sem dash; E pega e arremessa ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	for data in GameState.CLASSES:
		_check(not data.utility_ability is DashAbility, "%s não tem dash" % data.display_name)
	_check(InputMap.has_action("grab") and _has_key(&"grab", KEY_E), "E é a tecla de pegar")
	_check(InputMap.has_action("secondary") and InputMap.action_get_events(&"secondary").any(func(e: InputEvent) -> bool: return e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_RIGHT), "botão direito é a habilidade secundária")

	# E pega a caixa mirada; o botão esquerdo não arremessa o que está nas mãos.
	var crate := _nearest_crate(arena, player)
	player.global_position = crate.global_position + Vector3(0, -0.3, 1.6)
	await _frames(10)
	player.face_point(crate.global_position)
	await _frames(3)
	_press_key(KEY_E)
	await _frames(20)
	_check(player.held_body == crate, "E pega a caixa")
	player.request_action(Player.SLOT_PRIMARY)
	await _frames(5)
	_check(player.held_body == crate, "botão esquerdo não arremessa o que está nas mãos")

	# Arremesso com E herda o movimento de quem arremessa.
	player.release_held()
	crate.global_position = player.get_aim_origin() + Vector3(0, 0, 1.5)
	player.hold(crate, {"telekinetic": false, "distance": 1.5, "stiffness": 10.0, "throw_speed": 5.0, "carry_mass": 1000.0, "drain": 0.0})
	player.face_point(player.get_aim_origin() + Vector3(0, 0, 10))
	await _frames(3)
	player.velocity = Vector3(0, 0, 7)
	player.request_action(Player.ACTION_GRAB)
	await _frames(1)
	_check(player.held_body == null and crate.linear_velocity.z > 10.0, "E arremessa, e correndo soma o movimento (%.1f m/s)" % crate.linear_velocity.z)
	await _unload(arena)


func _has_key(action: StringName, key: Key) -> bool:
	return InputMap.action_get_events(action).any(func(e: InputEvent) -> bool: return e is InputEventKey and e.physical_keycode == key)


# Parede e pilar protegem de explosões; caixa solta e o próprio chão, não
# (design/gdd/physics-magic-system.md).
func _test_explosion_occlusion() -> void:
	print("\n--- Explosão: paredes protegem ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	var dummy: TrainingDummy = arena.dummy
	var factor: float = Explosion.DAMAGE.blocked_explosion_factor
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	# Dois lugares iguais, longe de tudo: um com parede entre a explosão e o alvo, outro sem.
	var open_site := Vector3(35, 0.5, -40)
	var walled_site := Vector3(35, 0.5, -25)
	arena._static_box(walled_site + Vector3(0, 1, 0.75), Vector3(4, 3, 0.3), null)
	var target := Vector3(0, -0.19, 1.5)

	var open_crate: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	var walled_crate: PhysicsProp = arena._prop(wood, box, size, walled_site + target)
	await _frames(20)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 50.0)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 50.0)
	await _frames(2)
	print("  caixa: calor %.1f sem parede, %.1f com parede; velocidade %.1f e %.1f m/s" % [open_crate.heat, walled_crate.heat, open_crate.linear_velocity.length(), walled_crate.linear_velocity.length()])
	_check(open_crate.heat > 15.0 and walled_crate.heat <= open_crate.heat * factor * 1.1, "parede corta o calor da explosão")
	_check(walled_crate.linear_velocity.length() < open_crate.linear_velocity.length() * 0.4, "parede corta o empurrão da explosão")
	open_crate.queue_free()
	walled_crate.queue_free()
	await _frames(3)

	# Boneco e jogador: a origem deles fica nos pés, mas o raio mira o centro do corpo.
	dummy.global_position = open_site + Vector3(0, -0.5, 1.5)
	await _frames(3)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 0.0)
	var open_damage := dummy.combo_damage
	dummy.reset()
	dummy.global_position = walled_site + Vector3(0, -0.5, 1.5)
	await _frames(3)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 0.0)
	_check(open_damage > 5.0 and dummy.combo_damage < open_damage * 0.3, "boneco atrás da parede quase não toma dano (%.1f x %.1f)" % [dummy.combo_damage, open_damage])
	dummy.global_position = Vector3(0, 0, 3)
	await _frames(3)
	var knockback: Array[float] = []
	for site: Vector3 in [open_site, walled_site]:
		player.global_position = site + Vector3(0, -0.45, 1.5)
		player.velocity = Vector3.ZERO
		await _frames(2)
		player.velocity = Vector3.ZERO
		Explosion.detonate(arena, site, 3.0, 400.0, 0.0)
		knockback.append(player.velocity.length())
		await _frames(2)
	_check(knockback[0] > 1.0 and knockback[1] < knockback[0] * 0.4, "jogador atrás da parede é pouco empurrado (%.1f x %.1f m/s)" % [knockback[1], knockback[0]])
	player.respawn()
	await _frames(3)

	# Pilar também é cobertura.
	var pillar_site := Vector3(45, 0.5, -40)
	var pillar := StonePillar.new()
	pillar.height = 3.0
	arena.add_child(pillar)
	pillar.start(Vector3(45, 0, -39.25), Vector3.FORWARD)
	await _frames(40)
	var covered: PhysicsProp = arena._prop(wood, box, size, pillar_site + target)
	await _frames(20)
	Explosion.detonate(arena, pillar_site, 3.0, 200.0, 50.0)
	_check(covered.heat < 10.0, "pilar protege (calor %.1f)" % covered.heat)
	covered.queue_free()
	pillar.queue_free()
	await _frames(3)

	# Caixa solta no caminho não vira escudo.
	var behind: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	var shield: PhysicsProp = arena._prop(wood, box, size, open_site + Vector3(0, -0.19, 0.7))
	await _frames(20)
	Explosion.detonate(arena, open_site, 3.0, 200.0, 50.0)
	_check(behind.heat > 15.0, "caixa solta no caminho não protege (calor %.1f)" % behind.heat)
	behind.queue_free()
	shield.queue_free()
	await _frames(3)

	# Explosão rente ao chão não se bloqueia nele.
	var near_floor: PhysicsProp = arena._prop(wood, box, size, open_site + target)
	await _frames(20)
	Explosion.detonate(arena, Vector3(open_site.x, 0.0, open_site.z), 3.0, 200.0, 50.0)
	_check(near_floor.heat > 15.0, "explosão rente ao chão não se bloqueia nele (calor %.1f)" % near_floor.heat)
	near_floor.queue_free()
	await _frames(3)

	# Acerto direto ignora a parede.
	var hit_crate: PhysicsProp = arena._prop(wood, box, size, walled_site + target)
	await _frames(20)
	Explosion.detonate(arena, walled_site, 3.0, 200.0, 50.0, [], Color.WHITE, hit_crate)
	_check(is_equal_approx(hit_crate.heat, 50.0), "acerto direto ignora a parede (calor %.1f)" % hit_crate.heat)
	await _unload(arena)


# Mede a distância real em que o fogo pula entre caixas de madeira, e a pirâmide inteira.
func _test_fire_spread() -> void:
	print("\n--- Contágio de fogo: medição ---")
	var arena := await _load_arena("fire")
	var wood: PropMaterial = arena.WOOD
	var box := PhysicsProp.Form.BOX
	var size := Vector3(0.6, 0.6, 0.6)
	var distances: Array[float] = [0.5, 0.62, 0.7, 0.85, 0.93, 1.1, 1.3]
	var neighbors: Array[PhysicsProp] = []
	var sources: Array[PhysicsProp] = []
	for i in distances.size():
		var base := Vector3(35, 0.31, -45 + i * 5.0)
		var source: PhysicsProp = arena._prop(wood, box, size, base)
		var neighbor: PhysicsProp = arena._prop(wood, box, size, base + Vector3(distances[i], 0, 0))
		source.freeze = true
		neighbor.freeze = true
		sources.append(source)
		neighbors.append(neighbor)
	# Três caixas em chamas a 0,9 m da mesma vizinha: o calor soma.
	var center := Vector3(45, 0.31, -30)
	var surrounded: PhysicsProp = arena._prop(wood, box, size, center)
	surrounded.freeze = true
	for direction: Vector3 in [Vector3(0.9, 0, 0), Vector3(-0.9, 0, 0), Vector3(0, 0, 0.9)]:
		var source: PhysicsProp = arena._prop(wood, box, size, center + direction)
		source.freeze = true
		sources.append(source)
	# Pirâmide da arena (x de 11 a 13, z = -2), acesa por uma caixa da base.
	var pyramid: Array[PhysicsProp] = []
	for node in arena.get_children():
		if node is PhysicsProp and node.material_data == wood and absf(node.global_position.z + 2.0) < 0.1 and node.global_position.x < 14.0:
			pyramid.append(node)
	await _frames(20)
	for source in sources:
		source.ignite()
	pyramid[0].ignite()

	var ignition_time := {}
	var pyramid_lit := {}
	var pyramid_full := -1.0
	var watched: Array[PhysicsProp] = neighbors.duplicate()
	watched.append(surrounded)
	for frame in 1200:
		await _frames(1)
		for crate in watched:
			if is_instance_valid(crate) and crate.burning and not ignition_time.has(crate):
				ignition_time[crate] = frame / 60.0
		for crate in pyramid:
			if not pyramid_lit.has(crate) and (not is_instance_valid(crate) or crate.burning):
				pyramid_lit[crate] = true
		if pyramid_full < 0.0 and pyramid_lit.size() == pyramid.size():
			pyramid_full = frame / 60.0
	for i in distances.size():
		var time: float = ignition_time.get(neighbors[i], -1.0)
		print("  %.2f m entre centros: %s" % [distances[i], "acende em %.1f s" % time if time >= 0.0 else "não acende"])
	print("  3 em chamas a 0,90 m: acende em %.1f s" % ignition_time.get(surrounded, -1.0))
	print("  pirâmide: %d de %d acesas; todas em %.1f s" % [pyramid_lit.size(), pyramid.size(), pyramid_full])
	_check(ignition_time.has(neighbors[0]), "caixa a 0,5 m acende a vizinha")
	_check(not ignition_time.has(neighbors[5]), "caixa a 1,1 m não acende a vizinha")
	_check(ignition_time.has(surrounded), "três caixas a 0,9 m somam calor e acendem")
	await _unload(arena)

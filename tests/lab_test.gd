extends Node
## Teste do Laboratório do Sábio (design/sabio/laboratorio.md): verifica cada módulo presente em
## assets/data/lab/ e pula os que foram apagados.
## Rodar: ver tests/README.md ou design/sabio/laboratorio.md. Sai com código 0 ou 1.

const LAB := preload("res://src/levels/sabio_lab.tscn")
const WOOD := preload("res://assets/data/materials/wood.tres")
const EXPLOSIVE := preload("res://assets/data/materials/explosive.tres")
const METAL := preload("res://assets/data/materials/metal.tres")
const BENCH := Vector3(35, 0, 30)

var _checks := 0
var _failures: Array[String] = []
var _arena: Node3D
var _lab: LabController


func _ready() -> void:
	GameState.selected_class = GameState.find_class("mage")
	_arena = LAB.instantiate()
	add_child(_arena)
	_lab = _arena.get_node("LabController")
	await _frames(5)

	_check(_lab.modules.size() > 0, "módulos carregados: %d" % _lab.modules.size())
	var props := get_tree().get_nodes_in_group(&"physics_props")
	_check(props.size() > 0 and props.all(func(p: Node) -> bool: return p is LabProp), "todos os objetos viraram LabProp (%d)" % props.size())

	await _test_water()
	await _test_web()
	await _test_oil()
	await _test_frost()
	await _test_dead_ground()
	await _test_mud_fire()
	await _test_arsonist()
	await _test_toggle()

	print("\n=== LAB TEST: %d verificações, %d falhas ===" % [_checks, _failures.size()])
	for failure in _failures:
		print("  FALHOU: " + failure)
	get_tree().quit(1 if _failures.size() > 0 else 0)


func _test_water() -> void:
	var module := _lab.find_module("Água e Molhado") as LabWaterModule
	if module == null:
		return
	var dry := _prop(WOOD, BENCH + Vector3(-6, 0.31, 0))
	var wood := _prop(WOOD, BENCH + Vector3(0, 0.31, 0))
	var barrel := _prop(EXPLOSIVE, BENCH + Vector3(1, 0.46, 0))
	await _frames(3)
	module.spawn_puddle(BENCH)
	await _frames(5)
	_check(wood.has_state(LabWetStatus.STATE), "poça deixa a caixa Molhada")
	_check(wood.get_display_name().contains("Molhado"), "a mira mostra Molhado: %s" % wood.get_display_name())
	# Bola de Fogo cheia do Elementalista inicial: 178 de calor.
	dry.add_heat(178.0)
	wood.add_heat(178.0)
	_check(dry.burning, "caixa seca acende com 178 de calor")
	_check(not wood.burning, "caixa Molhada não acende com 178 de calor")
	barrel.add_heat(500.0)
	barrel.explode()
	await _frames(2)
	_check(is_instance_valid(barrel) and not barrel.burning, "pólvora Molhada não acende nem explode")
	dry.extinguish()
	var fuse := _prop(EXPLOSIVE, BENCH + Vector3(-1, 0.46, 0))
	await _frames(1)
	fuse.ignite()
	await _frames(5)
	_check(not fuse.burning, "água apaga o pavio aceso")
	await _clear_bench(module)


func _test_web() -> void:
	var module := _lab.find_module("Teia") as LabWebModule
	if module == null:
		return
	var player: Player = _arena.get("player")
	var dummy: TrainingDummy = _arena.get("dummy")
	# Sem teia: dano de referência.
	dummy.reset()
	dummy.add_heat(80.0)
	var plain := dummy.fire_damage
	# A mira inicial do jogador olha para o boneco.
	var webs := module.webs
	_check(module.use(player) == "", "Teia acerta o boneco na mira")
	_check(module.webs == webs - 1, "Teia gasta 1 reagente")
	dummy.reset()
	var web := _find_web(dummy)
	_check(web != null, "boneco recebe o casulo")
	if web:
		web.add_heat(80.0)
		dummy.add_heat(80.0)
		_check(dummy.fire_damage > plain * 1.2, "fogo em alvo preso dói mais (%.1f x %.1f)" % [dummy.fire_damage, plain])
	await _frames(2)
	_check(_find_web(dummy) == null, "casulo queima e some")

	var box := _prop(WOOD, BENCH + Vector3(0, 0.31, 0))
	await _frames(3)
	module.trap(box, box.global_position)
	await _frames(2)
	box.linear_velocity = Vector3(3, 0, 0)
	await _frames(20)
	_check(box.linear_velocity.length() < 0.5, "caixa presa quase não se move (%.2f m/s)" % box.linear_velocity.length())
	box.apply_central_impulse(Vector3(0, 0, 400))
	await _frames(3)
	_check(_find_web(box) == null, "impacto forte arrebenta a teia")
	box.queue_free()

	var wood := _prop(WOOD, BENCH + Vector3(3, 0.31, 0))
	await _frames(3)
	module.trap(wood, wood.global_position)
	await _frames(2)
	wood.add_heat(12.0)
	await _frames(2)
	_check(wood.burning, "pouco calor queima a teia e acende a caixa presa")
	wood.queue_free()
	_arena.call("spawn_flying_targets")
	await _frames(2)
	var target: FlyingTarget = _arena.get("flying_targets")[0]
	var speed := target.orbit_speed
	module.trap(target, target.global_position)
	await _frames(2)
	_check(target.orbit_speed == 0.0, "alvo voador preso para")
	_find_web(target).add_heat(100.0)
	await _frames(2)
	_check(target.orbit_speed == speed, "alvo volta a voar quando a teia queima")
	await _clear_bench(module)


func _test_oil() -> void:
	var module := _lab.find_module("Óleo") as LabOilModule
	if module == null:
		return
	var oil := module.spawn_oil(BENCH)
	var box := _prop(WOOD, BENCH + Vector3(0.5, 0.31, 0))
	await _frames(5)
	# Explosão real no meio da mancha: o calor precisa alcançar a superfície.
	Explosion.detonate(_arena, BENCH + Vector3(2, 0.2, 0), 2.0, 0.0, 30.0, [])
	await _frames(2)
	_check(oil.burning, "explosão acende o óleo")
	await _seconds(1.5)
	_check(is_instance_valid(box) and box.burning, "óleo em chamas acende a caixa dentro")
	await _clear_bench(module)


func _test_frost() -> void:
	var module := _lab.find_module("Frio e Gelo") as LabFrostModule
	var water := _lab.find_module("Água e Molhado") as LabWaterModule
	if module == null:
		return
	var box := _prop(WOOD, BENCH + Vector3(3, 0.31, 0))
	await _frames(3)
	box.add_heat(80.0)
	module.blast(box.global_position)
	_check(box.heat == 0.0, "frio retira o calor acumulado")
	box.queue_free()
	if water:
		water.spawn_puddle(BENCH)
		await _frames(2)
		module.blast(BENCH)
		await _frames(2)
		_check(get_tree().get_nodes_in_group(&"lab_puddles").is_empty(), "frio transforma poça em gelo")
		var ice_box := _prop(METAL, BENCH + Vector3(-1.5, 0.26, 0))
		await _frames(10)
		ice_box.linear_velocity = Vector3(3, 0, 0)
		await _seconds(0.5)
		var on_ice := ice_box.linear_velocity.length()
		var floor_box := _prop(METAL, BENCH + Vector3(-1.5, 0.26, 6))
		await _frames(10)
		floor_box.linear_velocity = Vector3(3, 0, 0)
		await _seconds(0.5)
		var on_floor := floor_box.linear_velocity.length()
		_check(on_ice > on_floor + 0.5, "objeto desliza mais no gelo (%.2f x %.2f m/s)" % [on_ice, on_floor])
		ice_box.queue_free()
		floor_box.queue_free()
		water.on_disabled()
	await _clear_bench(module)


func _test_dead_ground() -> void:
	var module := _lab.find_module("Terra Morta") as LabDeadGroundModule
	if module == null:
		return
	var mud := MudPatch.new()
	_arena.add_child(mud)
	mud.global_position = BENCH
	var box := _prop(WOOD, BENCH + Vector3(0, 0.31, 0))
	var bolt := MaterializedProjectile.new()
	var bolt_shape := CollisionShape3D.new()
	bolt_shape.shape = SphereShape3D.new()
	bolt.add_child(bolt_shape)
	bolt.gravity_scale = 0.0
	bolt.position = BENCH + Vector3(1, 0.6, 0)
	await _frames(3)
	module.spawn_zone(BENCH)
	await _frames(3)
	_arena.add_child(bolt)
	await _frames(5)
	_check(not is_instance_valid(mud), "Terra Morta apaga o Lamaçal")
	_check(not is_instance_valid(bolt), "Terra Morta desfaz projétil mágico")
	_check(is_instance_valid(box), "objeto físico continua")
	box.queue_free()
	await _clear_bench(module)


func _test_mud_fire() -> void:
	var module := _lab.find_module("Lama e fogo") as LabMudFireModule
	if module == null:
		return
	var zone: HeatZone = null
	for child in _arena.get_children():
		if child is HeatZone:
			zone = child
	var box := _prop(WOOD, BENCH + Vector3(0, 0.31, 0))
	var mud := MudPatch.new()
	_arena.add_child(mud)
	mud.global_position = BENCH
	var brazier_mud := MudPatch.new()
	_arena.add_child(brazier_mud)
	brazier_mud.global_position = Vector3(zone.global_position.x, 0, zone.global_position.z)
	await _frames(3)
	_check(not zone.is_physics_processing(), "lama apaga o braseiro")
	box.add_heat(1000.0)
	_check(not box.burning, "objeto na lama ignora o calor")
	brazier_mud.queue_free()
	mud.queue_free()
	box.queue_free()
	await _frames(3)
	_check(zone.is_physics_processing(), "braseiro volta quando a lama some")


func _test_arsonist() -> void:
	var module := _lab.find_module("Incendiário") as LabArsonistModule
	if module == null:
		return
	var barrel := _prop(EXPLOSIVE, BENCH + Vector3(4, 0.46, 0))
	await _frames(3)
	var arsonist := module.spawn(BENCH)
	await _seconds(2.5)
	_check(not is_instance_valid(barrel) or barrel.burning, "Incendiário acende o barril")
	_check(is_instance_valid(arsonist) and arsonist.state == LabArsonist.State.FLEE, "Incendiário foge depois de acender")
	await _seconds(1.0)
	await _clear_bench(module)


func _test_toggle() -> void:
	var module := _lab.find_module("Água e Molhado") as LabWaterModule
	if module == null:
		return
	var box := _prop(WOOD, BENCH + Vector3(0, 0.31, 0))
	await _frames(3)
	module.spawn_puddle(BENCH)
	await _frames(4)
	_check(box.has_state(LabWetStatus.STATE), "objeto Molhado antes de desligar")
	_lab.set_module_enabled(module, false)
	await _frames(3)
	_check(get_tree().get_nodes_in_group(&"lab_puddles").is_empty(), "desligar remove as poças")
	_check(not box.has_state(LabWetStatus.STATE), "desligar remove o estado Molhado")
	_lab.set_module_enabled(module, true)
	box.queue_free()


func _prop(material: PropMaterial, pos: Vector3) -> LabProp:
	var prop := LabProp.new()
	prop.material_data = material
	prop.shape_kind = PhysicsProp.Form.CYLINDER if material.explosive else PhysicsProp.Form.BOX
	prop.size = Vector3(0.6, 0.9, 0.6) if material.explosive else Vector3(0.6, 0.6, 0.6)
	prop.position = pos
	_arena.add_child(prop)
	return prop


func _find_web(host: Node) -> LabWeb:
	for child in host.get_children():
		if child is LabWeb and not child.is_queued_for_deletion():
			return child
	return null


func _clear_bench(module: LabModule) -> void:
	module.on_disabled()
	for node in get_tree().get_nodes_in_group(&"physics_props"):
		if (node as Node3D).global_position.distance_to(BENCH) < 15.0:
			node.queue_free()
	await _frames(3)


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func _seconds(time: float) -> void:
	await get_tree().create_timer(time).timeout


func _check(condition: bool, label: String) -> void:
	_checks += 1
	print("%s %s" % ["ok  " if condition else "FALHA", label])
	if not condition:
		_failures.append(label)

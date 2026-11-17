extends Node
## Medição de quadros do teste profundo (.claude/skills/teste-profundo/SKILL.md). Abre a arena com
## janela e renderização de verdade, sem limite de FPS e sem vsync, e passa por fases de carga
## crescente. Mede o tempo de cada quadro e grava o resultado em production/perf/.
## Não roda em --headless: sem renderizar, o tempo de quadro não significa nada.
## Rodar: bash tools/teste-profundo.sh medir

const ARENA := preload("res://src/levels/test_arena.tscn")
const WOOD := preload("res://assets/data/materials/wood.tres")
const EXPLOSIVE := preload("res://assets/data/materials/explosive.tres")
const OUT_DIR := "res://production/perf/"

## Orçamento: 60 fps estáveis (CLAUDE.md). Quadro acima disso derruba o FPS; acima do dobro é tranco.
const BUDGET_MS := 1000.0 / 60.0
const HITCH_MS := BUDGET_MS * 2.0
## Quadros iniciais de cada fase que não contam: a cena ainda está se acomodando.
const WARMUP_FRAMES := 30
const PHASE_SECONDS := 6.0

var _arena: Node3D
var _player: Player
var _phase := ""
var _frame_ms: Array[float] = []
var _samples := {}
var _last_usec := 0
var _skip := 0
var _results: Array[Dictionary] = []


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	GameState.selected_class = GameState.find_class("fire")
	_arena = ARENA.instantiate()
	add_child(_arena)
	_player = _arena.get("player")
	await _frames(60)

	await _run_phase("parado", Callable())
	await _run_phase("fisica", _stress_physics)
	await _run_phase("magia", _stress_spells)
	await _run_phase("combate", _stress_combat)

	_report()
	get_tree().quit(0)


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	if _phase != "" and _last_usec > 0:
		if _skip > 0:
			_skip -= 1
		else:
			_frame_ms.append((now - _last_usec) / 1000.0)
			_sample(&"draw_calls", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			_sample(&"process_ms", Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
			_sample(&"physics_ms", Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
			_sample(&"objects", Performance.get_monitor(Performance.OBJECT_COUNT))
			_sample(&"nodes", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	_last_usec = now
	# A câmera gira devagar para o quadro não ficar sempre igual.
	if is_instance_valid(_player):
		_player.rotate_y(0.4 * _delta)


func _sample(key: StringName, value: float) -> void:
	if not _samples.has(key):
		_samples[key] = [0.0, 0.0]
	var pair: Array = _samples[key]
	pair[0] += value
	pair[1] = maxf(pair[1], value)


func _run_phase(name: String, stress: Callable) -> void:
	_frame_ms.clear()
	_samples.clear()
	_skip = WARMUP_FRAMES
	_phase = name
	if stress.is_valid():
		stress.call()
	await get_tree().create_timer(PHASE_SECONDS).timeout
	_phase = ""
	_results.append(_summarize(name))


func _summarize(name: String) -> Dictionary:
	var sorted := _frame_ms.duplicate()
	sorted.sort()
	var count := sorted.size()
	var total := 0.0
	var over_budget := 0
	var hitches := 0
	for ms: float in sorted:
		total += ms
		if ms > BUDGET_MS:
			over_budget += 1
		if ms > HITCH_MS:
			hitches += 1
	var avg := total / maxf(count, 1.0)
	var slowest := sorted.slice(int(count * 0.99)) if count > 0 else []
	var low := 0.0
	for ms: float in slowest:
		low += ms
	low /= maxf(slowest.size(), 1.0)
	var result := {
		"fase": name,
		"quadros": count,
		"fps_medio": 1000.0 / maxf(avg, 0.001),
		"fps_1pct_baixo": 1000.0 / maxf(low, 0.001),
		"ms_medio": avg,
		"ms_p99": sorted[int(count * 0.99)] if count > 0 else 0.0,
		"ms_pior": sorted[-1] if count > 0 else 0.0,
		"acima_de_16_7ms": over_budget,
		"trancos_acima_de_33ms": hitches,
		"memoria_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"corpos_fisicos_ativos": Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS),
	}
	for key: StringName in _samples:
		var pair: Array = _samples[key]
		result[String(key) + "_medio"] = pair[0] / maxf(count, 1.0)
		result[String(key) + "_max"] = pair[1]
	return result


## 60 caixas caindo em pilha e 4 barris de pólvora acesos no meio.
func _stress_physics() -> void:
	var center := _ahead(8.0)
	for i in 60:
		var offset := Vector3((i % 5) * 0.7 - 1.4, 1.0 + int(i / 25.0) * 0.8, (int(i / 5.0) % 5) * 0.7 - 1.4)
		_prop(WOOD, center + offset)
	for i in 4:
		var barrel := _prop(EXPLOSIVE, center + Vector3(i * 1.2 - 1.8, 0.5, 2.5))
		barrel.ignite.call_deferred()


## 12 Bolas de Fogo de carga cheia, uma a cada 0,25 s, na direção das caixas.
func _stress_spells() -> void:
	var ability := _player.get_ability(Player.SLOT_PRIMARY) as FireballAbility
	if ability == null:
		return
	for i in 12:
		var ball := FireballProjectile.new()
		ball.ability = ability
		ball.mass = ability.max_mass
		ball.heat = ability.base_heat
		ball.blast_radius = ability.blast_radius
		_arena.add_child(ball)
		ball.global_position = _player.get_aim_origin() + Vector3.UP
		ball.launch((_ahead(8.0) - ball.global_position).normalized() * ability.projectile_speed, Vector3.ZERO)
		await get_tree().create_timer(0.25).timeout


## O bot de combate entra na arena e luta.
func _stress_combat() -> void:
	if _arena.has_method("toggle_combat_bot"):
		_arena.call("toggle_combat_bot")


func _ahead(distance: float) -> Vector3:
	var forward := -_player.global_transform.basis.z
	forward.y = 0.0
	return _player.global_position + forward.normalized() * distance


func _prop(material: PropMaterial, pos: Vector3) -> PhysicsProp:
	var prop := PhysicsProp.new()
	prop.material_data = material
	prop.shape_kind = PhysicsProp.Form.CYLINDER if material.explosive else PhysicsProp.Form.BOX
	prop.size = Vector3(0.6, 0.9, 0.6) if material.explosive else Vector3(0.5, 0.5, 0.5)
	prop.position = pos
	_arena.add_child(prop)
	return prop


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func _report() -> void:
	print("\n=== TESTE PROFUNDO: QUADROS (sem vsync, sem limite de FPS) ===")
	print("fase      fps médio  1% baixo  ms p99  pior ms  >16,7ms  trancos  draw calls")
	for r in _results:
		print("%-9s %8.0f %9.0f %7.1f %8.1f %8d %8d %11.0f" % [r.fase, r.fps_medio, r.fps_1pct_baixo,
				r.ms_p99, r.ms_pior, r.acima_de_16_7ms, r.trancos_acima_de_33ms, r.get("draw_calls_medio", 0.0)])
	var report := {
		"data": Time.get_datetime_string_from_system(),
		"commit": _commit(),
		"placa_de_video": RenderingServer.get_video_adapter_name(),
		"processador": OS.get_processor_name(),
		"resolucao": DisplayServer.window_get_size(),
		"fases": _results,
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "-")
	var path := OUT_DIR + "quadros-%s.json" % stamp
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("Resultado gravado em %s" % ProjectSettings.globalize_path(path))


func _commit() -> String:
	var output := []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], output)
	return String(output[0]).strip_edges() if not output.is_empty() else ""

extends Node
## Medição de quadros do teste profundo (.claude/skills/teste-profundo/SKILL.md). Abre a arena com
## janela e renderização de verdade, sem limite de FPS e sem vsync, e passa por fases de carga.
## Cada fase roda 3 vezes, cada vez numa arena nova, e junta os quadros das 3 (~21 s por fase).
## Mede o tempo de cada quadro e grava o resultado em production/perf/. Reprova (sai com código 1)
## se alguma fase tiver p99 acima de 33 ms ou um quadro acima de 100 ms.
## Não roda em --headless: sem renderizar, o tempo de quadro não significa nada.
## Rodar: bash tools/teste-profundo.sh medir
## Para provar que o limite reprova, injete trancos de mentira:
##   ... res://tests/perf_test.tscn -- --injetar-tranco=50:20   (50 ms a cada 20 quadros medidos)

const ARENA := preload("res://src/levels/test_arena.tscn")
const WOOD := preload("res://assets/data/materials/wood.tres")
const EXPLOSIVE := preload("res://assets/data/materials/explosive.tres")
const OUT_DIR := "res://production/perf/"

## Orçamento: 60 fps estáveis (CLAUDE.md). Quadro acima disso derruba o FPS; acima do dobro é tranco.
const BUDGET_MS := 1000.0 / 60.0
const HITCH_MS := BUDGET_MS * 2.0
## Reprova a medição: mais de 1% dos quadros de uma fase acima de um tranco (trancos frequentes)...
const P99_LIMIT_MS := 33.0
## ... ou um único quadro acima disto: ~6 quadros perdidos de uma vez, uma travada que o jogador vê.
## O p99 sozinho não pega a travada isolada (ex.: a explosão dos 4 barris, 1 quadro em ~700).
const WORST_LIMIT_MS := 100.0
## Cada fase roda REPEATS vezes, cada uma numa arena nova, por REPEAT_SECONDS.
const REPEATS := 3
const REPEAT_SECONDS := 7.0
## Quadros iniciais de cada repetição que não contam: a cena ainda está se acomodando.
const WARMUP_FRAMES := 30

var _arena: Node3D
var _player: Player
var _measuring := false
var _frame_ms: Array[float] = []
var _samples := {}
var _last_usec := 0
var _skip := 0
var _results: Array[Dictionary] = []
var _barrels: Array[PhysicsProp] = []
# Teste do próprio teste: atraso de mentira (ms) a cada N quadros medidos.
var _fake_hitch_ms := 0
var _fake_hitch_every := 0
var _measured_frames := 0


func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	GameState.selected_class = GameState.find_class("fire")
	_read_args()
	# Os efeitos compilam o shader na primeira vez que aparecem. A fase de aquecimento paga esse
	# custo antes de medir; ela entra no relatório, mas não é julgada.
	await _run_phase("aquecimento", _warm_up, 1, false)
	await _run_phase("parado", Callable())
	await _run_phase("criacao", _stress_creation)
	await _run_phase("explosao", _stress_explosion, REPEATS, true, _prepare_explosion)
	await _run_phase("magia", _stress_spells)
	await _run_phase("combate", _stress_combat)
	_free_arena()

	var failed := _report()
	get_tree().quit(1 if failed else 0)


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	if _measuring and _last_usec > 0:
		if _skip > 0:
			_skip -= 1
		else:
			_frame_ms.append((now - _last_usec) / 1000.0)
			_sample(&"draw_calls", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			_sample(&"process_ms", Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
			_sample(&"physics_ms", Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
			_sample(&"objects", Performance.get_monitor(Performance.OBJECT_COUNT))
			_sample(&"nodes", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
			_measured_frames += 1
			if _fake_hitch_every > 0 and _measured_frames % _fake_hitch_every == 0:
				OS.delay_msec(_fake_hitch_ms)
	_last_usec = now
	# A câmera gira devagar para o quadro não ficar sempre igual.
	if is_instance_valid(_player):
		_player.rotate_y(0.4 * _delta)


func _read_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--injetar-tranco="):
			var parts := arg.trim_prefix("--injetar-tranco=").split(":")
			_fake_hitch_ms = int(parts[0])
			_fake_hitch_every = int(parts[1]) if parts.size() > 1 else 1
			print("=== ATENÇÃO: trancos de mentira de %d ms a cada %d quadros (teste do teste) ===" % [_fake_hitch_ms, _fake_hitch_every])


func _sample(key: StringName, value: float) -> void:
	if not _samples.has(key):
		_samples[key] = [0.0, 0.0]
	var pair: Array = _samples[key]
	pair[0] += value
	pair[1] = maxf(pair[1], value)


## Roda a fase `repeats` vezes, cada uma numa arena nova, e junta os quadros.
## `prepare` monta a cena antes de medir (não conta); `stress` começa junto com a medição.
func _run_phase(phase: String, stress: Callable, repeats := REPEATS, judged := true, prepare := Callable()) -> void:
	_frame_ms.clear()
	_samples.clear()
	var worst_per_repeat: Array[float] = []
	for i in repeats:
		await _load_arena()
		if prepare.is_valid():
			await prepare.call()
		var start := _frame_ms.size()
		_skip = WARMUP_FRAMES
		_measuring = true
		if stress.is_valid():
			stress.call()
		await get_tree().create_timer(REPEAT_SECONDS).timeout
		_measuring = false
		worst_per_repeat.append(_frame_ms.slice(start).max() if _frame_ms.size() > start else 0.0)
	var result := _summarize(phase)
	result["julgada"] = judged
	result["repeticoes"] = repeats
	result["pior_por_repeticao"] = worst_per_repeat
	_results.append(result)


## Troca a arena por uma nova e a põe como cena principal, como no jogo de verdade:
## projéteis e efeitos entram em current_scene, e o bot de combate procura projéteis ali.
func _load_arena() -> void:
	_free_arena()
	await _frames(3)
	_arena = ARENA.instantiate()
	get_tree().root.add_child(_arena)
	get_tree().current_scene = _arena
	_player = _arena.get("player")
	_player.debug_infinite_resources = true
	_player.debug_no_cooldowns = true
	await _frames(60)


func _free_arena() -> void:
	_barrels.clear()
	if is_instance_valid(_arena):
		get_tree().current_scene = self
		_arena.queue_free()
	_arena = null
	_player = null


## Percentil pelo método do posto mais próximo, numa lista já ordenada.
func _percentile(sorted: Array, fraction: float) -> float:
	if sorted.is_empty():
		return 0.0
	return sorted[clampi(ceili(fraction * sorted.size()) - 1, 0, sorted.size() - 1)]


func _summarize(phase: String) -> Dictionary:
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
		"fase": phase,
		"quadros": count,
		"fps_medio": 1000.0 / maxf(avg, 0.001),
		"fps_1pct_baixo": 1000.0 / maxf(low, 0.001),
		"ms_medio": avg,
		"ms_p95": _percentile(sorted, 0.95),
		"ms_p99": _percentile(sorted, 0.99),
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


## Uma explosão, uma caixa em chamas e uma Bola de Fogo à frente da câmera.
func _warm_up() -> void:
	var center := _ahead(6.0)
	_prop(WOOD, center + Vector3(0.8, 0.5, 0)).ignite()
	_prop(EXPLOSIVE, center + Vector3(-0.8, 0.5, 0)).ignite.call_deferred()
	_fireball(center)


## 60 caixas e 4 barris de pólvora surgem de uma vez e caem em pilha (sem fogo).
func _stress_creation() -> void:
	_spawn_pile()


## A mesma pilha, montada e assentada antes de medir; a medição começa ao acender os barris.
func _prepare_explosion() -> void:
	_spawn_pile()
	await get_tree().create_timer(2.0).timeout


func _stress_explosion() -> void:
	for barrel in _barrels:
		if is_instance_valid(barrel):
			barrel.ignite()


func _spawn_pile() -> void:
	var center := _ahead(8.0)
	for i in 60:
		var offset := Vector3((i % 5) * 0.7 - 1.4, 1.0 + int(i / 25.0) * 0.8, (int(i / 5.0) % 5) * 0.7 - 1.4)
		_prop(WOOD, center + offset)
	for i in 4:
		_barrels.append(_prop(EXPLOSIVE, center + Vector3(i * 1.2 - 1.8, 0.5, 2.5)))


## 12 Bolas de Fogo de carga cheia, uma a cada 0,25 s, para a frente.
func _stress_spells() -> void:
	var arena := _arena
	for i in 12:
		if _arena != arena:
			return
		_fireball(_ahead(8.0))
		await get_tree().create_timer(0.25).timeout


## O bot de combate entra na arena e luta; o jogador lança uma Bola de Fogo nele a cada segundo,
## para o bot ter projéteis de que se defender.
func _stress_combat() -> void:
	var arena := _arena
	arena.call("toggle_combat_bot")
	while _arena == arena and _measuring:
		await get_tree().create_timer(1.0).timeout
		if _arena != arena or not _measuring:
			return
		var bot: Node3D = arena.get("combat_bot")
		if is_instance_valid(bot):
			_fireball(bot.global_position + Vector3.UP)


## Bola de Fogo de carga cheia pelo mesmo caminho do jogo (mirar e usar a habilidade).
func _fireball(target: Vector3) -> void:
	_player.face_point(target)
	_player.use_ability(Player.SLOT_PRIMARY, 1.0)


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


## Mostra a tabela, grava o JSON e devolve true se alguma fase julgada passou do limite.
func _report() -> bool:
	print("\n=== TESTE PROFUNDO: QUADROS (sem vsync, sem limite de FPS, %d x %.0f s por fase) ===" % [REPEATS, REPEAT_SECONDS])
	print("fase         quadros  fps médio  1% baixo  ms p95  ms p99  pior ms  >16,7ms  trancos  draw calls  limite")
	var failed: Array[String] = []
	for r in _results:
		var verdict := "-"
		if r.julgada:
			var reasons: Array[String] = []
			if r.ms_p99 > P99_LIMIT_MS:
				reasons.append("p99 %.1f ms" % r.ms_p99)
			if r.ms_pior > WORST_LIMIT_MS:
				reasons.append("quadro de %.0f ms" % r.ms_pior)
			verdict = "ok" if reasons.is_empty() else "REPROVA"
			if not reasons.is_empty():
				failed.append("%s (%s)" % [r.fase, ", ".join(reasons)])
		print("%-12s %7d %10.0f %9.0f %7.1f %7.1f %8.1f %8d %8d %11.0f  %s" % [r.fase, r.quadros, r.fps_medio,
				r.fps_1pct_baixo, r.ms_p95, r.ms_p99, r.ms_pior, r.acima_de_16_7ms, r.trancos_acima_de_33ms,
				r.get("draw_calls_medio", 0.0), verdict])
	var report := {
		"data": Time.get_datetime_string_from_system(),
		"commit": _commit(),
		"placa_de_video": RenderingServer.get_video_adapter_name(),
		"processador": OS.get_processor_name(),
		"resolucao": DisplayServer.window_get_size(),
		"limite_p99_ms": P99_LIMIT_MS,
		"limite_pior_quadro_ms": WORST_LIMIT_MS,
		"tranco_injetado": "%d ms a cada %d quadros" % [_fake_hitch_ms, _fake_hitch_every] if _fake_hitch_every > 0 else "",
		"aprovado": failed.is_empty(),
		"fases": _results,
	}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "-")
	var path := OUT_DIR + "quadros-%s.json" % stamp
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("Resultado gravado em %s" % ProjectSettings.globalize_path(path))
	if failed.is_empty():
		print("=== RESULTADO: APROVADO (p99 até %.0f ms e nenhum quadro acima de %.0f ms) ===" % [P99_LIMIT_MS, WORST_LIMIT_MS])
	else:
		print("=== RESULTADO: REPROVADO em %s ===" % "; ".join(failed))
	return not failed.is_empty()


func _commit() -> String:
	var output := []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], output)
	return String(output[0]).strip_edges() if not output.is_empty() else ""

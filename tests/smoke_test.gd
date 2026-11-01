extends Node
## Teste de fumaça: executor fino. Descobre as suítes em tests/suites/, roda uma de cada vez
## e soma o resultado. Os testes ficam nas suítes; este arquivo não muda quando entra um teste.
## Rodar: ver tests/README.md. Sai com código 0 (passou) ou 1 (falhou).

const SUITES_DIR := "res://tests/suites/"
const Suite := preload("res://tests/suite_base.gd")

var _failures: Array[String] = []
var _checks := 0


func _ready() -> void:
	var files := _find_suites()
	if files.is_empty():
		_fail("nenhuma suíte encontrada em %s" % SUITES_DIR)
	for file in files:
		await _run_suite(file)
	print("")
	for failure in _failures:
		print("  FALHOU: " + failure)
	# Esta linha fica por último: tools/frentes.sh lê este formato.
	print("=== SMOKE TEST: %d verificações, %d falhas ===" % [_checks, _failures.size()])
	get_tree().quit(1 if _failures.size() > 0 else 0)


## Arquivos .gd da pasta de suítes, em ordem alfabética para o teste ser sempre igual.
func _find_suites() -> Array[String]:
	var files: Array[String] = []
	for file in DirAccess.get_files_at(SUITES_DIR):
		if file.get_extension() == "gd":
			files.append(file)
	files.sort()
	return files


func _run_suite(file: String) -> void:
	print("\n===== Suíte: %s =====" % file.get_basename())
	var script: Script = load(SUITES_DIR + file)
	# Suíte que não compila não pode sumir em silêncio: conta como falha.
	if script == null or not script.can_instantiate():
		_fail("suíte %s não carregou" % file)
		return
	var suite: Node = script.new()
	if not suite is Suite:
		suite.free()
		_fail("suíte %s não estende suite_base.gd" % file)
		return
	add_child(suite)
	await suite.run()
	print("  suíte %s: %d verificações, %d falhas" % [file.get_basename(), suite.checks, suite.failures.size()])
	if suite.checks == 0:
		_fail("suíte %s não fez nenhuma verificação" % file)
	_checks += suite.checks
	_failures.append_array(suite.failures)
	suite.queue_free()
	await get_tree().physics_frame


## Falha do próprio executor (fora de uma suíte); também conta como verificação.
func _fail(label: String) -> void:
	_checks += 1
	print("  FALHA " + label)
	_failures.append(label)

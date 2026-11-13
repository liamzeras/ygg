class_name LabModule
extends Resource
## Experimento do Laboratório do Sábio (design/sabio/laboratorio.md). Cada .tres em
## assets/data/lab/ vira um módulo: apagar o .tres remove o experimento do jogo.

@export var display_name := ""
@export var enabled := true

var controller: LabController

var _spawned: Array[Node] = []


func setup(lab: LabController) -> void:
	controller = lab


## Módulos passivos não usam tecla.
func is_usable() -> bool:
	return false


## Executa a ação da tecla. Devolve o motivo da falha, ou "" se deu certo.
func use(_player: Player) -> String:
	return ""


## Texto extra no painel (ex.: reagentes restantes).
func status_text() -> String:
	return ""


func tick(_delta: float) -> void:
	pass


## Permite ao módulo alterar o calor que um objeto recebe.
func filter_heat(_prop: LabProp, amount: float) -> float:
	return amount


func on_disabled() -> void:
	for node in _spawned:
		if is_instance_valid(node):
			node.queue_free()
	_spawned.clear()


## Registra algo criado pelo módulo, para sumir quando ele for desligado.
func track(node: Node) -> void:
	for i in range(_spawned.size() - 1, -1, -1):
		if not is_instance_valid(_spawned[i]):
			_spawned.remove_at(i)
	_spawned.append(node)

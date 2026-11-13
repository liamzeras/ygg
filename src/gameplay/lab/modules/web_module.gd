class_name LabWebModule
extends LabModule
## Tecla: gasta 1 Teia e prende o objeto ou alvo na mira (ideia 1 de
## design/sabio/inspiracao/ideias-para-ygg.md). Fogo queima a teia de uma vez e castiga o preso.

@export var reach := 15.0
## Reagentes por partida: simula o item dropado, até existir inventário.
@export var starting_webs := 8
@export var duration := 12.0
## Calor para a teia pegar fogo.
@export var ignition_heat := 10.0
## Calor extra entregue ao preso quando a teia queima.
@export var burn_heat := 120.0
## Velocidade (m/s) acima da qual o preso arrebenta a teia.
@export var break_speed := 4.0
## Frenagem aplicada ao objeto preso (damp do corpo).
@export var hold_damp := 30.0
@export var cocoon_radius := 0.6
@export var color := Color(0.92, 0.92, 0.85, 0.45)

var webs := 0


func setup(lab: LabController) -> void:
	super.setup(lab)
	webs = starting_webs


func is_usable() -> bool:
	return true


func status_text() -> String:
	return "Teias: %d" % webs


func use(player: Player) -> String:
	if webs <= 0:
		return "Sem Teia"
	var hit := controller.aim(player, reach)
	if hit.is_empty() or not (hit.collider is LabProp or hit.collider.has_method("register_hit")):
		return "Mire em um objeto ou alvo"
	if not trap(hit.collider, hit.position):
		return "Já está preso"
	webs -= 1
	return ""


## Prende `host`. Falso se já estiver preso.
func trap(host: Node3D, point: Vector3) -> bool:
	for child in host.get_children():
		if child is LabWeb:
			return false
	var web := LabWeb.new()
	web.host = host
	web.module = self
	host.add_child(web)
	web.global_position = point
	track(web)
	return true

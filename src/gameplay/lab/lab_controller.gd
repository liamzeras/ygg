class_name LabController
extends CanvasLayer
## Laboratório do Sábio (design/sabio/laboratorio.md): carrega os módulos de assets/data/lab/,
## troca os objetos da arena por LabProp e mostra o painel. Teclas: 1 a 9 usam o módulo;
## Alt + número liga ou desliga.

const MODULES_DIR := "res://assets/data/lab/"

var arena: Node3D
var modules: Array[LabModule] = []

var _label: Label


func _ready() -> void:
	add_to_group(&"lab_controller")
	arena = get_parent() as Node3D
	_load_modules()
	_build_panel()
	# A arena termina de montar depois dos filhos.
	_replace_props.call_deferred()


func _load_modules() -> void:
	var files := Array(DirAccess.get_files_at(MODULES_DIR))
	files.sort()
	for file: String in files:
		var path := file.trim_suffix(".remap")
		if not path.ends_with(".tres"):
			continue
		var module := (load(MODULES_DIR + path) as LabModule).duplicate() as LabModule
		module.setup(self)
		modules.append(module)


## Só objetos LabProp reagem aos experimentos; a arena original continua intacta.
func _replace_props() -> void:
	for child in arena.get_children():
		if child is PhysicsProp and not child is LabProp:
			var old := child as PhysicsProp
			var prop := LabProp.new()
			prop.material_data = old.material_data
			prop.shape_kind = old.shape_kind
			prop.size = old.size
			prop.display_name = old.display_name
			prop.transform = old.transform
			arena.remove_child(old)
			old.free()
			arena.add_child(prop)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	var slot: int = key.physical_keycode - KEY_1
	if slot < 0 or slot >= modules.size():
		return
	if key.alt_pressed:
		set_module_enabled(modules[slot], not modules[slot].enabled)
	else:
		use_module(modules[slot])
	get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	for module in modules:
		if module.enabled:
			module.tick(delta)


func _process(_delta: float) -> void:
	_refresh_panel()


func find_module(display_name: String) -> LabModule:
	for module in modules:
		if module.display_name == display_name:
			return module
	return null


func set_module_enabled(module: LabModule, value: bool) -> void:
	if module.enabled == value:
		return
	module.enabled = value
	if not value:
		module.on_disabled()


func use_module(module: LabModule) -> void:
	var player: Player = arena.get("player")
	if player == null or not module.is_usable():
		return
	var reason := "Módulo desligado (Alt + número)" if not module.enabled else module.use(player)
	if reason != "":
		player.action_failed.emit(reason)


func filter_heat(prop: LabProp, amount: float) -> float:
	for module in modules:
		if module.enabled:
			amount = module.filter_heat(prop, amount)
	return amount


## Primeiro corpo na mira até `reach` metros ({} = nada).
func aim(player: Player, reach: float) -> Dictionary:
	var origin := player.get_aim_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + player.get_aim_direction() * reach)
	query.exclude = [player.get_rid()]
	return player.get_world_3d().direct_space_state.intersect_ray(query)


## Ponto do chão mirado; mirar um objeto solto procura o chão embaixo dele. Sem chão, INF.
func aim_ground(player: Player, reach: float) -> Vector3:
	var hit := aim(player, reach)
	if hit.is_empty():
		return Vector3.INF
	var point: Vector3 = hit.position
	var down := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.1, point + Vector3.DOWN * 3.0)
	var excluded: Array[RID] = [player.get_rid()]
	if hit.collider is RigidBody3D:
		excluded.append((hit.collider as RigidBody3D).get_rid())
	down.exclude = excluded
	var ground := player.get_world_3d().direct_space_state.intersect_ray(down)
	return ground.position if not ground.is_empty() else Vector3.INF


func _build_panel() -> void:
	_label = Label.new()
	_label.position = Vector2(16, 200)
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 5)
	add_child(_label)


func _refresh_panel() -> void:
	var text := "LABORATÓRIO DO SÁBIO · Alt + número liga/desliga"
	for i in modules.size():
		var module := modules[i]
		var state := "ligado" if module.enabled else "DESLIGADO"
		var kind := "" if module.is_usable() else " (passivo)"
		var extra := module.status_text()
		text += "\n[%d] %s%s: %s%s" % [i + 1, module.display_name, kind, state, " · " + extra if extra != "" else ""]
	_label.text = text

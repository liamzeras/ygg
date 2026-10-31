extends Node
## Captura telas para revisão visual de UI.
## Uso: Godot --path . res://tests/screenshot.tscn -- --scene=res://... --out=C:/caminho.png [--class=mage] [--frames=60]
## Extras para a arena: --editor=1 (abre o editor de testes), --exhausted=1 (zera o Vigor),
## --field=1 (Campo Lento à frente), --charge=N (segura a carga por N quadros de física).

func _ready() -> void:
	var args := {"frames": "60"}
	for arg in OS.get_cmdline_user_args():
		var parts := arg.trim_prefix("--").split("=", true, 1)
		if parts.size() == 2:
			args[parts[0]] = parts[1]
	var scene: Node = load(args["scene"]).instantiate()
	add_child(scene)
	for i in int(args["frames"]):
		await get_tree().process_frame
	if args.has("editor") and scene.has_node("DebugEditor"):
		scene.get_node("DebugEditor").set_open(true)
	if args.has("exhausted") and "player" in scene:
		scene.player.spend(Player.Pool.STAMINA, 9999.0)
		for i in 90:
			await get_tree().process_frame
	if args.has("field") and "player" in scene:
		scene.player.face_point(scene.player.get_aim_origin() + scene.player.get_flat_forward() * 6.0 + Vector3.DOWN * 1.2)
		scene.player.request_action(Player.SLOT_MOBILITY)
		for i in 10:
			await get_tree().process_frame
	if args.has("charge") and "player" in scene:
		scene.player.request_action(Player.SLOT_PRIMARY)
		for i in int(args["charge"]):
			await get_tree().physics_frame
	if args.has("help_hidden") and scene.has_node("HUD"):
		scene.get_node("HUD")._help.visible = false
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args["out"])
	get_tree().quit()

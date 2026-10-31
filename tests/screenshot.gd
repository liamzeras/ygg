extends Node
## Captura telas para revisão visual de UI.
## Uso: Godot --path . res://tests/screenshot.tscn -- --scene=res://... --out=C:/caminho.png [--class=mage] [--frames=60]

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
	if args.has("help_hidden") and scene.has_node("HUD"):
		scene.get_node("HUD")._help.visible = false
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(args["out"])
	get_tree().quit()

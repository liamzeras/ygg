class_name LabWeb
extends StaticBody3D
## Teia presa a um corpo. Em objetos soltos, freia pelo damp do corpo e arrebenta com velocidade
## alta. Em alvos, vira um casulo que recebe o fogo. Queimar solta o preso e lhe entrega calor.

var host: Node3D
var module: LabWebModule

var _time_left := 0.0
var _heat := 0.0
var _released := false
var _damp_backup := Vector2.ZERO
var _orbit_backup := 0.0


func _ready() -> void:
	_time_left = module.duration
	add_to_group(&"heat_receivers")
	var mesh := SphereMesh.new()
	mesh.radius = module.cocoon_radius
	mesh.height = module.cocoon_radius * 2.0
	var material := StandardMaterial3D.new()
	material.albedo_color = module.color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)

	if host is LabProp:
		var prop := host as LabProp
		collision_layer = 0
		_damp_backup = Vector2(prop.linear_damp, prop.angular_damp)
		prop.linear_damp = module.hold_damp
		prop.angular_damp = module.hold_damp
		prop.heat_received.connect(add_heat)
	else:
		var shape := SphereShape3D.new()
		shape.radius = module.cocoon_radius
		var collision := CollisionShape3D.new()
		collision.shape = shape
		add_child(collision)
		if host is FlyingTarget:
			_orbit_backup = (host as FlyingTarget).orbit_speed
			(host as FlyingTarget).orbit_speed = 0.0


func _physics_process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return
	if host is LabProp:
		var prop := host as LabProp
		if prop.burning:
			_burn()
		elif prop.linear_velocity.length() > module.break_speed:
			Fx.burst(module.controller.arena, global_position, module.color, module.cocoon_radius)
			queue_free()


func add_heat(amount: float) -> void:
	_heat += amount
	if _heat >= module.ignition_heat:
		_burn()


func _exit_tree() -> void:
	_release()


func _burn() -> void:
	if _released:
		return
	_release()
	Fx.burst(module.controller.arena, global_position, Color(1.0, 0.5, 0.1), module.cocoon_radius * 2.0)
	if is_instance_valid(host):
		host.add_heat(module.burn_heat)
	queue_free()


func _release() -> void:
	if _released:
		return
	_released = true
	if not is_instance_valid(host) or host.is_queued_for_deletion():
		return
	if host is LabProp:
		var prop := host as LabProp
		prop.linear_damp = _damp_backup.x
		prop.angular_damp = _damp_backup.y
		prop.heat_received.disconnect(add_heat)
	elif host is FlyingTarget:
		(host as FlyingTarget).orbit_speed = _orbit_backup

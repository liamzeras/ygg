class_name TrainingDummy
extends StaticBody3D
## Boneco de testes estático ("rato de laboratório"). Não se mexe nem quebra:
## só mede e mostra o que recebeu (impulso, calor) e compara com um humano comum.

## Segundos que a última leitura fica destacada.
const HIGHLIGHT_TIME := 0.4
const HEAT_REPORT_INTERVAL := 0.5

@export var rules: AttributeRules

var last_source := ""
var last_impulse := 0.0
var max_impulse := 0.0
var hit_count := 0
var total_heat := 0.0

var _label: Label3D
var _body_material: StandardMaterial3D
var _flash := 0.0
var _pending_heat := 0.0
var _heat_timer := 0.0


func _ready() -> void:
	_build()
	_refresh()


## Chamado por habilidades, explosões e objetos que batem no boneco.
func register_hit(source: String, impulse: float) -> void:
	last_source = source
	last_impulse = impulse
	max_impulse = maxf(max_impulse, impulse)
	hit_count += 1
	_flash = HIGHLIGHT_TIME
	_refresh()


func add_heat(amount: float) -> void:
	_pending_heat += amount
	total_heat += amount


func reset() -> void:
	last_source = ""
	last_impulse = 0.0
	max_impulse = 0.0
	hit_count = 0
	total_heat = 0.0
	_refresh()


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash -= delta
		_body_material.albedo_color = Color(0.85, 0.7, 0.45).lerp(Color(1, 0.3, 0.2), clampf(_flash / HIGHLIGHT_TIME, 0, 1))
	_heat_timer -= delta
	if _heat_timer <= 0.0 and _pending_heat > 0.0:
		_heat_timer = HEAT_REPORT_INTERVAL
		_pending_heat = 0.0
		_refresh()


func _refresh() -> void:
	if _label == null:
		return
	var shove := rules.human_shove_impulse if rules else 60.0
	var lines := ["BONECO DE TESTES"]
	if hit_count == 0:
		lines.append("Acerte-me")
	else:
		lines.append("Último: %s" % last_source)
		lines.append("%.0f N·s  (%.1fx empurrão humano)" % [last_impulse, last_impulse / shove])
		lines.append("Máximo: %.0f N·s   Golpes: %d" % [max_impulse, hit_count])
	if total_heat > 0.0:
		lines.append("Calor total: %.0f" % total_heat)
	_label.text = "\n".join(lines)


func _build() -> void:
	# Poste + corpo + cabeça, tudo estático.
	_body_material = StandardMaterial3D.new()
	_body_material.albedo_color = Color(0.85, 0.7, 0.45)
	_add_part(_cylinder(0.08, 1.0), Vector3(0, 0.5, 0), Color(0.4, 0.3, 0.2))
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.28
	body_mesh.height = 1.0
	_add_part(body_mesh, Vector3(0, 1.25, 0), Color.WHITE, _body_material)
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.16
	head_mesh.height = 0.32
	_add_part(head_mesh, Vector3(0, 1.92, 0), Color.WHITE, _body_material)

	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 2.1
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 1.05
	add_child(collision)

	_label = Label3D.new()
	_label.position.y = 2.6
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.font_size = 40
	_label.pixel_size = 0.006
	_label.outline_size = 10
	_label.no_depth_test = true
	add_child(_label)


func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh


func _add_part(mesh: PrimitiveMesh, at: Vector3, color: Color, mat: StandardMaterial3D = null) -> void:
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.albedo_color = color
	mesh.material = mat
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	add_child(part)

class_name TrainingDummy
extends StaticBody3D
## Boneco de testes estático ("rato de laboratório"). Não se mexe nem quebra:
## converte o que recebe (impulso, calor) em dano pelas DamageRules e mostra
## o último golpe, o combo, o DPS e a comparação com um humano comum.
## Zera sozinho após `combo_reset_time` segundos sem receber dano.
## Ver design/gdd/damage-and-testing.md.

signal damaged(source: String, amount: float)
signal combo_reset

## Segundos que o destaque vermelho dura após um golpe.
const HIGHLIGHT_TIME := 0.4
## O texto é atualizado no máximo a cada intervalo (dano de fogo chega todo frame).
const REFRESH_INTERVAL := 0.1
## Calor menor que isto por frame é agrupado como "Fogo" contínuo.
const FIRE_SOURCE := "Fogo"
const BODY_HEIGHT := 2.1
const BODY_RADIUS := 0.3

@export var rules: AttributeRules
@export var damage_rules: DamageRules

var last_source := ""
var last_damage := 0.0
var last_impulse := 0.0
var max_damage := 0.0
var hit_count := 0
var combo_damage := 0.0
var fire_damage := 0.0

var _combo_time := 0.0
var _idle_time := 0.0
var _label: Label3D
var _body_material: StandardMaterial3D
var _flash := 0.0
var _refresh_timer := 0.0
var _dirty := false


func _ready() -> void:
	add_to_group(&"heat_receivers")
	_build()
	_refresh()


## Golpe físico (habilidades, explosões, objetos que batem). `impulse` em N·s.
func register_hit(source: String, impulse: float) -> void:
	var amount := damage_rules.impact_damage(impulse)
	last_source = source
	last_impulse = impulse
	_apply_damage(source, amount)
	hit_count += 1
	_flash = HIGHLIGHT_TIME


## Calor recebido (Bola de Fogo, explosões, objetos em chamas por perto, braseiro).
func add_heat(amount: float) -> void:
	var damage := damage_rules.heat_damage(amount)
	fire_damage += damage
	_apply_damage(FIRE_SOURCE, damage)


func reset() -> void:
	last_source = ""
	last_damage = 0.0
	last_impulse = 0.0
	max_damage = 0.0
	hit_count = 0
	combo_damage = 0.0
	fire_damage = 0.0
	_combo_time = 0.0
	_idle_time = 0.0
	_dirty = true
	combo_reset.emit()


## Distância de um ponto até a superfície do boneco (ver DamageRules.distance_to).
func surface_distance(point: Vector3) -> float:
	return DamageRules.capsule_distance(global_position, BODY_HEIGHT, BODY_RADIUS, point)


## Centro do corpo (a origem do nó fica nos pés).
func get_center() -> Vector3:
	return global_position + Vector3.UP * BODY_HEIGHT / 2.0


## Dano por segundo do combo atual (janela mínima de 1 s para não explodir no 1º golpe).
func get_dps() -> float:
	return combo_damage / maxf(_combo_time, 1.0)


func _apply_damage(source: String, amount: float) -> void:
	if amount <= 0.0:
		return
	if source != FIRE_SOURCE:
		last_damage = amount
		max_damage = maxf(max_damage, amount)
	combo_damage += amount
	_idle_time = 0.0
	_dirty = true
	damaged.emit(source, amount)


func _process(delta: float) -> void:
	if combo_damage > 0.0:
		_combo_time += delta
		_idle_time += delta
		if _idle_time >= damage_rules.combo_reset_time:
			reset()
	if _flash > 0.0:
		_flash -= delta
		_body_material.albedo_color = Color(0.85, 0.7, 0.45).lerp(Color(1, 0.3, 0.2), clampf(_flash / HIGHLIGHT_TIME, 0, 1))
	_refresh_timer -= delta
	if _refresh_timer <= 0.0 and (_dirty or combo_damage > 0.0):
		_refresh_timer = REFRESH_INTERVAL
		_dirty = false
		_refresh()


func _refresh() -> void:
	if _label == null:
		return
	var lines := ["BONECO DE TESTES"]
	if combo_damage <= 0.0:
		lines.append("Acerte-me")
		_label.text = "\n".join(lines)
		return
	if hit_count > 0:
		var shove := rules.human_shove_impulse if rules else 60.0
		lines.append("Último: %s  —  %.1f de dano" % [last_source, last_damage])
		lines.append("%.0f N·s  (%.1fx empurrão humano)" % [last_impulse, last_impulse / shove])
	lines.append("COMBO: %.1f de dano  ·  %d golpes  ·  %.1f s" % [combo_damage, hit_count, _combo_time])
	lines.append("DPS: %.1f   ·   Maior golpe: %.1f" % [get_dps(), max_damage])
	if fire_damage > 0.0:
		lines.append("Fogo: %.1f de dano" % fire_damage)
	lines.append("zera em %.0f s sem dano" % ceilf(damage_rules.combo_reset_time - _idle_time))
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
	shape.radius = BODY_RADIUS
	shape.height = BODY_HEIGHT
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = BODY_HEIGHT / 2.0
	add_child(collision)

	_label = Label3D.new()
	_label.position.y = 2.9
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

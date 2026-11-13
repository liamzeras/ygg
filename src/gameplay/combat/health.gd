class_name Health
extends Node3D
## Vida de um personagem (design/gdd/combat-bot.md). Fica como filho do corpo e recebe o dano
## pelas mesmas DamageRules do boneco. Em 0, o dono renasce (`respawn()`) com a vida cheia e fica
## invencível por `respawn_invulnerability` segundos.
## Vida máxima = base_health x mult(Vitalidade)^health_exponent.

signal changed(current: float, maximum: float)
signal damaged(source: String, amount: float)
signal died
signal respawned

const DAMAGE: DamageRules = preload("res://assets/data/damage_rules.tres")

var max_health := 100.0
var current := 100.0

var _invulnerable_time := 0.0


func _ready() -> void:
	add_to_group(&"heat_receivers")


## Define a vida máxima a partir do multiplicador de Vitalidade. Mantém a fração atual.
func setup(vitality_multiplier: float) -> void:
	var fraction := current / max_health if max_health > 0.0 else 1.0
	max_health = DAMAGE.base_health * pow(vitality_multiplier, DAMAGE.health_exponent)
	current = max_health * fraction
	changed.emit(current, max_health)


func is_invulnerable() -> bool:
	return _invulnerable_time > 0.0


func get_invulnerable_time() -> float:
	return _invulnerable_time


## Golpe físico (mesma assinatura do boneco de testes). `impulse` em N·s.
func register_hit(source: String, impulse: float) -> void:
	take_damage(source, DAMAGE.impact_damage(impulse))


## Calor recebido (explosões, objetos em chamas por perto).
func add_heat(amount: float) -> void:
	take_damage("Fogo", DAMAGE.heat_damage(amount))


func take_damage(source: String, amount: float) -> void:
	if amount <= 0.0 or is_invulnerable() or current <= 0.0:
		return
	current = maxf(current - amount, 0.0)
	damaged.emit(source, amount)
	changed.emit(current, max_health)
	if current <= 0.0:
		_die()


## Distância e centro: o dono sabe medir o próprio corpo (ver DamageRules.distance_to).
func surface_distance(point: Vector3) -> float:
	return DamageRules.distance_to(get_parent() as Node3D, point)


func get_center() -> Vector3:
	return DamageRules.center_of(get_parent() as Node3D)


func _physics_process(delta: float) -> void:
	_invulnerable_time = maxf(_invulnerable_time - delta, 0.0)


func _die() -> void:
	died.emit()
	var body := get_parent()
	if body.has_method("respawn"):
		body.respawn()
	current = max_health
	_invulnerable_time = DAMAGE.respawn_invulnerability
	changed.emit(current, max_health)
	respawned.emit()

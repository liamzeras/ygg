class_name DamageRules
extends Resource
## Converte física em dano. Dano não é um número inventado por habilidade:
## sai do impulso (N·s) e do calor que o alvo recebe. Dados em assets/data/damage_rules.tres.
## Fórmulas em design/gdd/damage-and-testing.md.
##   dano_físico = max(impulso - limiar, 0) x dano_por_impulso
##   dano_fogo   = calor x dano_por_calor
##   impulso_materializado = massa x velocidade_relativa x escala (sem o atributo)

## Impulso abaixo disto não machuca (esbarrar, empurrar de leve).
@export var impulse_threshold := 10.0
@export var damage_per_impulse := 0.1
@export var damage_per_heat := 0.1
## Segundos sem receber dano para o combo (e o boneco) zerar.
@export var combo_reset_time := 5.0
## Fração do impulso e do calor de uma explosão que passa por uma parede ou pilar.
@export_range(0.0, 1.0) var blocked_explosion_factor := 0.15
## Objetos materializados por magia pesam gramas: 10 g a 30 m/s são só 0,3 N·s de verdade.
## Esta escala é a energia mágica concentrada neles; sem ela, nenhum passaria do limiar.
@export var materialized_scale := 200.0


func impact_damage(impulse: float) -> float:
	return maxf(impulse - impulse_threshold, 0.0) * damage_per_impulse


func heat_damage(heat: float) -> float:
	return maxf(heat, 0.0) * damage_per_heat


## Impulso de um objeto materializado (magia): massa x velocidade x escala mágica.
func materialized_impulse(mass: float, relative_speed: float) -> float:
	return mass * relative_speed * materialized_scale


## Velocidade atual de um nó físico, para calcular impactos relativos (null ou parado = zero).
static func velocity_of(node: Node) -> Vector3:
	if node is RigidBody3D:
		return (node as RigidBody3D).linear_velocity
	if node is CharacterBody3D:
		return (node as CharacterBody3D).velocity
	if node != null and node.has_method("get_motion_velocity"):
		return node.get_motion_velocity()
	return Vector3.ZERO


## Distância (m) de um ponto até o corpo. Corpos altos informam a própria superfície
## (`surface_distance`); a origem de boneco e personagens fica nos pés e não serve de medida.
static func distance_to(node: Node3D, point: Vector3) -> float:
	if node.has_method("surface_distance"):
		return node.surface_distance(point)
	return node.global_position.distance_to(point)


## Distância de `point` até um corpo vertical em forma de cápsula, com os pés em `feet`.
static func capsule_distance(feet: Vector3, height: float, radius: float, point: Vector3) -> float:
	var nearest := feet + Vector3.UP * clampf(point.y - feet.y, radius, maxf(height - radius, radius))
	return maxf(nearest.distance_to(point) - radius, 0.0)


## Centro do corpo. Boneco e personagens informam o próprio (`get_center`), porque a origem
## deles fica nos pés.
static func center_of(node: Node3D) -> Vector3:
	return node.get_center() if node.has_method("get_center") else node.global_position

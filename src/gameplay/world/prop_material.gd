class_name PropMaterial
extends Resource
## Propriedades físicas e elementais de um material.
## Ver design/gdd/physics-magic-system.md (seções Materiais e As leis da fatia).

## Material do chão que não declara o próprio (chão da arena, paredes): conta como solo.
const DEFAULT_GROUND_PATH := "res://assets/data/materials/soil.tres"

@export var display_name := ""
@export var color := Color.WHITE
@export_range(0.0, 1.0) var roughness := 0.8
@export_range(0.0, 1.0) var metallic := 0.0

@export_group("Física")
## Densidade "de jogo" em kg/m³ (massa = volume x densidade).
@export var density := 100.0
@export_range(0.0, 1.0) var friction := 0.8
@export_range(0.0, 1.0) var bounce := 0.05

@export_group("Fogo")
@export var flammable := false
## Calor acumulado necessário para pegar fogo.
@export var ignition_heat := 100.0
## Calor perdido por segundo quando não está queimando.
@export var heat_decay := 20.0
## Combustível: quanto tempo queima com ar normal até virar cinzas (segundos).
@export var burn_time := 8.0
## Raio em que o fogo aquece outros objetos.
@export var fire_spread_radius := 1.6
## Calor por segundo transmitido a objetos no raio (cai com a distância).
@export var fire_spread_heat := 60.0
## Fração da massa que sobra quando o combustível acaba (o fogo consome o objeto).
@export_range(0.05, 1.0) var burnt_mass_fraction := 0.4

@export_group("Calor guardado")
## Calor máximo que um material que não queima consegue guardar. 0 = não guarda calor.
@export var max_heat := 0.0
## A partir deste calor, o objeto quente aquece quem está perto (pedra em brasa).
@export var radiate_threshold := 50.0
## Raio em que o objeto quente aquece os vizinhos.
@export var radiate_radius := 1.5
## Fração do calor acima do limiar passada por segundo a cada vizinho (cai com a distância).
## O objeto quente perde o que entrega, então duas pedras não se esquentam para sempre.
@export var radiate_rate := 0.6

@export_group("Terra")
## A Terra pode moldar este material (erguer pilar, abrir lama, revestir o golpe).
@export var earth_workable := false
## Multiplicador da força da Terra sobre este material (pedra responde mais forte).
@export var earth_force_factor := 1.0

@export_group("Explosão")
@export var explosive := false
## Segundos queimando antes de explodir.
@export var fuse_time := 1.5
@export var explosion_radius := 5.0
@export var explosion_impulse := 900.0
@export var explosion_heat := 150.0
## Velocidade de impacto (m/s) que detona o objeto na hora.
@export var impact_detonation_speed := 9.0

@export_group("Futuro")
## Reservado para eletricidade (ainda sem efeito).
@export var conductive := false


## true se o material só esquenta (não queima) e guarda o calor.
func stores_heat() -> bool:
	return not flammable and max_heat > 0.0


## Material de um corpo do mundo. PhysicsProp usa o próprio; qualquer nó pode declarar o seu
## com o metadado "material_data"; chão e paredes estáticos sem declaração contam como solo.
## Personagens e o resto do mundo não têm material (null).
static func of(node: Node) -> PropMaterial:
	if node == null:
		return null
	if node is PhysicsProp:
		return (node as PhysicsProp).material_data
	if node.has_meta(&"material_data"):
		return node.get_meta(&"material_data") as PropMaterial
	if node is StaticBody3D and not node is AnimatableBody3D:
		return load(DEFAULT_GROUND_PATH) as PropMaterial
	return null


## Lei da Terra: material do que está logo abaixo de `point` (até `depth` metros), ou null se não
## houver nada ali. Quem pergunta decide o que fazer com earth_workable e earth_force_factor.
static func ground_under(context: Node3D, point: Vector3, depth := 2.0, exclude: Array[RID] = []) -> PropMaterial:
	var query := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.05, point + Vector3.DOWN * depth)
	query.exclude = exclude
	var hit := context.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return of(hit.collider as Node)

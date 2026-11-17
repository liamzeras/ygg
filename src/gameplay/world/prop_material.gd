class_name PropMaterial
extends Resource
## Propriedades físicas e elementais de um material.
## Ver design/gdd/physics-magic-system.md (seções Materiais e As leis da fatia).

## Material do chão que não declara o próprio (chão da arena, paredes): é concreto (decisão do
## Liam, 2026-11-17), e a Terra pode manipulá-lo.
const DEFAULT_GROUND_PATH := "res://assets/data/materials/concrete.tres"
## Estágios do Quebrável: 0 inteiro, 1-3 rachado, 4 = vira pedaços (pedido do Liam).
const BREAK_STAGES := 4

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

@export_group("Quebrável")
## O objeto racha e vira pedaços quando apanha o bastante (lei do Quebrável).
@export var breakable := true
## Variação de velocidade (m/s) que um golpe teria de dar no objeto inteiro para avançar
## um estágio. Impulso por estágio = break_toughness x massa (madeira 6, pedra 2,8, metal 12).
@export var break_toughness := 6.0
## Golpes menores que esta fração do impulso por estágio não deixam marca (empurrões, apoio).
@export_range(0.0, 1.0) var break_min_fraction := 0.25
## Velocidade de batida (m/s) acima da qual uma queda ou colisão começa a rachar o objeto.
@export var break_impact_speed := 10.0
## Dureza de uma estrutura fixa do cenário feita deste material (1 = concreto). O impulso por
## estágio da estrutura é BreakRules.structure_stage_impulse x dureza; o tamanho não conta
## (decisão do Liam, 2026-11-17). Objetos soltos não usam isto.
@export var hardness := 1.0
## Em quantos pedaços o objeto se parte no último estágio.
@export_range(2, 8) var break_pieces := 4

@export_group("Explosão")
@export var explosive := false
## Segundos queimando antes de explodir.
@export var fuse_time := 1.5
## Variação do pavio, para mais ou para menos (0,1 = até 10%). Barris acesos juntos não
## explodem todos no mesmo tick.
@export_range(0.0, 0.5) var fuse_jitter := 0.1
@export var explosion_radius := 5.0
@export var explosion_impulse := 900.0
@export var explosion_heat := 150.0
## Velocidade de impacto (m/s) que detona o objeto na hora.
@export var impact_detonation_speed := 9.0

@export_group("Futuro")
## Reservado para eletricidade (ainda sem efeito).
@export var conductive := false


## Lei do Quebrável: impulso (N·s) que avança um estágio num objeto com esta massa.
func stage_impulse(body_mass: float) -> float:
	return break_toughness * maxf(body_mass, 0.01)


## Dano (N·s) que um golpe deixa num objeto desta massa: o impulso inteiro, ou 0 se for
## fraco demais para marcar (abaixo de break_min_fraction de um estágio) ou se não quebra.
func hit_damage(impulse: float, body_mass: float) -> float:
	if not breakable or impulse < stage_impulse(body_mass) * break_min_fraction:
		return 0.0
	return impulse


## Estágio (0 = inteiro, 1 a 3 = rachado, BREAK_STAGES = pedaços) para um dano acumulado.
## Construções que não são PhysicsProp (pilar de pedra) podem guardar o próprio dano e usar isto.
func stage_for(damage: float, body_mass: float) -> int:
	return mini(int(damage / stage_impulse(body_mass)), BREAK_STAGES)


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

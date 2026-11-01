class_name KineticDartAbility
extends Ability
## Psiônico — Dardo Cinético (design/gdd/mage-psionic.md): segurar carrega, soltar dispara.
## Agulha de força que não aquece nem explode. O impacto sai da física: ver
## MaterializedProjectile. custo = lerp(min_cost, cost, carga).

@export var min_speed := 30.0
@export var max_speed := 60.0
## Massa em kg (0,004 = 4 g) sem carga e com carga cheia.
@export var min_mass := 0.004
@export var max_mass := 0.007
## Custo do clique rápido (carga 0). `cost` é o custo com carga cheia.
@export var min_cost := 4.0
## Gravidade do projétil (0 = reto, 1 = cai como pedra).
@export var gravity_scale := 0.05
@export var lifetime := 4.0


func cost_at(charge: float) -> float:
	return lerpf(min_cost, cost, clampf(charge, 0.0, 1.0))


func max_charge_for(budget: float) -> float:
	if cost <= min_cost:
		return 1.0
	return clampf((budget - min_cost) / (cost - min_cost), 0.0, 1.0)


func activate(player: Player) -> void:
	activate_charged(player, 0.0)


func activate_charged(player: Player, charge: float) -> void:
	var direction := player.get_aim_direction()
	var dart := KineticDartProjectile.new()
	dart.source_name = display_name
	dart.mass = lerpf(min_mass, max_mass, charge)
	dart.power = power(player)
	dart.gravity_scale = gravity_scale
	dart.lifetime = lifetime
	player.get_tree().current_scene.add_child(dart)
	dart.global_position = player.get_aim_origin() + direction * 0.6
	dart.launch(direction * lerpf(min_speed, max_speed, charge), player.velocity)
	dart.add_collision_exception_with(player)
	player.add_shake(0.05 + 0.15 * charge)

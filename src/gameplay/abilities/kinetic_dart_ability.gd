class_name KineticDartAbility
extends Ability
## Psiônico — Dardo Cinético (design/gdd/mage-psionic.md): segurar carrega, soltar dispara.
## Projétil de impulso puro: não aquece, não explode.
## impulso = lerp(mín, máx, carga) x mult(Inteligência); custo = lerp(min_cost, cost, carga).

@export var min_impulse := 25.0
@export var max_impulse := 80.0
@export var min_speed := 30.0
@export var max_speed := 60.0
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


func impulse_at(player: Player, charge: float) -> float:
	return lerpf(min_impulse, max_impulse, charge) * power(player)


func activate(player: Player) -> void:
	activate_charged(player, 0.0)


func activate_charged(player: Player, charge: float) -> void:
	var direction := player.get_aim_direction()
	var dart := KineticDartProjectile.new()
	dart.source_name = display_name
	dart.impulse = impulse_at(player, charge)
	dart.launch_speed = lerpf(min_speed, max_speed, charge)
	dart.gravity_scale = gravity_scale
	dart.lifetime = lifetime
	player.get_tree().current_scene.add_child(dart)
	dart.global_position = player.get_aim_origin() + direction * 0.6
	dart.launch(direction)
	dart.add_collision_exception_with(player)
	player.add_shake(0.05 + 0.15 * charge)

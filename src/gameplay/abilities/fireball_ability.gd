class_name FireballAbility
extends Ability
## Elementalista — Bola de Fogo (design/gdd/mage-elementalist.md): projétil em arco que
## explode ao tocar algo, empurra e aquece. Com `charge_time` > 0, segurar carrega:
## mais carga = mais pesada, rápida, maior e mais quente. Calor x mult(Inteligência).
## O empurrão sai da física: ver MaterializedProjectile. Sem carga, usa os valores máximos.

## Gravidade do projétil (0 = reto, 1 = cai como pedra).
@export var gravity_scale := 0.2
@export var lifetime := 4.0
@export var min_speed := 16.0
@export var projectile_speed := 22.0
## Massa em kg (0,01 = 10 g) sem carga e com carga cheia.
@export var min_mass := 0.008
@export var max_mass := 0.01
@export var min_blast_radius := 1.0
@export var blast_radius := 1.6
@export var min_heat := 35.0
@export var base_heat := 60.0
## Custo do clique rápido (carga 0). `cost` é o custo com carga cheia.
@export var min_cost := 6.0


func cost_at(charge: float) -> float:
	return lerpf(min_cost, cost, clampf(charge, 0.0, 1.0))


func max_charge_for(budget: float) -> float:
	if cost <= min_cost:
		return 1.0
	return clampf((budget - min_cost) / (cost - min_cost), 0.0, 1.0)


func activate(player: Player) -> void:
	activate_charged(player, 1.0)


func activate_charged(player: Player, charge: float) -> void:
	var direction := player.get_aim_direction()
	var projectile := FireballProjectile.new()
	projectile.ability = self
	projectile.mass = lerpf(min_mass, max_mass, charge)
	projectile.power = power(player)
	projectile.heat = lerpf(min_heat, base_heat, charge) * power(player)
	projectile.blast_radius = lerpf(min_blast_radius, blast_radius, charge)
	player.get_tree().current_scene.add_child(projectile)
	projectile.global_position = player.get_aim_origin() + direction * 0.6
	projectile.launch(direction * lerpf(min_speed, projectile_speed, charge), player.velocity)
	projectile.add_collision_exception_with(player)

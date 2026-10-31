class_name FireballAbility
extends Ability
## Mago — Bola de Fogo: projétil que explode ao tocar algo, empurra e aquece.
## Calor e impulso = base x mult(Inteligência).

@export var projectile_speed := 22.0
## Gravidade do projétil (0 = reto, 1 = cai como pedra).
@export var gravity_scale := 0.2
@export var lifetime := 4.0
@export var blast_radius := 1.6
@export var base_impulse := 50.0
@export var base_heat := 60.0


func activate(player: Player) -> void:
	var direction := player.get_aim_direction()
	var projectile := FireballProjectile.new()
	projectile.ability = self
	projectile.impulse = base_impulse * power(player)
	projectile.heat = base_heat * power(player)
	player.get_tree().current_scene.add_child(projectile)
	projectile.global_position = player.get_aim_origin() + direction * 0.6
	projectile.linear_velocity = direction * projectile_speed
	projectile.add_collision_exception_with(player)

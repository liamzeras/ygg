class_name ArcaneLeapAbility
extends Ability
## Mago — Salto Arcano: impulso mágico para cima e para frente (funciona no ar)
## que também empurra objetos ao redor dos pés.
## Velocidade vertical = base x raiz(mult(Inteligência)).

@export var base_up_speed := 5.0
@export var forward_speed := 4.0
## Quanto da velocidade horizontal atual é mantida.
@export_range(0.0, 1.0) var keep_momentum := 0.5
@export var blast_radius := 2.0
@export var base_blast_impulse := 60.0


func activate(player: Player) -> void:
	var forward := player.get_flat_forward() * forward_speed
	var current := player.velocity * keep_momentum
	var up := base_up_speed * sqrt(power(player))
	player.velocity = Vector3(current.x + forward.x, up, current.z + forward.z)
	Explosion.detonate(player, player.global_position, blast_radius, base_blast_impulse * power(player), 0.0,
			[player.get_rid()], Color(0.6, 0.45, 1.0))
	player.add_shake(0.15)

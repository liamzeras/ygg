class_name ArcaneLeapAbility
extends Ability
## Pulo duplo (todas as classes): impulso no ar, para cima e na direção
## em que o jogador está andando. A versão arcana do mago também empurra o que está aos pés.
## Usado com Espaço no ar; o jogador garante só um por salto.
## Velocidade vertical = base x raiz(mult(atributo)): Agilidade no cavaleiro, Inteligência no mago.

@export var base_up_speed := 5.0
## Impulso horizontal na direção do movimento (0 se parado: sobe reto).
@export var directional_speed := 4.0
## Quanto da velocidade horizontal atual é mantida.
@export_range(0.0, 1.0) var keep_momentum := 0.5
@export var blast_radius := 2.0
@export var base_blast_impulse := 60.0


func activate(player: Player) -> void:
	var push := player.get_move_direction() * directional_speed
	var current := player.velocity * keep_momentum
	var up := base_up_speed * sqrt(power(player))
	player.velocity = Vector3(current.x + push.x, up, current.z + push.z)
	if base_blast_impulse > 0.0:
		Explosion.detonate(player, player.global_position, blast_radius, base_blast_impulse * power(player), 0.0,
				[player.get_rid()], Color(0.6, 0.45, 1.0))
	player.add_shake(0.15)

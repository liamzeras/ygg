class_name LavaFloorAbility
extends TerrainAbility
## Fogo — Chão de Lava (design/gdd/mage-fire.md): poça de lava no chão mirado que aquece tudo
## que está em cima, menos quem lançou. Área e duração crescem em partes iguais por nível:
## área = max_side² x nível / nível máximo; duração = max_duration x nível / nível máximo.
## Calor por segundo = heat_per_second x mult(atributo). Só uma por vez.

@export var max_side := 9.0
@export var max_duration := 10.0
@export var heat_per_second := 60.0

var _active: LavaPool


func side(player: Player) -> float:
	return sqrt(max_side * max_side * level_share(player))


func duration(player: Player) -> float:
	return max_duration * level_share(player)


func get_active_pool() -> LavaPool:
	return _active if is_instance_valid(_active) else null


func activate(player: Player) -> void:
	var ground := find_ground(player)
	if ground.is_empty():
		return
	if is_instance_valid(_active):
		_active.queue_free()
	var pool := LavaPool.new()
	pool.side = side(player)
	pool.duration = duration(player)
	pool.heat_per_second = heat_per_second * power(player)
	pool.caster = player
	pool.heat_owner = player
	player.get_parent().add_child(pool)
	pool.global_transform = Transform3D(Basis.looking_at(player.get_flat_forward(), Vector3.UP), ground.position)
	_active = pool

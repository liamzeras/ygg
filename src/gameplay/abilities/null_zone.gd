class_name NullZone
extends GravityZone
## Zona Nula (ver NullZoneAbility). Trava o kit de todo jogador dentro: quem lançou fica com
## os golpes de `kit`, os outros ficam sem habilidades. Projéteis mágicos dentro somem.

var kit := {}
## Quantos projéteis já apagou (para testes e para o HUD).
var erased := 0

var _shape: BoxShape3D


func _ready() -> void:
	super()
	_shape = BoxShape3D.new()
	_shape.size = Vector3(side, HEIGHT, side)


func _on_enter(character: Node3D) -> void:
	if character.has_method("set_ability_lock"):
		character.set_ability_lock(self, kit if character == caster else {})


func _on_exit(character: Node3D) -> void:
	if character.has_method("clear_ability_lock"):
		character.clear_ability_lock(self)


func _tick(_delta: float) -> void:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _shape
	query.transform = Transform3D(global_basis, global_position + Vector3.UP * HEIGHT / 2.0)
	for result in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var projectile := result.collider as MaterializedProjectile
		if projectile and not projectile.is_queued_for_deletion():
			erased += 1
			projectile.queue_free()

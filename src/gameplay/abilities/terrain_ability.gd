class_name TerrainAbility
extends Ability
## Base das magias de terreno do Elementalista (Escada de Pedra, Lamaçal): só funcionam
## mirando chão firme (estático e plano). Mirar um objeto solto procura o chão embaixo dele.
## Sem chão válido, o uso é bloqueado sem gastar Mana ("Precisa de chão firme").

@export var reach := 12.0
## Inclinação máxima (graus) do chão onde a magia pode nascer.
@export var max_slope := 45.0
## Lei da Terra: só nasce sobre material que a Terra trabalha (solo, pedra; ver
## PropMaterial.earth_workable). Magias de Terra ligam; as de outros elementos não.
@export var needs_earth := false


## Ponto e normal do chão mirado ({position, normal}), ou {} se não houver chão válido.
func find_ground(player: Player) -> Dictionary:
	var space := player.get_world_3d().direct_space_state
	var origin := player.get_aim_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + player.get_aim_direction() * reach)
	query.exclude = [player.get_rid()]
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return {}
	# Mirou um objeto solto: procura o chão logo abaixo dele.
	if hit.collider is RigidBody3D:
		var down := PhysicsRayQueryParameters3D.create(hit.position, hit.position + Vector3.DOWN * 3.0)
		down.exclude = [player.get_rid(), (hit.collider as RigidBody3D).get_rid()]
		hit = space.intersect_ray(down)
		if hit.is_empty():
			return {}
	if not _is_ground(hit.collider) or (hit.normal as Vector3).angle_to(Vector3.UP) > deg_to_rad(max_slope):
		return {}
	if needs_earth and not _is_earth(hit.collider):
		return {}
	return {"position": hit.position, "normal": hit.normal}


func get_block_reason(player: Player) -> String:
	if not find_ground(player).is_empty():
		return ""
	return "Precisa de terra ou pedra" if needs_earth else "Precisa de chão firme"


func _is_ground(collider: Object) -> bool:
	return collider is StaticBody3D and not collider is AnimatableBody3D and not collider is TrainingDummy


## Lei da Terra: o material do chão (PropMaterial.of) pode ser trabalhado pela Terra.
func _is_earth(collider: Object) -> bool:
	var material := PropMaterial.of(collider as Node)
	return material != null and material.earth_workable

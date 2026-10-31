class_name Ability
extends Resource
## Base de todas as habilidades. Cada subclasse implementa `activate`.
## O jogador controla custo e recarga; a habilidade só aplica o efeito no mundo.
## Os valores-base ficam no .tres da classe e são escalados pelo atributo
## `scaling_attribute` (multiplicador 1.0 = humano comum).

@export var display_name := ""
@export_multiline var description := ""
## Custo (em habilidades carregáveis: custo com carga cheia).
@export var cost := 20.0
## De qual recurso sai o custo: esforço físico (Vigor) ou magia (Mana).
@export var cost_pool := Player.Pool.STAMINA
@export var cooldown := 1.0
@export var scaling_attribute := Attributes.Kind.STRENGTH

@export_group("Carga")
## Segundos até a carga cheia. 0 = dispara ao apertar. Maior que 0 = segurar carrega e
## soltar dispara (estilo arco); o custo depende da carga (ver `cost_at`).
@export var charge_time := 0.0
## Segurando a carga cheia por mais que isso (s), a mira começa a tremer.
@export var tremor_delay := 1.5
## Amplitude do tremor (graus) para Destreza humana. Divide por mult(Destreza).
@export var tremor_degrees := 0.0


## Multiplicador de potência vindo do atributo do jogador.
func power(player: Player) -> float:
	return player.stats.mult(scaling_attribute)


func is_chargeable() -> bool:
	return charge_time > 0.0


## Custo para a carga `charge` (0 a 1). Padrão: custo fixo.
func cost_at(_charge: float) -> float:
	return cost


## Maior carga (0 a 1) que `budget` de recurso consegue pagar.
func max_charge_for(_budget: float) -> float:
	return 1.0


## true quando usar de novo apenas desliga o efeito (sem custo nem recarga).
func toggles_off(_player: Player) -> bool:
	return false


## Motivo para bloquear o uso (ex.: "Precisa estar no chão"), ou "" se pode usar.
func get_block_reason(_player: Player) -> String:
	return ""


func activate(_player: Player) -> void:
	pass


## Disparo de uma habilidade carregável. Padrão: ignora a carga.
func activate_charged(player: Player, _charge: float) -> void:
	activate(player)

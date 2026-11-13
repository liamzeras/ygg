class_name BotProfile
extends Resource
## Como um bot luta (design/gdd/combat-bot.md): distâncias, ritmo e pontaria. O kit e os
## atributos vêm do PlayerClassData da classe; aqui fica só o comportamento.

@export_group("Distância")
## Distância (m) que o bot tenta manter do alvo.
@export var preferred_range := 9.0
## Mais perto que isto, ele recua.
@export var min_range := 5.0
## Mais longe que isto, ele corre (gasta Vigor).
@export var sprint_range := 15.0

@export_group("Movimento")
## Segundos entre trocas de lado ao circular o alvo (mínimo e máximo).
@export var strafe_switch_min := 1.0
@export var strafe_switch_max := 2.5
## Segundos entre dashes de esquiva (mínimo e máximo).
@export var dash_interval_min := 2.5
@export var dash_interval_max := 5.0
## Chance de pular por segundo, no chão.
@export_range(0.0, 1.0) var jump_chance_per_second := 0.15

@export_group("Ataque")
## Carga escolhida para cada dardo, sorteada entre estes valores (0 a 1).
@export_range(0.0, 1.0) var charge_min := 0.35
@export_range(0.0, 1.0) var charge_max := 1.0
## Pausa extra (s) depois de cada disparo, sorteada entre estes valores.
@export var pause_min := 0.15
@export var pause_max := 0.5
## Erro de mira (graus) em cada disparo, para o jogador conseguir desviar.
@export var aim_error_degrees := 2.0
## Quanto do movimento do alvo o bot antecipa (0 = mira onde ele está, 1 = previsão perfeita).
@export_range(0.0, 1.0) var lead_factor := 0.8

@export_group("Defesa")
## Projétil vindo na direção do bot, mais perto que isto (m), dispara o Campo Lento.
@export var threat_range := 7.0

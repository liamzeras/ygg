# Combate contra bot: vida, renascer e o Psiônico agressivo

> Status: v1.0 · pedido do Liam em 2026-11-13 · aguarda playtest
> Código: `src/gameplay/combat/health.gd`, `src/gameplay/enemies/` (bot e perfil), `test_arena.gd` (F6)
> Dados: `assets/data/damage_rules.tres` (vida), `assets/data/enemies/psionic_bot.tres` (comportamento),
> `assets/data/classes/psionic.tres` (kit e atributos do bot)

## Overview (Visão geral)

Primeiro combate contra um inimigo com IA. **F6** chama um bot Mago Psiônico que ataca o jogador; apertar de
novo faz ele sumir. Jogador e bot têm vida. Ao chegar a 0, renascem no próprio ponto de nascimento, com vida
cheia e **0,5 s de invencibilidade**. Todo dano usa as mesmas regras do boneco de testes (`DamageRules`).

## Player Fantasy (Fantasia do jogador)

"Duelo de magos." O bot é rápido e insistente: circula a meia distância, carrega dardos e antecipa o seu
movimento. O jogador vence se mexendo, usando cobertura (paredes, Escada de Pedra) e o próprio kit. O bot dá
sinais claros: o orbe na mão dele cresce enquanto ele carrega o dardo.

## Detailed Rules (Regras)

### Vida (jogador e bot)

1. Vida máxima = 100 x mult(Vitalidade)^0,5. Cavaleiro ~128, magos ~103.
2. Tudo o que fere o boneco também fere personagens: dardos, Bola de Fogo, explosões, objetos arremessados,
   golpes, Investida, Dash, pedra subindo e caixas em chamas por perto.
3. Objeto só fere se vier mesmo na direção do alvo a mais de 2 m/s: andar contra uma caixa parada não machuca.
4. Em 0: renasce no ponto inicial (jogador: o início da arena; bot: o ponto dele, em (-4, 0, -8)), com vida
   cheia. Mana e Vigor do bot também enchem.
5. Por 0,5 s depois de renascer: não toma dano nem empurrão. O bot pisca nesse tempo.
6. HUD: barra vermelha de vida acima da Mana, clarão vermelho ao tomar dano e o aviso "Você caiu e renasceu".
   O bot mostra nome e vida em cima da cabeça.

### Bot Psiônico (F6)

- **Kit e atributos:** os mesmos do Psiônico jogável (`psionic.tres`): mesma Mana, Vigor, vida e dano.
- **Ataque:** carrega o Dardo Cinético por um tempo sorteado (35% a 100% da carga), mira prevendo 80% do seu
  movimento, com até 2° de erro, e dispara. Paga a Mana igual ao jogador: sem Mana, espera regenerar.
  Como o dardo herda o movimento de quem atira, o bot compensa o próprio movimento de lado na mira. Ele não
  dispara no meio de um dash.
- **Sem visão** (o boneco no caminho, por exemplo): contorna pelo lado em vez de empurrar o obstáculo.
- **Movimento:** tenta ficar a 9 m. Mais longe, ele se aproxima, e corre acima de 15 m. Mais perto que 5 m,
  ele recua. Na faixa certa, circula você e troca de lado a cada 1 a 2,5 s.
- **Esquiva:** dash lateral a cada 2,5 a 5 s (gasta Vigor) e um pulo de vez em quando.
- **Defesa:** quando um projétil seu vem na direção dele a menos de 7 m, ele ergue um Campo Lento em cima do
  projétil (custo e recarga do Campo Lento: 30 de Mana, 8 s).
- **Visão:** só ataca com linha de visão. Paredes, terreno e o boneco bloqueiam; caixas e personagens, não. Sem visão,
  ele circula e se aproxima (ainda não tem mapa de caminhos).

## Formulas (Fórmulas)

```
vida_max   = 100 x mult(VIT)^0,5                  (Psiônico, VIT 16: 103)
dano       = DamageRules (impacto e calor), igual ao boneco
tempo_de_carga do bot = charge_time / velocidade_de_ataque   (Psiônico: ~0,9 s para carga cheia)
mira       = centro do alvo + velocidade do alvo x tempo de voo x 0,8, com erro de até ±2°
```

Exemplo: um dardo cheio do bot faz ~17,6 de dano. Um Psiônico (103 de vida) cai com ~6 dardos cheios.

## Edge Cases (Casos-limite)

- **F6 com o bot vivo:** ele some na hora, sem renascer.
- **F5:** recarrega a arena e remove o bot.
- **Dardo do bot no boneco ou nos alvos voadores:** conta no combo do boneco, como qualquer golpe.
- **Explosão perto de você:** também fere você. Uma Bola de Fogo na parede a 1 m machuca quem a lançou. O Pulo
  Arcano não fere quem pula.
- **Braseiro:** não fere personagens; só aquece objetos.
- **Bot caindo da arena:** renasce no ponto dele.

## Dependencies (Dependências)

`Health` (componente filho) ← `DamageRules.receiver_of()` ← `Explosion`, `KineticDartProjectile`,
`ShieldBashAbility`, `PhysicsProp`. `PsionicBot` usa `PlayerClassData`, `AttributeRules`, `KineticDartAbility`,
`SlowField` e `BotProfile`. A arena cria a vida do jogador e o bot; `hud.gd` mostra a vida. `player.gd` não
mudou: a vida fica num filho chamado `Health`.

## Tuning Knobs (Ajustes)

| Ajuste | Onde | Valor | Faixa segura | Efeito |
|---|---|---|---|---|
| `base_health` / `health_exponent` | `damage_rules.tres` | 100 / 0,5 | 60–200 / 0,3–1 | Quanto aguenta cada um |
| `respawn_invulnerability` | `damage_rules.tres` | 0,5 s | 0,2–2 s | Proteção ao renascer |
| `preferred_range` / `min_range` | `psionic_bot.tres` | 9 / 5 m | 6–15 / 3–8 | Distância de luta |
| `aim_error_degrees` / `lead_factor` | `psionic_bot.tres` | 2° / 0,8 | 0,5–6° / 0–1 | Dificuldade da mira |
| `charge_min` / `charge_max` | `psionic_bot.tres` | 0,35 / 1 | 0–1 | Força e ritmo dos tiros |
| `dash_interval_*`, `jump_chance_per_second` | `psionic_bot.tres` | 2,5–5 s, 0,15 | — | Quão difícil é acertar o bot |
| `threat_range` | `psionic_bot.tres` | 7 m | 0 (desliga) a 12 | Reação com Campo Lento |

## Acceptance Criteria (Critérios de aceite)

Automáticos (teste de fumaça, suíte `monstros`):

- [x] Jogador tem vida pela Vitalidade; dardo tira vida; andar contra caixa parada não machuca.
- [x] Vida em 0: renasce no início com vida cheia; dano nos 0,5 s seguintes é ignorado; depois volta a valer.
- [x] F6 chama o bot com os atributos do Psiônico; ele acerta o jogador em poucos segundos e gasta Mana.
- [x] Com o jogador parado no início, o bot acerta em todas as 20 rodadas do diagnóstico, entre 0,7 e 2,2 s (limite do teste: 8 s).
- [x] Bot com vida em 0 renasce no ponto dele, cheio e invencível; F6 de novo faz ele sumir.

Playtest (Liam):

- [ ] O bot é agressivo, mas dá para desviar dos dardos andando de lado e usando cobertura.
- [ ] Dá para ler quando ele vai atirar (orbe na mão).
- [ ] Renascer é claro (aviso, posição) e os 0,5 s não parecem nem curtos nem longos.
- [ ] A barra de vida e o clarão vermelho comunicam o dano sem atrapalhar.

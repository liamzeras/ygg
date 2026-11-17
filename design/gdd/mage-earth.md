# Mago da Terra

Pedido do Liam em 2026-11-16. Parte da fatia vertical Fogo, Terra e Gravidade
(`design/sabio/inspiracao/magos-elementais.md`). Substitui a parte de Terra de `mage-elementalist.md`.

## 1. Overview

O Mago da Terra luta corpo a corpo com socos e chutes de pedra, molda o chão com a Escada de Pedra e o
Terremoto, e prende quem passa com o Lamaçal. A lei da Terra vale para tudo: ela só trabalha a pedra e o
solo que existem ali, e o que é de pedra responde mais forte a ela.

| Tecla | Habilidade | Recurso |
|---|---|---|
| Botão esq. | Soco de Pedra | Vigor |
| Botão dir. | Chute de Pedra | Vigor |
| Q | Escada de Pedra (já existia) | Mana |
| F | Terremoto | Mana |
| Ctrl | Lamaçal (já existia; antes no F) | Mana |
| E | Pegar e arremessar (todas as classes) | — |

O dash saiu de todas as classes por enquanto (decisão do Liam: "muito OP"). O código continua no projeto e
volta colocando o Dash no Ctrl de uma classe, no `.tres`.

## 2. Player Fantasy

Ser uma rocha que bate. O soco num bloco de pedra o lança longe como um projétil; na parede, cobre as mãos
de pedra e passa a bater mais forte e mais longe, a ponto de socar o ar e arremessar pedregulhos. O Terremoto
transforma um pedaço da arena em relevo, com estalagmites e pedras soltas, e joga para cima quem estava ali.

## 3. Detailed Rules

### Soco e Chute de Pedra

- Golpe instantâneo à frente do corpo, na direção da mira no plano horizontal.
- **Faixa do corpo:** o soco só atinge o que está da cintura de quem golpeia para cima (de 0,9 m a 1,9 m
  acima dos pés). O chute só atinge da cintura para baixo (de 0,05 m a 0,9 m). Uma caixa no chão é alvo de
  chute, e o boneco é alvo dos dois.
- Atinge um alvo só: o mais próximo dentro da área do golpe.
- **Objeto solto:** recebe o impulso do golpe. Se o material for de terra (pedra e metal hoje; concreto
  quando existir), o impulso dobra. O objeto não perde velocidade artificial: voa com a energia que recebeu
  e, ao bater em algo, causa dano por massa x velocidade (regra que já existe nos objetos).
- **Personagem ou boneco:** toma dano pelo impulso (regra de dano já existente) e é empurrado.
- **Construção da Terra** (pilar da Escada, coluna do Terremoto), playtest de 2026-11-17: segue a lei do
  Quebrável do mundo (design/gdd/physics-magic-system.md) com o material `earth_construct.tres` (pedra moldada).
  Cada golpe soma `hit_damage(impulso, massa)`; o estágio é `stage_for(dano, massa)` (0 inteiro, 1 a 3 rachado e
  mais escuro, 4 pedaços). No 4, a parte acima do chão vira `break_pieces` pedaços que saem com a velocidade
  do golpe (impulso / massa). Como é pedra, também reveste o membro.
- **Objeto solto:** o golpe usa `PhysicsProp.take_hit`: empurra, racha e, ao quebrar, os pedaços seguem o golpe.
- **Superfície que não se move** de terra ou pedra (lei da Terra, `earth_workable`): reveste o membro de pedra
  por alguns segundos. O soco reveste as mãos e o chute reveste os pés, separadamente. Madeira e metal fixos
  não revestem.
- **Revestido:** o golpe tem mais alcance e mais impulso. Golpear o ar arremessa um pedregulho de pedra
  na direção da mira (soco) ou rasteiro (chute). O pedregulho é um objeto de pedra comum: pode ser pego,
  socado de novo e some depois de alguns segundos.
- Golpear o ar sem revestimento não faz nada além de gastar o Vigor.

### Terremoto

- Nasce no chão mirado, como o Lamaçal e a Escada (precisa de chão firme).
- **Tamanho pelo nível do personagem:** a área cresce em partes iguais por nível, até 9 x 9 m no nível 99.
- A área vira uma grade de colunas de pedra, cada uma com altura sorteada entre 0,2 e 2 m. Parte das
  colunas vira estalagmite (ponta fina e alta). Pedregulhos soltos de pedra nascem sobre o relevo.
- Ao surgir, joga para cima e causa dano a todos os personagens e objetos na área, menos quem lançou.
  Quem lançou sobe junto com o relevo, se estiver em cima.
- Depois de 5 s o relevo afunda e os pedregulhos somem. Só um Terremoto por vez: lançar outro afunda o
  anterior.

## 4. Formulas

| Grandeza | Fórmula |
|---|---|
| Impulso do golpe (N·s) | `base_impulse x mult(Força) x (2 se material de terra) x (coated_multiplier se revestido)` |
| Dano no alvo | `(impulso − 10) x 0,1` (`damage_rules.tres`) |
| Alcance do golpe (m) | `reach`, ou `coated_reach` se revestido |
| Pedregulho | `pebble_speed x raiz(mult(Força))` m/s; massa = volume x densidade da pedra |
| Área do Terremoto (m²) | `81 x nível / 99` (nível 1 a 99) |
| Lado do Terremoto (m) | `raiz(área)` |
| Colunas por lado | `teto(lado / max_cell)`; largura de cada uma = `lado / colunas` |
| Dano do Terremoto (impulso, N·s) | `base_damage_impulse x mult(Inteligência)` |
| Empurrão para cima | personagens: `launch_impulse x raiz(mult(Inteligência))` N·s; objetos: `launch_speed x raiz(mult(Inteligência))` m/s |

Valores iniciais (a ajustar no playtest): soco e chute com `base_impulse` 140 e 170, 8 e 10 de Vigor, recarga
0,45 e 0,6 s, alcance 1,4 m (2,4 m revestido), revestido x1,5 por 6 s. Pedregulho de 0,25 m a 16 m/s.
Terremoto: 40 de Mana, recarga 8 s, `base_damage_impulse` 250, `launch_impulse` 420, `launch_speed` 6 m/s, colunas de até 1 m, 15% de estalagmites,
1 pedregulho a cada 8 colunas, alcance de 12 m.

Com Força humana (1x), o soco no boneco dá (140 − 10) x 0,1 = 13 de dano; revestido, 20. Um bloco de pedra de
0,6 m (≈ 76 kg) socado recebe 280 N·s e sai a ≈ 3,7 m/s.

## 5. Edge Cases

- Segurando um objeto: E arremessa. O botão esquerdo continua arremessando o que a Telecinese segura.
  Com as mãos ocupadas, soco e chute não saem.
- Golpe na própria escada ou no relevo do Terremoto: racha a construção e reveste.
- Terremoto no nível 1: a área é menor que 1 m², então vira uma coluna só.
- Terremoto mirando o céu ou uma rampa íngreme: bloqueado sem gastar Mana ("Precisa de chão firme").
- Revestimento acaba no meio do golpe: vale o estado na hora do golpe.

## 6. Dependencies

- `damage_rules.tres` (dano por impulso), objetos físicos (`physics_prop.gd`, dano por impacto).
- Escada de Pedra (`stone_pillar.gd`): as colunas do Terremoto são pilares de pedra.
- Atributos (`attributes.md`): Força nos golpes, Inteligência no Terremoto.
- HUD e menu de classes mostram as teclas novas (botão direito e Ctrl).

## 7. Tuning Knobs

Todos em `assets/data/classes/earth.tres`: impulsos, custos, recargas, alcances, faixas do corpo, duração e
multiplicador do revestimento, tamanho e velocidade do pedregulho, materiais de terra, tamanho máximo,
alturas, chance de estalagmite, pedregulhos e duração do Terremoto.

## 8. Acceptance Criteria

1. Soco num bloco de pedra o lança com o dobro do impulso de uma caixa de madeira de mesma massa.
2. Soco não atinge uma caixa no chão; chute atinge. Os dois atingem o boneco.
3. Socar a parede reveste as mãos; depois disso, socar o ar arremessa um pedregulho, e sem revestimento não.
   Socar parede de madeira não reveste.
4. Revestido, o soco no boneco dá mais dano que sem revestimento.
5. Terremoto no nível 99 cobre 9 x 9 m; no nível 50, cerca de metade da área.
6. Terremoto joga para cima e fere o boneco e as caixas na área, e não fere quem lançou.
7. Relevo com alturas entre 0,2 e 2 m e pelo menos uma estalagmite no tamanho máximo; tudo some depois de 5 s.
8. Nenhuma classe tem dash; E pega e arremessa em todas.
- Socos seguidos num pilar o racham em estágios e, no fim, o desfazem em 6 pedaços que seguem o golpe.
- Escada, Lamaçal e Terremoto só nascem sobre terra ou pedra (lei da Terra); a massa do pilar vem de earth_construct.tres.

## Medido no teste automático (2026-11-16)

Ficha da Terra (Força 16, Inteligência 30): soco no boneco 10,1 de dano (15,7 revestido), chute 12,5,
Terremoto 54,6 no boneco. O Terremoto está forte para um golpe de área: é o primeiro número a revisar no
playtest (`base_damage_impulse`).

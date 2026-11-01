# Mago Elementalista

> Status: v1.0 · desenhado com carta branca do Liam ("pode começar livremente") · 2026-10-31
> Implementado; aguarda o 3º playtest. Irmão do `mage-psionic.md`.
> Código: `fireball_ability.gd`, `terrain_ability.gd`, `stone_pillar_ability.gd`, `mud_ability.gd`
> (em `src/gameplay/abilities/`), `stone_pillar.gd` e `mud_patch.gd` (em `src/gameplay/world/`).
> Dados: `assets/data/classes/mage.tres`.

## Overview (Visão geral)

O Elementalista é a especialização do Mago que **cria matéria e energia**: fogo, pedra e lama.
Enquanto o Psiônico só muda a velocidade do que já existe, o Elementalista muda o **terreno**:
ergue colunas de pedra, amolece o chão e incendeia. É o arqueiro de artilharia: projétil
lento e em arco, mas que deixa o lugar diferente de como estava.

## Player Fantasy (Fantasia do jogador)

"Eu moldo o campo de batalha."

- Erguer um pilar embaixo de uma caixa e vê-la voar.
- Subir a escada de pilares para alcançar a torre que o pulo não alcança.
- Fazer um barril em chamas rolar para dentro da lama e apagar.

O Psiônico é preciso e esperto; o Elementalista é **criativo e destrutivo**.

## Detailed Rules (Regras)

### Kit

| Tecla | Habilidade | Escala com | Gasta | Resumo |
|---|---|---|---|---|
| Botão esq. | **Bola de Fogo** (carregável) | Inteligência | Mana | Segurar carrega, soltar dispara. Explode, empurra e aquece. |
| Q | **Escada de Pedra** | fixa | Mana | 3 pilares de 0,85, 1,70 e 2,55 m; o do meio na mira. Sobe com W. Elevador, cobertura e catapulta. |
| F | **Lamaçal** | Inteligência | Mana | Área de lama: tudo dentro fica lento e o fogo se apaga. |
| Espaço 2x | **Pulo Arcano** | Inteligência | Vigor | O pulo duplo do mago (até 2 m). |
| Ctrl | **Dash** | fixo | Vigor | Igual em todas as classes (ver `attributes.md`). |

A Telecinese saiu do Elementalista: ela é do Psiônico. Ele ainda pega coisas com as mãos (botão direito).

### 1. Bola de Fogo carregável (botão esquerdo)

1. Mesma regra de carga do Dardo Cinético: apertar carrega, soltar dispara, Mana paga no
   disparo, F ou pausa cancelam. Agilidade acelera a carga (velocidade de ataque).
2. Mais carga = projétil mais rápido, explosão maior, mais empurrão e mais calor.
3. Cai em arco (gravidade 20%): é artilharia, não tiro reto. O Psiônico é o atirador de precisão.
4. **Sem tremor de mira** (a dificuldade dela é o arco, não a firmeza).

### 2. Escada de Pedra (Q)

1. Mira um ponto do **chão firme** a até 12 m. Sobem **3 pilares de 1 x 1 m, com 0,85, 1,70 e 2,55 m de
   altura**, em linha na direção do olhar, em 0,35 s: o de **1,70 m nasce no ponto mirado**, o de
   0,85 m fica mais perto de quem lança e o de 2,55 m mais longe.
2. A altura é **fixa**: não depende de Inteligência.
3. O ponto mirado precisa ser chão estático e plano (inclinação até ~45°). Em objetos soltos,
   procura o chão embaixo deles; em paredes, outros pilares ou no ar: "Precisa de chão firme".
4. **Quem está em cima sobe junto** (elevador). O jogador sobe e para no topo; não é arremessado.
5. **Objetos soltos em cima são arremessados** para cima pela velocidade da subida (catapulta).
6. **A pedra subindo acerta** quem tem `register_hit` (boneco, alvos): massa x velocidade x transferência.
7. Dura 8 s e depois afunda em 0,6 s. **Uma escada por vez**: lançar outra derruba a anterior.
8. É sólida: bloqueia projéteis, objetos e personagens (cobertura).
9. **Subida automática:** encostar num degrau segurando W sobe sozinho (propriedade
   `auto_climb_height` do pilar). Outras direções não sobem. O pulo simples (0,85 m) também alcança cada degrau.

### 3. Lamaçal (F)

1. Mira um ponto do chão firme a até 12 m. Uma mancha de lama de 2,5 m de raio aparece ali.
2. **Objetos soltos** dentro da lama perdem quase toda a velocidade em ~1 s (barris param de rolar,
   caixas arremessadas não deslizam).
3. **Objetos em chamas** dentro da lama se apagam, e o calor deles cai rápido (lama molhada).
4. **Personagens** dentro da lama andam na metade da velocidade, **inclusive você** (é terreno,
   não magia mirada). Pulo e pulo duplo continuam normais.
5. Só um lamaçal por vez: lançar outro apaga o anterior.

### Atributos iniciais

Iguais ao Mago (FOR 16, AGI 15, VIT 16, DES 12, INT 30, SOR 6), iguais ao Psiônico.

## Formulas (Fórmulas)

`I` = mult(Inteligência) (Elementalista inicial: **2,22**, √I ≈ 1,49). `c` = carga (0 a 1).

### Bola de Fogo

```
tempo de carga = 0,8 s / velocidade_de_ataque
velocidade     = lerp(16, 30, c)  m/s     (gravidade 20%)
massa          = lerp(8, 10, c)  g
impulso        = massa x velocidade relativa ao alvo x 200 x I   N·s  → 57 a 133 (parado, alvo parado)
calor          = lerp(35, 80, c) x I              → 78 a 178
raio           = lerp(1,0, 1,8, c)  m
custo          = lerp(6, 24, c)  Mana
```

A velocidade do tiro soma a de quem lança: correndo a 7 m/s na direção do alvo, 37 m/s em vez
de 30 (+23% de impulso); recuando, 23 m/s (−23%). Só o impacto muda: o calor não depende da velocidade.
Dano medido no boneco: clique ≈ 13; carga cheia ≈ 30 (impacto + calor), igual em qualquer distância
e ponto do corpo. Mais forte que o Dardo cheio (~18), mas lento e em arco. Quem leva o acerto direto
recebe tudo; o respingo em volta cai com a distância até a superfície do corpo.

### Escada de Pedra

```
alturas  = 0,85, 1,70 e 2,55 m (fixas)
subida   = altura / 0,35 s                  2,4 / 4,9 / 7,3 m/s (passada aos objetos em cima)
massa    = 1 m² x altura x 350 kg/m³        298 / 595 / 893 kg
impacto  = massa x subida x 0,05            36 / 145 / 325 N·s → dano 2,6 / 13,5 / 31,5
custo 30 Mana · recarga 3 s · dura 8 s · afunda em 0,6 s · 1 escada por vez
```

### Lamaçal

```
raio     = 2,5 m
duração  = 4 s x √I                       Elementalista inicial ≈ 6 s
arrasto  = velocidade x e^(−3 x dt)       objetos perdem ~95% da velocidade em 1 s
calor    = −50 por segundo; em chamas → apaga na hora
personagens: velocidade x 0,5
custo 25 Mana · recarga 6 s
```

## Edge Cases (Casos-limite)

- **Mirado no céu ou numa parede**: nenhum pilar nasce, aviso "Precisa de chão firme", sem gastar Mana.
- **Degrau mais baixo ou mais alto sem chão, com parede no caminho ou em outro nível (±0,5 m)**: só esse
  degrau fica de fora; os outros nascem normalmente.
- **Pilar nasce embaixo do jogador**: o jogador sobe junto até o topo.
- **Pilar nasce embaixo do boneco de testes**: acerta uma vez e atravessa o boneco (estáticos não se empurram).
- **Pilar afunda com algo em cima**: desce junto; objetos caem normalmente.
- **Nova escada com uma ativa**: a anterior começa a afundar na hora.
- **Pilar dentro do Lamaçal**: funciona; objetos catapultados saem da lama e voltam a ser rápidos no ar.
- **Bola de Fogo no Lamaçal**: a explosão empurra e aquece normal, mas o que está dentro da lama apaga em seguida.
- **Barril de pólvora em chamas entra na lama**: apaga e o pavio para (não explode).
- **Lamaçal embaixo de você**: você também fica lento. Sair da lama devolve a velocidade na hora.
- **Carga da Bola de Fogo e F**: F cancela a carga (como no Psiônico) e lança o Lamaçal.

## Dependencies (Dependências)

| Sistema | Como o Elementalista depende dele |
|---|---|
| `Ability` (carga) e `Player` | Bola de Fogo usa a mesma carga do Dardo Cinético. |
| `PhysicsProp` | Lamaçal freia props e chama `extinguish()`; Pilar empurra props (corpo animado). |
| `Explosion` / `MaterializedProjectile` | Bola de Fogo: massa, velocidade relativa e calor por carga. |
| `Player` | Lamaçal reduz a velocidade (`set_speed_effect`); Pilar carrega o jogador. |
| `DamageRules` / `TrainingDummy` | Dano da Bola de Fogo. |

Dependências inversas: `physics-magic-system.md` (lama apaga fogo; pilar é terreno) e
`attributes.md` (velocidade de ataque acelera a carga).

## Tuning Knobs (Ajustes)

Tudo em `assets/data/classes/mage.tres`.

| Ajuste | Valor | Faixa segura | Efeito |
|---|---|---|---|
| Bola de Fogo: massa / calor mín.–máx. | 8–10 g / 35–80 | ±50% | Dano e alcance do fogo. |
| Bola de Fogo: velocidade mín.–máx. | 16–30 m/s | 12–40 | Arco mais fechado ou mais aberto. |
| Bola de Fogo: custo mín.–máx. | 6–24 | 4–35 | Tiros cheios por barra de Mana (~6). |
| Escada: `step_heights` | 0,85, 1,70, 2,55 m | 0,5–4 m por degrau | Que plataformas a escada alcança. |
| Escada: `auto_climb_height` | 0,9 m | 0 (desliga) a 1,2 m | Quanto se sobe sozinho com W. |
| Escada: `aimed_step` | 1 (o do meio) | 0–2 | Qual degrau nasce no ponto mirado. |
| Escada: `width` | 1 m | 0,8–2 | Largura e distância entre os degraus. |
| Escada: tempo de subida | 0,35 s | 0,2–1,0 | Força da catapulta e do impacto (mais rápido = mais forte). |
| Escada: duração | 8 s | 4–15 | Tempo de cobertura e de escalada. |
| Escada: `stone_density` / `impact_transfer` | 350 / 0,05 | 200–600 / 0–0,15 | Dano da pedra subindo. |
| Lamaçal: raio / duração base | 2,5 m / 4 s | 1,5–4 / 2–8 | Área controlada. |
| Lamaçal: arrasto | 3 /s | 1–8 | Quão rápido as coisas param. |
| Lamaçal: velocidade de personagens | 0,5x | 0,3–0,8 | Punição por andar na lama. |

## Acceptance Criteria (Critérios de aceite)

Automáticos (teste de fumaça):

- [x] Bola de Fogo: clique gasta ~6 de Mana, carga cheia ~24; cheia causa mais dano que clique.
- [x] Escada: 3 pilares de 0,85, 1,70 e 2,55 m, o do meio no ponto mirado, o mais alto mais longe; somem depois de 8 s + afundar.
- [x] Escada mirada no céu não nasce e não gasta Mana.
- [x] Jogador em cima de um degrau sobe junto até o topo (± 0,1 m).
- [x] Caixa em cima do pilar é arremessada para cima (> 4 m/s).
- [x] Pilar mais alto subindo acerta o boneco (> 25 de dano).
- [x] Segurando W, sobe os 3 degraus; de ré encostado, não sobe.
- [x] Nova escada derruba a anterior (nunca mais de 3 pilares de pé).
- [x] Caixa a 6 m/s dentro do Lamaçal cai para menos de 1 m/s em 1 s.
- [x] Caixa em chamas dentro do Lamaçal apaga.
- [x] Jogador dentro do Lamaçal anda a metade da velocidade; fora, volta ao normal.

Playtest (Liam):

- [ ] Dá para chegar no topo da torre de 3 m usando um pilar ao lado dela.
- [ ] Catapultar uma caixa com o pilar é divertido e previsível.
- [ ] Parar um barril em chamas com a lama antes de explodir é viável.
- [ ] O arco da Bola de Fogo carregada é legível (dá para acertar o boneco de longe).

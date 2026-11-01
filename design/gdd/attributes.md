# Atributos e escala sobre-humana

> Status: rascunho v0.1 · implementado em `src/gameplay/stats/` · dados em `assets/data/attribute_rules.tres`

## Overview (Visão geral)

Seis atributos definem todos os números físicos do personagem. Eles são calibrados contra
um **humano comum** (homem adulto, ~1,80 m, em forma). O teto com bônus é 150, e nesse teto
o personagem é no máximo **8x** um humano naquele quesito (ajustável entre 5 e 10).

## Player Fantasy (Fantasia do jogador)

Subir um atributo deve ser *sentido* no mundo: carregar a caixa que antes era pesada,
alcançar o degrau que antes não dava. Mas mesmo no teto, o mundo continua crível.

## Detailed Rules (Regras)

### Recursos

Todo personagem tem **Vigor** (esforço físico: correr, pulo duplo, habilidades do cavaleiro)
e **Mana** (magia). O Vigor não tem barra: quando falta fôlego para correr ou dar o pulo
duplo, as bordas da tela escurecem de leve e "respiram". A Mana aparece em barra no HUD.

### Pulo duplo

Todas as classes: apertar Espaço de novo no ar. Um por salto (recarrega ao tocar o chão),
custa 25 de Vigor. **O topo do salto nunca passa de 2 m acima do chão de onde pulou**
(`max_total_height` no `.tres` da classe); alturas maiores só com habilidades de mobilidade
ainda não criadas. Cavaleiro: impulso só das pernas, escala com Força.
Mago: Pulo Arcano, escala com Inteligência e empurra o que está aos pés. Com atributos
altos o impulso só fica mais rápido, não mais alto.

### Duas regras dos atributos

**Regra 1, a escala:** o humano comum é a referência (FOR 20, AGI 12, VIT 15, DES 7, INT 11, SOR 5
= 1x). O teto com bônus é 150 = 8x.

**Regra 2, a progressão:** o personagem começa no nível 1 com 1 em cada atributo e sobe até o
nível 99. A cada nível ganha pontos para distribuir como quiser, até 99 por atributo (de 99 a 150,
só com bônus, que ainda não existem). O total do jogo vem da build de referência do nível 99: dois
atributos em 99, um em 50, um em 15 e dois em 1, ou seja, **259 pontos**.

| Nível | 1 | 2 | 10 | 27 | 50 | 75 | 99 |
|---|---|---|---|---|---|---|---|
| Pontos acumulados | 0 | 7 | 38 | 90 | 149 | 207 | 259 |

O ganho por nível é dinâmico: 7 no nível 2, caindo até 2 no fim. Por essa curva, um humano comum
(64 pontos) equivale ao nível 18. No nível 99 sem bônus, 99 de Força é ~5,2x um humano; só os bônus
levam a 8x. Um personagem de nível 1 fica bem abaixo do humano: Força 1 carrega ~1,6 kg.

**Builds de teste:** os atributos no `.tres` de cada classe são uma build pronta (nível 27). A
arena continua usando essas builds; o editor F2 tem nível, pontos e os atalhos "Nível 1" e "Nível 99".

### Dash

Todas as classes: Ctrl. Arrancada de 3 m em 0,2 s (15 m/s), na direção do WASD ou para a frente
se parado; com a frenagem, anda ~3,7 a 3,9 m. Custa 20 de Vigor, recarga de 1 s, funciona no ar e
não sobe. É movimento com colisão normal: desliza em parede de lado e para ao bater de frente,
sem atravessar. Não depende de atributo. Impacto = massa x 15 m/s x 0,1 (cavaleiro ≈ 14 de dano,
magos ≈ 9,5). Ajustes no `.tres` de cada classe: `distance` (2–5 m), `duration` (0,15–0,4 s),
`cost`, `cooldown`.

### Referência humana

| Atributo | Sigla | Humano | Afeta hoje |
|---|---|---|---|
| Força | FOR | 20 | carga nas mãos, velocidade de arremesso, empurrão ao andar, Golpe de Escudo, Investida e pulo duplo do cavaleiro |
| Agilidade | AGI | 12 | **só velocidade de ataque** (recarga e tempo de carga do botão esquerdo). Não muda corrida, pulo nem habilidades |
| Vitalidade | VIT | 15 | Vigor (tamanho e regeneração), Postura de Muralha |
| Destreza | DES | 7 | firmeza ao segurar objetos, tremor da mira do Dardo Cinético (Psiônico) |
| Inteligência | INT | 11 | Mana (tamanho e regeneração), magias, pulo duplo do mago |
| Sorte | SOR | 5 | sem efeito por enquanto (decisão do Liam) |

### Classes no nível inicial

| | FOR | AGI | VIT | DES | INT | SOR |
|---|---|---|---|---|---|---|
| Cavaleiro | 32 | 14 | 26 | 10 | 8 | 5 |
| Mago | 16 | 15 | 16 | 12 | 30 | 6 |

## Formulas (Fórmulas)

**Multiplicador** de um atributo (1,0 = humano):

```
alfa = ln(M) / ln(teto / humano)
mult(v) = (v / humano) ^ alfa
```

- `M` = `multiplier_at_cap` (8). `teto` = 150. `humano` = valor da tabela acima.
- Garante mult = 1 no humano e mult = M no teto **para todo atributo**, mesmo que a
  referência humana seja 7 (Destreza) ou 20 (Força). Sem isso, Destreza 150 seria 21x
  um humano, o que quebraria o pilar "crível".

**Pontos por nível:**

```
pontos_acumulados(nível) = arredonda(259 x ((nível - 1) / 98) ^ curva)      curva = 0,8
ganho(nível)             = pontos_acumulados(nível) - pontos_acumulados(nível - 1)
```

Arredondar o acumulado garante os 259 exatos no nível 99.

**Valores derivados** (humano → personagem):

| Valor | Humano | Fórmula | Cavaleiro | Mago |
|---|---|---|---|---|
| Carga nas mãos | 35 kg | 35 x mult(FOR) | 57 kg | 28 kg |
| Arremesso | 9 m/s | 9 x mult(FOR)^0,5 | 11,5 m/s | 8,0 m/s |
| Andar / correr | 4,5 / 7 m/s | fixo para todos (só montarias e efeitos mudam, a definir) | 4,5 / 7 | 4,5 / 7 |
| Altura do pulo | 0,85 m | igual para todos (teto 1,0 m) | 0,85 m | 0,85 m |
| Velocidade de ataque | 1,0x | mult(AGI)^0,5 (teto: 2,8x) | 1,07x | 1,10x |
| Degrau sem pular | 0,4 m | fixo para todos (`step_height`) | 0,4 m | 0,4 m |
| Vigor | 100 | 100 x mult(VIT)^0,5 | 128 | 103 |
| Mana | 100 | 100 x mult(INT)^0,5 | 88 | 149 |

Os expoentes (0,5 etc.) refletem física: energia escala com a força, velocidade com a raiz.

**Habilidades**: `efeito = valor-base x mult(atributo da habilidade)`, às vezes com raiz.
Ex.: Golpe de Escudo = 120 N·s x mult(FOR) → cavaleiro ≈ 195 N·s ≈ 3,2x o empurrão de um
humano (60 N·s). O boneco de testes mostra essa comparação ao vivo.

## Edge Cases (Casos-limite)

- Atributo abaixo do humano dá mult < 1 (mago com FOR 16 carrega 28 kg, menos que um humano).
- Atributo 0 ou negativo é tratado como 1.
- Atributo acima do teto continua crescendo pela mesma curva. A limitação de 150 deve vir
  do sistema de bônus (ainda não existe).

## Dependencies (Dependências)

`Attributes` (dados) → `AttributeRules.derive()` → `DerivedStats` → `Player` e `Ability.power()`.

## Tuning Knobs (Ajustes)

`attribute_rules.tres`: `reference_build` (99, 99, 50, 15: define o total de pontos), `level_curve`
(0,8; faixa segura 0,6–1,0: menor = início mais rápido), `max_level`, `base_cap`, `start_value`;
referência humana, `cap`, `multiplier_at_cap`, `max_jump_height` (1 m,
faixa segura 0,8–1,5), `step_height` (0,4 m, faixa segura 0,25–0,5), valores humanos
(carga, velocidades, pulo, recurso, empurrão de referência) e todos os expoentes.

## Acceptance Criteria (Critérios de aceite)

- [x] mult = 1,0 para a referência humana em todos os atributos (teste de fumaça).
- [x] mult = `multiplier_at_cap` no teto, inclusive Destreza (teste de fumaça).
- [x] Agilidade no teto não muda a velocidade de corrida (teste de fumaça).
- [x] Nível 99 paga exatamente 99/99/50/15, um ponto a mais não cabe e nada passa de 99 com pontos (teste de fumaça).
- [x] Nível 1 com tudo em 1 não tem pontos livres; subir de nível dá pontos e gastar sobe o atributo (teste de fumaça).
- [x] Dash: Ctrl gasta Vigor, vai para a frente parado e para o lado com direção, não atravessa parede (teste de fumaça).
- [x] Pulo duplo: um por salto, gasta Vigor, recarrega ao tocar o chão (teste de fumaça).
- [ ] Playtest: diferença de carga entre cavaleiro e mago é perceptível sem ler números.

## Decisões do Liam (1º playtest)

- Pulo base de **0,85 m** (3º playtest; antes 0,6 m); a altura extra vem do pulo duplo, que gasta Vigor.
- (2º playtest) Pulo no máximo **1 m**, mesmo com Agilidade 150; com pulo duplo, no máximo
  **2 m**. Tempo no ar alto tirava o realismo e a graça do Flutuar do Psiônico.
- (4º pedido) Subida de escada contínua: o corpo sobe antes de encostar no degrau, sem perder
  velocidade (um degrau a cada 4 ou 5 quadros na escada de 0,2 m, antes 4 a 13), e a câmera acompanha
  com mola (`step_camera_time` 0,06 s, faixa 0,03–0,12; `step_camera_max_speed` 4 m/s, faixa 2–8).
- (2º playtest) Degraus de até **0,4 m** sobem só andando (escadas, meio-fio). O corpo do
  personagem virou um cilindro para apoiar bem na beirada do degrau.
- Velocidade de movimento é fixa para todos. Montarias e efeitos ficam para depois.
- Vigor sem barra (efeito sutil nas bordas da tela). Vigor e Mana para todas as classes.

## Perguntas respondidas (2º playtest)

1. 8x no teto vale para todos os atributos: **sim**.
2. Agilidade: **só velocidade de ataque**, por enquanto. Investida e pulo duplo do cavaleiro
   passaram a escalar com Força (valores-base reduzidos para manter a sensação).
3. Sorte: **nada**, por enquanto.

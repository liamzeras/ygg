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
custa 25 de Vigor. Cavaleiro: impulso só das pernas, escala com Agilidade (+1,4 m).
Mago: Pulo Arcano, escala com Inteligência (+2,6 m) e empurra o que está aos pés.

### Referência humana

| Atributo | Sigla | Humano | Afeta hoje |
|---|---|---|---|
| Força | FOR | 20 | carga nas mãos, velocidade de arremesso, empurrão ao andar, Golpe de Escudo |
| Agilidade | AGI | 12 | altura do pulo, pulo duplo do cavaleiro, Investida (**não** muda a velocidade de andar/correr) |
| Vitalidade | VIT | 15 | Vigor (tamanho e regeneração), Postura de Muralha |
| Destreza | DES | 7 | firmeza ao segurar objetos |
| Inteligência | INT | 11 | Mana (tamanho e regeneração), magias, pulo duplo do mago |
| Sorte | SOR | 5 | ainda sem efeito |

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

**Valores derivados** (humano → personagem):

| Valor | Humano | Fórmula | Cavaleiro | Mago |
|---|---|---|---|---|
| Carga nas mãos | 35 kg | 35 x mult(FOR) | 57 kg | 28 kg |
| Arremesso | 9 m/s | 9 x mult(FOR)^0,5 | 11,5 m/s | 8,0 m/s |
| Andar / correr | 4,5 / 7 m/s | fixo para todos (só montarias e efeitos mudam, a definir) | 4,5 / 7 | 4,5 / 7 |
| Altura do pulo | 0,6 m | 0,6 x mult(AGI) | 0,68 m | 0,72 m |
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

`attribute_rules.tres`: referência humana, `cap`, `multiplier_at_cap`, valores humanos
(carga, velocidades, pulo, recurso, empurrão de referência) e todos os expoentes.

## Acceptance Criteria (Critérios de aceite)

- [x] mult = 1,0 para a referência humana em todos os atributos (teste de fumaça).
- [x] mult = `multiplier_at_cap` no teto, inclusive Destreza (teste de fumaça).
- [x] Agilidade no teto não muda a velocidade de corrida (teste de fumaça).
- [x] Pulo duplo: um por salto, gasta Vigor, recarrega ao tocar o chão (teste de fumaça).
- [ ] Playtest: diferença de carga entre cavaleiro e mago é perceptível sem ler números.

## Decisões do Liam (1º playtest)

- Pulo base continua realista (0,6 m); a altura extra vem do pulo duplo, que gasta Vigor.
- Velocidade de movimento é fixa para todos. Montarias e efeitos ficam para depois.
- Vigor sem barra (efeito sutil nas bordas da tela). Vigor e Mana para todas as classes.

## Perguntas em aberto para o Liam

1. 8x no teto está bom para todos os atributos, ou algum precisa de teto próprio?
2. A Agilidade deve continuar afetando o pulo e a Investida?
3. O que a Sorte deve afetar? Sugestão: variação em resultados físicos (chance de um
   arremesso acertar "em cheio", de o fogo se espalhar).

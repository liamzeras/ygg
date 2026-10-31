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

### Referência humana

| Atributo | Sigla | Humano | Afeta hoje |
|---|---|---|---|
| Força | FOR | 20 | carga nas mãos, velocidade de arremesso, empurrão ao andar, Golpe de Escudo |
| Agilidade | AGI | 12 | velocidade de andar/correr, altura do pulo, Investida |
| Vitalidade | VIT | 15 | Vigor (tamanho e regeneração), Postura de Muralha |
| Destreza | DES | 7 | firmeza ao segurar objetos |
| Inteligência | INT | 11 | Mana, todas as magias do Mago |
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
| Corrida | 7 m/s | 7 x mult(AGI)^0,5 | 7,5 m/s | 7,7 m/s |
| Altura do pulo | 0,6 m | 0,6 x mult(AGI) | 0,68 m | 0,72 m |
| Recurso | 100 | 100 x mult(atributo do recurso)^0,5 | 128 Vigor | 149 Mana |

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
- [ ] Playtest: diferença de carga entre cavaleiro e mago é perceptível sem ler números.

## Perguntas em aberto para o Liam

1. 8x no teto está bom, ou cada atributo deve ter o próprio teto (ex.: Agilidade 4x,
   porque 8x de velocidade parece absurdo)?
2. O pulo humano de 0,6 m é realista, mas pode deixar a movimentação "pesada". Aceitamos
   isso (pilar crível) ou damos uma margem de "jogo" (~0,9 m)?
3. O que a Sorte deve afetar? Sugestão: variação em resultados físicos (chance de um
   arremesso acertar "em cheio", de o fogo se espalhar).

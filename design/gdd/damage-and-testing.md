# Dano físico, boneco de testes e editor de testes

> Status: rascunho v0.1 · aprovado pelo Liam (dano derivado de física) · 2026-10-31
> Código: `src/gameplay/combat/damage_rules.gd`, `src/gameplay/world/training_dummy.gd`, `src/ui/debug_editor.gd`
> Dados: `assets/data/damage_rules.tres`

## Overview (Visão geral)

Dano não é um número inventado por habilidade: ele **sai da física**. O que machuca é o
impulso recebido (massa x velocidade, em N·s) e o calor. Assim, tudo o que empurra ou
esquenta (um golpe, uma caixa arremessada, uma explosão, uma caixa pegando fogo ao lado)
causa dano coerente, sem tabela especial.

## Player Fantasy (Fantasia do jogador)

"Bati com força, machucou muito. Joguei uma caixa pesada rápido, machucou. Encostei
algo pegando fogo, queimou." O jogador entende o dano olhando a cena, sem decorar números.

## Detailed Rules (Regras)

1. **Impacto**: toda fonte de empurrão chama `register_hit(fonte, impulso)` no alvo.
   Fontes atuais: Golpe de Escudo, Investida, explosões (barril, Bola de Fogo, Pulo Arcano)
   e objetos que batem a mais de 2 m/s.
2. **Calor**: toda fonte de calor chama `add_heat(quantidade)`: Bola de Fogo, explosões,
   braseiro e **objetos em chamas por perto** (grupo `heat_receivers`).
3. **Combo**: dano em sequência soma no mesmo combo. Após **5 s sem dano** o boneco zera.
4. **Boneco de testes** mostra: último golpe (fonte, dano, impulso, comparação com o
   empurrão humano), dano total do combo, nº de golpes, duração, **DPS**, maior golpe,
   dano de fogo e a contagem regressiva para zerar.

## Formulas (Fórmulas)

```
dano_impacto = max(impulso - limiar, 0) x dano_por_impulso     (limiar 10 N·s, 0,1 por N·s)
dano_fogo    = calor x dano_por_calor                           (0,1 por unidade de calor)
DPS          = dano_do_combo / max(duração_do_combo, 1 s)
```

Valores medidos no teste de fumaça (classe no nível inicial):

| Fonte | Impulso / calor | Dano |
|---|---|---|
| Golpe de Escudo (1,8 m do boneco) | ~100 N·s | ~9 |
| Bola de Fogo (acerto direto) | calor 133 + explosão | ~16 |
| Caixa em chamas encostada | ~20 calor/s | ~2 por segundo |

## Edge Cases (Casos-limite)

- Esbarrar ou empurrar andando fica abaixo do limiar e não causa dano.
- Dano de fogo chega um pouco a cada frame: entra no combo, mas não conta como "golpe".
- O DPS usa no mínimo 1 s de janela, senão o primeiro golpe daria DPS infinito.

## Dependencies (Dependências)

Explosion, PhysicsProp (impactos e fogo), habilidades, HeatZone → TrainingDummy.
Futuro: personagens e inimigos com vida usam as mesmas `DamageRules`.

## Tuning Knobs (Ajustes)

`damage_rules.tres`: `impulse_threshold`, `damage_per_impulse`, `damage_per_heat`, `combo_reset_time`.

## Acceptance Criteria (Critérios de aceite)

- [x] Caixa em chamas ao lado do boneco causa dano de fogo (teste de fumaça; bug reportado no 1º playtest).
- [x] Boneco zera após 5 s sem dano (teste de fumaça).
- [x] Esbarrão abaixo do limiar não causa dano (teste de fumaça).
- [ ] Playtest: o DPS mostrado bate com a sensação de "isso bateu forte".

---

## Editor de testes (F2)

Painel in-game para testar o que o personagem ainda não alcança. **Nada é salvo**: F5
(recarregar a arena) volta tudo ao normal, e os arquivos `.tres` das classes não mudam.

- **Atributos**: 6 sliders de 1 a 150, com o multiplicador em relação ao humano ao lado.
  Atalhos: Humano (referência), Classe (valores iniciais), Teto (tudo em 150).
- **Valores calculados**: carga, arremesso, andar/correr, pulo, Vigor e Mana (com regeneração).
- **Trapaças**: Vigor e Mana infinitos, sem recarga, velocidade do tempo (10% a 100%).
- **Arena**: zerar boneco, recarregar.

Com o editor aberto o mouse fica livre e o personagem para de responder ao teclado.

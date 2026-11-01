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
impulso_materializado = massa x velocidade_relativa x 200 x mult(atributo)
velocidade_do_tiro    = velocidade_da_magia + velocidade_de_quem_lança
```

Valores medidos no teste de fumaça (classe no nível inicial):

| Fonte | Impulso / calor | Dano |
|---|---|---|
| Golpe de Escudo (qualquer ponto do alcance) | ~195 N·s | ~18,5 |
| Bola de Fogo, carga cheia (10 g a 30 m/s) | 133 N·s + calor 178 | ~30 |
| Dardo Cinético, carga cheia (7 g a 60 m/s) | 187 N·s | ~18 |
| Degrau mais alto da escada subindo | 325 N·s | ~31,5 |
| Caixa em chamas encostada | ~32 calor/s | ~3 por segundo |

### Objetos materializados e movimento

O que a magia cria tem massa de verdade: uma Bola de Fogo cheia pesa 10 g e um Dardo cheio, 7 g.
Fisicamente, 10 g a 30 m/s são só 0,3 N·s, abaixo do limiar de dano. A escala `materialized_scale`
(200, faixa segura 100–400) representa a energia mágica concentrada, e o restante é física:
mais velocidade = mais impacto.

Onde o movimento conta:

- **Projéteis mágicos**: herdam toda a velocidade de quem lança; o impacto usa a velocidade
  relativa ao alvo. Correr para o alvo soma, recuar subtrai, alvo vindo de frente soma.
- **Campo Lento**: um projétil freado bate fraco.
- **Objetos arremessados** (mãos e telecinese): herdam todo o movimento de quem arremessa
  (antes era metade). O impacto em alvos usa a velocidade relativa.
- **Golpe de Escudo**: soma massa x velocidade para a frente x 0,15. Recuar não subtrai.
- **Investida e Dash**: já vêm da massa e da velocidade.
- **Pilares**: massa x velocidade de subida x 0,05.
- **Calor não muda com a velocidade.**

**Correção do 3º playtest:** o dano mudava com o ponto do corpo atingido (Bola de Fogo cheia: 36 nas
pernas, 18 na cabeça), porque a explosão media a distância até a origem do boneco, que fica nos pés.
Isso parecia efeito de distância e de pulo contra queda. Agora o acerto direto recebe tudo, o respingo
mede até a superfície do corpo, projéteis não têm resistência do ar e o Golpe de Escudo é igual em todo
o alcance. Um pulo (4 m/s) ou uma queda de 4 m (8,9 m/s) são quase perpendiculares a um tiro na
horizontal e mudam pouco; só o movimento na direção do tiro pesa muito.

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
- [x] Distância (3, 8, 20 m) e ponto do corpo (0,5; 1,2; 1,9 m) mudam o dano em menos de 5% (teste de fumaça).
- [x] Cair de 4 m pesa mais que um pulo baixo (teste de fumaça).
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

## Alvos voadores (F7)

Cada pressão de F7 cria 3 alvos em volta do boneco, em órbitas diferentes (`TARGET_ORBITS` em
`test_arena.gd`): raio 4 m a 3 m/s, 6 m a 5 m/s no sentido contrário e 8 m a 7 m/s, entre 2,6 e 5 m
de altura. No máximo 9: acima disso, somem os mais antigos. F5 limpa todos.

Os alvos não têm vida. O dano aparece em cima do alvo e entra no combo e no DPS do boneco (com o
nome "Alvo: ..."). Golpes os empurram para fora da órbita (massa 5 kg) e eles voltam sozinhos.

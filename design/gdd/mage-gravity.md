# Mago da Gravidade

Pedido do Liam em 2026-11-16. Parte da fatia vertical Fogo, Terra e Gravidade
(`design/sabio/inspiracao/magos-elementais.md`). Substitui o Psiônico (`mage-psionic.md`) no menu: o
Psiônico continua existindo só como a ficha do bot do F6.

## 1. Overview

O Mago da Gravidade mexe em tudo que tem massa: empurra e puxa, cria um mini buraco negro, muda o peso de
quem está por perto e, com o F, abre uma zona onde nenhuma magia funciona e a luta vira corpo a corpo.

| Tecla | Fora da Zona Nula | Dentro da Zona Nula |
|---|---|---|
| Botão esq. | Push-Pull | Soco esquerdo |
| Botão dir. | Mibune | Soco direito |
| Q | Gravidade dos Sonhos | Chute direito |
| Ctrl | Gravidash | Chute esquerdo |
| E | Pegar e arremessar | Agarrar por 0,3 s |
| F | Zona Nula | — |

## 2. Player Fantasy

Ser quem decide para onde as coisas caem. Fora da zona, o mago controla o espaço de longe. Com o F, ele
troca tudo isso por uma luta "na mão", onde as magias de todo mundo deixam de existir.

## 3. Detailed Rules

### Push-Pull (botão esq.)

- Age no objeto ou personagem na mira, até `reach` m.
- **Perto** (até `push_distance` m): empurra para longe, na direção da mira. **Longe:** puxa na sua direção.
- Empurrar um personagem ou boneco causa dano pelo impulso; puxar só move.
- **Desviar projéteis:** projéteis mágicos à sua frente que vêm na sua direção são rebatidos para onde você
  mira, se o impulso do Push-Pull for maior ou igual ao impulso que o projétil causaria. Se for menor, passam.

### Mibune (botão dir.)

- Primeira conjuração: o mini buraco negro **se forma `spawn_offset` m (0,3 m) à frente do corpo do mago**, na
  altura do peito, e não no ponto mirado (Liam, 2026-11-17). Ali ele puxa objetos soltos e monstros próximos.
  Como se forma colado no mago, o que ele puxa se junta logo à frente dele e pode encostar nele.
- Segunda conjuração, com o Mibune ativo (playtest de 2026-11-17): o Mibune sai da frente do mago
  (`spawn_offset` m à frente da mira) e dispara rápido na direção da mira, como um projétil. Ele continua
  puxando o que encontra pelo caminho. Ao bater em parede, chão, pilar ou personagem (Liam, 2026-11-17), para,
  fere quem está a até `impact_radius` m (2 m; impulso `impact_impulse` = 200 x mult(Inteligência), caindo com
  a distância até 20%), racha construções da Terra e some depois de `impact_linger` s (0,4 s). Objetos soltos
  não o param: são puxados.
- Lei da Gravidade: o Mibune é uma área de gravidade do mundo (gravidade para o centro, somada à do lugar).
  Objetos soltos caem para ele e mudam de peso. Monstros recebem o mesmo puxão direto do Mibune. **Magos não**
  (nem quem lançou, nem outros magos): o corpo de um mago só muda pelas próprias habilidades (Liam, 2026-11-17).
- Some depois de `lifetime` s. Não causa dano direto: o dano vem das colisões do que ele arrasta.

### Gravidade dos Sonhos (Q)

- Zona quadrada em volta do mago, fixa no chão, com área em partes iguais por nível até 9 x 9 m.
- Adversários dentro ficam mais lentos e mais pesados; o mago, dentro, pula mais alto e tem recargas mais
  curtas. A proporção é a mesma nos quatro efeitos (`strength`).
- Lei da Gravidade: a zona também é área de gravidade do mundo (gravidade x (1 + `strength`)). Objetos soltos
  dentro pesam mais e caem mais rápido, para todos, inclusive os do mago.
- Outros magos dentro da zona ficam mais lentos, mas **não mais pesados**; o peso extra vale só para monstros
  (Liam, 2026-11-17: o mago só muda de peso pelas próprias habilidades). Ficar mais lento continua valendo
  (pergunta aberta ao Liam).
- Dura `duration` s. Uma por vez.

### Gravidash (Ctrl)

- Arrancada curta na direção escolhida: a direção do movimento em relação à câmera (olhar para cima ou para
  baixo inclina a arrancada), para cima se Espaço estiver pressionado, ou para a frente da câmera se parado.
- Carrega junto os objetos soltos e empurra os personagens que estiverem perto na hora da arrancada.
- Dá para usar **duas vezes** antes da recarga: a recarga começa na primeira, e a segunda precisa sair antes
  de ela acabar.
- Para baixo, por enquanto, só se move. O dano ao chão espera o sistema de chão destrutível (decisão do Liam).

### Zona Nula (F)

- Gasta **toda a Mana** (precisa de um mínimo, o custo da habilidade) e cria uma zona quadrada em volta do
  mago, fixa no chão, com área em partes iguais por nível até 9 x 9 m, por `duration` s (fixa).
- Dentro da zona: ninguém usa habilidades, e projéteis mágicos que entram somem sem efeito.
- O mago que lançou troca o kit por golpes sem magia enquanto estiver dentro: soco esquerdo e direito (da
  cintura para cima), chute esquerdo e direito (da cintura para baixo).
- **Agarrar (E):** segura por `hold_time` s (0,3) o personagem à frente, que fica parado. Nesse tempo, o
  próximo golpe do mago sai de graça (sem custo de Vigor).
- Saindo da zona, cada um recupera o próprio kit. A zona não desfaz o que já existe (relevo, lama, lava).

## 4. Formulas

`parte(nível) = nível / nível máximo (99)`.

| Grandeza | Fórmula |
|---|---|
| Impulso do Push-Pull (N·s) | `base_impulse x mult(Inteligência)` |
| Rebate projétil se | `impulso do Push-Pull >= impulso do projétil` (massa x velocidade x escala mágica x poder) |
| Puxão do Mibune (m/s²) | `pull_acceleration x mult(Inteligência)`, igual em todo o raio (área de gravidade) |
| Área das zonas (m²) | `max_side² x parte(nível)`; lado = raiz(área) |
| Gravidade dos Sonhos | adversário: velocidade x (1 − strength), gravidade x (1 + strength); mago: altura do pulo x (1 + strength), recarga / (1 + strength) |
| Gravidash | `distance / duration` m/s por `duration` s |

Valores iniciais (a ajustar no playtest): Push-Pull com `base_impulse` 120, alcance 15 m, empurra até 4 m,
12 de Mana, recarga 0,5 s. Mibune com raio 5 m, puxão 15 m/s², formação e disparo a 0,3 m à frente, disparo a 35 m/s, 5 s de vida, 30 de Mana,
recarga 6 s. Gravidade dos Sonhos com `strength` 0,4 por 6 s, 30 de Mana, recarga 12 s. Gravidash de 4 m em
0,2 s, 15 de Vigor, recarga 4 s. Zona Nula por 8 s, mínimo de 20 de Mana, recarga 20 s. Socos 140 e chutes
170 de impulso, como os da Terra sem pedra.

## 5. Edge Cases

- Push-Pull sem nada na mira: só tenta rebater projéteis; gasta a Mana do mesmo jeito.
- Push-Pull num objeto preso ou no chão: nada acontece.
- Mibune arremessado para o céu: some no fim do tempo de vida.
- Mibune disparado contra quem lançou: impossível, ele sai da frente da mira e ignora o próprio mago.
- Outros magos: são feridos pelo impacto, mas não puxados.
- Gravidade dos Sonhos e Lamaçal juntos: vale a lentidão mais forte, não somam.
- Segundo Gravidash sem Vigor: não sai, e a recarga da primeira continua.
- Zona Nula com menos Mana que o mínimo: bloqueada ("Mana insuficiente").
- Pulo duplo dentro da Zona Nula: bloqueado para todos (é uma habilidade).
- O bot dentro da Zona Nula ainda tenta atirar, mas os dardos somem ao nascer.
- Dois magos da Gravidade com Zona Nula sobreposta: cada um luta "na mão" enquanto estiver na própria zona.

## 6. Dependencies

- `damage_rules.tres`, objetos físicos e projéteis materializados (`materialized_projectile.gd`).
- Jogador (`player.gd`): arrancada com componente vertical, efeitos de pulo, recarga e peso, troca de kit.
- Golpes corpo a corpo (`stone_strike_ability.gd`): os socos e chutes da zona são o mesmo golpe, sem pedra.
- HUD: mostra o kit trocado dentro da zona.
- Bot do F6 (`combat-bot.md`): usa a ficha do Psiônico, que sai do menu.

## 7. Tuning Knobs

Todos em `assets/data/classes/gravity.tres`: impulsos, alcances, distância de empurrar, raio e puxão do
Mibune, força e duração das zonas, distância do Gravidash, custos e recargas.

## 8. Acceptance Criteria

1. Push-Pull empurra uma caixa a 2 m e puxa uma caixa a 8 m.
2. Push-Pull rebate um Dardo Cinético fraco que vem na direção do mago e não rebate um forte demais.
3. Mibune puxa uma caixa próxima; a segunda conjuração o arremessa a mais de 15 m/s; some no tempo de vida.
   O Mibune se forma 0,3 m à frente do corpo do mago, na altura do peito (não na mira). A segunda conjuração o
   faz sair a menos de 1,3 m da mira do mago, na direção da mira atual.
   Disparado contra uma parede, para nela, fere o boneco ao lado e some em até 0,4 s.
4. Na Gravidade dos Sonhos, o mago pula mais alto que fora dela, e a zona no nível 99 mede 9 x 9 m.
5. Gravidash sai duas vezes seguidas e a terceira é bloqueada pela recarga; com Espaço, sobe.
6. Zona Nula zera a Mana, troca o kit por socos e chutes, e um projétil que entra some.
7. Agarrar deixa o próximo golpe sem custo de Vigor.
8. O menu mostra Fogo, Terra e Gravidade; o bot do F6 continua atirando dardos.

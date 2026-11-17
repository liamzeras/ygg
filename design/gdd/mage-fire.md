# Mago do Fogo

Pedido do Liam em 2026-11-16. Parte da fatia vertical Fogo, Terra e Gravidade
(`design/sabio/inspiracao/magos-elementais.md`). Substitui a parte de Fogo de `mage-elementalist.md`.

## 1. Overview

O Mago do Fogo luta à distância e pelo ar: voa com jatos nos pés, lança a Bola de Fogo e o Fogo-Fátuo, cobre
o chão de lava e se protege com a Almôndega de Fogo, que consome projéteis.

| Tecla | Habilidade | Recurso |
|---|---|---|
| Botão esq. | Bola de Fogo (já existia) | Mana |
| Botão dir. | Fogo-Fátuo | Mana |
| Q | Chão de Lava | Mana |
| F | Almôndega de Fogo | Mana |
| Ctrl | Jatos de Fogo (voo e impulso) | Mana |

## 2. Player Fantasy

Dominar o espaço. De cima, o mago escolhe onde o fogo cai; o Fogo-Fátuo é uma ameaça lenta que não some
sozinha; a lava fecha um pedaço da arena; e a Almôndega transforma o tiro do inimigo em nada.

## 3. Detailed Rules

### Jatos de Fogo (Ctrl)

- A primeira ativação liga o voo: sem gravidade, o mago anda para onde a câmera aponta (olhar para cima sobe,
  para baixo desce) e segurar Espaço sobe. Parado, ele paira.
- Com o voo ligado, apertar Ctrl de novo dá um **impulso** na direção da mira, pagando Mana a cada vez.
- O voo dura um tempo que cresce em partes iguais por nível, até 15 s no nível 99. Depois, cai normalmente.
- A recarga começa na primeira ativação.

### Fogo-Fátuo (botão dir.)

- Bola de fogo lenta, em linha reta, sem gravidade. **Não some sozinha:** só ao bater em alguma coisa (objeto,
  parede, teto, chão, personagem).
- O que ela toca queima por 10 s, seja qual for o material. Personagens e bonecos tomam dano de fogo por
  segundo. Objetos inflamáveis pegam fogo de verdade; os outros ficam em chamas só pelos 10 s.
- Acertar de novo um alvo que já queima reinicia os 10 s (não acumula).

### Chão de Lava (Q)

- Nasce no chão mirado (precisa de chão firme, como o Terremoto).
- Área e duração crescem em partes iguais por nível: até 9 x 9 m e até 10 s no nível 99.
- Tudo que estiver em cima recebe calor por segundo, **inclusive quem lançou**. Objetos inflamáveis pegam fogo.
- Uma lava por vez: lançar outra apaga a anterior.

### Almôndega de Fogo (F)

- Uma bola de fogo envolve o mago por alguns segundos.
- Projéteis mágicos (Bola de Fogo, Fogo-Fátuo, Dardo Cinético) que entram nela vindo na direção do mago são
  consumidos: somem sem explodir nem causar dano.
- Objetos soltos que chegam rápido (pedregulhos, caixas arremessadas) são parados e aquecidos.
- Os projéteis do próprio mago saem normalmente, porque se afastam dele.
- Não protege de golpes corpo a corpo, explosões já em andamento, lava ou Terremoto.

## 4. Formulas

`parte(nível) = nível / nível máximo (99)`.

| Grandeza | Fórmula |
|---|---|
| Duração do voo (s) | `max_duration x parte(nível)` = 15 x nível / 99 |
| Área da lava (m²) | `max_side² x parte(nível)` = 81 x nível / 99; lado = raiz(área) |
| Duração da lava (s) | `max_duration x parte(nível)` = 10 x nível / 99 |
| Calor da lava | `heat_per_second x mult(Inteligência)` por segundo |
| Dano de fogo | `calor x 0,1` (`damage_rules.tres`) |
| Queimadura do Fogo-Fátuo | `burn_heat_per_second x mult(Inteligência)` por `burn_duration` s |

Valores iniciais (a ajustar no playtest): voo a 9 m/s, impulso de 20 m/s por 10 de Mana, 30 de Mana e recarga de
20 s. Fogo-Fátuo a 6 m/s, 20 de Mana, recarga 2 s, 20 de calor por segundo por 10 s. Lava com 60 de calor por
segundo, 35 de Mana, recarga 10 s. Almôndega com raio de 1,8 m por 3 s, 30 de Mana, recarga 8 s.

Exemplo no nível 50: voo de 7,6 s; lava de 6,4 x 6,4 m por 5,1 s.

## 5. Edge Cases

- Nível 1: o voo dura 0,15 s e a lava 0,1 s numa área de 0,9 x 0,9 m. É o resultado da regra linear pedida;
  vale revisar um piso mínimo no playtest.
- Voo acaba no ar: o mago cai com a gravidade normal (sem dano de queda hoje).
- Impulso sem Mana: não sai e avisa "Mana insuficiente"; o voo continua.
- Fogo-Fátuo lançado para o céu aberto: segue até sair da arena e é apagado a 300 m de onde nasceu.
- Lamaçal sobre um alvo queimando pelo Fogo-Fátuo: apaga objetos inflamáveis, mas a queimadura de 10 s
  continua. Ponto em aberto para o Liam (a lama deveria apagar?).
- Almôndega ativa e Bola de Fogo do bot chegando: some sem explodir.

## 6. Dependencies

- `damage_rules.tres` (dano por calor), objetos físicos (fogo e calor em `physics_prop.gd`).
- Projéteis materializados (`materialized_projectile.gd`): é por essa base que a Almôndega reconhece projéteis.
- Jogador (`player.gd`): estado de voo.
- Nível do personagem (`attribute_rules.tres`, `max_level`).

## 7. Tuning Knobs

Todos em `assets/data/classes/fire.tres`: durações e tamanhos máximos, velocidades, calor por segundo, raio e
duração da Almôndega, custos e recargas.

## 8. Acceptance Criteria

1. Ctrl liga o voo: o mago não cai, sobe segurando Espaço, e o voo acaba no tempo da fórmula.
2. Ctrl de novo durante o voo dá impulso na direção da mira e gasta Mana.
3. Fogo-Fátuo continua existindo depois de 10 s no ar e some ao bater.
4. Fogo-Fátuo no boneco causa dano de fogo ao longo de 10 s; num bloco de pedra, deixa-o em chamas por 10 s.
5. Chão de Lava no nível 99 mede 9 x 9 m e dura 10 s; causa dano de fogo no boneco e acende caixa de madeira.
6. Almôndega consome um Dardo Cinético e uma Bola de Fogo que vêm na direção do mago, sem dano.
7. Com a Almôndega ativa, a Bola de Fogo do próprio mago sai normalmente.

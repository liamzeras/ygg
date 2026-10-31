# Mago Psiônico

> Status: v1.0 aprovado e implementado · 2026-10-31
> Código: `src/gameplay/abilities/` (kinetic_dart_*, slow_field_ability, float_ability, telekinesis_ability),
> `src/gameplay/world/slow_field.gd`, `src/gameplay/player/player.gd` (carga e flutuar). Dados: `assets/data/classes/psionic.tres`.
> Decisões tomadas: card próprio na seleção de classes, botão esquerdo carregável
> (estilo arco), Q só desacelera, flutuar = queda lenta.

## Overview (Visão geral)

O Psiônico é a especialização do Mago que abre mão dos elementos (fogo, pedra, água) e
manipula **movimento**: empurra com força pura, desacelera o que está numa área e freia a
própria queda. É o "arqueiro" do Ygg: atira de longe, controla o espaço e usa a altura a seu
favor. Ele não cria nada novo no mundo, só muda a velocidade das coisas que já existem.
Por isso combina com a física do jogo: tudo o que ele faz é força, impulso e atrito.

## Player Fantasy (Fantasia do jogador)

"Eu controlo o ritmo da luta."

- Puxar o arco mental, sentir a carga subir e soltar um dardo que joga a caixa longe.
- Jogar uma bolha lenta na frente de um barril rolando e ver ele quase parar.
- Pular do alto da torre, abrir o flutuar e descer devagar mirando lá embaixo.

O jogador deve se sentir **preciso e esperto**, não forte. O cavaleiro resolve com o
corpo; o Psiônico resolve com timing e posição.

## Detailed Rules (Regras)

### Kit

| Tecla | Habilidade | Escala com | Gasta | Resumo |
|---|---|---|---|---|
| Botão esq. | **Dardo Cinético** | Inteligência | Mana | Projétil de impulso puro (sem calor). Segurar carrega, soltar dispara. |
| Q | **Campo Lento** | Inteligência | Mana | Bolha de 3 m no ponto mirado: tudo dentro fica lento por 4 s. |
| F | **Telecinese Acelerada** | Inteligência | Mana | A Telecinese atual, com arremesso bem mais rápido. |
| Espaço 2x | **Pulo Arcano** | Inteligência | Vigor | O pulo duplo do mago (igual ao atual). |
| Segurar Espaço no ar | **Flutuar** | Inteligência | Mana | Enquanto cai, desce devagar e com controle total da direção. |

### 1. Dardo Cinético (botão esquerdo)

1. **Apertar** começa a carregar. Aparece um indicador de carga perto da mira.
2. **Soltar** dispara o dardo. A Mana é gasta só no disparo, proporcional à carga.
3. Clique rápido (carga 0%) = dardo fraco e barato. Carga cheia (~1 s) = dardo rápido,
   forte e caro.
4. Carga cheia segurada por mais de 1,5 s: a mira começa a **tremer** (cansaço mental).
   Destreza reduz o tremor.
5. O dardo voa quase reto e, ao bater, aplica **só impulso** na direção do voo. Não aquece,
   não explode e não acende nada. Quebrar a pólvora só acontece pelo impacto (≥ 9 m/s,
   regra atual dos materiais).
6. Sem Mana para o disparo mínimo, a carga não começa e aparece "Mana insuficiente".

### 2. Campo Lento (Q)

1. Cria uma bolha translúcida de 3 m de raio no ponto mirado, até 15 m de distância (se
   mirar no céu, nasce a 15 m na direção da mira).
2. Por 4 s, todo corpo físico e projétil **dentro** da bolha se move bem mais devagar,
   inclusive a queda. Ao sair da bolha, recupera a velocidade normal (não a que tinha
   antes de entrar).
3. **Não afeta o próprio Psiônico.** No futuro afetará inimigos e outros jogadores.
4. Só um campo ativo por vez. Usar de novo antes de acabar substitui o anterior.
5. Fogo e explosões continuam normais dentro do campo (ele mexe em movimento, não em
   calor), mas os destroços arremessados ficam lentos.

### 3. Telecinese Acelerada (F)

1. Igual à Telecinese atual: segura um objeto à distância, carrega menos que braços fortes
   e drena Mana enquanto segura.
2. Diferença: o arremesso (botão esquerdo com objeto seguro) sai **bem mais rápido**. Esse
   é o "acelerar" do Psiônico. Objetos pesados ganham menos velocidade que os leves.
3. Enquanto segura um objeto, o botão esquerdo arremessa em vez de carregar o dardo.

### 4. Flutuar (segurar Espaço no ar)

1. Funciona só **descendo** (velocidade vertical negativa). Não serve para subir.
2. No ar, o primeiro toque em Espaço continua sendo o pulo duplo. Segurar Espaço depois
   (ou segurar com o pulo duplo já gasto) ativa o flutuar quando começar a cair.
3. Flutuando: a queda fica limitada a uma velocidade baixa, e o controle no ar fica igual
   ao do chão. Drena Mana por segundo.
4. Soltar Espaço, tocar o chão ou zerar a Mana encerra o flutuar.
5. Efeito visual sutil: partículas leves sob os pés e um leve "zumbido" na tela.

### Seleção de classes

A tela de classes passa a ter 3 cards: **Cavaleiro**, **Mago Elementalista** e **Mago
Psiônico**. Até o kit do Elementalista ser desenhado, o card dele usa o Mago atual (Bola
de Fogo + Telecinese, Q vazio).

### Atributos iniciais

Iguais ao Mago (FOR 16, AGI 15, VIT 16, DES 12, INT 30, SOR 6) para comparar as duas
especializações em pé de igualdade. Ajustável depois do playtest.

## Formulas (Fórmulas)

Variáveis:

- `I` = mult(Inteligência). Psiônico inicial (INT 30): **I ≈ 2,22**, √I ≈ 1,49.
- `D` = mult(Destreza). Psiônico inicial (DES 12): **D ≈ 1,44**.
- `c` = carga do dardo, de 0 (clique) a 1 (segurou 1 s).
- `lerp(a, b, c)` = a + (b − a) x c.

O dano sai das `DamageRules` que já existem: `dano = max(impulso − 10, 0) x 0,1`.

### Dardo Cinético

```
impulso    = lerp(25, 80, c) x I          N·s     (faixa: 25 a 640 no teto, I = 8)
velocidade = lerp(30, 60, c)              m/s     (gravidade 5% da normal)
custo      = lerp(4, 20, c)               Mana    (pago ao soltar)
tremor     = 2° / D                       só depois de 1,5 s com carga cheia
```

| Exemplo (Psiônico inicial) | Impulso | Dano no boneco | Caixa de madeira (19 kg) sai a | Mana |
|---|---|---|---|---|
| Clique (c = 0) | 56 N·s | ~4,6 | 2,9 m/s | 4 |
| Carga cheia (c = 1) | 178 N·s | ~16,8 | 9,4 m/s | 20 |

A carga cheia fica no nível da Bola de Fogo (~16), mas sem fogo. Com 149 de Mana e
regeneração de 15/s, cabem ~7 disparos cheios seguidos. Barril de pólvora (28 kg) leva
6,4 m/s de um dardo cheio: não explode com o tiro, mas pode explodir ao bater numa parede
se for arremessado mais forte.

### Campo Lento

```
raio          = 3 m                         (fixo)
duração       = 2,5 s x √I                  Psiônico inicial ≈ 3,7 s
alcance       = 15 m
custo         = 30 Mana · recarga 8 s
dentro:  velocidade máxima = 1,5 m/s  (o excesso é retirado a cada quadro)
         gravidade x 0,1
```

Exemplos: barril rolando a 6 m/s entra e cai para 1,5 m/s. Dardo cheio (60 m/s) entra e
passa a 1,5 m/s. Caixa caindo da torre de 6 m flutua para baixo devagar enquanto estiver
dentro.

### Telecinese Acelerada

```
arremesso = 14 m/s x √I x clamp(1 − massa / (carga x 1,5), 0,3, 1)
carga     = 12 kg x I      (igual à Telecinese atual)
```

Psiônico inicial: carga 27 kg, arremesso máximo 21 m/s (a Telecinese atual dá 9 m/s).
Caixa de madeira (19 kg) sai a ~11 m/s → impacto de ~208 N·s → **~20 de dano**.
Arremessar custa 10 de Mana, além do dreno de 8/s enquanto segura.

### Flutuar

```
queda máxima = 1,5 m/s
dreno        = 15 Mana/s ÷ √I               Psiônico inicial ≈ 10/s
controle no ar = igual ao do chão
mínimo para começar = 5 de Mana
```

Descer da torre de 6 m leva ~4 s e custa ~40 de Mana. Com Mana cheia dá ~15 s no ar.

## Edge Cases (Casos-limite)

- **Carregando o dardo e aperta F (telecinese)**: a carga é cancelada sem gastar Mana.
- **Carregando e a Mana cai abaixo do custo da carga atual**: a carga para de subir no
  valor que a Mana paga. Se nem o clique (4) for pago, a carga é cancelada e aparece
  "Mana insuficiente".
- **Abrir pausa ou editor F2 carregando**: a carga é cancelada sem gastar Mana.
- **Segurando objeto na telecinese**: o botão esquerdo arremessa, nunca carrega dardo.
- **Dardo acerta o boneco**: conta como golpe no combo com o nome "Dardo Cinético".
- **Dardo acerta um objeto dentro do Campo Lento**: o impulso é aplicado normalmente, mas o
  objeto não passa de 1,5 m/s enquanto estiver na bolha. Quando o campo acaba, ele segue
  na velocidade que tinha (lenta). O campo é um **freio**, não guarda energia.
- **Campo nasce colado no jogador**: o jogador não é afetado, mas objetos que ele estiver
  segurando com a telecinese são.
- **Dardo freado pelo campo**: o impulso do dardo cai junto com a velocidade (impulso x
  velocidade atual / velocidade de disparo). Um dardo que saiu da bolha a 1,5 m/s quase não empurra.
- **Projéteis dentro do campo**: continuam contando o tempo de vida. Se ele acabar lá
  dentro, o projétil some.
- **Fogo e explosão dentro do campo**: calor normal. Os destroços arremessados respeitam o
  limite de 1,5 m/s enquanto estiverem dentro.
- **Novo campo com um ativo**: o antigo some na hora e o novo nasce.
- **Flutuar subindo** (logo depois do pulo duplo): não faz nada até começar a cair. Segurar
  Espaço o tempo todo funciona: o flutuar liga sozinho no topo do salto.
- **Flutuar e a Mana acaba**: o flutuar desliga e o personagem cai normalmente, com o aviso
  "Mana esgotada".
- **Flutuar e tocar o chão**: o flutuar desliga. Não há dano de queda no jogo ainda.
- **Cavaleiro ou Elementalista segurando Espaço no ar**: nada acontece (flutuar é só do
  Psiônico).

## Dependencies (Dependências)

| Sistema | Como o Psiônico depende dele |
|---|---|
| `Ability` / `PlayerClassData` | As 4 habilidades novas são `Ability`; o card novo é um `.tres` de classe. |
| `Player` | Precisa de "segurar e soltar" para o dardo e de um estado de flutuar no ar. |
| `PhysicsProp` (grupo `physics_props`) | O Campo Lento limita a velocidade dos props dentro dele. |
| Projéteis (`FireballProjectile` e o novo dardo) | Também são freados pelo Campo Lento. |
| `DamageRules` e `TrainingDummy` | O dardo usa `register_hit`, então o dano sai da fórmula de impulso. |
| `AttributeRules` | `I` e `D` vêm de `mult()`. |
| HUD | Indicador de carga na mira, recarga do campo, estado do flutuar. |
| Seleção de classes / `GameState.CLASSES` | Ganha o 3º card. |

Dependências inversas a registrar: `physics-magic-system.md` (o Campo Lento mexe em
props e projéteis) e `attributes.md` (Destreza agora afeta o tremor do dardo).

## Tuning Knobs (Ajustes)

Tudo no `.tres` do Psiônico (`assets/data/classes/psionic.tres`).

| Ajuste | Valor | Faixa segura | O que muda no jogo |
|---|---|---|---|
| Dardo: impulso mín./máx. | 25 / 80 | 15–40 / 50–120 | Força e dano. Acima de 120, o dardo arremessa barris o bastante para explodir. |
| Dardo: velocidade mín./máx. | 30 / 60 m/s | 20–40 / 40–80 | Facilidade de mirar de longe. |
| Dardo: custo mín./máx. | 4 / 20 | 2–8 / 12–30 | Quantos tiros cheios cabem na Mana. |
| Dardo: tempo de carga | 1,0 s | 0,6–1,5 | Ritmo do "arco". |
| Dardo: tremor e início dele | 2° após 1,5 s | 0,5–4° / 1–3 s | Punição por segurar demais. |
| Campo: raio | 3 m | 2–5 | Tamanho da área controlada. |
| Campo: duração base | 2,5 s | 1,5–4 | Tempo de controle. |
| Campo: velocidade máxima dentro | 1,5 m/s | 0,5–3 | Quanto o campo "congela". Abaixo de 0,5 parece parado no tempo (surreal demais). |
| Campo: custo / recarga | 30 / 8 s | 20–50 / 5–15 | Frequência de uso. |
| Telecinese: arremesso base | 14 m/s | 9–20 | Força do "acelerar". |
| Telecinese: custo do arremesso | 10 | 0–20 | Freio para não spammar. |
| Flutuar: queda máxima | 1,5 m/s | 0,8–3 | Quanto tempo se fica no ar. |
| Flutuar: dreno base | 15/s | 8–25 | Duração máxima do flutuar. |

## Acceptance Criteria (Critérios de aceite)

Automáticos (teste de fumaça):

- [x] Clique rápido gasta 4 de Mana e causa entre 3 e 6 de dano no boneco.
- [x] Carga cheia gasta 20 de Mana e causa entre 14 e 20 de dano no boneco.
- [x] O dardo não aquece nada: uma caixa de madeira atingida 5 vezes não pega fogo.
- [x] Com o Campo Lento ativo, uma caixa dentro dele nunca passa de 1,5 m/s.
- [x] O Campo Lento não muda a velocidade do jogador.
- [x] O campo some depois da duração calculada (± 0,1 s).
- [x] O arremesso da Telecinese Acelerada sai mais rápido que o da Telecinese do Elementalista.
- [x] Flutuando, a velocidade de queda nunca passa de 1,5 m/s, e a Mana diminui.
- [x] Sem Mana, o flutuar desliga e a queda volta ao normal.
- [x] Cavaleiro segurando Espaço no ar cai normalmente.

Playtest (Liam):

- [ ] Dá para perceber a carga do dardo sem ler números (indicador + som/efeito).
- [ ] Parar um barril rolando com o campo antes dele bater no braseiro é possível e divertido.
- [ ] Pular da torre de 6 m e acertar o boneco flutuando é viável.
- [ ] Psiônico e Elementalista resolvem a mesma situação de formas diferentes.

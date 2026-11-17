# Sistema de física, materiais e magia

> Status: v0.3 (2026-11-17) · leis de Fogo, Terra, Gravidade e Quebrável no mundo · implementado em `src/gameplay/world/`
> Fontes: `game-concept.md` (visão dos magos de um elemento), `mage-fire.md`, `mage-earth.md`, `mage-gravity.md`,
> e o material do Sábio `design/sabio/inspiracao/magos-elementais.md` e `tabela-elementos-materiais.md`.

## Overview (Visão geral)

Todo objeto interativo é um `PhysicsProp` feito de um `PropMaterial`. A massa vem do volume x densidade. Cada
elemento tem uma **lei**: uma regra física sempre ligada que **mora no mundo, não no mago**. Por isso magos,
monstros, objetos e o braseiro obedecem às mesmas regras, e o que um mago deixa para trás (calor, lama, peso)
vira gancho para o outro. Este documento define as leis da fatia vertical (Fogo, Terra e Gravidade), como elas
conversam entre si e com os materiais, e as regras de calor e explosão que já existiam.

## Player Fantasy (Fantasia do jogador)

"Se parece que deveria funcionar, funciona, e funciona sempre igual." Jogar uma caixa no barril de pólvora faz
explodir. A pedra que levou fogo fica em brasa e acende a caixa encostada nela, seja de quem for. A lama apaga o
braseiro. Um barril que cai de pouca altura não explode, mas o mesmo barril onde tudo pesa três vezes mais
explode ao bater no chão. O jogador aprende a lei uma vez e usa contra monstros e jogadores.

## Detailed Rules (Regras)

### Materiais atuais

| Material | Densidade de jogo | Exemplo | Fogo | Calor guardado | Terra |
|---|---|---|---|---|---|
| Madeira | 90 kg/m³ | caixa 0,6 m = 19 kg | queima 10 s, espalha num raio de 1,4 m | não (perde 15/s) | não trabalha · força 1x |
| Metal | 600 kg/m³ | caixa 0,5 m = 75 kg | não queima | até 300, perde 25/s | não trabalha · força 1x |
| Pedra | 350 kg/m³ | bloco 0,6 m = 76 kg; 1,2 m = 605 kg | não queima | até 400, perde 3/s | trabalha · força 2x |
| Pólvora | 110 kg/m³ | barril = 28 kg | pavio 1,5 s; detona com impacto ≥ 9 m/s | não | não trabalha · força 1x |
| Concreto | 320 kg/m³ | chão e paredes sem material declarado | não queima | até 350, perde 4/s | trabalha · força 1,5x |
| Solo | 160 kg/m³ | terra de verdade (a fase declara) | não queima | não | trabalha · força 1x |

A densidade "de jogo" é mais baixa que a real (madeira real ~600) para que caixas comuns sejam carregáveis.
Consistência entre materiais importa mais que o valor absoluto. `conductive` (metal) segue reservado para a
Eletricidade.

### Regra de ouro das interações

Toda interação tem **dois lados**: ela ajuda quem a provoca e pode ser usada contra ele, por aliados, inimigos e
monstros. Nenhuma lei sabe quem é o dono do calor, da lama ou do peso. A tabela de interações abaixo traz, em cada
linha, o lado que ajuda e o lado que pune.

### Lei do Fogo: o calor acumula, espalha e consome combustível; precisa de ar

1. `add_heat(q)` soma calor. Inflamável com calor ≥ `ignition_heat` → pega fogo.
2. Fora do fogo, o calor cai `heat_decay` por segundo (um toque rápido de fogo não basta).
3. **Combustível:** cada material inflamável tem `burn_time` segundos de combustível. Queimando, gasta
   combustível na proporção do ar. Apagar e reacender **continua do que sobrou**; não há combustível novo.
4. **O fogo consome o objeto:** a massa cai de 100% até `burnt_mass_fraction` (40%) conforme o combustível
   acaba. Uma caixa meio queimada voa mais longe com o mesmo empurrão. Sem combustível, vira cinzas e some.
5. **Ar:** cada ponto do mundo tem ar entre 0 e 1 (normal = 1). Zonas sem ar (`HeatZone` com `air_factor` 0;
   lama e, no futuro, água) **apagam** o que queima dentro, **impedem o calor de entrar** e impedem de acender.
   Uma fonte de calor (braseiro) tocada por uma zona sem ar também para de aquecer enquanto estiver tocada.
   No mesmo tick, vale o menor ar: **sem ar sempre vence o fogo**, não importa a ordem.
6. Pólvora em chamas: após `fuse_time` (com variação de até `fuse_jitter`, 10%, para mais ou para menos), explode.
   Apagar para o pavio. **No máximo `max_explosions_per_frame` (1) explosão por quadro;** as outras esperam o
   quadro seguinte (alguns ms). Barris acesos juntos explodem em sequência, não todos no mesmo quadro.
7. **Pedra e metal guardam calor:** não queimam, mas acumulam calor até `max_heat` e perdem devagar
   (`heat_decay`). Acima de `radiate_threshold`, aquecem os vizinhos no raio `radiate_radius` e **perdem o calor
   que entregam** (o calor não se multiplica entre duas pedras). A cor vai para o vermelho conforme o calor.

### Lei da Terra: massa e permanência; só trabalha o solo, o concreto e a pedra que existem ali

1. O mundo responde **qual material está sob um ponto** (`PropMaterial.ground_under`): o material do objeto,
   ou **concreto** para chão e paredes estáticos sem material declarado, ou **nada** (ar, vazio).
2. Só materiais com `earth_workable` servem de base para a Terra (erguer pilar, abrir lama, revestir o golpe).
   Hoje: solo, concreto e pedra. Em cima de madeira, metal ou no ar, a Terra não tem com o que trabalhar.
3. A força da Terra sobre um material é multiplicada por `earth_force_factor`: a pedra responde 2x.
4. O que a Terra ergue tem a massa do material de que é feito (volume x densidade da pedra) e fica até alguém
   destruir. A densidade vem sempre do `.tres` do material, nunca de um número dentro da habilidade.
5. Qualquer cena pode declarar o material de um corpo com o metadado `material_data` (ex.: um chão de madeira,
   uma ponte de metal). Assim, a fase decide onde a Terra funciona sem código novo.

### Lei da Gravidade: muda o peso e a direção da queda de tudo que tem massa; não cria matéria

1. A gravidade de um lugar é definida por **áreas de gravidade** do mundo (`Area3D` com substituição de
   gravidade): intensidade e direção, ou um ponto que atrai.
2. **Peso = massa x gravidade do lugar x escala de gravidade do corpo** (`PhysicsProp.get_weight()`). A massa
   não muda: a Gravidade nunca cria nem tira matéria; ela só move o que já existe.
3. Tudo que tem massa responde igual: objetos, projéteis com corpo, pedregulhos da Terra, barris, monstros. **O mago não** (decisão do Liam):
   ele só muda de peso pelas próprias habilidades.
4. Mais peso significa queda mais rápida e impactos mais fortes; menos peso, objetos que flutuam e voam mais
   longe com o mesmo empurrão. As regras de impacto (dano por massa x velocidade, pólvora a 9 m/s) não mudam:
   a gravidade só muda a velocidade com que as coisas chegam.

### Lei do Quebrável: todo objeto racha em estágios e vira pedaços; os pedaços herdam o golpe e o material

Pedido do Liam (2026-11-17): todo objeto tem a propriedade quebrável. Até aqui nada quebrava; as caixas só voavam.

1. **Estágios:** 0 inteiro → 1, 2, 3 rachado (a cor escurece 14% por estágio e sai poeira) → 4 **pedaços**.
2. **Dano é impulso (N·s).** Todo golpe do mundo passa por `PhysicsProp.take_hit(impulso)`, que empurra e racha:
   soco, chute, explosão, construção que cai. O dano acumula; não se recupera.
3. **Impulso por estágio = `break_toughness` x massa inteira.** `break_toughness` é a variação de velocidade
   (m/s) que o golpe teria de dar no objeto inteiro para avançar um estágio. Objeto maior aguenta mais.
4. **Golpe fraco não marca:** abaixo de `break_min_fraction` (25%) de um estágio, o dano é 0. Empurrar, apoiar e
   esbarrar nunca quebram nada, por mais vezes que se repita.
5. **Batidas também racham:** queda ou arremesso acima de `break_impact_speed` deixam
   `massa_reduzida x (velocidade - break_impact_speed)` de dano. As explosões já passam por `take_hit`.
6. **Pedaços:** no estágio 4 o objeto some e nasce `break_pieces` pedaços em caixa, cortando sempre o maior pelo
   lado mais longo. Juntos, os pedaços têm o mesmo volume e a mesma massa do objeto.
7. **Direção e força:** cada pedaço sai com a velocidade do objeto + impulso do golpe / massa, mais um afastamento
   de `spread_speed` (1,5 m/s) a partir do centro. O conjunto anda para onde o golpe empurrou.
8. **O material segue a lei:** cada pedaço tem o material do objeto e herda o calor guardado (pedra em brasa vira
   brasas), o fogo e a **fração de combustível** que sobrou (queimado pela metade continua queimado pela metade).
9. **Pólvora não vira pedaços:** barril quebrado explode na hora.
10. **Pedaços não quebram de novo.** Somem após `piece_lifetime` (8 s). Com mais de `max_pieces` (40) vivos, os
    mais antigos somem primeiro. Pedaço que some vai para uma **reserva** (escondido, sem colisão) e volta como
    pedaço de outro objeto: quebrar não cria nós novos. A reserva (`max_pieces`) é criada quando a cena carrega.
11. **Física simplificada (desempenho):** pedaços ficam na camada de colisão 2. Colidem com o mundo, os objetos e
    os personagens, mas **não entre si**, e o mago anda através deles sem tropeçar. Pedaços com o maior lado
    abaixo de `small_piece_size` (0,25 m) não recebem calor e não avisam contato.
12. **Construções que não são `PhysicsProp`** (pilar de pedra, muro) usam a mesma lei pelo material:
    `material.hit_damage()` e `material.stage_for()` para os estágios, e `PhysicsProp.spawn_pieces()` para
    virar pedaços. O material delas é a **pedra moldada** (`earth_construct.tres`). Ela é igual à pedra, mas
    `break_toughness` 0,35, para que um pilar de uma tonelada caia em 6 socos de pedra.
13. **Poeira por quadro:** no máximo `max_bursts_per_frame` (3) nuvens de poeira (rachar, quebrar, virar cinzas) por
    quadro; as outras não aparecem. A poeira da explosão sempre aparece.
14. **Quebras não esperam:** tudo que uma explosão parte vira pedaços no mesmo quadro. Adiar quebras foi medido no
    teste profundo (2026-11-17) e deixou o tranco pior: a cena pesada dura mais quadros.

| Material | `break_toughness` | Exemplo | Impulso por estágio | Soco de Pedra (140; x2 em pedra) | Racha em queda acima de | Pedaços |
|---|---|---|---|---|---|---|
| Madeira | 6 m/s | caixa 0,6 m, 19 kg | 117 N·s | 4 socos; 3 revestido (210) | 10 m/s (~5 m) | 4 |
| Pedra | 2,8 m/s | bloco 0,6 m, 76 kg | 212 N·s | 4 socos (280); 3 revestido (420) | 8 m/s (~3,3 m) | 6 |
| Pedra | 2,8 m/s | bloco 1,2 m, 605 kg | 1694 N·s | o soco não marca (mínimo 423) | 8 m/s | 6 |
| Pedra moldada | 0,35 m/s | pilar 1x3x1 m, 1050 kg | 368 N·s | 6 socos (280); 4 revestido (420) | 8 m/s | 6 |
| Metal | 12 m/s | caixa 0,5 m, 75 kg | 900 N·s | o soco não marca (mínimo 225) | 18 m/s | 4 |
| Pólvora | 4 m/s | barril, 28 kg | 112 N·s | 4 socos e explode | 10 m/s (antes, detona a 9) | explode |
| Concreto, solo | 2,5 e 3 m/s | (chão não quebra; reservado para muros declarados) | — | — | 9 e 10 m/s | 6 e 4 |

### Cenário quebrável: tudo quebra e volta em 30 s (pedido do Liam, 2026-11-17)

Paredes, torres, degraus, escadas, rampas, plataformas e o chão da arena são `BreakableStructure`
(`src/gameplay/world/breakable_structure.gd`), de concreto. Seguem a lei do Quebrável com estas diferenças:

1. **Mesma interface dos objetos:** `take_hit(impulso, ponto)`. Soco, chute, Mibune e explosões já chamam isso.
2. **Resistência igual para qualquer tamanho:** cada estágio custa `structure_stage_impulse` (420 N·s), seja
   um degrau ou uma torre de 6 m. São 6 socos de pedra (280 no concreto) ou 4 revestidos (420). Golpes abaixo de
   25% de um estágio (105 N·s) não marcam.
3. **Estrutura comum, no 4º estágio:** some (sem colisão e invisível) e solta os pedaços do concreto (6), que
   saem na direção do golpe. A massa somada dos pedaços é no máximo `structure_piece_mass` (200 kg): uma torre
   de verdade pesaria toneladas e esmagaria tudo.
4. **Contenção (chão e muros da borda):** nunca perde a colisão, para ninguém cair para fora do mundo. No 4º
   estágio solta entulho de um bloco de `bedrock_chunk_size` (0,8 m) no ponto do golpe, fica rachada e pode
   rachar de novo.
5. **Volta sozinha:** `rebuild_time` (30 s) depois de quebrar, volta inteira (estágio 0, cor original).
6. **Não prende nem esmaga ninguém:** na hora de voltar, a estrutura confere o próprio volume. Se houver
   jogador, bot ou objeto inteiro (caixa, barril), espera e tenta de novo a cada `rebuild_retry` (0,5 s). Pedaços
   soltos dentro do volume vão para a reserva antes de ela voltar. Chão e vizinhos fixos encostados não contam.
7. **Explosões:** acertam a estrutura no ponto dela mais perto da explosão, com a queda por distância até a
   superfície (não até o centro, que numa parede de 100 m fica longe).
8. **Rachaduras:** escurecem só a estrutura atingida (cópia do material); voltam ao normal ao reconstruir.

### Interações da fatia (rastro de um, gancho do outro)

| Rastro | Gancho | O que acontece | O lado que ajuda | O outro lado |
|---|---|---|---|---|
| Fogo: calor | Pedra (Terra) | Pedra em brasa guarda calor e acende madeira encostada | O Fogo transforma pilares e pedregulhos em armadilhas | O mago da Terra pode arremessar a pedra quente; e quem a aqueceu também se queima perto dela |
| Terra: lama | Fogo | Lama é zona sem ar: apaga, bloqueia calor e abafa o braseiro | Terra desliga a área do Fogo | A lama também apaga o fogo que protegia o mago da Terra e para o pavio de um barril que ele queria explodir |
| Fogo: queima | Gravidade | Queimar tira massa: o objeto fica mais leve | Gravidade arremessa mais longe o que já queimou | O mesmo vale para o inimigo arremessar de volta |
| Gravidade: peso | Pólvora (Fogo) | Mais peso → queda mais rápida → impacto passa de 9 m/s e detona | Gravidade vira detonador à distância | O barril explode onde cair, inclusive perto de quem pesou |
| Gravidade: leveza | Terra | Pedras leves flutuam e viram projéteis e plataformas | Os dois usam as pedras | O inimigo também sobe nas plataformas e pega os projéteis |
| Gravidade: peso | Terra | Pedra é a mais densa: no peso alto, esmaga mais | Terra ganha força | Mais difícil para a própria Terra arremessar |
| Explosão | Pedra | A explosão aquece a pedra próxima | Rastro duradouro do Fogo | Fica quente para os dois lados |
| Terra: soco/chute | Construções e objetos | Racha em estágios e arremessa os pedaços na direção do golpe | A Terra derruba muros e faz chuva de pedra | Os pilares da própria Terra também caem: o inimigo derruba a escada dela |
| Fogo: calor | Quebrável | Pedra em brasa quebrada vira várias brasas; caixa em chamas quebrada espalha pedaços acesos | O Fogo espalha o incêndio ao quebrar | Os pedaços acesos voam também para quem quebrou |
| Explosão | Quebrável | A onda de choque é golpe: racha e parte caixas e construções no raio | Fogo abre caminho | A cobertura de pedra de quem se escondeu também se desfaz |
| Gravidade: peso | Quebrável | Mais peso → queda mais rápida → passa de `break_impact_speed` e racha | Gravidade quebra à distância soltando coisas | O que ela levanta e solta pode quebrar no inimigo ou no aliado |

### Explosões

Esfera de raio R a partir da origem. Quem leva o acerto direto recebe tudo. Os demais perdem força com a distância
d até a superfície do corpo. A explosão não depende de ar (a pólvora traz o que precisa); só o pavio para quando
o fogo é apagado.

**Cobertura:** um raio vai da explosão até o centro de cada corpo. Se uma parede ou um pilar estiver no caminho,
só 15% do impulso e do calor passam. Objetos soltos, personagens e o boneco não bloqueiam, para uma caixa não
virar escudo total. O raio é um só: quem está com o centro do corpo coberto conta como protegido.

### Alcance real do fogo (medido no teste de fumaça, caixas de madeira)

`fire_spread_radius` (1,4 m) é só onde o calor começa a chegar. Para acender, o calor precisa vencer o
resfriamento (15/s) antes de a vizinha acabar de queimar (10 s).

| Situação | Resultado |
|---|---|
| Uma caixa em chamas a 0,50 m entre centros | acende em 7,2 s |
| Uma a 0,62 m (distância da pirâmide) | acende em 9,9 s, quase no limite |
| Uma a 0,70 m ou mais | não acende |
| Três a 0,90 m | acende em 3,0 s (o calor soma) |
| Pirâmide de 10 caixas, acesa por uma da base | todas em 18,9 s |
| Pedra em brasa (400) e caixa a 0,8 m entre centros | acende em 1,6 s; a pedra cai para ~270 |
| Barril solto de 2,5 m (base) | gravidade normal: não detona · gravidade 3x: detona |

## Formulas (Fórmulas)

```
massa             = volume x densidade
peso              = massa x |gravidade_local| x gravity_scale
combustível/s     = ar                                   (ar: 0 a 1; 0 apaga)
calor_vizinho/s   = fire_spread_heat x ar x (1 - d / fire_spread_radius)
massa_queimando   = massa_inicial x lerp(1, burnt_mass_fraction, queimado)     queimado = 1 - combustível / burn_time
calor_guardado    = min(calor + q, max_heat)                                    (pedra, metal)
irradiado/s       = (calor - radiate_threshold) x radiate_rate x (1 - d / radiate_radius)   por vizinho, se calor > limiar
calor_emissor    -= soma do irradiado                                           (conservação)
tempo_para_acender = ignition_heat / (calor_recebido/s - heat_decay)            (nunca, se o divisor ≤ 0)
queda             = clamp(1 - d / R, 0, 1)      (x 0,15 atrás de parede ou pilar; 1 no acerto direto)
impulso_corpo     = impulso_explosão x queda    (direção: para fora + 40% para cima)
calor_corpo       = calor_explosão x queda
vel_jogador      += impulso / massa_jogador
impacto_no_boneco = massa x velocidade          (N·s, quantidade de movimento)
vel_impacto       = raiz(2 x g_local x altura)  (detona pólvora se ≥ impact_detonation_speed)
força_terra       = força_base x earth_force_factor
arremesso         = vel_arremesso x clamp(1 - massa / (carga x 1,5), 0,3, 1)

# Quebrável
impulso_estágio   = break_toughness x massa_inteira                              (N·s)
dano_golpe        = |impulso|  se |impulso| ≥ break_min_fraction x impulso_estágio, senão 0
dano_batida       = massa_reduzida x max(0, |v_relativa| - break_impact_speed)   massa_reduzida = m1·m2/(m1+m2); chão = m
estágio           = min(floor(dano_acumulado / impulso_estágio), 4)             (4 = pedaços)
massa_pedaço      = massa_atual x volume_pedaço / volume_total                  (soma = massa do objeto)
vel_pedaço        = vel_objeto + impulso_golpe / massa_atual + direção_do_centro x spread_speed
calor_pedaço      = calor_objeto ; combustível_pedaço = combustível_objeto (mesma fração queimada)
```

| Variável | Significado | Faixa | Origem |
|---|---|---|---|
| `ar` | Ar no ponto | 0 a 1 (acima de 1 reservado ao Ar/vento) | `HeatZone.air_factor` |
| `burn_time` | Combustível em segundos com ar normal | 3 a 10 | `materials/*.tres` |
| `burnt_mass_fraction` | Massa que sobra no fim da queima | 0,05 a 1 (0,4) | `materials/*.tres` |
| `max_heat` | Calor máximo guardado | pedra 400, metal 300 | `materials/*.tres` |
| `radiate_threshold` | Calor a partir do qual irradia | pedra 50, metal 80 | `materials/*.tres` |
| `radiate_rate` | Fração do excesso entregue por segundo | pedra 0,6, metal 0,4 | `materials/*.tres` |
| `earth_force_factor` | Multiplicador da Terra | pedra 2, demais 1 | `materials/*.tres` |
| `break_toughness` | m/s de variação de velocidade por estágio | 0,35 (pedra moldada) a 12 (metal) | `materials/*.tres` |
| `break_min_fraction` | Golpe mínimo que marca, em fração de um estágio | 0,25 | `materials/*.tres` |
| `break_impact_speed` | Velocidade de batida a partir da qual racha | 8 (pedra) a 18 (metal) | `materials/*.tres` |
| `break_pieces` | Pedaços no último estágio | 2 a 8 | `materials/*.tres` |
| `max_pieces`, `piece_lifetime`, `spread_speed`, `small_piece_size` | Limites dos pedaços | 40, 8 s, 1,5 m/s, 0,25 m | `materials/break_rules.tres` |

**Exemplo do Quebrável:** caixa de madeira de 0,6 m = 19,4 kg → `6 x 19,4 = 117 N·s` por estágio. Soco de 140:
1,2 estágio por soco. Depois de 3 socos (420) está no estágio 3; o 4º (560 ≥ 467) parte a caixa. Os 4 pedaços de
4,9 kg saem a `140 / 19,4 = 7,2 m/s` na direção do soco (medido: 5,6 m/s no conjunto, porque o atrito com o chão
já freia no primeiro quadro). Queda de 20 m: chega a ~19,7 m/s → `19,4 x (19,7 - 10) = 188 N·s` = estágio 1.

`d` é sempre a distância até a superfície do vizinho, não até o centro.

**Exemplos:** madeira a 1 m (superfície) de uma pedra em 400 de calor recebe `350 x 0,6 x (1 - 1/1,5) = 70/s`;
descontado o resfriamento de 15/s, acende em ~1,8 s, um pouco mais porque a pedra esfria ao entregar. Barril de 2,5 m: `raiz(2 x 9,8 x 2,5) = 7 m/s` (não detona);
`raiz(2 x 29,4 x 2,5) = 12,1 m/s` (detona).

## Edge Cases (Casos-limite)

- Explosão perto de outros barris: eles aquecem, acendem e explodem em cadeia (com atraso do pavio).
- Objeto em chamas sendo segurado continua queimando e espalhando calor.
- Barril jogado contra parede a ≥ 9 m/s explode na hora.
- Consultas de física nunca rodam dentro de callbacks de colisão (usamos `call_deferred`).
- Explosão rente ao chão ou colada numa parede: o raio começa 10 cm acima da origem.
- **Objeto dentro da lama e do braseiro ao mesmo tempo:** sem ar vence; o calor é ignorado e ele não acende
  (fecha a lacuna 2 do Sábio, de acender e apagar em ciclo).
- **Braseiro dentro da lama:** para de aquecer enquanto a lama o tocar e volta sozinho quando ela some (lacuna 1).
- **Objeto sem combustível:** não reacende, mesmo com calor.
- **Duas pedras quentes lado a lado:** trocam calor, mas cada uma perde o que entrega e o resfriamento continua;
  as duas esfriam até o limiar.
- **Pedra quente dentro de zona sem ar:** não recebe calor novo, mas continua irradiando o que guardou (calor
  guardado não é chama).
- **Explosão em zona sem ar:** empurra normalmente, mas o calor dela não entra em quem está sem ar (a lama
  protege do fogo, não da onda de choque).
- **Gravidade apontando para cima ou de lado:** os objetos "caem" naquela direção; o impacto conta igual.
- **Gravidade zero:** peso 0; o objeto mantém a velocidade que tinha. Nada cai, nada detona por queda.
- **Terra sobre o vazio, madeira ou metal:** `ground_under` devolve nada ou um material não trabalhável; a
  habilidade deve recusar sem gastar recurso.
- **Quebrar um barril de pólvora:** explode na hora, sem pedaços (inclusive pela onda de outra explosão: a reação
  em cadeia fica mais rápida perto do centro).
- **Objeto quebrado enquanto queima:** o fogo passa para os pedaços que não são pequenos; os pequenos nascem
  apagados e sem calor.
- **Pedaço atingido de novo:** é empurrado, mas não racha nem se divide (sem cascata de pedaços).
- **Mais de 40 pedaços:** os mais antigos somem no mesmo quadro em que os novos nascem.
- **Pedaços dentro de `HeatZone` (lama, braseiro):** as zonas só enxergam a camada 1, então os pedaços não são
  aquecidos nem abafados por elas. Pedaços quentes ainda aquecem e acendem vizinhos pelo calor espalhado.
- **Golpe com objeto congelado (`freeze`):** não empurra, mas racha normalmente.
- **Objeto redondo (esfera, cilindro):** os pedaços são caixas com o mesmo volume e a proporção do contorno.
- **Golpe enorme (de uma vez passa de 4 estágios):** vira pedaços direto; o excesso vai inteiro para a velocidade.

## Dependencies (Dependências)

| Sistema | Relação |
|---|---|
| `PropMaterial` (`prop_material.gd`) | Dados de todas as leis; `of()` e `ground_under()` respondem o material de um corpo e do chão |
| `PhysicsProp` (`physics_prop.gd`) | Calor, combustível, ar (`apply_air`), calor guardado, irradiação, peso (`get_weight`), quebrável (`take_hit`, `add_damage`, `shatter`, `spawn_pieces`, sinais `stage_changed` e `shattered`) |
| `BreakRules` (`break_rules.gd` + `materials/break_rules.tres`) | Limites globais dos pedaços (quantidade, vida, afastamento, física simplificada) |
| Soco/Chute de Pedra, Escada de Pedra (frente classes) | Devem golpear por `take_hit` e quebrar construções por `stage_for` + `spawn_pieces` (pedido registrado) |
| `HeatZone` (`heat_zone.gd`) | Zona de ambiente: calor por segundo e ar; braseiro e zonas sem ar |
| `Explosion` (`explosion.gd`) | Onda de choque; o calor dela também esquenta pedra e metal |
| Áreas de gravidade (`Area3D` do Godot) | Gravidade local; usadas por `SlowField` (frente classes) e pelos testes |
| Habilidades (frente classes) | Usam as leis: Bola de Fogo, Fogo-Fátuo, Chão de Lava e Almôndega chamam `add_heat`/`ignite`; Terra consulta o chão; Gravidade muda peso e direção |
| `MudPatch` (frente classes) | Hoje apaga e esfria os objetos por conta própria; deve passar a usar o ar do mundo (pedido registrado) |
| `TrainingDummy`, `FlyingTarget` (frente monstros) | Recebem calor (inclusive de pedra em brasa) e impacto |
| Tabela do Sábio | `tabela-elementos-materiais.md` é a origem das interações; este documento é a versão em vigor da fatia |

## Tuning Knobs (Ajustes)

Todos em `assets/data/materials/*.tres`: densidade, atrito, ignição, `heat_decay`, `burn_time`,
`burnt_mass_fraction`, `max_heat`, `radiate_threshold`, `radiate_radius`, `radiate_rate`, `earth_workable`,
`earth_force_factor` e os campos de explosão. `heat_per_second` e `air_factor` de cada `HeatZone` (o braseiro fica
em `test_arena.gd`). `blocked_explosion_factor` em `assets/data/damage_rules.tres` (0,15; faixa segura 0–0,5).

| Ajuste | Inicial | Faixa segura | Efeito de mexer |
|---|---|---|---|
| `radiate_rate` (pedra) | 0,6 | 0,2–1,0 | Abaixo de 0,3 a pedra quente quase não acende nada; acima de 1 vira lança-chamas |
| `max_heat` (pedra) | 400 | 150–600 | Quanto tempo a pedra fica perigosa depois do fogo |
| `heat_decay` (pedra) | 3/s | 1–10 | Quanto a pedra guarda sozinha; 3/s = ~2 min de 400 até o limiar |
| `burnt_mass_fraction` | 0,4 | 0,2–0,8 | O quanto queimar muda o arremesso |
| `earth_force_factor` (pedra) | 2 | 1,5–3 | Quanto a Terra prefere pedra |
| `break_toughness` (madeira) | 6 m/s | 3–10 | Socos para partir uma caixa (3 → 2 socos; 10 → 7) |
| `break_toughness` (pedra moldada) | 0,35 m/s | 0,2–0,8 | Socos para derrubar um pilar (0,8 → nem marca) |
| `break_min_fraction` | 0,25 | 0,1–0,5 | Abaixo de 0,1 esbarrões acabam rachando; acima de 0,5 golpes médios não fazem nada |
| `max_pieces` | 40 | 16–80 | Quantos pedaços ao mesmo tempo; principal botão de desempenho |
| `piece_lifetime` | 8 s | 3–20 | Quanto tempo os destroços ficam no chão |
| `max_explosions_per_frame` | 1 | 1–3 | Explosões no mesmo quadro; mais = tranco maior em cadeias de barris |
| `max_bursts_per_frame` | 3 | 1–8 | Nuvens de poeira por quadro em quebras grandes |
| `fuse_jitter` (pólvora) | 0,1 | 0–0,3 | Variação do pavio; 0 = barris acesos juntos explodem juntos |
| `structure_stage_impulse` | 420 N·s | 200–1000 | Socos para derrubar parede/torre (420 = 6 socos; 280 = 4) |
| `rebuild_time` | 30 s | 5–120 | Quanto tempo o cenário fica quebrado |
| `rebuild_retry` | 0,5 s | 0,2–2 | Espera extra quando há alguém no lugar |
| `structure_piece_mass` | 200 kg | 50–500 | Peso dos destroços de uma estrutura grande |
| `bedrock_chunk_size` | 0,8 m | 0,4–1,5 | Tamanho do entulho que o chão e a borda soltam |
| `spread_speed` | 1,5 m/s | 0,5–4 | O quanto os pedaços se abrem em leque |

## Acceptance Criteria (Critérios de aceite)

Testes automáticos em `tests/suites/gameplay.gd` (nenhum usa habilidade):

- [x] Madeira com calor suficiente pega fogo; barril explode e some.
- [x] Parede e pilar cortam impulso e calor; caixa solta e chão não bloqueiam; acerto direto ignora parede.
- [x] Fogo se espalha pela pirâmide de caixas em menos de 20 s (medido: 18,9 s).
- [x] **Fogo · combustível:** 3 s queimando deixam 7 s de 10; reacender continua do que sobrou; a massa cai.
- [x] **Fogo · ar:** zona sem ar apaga, impede calor e impede de acender.
- [x] **Fogo · braseiro abafado:** braseiro tocado por zona sem ar não aquece; sem a zona, volta a acender.
- [x] **Fogo · pedra:** pedra esquenta até 400 sem pegar fogo; guarda mais de 150 de 200 em 5 s enquanto a madeira
  perde tudo; pedra em brasa acende madeira a 0,8 m e esfria ao entregar calor.
- [x] **Terra:** chão da arena é concreto trabalhável; madeira não; pedra sim; no ar não há material; pedra 2x.
- [x] **Gravidade:** gravidade 3x triplica o peso sem mudar a massa; o objeto mais pesado cai mais rápido;
  gravidade de lado faz cair para o lado.
- [x] **Gravidade x Fogo:** barril solto de 2,5 m só detona na gravidade 3x.
- [x] **Quebrável · estágios:** golpe abaixo de 25% não marca; três golpes de um estágio passam por 1, 2 e 3; o
  4º vira 4 pedaços e o objeto some.
- [x] **Quebrável · conservação:** a massa dos pedaços soma a do objeto; o conjunto sai na direção do golpe.
- [x] **Quebrável · materiais:** o golpe que racha madeira só arranha a pedra e não marca o metal.
- [x] **Quebrável · batida:** queda de 20 m racha a caixa; de 1 m, não. Explosão a 1,2 m parte a caixa.
- [x] **Quebrável · herança:** pedra quente vira pedaços com o mesmo calor; caixa queimando vira pedaços
  queimando com o combustível que sobrou; barril quebrado explode.
- [x] **Quebrável · construções:** pilar de pedra moldada (1050 kg) cai no 6º soco de 280; `spawn_pieces` parte
  o pilar conservando a massa.
- [x] **Quebrável · desempenho:** nunca mais de 40 pedaços vivos (os antigos somem primeiro); pedaços não
  colidem entre si; pequenos sem calor e sem contato; somem ao fim da vida; partir 10 caixas cabe num quadro
  (< 16 ms; medido ~5 ms em modo headless); 40 pedaços vivos custam menos de 3,5 ms por quadro na física (medido ~2,7 ms, janela de 1,2 s).
- Explosões: 2 barris mandados explodir no mesmo quadro explodem em quadros seguidos; o pavio de 6 barris varia
  dentro de ±10%. Teste profundo (com janela): pior quadro da fase física abaixo de 33 ms.
- Cenário: 6 socos de 280 N·s derrubam a torre de 3 m em 6 pedaços que saem na direção do soco; com uma caixa no
  lugar a torre espera; sem ninguém, volta inteira. Chão golpeado solta entulho, não perde a colisão e nada cai
  através dele; volta inteiro. `rebuild_time` = 30 s no `.tres`.
- [ ] Playtest: dá para ver os 3 estágios de rachadura antes de quebrar (hoje só escurece e solta poeira; a
  arte pode trocar por rachaduras de verdade).
- [ ] Playtest: o Liam não sente travada ao partir várias caixas com uma explosão.
- [ ] Playtest: ficar atrás de parede ou da Escada de Pedra protege de um barril de um jeito fácil de entender.
- [ ] Playtest: o jogador percebe que a pedra está quente antes de encostar (cor e, no futuro, som e vapor).
- [ ] Playtest: lama sobre o braseiro é entendida como "abafou", não como bug.
- [x] **Fogo · dono do calor:** zona de calor e fogo conjurados não aquecem quem os conjurou e aquecem os outros;
  o calor espalhado continua sendo do conjurador.
- [x] **Terra · concreto:** o chão sem material declarado é concreto, e a Terra trabalha nele.
- [ ] Monstros obedecem às áreas de gravidade (pedido à frente monstros: usar `get_gravity()`).

## Decisões do Liam (2026-11-17)

1. **Áreas de gravidade: opção (c).** O mago só muda de peso pelas próprias habilidades. Áreas de gravidade,
   inclusive as de outros magos, mexem em objetos e monstros, não no corpo do mago. O `player.gd` continua sem
   ler a gravidade das áreas.
2. **Queimadura: quem conjurou não se queima com o que criou.** Outros magos, inclusive outros magos de fogo, se
   queimam. No mundo, isso é o **dono do calor** (`heat_owner`):
   - `add_heat(q, conjurador)` e `ignite(conjurador)` marcam o dono no objeto. `HeatZone.heat_owner` marca o dono
     da zona (Chão de Lava, por exemplo). Sem conjurador, o calor é do ambiente e queima todos.
   - O dono passa adiante: o que o fogo dele acende, a pedra que ele esquentou e os pedaços disso continuam
     dele. Se dois magos aquecem o mesmo objeto, vale o último que aqueceu.
   - O conjurador e tudo que é filho dele (a vida, por exemplo) são pulados ao espalhar calor.
   - **Lado que pune (regra de ouro):** o mago de fogo não se queima com o próprio fogo, mas o mago da Terra se
     queima com a pedra que o mago de fogo aqueceu, mesmo sendo ele quem a arremessa.
   - Hoje o mago **não tem vida** (só monstros usam `Health`). Para o mago se queimar, falta pôr vida no
     jogador e as habilidades passarem o conjurador. Os dois pedidos estão registrados.
3. **Chão sem material declarado é concreto** (`concrete.tres`), e o Mago da Terra pode manipulá-lo. Ele é
   menos denso que a pedra, guarda calor como ela e responde 1,5x à Terra. `soil.tres` (solo) continua existindo
   para fases que declararem terra de verdade.

## Perguntas abertas (para o Liam)

1. **Ar acima de 1 (vento)** fica reservado para o elemento Ar: alimenta o fogo (mais calor, consome mais
   rápido). Nada disso está ligado agora.
2. **Objeto grande aguenta proporcional à massa?** Hoje sim: o bloco de pedra de 1,2 m (605 kg) não racha com
   o soco, só com explosão ou queda. As construções da Terra usam a pedra moldada, mais frágil, para cair no
   soco. Opções: (a) manter (grande = só explosão); (b) pedra comum mais frágil; (c) resistência cresce mais
   devagar que a massa.
3. **Pedaços atravessáveis pelo mago?** Escolhido por desempenho e para o mago não tropeçar em destroços. Os
   pedaços ainda batem no mago e nos monstros. Quer que bloqueiem a passagem?
4. **Pedaços machucam?** Pedaços grandes que batem rápido num monstro ou no boneco dão dano de impacto (massa x
   velocidade), como qualquer objeto. Os pequenos não dão. Confirma?
5. **Buraco no chão?** Hoje o chão e os muros da borda racham e soltam entulho, mas não abrem buraco (para ninguém
   cair para fora do mundo). Opções: (a) manter assim; (b) abrir cratera rasa no chão (o chão vira placas com
   uma base indestrutível embaixo; custa mais desempenho); (c) buraco de verdade só em pisos elevados
   (plataformas), nunca no chão da arena.
6. **Força igual para toda estrutura?** Hoje degrau e torre de 6 m caem com os mesmos 6 socos. Quer que as
   grandes aguentem mais (por exemplo, proporcional ao tamanho)?

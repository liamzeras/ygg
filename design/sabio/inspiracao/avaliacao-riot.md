# Avaliação dos 3 magos pela filosofia de design da Riot

> Fichamento do Sábio, 2026-11-17. Frente: Inspiração. Semáforo: verde (só padrões de método; sem nomes, textos
> ou números da Riot no jogo). Nada aqui é decisão: as propostas esperam o Liam.
> Magos avaliados: Fogo, Terra e Gravidade, como estão nos GDDs `mage-fire.md`, `mage-earth.md`,
> `mage-gravity.md` e nos `.tres` de `assets/data/classes/` em 2026-11-17.
> Pesquisa anterior (passivas, "kit como frase"): [lol-passivas.md](lol-passivas.md).

## Conclusão

Os três magos têm **boa fantasia e bom gancho**, porque o gancho mora na física (como a pesquisa anterior
recomendava). O ponto fraco comum, pelo olhar da Riot, é **contrajogo e janela de punição**: várias
habilidades fortes acontecem **de uma vez, sem aviso**, ou **protegem o mago sem custo claro**. O segundo ponto é
**número invisível** (rebate do Push-Pull, recarga menor dos Sonhos, bônus do Terremoto): o jogador não vê por
que algo aconteceu, e isso fere o pilar 4.

Notas gerais (média dos critérios, 1 a 5): **Terra 4,0 / Gravidade 3,8 / Fogo 3,5.**

## 1. O que a Riot diz (fontes)

O que a fonte diz, separado do que proponho.

| # | O que a fonte diz | Fonte |
|---|---|---|
| 1 | **Contrajogo** = desenhar campeões "desafiadores de dominar" tanto para quem joga com ele quanto para quem enfrenta. Um campeão sem contrajogo, bem executado, deixa o oponente com respostas rasas ou nenhuma. (paráfrase do post de 2014) | [Design Values: In-depth with Mastery (arquivo)](https://archive.runeterra.net/na/riot-official/Ex5oYQW6), com o trecho citado em [MobaFire](https://www.mobafire.com/league-of-legends/forum/news/30804) `[fonte fraca: espelho]` |
| 2 | **Dominar (mastery) tem camadas**: perícia pessoal, jogo em equipe e adaptação. Campeões devem ter "vários níveis de domínio". Habilidade constante deve ganhar de bônus numérico. | [Design Values: Mastery](https://archive.runeterra.net/na/riot-official/Ex5oYQW6) |
| 3 | **Clareza visual**: "empurrar os limites com campeões novos costuma custar muita poluição visual". **Fraquezas pretendidas devem existir** ("intended weaknesses"). **Restrições significativas** deixam as forças brilharem. **Razão para ser escolhido** (identidade estratégica). | [Champion Gameplay Values 2016](https://archive.runeterra.net/na/developer-corner/uOVIbuoi) |
| 4 | **Padrões "anti-diversão" do Zileas**: "Carga de conhecimento" (efeito escondido que só quem já sabe responde); "diversão não supera a anti-diversão" (o outro lado sofre mais do que você se diverte); "você morre antes de poder reagir"; "otimização pouco clara" (não dá para saber se jogou bem). Bom contraexemplo: o Dark Binding dá esquivas visíveis: "o oponente tem esquivas de mestre como você tem acertos de mestre". | [Zileas' List of Anti-Fun Patterns, resumo no Law of Game Design](https://lawofgamedesign.com/2014/02/20/zileas-list-of-game-design-anti-fun-patterns/) `[fonte fraca: resumo de terceiro]` |
| 5 | **Phroxzon (2026)**: encontrar uma Mel de Seraphine é "uma experiência muito frustrante" porque ela anula o kit; mesmo assim, confrontos difíceis são "um dos molhos secretos" do LoL, mas "podemos exagerar se tivermos muitos". Ou seja: a Riot aceita **alguns** contras duros, não todos. | [PCGamesN](https://www.pcgamesn.com/league-of-legends/phroxzon-debate-mel-balance) `[fonte fraca: imprensa]` |
| 6 | **August Browning** (chefe de design de campeões): alcance é uma das maiores vantagens do LoL, então corpo a corpo recebe ferramentas (dash, controle) para competir; e levar um tiro só e morrer é "chato" e dá pouco contrajogo. | [Spilled.gg](https://spilled.gg/riots-lead-designer-finally-explains-favorite-melee-champion-keeps-getting-destroyed-ranged-attackers) e [Win.gg](https://win.gg/news/riot-games-employee-gives-hot-take-on-assassins-and-burst-damage/) `[fonte fraca: imprensa, resumo]` |
| 7 | **"Power budget"** (orçamento de poder): é uma metáfora **informal**, sem documento oficial com número. Exemplo reportado: o poder da Ambessa ficou concentrado nos dashes, deixando o resto do kit mais fraco. Quem explica melhor é a ideia: o kit gasta um orçamento fixo; se uma habilidade leva demais, as outras ficam sem espaço. | [Fórum Runeterra: "Can someone from Riot explain Power Budgets?"](https://archive.runeterra.net/na/skin-champion-concepts/XlrFhIKw) `[fonte fraca: fórum]`; Ambessa e Browning via resumo de imprensa `[fonte fraca]` |
| 8 | **Valorant: "Como balanceamos"**: no caso da Raze, jogadores "não reagiam às deixas de contrajogo" das habilidades e "tinham dificuldade de entender o que acontecia com eles"; a Riot respondeu **mudando as deixas de áudio** e a frustração medida ("ser foguetado e granadeado") levou a mudar o kit. Também usa "identidade central" para justificar mudanças. | [How we balance VALORANT](https://playvalorant.com/en-us/news/dev/how-we-balance-valorant/) |

**Lacunas honestas:** não achei fala direta do Phreak nem do Meddler sobre contrajogo (só uma menção de fórum ao
Phreak, não confirmada). Não encontrei lista oficial de "princípios de agente" do Valorant com as palavras
"informação" e "identidade de agente"; a página "How we design agents" redireciona para um vídeo que não
consegui ler. Tudo que digo abaixo sobre "telegrafar" e "janela de punição" como regra geral da Riot é
`[memória, a confirmar]`: a ideia aparece na fonte 4 e 8, mas não como regra escrita com esses nomes.

## 2. Critérios usados (notas 1 a 5)

| Sigla | Critério | Pergunta |
|---|---|---|
| CL | Clareza | Dá para entender o que faz só de ver e ouvir? |
| GA | Gancho | Tem uma ideia própria, ligada à física ou ao kit? |
| CJ | Contrajogo | O adversário tem uma resposta que dependa de habilidade dele? |
| JP | Janela de punição | Usar a habilidade deixa o mago vulnerável de forma justa? |
| LV | Legibilidade (visual e sonora) | O sinal na tela e no som explica por quê? (hoje, pelos GDDs; arte e som podem não estar prontos: nota = o que o desenho prevê) |
| DO | Domínio | Há teto de habilidade (precisa mirar, cronometrar, combinar)? |

"Sem número invisível" entra dentro de LV. Nota 3 = ok; 5 = exemplar; 1 = problema sério.

Custo da mudança: **baixo** = mexer em valor no `.tres`; **médio** = regra nova pequena ou sinal novo;
**alto** = sistema novo.

## 3. Mago do Fogo (nota geral 3,5)

**Fantasia:** "dominar o espaço de cima". **Gancho do kit:** o fogo fica no mundo (lava, queimadura) e a
Almôndega consome projéteis. É uma frase boa: *voa, marca o chão, e ninguém consegue ficar parado*. **Fraqueza
pretendida** (fonte 3): hoje é só gastar Mana (tudo no mesmo reservatório) e a recarga do voo. Falta fraqueza
física: do alto, o mago não é difícil de acertar nem punido ao voar.

| Habilidade | CL | GA | CJ | JP | LV | DO | Média |
|---|---|---|---|---|---|---|---|
| Bola de Fogo (esq.) | 5 | 3 | 4 | 4 | 4 | 4 | 4,0 |
| Fogo-Fátuo (dir.) | 4 | 4 | 4 | 3 | 3 | 3 | 3,5 |
| Chão de Lava (Q) | 4 | 4 | 3 | 2 | 4 | 2 | 3,2 |
| Almôndega (F) | 3 | 4 | 2 | 2 | 3 | 2 | 2,7 |
| Jatos de Fogo (Ctrl) | 4 | 3 | 2 | 2 | 3 | 4 | 3,0 |

**Bola de Fogo.** Funciona: carrega, cai em arco, explode: lê-se na hora, é esquivável e custa Mana por tiro.
Mudar: nada urgente. A nota de gancho é 3 porque o gancho (acender o que é inflamável) vem da física, não da
habilidade. Custo: nenhum.

**Fogo-Fátuo.** Funciona: lento (6 m/s), visível, esquivável, e "não some sozinho" é ótima fantasia. Mudar:
(a) hoje a queimadura de 10 s sobre um personagem **continua mesmo na lama** (pergunta aberta no GDD); sem
resposta, "sofrer 10 s e esperar" vira o contrajogo, que a fonte 4 chama de "você sofre sem poder agir". Sugestão:
lama, água ou rolar no chão **encerram a queimadura em personagens**, e o jogador vê o fogo apagar. Isso cria
contrajogo e conversa com o pilar 5. (b) Som próprio de "está chegando", mesmo longe. Custo: baixo (a, regra
pequena) e médio (b).

**Chão de Lava.** Funciona: cobre a área com um sinal claro e o dono não se queima (regra do Liam). Problema de
orçamento de poder: **duração máxima 10 s, recarga 10 s, só uma por vez**. No nível 99 a zona fica quase
sempre no chão: negação de área permanente e barata (35 Mana). Também é "quase só verbo": o mago a conjura e
fica livre. Mudar: contar a recarga **a partir do fim da lava** (assim ela some pelo menos uns segundos), ou
reduzir a duração máxima para ~7 s; e deixar a **borda visível 0,5 s antes** de aquecer (aviso de "vai
queimar"). Custo: baixo (recarga e duração) e médio (aviso).

**Almôndega de Fogo.** É o ponto mais crítico do Fogo. **3 s de invulnerabilidade total** (absorve todo dano
vindo de fora), recarga 8 s (cerca de 37% do tempo ativa) e ainda queima quem está perto. Pela fonte 4 e 5, é o
tipo de "anular o kit do outro" sem o outro poder agir: o oponente só espera. Hoje a única pista de custo é a
Mana. Ponto bom: **consumir projéteis** é gancho excelente e legível. Mudar: (a) o mago **não pode usar as
magias de fogo de ataque durante a Almôndega** (escolha: defender ou atacar); ou a invulnerabilidade vira
"resistência alta" (reduz, não anula); (b) mostrar uma **barra/anel que esvazia** (o jogador vê quanto falta,
então a espera é uma decisão, não um castigo); (c) cooldown começa quando a bola acaba. A nota "provisório" do
GDD (bloqueia também golpes de quem está dentro) é um bug de legibilidade a corrigir. Custo: baixo (a, c),
médio (b).

**Jatos de Fogo.** Voo em primeira pessoa é muito forte: o mago sai do alcance do soco da Terra e da área dos
Sonhos. Funciona: duração por nível, recarga 20 s, Mana. Falta: **janela de punição** (fonte 3, "fraquezas
pretendidas"). Hoje, voando, o mago não perde nada. Mudar: durante o voo, a mira de baixo fica mais lenta ou o
voo **gasta Mana por segundo** (assim voar mais alto/longe tem custo contínuo visível); ao acabar, cair sem
controle de ar por 0,5 s; e **rastro de fogo/som alto** para ouvir de onde ele vem. Custo: médio.

## 4. Mago da Terra (nota geral 4,0)

**Fantasia:** "ser uma rocha que bate". **Gancho do kit:** "a pedra existe ali, então eu uso": socar parede
reveste as mãos, e golpe no ar vira pedregulho. É o melhor exemplo do pilar 3: o mundo é o recurso. **Fraqueza
pretendida:** alcance curto (1,4 m) e depender de pedra por perto. Bom, é uma fraqueza física.

| Habilidade | CL | GA | CJ | JP | LV | DO | Média |
|---|---|---|---|---|---|---|---|
| Soco de Pedra (esq.) | 5 | 5 | 4 | 4 | 4 | 4 | 4,3 |
| Chute de Pedra (dir.) | 5 | 4 | 4 | 4 | 4 | 4 | 4,2 |
| Escada de Pedra (Q) | 4 | 4 | 5 | 4 | 4 | 4 | 4,2 |
| Terremoto (F) | 3 | 4 | 1 | 2 | 3 | 3 | 2,7 |
| Lamaçal (Ctrl) | 4 | 4 | 4 | 4 | 4 | 3 | 3,8 |

**Soco e Chute.** Funcionam muito bem: a faixa do corpo (soco da cintura para cima, chute da cintura para baixo) é
**legibilidade por física**: o jogador entende "por que não acertou". Gastar Vigor num golpe no ar é punição justa;
o revestimento dá teto de habilidade (socar a parede antes, pensando no próximo golpe). Mudar: (a) mostrar um
**indicador de revestimento** (mão com pedra visível, contador de tempo) e (b) som diferente com e sem pedra.
Também cuide do "mestre do alcance": 2,4 m revestido ainda pode ficar curto contra voo; é bom assim, não corrigir
(o voo do Fogo é a contra-medida certa). Custo: médio (sinais).

**Escada de Pedra.** Exemplar em contrajogo: **o inimigo pode socar e quebrar a escada**, e ela dura 8 s. A
construção é visível e dá uma regra clara. Mudar: nada. Custo: nenhum.

**Terremoto.** Ponto crítico da Terra. O código confirma: `_launch(ground)` roda **ao nascer** da zona; o relevo
sobe em 0,3 s e a pessoa é lançada e ferida na hora. **Sem aviso**: pelas fontes 4 e 6, é "levar o golpe antes de
reagir". A medição do GDD já aponta dano forte (54,6 no boneco). Mudar: (a) **0,6 a 0,8 s de tremor no chão antes**
(rachaduras, poeira, som grave): o contrajogo vira "sai da área ou pula"; (b) com aviso, o dano atual é
defensável; sem aviso, reduzir; (c) o mago continua imune ao próprio efeito. Custo: médio (aviso e sinal),
baixo (dano).

**Lamaçal.** Bom exemplo de controle com custo: **atrasa o caster também**, só nasce em terra/pedra, e apaga
fogo (conversa com o Fogo). Mudar: dar um **sinal claro da borda** (cor e som de "pisar em lama") e deixar que
fogo/lama se anulem de forma visível. Custo: baixo.

## 5. Mago da Gravidade (nota geral 3,8)

**Fantasia:** "ser quem decide para onde as coisas caem". **Gancho do kit:** o rastro é uma *zona de gravidade
do mundo*, e objetos arrastados causam dano pela colisão. O mais surreal dos três, então a Zona Nula (antimagia) e
a regra "magos não são puxados" mostram a limitação certa do pilar 2. **Fraqueza pretendida:** Mana alta por
habilidade e alcance curto. O Mibune e o Push-Pull são as peças de maior **teto de habilidade** dos três magos.

| Habilidade | CL | GA | CJ | JP | LV | DO | Média |
|---|---|---|---|---|---|---|---|
| Push-Pull (esq.) | 3 | 4 | 4 | 4 | 2 | 4 | 3,5 |
| Mibune (dir.) | 4 | 5 | 4 | 4 | 4 | 5 | 4,3 |
| Gravidade dos Sonhos (Q) | 3 | 4 | 4 | 3 | 2 | 3 | 3,2 |
| Gravidash (Ctrl) | 5 | 3 | 3 | 3 | 4 | 4 | 3,7 |
| Zona Nula (F) | 3 | 5 | 2 | 3 | 3 | 3 | 3,2 |

**Push-Pull.** Mudar o **efeito pela distância** (perto empurra, longe puxa, limite de 4 m) é inteligente
(um botão, duas funções), mas **só o jogador experiente sabe onde está a linha**. E o rebate de projéteis
depende de uma comparação invisível ("impulso do Push-Pull >= impulso do projétil"): o jogador vê o projétil
passar e não sabe por quê (fonte 4: "carga de conhecimento", "otimização pouco clara"). Mudar: (a) mira com
seta para dentro/fora conforme a distância; (b) quando rebate, brilho e som de "clang"; quando falha, o projétil
**brilha mais forte** e o som é diferente: o jogador entende "era forte demais". Custo: médio.

**Mibune.** Melhor habilidade de domínio do jogo: duas conjurações (formar, disparar), objetos arrastados que
viram dano, e o limite de não puxar magos (pilar 2). Mudar: deixar claro, com **linha/anel de alcance de 5 m**
e **som crescente**, onde ele puxa; e pensar se 200 de impulso no impacto com raio de 2 m é um golpe que se
esquiva (o GDD diz que sim: velocidade 35 m/s é rápida; esquivar depende de ouvir o disparo). Custo: baixo.

**Gravidade dos Sonhos.** Boa ideia: zona fixa, **sair dela é o contrajogo**. Mas os efeitos são sutis e
numéricos (adversário 40% mais lento e pesado; o mago pula mais e **recarrega 1,4x mais rápido**). Recarga
menor é **número invisível**: o jogador não vê que o mago está mais perigoso por 6 s. Mudar: mostrar a zona com
partículas caindo mais rápido, **mago com brilho** enquanto acelera as recargas (HUD: ícone de recarga
brilhando). Custo: médio. Observação: no GDD, a zona não pesa outros magos mas os atrasa; pode parecer
"inconsistente" (pergunta aberta do próprio GDD) e merece 1 frase de explicação no jogo.

**Gravidash.** Clara e boa: duas cargas, 4 m em 0,2 s. Ponto de atenção: o GDD de Terra registra que o **dash saiu
das classes por ser "muito OP"**, mas o Gravidash existe e é, na prática, um dash de 20 m/s com 2 cargas e
recarga de 4 s, que ainda empurra quem está perto. Pergunta ao Liam: o Gravidash é a exceção intencional?
Mudar: manter o custo em Vigor (a janela de punição é Vigor baixo) e **mostrar as cargas** no HUD. Custo: baixo.

**Zona Nula.** O maior gancho do jogo ("a luta vira corpo a corpo"), mas é o **ponto de maior frustração
potencial**. O código (`null_zone.gd`) confirma: o caster fica com os golpes; **os outros ficam sem
habilidades** (`set_ability_lock(self, kit if character == caster else {})`). Ou seja: **o mago de Gravidade usa
socos e chutes, e o Fogo fica sem nada**, inclusive sem soco (confirmar no jogo; do GDD parece ser isso). Pela
fonte 5, a Riot só aceita alguns contras duros, e sempre com saída. Saída hoje: sair da zona de até 9x9 m, que
não se move, e o custo é **toda a Mana** (boa regra de custo!). Mudar: (a) dar a todos **golpes básicos** (o
mesmo soco/chute sem magia) dentro da zona, para a luta "na mão" ser realmente uma luta, não uma execução;
(b) **bordas bem visíveis** e som ao entrar ("a magia se apaga"); (c) mostrar no HUD "zona nula: N s" para quem
está dentro; (d) o mago da Gravidade **também perde Mana para 0**: a janela de punição já existe; mostrar isso.
Custo: baixo (a), médio (b, c).

## 6. O que o Ygg NÃO deve copiar do LoL

O LoL é um MOBA visto de cima, com mira em um ponto do chão e mapa pequeno; o Ygg é primeira pessoa com física.

1. **"Controle duro" travando o personagem** (atordoar, silenciar, enraizar por tempo fixo). Em FPS, perder o
   controle da câmera é muito pior do que ver o personagem parado do alto. Prefira controle **de movimento**
   (lama, peso, empurrão): o jogador continua olhando e atirando. A Zona Nula é a exceção, e por isso precisa
   de tantos sinais. `[memória, a confirmar]` sobre o desconforto em FPS; é opinião de design minha.
2. **Habilidades-alvo (clique em alguém e dá o efeito)** e acúmulos escondidos (marcas, pilhas em cima da
   cabeça). A pesquisa de passivas já recomenda trocar pilhas por **grandezas no mundo**.
3. **Ver o inimigo de cima.** Nenhum "círculo de aviso" sobre a cabeça: o aviso tem de ser **no mundo** (poeira,
   rachadura, som posicional), porque o jogador está olhando em uma direção só.
4. **Visão de mapa e "pings".** Em primeira pessoa, **o som é o minimapa**. Cada habilidade precisa de som
   distinguível antes de ter vistosidade.
5. **Contagem de recargas em segundos exatos como regra principal de balanceamento.** No LoL, tudo se resolve por
   números; no Ygg, o jogador se defende com **física** (objeto, terreno), e o número deve vir por trás dela.
6. **Tabela de contra-campeões.** O pilar 5 do Ygg pede que ninguém seja um "counter" fixo de outro; a
   frustração da Mel (fonte 5) é justamente esse tipo de contra duro.

## Propostas

Máximo de 6, em ordem de prioridade. Cada uma cabe em sim ou não.

1. **Terremoto avisa antes (0,6 a 0,8 s de tremor, rachadura e poeira) e o dano atual só vale depois do aviso.**
   Frente dona: **classes** (regra e `.tres`) com **arte** para o sinal. Sim ou não?
2. **Almôndega de Fogo vira escolha: enquanto ativa, o mago não usa as magias de fogo de ataque, e um anel
   mostra quanto falta. A recarga só começa quando ela acaba.** Frente dona: **classes**; o anel é de
   **interface**. Sim ou não?
3. **Zona Nula dá a todos os magos dentro os mesmos socos e chutes sem magia (hoje só o mago da Gravidade os
   tem), com bordas bem visíveis e som ao entrar.** Frente dona: **classes**; bordas por **arte**; som por
   **audio** (só design). Sim ou não?
4. **Queimadura de personagem apaga na lama ou na água (o Fogo-Fátuo deixa de ter 10 s sem resposta).** Frente
   dona: **classes**. Sim ou não?
5. **Chão de Lava: a recarga começa quando a lava acaba (ou a duração máxima cai para ~7 s), com a borda
   visível 0,5 s antes de aquecer.** Frente dona: **classes**; borda por **arte**. Sim ou não?
6. **Mostrar os "números invisíveis" na tela: seta para dentro/fora e "clang" no Push-Pull, brilho no mago com
   recargas aceleradas nos Sonhos, ícone de revestimento da Terra, cargas do Gravidash.** Frente dona:
   **interface** (HUD), **arte** (brilhos) e **audio** (design dos sons). Sim ou não?

**Perguntas abertas ao Liam (fora das 6):** o Gravidash é exceção ao "dash saiu das classes"? O voo do Fogo deve
ter custo contínuo de Mana ou janela de queda? O Fogo sem soco dentro da Zona Nula é intencional?

# Magos de um elemento: a abordagem repensada

> Sábio, 2026-11-16. Substitui a parte "para o Ygg" de [lol-passivas.md](lol-passivas.md), que pensava em
> Cavaleiro, Elementalista e Psiônico. Material de pesquisa e proposta, não GDD: a visão nova ainda precisa
> entrar em `design/gdd/game-concept.md`, que não é do Sábio.

## A visão do Liam (2026-11-16)

- Batalha em que **todos os personagens são magos elementais**.
- No começo, cada mago domina **um só elemento**: água, fogo, terra, ar, natureza, eletricidade ou gravidade.
- Cada elemento tem em média **2 especializações** (estilos de magia e de combate). Elas podem ser combinadas,
  mas **nunca exploradas por completo ao mesmo tempo**.
- O mago só trabalha com as propriedades e transformações do seu elemento.
- Todo mago tem **movimento, ataque, defesa e manipulação de terreno**, com a cara do elemento e diferentes
  entre si.
- Combinar classes pode vir no futuro, mas o jogo não é feito pensando nisso.

## O que muda na abordagem

Antes, a passiva do LoL virava a **cola entre as habilidades de um kit misto**. Com magos de um elemento só, a
cola já existe: é a física do próprio elemento. A ideia se divide em duas:

1. **A lei do elemento (a "passiva").** Cada elemento tem uma regra física sempre ligada, que todas as
   habilidades dele obedecem. É o que a Qiyana e a Taliyah fazem com o terreno: o mundo muda o que a
   magia faz.
2. **Rastros como linguagem entre magos.** Num kit misto, o rastro de uma habilidade servia a outra do mesmo
   kit. Numa batalha de magos de um elemento, **o rastro de um mago é o gancho do outro**: a poça do mago de
   água conduz o raio do mago de eletricidade, e o vento do mago de ar espalha o fogo. Isso vale para aliados e
   para inimigos, e é aí que mora a criatividade do pilar 3.

A regra "troque pilhas por grandezas" continua valendo, e fica mais importante: se o estado mora no mundo (calor,
água, massa, carga elétrica), os elementos conversam sem nenhum código especial entre eles.

**Bônus de graça para o futuro:** se a lei mora no mundo e não no mago (lição do blog técnico da Mel, em
[lol-passivas.md](lol-passivas.md)), combinar classes depois não exige refazer nada. Não custa nada agora e não
obriga a pensar nisso.

## Referências novas

| Fonte | O que ensina | Cuidado |
|---|---|---|
| **Avatar** (sub-dobras): metal é uma especialização da terra, lava é terra com calor, cura é água sobre o corpo, combustão é fogo concentrado ([Winter is Coming](https://winteriscoming.net/posts/every-type-of-sub-bending-in-avatar-the-last-airbender/3), [SlashFilm](https://www.slashfilm.com/1526194/avatar-the-last-airbender-powers-explained)) `[fonte fraca]` | **A especialização é uma transformação física do elemento**, não um tema solto | Algumas sub-dobras quebram a lei do elemento (sangue). Evitar |
| **Guild Wars 2**: o elementalista troca entre 4 elementos, e cada um puxa para um papel: fogo dano, água cura e lentidão, ar dano e controle, terra defesa ([wiki oficial](https://wiki.guildwars2.com/wiki/attunement)) | Dá identidade rápida a cada elemento | **Elemento vira papel** ("água é o curandeiro"). No Ygg, todo elemento precisa dos 4 papéis |
| **Spellbreak**: battle royale com 6 elementos; a classe define o elemento principal, e elementos se combinam ou se anulam ([Twinfinite](https://twinfinite.net/guides/spellbreak-best-gauntlet-elements-class-combos/), [PCGamesN](https://www.pcgamesn.com/spellbreak/best-gauntlet-tier-list)) | É a referência mais próxima: combos entre elementos são o conteúdo | Os guias logo criaram ranking de "melhor combo". **Interação que só ajuda um lado vira meta fixa** |

## O modelo proposto

### Elemento = lei + eixo com dois polos

Cada elemento tem uma **lei** e um **eixo físico**. As duas especializações são as pontas desse eixo. Isso
explica sozinho por que elas se combinam, mas não por inteiro: ninguém fica nas duas pontas ao mesmo tempo. A
água pode estar mais quente ou mais fria, mas não as duas coisas.

### As 4 funções, cada uma com duas versões

Cada função (movimento, ataque, defesa e terreno) tem uma versão de cada especialização. O mago escolhe uma
versão por função.

- **4 escolhas da mesma ponta:** ganha a **maestria** dessa especialização, um efeito extra forte.
- **Escolhas misturadas:** mais flexível, mas sem maestria.
- **Nunca as duas maestrias.** A regra do Liam sai naturalmente.

Isso é a opção **C** abaixo, a que recomendo. As outras ficam para comparar:

| Opção | Como funciona | A favor | Contra |
|---|---|---|---|
| A. Barra de afinidade | Um valor de 0 a 100 entre os polos; cada habilidade fica mais forte conforme a barra | Muito físico (temperatura, peso) | Difícil de ler: "minha lança está 63% forte?" |
| B. Árvore com pontos | Duas árvores e menos pontos do que o total; o último nó de cada uma exige muitos pontos | Conhecido (WoW, Path of Exile) `[memória, a confirmar]` | Muitos números pequenos e invisíveis, o erro que o LoL ensina |
| **C. Uma escolha por função** | 4 funções x 2 versões; a maestria pede as 4 da mesma ponta | Legível, cabe nas 4 teclas, fácil de testar | Menos granular; precisa de 8 habilidades por elemento |

### Os 7 elementos

A ideia de cada linha é um rascunho para discussão, não um número. O objetivo é mostrar que os 4 papéis cabem em
cada elemento e que **os verbos de movimento não se repetem**.

#### Fogo
- **Lei:** calor acumula, espalha e consome combustível. Precisa de ar: o vento alimenta, e água e lama apagam.
- **Eixo:** velocidade da queima. **Chama** (lenta, espalha, área, dano ao longo do tempo) ↔ **Explosão**
  (rápida, concentrada, impulso).

| Função | Chama | Explosão |
|---|---|---|
| Movimento | Corrida que deixa trilha de fogo atrás | Propulsão: explosão atrás ou embaixo de você (recuo) |
| Ataque | Jato de chamas contínuo | Bola de Fogo (já existe) |
| Defesa | Muro de fogo que queima projéteis de madeira e planta | Detonar um projétil inimigo no ar |
| Terreno | Incendiar mato, secar lama, derreter gelo | Cratera: abre buraco e lança destroços |

#### Água
- **Lei:** muda de estado com a temperatura (gelo, líquido, vapor), escorre para baixo, molha. O que está
  molhado demora a pegar fogo e conduz eletricidade.
- **Eixo:** temperatura. **Gelo** (sólido) ↔ **Maré** (líquido, pressão).

| Função | Gelo | Maré |
|---|---|---|
| Movimento | Trilho de gelo para deslizar | Surfar numa onda |
| Ataque | Lança de gelo (massa, perfura) | Jato d'água (empurra e molha) |
| Defesa | Parede de gelo (derrete com fogo) | Bolha d'água que freia projéteis |
| Terreno | Congelar o chão (escorrega) | Alagar: poça, e lama se houver terra |

#### Terra
- **Lei:** massa e permanência. O que a terra ergue fica e pesa até alguém destruir. **Depende do chão:** só
  trabalha solo e pedra que existem ali (é a ideia E1, que vira o centro do elemento).
- **Eixo:** coesão. **Rocha** (rígida) ↔ **Areia** (granular, escorre).

| Função | Rocha | Areia |
|---|---|---|
| Movimento | Pilar elevador (a Escada de Pedra já existe) | Afundar e sair adiante, num túnel curto |
| Ataque | Arremessar pedra (massa, impacto) | Jato de areia: cega e desgasta, empurra pouco |
| Defesa | Muralha de pedra | Escudo de areia que absorve o impacto e se desfaz |
| Terreno | Erguer cobertura | Lamaçal ou areia movediça (o Lamaçal já existe) |

#### Ar
- **Lei:** pressão. Empurra sem tocar e carrega o que é leve (fumaça, vapor, esporos, faíscas). Quase não tem
  massa própria, então só move o que já existe. Alimenta o fogo.
- **Eixo:** movimento do ar. **Vento** (fluxo) ↔ **Vácuo** (pressão parada: comprimir, tirar o ar).

| Função | Vento | Vácuo |
|---|---|---|
| Movimento | **Planar**, dependendo do vento: sobe em correntes, e o fogo cria corrente para cima | Super salto com ar comprimido sob os pés |
| Ataque | Rajada em cone (o Golpe de Escudo vira isto) | Bolha comprimida que estoura (concussão) |
| Defesa | Redemoinho que desvia projéteis leves | Bolha sem ar: apaga fogo e corta a onda de explosão |
| Terreno | Vento constante numa área | Bolsão sem ar onde o fogo não acende |

O corte da explosão é física real: a onda de choque precisa de ar para viajar. Vale conferir os números antes de
usar `[memória, a confirmar]`.

#### Natureza
- **Lei:** crescimento leva tempo e precisa de solo. A água acelera, o fogo destrói. Tudo que cresce é
  madeira, então pega fogo.
- **Eixo:** ciclo da vida. **Crescimento** (raízes, cipós, árvores) ↔ **Podridão** (fungos, esporos,
  apodrecer).

| Função | Crescimento | Podridão |
|---|---|---|
| Movimento | Cipó gancho para puxar e balançar | Cogumelo trampolim que cresce e lança |
| Ataque | Espinhos ou sementes como projéteis | Nuvem de esporos: veneno ao longo do tempo, levada pelo vento |
| Defesa | Muro de raízes (bloqueia, mas queima) | Apodrecer a madeira e as construções do inimigo |
| Terreno | Mato e árvores (cobertura e esconderijo) | Pântano podre que solta gás inflamável |

O gás do pântano é metano, que existe de verdade e é o melhor gancho para o mago de fogo `[memória, a confirmar]`.

#### Eletricidade
- **Lei:** caminho. A corrente segue o condutor (metal, água, o que está molhado) até o chão. É instantânea, mas
  só onde existe caminho: no ar seco, o alcance é curto. O campo `conductive` dos materiais já existe.
- **Eixo:** carga em movimento ou parada. **Descarga** (corrente: dano, choque, cadeia) ↔ **Magnetismo**
  (campo: atrair e repelir metal).

| Função | Descarga | Magnetismo |
|---|---|---|
| Movimento | Salto relâmpago até um condutor próximo | Puxar-se até um metal (gancho magnético) |
| Ataque | Raio que pula entre condutores | Arremessar metal em alta velocidade |
| Defesa | Para-raios: estaca que atrai as descargas | Campo que desvia projéteis de metal |
| Terreno | Eletrificar poça ou metal (área perigosa) | Magnetizar metal para montar cobertura |

**Diferença da gravidade:** o magnetismo só mexe em metal. A gravidade mexe em tudo que tem massa.

#### Gravidade
- **Lei:** muda o peso e a direção da queda, mas não cria matéria. Tudo que tem massa responde, inclusive o
  próprio mago. É o elemento mais surreal, então é o mais caro e o de menor alcance (pilar 2).
- **Eixo:** **Peso** (ancorar, esmagar, puxar) ↔ **Leveza** (flutuar, arremessar, desacelerar). O Psiônico
  já é quase todo Leveza.

| Função | Peso | Leveza |
|---|---|---|
| Movimento | Queda meteoro: despenca e causa impacto | Flutuar (já existe) |
| Ataque | Poço que puxa tudo para um ponto | Telecinese com arremesso (já existe) |
| Defesa | Ancorar: imune a empurrões (a Postura de Muralha vira isto) | Campo Lento (já existe) |
| Terreno | Esmagar: afundar o chão, derrubar estruturas | Pedras flutuantes como plataformas |

**Planar (Ar) e Flutuar (Gravidade) não são iguais:** planar depende do vento e de correntes, é barato e sem
controle total. Flutuar não depende de nada, tem controle total e drena Mana.

### Verbos de movimento (conferência)

| Fogo | Água | Terra | Ar | Natureza | Eletricidade | Gravidade |
|---|---|---|---|---|---|---|
| Propulsão / trilha | Surfar / deslizar | Elevador / túnel | Planar / super salto | Gancho / trampolim | Salto a condutor / ímã | Flutuar / meteoro |

Nenhum se repete. O dash e o pulo duplo continuam iguais para todos.

## Rastro de um, gancho do outro

São as interações que transformam a batalha em conteúdo. **Regra de ouro:** cada interação tem dois lados, e
nenhum elemento ganha sempre. Isso evita a tabela de tipos do Pokémon e o "melhor combo" fixo do Spellbreak.

| Rastro | Gancho | O que acontece | O outro lado |
|---|---|---|---|
| Água: poça, molhado | Eletricidade | Conduz o raio | O mago de água também se molha e conduz |
| Água | Fogo | Apaga | O fogo transforma a água em vapor, que tira a visão |
| Ar: vento | Fogo | Alimenta e espalha | O fogo espalhado pode voltar contra o aliado |
| Fogo: calor | Ar | Corrente para cima: o planador sobe | |
| Natureza: pântano | Fogo | O gás explode | O mago de natureza perde o próprio terreno |
| Natureza: madeira | Fogo | Raízes e muros queimam | |
| Água | Natureza | Acelera o crescimento | |
| Água + Terra | Todos | Lama: freia e apaga | |
| Ar | Natureza: esporos | O vento leva a nuvem | Pode levar para o lado errado |
| Gelo | Gravidade: peso | Esmaga e quebra o gelo | |
| Gravidade: leveza | Terra | Pedras flutuantes viram projéteis e plataformas | |
| Metal | Eletricidade | Ímã e condutor | Quem está perto de metal fica exposto |
| Ar: vácuo | Fogo e explosões | Apaga e corta a onda | |

A [tabela de elementos e materiais](tabela-elementos-materiais.md) passa a ser a fonte dessas regras e precisa
crescer para 7 x 7.

## O que já temos e para onde vai

| Hoje | Vira |
|---|---|
| Bola de Fogo | Fogo, ataque (Explosão) |
| Escada de Pedra | Terra, movimento (Rocha) |
| Lamaçal | Terra, terreno (Areia) |
| Flutuar, Telecinese, Campo Lento | Gravidade (Leveza) |
| Postura de Muralha | Gravidade, defesa (Peso) |
| Golpe de Escudo | Ar, ataque (Vento) |
| Dardo Cinético | Ar, ataque (Vácuo), ou sai |
| Investida | Gravidade (Peso), como alternativa de movimento à queda meteoro: o mago fica pesado enquanto corre, e o impacto continua sendo massa x velocidade |
| Laboratório: água, gelo, molhado | Água |
| Laboratório: teia, óleo | Natureza, ou ficam como materiais do mundo |

**O Cavaleiro é repartido entre os elementos** (decidido em 2026-11-16). Nenhuma habilidade dele se perde:

- Golpe de Escudo vai para o Ar, Postura de Muralha e Investida vão para a Gravidade (Peso).
- Dash e Pulo Duplo já são de todos e continuam assim.
- Os valores atuais servem de ponto de partida, porque já foram testados. O que muda é a explicação: a força vem
  do elemento, não do corpo, e o custo passa de Vigor para Mana.
- **Ainda não muda o jogo.** Tirar o Cavaleiro do menu e mover o código é trabalho da frente `classes`, depois
  que a fatia vertical for decidida. Até lá, ele continua jogável para os testes.

## As 6 ideias do LoL, revistas

| Ideia | Antes | Agora |
|---|---|---|
| P1. Recuo do Dardo | Psiônico | **Mantém, vira Fogo (Explosão), movimento.** O recuo de uma explosão é muito mais crível que o de um dardo |
| P2. Campo guarda o momento | Psiônico | **Mantém, vira maestria de Gravidade (Leveza)** |
| P3. Telecinese esquenta | Psiônico | **Descartar.** Calor é do Fogo, e a regra é um elemento por mago |
| C1. Pulo na parede | Cavaleiro | **Mantém, para todos**, como o dash e o pulo duplo |
| C2. Muralha guarda o golpe | Cavaleiro | **Descartar.** O ancorar do Peso cobre a fantasia sem guardar energia |
| E1. O chão define o pilar | Elementalista | **Vira a lei da Terra** |

## Jogadores e monstros (decidido em 2026-11-16)

A batalha é **contra jogadores e contra monstros**. O que isso muda:

- **Monstros obedecem às mesmas leis.** Um monstro de fogo acende madeira e é apagado pela lama, como um
  mago. É a mesma regra do bot Psiônico, que já usa o kit do jogador. Assim, quem aprende a lutar contra
  monstros aprende a lutar contra jogadores.
- **Monstros podem ser só material.** Nem todo monstro precisa de elemento: um de madeira queima, um de metal
  conduz. Isso cria problemas que cada elemento resolve de um jeito.
- **As defesas precisam servir para os dois casos.** Contra jogador, a defesa responde a uma habilidade.
  Contra um grupo de monstros, ela precisa durar ou cobrir área. Cada elemento precisa de pelo menos uma
  versão de defesa que funcione contra vários alvos.
- **O controle precisa de dois limites.** Prender ou atordoar um monstro é divertido, mas prender um
  jogador por muito tempo é frustrante. Proposta: a mesma habilidade dura menos contra jogadores, e o efeito
  aparece na tela para os dois lados.
- **O equilíbrio olha para dois lugares.** Um elemento fraco no duelo pode ser ótimo contra grupos, e vice-versa.
  Isso é aceitável se ninguém for fraco nos dois.

## Riscos

- **Escopo.** Com a opção C, são 7 elementos x 8 habilidades = **56 habilidades**. Sugestão de fatia vertical:
  **Fogo, Terra e Gravidade**, que já têm código, e **Água** em seguida, que já tem módulos no laboratório.
- **Pilar 2.** Gravidade e eletricidade são os elementos mais surreais. Precisam dos limites mais claros:
  eletricidade só com condutor, gravidade drenando Mana rápido.
- **Equilíbrio na batalha.** Elementos com movimento muito forte dominam o combate. Os verbos de movimento
  precisam de custo e de janela de vulnerabilidade, como a recarga do Jhin.
- **Terreno pobre.** Terra e Natureza dependem do chão. Uma arena de metal deixa os dois sem nada. A arena
  precisa ter variedade de materiais, e cada mapa vira uma escolha.

## Perguntas para o Liam

1. ~~**Batalha contra quem?**~~ Respondido: jogadores e monstros (ver a seção acima).
2. **Especializações:** a opção C (uma escolha por função, maestria com as 4 da mesma ponta) serve?
3. ~~**O Cavaleiro**~~ Respondido: repartido entre os elementos (ver "O que já temos e para onde vai").
4. **Fatia vertical:** começamos por Fogo, Terra e Gravidade?
5. Os eixos dos 7 elementos fazem sentido, ou algum elemento tem outra especialização na sua cabeça?

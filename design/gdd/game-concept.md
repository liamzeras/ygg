# Ygg — Conceito do Jogo

> Status: rascunho v0.2 · 2026-11-16 · dono: Liam
> v0.2: visão nova de **magos de um elemento**, decidida pelo Liam em 2026-11-16. Pesquisa e
> justificativas em `design/sabio/inspiracao/magos-elementais.md`. As partes marcadas
> **[em transição]** descrevem o que o código ainda usa (Cavaleiro, Elementalista, Psiônico) e
> continuam valendo até as frentes trocarem o código.

## Overview (Visão geral)

RPG em primeira pessoa onde o mundo é físico e **sistêmico**: todo objeto é feito de um
material com propriedades (massa, inflamável, explosivo, condutor…) e a magia é força e estado
aplicados a essa física. **Todo personagem selecionável é um mago de um elemento só**: água,
fogo, terra, ar, natureza, eletricidade ou gravidade. O jogador luta contra outros jogadores e
contra monstros, e os monstros obedecem às mesmas leis. O jogo não é sobre feitos grandiosos, e
sim sobre **pequenos feitos sobre-humanos amplificados pela criatividade do jogador**.

## Player Fantasy (Fantasia do jogador)

"Eu domino um elemento e entendo como ele funciona de verdade. Num mundo que parece real, eu
venço porque pensei num jeito esperto de usar a lei do meu elemento e o que o outro mago deixou
para trás: a poça dele conduz o meu raio, o vento dele espalha o meu fogo."

## Pilares

1. **Crível antes de espetacular.** O mundo é semi-realista. O especial/mágico se destaca
   porque o fundo é normal. Mesmo sem magia, o personagem é notavelmente capaz, mas nunca
   absurdo: no máximo **5 a 10 vezes** um humano comum em qualquer atributo.
2. **Quanto mais surreal, mais limitado.** Efeitos que dobram a realidade (telecinese,
   fogo do nada) custam mais, alcançam menos e têm restrições claras. Força bruta é barata;
   mágica é cara. Gravidade e eletricidade, os elementos mais surreais, têm os limites mais
   claros (eletricidade só com condutor; gravidade drena Mana rápido e alcança pouco).
3. **Criatividade > números.** Uma ideia esperta deve valer mais que um atributo alto.
   As interações entre sistemas (fogo + madeira + pólvora + empurrão) são o conteúdo. Entre
   magos, **o rastro de um é o gancho do outro**.
4. **Legibilidade.** O jogador precisa entender por que algo aconteceu. Objetos mostram
   nome e peso, o boneco de testes mostra números, e materiais têm aparência consistente.

## Detailed Rules (Regras)

### Visão do jogo (decidida em 2026-11-16)

- **Começo:** o jogador começa **sem classe**. Depois de uma intro curta e de uma
  demonstração, escolhe o elemento na **escola de magos**. *Pendente: intro, demonstração e
  escola ainda não têm desenho.* Rumo sugerido pela pesquisa: a demonstração mostra a lei de
  cada elemento e os rastros entre elementos, e a escola deixa experimentar antes de escolher,
  se a escolha for permanente.
- **Um elemento por mago:** água, fogo, terra, ar, natureza, eletricidade ou gravidade. O mago
  só trabalha com as propriedades e transformações do seu elemento. Combinar elementos pode
  vir no futuro, mas o jogo não é feito pensando nisso.
- **O Cavaleiro sai do jogo.** Toda classe selecionável é um mago elemental.
- **Para todos os magos:** Vigor e Mana, dash (Ctrl), pulo duplo (Espaço 2x), a mesma
  velocidade de movimento, pegar e arremessar objetos (limite de carga pela Força). Andar
  empurra objetos.
- **Atributos:** Força, Agilidade, Vitalidade, Destreza, Inteligência, Sorte. Regras em
  `attributes.md`.
- **Mundo:** materiais madeira, metal, pedra e pólvora; braseiro como fonte de fogo do
  ambiente. Regras em `physics-magic-system.md`.

### Estrutura de cada elemento

1. **Lei do elemento:** uma regra física sempre ligada que todas as habilidades do elemento
   obedecem. A lei mora no mundo (calor, água, massa, carga), não no mago, para que os
   elementos conversem sem código especial entre eles.
2. **Eixo com 2 especializações:** as duas pontas de um eixo físico. Elas se combinam, mas
   ninguém fica nas duas pontas ao mesmo tempo.
3. **4 funções:** movimento, ataque, defesa e terreno. Todo elemento tem as 4; nenhum elemento
   vira um papel só ("água é o curandeiro" está proibido). Os verbos de movimento não se
   repetem entre elementos.
4. **Especializações pela opção C:** cada função tem uma versão de cada especialização
   (8 habilidades por elemento). O mago escolhe uma versão por função.
   - As 4 escolhas da mesma ponta dão a **maestria** daquela especialização, um efeito extra
     forte.
   - Escolhas misturadas são mais flexíveis, mas sem maestria.
   - **Nunca as duas maestrias.**
   - *Pendente: quando e onde o jogador troca as versões, e o que cada maestria faz.*

| Elemento | Lei (resumo) | Eixo: especialização ↔ especialização |
|---|---|---|
| Fogo | Calor acumula, espalha e consome combustível; precisa de ar | Chama ↔ Explosão |
| Água | Muda de estado com a temperatura, escorre, molha | Gelo ↔ Maré |
| Terra | Massa e permanência; só trabalha o solo e a pedra que existem ali | Rocha ↔ Areia |
| Ar | Pressão; só move o que já existe; alimenta o fogo | Vento ↔ Vácuo |
| Natureza | Crescer leva tempo e precisa de solo; tudo que cresce queima | Crescimento ↔ Podridão |
| Eletricidade | A corrente segue o condutor até o chão | Descarga ↔ Magnetismo |
| Gravidade | Muda peso e direção da queda, não cria matéria | Peso ↔ Leveza |

As habilidades de cada elemento estão em rascunho em
`design/sabio/inspiracao/magos-elementais.md`. Cada elemento ganha o próprio documento de
design quando entrar em produção.

### Rastros entre magos

Cada interação entre elementos tem dois lados, e nenhum elemento ganha sempre (nada de tabela
de tipos fixa). Exemplos: a poça d'água conduz o raio, mas o mago de água também se molha; o
vento espalha o fogo, que pode voltar contra o aliado. A tabela de elementos e materiais
(`design/sabio/inspiracao/tabela-elementos-materiais.md`) é a fonte dessas regras e vai crescer
para 7 x 7.

### Jogadores e monstros

- A batalha é **contra jogadores e contra monstros**.
- **Monstros seguem as mesmas leis:** um monstro de fogo acende madeira e é apagado pela lama.
  Monstros podem ser só material (um de madeira queima, um de metal conduz).
- Cada elemento tem pelo menos uma versão de defesa que funciona contra vários alvos.
- Controle (prender, atordoar) dura menos contra jogadores do que contra monstros, e o efeito
  aparece na tela para os dois lados.

### Fatia vertical: Fogo, Terra e Gravidade; Água em seguida

3 elementos x 8 habilidades = 24 (6 já existem). Entram na fatia a lei de cada elemento, as
2 maestrias de cada um e as interações entre eles. Por que estes três: já têm código e cobrem os
três tipos de lei (Fogo muda o estado do material, Terra depende do chão, Gravidade mexe em tudo
que tem massa).

| Hoje no código | Vira |
|---|---|
| Bola de Fogo | Fogo · ataque (Explosão) |
| Escada de Pedra | Terra · movimento (Rocha) |
| Lamaçal | Terra · terreno (Areia) |
| Flutuar, Telecinese, Campo Lento | Gravidade · movimento, ataque e defesa (Leveza) |
| Dardo Cinético | Ar · ataque (Vácuo), ou sai |
| Habilidades do Cavaleiro | Saem do jogo |

### [em transição] Classes que o código ainda usa

Até a frente `classes` trocar menu e código, o jogo ainda tem as 3 classes antigas. Valem como
estão para testes e para o teste de fumaça.

- **Classes iniciais:** Cavaleiro, Mago Elementalista e Mago Psiônico. *(Elementalista e
  Psiônico se dissolvem nos elementos Fogo, Terra e Gravidade; o Cavaleiro sai.)*
- **Mago:** se divide em **Elementalista** (elementos + manipulação de terreno) e **Psiônico**
  (sem elementos: acelerar, desacelerar, flutuar). Detalhes em `mage-elementalist.md` e
  `mage-psionic.md`.

#### [em transição] Cavaleiro (habilidades gastam Vigor) · sai do jogo

| Tecla | Habilidade | Escala com | Ideia |
|---|---|---|---|
| Botão esq. | Golpe de Escudo | Força | Cone de empurrão. Leves voam, pesados mal se mexem. |
| Q | Investida | Força | Arrancada no chão; o impacto é a quantidade de movimento (massa x velocidade). |
| F | Postura de Muralha | Vitalidade | Por alguns segundos ignora 85% dos empurrões e explosões, mas fica lento. |

#### [em transição] Mago Elementalista (magias gastam Mana) · vira Fogo e Terra

| Tecla | Habilidade | Escala com | Ideia |
|---|---|---|---|
| Botão esq. | Bola de Fogo (carregável) | Inteligência | Projétil em arco: explode, empurra e incendeia. |
| Q | Escada de Pedra | fixa | 3 pilares de 0,85, 1,70 e 2,55 m; o do meio na mira. Sobe com W. |
| F | Lamaçal | Inteligência | Lama: objetos param, fogo apaga, quem pisa fica lento. |

#### [em transição] Mago Psiônico · vira Gravidade (Leveza)

Dardo Cinético (carregável), Campo Lento (Q), Telecinese Acelerada (F) e Flutuar (segurar
Espaço caindo).

## Formulas (Fórmulas)

Ver `attributes.md` (atributo → valor físico) e `physics-magic-system.md` (calor,
explosões, impactos).

- **Habilidades por elemento:** `H = funções x especializações = 4 x 2 = 8`.
- **Escopo total:** `7 elementos x 8 = 56 habilidades`; fatia vertical `3 x 8 = 24`.
- **Maestria:** `maestria(ponta) = (as 4 versões escolhidas são da mesma ponta)`. Como o mago
  escolhe exatamente 1 versão por função, no máximo 1 maestria fica ativa.
- **Controle contra jogador:** `duração_jogador = duração_base x fator_jogador`, com
  `fator_jogador < 1`. *Pendente: valor do fator.*

## Edge Cases (Casos-limite)

- Objeto segurado preso atrás de parede: solta sozinho se se afastar mais que
  distância de segurar + 2,5 m.
- Mana zera durante a telecinese: o objeto cai e aparece o aviso "Mana esgotada".
- Cair do mapa: o jogador volta ao ponto inicial e os objetos abaixo de -50 m somem.
- **Terreno pobre:** Terra e Natureza dependem do chão; numa arena só de metal ficam sem
  material. Cada arena precisa de variedade de materiais.
- **Escolhas misturadas:** um mago com 2 versões de cada ponta não tem maestria nenhuma, mas
  todas as habilidades funcionam normalmente.
- **Interação que só ajuda um lado:** proibida; se surgir no playtest, ganha um custo para quem
  se beneficia.

## Dependencies (Dependências)

Atributos → Jogador → Habilidades (lei do elemento) → Física/Materiais → HUD (somente por
sinais). Monstros usam as mesmas Habilidades e a mesma Física. A escolha de elemento depende da
escola de magos (ainda sem desenho).

## Tuning Knobs (Ajustes)

Tudo em `assets/data/`: `attribute_rules.tres`, `classes/*.tres` (atributos e habilidades)
e `materials/*.tres`. Dá para editar no Inspetor do Godot sem tocar em código. Ajustes novos
previstos: efeito de cada maestria, `fator_jogador` do controle, custo e janela de
vulnerabilidade dos verbos de movimento.

## Acceptance Criteria (Critérios de aceite)

### Fatia vertical nova (Fogo, Terra e Gravidade)

- [ ] O jogador começa sem classe e escolhe o elemento na escola de magos.
- [ ] Cada um dos 3 elementos tem as 8 habilidades (4 funções x 2 especializações).
- [ ] Escolher as 4 versões da mesma ponta ativa a maestria; nunca ficam 2 maestrias ativas.
- [ ] A lei de cada elemento vale para jogador e monstro (teste automatizado).
- [ ] Playtest: Fogo, Terra e Gravidade resolvem o mesmo obstáculo de formas diferentes.
- [ ] Playtest: um jogador novo usa o rastro de outro mago a seu favor sem explicação.

### Continuam valendo

- [ ] Um jogador novo entende, sem explicação, que madeira queima e pólvora explode.
- [ ] O boneco de testes mostra o impulso de cada habilidade e a comparação com um humano.
- [ ] Nenhuma habilidade passa de ~10x o equivalente humano com atributos no teto.

### [em transição] Fatia antiga (até o código trocar de classes)

- [ ] Do menu principal ao jogo em até 3 cliques (Novo Jogo → classe → jogar).
- [ ] As classes usam as 3 habilidades sem erro (teste de fumaça automatizado).

## Fora do escopo agora

Inventário, missões, mundo aberto real, arte final, áudio. Inimigos de verdade estão começando
(o bot de teste do F6, ver `combat-bot.md`, liberou a frente `monstros`). Elementos fora da
fatia vertical (Água, Ar, Natureza, Eletricidade) ficam só em design até a fatia fechar; a Água
é a próxima. O campo `conductive` já existe nos materiais. Combinar elementos num mesmo mago
também fica de fora.

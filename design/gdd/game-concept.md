# Ygg — Conceito do Jogo

> Status: rascunho v0.2 · 2026-11-16 · dono: Liam
> Mudança da v0.2: visão dos magos de um elemento, decidida pelo Liam em 2026-11-16. As 3 classes antigas
> (Cavaleiro, Elementalista, Psiônico) saem. Pesquisa e proposta completas do Sábio em
> [`design/sabio/inspiracao/magos-elementais.md`](../sabio/inspiracao/magos-elementais.md) (referência; este
> documento leva só as decisões).

## Overview (Visão geral)

RPG de mundo aberto em primeira pessoa onde **todo personagem é um mago de um só elemento**: água, fogo,
terra, ar, natureza, eletricidade ou gravidade. O mundo é físico e **sistêmico**: todo objeto é feito de um
material com propriedades (massa, inflamável, explosivo, condutor…) e cada magia é uma força ou um estado
aplicado a essa física. Cada elemento obedece a uma **lei física** própria, e o que um mago deixa no mundo (poça,
fogo, pedra, vento) vira ferramenta para outro mago, aliado ou inimigo. A batalha é contra **jogadores e
monstros**, e os monstros seguem as mesmas leis. O jogo não é sobre feitos grandiosos, e sim sobre **pequenos
feitos sobre-humanos amplificados pela criatividade do jogador**.

## Player Fantasy (Fantasia do jogador)

"Eu domino um elemento e entendo como ele funciona de verdade. Num mundo que parece real, resolvo problemas e
venço lutas porque pensei num jeito esperto de usar o meu elemento e o que estava à mão: secar a lama com fogo,
erguer pedra onde havia chão, deixar o inimigo leve e jogá-lo longe. Quando outro mago passa por mim, o rastro
dele vira a minha chance."

## Pilares

1. **Crível antes de espetacular.** O mundo é semi-realista. O mágico se destaca porque o fundo é normal. Mesmo
   sem magia, o personagem é notavelmente capaz, mas nunca absurdo: no máximo **5 a 10 vezes** um humano comum
   em qualquer atributo.
2. **Quanto mais surreal, mais limitado.** Efeitos que dobram a realidade custam mais, alcançam menos e têm
   restrições claras. Gravidade e eletricidade são os elementos mais surreais e têm os limites mais claros
   (eletricidade só onde há condutor; gravidade drena Mana rápido e tem alcance curto).
3. **Criatividade > números.** Uma ideia esperta vale mais que um atributo alto. As interações entre elementos e
   materiais (fogo + madeira + vento, água + raio) são o conteúdo. **O rastro de um mago é o gancho do outro.**
4. **Legibilidade.** O jogador precisa entender por que algo aconteceu. Objetos mostram nome e peso, o boneco de
   testes mostra números, materiais têm aparência consistente, e cada elemento se explica pela sua lei, não por
   uma tabela escondida.
5. **Toda interação tem dois lados.** Nenhum elemento ganha sempre de outro. A água apaga o fogo, mas o fogo a
   transforma em vapor que tira a visão. Isso evita a "tabela de tipos" e o combo fixo que todo mundo copia.

## Loop principal

- **Momento a momento (segundos):** ler o terreno e os materiais em volta → escolher entre movimento, ataque,
  defesa e terreno do meu elemento → ver a física responder → aproveitar o rastro que ficou (meu ou de outro
  mago).
- **Encontro (minutos):** enfrentar um monstro, um grupo de monstros ou um jogador. Cada um pede uma solução
  diferente: monstros de material (madeira queima, metal conduz) e monstros de elemento (obedecem à mesma lei de
  um mago).
- **Progressão (horas):** ajustar a escolha das versões das 4 funções, buscar a maestria de uma especialização
  ou ficar no estilo misto, e aprender como o meu elemento conversa com os outros.

## Detailed Rules (Regras)

### Começo do jogo: a escola de magos

- O jogador começa **sem classe**.
- Depois de uma **intro curta** e de uma **demonstração**, escolhe o elemento na **escola de magos**.
- A intro e a demonstração serão desenhadas depois (ver Perguntas abertas). O Sábio sugere que a demonstração
  mostre a lei de cada elemento e os rastros entre elementos, e que a escola deixe experimentar antes de decidir.

### O mago de um elemento

- Cada mago domina **um só elemento** e só trabalha com as propriedades e transformações dele.
- Cada elemento tem:
  - uma **lei**: a regra física sempre ligada, que todas as habilidades dele obedecem e que mora no mundo, não no
    mago;
  - um **eixo físico** com **2 especializações**, uma em cada ponta (exemplo: Fogo vai de Chama, lenta e em área,
    a Explosão, rápida e concentrada).
- Todo mago tem **4 funções**: **movimento, ataque, defesa e terreno**, com a cara do elemento.
- **Cada função tem 2 versões**, uma de cada especialização. O mago escolhe **uma versão por função**.
- **Maestria (opção C, escolhida em 2026-11-16):**
  - as 4 escolhas da mesma ponta → ganha a **maestria** dessa especialização, um efeito extra forte;
  - escolhas misturadas → mais flexível, sem maestria;
  - **nunca as duas maestrias ao mesmo tempo.**
- O verbo de movimento de cada elemento é diferente dos outros (nenhum se repete).
- **Todos os magos** têm Vigor e Mana, dash (Ctrl), pulo duplo (Espaço 2x) e a mesma velocidade de movimento.
- Combinar elementos pode vir no futuro, mas o jogo não é desenhado pensando nisso.

### Os 7 elementos

Elemento, lei e eixo de cada um estão propostos pelo Sábio em
[`magos-elementais.md`](../sabio/inspiracao/magos-elementais.md#os-7-elementos). **Só os da fatia vertical estão
decididos**; o resto é rascunho até o Liam aprovar (ver Perguntas abertas). As habilidades de cada elemento ficam
nos GDDs de elemento da frente `classes`.

| Elemento | Situação | Ideia da lei (resumo) |
|---|---|---|
| Fogo | fatia vertical | Calor acumula, espalha e consome combustível; precisa de ar |
| Terra | fatia vertical | Massa e permanência; só trabalha o solo e a pedra que existem ali |
| Gravidade | fatia vertical | Muda peso e direção da queda de tudo que tem massa; não cria matéria |
| Água | logo depois da fatia | Muda de estado com a temperatura, escorre, molha |
| Ar, Natureza, Eletricidade | depois | ver material do Sábio |

### Rastro de um, gancho do outro

- O que um mago deixa no mundo (calor, água, massa, carga, vento) é estado do mundo, e qualquer outro mago ou
  monstro pode usar. Vale para aliados e inimigos.
- **Regra de ouro:** cada interação tem dois lados (pilar 5).
- Exemplos e a tabela proposta: seção "Rastro de um, gancho do outro" do material do Sábio. A fonte das regras
  passa a ser a [tabela de elementos e materiais](../sabio/inspiracao/tabela-elementos-materiais.md), que precisa
  crescer para 7 x 7.

### Jogadores e monstros

- A batalha é **contra jogadores e contra monstros** (monstros com IA liberados em 2026-11-13; ver
  `combat-bot.md`).
- **Monstros obedecem às mesmas leis** do jogador: um monstro de fogo acende madeira e é apagado pela lama. Quem
  aprende a lutar contra monstros aprende a lutar contra jogadores.
- **Monstros podem ser só material**, sem elemento (madeira queima, metal conduz).
- **Defesas servem aos dois casos:** cada elemento precisa de pelo menos uma versão de defesa que funcione contra
  vários alvos.
- **Controle com dois limites:** a mesma habilidade de prender ou atordoar dura menos contra jogadores, e o efeito
  aparece na tela para os dois lados. (Proposta do Sábio; os números ficam para os GDDs de elemento.)
- **Equilíbrio olha para dois lugares:** um elemento pode ser fraco no duelo e forte contra grupos, desde que
  ninguém seja fraco nos dois.

### Base que continua

- **Atributos**: Força, Agilidade, Vitalidade, Destreza, Inteligência, Sorte. Regras em `attributes.md`.
- **Interação básica**: qualquer mago pega objetos com as mãos (limite de carga pela Força) e arremessa. Andar
  empurra objetos.
- **Mundo**: materiais madeira, metal, pedra e pólvora; braseiro como fonte de fogo do ambiente. Regras em
  `physics-magic-system.md`.
- **O Cavaleiro sai do jogo** (decidido em 2026-11-16): toda classe selecionável é um mago elemental. Tirá-lo do
  menu e do código é trabalho da frente `classes`. Os GDDs `mage-elementalist.md` e `mage-psionic.md` descrevem
  as classes antigas e serão substituídos pelos GDDs de elemento.

### Fatia vertical: Fogo, Terra e Gravidade

São 3 elementos x 8 habilidades = **24 habilidades**. **6 já existem** no código e mudam de lugar:

| Elemento | Já existe (vira) | Faltam |
|---|---|---|
| Fogo | Bola de Fogo (ataque, Explosão) | 7 |
| Terra | Escada de Pedra (movimento, Rocha); Lamaçal (terreno, Areia) | 6 |
| Gravidade | Flutuar (movimento), Telecinese (ataque), Campo Lento (defesa), todos da Leveza | 5 |

Também entram na fatia: a **lei** de cada um dos 3 elementos, as **2 maestrias** de cada um e as **interações
entre eles** (Gravidade e Terra; Fogo e Terra). **Água vem em seguida** (já tem módulos no laboratório).

**Por que estes três:** já têm código e cobrem os três tipos de lei: o Fogo muda o estado do material, a Terra
depende do chão e a Gravidade mexe em tudo que tem massa.

## Formulas (Fórmulas)

- **Maestria:** `maestria_ativa(e) = (versões escolhidas da ponta e) == 4`, onde `e` é uma das 2 especializações
  e há 4 funções. Como cada função tem uma só versão escolhida, no máximo uma ponta chega a 4. Exemplo: Fogo com
  Explosão em movimento, ataque, defesa e terreno → maestria da Explosão; com 3 de Explosão e 1 de Chama → sem
  maestria.
- **Tamanho do kit:** `habilidades = elementos x 4 funções x 2 versões`. Jogo completo: 7 x 8 = 56. Fatia
  vertical: 3 x 8 = 24.
- Atributo → valor físico: `attributes.md`. Calor, explosões e impactos: `physics-magic-system.md`.

## Edge Cases (Casos-limite)

- Objeto segurado preso atrás de parede: solta sozinho se se afastar mais que distância de segurar + 2,5 m.
- Mana zera durante uma magia contínua (exemplo: telecinese): o efeito para, o objeto cai e aparece o aviso
  "Mana esgotada".
- Cair do mapa: o jogador volta ao ponto inicial e os objetos abaixo de -50 m somem.
- Escolhas misturadas: nenhuma maestria fica ativa; o mago usa as 4 versões normalmente.
- Terreno sem o material que o elemento pede (exemplo: Terra numa arena toda de metal): o elemento fica com pouco
  ou nada para trabalhar. Por isso as arenas precisam de variedade de materiais. O que a habilidade faz nesse caso
  (falha com aviso, efeito menor) fica para os GDDs de elemento.
- Monstro e jogador atingidos pelo mesmo controle: cada um recebe a duração do seu caso (menor para jogador).

## Dependencies (Dependências)

Atributos → Jogador (mago) → Habilidades do elemento → Física/Materiais → HUD (somente por sinais).

- **GDDs de elemento** (frente `classes`, a criar): detalham lei, eixo, as 8 habilidades e as 2 maestrias de cada
  elemento.
- **Monstros** (frente `monstros`, `combat-bot.md`): usam as mesmas leis e habilidades.
- **Tabela de elementos e materiais** (Sábio): fonte das interações entre elementos.
- **Escola de magos** (a desenhar): menu de escolha de classe e começo do jogo.

## Tuning Knobs (Ajustes)

Tudo em `assets/data/`: `attribute_rules.tres`, `classes/*.tres` (atributos e habilidades) e `materials/*.tres`.
Dá para editar no Inspetor do Godot sem tocar em código. Os ajustes de cada elemento (custo, alcance, força da
maestria, duração de controle contra jogador e contra monstro) serão definidos nos GDDs de elemento.

## Acceptance Criteria (Critérios de aceite da fatia vertical)

- [ ] O Cavaleiro não aparece em nenhum menu nem no jogo; só magos elementais são selecionáveis.
- [ ] O jogador começa sem classe e escolhe Fogo, Terra ou Gravidade.
- [ ] Cada um dos 3 elementos tem as 8 habilidades (4 funções x 2 versões) e funciona sem erro no teste de
      fumaça automatizado.
- [ ] Escolher as 4 versões da mesma ponta ativa a maestria dela; trocar uma só versão desativa. Nunca as duas
      ficam ativas.
- [ ] Os verbos de movimento de Fogo, Terra e Gravidade são diferentes entre si.
- [ ] Pelo menos uma interação entre elementos da fatia funciona nos dois sentidos (exemplo: lama apaga fogo;
      fogo seca lama).
- [ ] Um monstro de material e um monstro de elemento reagem às mesmas leis que o jogador.
- [ ] Um jogador novo entende, sem explicação, que madeira queima e pólvora explode.
- [ ] O boneco de testes mostra o impulso de cada habilidade e a comparação com um humano.
- [ ] Nenhuma habilidade passa de ~10x o equivalente humano com atributos no teto.
- [ ] Playtest: magos de Fogo, Terra e Gravidade resolvem o mesmo obstáculo de formas diferentes.

## Fora do escopo agora

Água, Ar, Natureza e Eletricidade como elementos jogáveis (Água é a próxima); combinar elementos num mesmo mago;
intro e demonstração da escola de magos (a desenhar); inventário; missões; mundo aberto real; arte final; áudio.
Monstros com IA **saíram desta lista** em 2026-11-13.

## Perguntas abertas para o Liam

Estas escolhas ainda não foram feitas. O documento não decide nenhuma delas.

1. **Eixos dos 7 elementos:** os eixos propostos pelo Sábio (Fogo: Chama ↔ Explosão; Água: Gelo ↔ Maré; Terra:
   Rocha ↔ Areia; Ar: Vento ↔ Vácuo; Natureza: Crescimento ↔ Podridão; Eletricidade: Descarga ↔ Magnetismo;
   Gravidade: Peso ↔ Leveza) fazem sentido, ou algum elemento tem outra especialização na sua cabeça?
2. **Efeito de cada maestria:** o que a maestria de cada especialização faz? (O Sábio sugere, por exemplo, que a
   da Leveza seja o "campo guarda o momento".)
3. **Quando e onde trocar versões:** o jogador troca as versões das funções a qualquer momento, só em certos
   lugares (como a escola), ou com algum custo?
4. **Intro e demonstração da escola:** como são a intro curta e a demonstração antes da escolha? O elemento
   escolhido é permanente? O jogador pode experimentar antes de decidir?

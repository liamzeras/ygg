# Jogos sistêmicos: lições e alertas

> Consultado em 2026-11-01. Primeira leva; aprofundar conforme a demanda.

## Zelda: Breath of the Wild (Nintendo, GDC 2017)

**O que a fonte diz:** o jogo tem um "motor de química", um calculador de **estados** baseado em
regras, separado da física, que calcula **movimento**. Elementos (fogo, água, gelo, vento,
eletricidade) não têm estado fixo; materiais são sólidos (árvore, rocha, jogador). São três regras:

1. Elementos mudam o estado de materiais.
2. Elementos mudam o estado uns dos outros.
3. Materiais não mudam o estado uns dos outros.

A equipe também defendeu "mentiras" controladas na física e consistência para ganhar a confiança do
jogador. [Thumbsticks](https://www.thumbsticks.com/gdc-17-breath-of-the-wild-science-lies)

**Para o Ygg:** é a lição mais direta da leva.

- O Ygg já faz essa separação na prática: `PhysicsProp` e empurrões de um lado, calor e fogo do outro.
- A densidade "de jogo" do Ygg é uma dessas mentiras úteis, então estamos em boa companhia.
- A regra 3 evita explosão combinatória: em vez de programar "caixa + barril", criamos "fogo + o que
  queima". Cada material novo funciona com tudo que já existe.
- Sugestão: oficializar essas 3 regras no GDD e criar a tabela elemento × material.

## Divinity: Original Sin 2 (Larian)

**O que a fonte diz:** o jogo começou como protótipo de arena para testar sistemas e combinações. A
IA eletrificava e congelava água e explodia poças de óleo e veneno, então, segundo o designer de
combate, dava para aprender **só de assistir**. Vincke admitiu que haveria muitas combinações que
talvez nunca fossem vistas. Em contrapartida, um programador de scripts pediu que os momentos de
história nunca mais interagissem entre si.
[PC Gamer](https://www.pcgamer.com/uk/the-making-of-divinity-original-sin-2)

**Para o Ygg:**

- **Inimigos são professores.** Se um inimigo acende um barril perto de você, isso ensina mais que um
  tutorial. Isso conversa com o critério "um jogador novo entende sem explicação".
- A arena de testes atual é o mesmo método que a Larian usou. Vale mantê-la.
- **Alerta:** sistemas soltos custam barato; conteúdo roteirizado que interage com tudo custa caro.
  Mantenha a interação nas regras do mundo, não em casos especiais de história.

## Noita (Nolla Games)

**O que a fonte diz:** Petri Purho disse que os problemas técnicos tinham solução e que as verdadeiras
dificuldades estavam no design: se os jogadores entenderiam o jogo e se seria difícil ou frustrante
demais. Ele contou o caso do corpo de um inimigo que quebrou um lampião de óleo e o incendiou.
[Game Developer](https://www.gamedeveloper.com/game-platforms/road-to-the-igf-nolla-games-i-noita-i-)

Lacuna: não encontrei o conteúdo da palestra "Exploring the Tech and Design of Noita".

**Para o Ygg:**

- **Alerta de frustração:** morrer por uma reação em cadeia que você não viu chegar parece injusto.
  Mostrar a causa com clareza é o pilar de Legibilidade. Para o Liam e o QA, um critério testável:
  "depois de cada dano grande, o jogador sabe dizer o que causou?"

## Prey (Arkane, 2017)

**O que a fonte diz:** o Canhão GLOO atira glóbulos de cola que imobilizam inimigos ou viram blocos
para cobertura e escalada, inclusive para abrir caminhos alternativos. A equipe diz evitar "design de
poltrona" e jogar para achar soluções inesperadas. Críticas: uma análise diz que, em boa parte do
jogo, não teve liberdade para enfrentar o combate como queria, e outra lembra que a história ainda
exige um caminho crítico.
[PC Gamer](https://www.pcgamer.com/au/prey-channels-the-spirit-of-system-shock) ·
[GameSpot](https://www.gamespot.com/reviews/prey-review/1900-6416678/) ·
[Prima Games](https://primagames.com/gaming/prey-review)

**Para o Ygg:**

- **Uma ferramenta, vários verbos.** O GLOO prende, protege e constrói. A Teia do Ygg poderia seguir
  esse caminho, e a Escada de Pedra já é um exemplo.
- **Alerta:** liberdade no papel não basta. Se recursos escassos obrigam a jogar sempre do mesmo jeito,
  a criatividade morre. O preço dos reagentes precisa ser testado com esse olho.

## Lacunas para a próxima pesquisa

- Críticas à sobrecarga de superfícies e ao sistema de armadura de Divinity: não achei fonte boa.
- Palestra de Noita completa.
- Lições de Warren Spector e Harvey Smith sobre imersive sims.
- Outros candidatos: Dwarf Fortress, Ultima Online, Magicka, Tears of the Kingdom.

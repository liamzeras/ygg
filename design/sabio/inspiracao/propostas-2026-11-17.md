# Propostas para o Liam: sim ou não

> Sábio, 2026-11-17. Junta as propostas de três pesquisas pedidas pelo Liam através do orquestrador:
> [próximos elementos](proximos-elementos.md), [combos da fatia](combos-da-fatia.md) e
> [avaliação pela filosofia da Riot](avaliacao-riot.md). Conferi no código os itens marcados com ✔.
> O que for aprovado volta ao orquestrador como pedido para a frente dona.

## Consertos (o jogo faz algo que ninguém decidiu)

| # | Proposta | Por quê | Frente |
|---|---|---|---|
| 1 | **Gravidash respeita o peso** do que carrega | ✔ Hoje joga qualquer objeto a 16 m/s, até um bloco de 605 kg (`gravidash_ability.gd:78-80`) | classes |
| 2 | **Tiro rebatido pelo Push-Pull troca de dono** | ✔ Hoje a Bola de Fogo rebatida atravessa quem a lançou, porque continua ignorando essa pessoa (`fireball_ability.gd:50`, `push_pull_ability.gd:77`) | classes |
| 3 | **Explosão racha a Escada de Pedra e o relevo do Terremoto** | ✔ O pilar não é atingido por explosão (`explosion.gd:79`), só serve de cobertura. Isso contradiz o GDD de física | gameplay |

## Contrajogo (o outro lado precisa poder reagir)

| # | Proposta | Por quê | Frente |
|---|---|---|---|
| 4 | **Terremoto avisa 0,6 a 0,8 s antes** de lançar e ferir | ✔ Hoje lança e fere ao nascer, sem aviso | classes e arte |
| 5 | **Almôndega de Fogo vira escolha:** sem atacar com fogo enquanto está ativa, anel mostrando o tempo e recarga contando só depois que acaba | ✔ São 3 s sem levar dano a cada 8 s | classes e interface |
| 6 | **Zona Nula deixa todos os magos com socos e chutes**, com borda visível e som | Hoje só o mago da Gravidade continua lutando dentro dela | classes, arte e áudio (som só no papel) |
| 7 | **Chão de Lava com aviso na borda** e recarga contando só depois que acaba | Área de dano longa e sem aviso | classes e arte |

## Legibilidade (o jogador entender o que aconteceu)

| # | Proposta | Por quê | Frente |
|---|---|---|---|
| 8 | **Mostrar na tela os números escondidos:** carga do Push-Pull e do Gravidade dos Sonhos, revestimento da Terra, cargas do Gravidash | Hoje o jogador não vê o que muda o resultado | interface e arte |
| 9 | **Três sinais visuais:** lava coberta por lama deixa de ficar vermelha, o Fogo-Fátuo ganha cor própria (hoje é quase o azul do Dardo), e objetos pesados ou quentes ficam reconhecíveis | Divergências e cores parecidas confundem | arte |

## Próximos elementos

| # | Proposta | Por quê | Frente |
|---|---|---|---|
| 10 | **Água entra na fila**, começando por Alagar e Congelar o chão, que custam pouco e reaproveitam o laboratório | É a próxima da fila e a mais pronta | classes |
| 11 | **"Molhado conduz" vira regra do mundo**, valendo também para personagens e monstros | Base para a Eletricidade e para os combos com Água | gameplay |
| 12 | **Aceitar 3 trocas de verbo de movimento:** Ar puxa o mago na horizontal (sucção), em vez do super salto; Natureza fica só com o balanço de cipó; Eletricidade empurra o mago para longe do metal, em vez de puxar até ele | Os verbos antigos repetiam o trampolim da Natureza e o gancho de outros | classes |

## Decisões de regra (sim ou não, sem trabalho grande)

| # | Pergunta | Frente |
|---|---|---|
| 13 | A lama apaga a queimadura do Fogo-Fátuo? O código diz que sim, e o `mage-fire.md` diz que não | classes |
| 14 | O Lamaçal deixa o próprio dono lento? | classes |
| 15 | O Gravidash é uma exceção à regra "o dash saiu das classes"? | classes |
| 16 | Quem cria uma poça elétrica leva choque se estiver nela? É uma exceção à regra "quem conjura não se queima com o que criou" | gameplay |

## Recomendação do Sábio

Se a resposta for curta: **sim para 1 a 5 e para 10.** Os consertos e o contrajogo mudam como a luta é sentida, e a
Água mantém a fila andando. O resto pode esperar a próxima conversa.

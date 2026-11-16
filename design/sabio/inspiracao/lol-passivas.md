# League of Legends: a filosofia das passivas aplicada às ativas do Ygg

> Fichamento do Sábio, 2026-11-13. Frente: Inspiração. Semáforo: 🟢 em tudo, porque só usamos padrões de
> regra, sem nomes, textos ou números do LoL. Nada aqui é decisão: as propostas esperam o Liam.
>
> **Revisto em 2026-11-16:** a visão mudou para magos de um elemento só. A abordagem e o destino das 6 ideias
> estão em [magos-elementais.md](magos-elementais.md). A pesquisa abaixo continua válida.

## Resumo em uma frase

No LoL, a passiva é a **cola do kit**: uma regra sempre ligada que dá ritmo, junta as habilidades entre si
e põe a fantasia do personagem em jogo. O Ygg não tem espaço de passiva, mas pode dar a cada ativa uma
**camada passiva**: algo que ela deixa no mundo e algo do mundo a que ela reage.

## O que as fontes dizem

A Riot não publicou uma "regra das passivas". O que existe são falas soltas de designers e as mecânicas em si.

- **Passiva como cola.** O designer do Locke chamou a passiva dele de *glue ability*: dá o que fazer enquanto
  o resto do kit recarrega e ajuda a terminar alvos com pouca vida
  ([rft.gg, 2026](https://rft.gg/news/locke-abilities-lol-new-champion-breakdown)) `[fonte fraca]`.
- **Passiva define um padrão de jogo.** No Jhin, a passiva é o padrão de curta distância: entrar e sair do
  alcance para encaixar os tiros, em contraste com o padrão de longa distância do W e da ultimate
  ([PCGamesN](https://www.pcgamesn.com/league-of-legends/designing-a-league-of-legends-champion-sometimes-you-get-vayne-and-sometimes-you-get-yorick)).
- **Fantasia primeiro.** A Riot começa pela fantasia central e cria limites para perceber quando um kit se
  afasta dela ([/dev: Illaoi](https://www.riotgames.com/en/news/dev-illaoi-in-project-l)).
- **Arquitetura.** Passivas vivem num objeto separado das magias. Quando a Mel passou a refletir magias de
  outros campeões, quebrou tudo que supunha "quem lança tem a passiva"
  ([Riot Tech Blog: Mel](https://www.riotgames.com/en/news/mel-reflect-tech-blog)).
- **Restrição que vira castigo.** A passiva antiga da Cassiopeia (sem botas) foi refeita porque "às vezes
  parecia uma punição em vez de uma vantagem" ([Patch 26.1](https://www.leagueoflegends.com/en-us/news/game-updates/patch-26-1-notes/)).

### Mecânicas fichadas

| Campeão | Passiva | Padrão |
|---|---|---|
| Qiyana | Pega um elemento do terreno (rio, mato ou terreno sólido) e ele muda o efeito das habilidades ([site oficial](https://leagueoflegends.com/en-gb/champions/qiyana/)) `[fonte fraca: as fontes divergem nos detalhes]` | **O mundo é o recurso** |
| Taliyah | Corre mais perto de paredes; o chão onde ela usa a magia fica "trabalhado" e a mesma magia ali sai mais fraca ([wiki](https://wiki.leagueoflegends.com/en-us/Taliyah/Development), [dodge.gg](https://www.dodge.gg/lol/news/taliyah-build-2026)) | **O mundo guarda o que você fez** |
| Zyra | Sementes nascem no chão; uma magia lançada perto de uma semente faz brotar uma planta. Inimigos podem pisar e destruir a semente ([site oficial](https://www.leagueoflegends.com/champions/zyra/)) | **Uma ativa deixa rastro, outra usa** |
| Brand | Magias acendem o alvo; 3 acúmulos fazem ele explodir depois de 2 s, e a explosão acende quem está perto ([wiki](https://wiki.leagueoflegends.com/en-us/Brand?oldid=3892019)) | **Acúmulo que vira evento** |
| Jhin | 4 balas; a 4ª é crítica garantida; depois, recarga que deixa uma janela vulnerável ([dodge.gg](https://www.dodge.gg/lol/news/jhin-build-2026)) | **Ritmo com respiro** |
| Annie, Sona, Vayne | A cada 4 magias, a próxima atordoa; 3 magias fortalecem o próximo ataque; o 3º acerto seguido causa dano extra `[memória, a confirmar]` | **Contador visível** |
| Garen, Rengar | Recupera vida fora de combate; salta do mato sobre o alvo `[memória, a confirmar]` | **Fantasia virando regra** |

## Os 6 padrões

1. **O mundo é o recurso** (Qiyana, Taliyah). O lugar onde você está muda o que a habilidade faz.
2. **Rastro e gancho** (Zyra, Taliyah). Uma ativa deixa algo no mundo e outra reage a ele. O kit vira uma
   frase, não uma lista de botões.
3. **Acúmulo que vira evento** (Brand). Pequenas aplicações somam até virar algo grande e visível.
4. **Ritmo com respiro** (Jhin). A força tem um tempo certo e uma janela de fraqueza. Isso cria decisão para
   quem usa e chance de reação para quem enfrenta.
5. **Contador visível** (Annie, Sona, Vayne). O jogador conta junto e planeja o próximo passo.
6. **Fantasia virando regra** (Garen, Rengar). Uma frase do personagem ("ataca da emboscada") vira mecânica.

### Onde isso dá errado

- **Passiva invisível.** Um bônus sempre ligado sem sinal na tela parece não existir. Guias de design pedem
  um aviso visual ou sonoro ([superpowersgenerator](https://superpowersgenerator.com/passive-skill-creator/)) `[fonte fraca]`.
- **Restrição como castigo.** O caso da Cassiopeia acima.
- **Peso de balanceamento.** Passiva forte vira o centro do personagem e difícil de equilibrar. Exemplo: a
  passiva da Lissandra, que voltou à versão anterior no patch 9.7
  ([vídeo](https://www.youtube.com/watch?v=2ZfHX0QwZPA)) `[fonte fraca]`.
- **Excesso de regra.** Kits com muitas exceções viram leitura obrigatória antes de jogar `[memória, a confirmar]`.

## Por que funciona, e o que muda no Ygg

O LoL não tem física. Por isso, ele inventa **pilhas e contadores** para que uma ação lembre a anterior.
**O Ygg já tem essa memória na física:** calor acumulado até acender, umidade, momento, objetos que ficam no
chão. O Brand precisa de "3 acúmulos"; no Ygg, três Bolas de Fogo já aquecem uma caixa até ela pegar fogo.

Daí sai a regra principal desta pesquisa:

> **Troque pilhas por grandezas.** Se uma ativa precisa lembrar algo, guarde isso no mundo (calor, água,
> momento, um objeto, o estado do chão), não num número escondido no jogador.

Isso respeita os pilares: **crível** (é física), **legível** (dá para ver no mundo) e **criatividade**
(qualquer fonte da mesma grandeza serve: um braseiro aquece como uma Bola de Fogo). Também resolve o problema
da Mel: o gancho mora no mundo, então funciona com a magia de qualquer classe ou de um monstro.

## Proposta: toda ativa com três camadas

| Camada | Pergunta | Exemplo atual |
|---|---|---|
| **Verbo** | O que ela faz quando aperto? | Bola de Fogo: explode, empurra, aquece |
| **Rastro** | O que fica no mundo depois? | Lamaçal: a lama fica 4 s no chão |
| **Gancho** | A que coisa do mundo ou do kit ela reage? | Lamaçal apaga fogo |

**Limites do gancho**, para não cair nos erros acima:

- No máximo **um gancho por ativa**, e ele precisa ter um sinal na tela (cor, partícula, som).
- O gancho **abre opção**, nunca proíbe. Se a ativa não encontra o gancho, funciona normalmente.
- O gancho segue a física ou a tabela de elementos. Nada de "x2 porque sim".

### Como as ativas atuais se saem

| Classe | Ativa | Rastro | Gancho | Nota |
|---|---|---|---|---|
| Elementalista | Bola de Fogo | Calor, fogo | Acende o que está quente | ✅ completa |
| Elementalista | Escada de Pedra | Pilares por 8 s | Arremessa o que está em cima | ✅ completa |
| Elementalista | Lamaçal | Lama por 4 s | Apaga fogo, freia | ✅ completa |
| Psiônico | Dardo Cinético | Nenhum | Nenhum | ⚠️ só verbo |
| Psiônico | Campo Lento | Bolha por 4 s | Nenhum próprio | ⚠️ falta gancho |
| Psiônico | Telecinese | Nenhum | Nenhum | ⚠️ só verbo |
| Psiônico | Flutuar | Nenhum | Nenhum | ⚠️ só verbo |
| Cavaleiro | Golpe de Escudo | Nenhum | Massa do alvo | 🟡 gancho fraco |
| Cavaleiro | Investida | Nenhum | Massa x velocidade | 🟡 gancho fraco |
| Cavaleiro | Postura de Muralha | Nenhum | Nenhum | ⚠️ só verbo |

O Elementalista já segue a filosofia, porque nasceu da tabela de elementos. O Psiônico e o Cavaleiro são onde
a ideia mais rende.

## Ideias para o Ygg

Status: 💡 proposta. Todas são 🟢 no semáforo. "Surreal" indica o pilar 2: quanto mais dobra a realidade,
mais limite precisa.

### P1. Recuo do Dardo no ar (Psiônico) 💡

**Padrão:** fantasia virando regra. **Pilares:** crível, criatividade.

Disparar o Dardo enquanto flutua empurra o Psiônico para trás, como a terceira lei de Newton. No chão, o atrito
segura e nada muda. Vira manobra: atirar para baixo para subir um pouco, atirar para trás para avançar.

- **Cuidado com a conta:** o dardo tem 7 g. O recuo real, a 60 m/s, seria 0,42 N·s, o que tira só 0,005 m/s
  de alguém com 80 kg, ou seja, nada. Para ser sentido, o recuo precisa usar o impulso de impacto do dardo
  (`materialized_impulse`), que já é maior que a conta pura. A explicação: a mente empurra o dardo e é
  empurrada de volta. Fica menos crível, mas ainda legível.
- **Limite:** só funciona no ar (flutuando ou caindo) e com carga acima da metade.
- **Teste:** flutuando parado, disparar com carga cheia para baixo. O Psiônico precisa parar de descer por
  um instante, sem subir mais de 0,5 m (o Liam ajusta).

### P2. Campo Lento guarda o momento (Psiônico) 💡

**Padrão:** rastro e gancho. **Pilar:** surreal, então precisa de limite claro.

Hoje, quem sai do campo volta à velocidade normal. A proposta: quando o campo **acaba**, tudo que ainda está
dentro recupera a velocidade que tinha. Dardos disparados para dentro do campo ficam quase parados e saem todos
juntos no fim. É uma armadilha montada com antecedência.

- **Conflito:** muda a regra 2 do Campo Lento em `mage-psionic.md`. Só vale se o Liam aprovar a troca.
- **Limite:** guarda só a velocidade, não soma. Dez dardos continuam sendo dez dardos.
- **Sinal:** os objetos guardados brilham, e a bolha pisca 1 s antes de acabar.

### P3. Telecinese aquece o que roda (Psiônico) 💡

**Padrão:** acúmulo que vira evento. **Pilar:** surreal, com limite.

Girar um objeto segurado por um tempo esquenta ele. No mundo real, o atrito com o ar nessas velocidades não
esquenta quase nada; aqui é a mente agitando o material, ou seja, magia assumida. Uma caixa de madeira segurada e agitada
por 5 s pega fogo. Dá ao Psiônico, que não tem fogo, um jeito lento e caro de usar o sistema de calor.

- **Dúvida:** pode tirar a identidade "o Psiônico não acende nada" (regra 5 do Dardo). O Liam decide se a
  fronteira entre as classes é mais importante.

### C1. Pulo na parede (Cavaleiro e todos) 💡

**Padrão:** o mundo é o recurso (Taliyah). **Pilar:** crível.

O Pulo Duplo, se feito encostado numa parede, empurra para longe dela e sobe um pouco mais. É parkour, nada
mágico. A parede vira ferramenta de movimento.

- **Teste:** medir a altura máxima alcançada com pulo duplo encostado na parede e sem parede. A diferença precisa ser visível (o Liam define o quanto).

### C2. Muralha guarda o golpe (Cavaleiro) 💡

**Padrão:** ritmo com respiro (Jhin). **Pilar:** crível com exagero leve.

A Postura de Muralha segura empurrões e explosões. Na proposta, uma fração do que ela segurou vai para o
próximo Golpe de Escudo, nos 2 s seguintes. Aguentar uma explosão e devolver na hora certa.

- **Limite:** no máximo o dobro do Golpe normal, e só nos 2 s seguintes à Postura.
- **Sinal:** o escudo brilha mais conforme guarda força.
- **Ressalva:** não é física pura (um escudo não guarda energia). Talvez o pilar 1 peça a versão sem
  guardar nada, e o ganho venha só da posição firme.

### E1. O chão define o pilar (Elementalista) 💡

**Padrão:** o mundo é o recurso (Qiyana). **Pilares:** crível, legibilidade.

A Escada de Pedra muda conforme o material do chão mirado. Em pedra, os pilares saem mais densos e duram mais.
Em terra, saem normais. Em lama, saem moles e afundam mais cedo. Em madeira ou metal, não saem.

- **Junta com o módulo 5 (Terra Morta) do laboratório:** o chão já gasto rende menos, como o "chão
  trabalhado" da Taliyah. Isso desestimula repetir a mesma magia no mesmo lugar sem proibir.
- **Depende de:** o chão do mundo ter material, o que hoje só os objetos têm.

## Perguntas para o Liam

1. A regra "toda ativa tem verbo, rastro e gancho" vale como critério para as próximas habilidades?
2. Quais ideias vão para o laboratório primeiro? Minha sugestão: **P1** e **C1**, que são as mais críveis e
   baratas.
3. **P3** e **C2** mexem na fronteira entre as classes e no pilar 1. Vale testar ou já descartamos?

# Ygg — Conceito do Jogo

> Status: rascunho v0.1 · 2026-10-31 · dono: Liam

## Overview (Visão geral)

RPG de mundo aberto em primeira pessoa, baseado em classes, onde o mundo é físico e
**sistêmico**: todo objeto é feito de um material com propriedades (massa, inflamável,
explosivo…) e as habilidades são forças e estados aplicados a essa física. O jogo não é
sobre feitos grandiosos, e sim sobre **pequenos feitos sobre-humanos amplificados pela
criatividade do jogador**.

## Player Fantasy (Fantasia do jogador)

"Eu sou alguém treinado ou talentoso além do comum, num mundo que parece real. Quando
resolvo um problema, é porque pensei num jeito esperto de usar o que tinha à mão: empurrar
o barril certo, carregar uma caixa até o braseiro, saltar no momento certo."

## Pilares

1. **Crível antes de espetacular.** O mundo é semi-realista. O especial/mágico se destaca
   porque o fundo é normal. Mesmo sem magia, o personagem é notavelmente capaz, mas nunca
   absurdo: no máximo **5 a 10 vezes** um humano comum em qualquer atributo.
2. **Quanto mais surreal, mais limitado.** Efeitos que dobram a realidade (telecinese,
   fogo do nada) custam mais, alcançam menos e têm restrições claras. Força bruta é barata;
   mágica é cara.
3. **Criatividade > números.** Uma ideia esperta deve valer mais que um atributo alto.
   As interações entre sistemas (fogo + madeira + pólvora + empurrão) são o conteúdo.
4. **Legibilidade.** O jogador precisa entender por que algo aconteceu. Objetos mostram
   nome e peso, o boneco de testes mostra números, e materiais têm aparência consistente.

## Detailed Rules (Regras — fatia vertical atual)

- **Atributos**: Força, Agilidade, Vitalidade, Destreza, Inteligência, Sorte. Regras em
  `attributes.md`.
- **Classes iniciais**: Cavaleiro, Mago Elementalista e Mago Psiônico. Todos têm Vigor e Mana, dash (Ctrl), pulo duplo (Espaço 2x)
  e a mesma velocidade de movimento.
- **Rumo do Mago**: será o "arqueiro" do jogo (dano à distância) e se divide em duas
  especializações: **Elementalista** (elementos + manipulação de terreno) e **Psiônico**
  (sem elementos: acelerar, desacelerar, flutuar). Psiônico desenhado e implementado em
  `mage-psionic.md`; Elementalista em `mage-elementalist.md` (Bola de Fogo carregável, Escada de
  Pedra, Lamaçal).
- **Interação básica**: qualquer classe pega objetos com as mãos (limite de carga pela
  Força) e arremessa. Andar empurra objetos.
- **Mundo**: materiais madeira, metal, pedra e pólvora; braseiro como fonte de fogo do
  ambiente. Regras em `physics-magic-system.md`.

### Cavaleiro (habilidades gastam Vigor)

| Tecla | Habilidade | Escala com | Ideia |
|---|---|---|---|
| Botão esq. | Golpe de Escudo | Força | Cone de empurrão. Leves voam, pesados mal se mexem. |
| Q | Investida | Força | Arrancada no chão; o impacto é a quantidade de movimento (massa x velocidade). |
| F | Postura de Muralha | Vitalidade | Por alguns segundos ignora 85% dos empurrões e explosões, mas fica lento. |

### Mago Elementalista (magias gastam Mana) · detalhes em `mage-elementalist.md`

| Tecla | Habilidade | Escala com | Ideia |
|---|---|---|---|
| Botão esq. | Bola de Fogo (carregável) | Inteligência | Projétil em arco: explode, empurra e incendeia. |
| Q | Escada de Pedra | fixa | 3 pilares de 0,85, 1,70 e 2,55 m; o do meio na mira. Sobe com W. |
| F | Lamaçal | Inteligência | Lama: objetos param, fogo apaga, quem pisa fica lento. |

### Mago Psiônico · detalhes em `mage-psionic.md`

Dardo Cinético (carregável), Campo Lento (Q), Telecinese Acelerada (F) e Flutuar (segurar Espaço caindo).

## Formulas (Fórmulas)

Ver `attributes.md` (atributo → valor físico) e `physics-magic-system.md` (calor,
explosões, impactos).

## Edge Cases (Casos-limite)

- Objeto segurado preso atrás de parede: solta sozinho se se afastar mais que
  distância de segurar + 2,5 m.
- Mana zera durante a telecinese: o objeto cai e aparece o aviso "Mana esgotada".
- Cair do mapa: o jogador volta ao ponto inicial e os objetos abaixo de -50 m somem.

## Dependencies (Dependências)

Atributos → Jogador → Habilidades → Física/Materiais → HUD (somente por sinais).

## Tuning Knobs (Ajustes)

Tudo em `assets/data/`: `attribute_rules.tres`, `classes/*.tres` (atributos e habilidades)
e `materials/*.tres`. Dá para editar no Inspetor do Godot sem tocar em código.

## Acceptance Criteria (Critérios de aceite da fatia vertical)

- [ ] Do menu principal ao jogo em até 3 cliques (Novo Jogo → classe → jogar).
- [ ] As duas classes usam as 3 habilidades sem erro (teste de fumaça automatizado).
- [ ] Um jogador novo entende, sem explicação, que madeira queima e pólvora explode.
- [ ] O boneco de testes mostra o impulso de cada habilidade e a comparação com um humano.
- [ ] Nenhuma habilidade passa de ~10x o equivalente humano com atributos no teto.
- [ ] Playtest: o cavaleiro e o mago resolvem o mesmo obstáculo de formas diferentes.

## Fora do escopo agora

Combate contra inimigos com IA, vida/dano, inventário, missões, mundo aberto real,
arte final, áudio, eletricidade (o campo `conductive` já existe nos materiais).

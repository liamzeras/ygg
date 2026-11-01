# Mapa das frentes do Ygg

Cada frente é um time de agentes com uma área própria do jogo. Quem é dono de qual arquivo
está em `donos.txt`. O fluxo de operação está na skill `/orquestrar`.

## As 13 frentes

**Modo** diz o que a frente pode fazer hoje. `código` já tem o que construir. `só design`
escreve documentos até o Liam liberar o código, porque o assunto está em "Fora do escopo
agora" em `design/gdd/game-concept.md`.

| Frente | Cuida de | Líder | Especialistas | Skill de time | Modo |
|---|---|---|---|---|---|
| `fundacao` | Base técnica, entrada, arquitetura, desempenho, ferramentas (a "lógica") | `lead-programmer` | `technical-director`, `godot-specialist`, `godot-gdscript-specialist`, `engine-programmer`, `performance-analyst`, `tools-programmer` | — | código |
| `gameplay` | Corpo do jogador (movimento, segurar, arremessar) e física sistêmica (materiais, fogo, explosão) | `game-designer` | `systems-designer`, `gameplay-programmer`, `godot-gdscript-specialist` | — | código |
| `classes` | Classes, habilidades, atributos e balanceamento | `systems-designer` | `game-designer`, `gameplay-programmer` | `/balance-check` | código |
| `interface` | Menus, HUD, feedback ao jogador, acessibilidade | `ux-designer` | `ui-programmer`, `accessibility-specialist`, `art-director` | `/team-ui` | código |
| `mundo` | Arena, fases, mapa aberto, ambientação | `level-designer` | `world-builder`, `godot-specialist`, `art-director` | `/team-level` | código na arena; mapa aberto só design |
| `arte` | Direção de arte, efeitos visuais, shaders | `art-director` | `technical-artist`, `godot-shader-specialist` | `/asset-audit` | código nos efeitos; arte final só design |
| `qualidade` | Testes, roteiros de QA, relatórios de playtest | `qa-lead` | `qa-tester`, `performance-analyst` | `/bug-report`, `/playtest-report` | código |
| `monstros` | Inimigos com IA, combate, dano, alvos de teste | `game-designer` | `ai-programmer`, `systems-designer`, `gameplay-programmer` | `/team-combat` | código nos alvos de teste; inimigos só design |
| `equipamentos` | Itens, inventário, loot, economia | `systems-designer` | `economy-designer`, `gameplay-programmer` | `/design-system` | só design |
| `loop` | Ciclo principal, progressão, salvamento, visão do jogo | `game-designer` | `creative-director`, `economy-designer`, `producer` | `/map-systems` | só design |
| `quests` | Sistema e conteúdo de missões | `narrative-director` | `level-designer`, `writer`, `gameplay-programmer` | `/design-system` | só design |
| `historia` | Roteiro, lore, personagens, diálogos | `narrative-director` | `writer`, `world-builder` | `/team-narrative` | só design |
| `audio` | Identidade sonora, lista de sons | `audio-director` | `sound-designer` | `/team-audio` | só design |

A sessão de pesquisa Sábio não é uma frente. O material dela (`design/sabio/`) serve de
consulta para as frentes, e só ela escreve lá e no próprio laboratório (`src/gameplay/lab/`).

Monetização, marketing, multiplayer e lançamento ficam de fora: `studio_mode` é `indie` e
o jogo ainda está em pré-produção.

## Regras de convivência

1. **Limite de sessões:** no máximo 3 frentes em `código` ao mesmo tempo, somadas a
   até 2 em `só design`. O gargalo é a revisão e o playtest do Liam, não a quantidade de agentes.
2. **Cada frente altera só os próprios arquivos.** Precisou de algo de outra frente? Pare e
   peça ao orquestrador. Ele reserva o arquivo ou abre uma tarefa para a frente dona.
3. **Arquivo com trava** exige reserva no quadro antes de começar. Sem reserva, a frente
   não altera, e a tarefa espera ou é refeita de outro jeito.
4. **Sistemas conversam por sinais.** Uma frente nova se liga às outras por sinais e dados em
   `.tres`, sem editar o código da outra (regra do `CLAUDE.md`).
5. **Só o orquestrador junta o trabalho na `main`**, um ramo por vez, com ordem do Liam e
   teste de fumaça depois de cada junção.
6. **Conversa principal também conta:** ela trabalha direto na `main` e aparece no quadro como
   `principal`, com as reservas dela. Ela entrega sozinha com `tools/entregar.sh` (commit e envio,
   regra no `CLAUDE.md`). O que ainda está sem commit lá é invisível para as frentes.
7. **Testes:** cada frente acrescenta testes só na própria suíte em `tests/suites/`.

## Limpeza que tira os gargalos

A divisão de agentes não limpa o código sozinha. Ela só deixa claro de quem é cada coisa.
Quem reduz a disputa por arquivos são estas tarefas, nesta ordem:

| # | Frente | Tarefa | Por quê |
|---|---|---|---|
| 1 | `qualidade` | **Feita:** dividir `tests/smoke_test.gd` em uma suíte por frente | Tinha 789 linhas e toda funcionalidade nova mexia nele |
| 2 | `gameplay` | Separar de `player.gd` os componentes de movimento, mãos e recursos | Tem 773 linhas e 13 habilidades chamam o jogador diretamente |
| 3 | `mundo` | Separar de `test_arena.gd` as estações de teste por área | Toda classe nova acrescenta coisas à arena |
| 4 | `interface` | Fazer o HUD montar os espaços de habilidade a partir dos dados | Hoje `hud.gd` trata casos por habilidade |

Cada uma começa com o teste de fumaça passando e deve terminar com ele passando, sem
mudar o comportamento do jogo. Quando uma trava deixar de ser necessária, tire a palavra `trava` do `donos.txt`.

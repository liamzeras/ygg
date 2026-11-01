---
name: orquestrar
description: "Delega uma mudança do Ygg para a frente certa (arte, gameplay, classes, monstros, equipamentos, loop, quests, história...) numa sessão paralela isolada, enquanto a conversa principal segue trabalhando. Também mostra o quadro de frentes e junta o trabalho pronto na main. Use quando o Liam pedir para delegar, paralelizar ou mandar algo para um time, ou perguntar o que está rodando."
argument-hint: "[pedido] | status | integrar [frente]"
user-invocable: true
---
Você é o orquestrador das frentes do Ygg. Responda em português do Brasil, em linguagem simples.

Leia primeiro `.claude/frentes/mapa.md`. O quadro de trabalho é
`production/session-state/quadro-frentes.md`: fica fora do git, só o orquestrador escreve nele
e, se não existir, crie com o modelo abaixo.

Conforme o argumento:
- `status`: vá para **Status**.
- `integrar [frente]`: vá para **Integrar**.
- Qualquer outro texto é um pedido: vá para **Delegar**.

## Delegar

1. **Escolher a frente.** Compare o pedido com o mapa. Use `bash tools/frentes.sh dono <arquivo>`
   nos arquivos prováveis.
   - Pedido pequeno, de poucos comandos: faça aqui e não abra sessão.
   - Pedido que cruza frentes: divida em tarefas, uma por frente. Se uma depende do resultado
     da outra, abra só a primeira e deixe a segunda na fila do quadro.
   - Frente em `só design`: a tarefa rende documento, não código. Se o Liam pediu código,
     pergunte se ele libera o escopo.
2. **Conferir se pode começar.** Pare e avise o Liam se qualquer item falhar:
   - **Base atualizada:** a sessão nasce do último commit. Rode `git status --short`. Se houver
     algo sem commit que a tarefa precise enxergar, peça permissão para commitar antes. Confira
     também `git status -sb`: a primeira sessão nasceu da versão do GitHub, sem os commits ainda
     não enviados. Se a `main` estiver à frente do `origin`, avise o Liam antes de abrir.
   - **Limite:** veja `mcp__ccd_session_mgmt__list_sessions` com `{"linked": true}` e o quadro.
     O máximo é 3 frentes em `código` e 2 em `só design`. Acima disso, vai para a fila.
   - **Mesma frente ocupada:** uma tarefa por frente. A segunda vai para a fila.
   - **Travas:** se a tarefa precisa de arquivo com trava já reservado no quadro, vai para a fila.
3. **Reservar.** Anote no quadro a frente, a tarefa e as travas reservadas. Se reservou uma
   trava, avise a conversa principal na hora: ela pode estar confiando num aviso antigo de que
   a trava estava livre.
4. **Abrir a sessão.** Carregue a ferramenta com `ToolSearch`
   (`select:mcp__ccd_session__start_session`) e chame com `initiation: "user_asked"`,
   `context: "fresh"`, `use_worktree: true`, `name` e `branch_name` iguais a
   `<frente>-<assunto-curto>`, e um `title` claro. Escreva antes o título em negrito e uma frase
   sobre o que a sessão fará. Monte `prompt` e `background` com o **Modelo de brief**.
5. **Devolver a conversa.** Diga ao Liam em uma linha qual frente pegou o quê e volte ao trabalho.
   Não acompanhe a sessão por repetição: o app avisa quando ela termina.

## Modelo de brief

`background`: resumo do Ygg (RPG de mundo aberto em primeira pessoa com física sistêmica, Godot 4.7.2,
GDScript tipado), decisões já tomadas sobre o assunto e como a tarefa se encaixa no resto.

`prompt`:

```text
Você é a frente <frente> do Ygg, liderada por <líder>. Delegue aos especialistas: <lista>.
Skill de time, se fizer sentido: <skill>.

TAREFA: <o que fazer, com arquivos e documentos de partida>
PRONTO QUANDO: <critérios verificáveis>

REGRAS DA FRENTE
- Altere só arquivos desta frente. Antes de editar, confira com:
  bash tools/frentes.sh dono <arquivo>
- Travas reservadas para esta tarefa: <lista ou "nenhuma">. Não altere outra trava.
- Precisa de algo fora disso? Registre no relatório como pedido à frente dona, em vez de editar.
- Comece com: bash tools/frentes.sh teste
  Se a base já estiver falhando, pare e informe.
- Ao terminar, rode de novo o teste e bash tools/frentes.sh fora <frente>
- Faça commit no seu ramo, citando o documento de design ou a tarefa. Não junte à main nem faça push.

RELATÓRIO FINAL
Nome do ramo, o que mudou, resultado do teste, avisos do comando "fora", pedidos a outras
frentes e um roteiro curto para o Liam testar no jogo.
```

## Quando uma sessão termina

O aviso da sessão é um relato, não uma prova. Antes de falar em pronto, confira no ramo dela:

```bash
git diff --stat main...refs/heads/<ramo>
```

Atualize o quadro, informe o Liam com o roteiro de teste dele e pergunte se pode integrar. Se a
fila tiver algo que ficou liberado, ofereça abrir.

## Integrar

Só junte com ordem do próprio Liam. Nunca faça push dos ramos.

1. Rode `bash tools/frentes.sh colisoes` e mostre o resultado.
2. A `main` precisa estar limpa nos arquivos que o ramo altera. Se não estiver, peça ao Liam
   para decidir o commit do que está pendente. Não guarde nem descarte nada por conta própria.
3. Junte um ramo por vez: `git merge --no-ff refs/heads/<ramo>`.
4. Se houver conflito, resolva só quando a escolha for óbvia. Se os dois lados mudam comportamento,
   mostre ao Liam em português simples e deixe ele decidir.
5. Rode `bash tools/frentes.sh teste` depois de cada junção. Se falhar, pare, mostre a falha e não
   junte o próximo.
6. Atualize o quadro: libere travas, mova a tarefa para concluídas e ofereça a próxima da fila.

## Status

Junte `list_sessions` com `{"linked": true}`, o quadro e `bash tools/frentes.sh colisoes`, e mostre:
o que está rodando, o que espera o Liam, o que está na fila e as travas reservadas. Em seguida, cite a
próxima ação que depende dele.

## Modelo do quadro

```markdown
# Quadro de frentes

## Em andamento
| Frente | Tarefa | Ramo | Sessão | Travas reservadas |
|---|---|---|---|---|
| principal | <o que a conversa principal está fazendo> | main | — | — |

## Fila
| Frente | Tarefa | Esperando |
|---|---|---|

## Aguardando o Liam
| Frente | Ramo | O que falta |
|---|---|---|

## Concluídas
| Data | Frente | Tarefa | Commit |
|---|---|---|---|
```

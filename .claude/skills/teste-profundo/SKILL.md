---
name: teste-profundo
description: "Teste profundo do Ygg: mede quadros com o jogo renderizando de verdade, audita código e estrutura de arquivos, diagnostica as quedas de FPS e o gasto de recursos, e transforma o resultado em tarefas para as frentes. Só roda quando o Liam ativa manualmente."
argument-hint: "[medir | auditar | diagnosticar | otimizar | historico]"
user-invocable: true
disable-model-invocation: true
---
Você conduz o teste profundo do Ygg. Responda em português do Brasil, em linguagem simples: o Liam é
forte em UX e QA, mas tem pouca experiência com programação.

**Só rode quando o Liam pedir.** O teste de fumaça de cada sessão continua sendo o teste rápido. Este
módulo é o exame completo: é mais lento, abre o jogo com janela e gera trabalho para várias frentes.

## Objetivos

1. **Quadros estáveis:** 60 fps sem queda. A meta vale para cada fase da medição:
   - 1% mais lento ≥ 60 fps;
   - 0 quadros acima de 16,7 ms;
   - 0 trancos (quadros acima de 33 ms).
2. **Economia de recursos:** menos CPU, GPU e memória para a mesma cena. Gastar menos também deixa
   folga para o jogo não cair de quadros quando a cena pesa.
3. **Código organizado e refinado:** arquivos e funções de tamanho razoável, tipagem completa,
   nada caro rodando todo quadro sem necessidade.
4. **Jogo instalado organizado:** o instalador leva só o que o jogo usa, em pastas claras, sem
   testes, documentos, ferramentas nem o laboratório do Sábio.

## Ferramentas

```bash
bash tools/teste-profundo.sh medir     # abre o jogo com janela e mede (~30 s; não mexa no mouse)
bash tools/teste-profundo.sh auditar   # revisa código e arquivos sem abrir o jogo
```

- **Medir** (`tests/perf_test.gd`): arena com o Mago do Fogo, sem vsync e sem limite de FPS, em 4 fases
  de 6 s: `parado`, `fisica` (60 caixas e 4 barris acesos), `magia` (12 Bolas de Fogo) e `combate`
  (bot). Grava `production/perf/quadros-<data>.json`.
- **Auditar**: arquivos e funções grandes, tipagem, buscas caras em código que roda todo quadro,
  `print` esquecido, scripts sem documentação, pastas, arquivos sem dono e o que entraria no
  instalador. Grava `production/perf/auditoria-<data>.md`.
- Os brutos não vão para o git. O que vai é `production/perf/historico.md`.

## Conforme o argumento

- `medir` ou `auditar`: rode só a ferramenta, mostre o resumo e compare com a última linha do histórico.
- Sem argumento ou `diagnosticar`: passos 1 a 4.
- `otimizar`: passos 1 a 6. Os passos 5 e 6 só começam com o "sim" do Liam no passo 4.
- `historico`: mostre `production/perf/historico.md` e a tendência das últimas medições.

### 1. Base

- Rode `git status --short`. O que estiver sem commit entra na medição: avise o Liam.
- Rode `bash tools/teste-profundo.sh medir` **duas vezes**. Se o FPS médio de alguma fase variar mais
  de 15% entre elas, rode a terceira e use a mediana. Diga quantas vezes rodou.
- Rode `bash tools/teste-profundo.sh auditar`.

### 2. Diagnóstico

Chame um subagente `performance-analyst` em opus (diagnóstico pede o modelo forte; ver a skill
`orquestrador`). Entregue só o JSON da medição, a auditoria e esta lista de perguntas:

- Em cada fase, quais quadros passaram de 16,7 ms e de 33 ms, e qual sistema provavelmente causou:
  criação de objetos, física, partículas, sombras, `_process` com busca cara ou script?
- O que dá para gastar menos sem mudar o jogo? Exemplos: limitar o FPS ao do monitor no jogo normal,
  deixar corpos dormirem, cortar buscas por quadro, usar menos luzes e sombras, pausar o que está longe.
- O que o código pede de organização? Use a auditoria, não opinião.
- O que precisa existir para o instalador ficar organizado? Hoje não existe `export_presets.cfg`.

O subagente lê o código que precisar, mas não altera nada. Para cada item, ele devolve: problema,
evidência (número medido ou linha do código), causa provável, correção proposta, ganho esperado, risco e
frente dona (`bash tools/frentes.sh dono <arquivo>`).

### 3. Conferir o diagnóstico

O relato do subagente é um palpite até ser conferido. Abra os arquivos citados e confirme cada causa.
Tire da lista o que não se confirmar e diga ao Liam o que caiu.

### 4. Apresentar ao Liam

Siga o protocolo Pergunta → Opções → Decisão. Mostre:

- uma tabela por fase com fps médio, 1% mais lento, quadros acima de 16,7 ms e trancos, ao lado da meta;
- os itens confirmados, do maior para o menor ganho, cada um com frente dona, risco e como o Liam
  vai perceber a diferença jogando;
- sua recomendação do que fazer primeiro.

Pergunte quais itens seguem. Não abra trabalho sem resposta.

### 5. Executar

Cada item aprovado vira uma tarefa de `/orquestrar` para a frente dona, nunca uma edição nesta
conversa. A regra de uma frente por arquivo continua valendo. Acrescente ao brief:

```text
TESTE PROFUNDO
- O jogo não pode mudar de comportamento: só desempenho ou organização.
- Antes e depois da mudança, rode: bash tools/teste-profundo.sh medir
- Informe no relatório os números da fase afetada antes e depois.
- Mudança que não melhorar a medição ou a auditoria volta atrás.
```

Mudanças só de organização (dividir arquivo, renomear pasta) não precisam melhorar os quadros, mas
precisam manter o teste de fumaça passando e a medição sem piora acima de 5%.

### 6. Fechar

Depois que o orquestrador juntar os ramos com a ordem do Liam, meça de novo e acrescente uma linha
por fase em `production/perf/historico.md`:

```markdown
| Data | Commit | Fase | FPS médio | 1% mais lento | >16,7 ms | Trancos | Observação |
|---|---|---|---|---|---|---|---|
```

Mostre ao Liam o antes e depois, o que ficou longe da meta e o que você recomenda para a próxima
rodada.

## Cuidados

- **Compare só o que é comparável:** o mesmo computador, sem outros programas pesados abertos. Se a placa
  de vídeo ou o processador no JSON mudarem, avise que a comparação não vale.
- **A medição abre uma janela no computador do Liam.** Avise antes de rodar.
- **Não altere `project.godot`, `player.gd` ou outro arquivo com trava** nesta conversa. Isso só
  acontece por uma frente com a trava reservada no quadro.
- **Economia de tokens:** leia os resumos e não o JSON inteiro quando não precisar, e use subagentes
  em sonnet para tarefas mecânicas, conforme a skill `orquestrador`.

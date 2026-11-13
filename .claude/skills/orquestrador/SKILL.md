---
name: orquestrador
description: 'Protocolo de orquestração de Ygg. Decide se uma tarefa vira resposta direta, uma skill, um agente, um time ou uma frente paralela, escolhe o modelo certo para cada tipo de trabalho, monta pacotes de contexto mínimos e cobra retornos curtos. Usar no início de qualquer tarefa com mais de 2 etapas, quando o Liam disser "orquestra", "chama os agentes", "monta o time", "economiza tokens", antes de disparar subagentes, ou quando for escolher entre fable, opus, sonnet e haiku.'
---

# Orquestrador: sinergia, versões e economia de tokens

Objetivo: o mesmo resultado, ou melhor, com o menor custo de contexto. Cada subagente começa "frio" e relê tudo; cada arquivo lido fica no contexto até o fim. Então: delegar pouco, delegar certo, receber resumido.

## 1. Triagem (sempre, em silêncio, antes do primeiro passo)

Use a faixa mais barata que entrega o resultado:

| Faixa | Quando | Como |
|---|---|---|
| 0 · Direto | Pergunta, ajuste pequeno, algo que já está no contexto | Responder ou fazer sem skill nem agente |
| 1 · Skill | Precisa de método ou checklist de um domínio | Carregar UMA skill e aplicar no fluxo principal |
| 2 · Agente | Trabalho pesado cujo contexto não precisa voltar inteiro (varrer logs, ler muitos arquivos, revisar um diff grande) | Um agente com pacote mínimo; volta só o resumo |
| 3 · Time | Partes independentes em paralelo, ou checagem independente de algo caro ou irreversível | 2 a 3 agentes no máximo, com escopos que não se sobrepõem |
| 4 · Frente | Tarefa longa de uma área do projeto, que pode andar enquanto a conversa segue | `/orquestrar <pedido>` |

Regra de ouro: suba de faixa só quando a de baixo comprovadamente não basta. Nunca abra agente para algo que se resolve lendo 1 ou 2 arquivos. A faixa 4 é a mais cara em atenção, porque cria mais uma conversa e mais uma integração.

## 2. Pacote de contexto (o que vai para cada agente)

No máximo ~15 linhas:

```text
OBJETIVO: <uma frase, resultado verificável>
ACEITE: <2 a 4 critérios objetivos>
ONDE: <arquivos ou telas exatos; nada de "explore o projeto">
JÁ SABEMOS: <fatos decididos que o agente não deve redescobrir>
NÃO FAZER: <limites: não publicar, não reescrever arquivos inteiros>
RETORNO: <até 150 palavras + caminhos de arquivo; achados por ordem de impacto>
```

Nunca cole a conversa inteira. Aponte o documento de notas do projeto em vez de resumi-lo de novo.

## 3. Orquestrador de versões (qual modelo faz o quê)

Pensar e planejar ficam com os modelos mais fortes. Executar o que já foi decidido, fazer tarefas básicas e redigir relatórios ficam com os mais fracos. Escolha pelo **tipo de trabalho**, não pelo tamanho da tarefa: uma tarefa grande e mecânica é nível 2; uma pergunta curta que decide a arquitetura é nível 4.

| Nível | Modelo | Esforço | Quando |
|---|---|---|---|
| 4 · Decidir | `fable` | `high` | Decisão cara ou irreversível, arquitetura nova, problema em que o nível 3 já falhou, revisão independente de algo que mexe com dinheiro |
| 3 · Pensar | `opus` | `high` | Planejar, quebrar a tarefa, escrever o pacote de contexto, diagnosticar bug, revisar um plano |
| 2 · Executar | `sonnet` | `medium` | Seguir um plano pronto: código rotineiro, testes, texto com modelo definido |
| 1 · Básico | `haiku` | `low` | Extrair, contar, reformatar, varrer arquivos, conferir lista contra lista, montar relatório ou status a partir de conclusões já prontas |

**Regras**

1. **Quem pensa entrega o plano pronto.** As decisões do nível 3 ou 4 vão no pacote de contexto, para o nível 2 ou 1 só executar. Se a execução esbarrar numa escolha que o plano não cobre, o agente devolve a pergunta, em vez de decidir; quem resolve é um nível de pensar.
2. **Sub-ótimo vale para os dois lados.** Modelo fraco demais gera retrabalho, e forte demais gasta tempo e dinheiro sem ganho. Compare o custo por tarefa concluída, não por chamada: uma chamada barata que precisa ser refeita duas vezes saiu cara.
3. **Subir um nível** quando a saída falhar na conferência duas vezes, o agente disser que não tem certeza, ou a tarefa passar a mexer com dinheiro ou algo irreversível. Diga em uma linha que subiu e por quê.
4. **Relatório tem duas partes.** Tirar conclusões é pensar; organizar conclusões já tiradas é básico. Não peça ao nível 1 que julgue o que é importante.
5. **Nomes curtos, nunca versões fixas.** Use `fable`, `opus`, `sonnet` e `haiku`, que sempre apontam para a versão atual. Identificadores fixos, como `claude-opus-4-6`, envelhecem e prendem o trabalho a uma versão pior; só use quando pedirem.
6. **Sem o modelo no plano**, use o mais forte disponível abaixo dele e avise uma vez.

**Onde aplicar**

- **Subagente:** passe `model` e `effort` na chamada do agente, conforme a tabela.
- **Agente com arquivo próprio** (`.claude/agents/`): `model:` no cabeçalho, com o nome curto do nível dele. Agente que planeja não fica em `haiku`; agente que só extrai não fica em `opus`.
- **Sessão paralela:** passe `model` ao abrir. Ela só pode usar o modelo da conversa principal ou um mais barato, por isso a principal precisa estar no nível mais alto que o trabalho pede.
- **Conversa principal:** é onde se pensa, então fica no nível 3 ou 4. Ela não troca o próprio modelo: se estiver abaixo do que a tarefa pede, proponha a troca no seletor de modelo do app.

## 4. Mapa de sinergia (quem trabalha junto)

- **Delegar a uma área do jogo:** `/orquestrar <pedido>` (faixa 4), que escolhe a frente pelo `.claude/frentes/mapa.md`.
- **Times por área:** combate e monstros com `/team-combat`, interface com `/team-ui`, fases e arena com `/team-level`, história com `/team-narrative` e áudio com `/team-audio`.
- **Pesquisa em outros jogos:** agente `sabio`; o material fica em `design/sabio/`.
- **Balanceamento de classes e atributos:** `systems-designer` + `/balance-check`.
- **Bugs e testes:** `qa-lead` + `/bug-report`; relatório de playtest com `/playtest-report`.
- **Decisões que cruzam áreas:** `producer`. Conflito de design vai para `creative-director`; conflito técnico, para `technical-director`.

## 5. Contrato de retorno

Todo agente devolve: (1) resposta em até 150 palavras, (2) arquivos criados ou alterados, (3) riscos e pendências. Material longo vai para arquivo, nunca para o chat.

Se surgir uma decisão que é do Liam, o agente devolve pergunta, opções e recomendação. O fluxo principal transforma isso em voto com `AskUserQuestion`, com a recomendação em primeiro.

## 6. Orçamento

- Ler arquivo por trecho (offset/limit, grep) antes de ler inteiro.
- Não reler o que já está no contexto; não pedir ao agente o que o fluxo principal já sabe.
- Se a tarefa estiver custando mais que o planejado, pare, resuma o estado e proponha um caminho mais curto.

## 7. Verificação proporcional

- Mudança que mexe em dinheiro ou é irreversível: uma checagem independente, por quem não viu o processo.
- Mudança pequena e reversível: auto-checagem (rodar, abrir, conferir número) basta.

## Anti-padrões

Abrir agente para "dar uma olhada"; dois agentes lendo os mesmos arquivos; pedir relatório longo de volta; repetir pesquisa que já está nas notas; delegar uma decisão que é do Liam.

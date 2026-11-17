# O Sábio: base de conhecimento externo do Ygg

> Criada em 2026-11-01. Agente: `.claude/agents/sabio.md`. Isto é material de pesquisa, não GDD:
> nada aqui vale como regra do jogo até virar decisão em `design/gdd/`.

## As duas frentes

| Frente | Quando usar | Resultado |
|---|---|---|
| **Inspiração** | Pensar em sistemas únicos, aprendendo com acertos e erros de outros jogos | Fichamento e ideias propostas para o Ygg |
| **Roubo** | Demanda grande e pouco específica, com um sistema base já pronto no Ygg | Dados extraídos, adaptados e convertidos em `.tres` |

## Índice

**Inspiração**

- [Ragnarok: reagentes, estados e terreno](inspiracao/ragnarok-reagentes-e-estados.md)
- [Jogos sistêmicos: lições e alertas](inspiracao/jogos-sistemicos.md)
- [Ideias para o Ygg](inspiracao/ideias-para-ygg.md) (backlog para o Liam decidir)
- [Elementos × materiais](inspiracao/tabela-elementos-materiais.md) (rascunho de GDD; aguarda decisões)
- [LoL: passivas como cola do kit](inspiracao/lol-passivas.md) (pesquisa; a aplicação foi revista)
- [Magos de um elemento](inspiracao/magos-elementais.md) (lei, eixo e 4 funções dos 7 elementos; aguarda decisões)
- [Maestrias](inspiracao/maestrias.md) (critérios e 6 propostas para Fogo, Terra e Gravidade; aguarda decisões)

**Pesquisa científica**

- [Princípios para o Deep Research](pesquisa/principios-para-deep-research.md) (prompt e 140 princípios; as respostas voltam para esta pasta)
- [Contexto físico auditado](pesquisa/contexto-fisico.md) (18 princípios do Gemini, com erros apontados)
- [Faltantes](pesquisa/faltantes.md) (122 princípios pesquisados, com o arquivo e a confiança de cada bloco)
- [Decisão de implementação](pesquisa/decisao-implementacao.md) (proposta e respostas da conversa principal e do orquestrador)
- [Fórmulas contra o jogo](pesquisa/resultado-formulas.md) (previsto versus medido na física real)

**Protótipos**

- [Laboratório do Sábio](laboratorio.md) (módulos para avaliar, manter ou apagar)

**Roubo**

- [Fontes e processo](roubo/fontes-e-processo.md) (Ragnarok; plano para equipamentos)

## Semáforo de reuso

Este semáforo é um critério de trabalho, não parecer jurídico. Antes de vender o jogo, vale uma
revisão com advogado de propriedade intelectual.

| Nível | O quê | O que fazemos |
|---|---|---|
| 🟢 Verde | Regras, mecânicas, formato de fórmulas, categorias de sistema, faixas de valores usadas para calibrar | Usamos livremente e adaptamos ao Ygg |
| 🟡 Amarelo | Tabela inteira, escada de progressão completa, combinação muito reconhecível | Usamos como referência, mas selecionamos, reequilibramos e renomeamos. O Liam aprova |
| 🔴 Vermelho | Nomes próprios, descrições, lore, personagens, arte, sprites, áudio, arquivos do rAthena copiados para o jogo, espelho do Divine Pride | Não entra no Ygg |

**Por quê:**

- Regras de jogos não têm proteção de direito autoral no Brasil (Lei 9.610/98, art. 8º, II) e, em
  geral, nem nos EUA. A expressão ao redor delas tem.
- Uma base de dados pode ser protegida pela seleção e organização, embora essa proteção não alcance
  os dados em si (art. 7º, XIII e § 2º). Outro motivo para a tabela inteira ser amarela.
- Trocar só o nome não basta: em *Tetris v. Xio*, o clone perdeu por copiar a aparência e o
  comportamento visual. No caso de *Triple Town*, a própria hierarquia de objetos foi considerada
  protegível. Por isso a escada completa é amarela.
- Traços marcantes de personagens também podem ser protegidos, como o "sonic boom" do Guile.
- Não encontrei decisão específica sobre tabelas numéricas de jogos. Tratamos como zona cinzenta.

Fontes: [Lei 9.610/98](https://www.planalto.gov.br/ccivil_03/leis/l9610.htm) ·
[Frankfurt Kurnit, 2017](https://fkks.com/news/how-courts-view-copyright-protection-for-video-games) ·
[Tetris v. Xio](https://www.lizerbramlaw.com/blog/tetris-case-video-game-copyright/)

## Modelo de fichamento

```markdown
### Nome da mecânica (jogo, versão ou servidor)
**O que a fonte diz:** fatos e números, com link.
**Por que funciona:** análise do Sábio.
**Onde falha ou o que evitar:** erros, abusos, custos.
**Padrão reaproveitável:** a ideia sem o jogo de origem.
**Para o Ygg:** proposta, com o pilar envolvido e o semáforo.
```

## Marcas de confiança

- Sem marca: confirmado na fonte citada.
- `[memória, a confirmar]`: lembrança do Sábio; não usar em decisão antes de verificar.
- `[fonte fraca]`: fonte secundária ou com aviso de que pode estar incompleta.

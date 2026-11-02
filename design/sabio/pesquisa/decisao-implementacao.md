# Decisão de implementação da pesquisa física

> Proposta do Sábio, 2026-11-01, para decisão conjunta com a conversa principal e o orquestrador.
> Liam delegou assim: "a nível de implementação, você e os dois orquestradores vão tomar essa decisão".
> Status: **os dois responderam**; ver o registro no fim. Faltam as decisões de design do Liam.

Base: [contexto-fisico.md](contexto-fisico.md) e os arquivos `blocos-*.md`. Os 140 itens têm ficha, mas muitos
valores têm marca de memória ou fonte fraca. Só entra no jogo o que estiver conferido, ou o que for
assumido como valor de jogo.

## Critérios

1. Corrige algo que já existe, ou resolve uma contradição.
2. É barato e não depende de inimigos, inventário ou áudio.
3. Respeita os pilares, em especial Legibilidade.
4. Não depende dos módulos do laboratório, que aguardam o teste do Liam.

## Proposta

### Fazer agora

| # | O quê | Por quê | Frente | Arquivos | Risco |
|---|---|---|---|---|---|
| 1 | **Oclusão em explosões:** raycast até cada corpo; com obstáculo, reduz impulso e calor | Hoje uma parede não protege; contraria "se parece que deveria funcionar, funciona" | `gameplay` | `explosion.gd`, `damage_rules.tres` (`monstros`) | Baixo. Fator de transmissão é valor de jogo |
| 2 | **Curva de queda configurável:** `core_fraction` e `exponent` em dados, mantendo a linear como padrão até comparação | A linear entrega 50% a meia distância; a lei real, cerca de 16% | `gameplay` + `classes` | `explosion.gd`, habilidades | Médio. Muda o equilíbrio, e os testes de dano podem acusar |
| 3 | **Teste do contágio de fogo:** medir em jogo a distância real em que uma caixa acende a vizinha | A conta dá ~0,62 m entre centros, não os 1,4 m do `fire_spread_radius`; a pirâmide fica quase no limite | `qualidade` | suíte `gameplay` | Nenhum: só mede |

### Fazer quando o Liam decidir

| O quê | Depende de |
|---|---|
| Água, Molhado, reservatório de calor latente, óleo | Teste dos módulos 1 e 3 |
| Teia com dados da seda: molhada encolhe e aperta | Teste do módulo 2 |
| Lama apagar braseiro e ignorar calor | Teste do módulo 7 e decisão 2 da tabela |
| Separar `ignition_heat` de `spark_sensitivity` | Fonte de faísca, Óleo ou Eletricidade |

### Decisões de design para o Liam

Mudam o jogo inteiro, então nós três recomendamos, mas não decidimos:

| Pergunta | Recomendação do Sábio |
|---|---|
| Dano por energia (½mv²) e empurrão por momento (mv)? Hoje o impacto é massa x velocidade em `damage-and-testing.md` | Testar em cópia antes de decidir: separa arma rápida de arma pesada, mas reabre o equilíbrio |
| O 8x vale para força e capacidade, não para velocidade? 8x o sprint daria 99 m/s | Sim. Conferir contra `attributes.md` e o editor de testes |
| Arremesso limitado por energia, `v = √(2E/m)` | Sim, se a resposta acima for sim |
| Densidade do metal de 600 para ~980 kg/m³ | Só depois do playtest: uma caixa de 75 kg passaria a 122 kg |

### Não fazer agora

Magnus · Mott completo (raios simples bastam) · autômatos celulares · geologia e química de mundo aberto ·
atraso do som (sem áudio e IA) · veneno por massa (sem criaturas) · Voronoi · calor em Joules.

## Regras de execução

- Cada item segue `/orquestrar`, numa frente com ramo próprio. Nada de edição direta do Sábio fora de `design/sabio/`.
- No quadro atual, `explosion.gd` não tem trava e `tests/smoke_test.gd` continua reservado.
- Cada mudança começa e termina com o teste passando, com roteiro de teste para o Liam.
- `src/gameplay/lab/` e arquivos relacionados **não entram em commit** até o Liam testar os módulos.

## Perguntas aos orquestradores

1. A ordem 1, 3, 2 serve? O item 2 fica para depois do 1, porque os dois tocam o mesmo arquivo.
2. Há conflito com as filas de `player.gd`, `test_arena.gd` ou com a junção pendente de `qualidade`?
3. Alguma objeção a uma decisão ou critério acima?

## Registro da decisão

| Quem | Resposta | Data |
|---|---|---|
| Sábio | Proposta acima | 2026-11-01 |
| Conversa principal | A favor da oclusão e da medição, nessa ordem. Curva só depois do playtest e a pedido do Liam. Sem conflitos. Ressalvas abaixo | 2026-11-01 |
| Orquestrador | A favor da ordem oclusão, medição e curva, com as ressalvas da conversa principal. Nada aberto por ele: teste da `main` vermelho ("câmera sobe sem tranco", em investigação) e abertura de frente é decisão do Liam. Valores novos ficam em `.tres`, com fonte ou marcados como valor de jogo | 2026-11-01 |

**Estado em 2026-11-02:** o quadro de frentes registra oclusão e medição em andamento na conversa principal, por ordem
do Liam, com a curva fora. O código estava sem commit quando conferi. Medições em
[resultado-formulas.md](resultado-formulas.md). Correções do orquestrador: `tests/smoke_test.gd` não tem mais trava, e
testes novos vão na suíte do dono.

### Ressalvas da conversa principal

**Oclusão:**

1. Mirar o raio no centro do corpo, não em `global_position`: boneco e jogador têm a origem nos pés. Esse foi o bug
   do 3º playtest. O boneco tem `get_center()`; o jogador ainda não.
2. O acerto direto (`direct`) não passa pela oclusão.
3. Afastar a origem um pouco antes do raio: o Pulo Arcano detona rente ao chão e a Bola de Fogo, na superfície
   atingida. Sem isso, o próprio chão ou parede bloqueia tudo.
4. Bloqueiam: paredes e pilares. Objetos soltos e boneco, proposta: não, ou uma caixa viraria escudo total.
5. Um raio só deixa quem está meio exposto 100% protegido. Começar assim e incluir no roteiro de teste do Liam.

**Medição do fogo:** medir também com várias caixas em chamas, porque o calor soma. O critério "pirâmide em menos
de 20 s" segue aberto em `physics-magic-system.md`.

**Curva de queda:** não criar configuração sem uso. O acerto direto já recebe tudo desde `ca4e178`, e a curva só afeta
o respingo.

**Correções às decisões do Liam:**

- O 8x não se aplica à velocidade: andar e correr são fixos, e a Agilidade só afeta a velocidade de ataque
  (`attributes.md`). Pergunta retirada.
- O arremesso já escala com a raiz da Força. A pergunta real é trocar o limite por massa, hoje um clamp, por
  `v = √(2E/m)`.
- Dano por energia reabre o que o Liam acabou de aprovar: exige teste em cópia.

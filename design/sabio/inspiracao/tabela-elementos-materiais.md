# Elementos × materiais (rascunho para virar GDD)

> Status: proposta do Sábio · 2026-11-01 · aguarda decisões do Liam. Nada aqui entrou no jogo normal;
> parte das propostas pode ser testada como protótipo no [Laboratório](../laboratorio.md).
> O que está marcado como ✅ foi conferido lendo o código atual, não jogando.
> Origem: regras de química de [Breath of the Wild](https://www.thumbsticks.com/gdc-17-breath-of-the-wild-science-lies).
> Ideia 2 de [ideias-para-ygg.md](ideias-para-ygg.md).

**Legenda:** ✅ já existe · 💡 proposta · ⚠️ lacuna atual · — nada acontece, de propósito.

## Overview (Visão geral)

Uma única tabela define o que cada elemento faz com cada material. Quem cria conteúdo consulta a
tabela em vez de programar casos especiais: um material novo só precisa preencher uma coluna e já
funciona com tudo que existe.

## Player Fantasy (Fantasia do jogador)

"Se parece que deveria funcionar, funciona, e funciona sempre igual." Molhei a caixa, ela demora a
pegar fogo. Vale para mim, para o inimigo e para qualquer objeto do mundo.

## Detailed Rules (Regras)

### As 3 regras do Ygg

1. **Elementos mudam o estado de materiais.** Fogo queima madeira.
2. **Elementos mudam uns aos outros.** Água apaga fogo.
3. **Materiais só mudam o estado de outro material por um elemento ou por impacto.** Madeira em
   chamas não "queima o vizinho": ela emite calor, e o calor age.

**Diferença de Breath of the Wild:** lá, materiais nunca influenciam o estado uns dos outros. O Ygg
precisa do impacto como exceção, porque o barril de pólvora já detona a 9 m/s e isso combina com o
nosso conceito. Impacto só muda estado ao passar de um limite definido no material.

### Quatro categorias

| Categoria | O que é | Exemplos |
|---|---|---|
| **Elemento** | Age sobre estados; não tem corpo | Fogo ✅, Água 💡, Frio 💡, Eletricidade 💡 |
| **Material** | Corpo com massa | Madeira, Metal, Pedra, Pólvora ✅, Teia 💡 |
| **Superfície** | Área no chão que carrega um elemento | Lamaçal ✅, Poça 💡, Gelo 💡, Óleo 💡 |
| **Estado** | Condição temporária de um corpo | Em chamas ✅, Molhado 💡, Congelado 💡 |

**Fora dos elementos:** a magia do Psiônico continua sendo força, sem elemento, como já definido em
`mage-psionic.md`. Vento também fica como força por enquanto.

### Tabela A: elemento × material

| | Madeira | Pólvora | Metal | Pedra | Teia 💡 | Personagem |
|---|---|---|---|---|---|---|
| **Fogo** | ✅ Acumula calor, queima 10 s, espalha e vira cinzas | ✅ Acende; explode após pavio de 1,5 s | ✅ — | ✅ — | 💡 Queima de uma vez, causa calor em quem está preso e solta | ✅ Boneco toma dano · ⚠️ Jogador ignora calor |
| **Água** | 💡 Apaga; fica Molhada | 💡 Apaga e para o pavio; Molhada não acende nem detona | 💡 Molhado | 💡 Molhada; sem outro efeito | 💡 Molhada; não pega fogo | 💡 Apaga; Molhado |
| **Frio** | 💡 Retira calor | 💡 Retira calor | — | — | 💡 Fica quebradiça: solta com menos força | 💡 Mais lento |
| **Eletricidade** | — | 💡 A faísca detona | 💡 Conduz | — | — | 💡 Choque, se Molhado ou encostado em metal |
| **Impacto** *(ponte)* | 💡 Quebra (ideia já listada no GDD) | ✅ Detona a 9 m/s ou mais | — | — | 💡 Arrebenta acima da resistência | ✅ Boneco toma dano |

### Tabela B: elemento × elemento

| | Fogo | Água | Frio | Eletricidade |
|---|---|---|---|---|
| **Água** | 💡 Apaga | | | |
| **Frio** | 💡 Um desconta do outro | 💡 Vira Gelo no chão: escorrega | | |
| **Eletricidade** | 💡 Faísca: pouco calor, suficiente para pólvora | 💡 Poça conduz em toda a área | — | |

Respeita o GDD atual: gelo deixa o chão escorregadio e não congela coisas no ar.

### Tabela C: superfícies

| Superfície | Carrega | Efeito próprio | Reage a |
|---|---|---|---|
| **Lamaçal** ✅ | Água | Arrasto em objetos; personagens a 0,5x | Fogo: não sobrevive em objetos dentro ✅ · Frio: endurece e vira chão firme 💡 |
| **Poça** 💡 | Água | Deixa Molhado quem pisa | Frio: vira Gelo · Eletricidade: conduz |
| **Gelo** 💡 | Frio | Atrito baixo | Fogo: vira Poça |
| **Óleo** 💡 | — | Atrito baixo; muito inflamável | Fogo: queima a área inteira |

### Estado Molhado (primeiro estado novo)

- **Como entra:** Água, Poça ou sair do Lamaçal.
- **Efeito:** calor recebido pela metade; pólvora não acende nem detona; passa a conduzir.
- **Como sai:** depois de 15 s, ou com calor.
- **Como se vê:** escurece e fica mais brilhante, e a mira mostra "Molhado". Sem isso, o efeito parece
  um bug.

### Lacunas atuais encontradas no código

1. **Lamaçal não afeta o braseiro.** A lama só age em objetos soltos (`mud_patch.gd:62`), e o braseiro
   é uma área (`heat_zone.gd`). Pela regra 2, a água deveria apagar o fogo.
2. **Objeto reacende e apaga em ciclo.** Dentro da lama e do braseiro ao mesmo tempo, uma caixa
   acumula calor, acende e apaga no quadro seguinte. Previsto pela conta abaixo, não testado no jogo.
3. **Jogador ignora o calor.** Só boneco, alvos e objetos recebem calor. Já estava previsto como futuro
   no comentário de `physics_prop.gd:125`, e depende do sistema de vida do jogador.

## Formulas (Fórmulas)

```text
tempo_para_acender = ignition_heat / (calor_por_s x fator_estado - heat_decay - resfriamento)
```

| Variável | Significado | Faixa | Origem |
|---|---|---|---|
| `ignition_heat` | Calor para pegar fogo | Madeira 100, pólvora 60 | `materials/*.tres` |
| `calor_por_s` | Calor recebido por segundo | Braseiro 80 | `heat_zone.gd` |
| `fator_estado` | Seco 1,0; Molhado 0,5 💡 | 0,25 a 0,75 | Proposta, a testar |
| `heat_decay` | Calor perdido por segundo | Madeira 15, pólvora 10 | `materials/*.tres` |
| `resfriamento` | Lamaçal 50; fora dele, 0 | 0 a 100 | `mage-elementalist.md` |

Se o divisor for zero ou negativo, o objeto nunca acende.

**Exemplos de caixa de madeira no braseiro:**

| Situação | Conta | Resultado |
|---|---|---|
| Seca | 100 / (80 − 15) | 1,5 s |
| Molhada 💡 | 100 / (40 − 15), sem contar a secagem | 4 s; **medido no protótipo: 3,4 s**, porque o calor seca ([resultado](../pesquisa/resultado-formulas.md)) |
| Dentro da lama ⚠️ | 100 / (80 − 15 − 50) | 6,7 s, e apaga em seguida: é a lacuna 2 |

**Exemplo com a Bola de Fogo:** o calor vai de 78 (clique) a 178 (carga cheia), no Elementalista
inicial. Numa madeira seca, a carga cheia acende sozinha, porque 178 ≥ 100. Na molhada, 178 x 0,5 = 89
não acende com um único tiro. Dá para entender isso jogando: "preciso secar primeiro ou bater duas
vezes".

## Edge Cases (Casos-limite)

- **Objeto Molhado recebe calor:** recebe metade, e o calor recebido encurta o tempo Molhado. Só acende
  se somar `ignition_heat`.
- **Pólvora Molhada a 9 m/s ou mais:** não detona. Ao secar, volta a funcionar.
- **Objeto em chamas entra na água:** apaga na hora, com o calor zerado, e fica Molhado.
- **Pavio aceso e Água:** o pavio para, como já acontece na lama.
- **Objeto dentro do Lamaçal recebe calor (correção da lacuna 2):** o calor é ignorado enquanto estiver
  lá, e a explosão ainda empurra.
- **Braseiro dentro do Lamaçal (correção da lacuna 1):** apaga enquanto a lama durar e reacende depois.
  Isso exige que a fonte de calor saiba quando está sobre água.
- **Explosão em Poça:** empurra e aquece normalmente; a água não blinda contra a onda de choque.
- **Dois efeitos no mesmo quadro:** a ordem não pode mudar o resultado. Água sempre vence Fogo no
  mesmo quadro.

## Dependencies (Dependências)

| Sistema | Relação |
|---|---|
| `PropMaterial`, `PhysicsProp`, `Explosion`, `HeatZone` | Implementam fogo e impacto (`physics-magic-system.md`, precisa citar este documento) |
| `MudPatch` | Primeira superfície (`mage-elementalist.md`, precisa citar este documento) |
| `TrainingDummy`, `FlyingTarget` | Recebem calor e impacto (`damage-and-testing.md`) |
| HUD e mira | Mostram estados, sempre por sinais |
| Sistema de estados em personagens | Ainda não existe; bloqueia a coluna Personagem |
| Teia | [Ideia 1](ideias-para-ygg.md); depende desta tabela |

Quando virar GDD, o arquivo precisa de dono: `design/gdd/elements-*` ainda não está em `donos.txt`, e a
frente natural é `gameplay`.

## Tuning Knobs (Ajustes)

Todos em `.tres`, nunca no código. Valores 💡 são pontos de partida para o playtest.

| Ajuste | Inicial | Faixa segura | Efeito |
|---|---|---|---|
| Fator de calor Molhado | 0,5 | 0,25–0,75 | Quanto molhar protege do fogo. Abaixo de 0,25, molhado vira imunidade |
| Duração Molhado | 15 s | 5–30 s | Janela para combinar água com outra coisa |
| Calor que encurta o Molhado | 1 s a cada 10 de calor | 5–30 de calor | Quão rápido o fogo seca |
| Atrito do Gelo | 0,05 | 0–0,2 | Abaixo de 0,02, dificulta sair do lugar |
| Velocidade com Frio | 0,8x | 0,6–0,9x | Não pode virar imobilização: isso é "congelar no ar" |

## Acceptance Criteria (Critérios de aceite)

**Automáticos, no teste de fumaça:**

- [ ] Caixa seca no braseiro acende em 1,5 s (± 0,2); Molhada, em 4 s (± 0,3).
- [ ] Pólvora Molhada a 10 m/s não explode; depois de secar, explode.
- [ ] Caixa em chamas na água apaga no quadro seguinte.
- [ ] Caixa dentro de lama e braseiro por 15 s não acende nenhuma vez.
- [ ] Metal e pedra ignoram 1.000 de calor sem mudar de estado.
- [ ] Trocar a ordem de Água e Fogo no mesmo quadro dá o mesmo resultado.

**Playtest, com o Liam:**

- [ ] Sem explicação, o jogador identifica um objeto Molhado só de olhar, em 3 de 3 tentativas.
- [ ] Depois de cada interação, o jogador sabe dizer por que aquilo aconteceu.
- [ ] O jogador tenta pelo menos uma combinação que não foi ensinada.

## Ordem sugerida

| Fase | O quê | Por quê |
|---|---|---|
| 0 | Aprovar este documento e corrigir as lacunas 1 e 2 | Barato; organiza o resto |
| 1 | Água, Poça e Molhado | Já existe campo de lama e dá mais combinações por menos trabalho |
| 2 | Teia | É a sua inspiração original e usa fogo e impacto, que já existem |
| 3 | Frio e Gelo | Precisa da Água |
| 4 | Eletricidade | Precisa de Água e do `conductive`, que já está reservado |

## Decisões para o Liam

1. **Regra 3:** aceitar impacto como exceção? *Recomendo sim*; sem ela, o barril atual quebra a regra.
2. **Lama e fogo:** o Lamaçal deve apagar o braseiro? *Recomendo sim*, enquanto a lama durar.
3. **Pólvora Molhada:** deixa de detonar por impacto? *Recomendo sim*; é crível e dá um uso defensivo
   à água.
4. **Fase seguinte:** Água primeiro ou Teia primeiro? *Recomendo Água*, mas a Teia pode vir antes se
   você quiser sentir logo a inspiração em jogo.

# Fórmulas contra o jogo: resultado

> Medido em 2026-11-02 com `tests/formulas_test.gd`, na física real do jogo (Jolt, 60 Hz), sem janela.
> Só cobre o que o jogo já simula: fórmulas de sistemas que não existem, como eletricidade, veneno e geologia,
> **não têm como ser testadas** ainda. Medir bater com a fórmula não prova que a sensação em jogo é boa.
> O código testado inclui a oclusão que a conversa principal estava fazendo, ainda sem commit.

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://tests/formulas_test.tscn
```

## O que bateu

| Fórmula | Previsto | Medido |
|---|---|---|
| Massa da caixa de madeira de 0,6 m | 19,44 kg | 19,44 kg |
| Dobrar o lado multiplica a massa | 8x | 8x |
| Madeira no braseiro: `100 / (80 − 15)` | 1,54 s | 1,57 s |
| Pólvora no braseiro: `60 / (80 − 10)` | 0,86 s | 0,88 s |
| Contágio com 1 caixa a 0,50 m | 7,18 s | 7,17 s |
| Contágio com 1 caixa a 0,62 m | 9,93 s | 9,92 s |
| Contágio com 1 caixa a 0,65 m | não acende | não acende |
| Contágio com 2 caixas a 1,00 m | 9,33 s | 9,32 s |
| Contágio com 3 caixas a 0,80 m | 2,33 s | 2,33 s |
| Explosão a 1 / 2,5 / 4 m | 11,11 / 6,94 / 2,78 m/s | 11,07 / 6,92 / 2,77 m/s |
| Parede corta a explosão a 15% | 1,04 m/s | 1,04 m/s, contra 6,93 sem parede |
| Primeira ignição na lama + braseiro | 6,67 s | 6,60 s |
| Pólvora por impacto: 8 m/s e 10 m/s | não explode, explode | não explodiu, explodiu |
| Arco com 20% de gravidade, em 2 s | 32 m / 3,92 m | 32 m / 3,95 m |

## O que o teste corrigiu

| Achado | Antes | Medido | Explicação |
|---|---|---|---|
| **Amortecimento escondido** | Parada = `v² / (2μg)` | Gelo de μ 0,02: 11,8 m, não 23,0 m | O projeto usa o amortecimento padrão de 0,1, que age como resistência do ar em todo objeto. Fórmula correta abaixo |
| **Molhado** (protótipo) | Tabela previa 4 s | 3,42 s | Faltou contar a secagem: o calor encurta o estado. A conta com secagem dá 3,39 s |
| **Fogo do topo da pirâmide** | Não previsto | Só a caixa do topo queima | As vizinhas estão a 0,68 m, além do limite de ~0,62 m |

```text
parada = v/c − (μg/c²) x ln(1 + c x v/(μg))     c = 0,1 por segundo
```

Com essa versão, os 6 casos medidos ficam dentro de 5%, e a distância não muda com a massa: 75 kg e 600 kg
pararam nos mesmos 1,07 m. Lamaçal e impacto também precisam dele: `6 x e^(−3,1)` = 0,27 m/s e 92,4 N·s, ambos iguais
ao medido.

**Consequência:** o gelo desliza metade do que a física pura prevê. Se quisermos gelo mais escorregadio, baixar o
atrito não adianta muito: é preciso reduzir o amortecimento de quem está sobre ele. Para decisão, depois do teste
do módulo.

## Medições novas

**Pirâmide, um só ponto de fogo.** Critério do GDD: menos de 20 s.

| Caixa acesa | Acesas | Última em |
|---|---|---|
| Canto da base | 10 de 10 | 18,9 s |
| Meio da base | 10 de 10 | 16,1 s |
| Topo | 1 de 10 | — |

Passa, mas por pouco: a base depende de 9,9 s de um limite de 10 s. Uma folga pequena na posição das caixas pode
interromper o fogo. O do topo é aceitável, porque fogo real sobe mais do que desce, mas o jogador pode esperar o
contrário. Vale olhar no playtest.

**Tunelamento.** Parede de 0,1 m, 10 tiros em fases diferentes:

| Velocidade | Por passo | Sem CCD | Com CCD |
|---|---|---|---|
| 80 m/s | 1,33 m | 9 atravessam | 0 |
| 37 m/s | 0,62 m | 8 atravessam | 0 |
| 5 m/s | 0,08 m | 0 atravessam | — |

Confirma a regra. A Bola de Fogo chega a 37 m/s e já usa CCD. **Atenção:** caixas e barris arremessados não usam, e
um objeto a 37 m/s passaria por uma parede fina. Não medi em qual velocidade isso começa com objetos do tamanho real.

**Lacuna 2 da tabela confirmada.** Na lama e no braseiro sem o módulo, a caixa acendeu e apagou 2 vezes em 15 s.

## Limites

- Os tempos têm folga de um quadro (~0,017 s) a cerca de 0,1 s.
- Atravessar parede foi medido com esferas de 5 cm, não com caixas.
- Módulo Molhado: o teste só roda se o laboratório existir; é pulado se for apagado.

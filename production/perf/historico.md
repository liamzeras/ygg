# Histórico do teste profundo

Uma linha por fase em cada medição. Medido com `bash tools/teste-profundo.sh medir`: sem vsync, sem limite de FPS,
janela de 1600 x 900. Meta: 1% mais lento ≥ 60, nenhum quadro acima de 16,7 ms e nenhum tranco (acima de 33 ms).
Compare só medições do mesmo computador.

| Data | Commit | Fase | FPS médio | 1% mais lento | >16,7 ms | Trancos | Observação |
|---|---|---|---|---|---|---|---|
| 2026-11-17 | acaeeaf | parado | 115 | 97 | 0 | 0 | Primeira medição (validação do módulo) |
| 2026-11-17 | acaeeaf | fisica | 98 | 18 | 12 | 1 | Pior quadro 180 ms, quando surgem 60 caixas e 4 barris |
| 2026-11-17 | acaeeaf | magia | 95 | 30 | 27 | 2 | 12 Bolas de Fogo; 361 draw calls em média |
| 2026-11-17 | acaeeaf | combate | 104 | 34 | 23 | 1 | Bot de combate |
| 2026-11-17 | 1c80dcc | parado | 109 / 107 | 72 / 59 | 0 / 3 | 0 / 0 | Rodadas 2 e 3, para o diagnóstico |
| 2026-11-17 | 1c80dcc | fisica | 97 / 95 | 23 / 21 | 3 / 9 | 1 / 1 | Tranco de 178 e 184 ms: repetido nas 3 rodadas |
| 2026-11-17 | 1c80dcc | magia | 98 / 101 | 68 / 52 | 1 / 6 | 0 / 0 | 1% mais lento instável (30 a 68): fases curtas |
| 2026-11-17 | 1c80dcc | combate | 111 / 96 | 71 / 44 | 2 / 3 | 0 / 1 | O bot não enxerga projéteis dentro do teste |

## Medição confiável (a partir de 2026-11-17)

Item 0 do diagnóstico. A arena entra como cena principal; aquecimento antes de medir; cada fase roda 3 vezes
de 7 s numa arena nova; a física virou `criacao` e `explosao`. Reprova com p99 acima de 33 ms ou um quadro
acima de 100 ms. **Não compare com a tabela de cima:** as fases mudaram. Duas rodadas seguidas, sem outro
Godot aberto, separadas por `/`.

| Data | Commit | Fase | FPS médio | 1% mais lento | ms p95 | ms p99 | >16,7 ms | Trancos | Observação |
|---|---|---|---|---|---|---|---|---|---|
| 2026-11-17 | cd0a250 | parado | 116 / 116 | 103 / 104 | 9,4 / 9,3 | 9,6 / 9,5 | 0 / 0 | 0 / 0 | Base nova |
| 2026-11-17 | cd0a250 | criacao | 114 / 109 | 97 / 88 | 9,9 / 11,1 | 10,2 / 11,2 | 0 / 0 | 0 / 0 | 60 caixas e 4 barris surgem sem tranco |
| 2026-11-17 | cd0a250 | explosao | 109 / 109 | 29 / 30 | 14,1 / 14,1 | 15,0 / 15,0 | 10 / 9 | 6 / 6 | **Reprova:** pior quadro 137 / 133 ms (item 1) |
| 2026-11-17 | cd0a250 | magia | 97 / 100 | 76 / 78 | 12,1 / 11,9 | 12,9 / 12,5 | 0 / 0 | 0 / 0 | 12 Bolas de Fogo por rodada |
| 2026-11-17 | cd0a250 | combate | 96 / 98 | 26 / 29 | 11,2 / 11,2 | 15,2 / 15,4 | 15 / 15 | 7 / 5 | **Reprova:** pior quadro 118 / 135 ms; o bot agora vê os projéteis |
| 2026-11-17 | 3cb0d0b | parado | 117 / 116 | 103 / 105 | 9,2 / 9,1 | 9,6 / 9,4 | 0 / 0 | 0 / 0 | Depois dos itens 0, 1, 2 e 7: igual |
| 2026-11-17 | 3cb0d0b | criacao | 115 / 114 | 101 / 99 | 9,7 / 9,8 | 9,9 / 10,0 | 0 / 0 | 0 / 0 | Igual |
| 2026-11-17 | 3cb0d0b | explosao | 110 / 109 | 55 / 52 | 12,0 / 12,7 | 15,0 / 17,6 | 8 / 32 | 0 / 0 | **Passa a aprovar:** pior quadro 29 / 26 ms (era 137 / 133) |
| 2026-11-17 | 3cb0d0b | magia | 98 / 95 | 79 / 75 | 12,1 / 12,4 | 12,5 / 13,0 | 0 / 0 | 0 / 0 | Igual |
| 2026-11-17 | 3cb0d0b | combate | 98 / 99 | 36 / 39 | 11,2 / 10,9 | 15,7 / 15,3 | 15 / 13 | 4 / 2 | **Passa a aprovar:** pior quadro 47 / 63 ms (era 118 / 135); ainda tem trancos |
| 2026-11-17 | 94fa63b | parado | 116 / 116 | 105 / 105 | 9,3 / 9,2 | 9,4 / 9,4 | 0 / 0 | 0 / 0 | Depois dos itens 4 e 6 (o 5 foi revertido): igual |
| 2026-11-17 | 94fa63b | criacao | 114 / 114 | 99 / 98 | 9,8 / 9,7 | 10,0 / 10,1 | 0 / 0 | 0 / 0 | Igual |
| 2026-11-17 | 94fa63b | explosao | 110 / 109 | 57 / 59 | 12,1 / 11,9 | 13,8 / 13,1 | 11 / 10 | 0 / 0 | p99 caiu (15,0 / 17,6 → 13,8 / 13,1); ainda com quadros acima de 16,7 ms |
| 2026-11-17 | 94fa63b | magia | 98 / 96 | 79 / 79 | 12,2 / 12,3 | 12,6 / 12,6 | 0 / 0 | 0 / 0 | Igual |
| 2026-11-17 | 94fa63b | combate | 100 / 101 | 66 / 63 | 11,0 / 11,0 | 11,4 / 11,4 | 5 / 5 | 1 / 1 | **1% mais lento passa de 60** (era 36 / 39); trancos 4 / 2 → 1 / 1 |

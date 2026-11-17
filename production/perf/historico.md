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

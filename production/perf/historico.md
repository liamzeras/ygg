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

# Diagnóstico do teste profundo: 2026-11-17

> Rodada 1 (`/teste-profundo diagnosticar`), commit `1c80dcc`. Computador do Liam: GTX 650 Ti Boost e
> i5-9400F, janela de 1600 x 900, sem vsync. Diagnóstico feito pelo `performance-analyst` e conferido no
> código pelo Sábio. **Itens 0, 1, 2, 3 e 7 aprovados pelo Liam e enviados ao orquestrador em 2026-11-17.**
> Itens 0, 1, 2 e 7 juntados em `3cb0d0b`; o 3 foi desfeito por não mudar a medição. **Itens 4, 5 e 6 aprovados pelo Liam e
> enviados ao orquestrador em 2026-11-17 (segunda rodada, foco no combate).** O 8 espera decisão de UX e o 9 espera a
> trava do `player.gd`.

## Medição (3 rodadas)

| Fase | FPS médio | 1% mais lento | >16,7 ms | Trancos | Pior quadro |
|---|---|---|---|---|---|
| Parado | 107 a 115 | 59 a 97 | 0 a 3 | 0 | 11 a 24 ms |
| Física | 95 a 98 | **18 a 23** | 3 a 12 | **1 em todas** | **178 a 184 ms** |
| Magia | 95 a 101 | 30 a 68 | 1 a 27 | 0 a 2 | 20 a 34 ms |
| Combate | 96 a 111 | 34 a 71 | 2 a 23 | 0 a 1 | 21 a 41 ms |

Meta: 1% mais lento ≥ 60, nenhum quadro acima de 16,7 ms e nenhum tranco. Hoje, só a fase parada chega perto.

**A medição é instável:** fases de 6 s dão só ~600 quadros, e o "1% mais lento" são 6 quadros. Por isso a magia
variou de 30 a 68. O tranco da física é o único achado firme, repetido nas 3 rodadas.

## Itens confirmados

Conferi no código cada causa marcada como confirmada. O custo exato de cada parte ainda é hipótese, a medir
antes e depois da correção.

| # | Problema | Causa (conferida) | Correção | Ganho esperado | Risco | Frente |
|---|---|---|---|---|---|---|
| 0 | Medição instável | Fases curtas e 1% calculado sobre 6 quadros. O bot de combate não enxerga os projéteis dentro do teste (`psionic_bot.gd:301` olha só os filhos diretos da cena, e no teste a arena não é a cena) | Fases de 20 s ou repetidas, p95 e p99, pré-aquecer efeitos, separar "criação" e "explosão", falhar acima de um limite, carregar a arena como cena principal | Base confiável para provar cada ganho | Nenhum | `qualidade` |
| 1 | Tranco de ~180 ms na física | Os 4 barris explodem no mesmo tick (`physics_prop.gd:97-100`). Cada explosão consulta até 64 corpos e até 8 raios por corpo (`explosion.gd`), cria pedaços com malha e material novos (`physics_prop.gd:351`, `:523`, `:538`), acende caixas com partículas e luz (`:172`) e chama `Fx.burst` (`:296`, `:329`) | Fila de explosões e quebras com limite por tick, pequena variação no pavio, reaproveitar pedaços e limitar efeitos por tick | De ~180 ms para menos de 33 ms | Médio: a cadeia de explosões atrasa alguns ms | `gameplay` |
| 2 | Efeitos criados do zero | `Fx.burst` cria partículas, luz, malha e material novos a cada chamada (`fx.gd`). A Bola de Fogo também cria material e malha próprios | Criar malhas e materiais uma vez só e reaproveitar os efeitos | 5 a 10 ms a menos nos piores quadros da magia (hipótese) | Baixo | `arte` (fx) e `classes` (projéteis) |
| 3 | Fogo e projéteis fazem sombra | O sol tem sombra (`test_arena.gd:129`), e só o Campo Lento desliga a sombra dos próprios efeitos (`slow_field.gd:44`) | Desligar a sombra de partículas, projéteis e textos 3D | Menos draw calls na magia (342 a 362 hoje, contra 222 parado) | Nenhum visível | `arte` e `classes` |
| 4 | O calor custa mais a cada objeto novo | Cada objeto queimando percorre todos os que recebem calor, a cada tick (`physics_prop.gd:211`). 60 caixas acesas dão ~3.900 checagens por tick | Buscar só no raio, ou espalhar o calor a cada 0,1 s | Menos tempo de física com muitas coisas queimando (hipótese) | Baixo | `gameplay` |
| 5 | Primeira compilação de efeitos | Hipótese: o material das partículas compila na primeira explosão | Pré-aquecer os efeitos ao carregar a arena | Menos tranco na primeira vez | Baixo | `mundo` |
| 6 | O bot varre a cena toda | `psionic_bot.gd:301` percorre os filhos da cena a cada tick para achar projéteis | Grupo próprio de projéteis e checagem a cada 0,1 s | Pequeno | Baixo | `monstros` |
| 7 | Sem configuração de exportação | Não existe `export_presets.cfg`. Nenhum arquivo do jogo carrega o laboratório, então ele pode ficar fora | Preset Windows que exclui `.claude`, `design`, `docs`, `production`, `tests`, `tools`, o laboratório e o Godot | Instalador só com o jogo, ~17 MB a menos | Baixo | `fundacao` |
| 8 | Qualidade gráfica fixa | MSAA 2x, SSAO e brilho sempre ligados (`project.godot`, `test_arena.gd:120-121`), pesados numa GTX 650 Ti. O vsync já vem ligado (`settings.gd:17`) | Opção de qualidade nas Configurações e sombra do sol mais curta | Folga em PCs fracos | **Decisão de UX sua** | `interface` e `mundo` |
| 9 | Arquivos grandes | `player.gd` tem 972 linhas (limite 400) e `physics_prop.gd` 541, misturando forma, calor e quebra | Separar movimento em `player.gd`; separar construção, calor e quebra em `physics_prop.gd` | Organização; ajuda os itens 1, 2 e 4 | Médio: `player.gd` tem trava | `gameplay` |

## Recomendação do Sábio

1. **Item 0 primeiro.** Sem ele, não dá para provar se as outras correções melhoram alguma coisa.
2. Depois, **1, 2 e 3** juntos, em frentes diferentes. São os que atacam as quedas que você sente.
3. **7** em paralelo, porque não mexe no jogo.
4. **4, 5 e 6** numa segunda rodada, medindo de novo.
5. **8** espera a sua decisão de UX, e **9** espera a trava do `player.gd`.

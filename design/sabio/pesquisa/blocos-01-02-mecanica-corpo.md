# Blocos 1 e 2: mecânica e corpo (pesquisa do Sábio)

> Criado em 2026-11-01. Material de pesquisa, não GDD: nada aqui muda o jogo sem aprovação do Liam.
> Marcas: sem marca = conferido na fonte citada; `[memória, a confirmar]`; `[fonte fraca]`.
> Itens cobertos: 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 23, 24, 25, 26, 27. O item 6 (atrito) já está em [contexto-fisico.md](contexto-fisico.md); só somo os valores de gelo e óleo no item 7.
> Fórmulas de livro-texto sem link levam `[memória, a confirmar]`. Contas de exemplo são do Sábio.

## Resumo para decidir

- **Teto de 25 m/s (item 18):** serve para a velocidade da *mão ou arma* de quem ataca (humano comum soca a ~12 m/s), mas é baixo demais como teto de *arremesso* (humano comum de elite já passa de 28 m/s com dardo e 47 m/s com bola). Sugestão no item 18.
- **Dano (item 4):** energia decide dano e quebra; momento decide empurrão e quem voa. Os dois já saem de `massa` e `velocidade`.

## Bloco 1: Mecânica e movimento

### 1. Leis de Newton [P1]
- **Regra:** sem força líquida, o movimento não muda; força líquida acelera o corpo (inverso da massa); toda força tem reação igual e contrária.
- **Fórmula:** `F = m x a` (N = kg·m/s²). Empurrar 80 kg com 400 N: `a = 5 m/s²`. `[memória, a confirmar]`
- **Valores:** `g` = 9,81 m/s² `[memória, a confirmar]`.
- **Para o Ygg:** a Jolt já faz isso. Falta só garantir que o jogador também receba a reação (recuo ao empurrar ou lançar algo pesado).
- **Ideia:** lançar uma pedra pesada em pé sobre gelo empurra o jogador para trás; usar a reação para atravessar um lago escorregadio.

### 2. Conservação do momento linear [P1]
- **Regra:** em colisão, a soma `m x v` antes é igual à soma depois. O leve voa, o pesado quase não muda.
- **Fórmula:** `v2' = (1+e) x m1 x v1 / (m1+m2)`. 80 kg a 10 m/s contra 20 kg parado, `e = 0,5`: o leve sai a 12 m/s e o pesado fica a 7 m/s. `[memória, a confirmar]`
- **Valores:** `e` no item 5.
- **Para o Ygg:** a Jolt resolve; o que falta é o jogo respeitar isso nas magias de empurrão (aplicar impulso `J`, não velocidade direta).
- **Ideia:** barril rolando acerta um inimigo leve e para quase parado diante de um pesado; o jogador aprende quem empurrar.

### 3. Impulso e tempo de contato [P1]
- **Regra:** a mudança de momento é `F média x tempo`. O mesmo impulso em 5 ms é força enorme; em 0,5 s é suave.
- **Fórmula:** `J = F x Δt = Δp`. Com `Δp = 20 kg·m/s`: 5 ms dá 4000 N; 0,5 s dá 40 N. `[memória, a confirmar]`
- **Valores:** não encontrado em fonte.
- **Para o Ygg:** golpe = impulso único (`apply_impulse`); empurrão contínuo = força por vários quadros. Dano de golpe usa pico, empurrão não.
- **Ideia:** martelo quebra a porta (pico alto); um gigante só encosta e empurra a mesma porta sem quebrar.

### 4. Energia cinética versus momento: o que decide o dano [P1]
- **Regra:** o momento (`mv`) se conserva e decide quem voa. A energia (`½mv²`) é o que se gasta para deformar, quebrar e penetrar; ela não se conserva nas batidas.
- **Fórmula:** 1 kg a 10 m/s: `p = 10`, `E = 50 J`. 10 kg a 1 m/s: `p = 10`, `E = 5 J`. Mesmo empurrão, 10x menos estrago. `[memória, a confirmar]`; ver perda `(1−e²)` em [Wikipedia](https://en.wikipedia.org/wiki/Coefficient_of_restitution).
- **Para o Ygg:** **recomendação (proposta):** dano e quebra por energia; empurrão e knockback por momento. Evita a flecha lenta e pesada matar mais que a rápida, e o martelo "pesado" rápido virar absurdo.
- **Ideia:** uma lâmina leve e rápida corta, um tronco lento só empurra: a mesma força de 8x faz coisas diferentes.

### 5. Coeficiente de restituição [P1]
- **Regra:** é uma propriedade do *par*, não de um objeto. 0 = gruda, 1 = elástico; depende da velocidade.
- **Fórmula:** `e = √(h_quique / h_queda)`: cai de 1 m, sobe 0,64 m, `e = 0,8`. Energia perdida `∝ (1−e²)`. [Wikipedia](https://en.wikipedia.org/wiki/Coefficient_of_restitution)
- **Valores:** bolas de esporte: tênis 0,85 (referência), mesa 0,89–0,92, basquete 0,76–0,78 (mesma fonte). Experimento de escola (queda de 92 cm sobre concreto, 5 tentativas, sem incerteza informada): bola de borracha 0,83; golfe 0,86; bilhar 0,80; tênis 0,71; vidro 0,66; madeira 0,60; rolamento de aço 0,60 ([Hypertextbook](https://hypertextbook.com/facts/2006/restitution.shtml)). Atenção: é restituição *bola-concreto*, não do material puro, e o aço dá o mesmo que a madeira, o que mostra que o par importa. Pedra e lama: não encontrado (a ToolBox deu 404). Ordem sugerida: barro ~0, madeira e pedra médio-baixo, borracha alto.
- **Para o Ygg:** `bounce` da Godot é somado entre os dois corpos; `absorbent` subtrai ([docs](https://docs.godotengine.org/en/stable/classes/class_physicsmaterial.html)). Não é produto do par real, então tabelar valores baixos (0–0,5) e testar.
- **Ideia:** bola de borracha rebate flecha de volta em corredor; lama absorve a mesma bola.

### 7. Atrito de rolamento [P2]
- **Regra:** rolar custa muito menos que arrastar, e depende do chão.
- **Fórmula:** `F = Crr x m x g`. 100 kg em cascalho (`Crr` 0,05): ~49 N.
- **Valores:** [ToolBox](https://www.engineeringtoolbox.com/rolling-friction-resistance-d_1303.html) (para pneus): aço sobre trilho 0,001–0,002; pneu em concreto 0,01–0,015; areia compacta 0,04–0,08; areia solta 0,2–0,4. Pedra redonda, barril de madeira: não encontrado. Apoio de atrito deslizante: gelo sobre gelo 0,1 (est.) e 0,02 (din.) a 0 °C; aço sobre aço com óleo de rícino 0,15/0,081 ([ToolBox](https://www.engineeringtoolbox.com/friction-coefficients-d_778.html)).
- **Para o Ygg:** a Godot não tem atrito de rolamento; usar `angular_damp` conforme o chão (areia alta, pedra lisa baixa).
- **Ideia:** barril desce a ladeira com ritmo diferente em lama, areia e gelo.

### 8. Centro de massa e tombamento [P1]
- **Regra:** tomba quando a vertical do centro de massa sai da base de apoio.
- **Fórmula:** caixa de largura `b`, centro a altura `h`: `θ = atan(b/2 / h)`; energia para tombar `E = m x g x (√((b/2)²+h²) − h)`. Caixa 1 m de largura, centro a 0,5 m, 100 kg: 45° e ~203 J. `[memória, a confirmar]`
- **Valores:** não aplicável.
- **Para o Ygg:** a Jolt faz sozinha desde que o centro de massa esteja certo; falta checar objetos compostos e pilhas (altas e estreitas devem cair mais fácil).
- **Ideia:** tirar o apoio de baixo de uma torre de caixas derruba tudo em cadeia.

### 9. Torque e momento de inércia [P2]
- **Regra:** girar algo custa mais quanto mais a massa fica longe do eixo.
- **Fórmula:** `τ = I x α`; barra uniforme: `I = mL²/12` (pelo centro), `mL²/3` (pela ponta). Barra 1,2 kg e 1 m girada pela ponta: `I = 0,4 kg·m²`; a 10 rad/s, ponta a 10 m/s e 20 J. `[memória, a confirmar]`
- **Valores:** não encontrado.
- **Para o Ygg:** a Jolt calcula a inércia pelas formas; o útil é dar às armas ponta pesada (machado) ou cabo (adaga) e deixar o balanço diferente.
- **Ideia:** lança longa é lenta de virar em corredor; a adaga gira rápido.

### 10. Conservação do momento angular [P2]
- **Regra:** sem torque externo, `L = I x ω` fica igual. Encolher o corpo gira mais rápido.
- **Fórmula:** `I` cai à metade, `ω` dobra. `[memória, a confirmar]`
- **Valores:** não encontrado.
- **Para o Ygg:** objetos arremessados já giram na Jolt; falta decidir se a rotação some com `angular_damp` (sim, barato).
- **Ideia:** facas e machados arremessados cravam só se a rotação acerta o ângulo (distância certa), recompensando a leitura do alvo.

### 11. Alavancas, polias e vantagem mecânica [P2]
- **Regra:** troca-se força por distância; o trabalho não aumenta.
- **Fórmula:** `F1 x d1 = F2 x d2`; polia com `n` cordas: `MA = n`. Pé de cabra de 1,5 m com 0,15 m do apoio: MA 10 (arredonda a 9 se não contar o braço do apoio); 400 N levantam ~4000 N (~400 kg). `[memória, a confirmar]`
- **Valores:** não encontrado.
- **Para o Ygg:** alavanca como `Joint`/ferramenta que multiplica o empurrão do jogador com atrito perdido. Custo médio.
- **Ideia:** mover pedra de 800 kg com tronco e apoio: solução criativa sem magia, alinhada ao pilar 3.

### 12. Trabalho e potência [P2]
- **Regra:** levantar custa `m x g x h`; potência é trabalho por segundo; o músculo converte só parte da energia química em trabalho.
- **Fórmula:** `W = m g h`; `P = W/t`. 80 kg subindo 2 m: ~1570 J; em 2 s, ~785 W. Eficiência muscular ~25% `[memória, a confirmar]`.
- **Valores:** custo metabólico: ver item 23.
- **Para o Ygg:** consumir Vigor por `m x g x Δh` ao carregar e escalar. Barato.
- **Ideia:** subir o barril de pólvora até o telhado cansa; rampa e polia economizam Vigor.

### 13. Balística com gravidade [P1]
- **Regra:** sem ar, trajetória é uma parábola; alcance máximo a 45° se a altura de soltura e de chegada forem iguais.
- **Fórmula:** `R = v² x sin(2θ) / g`. 30 m/s a 45°: 92 m. Dardo a 29,7 m/s e 35° dá ~83 m sem ar nem altura de soltura; o vencedor de 1999 fez 89,52 m ([NEA/IAAF](https://www.uv.es/jcampos/Documentos/NEA_IAAF_MenJavelin.pdf)), logo a conta bate em ordem de grandeza.
- **Valores:** velocidades de soltura, ver item 18.
- **Para o Ygg:** a Jolt já faz a parábola; falta o arrasto (item 14) e uma linha de mira preditiva para o jogador "entender por que".
- **Ideia:** arco de longo alcance só acerta se o jogador corrigir a queda; magia mais fraca tem trajetória menos plana.

### 14. Arrasto e velocidade terminal [P1]
- **Regra:** a força do ar cresce com `v²`; a queda acelera até equilibrar o peso.
- **Fórmula:** `F = ½ ρ Cd A v²`; `v_t = √(2 m g / (ρ Cd A))`. Pedra esférica de 1 kg (densidade 2400, `A` = 0,0068 m², `Cd` 0,47, `ρ` do ar 1,2): ~72 m/s.
- **Valores:** esfera lisa `Cd` ≈ 0,47; placa plana 3D ≈ 1,28 ([Wikipedia](https://en.wikipedia.org/wiki/Drag_coefficient)); paraquedista de barriga ~55 m/s, de cabeça ~150 m/s ([Wikipedia](https://en.wikipedia.org/wiki/Terminal_velocity)). Objeto maior do mesmo material tem `v_t` maior (peso `∝ s³`, arrasto `∝ s²`).
- **Para o Ygg:** `linear_damp` da Godot é arrasto linear, não quadrático; para flechas leves aplicar `-k x |v| x v` por quadro via script (um vetor). Descartar variação de densidade do ar.
- **Ideia:** pena e pedra caem diferente; flecha de ponta larga freia mais.

### 16. Pressão como força por área [P2]
- **Regra:** a mesma força concentra mais pressão em área pequena: ponta fura, martelo amassa.
- **Fórmula:** `P = F / A`. 1000 N em ponta de 1 mm² = 1 GPa; em face de 100 cm² = 100 kPa. `[memória, a confirmar]`
- **Valores:** resistência de pele e madeira à perfuração: não encontrado.
- **Para o Ygg:** dano de perfuração = energia ÷ área da ponta do projétil, comparada ao `yield_threshold` do material. Um campo `tip_area` no projétil.
- **Ideia:** a mesma flecha fura gibão de couro, mas é parada por placa; a clava amassa mas não fura.

## Bloco 2: Corpo e limites humanos

### 18. Limites humanos: régua do "1x" [P1]
- **Regra:** medidas de atletas de elite mostram o teto humano; um golpe chega a ~12 m/s na mão, e o arremesso, a dezenas de m/s dependendo da massa do objeto.
- **Fórmula:** salto: `v = √(2 g h)`; 0,6 m dá 3,4 m/s de decolagem. Energia de arremesso é limitada por potência, então objeto mais pesado sai mais lento.
- **Valores (medidos):**
  - Sprint: pico 12,42 m/s entre 70 e 90 m (estudo cinemático, Zagreb 2011; outro trecho dá 12,14 m/s; análise a laser dá ~12,3 m/s) ([IAT](https://lida.sport-iat.de/ta/Record/4058152?lng=en), [FUPES](https://casopisi.junis.ni.ac.rs/index.php/FUPhysEdSport/article/view/4984)).
  - Soco: faixa-preta de caratê 12,3 m/s, faixa-branca 10,6 m/s; gancho de boxeador amador 11,95 ± 1,84 m/s (amostras de 5 e 15 pessoas) ([Konstanz](https://ojs.ub.uni-konstanz.de/cpa/article/view/1519/1424)).
  - Dardo: soltura de elite 28,24 ± 0,87 m/s ([UTAD](https://repositorio.utad.pt/handle/10348/9981?mode=full)); campeão mundial de 1999 a 29,7 m/s ([NEA/IAAF](https://www.uv.es/jcampos/Documentos/NEA_IAAF_MenJavelin.pdf)); nível regional 23–26,3 m/s ([Konstanz](https://ojs.ub.uni-konstanz.de/cpa/article/view/637/562)).
  - Bola de beisebol: 47,3 m/s (105,8 mph, Chapman, 2010) ([Wikipedia](https://en.wikipedia.org/wiki/Fastball)). Massa da bola ~0,145 kg `[memória, a confirmar]`.
  - Levantamento: 460,4 kg raw (2011) e 510 kg em strongman (2025) ([Wikipedia](https://en.wikipedia.org/wiki/Deadlift)).
  - Salto parado (recorde): 1,70 m (Christopher Spell, EUA, 7/2/2021), que supera o 1,61 m de Evan Ungar (2016) que eu havia citado; o Guinness não descreve o método de medição ([Guinness](https://www.guinnessworldrecords.com/world-records/highest-standing-jump)). Salto típico de atleta de elite em laboratório (~50-60 cm): sem fonte conferida, não encontrado. Decolagem a 1,70 m seria `√(2g·1,7)` = 5,8 m/s.
- **Para o Ygg (avaliação do teto de 25 m/s):**
  - **Mão, punho, ponta de arma em golpe:** 25 m/s é ~2x o soco de elite. Como teto de 8x faz sentido. Atenção: 8x linear no sprint daria 99 m/s (~357 km/h), violando o pilar 1.
  - **Arremesso:** 25 m/s é *baixo demais*, porque o humano de elite já lança 28–47 m/s. Não use um teto único. Proposta: velocidade de soltura limitada por energia, `v = √(2 E_max / m)`, com teto absoluto em torno de 50–60 m/s para objetos leves.
  - Regra geral: os atributos 8x entram principalmente em força e capacidade; velocidade cresce devagar (ver Hill em [contexto-fisico.md](contexto-fisico.md)).
- **Ideia:** soltar um tronco de 50 kg a 8x vira projétil pesado e lento; a pedrinha vira bala. O jogador escolhe pelo tipo de estrago.

### 20. Tolerância à aceleração e à queda [P1]
- **Regra:** o corpo suporta o impacto conforme a *distância de frenagem* e a direção; picos curtos são toleráveis, constantes não.
- **Fórmula:** `v = √(2 g h)`; 6 m dá 10,8 m/s; frenagem em 0,3 m: `a = v²/2d ≈ 194 m/s² ≈ 20 g`. `[memória, a confirmar]`
- **Valores:** sem treino, ~5 g vertical sustentado causa desmaio; pilotos com traje, ~9 g; Stapp sobreviveu a 46,2 g em trenó; pico de 214 g sobrevivido em acidente de automobilismo ([Wikipedia](https://en.wikipedia.org/wiki/G-force)). Queda (revisão em [PMC3212924](https://pmc.ncbi.nlm.nih.gov/articles/PMC3212924)): corte de triagem do ACS-COT em 6 m (20 pés); lesões de sobreviventes concentram-se abaixo de 20-25 pés; 100% de mortalidade a partir de ~8 andares (90-100 pés) em 287 vítimas (Lapostolle); 101 sobreviventes de queda vertical (Richter) tinham altura média de 7,2 m; mais comum: fratura de coluna e membros inferiores; morte vem de lesão no cérebro e na cervical. Há um caso isolado de sobrevivência a 300 pés. Superfície, postura e idade importam tanto quanto a altura. Fontes web que falavam em 48 pés e 12 m/s seguros eram blogs e fóruns, e não as usei.
- **Para o Ygg:** dano de queda `∝ energia absorvida acima de um limiar`, reduzido por superfície (lama, água, neve) e por atributo. Aceitar que 8x multiplica o limiar.
- **Ideia:** cair em lama ou lago zera o dano; cair de lado em pedra dói mais.

### 22. Centro de gravidade e equilíbrio [P2]
- **Regra:** em pé, o equilíbrio é um pêndulo invertido: tomba se o centro passa o limite do pé; pessoas se recuperam dando um passo.
- **Fórmula:** centro a 1 m e meia largura do pé 0,15 m: `θ = atan(0,15/1) = 8,5°`; energia p/ tombar `m g (√(0,15²+1²) − 1)`, 80 kg: ~8,8 J. `[memória, a confirmar]`
- **Valores:** não encontrado.
- **Para o Ygg:** estado de cambaleio quando o impulso recebido passa um limiar proporcional a `massa x estabilidade`; carregar peso eleva o centro e baixa o limiar. Só um número.
- **Ideia:** com carga nas costas, a rajada de vento ou um empurrão derruba na beira do penhasco.

### 23. Custo energético de correr e carregar [P2]
- **Regra:** carga, velocidade, inclinação e terreno aumentam o gasto.
- **Fórmula:** Pandolf: `M = 1,5W + 2,0(W+L)(L/W)² + η(W+L)(1,5V² + 0,35VG)` (W, de watts). Para `W` 75 kg, `L` 20 kg, `V` 1,34 m/s, plano, `η` 1: ~382 W; sem carga: ~315 W; na areia solta (`η` 2,1): ~664 W ([Wikipedia](https://en.wikipedia.org/wiki/Pandolf_equation)).
- **Valores:** `η` asfalto 1,0; estrada de terra 1,1; mato leve 1,2; pesado 1,5; pântano 1,8; areia solta 2,1; neve de 15 cm 2,5; 25 cm 3,3; 35 cm 4,1 (mesma fonte). Estudo com 39 soldados: as equações costumam *subestimar* ([Chichester](https://eprints.chi.ac.uk/5152)).
- **Para o Ygg:** um multiplicador de terreno no gasto de Vigor reaproveita a tabela de `η`. Baixíssimo custo.
- **Ideia:** neve funda e carga pesada esgotam o Vigor muito antes da mesma carga na estrada.

### 24. Metabolismo e ATP [P2]
- **Regra:** esforço máximo usa a reserva imediata (fosfocreatina) por poucos segundos; depois entram vias mais lentas.
- **Fórmula:** modelo em 3 reservas: curta, média e longa, cada uma com taxa de recarga. Proposta do Sábio.
- **Valores:** a fosfocreatina sustenta os primeiros 5–8 s de esforço máximo ([Wikipedia](https://en.wikipedia.org/wiki/Phosphocreatine), com marca de "precisa de citação" na própria página) `[fonte fraca]`. Tempos das outras vias: não encontrado.
- **Para o Ygg:** duas barras bastam: explosão (recarrega em segundos) e fôlego (minutos). Barato.
- **Ideia:** investida de 8x esgota a barra curta; o jogador planeja o salto antes da luta.

### 25. Ácido lático e recuperação [P2]
- **Regra:** abaixo do limiar o corpo remove o lactato na mesma taxa em que produz; acima, ele acumula e o cansaço cresce.
- **Fórmula:** modelo de potência crítica: reserva `W'` gasta quando a potência passa de `P_crit` e recupera abaixo. `[memória, a confirmar]`
- **Valores:** lactato em repouso 1–2 mmol/L; limiar ~2; acúmulo a 4 mmol/L ([Wikipedia](https://en.wikipedia.org/wiki/Lactate_threshold)). Limpeza após esforço máximo (10 atletas, bicicleta a 150% do VO2max): meia-vida do lactato de 15,7 ± 2,5 min com recuperação ativa a 30% do VO2max, 21,8 ± 3,5 min com massagem e 21,5 ± 2,8 min parado ([PubMed 8833711](https://pubmed.ncbi.nlm.nih.gov/8833711/)). Outro estudo (Denadai 2000, só pelo resumo da busca, não abri) dá ~8-13 min ativo e ~19-26 min parado; amostras pequenas.
- **Para o Ygg:** correr abaixo de `P_crit` não cansa; acima, drena uma reserva e o descanso recarrega mais devagar quando está vazia.
- **Ideia:** ritmo constante cruza o mapa; sprintar toda hora te deixa sem fôlego diante do inimigo.

### 26. Lesões por impacto, corte e perfuração [P2]
- **Regra:** o tipo de lesão depende de como a energia é concentrada: espalhada (contusão, osso), em linha (corte), em ponto (perfuração).
- **Fórmula:** trabalho de penetração `W ≈ F x profundidade`; mesma energia, menor área, maior profundidade (ver item 16). `[memória, a confirmar]`
- **Valores:** forças de ruptura de pele, osso e músculo: não encontrado (não abri fonte médica).
- **Para o Ygg:** três tipos de dano (contusão, corte, perfuração) com efeitos diferentes: contusão atordoa e quebra, corte sangra, perfuração atravessa e causa dano profundo. Tipo vem da forma do projétil, e a energia, do item 4.
- **Ideia:** armadura acolchoada para contusão e malha para corte; o jogador troca de equipamento conforme o inimigo.

### 27. Tempo de reação e percepção [P3]
- **Regra:** não se reage a um estímulo em menos de ~100–200 ms; mais opções, mais demora.
- **Fórmula:** Hick: `TR = a + b x log2(n+1)`.
- **Valores:** simples, sonoro ~160 ms e visual ~190 ms; sprinters olímpicos 166/169 ms (homens/mulheres) em Pequim 2008; falsa largada abaixo de 100 ms; casos de 80–85 ms são controversos ([Wikipedia](https://en.wikipedia.org/wiki/Reaction_time), citando Kosinski 2008).
- **Para o Ygg:** esquiva exige telegrafar o golpe por ≥ 0,2 s; um personagem 8x não reage 8x mais rápido (propor teto perto de 100 ms). Inimigos com ataque mais curto que isso não são justos.
- **Ideia:** monstro grande telegrafa devagar (pilar 4); o jogador sempre vê a causa.

## Pendências e lacunas

- Todos os itens listados no início estão preenchidos, mas **vários só com fórmula de livro-texto marcada como memória** (1–3, 8–12, 16, 22, 25, 26). Convém conferir antes de virar regra.
- **Segunda passada (2026-11-01):** fechados com fonte aberta: restituição de madeira, aço e vidro (Hypertextbook; valor bola-concreto), recorde de salto parado (Guinness: 1,70 m, corrige o 1,61 m), queda (PMC3212924, no lugar do boletim), meia-vida do lactato (PubMed 8833711).
- **Continua sem fonte:** restituição de pedra e lama; atrito de rolamento de barris e pedras; resistência de pele e osso à perfuração; tempos das vias energéticas além dos 5–8 s (Wikipedia, com aviso de citação `[fonte fraca]`); salto de atleta de laboratório; método de medição do recorde de salto; todas as fórmulas de livro-texto marcadas como memória (HyperPhysics deu 404/erro de certificado).
- Item 6 (atrito) e itens 15, 17, 19, 21 não eram meus (ver outros blocos).

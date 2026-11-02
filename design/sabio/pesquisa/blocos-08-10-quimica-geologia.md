# Blocos 8 e 10: química prática e geologia (itens 88-99 e 110-120)

> Criado em 2026-11-01 pelo Sábio. Conhecimento, não decisão. Marcas: sem marca = conferido na fonte citada;
> `[memória, a confirmar]`; `[fonte fraca]` = só vi em trecho de busca ou fonte secundária.
> Fórmulas de livro-texto sem fonte aberta levam a marca de memória. Nada aqui ensina síntese; só efeitos
> observáveis e modelos simplificados.

## Bloco 8: química prática

### 88. Oxidação e redução [P1]
- **Regra:** oxidação é o material perder elétrons para o oxigênio. Fogo é a oxidação rápida e quente; ferrugem é a lenta e fria. É a mesma química com velocidades diferentes. `[memória, a confirmar]`
- **Fórmula:** perda de espessura `d = r × t` (µm = µm/ano × anos). Aço de 3 mm a 50 µm/ano: 3000/50 = 60 anos para sumir.
- **Valores:** a norma ISO 9223 classifica o ar por quanto aço comum perde no 1º ano: C1 ≤ 1,3 µm [fonte fraca: [tabela no artigo MDPI](https://pmc.ncbi.nlm.nih.gov/articles/PMC8467660/table/materials-14-05219-t001), visto só em trecho]. Faixas C2 a C5 (≈ 1,3 a 200 µm/ano) `[memória, a confirmar]`.
- **Para o Ygg:** ferrugem como número `corrosão` (0 a 1) por peça, que sobe com o tempo e com umidade. Hoje não existe; o `heat` já cobre o lado rápido.
- **Ideia:** a mesma peça de ferro "arde" no fogo e "enferruja" na água do Lamaçal: um único estado `oxidado` com duas velocidades, fácil de o jogador entender.

### 89. Corrosão e ferrugem (água e sal) [P2]
- **Regra:** água e sal formam o eletrólito que acelera a ferrugem; o ar litorâneo é bem mais agressivo que o seco.
- **Fórmula:** `d = k × tⁿ` (n ≈ 0,5 a 1; k = perda no 1º ano) `[memória, a confirmar]`. Com k = 40 µm e n = 0,6, em 10 anos: 40 × 10^0,6 ≈ 159 µm.
- **Valores:** multiplicador exato de sal sobre água doce: não encontrado em fonte aberta. Categorias de ambiente (C1 interior seco até C5 marinho) da ISO 9223 `[memória, a confirmar]`.
- **Para o Ygg:** multiplicador por ambiente (seco 1x, úmido 3x, salino 6x são valores de jogo, não medidos) aplicado ao ritmo da `corrosão`. Custo baixo: um número por zona.
- **Ideia:** a armadura de aço dura semanas num pântano ou costa e anos no deserto; o jogador lê o clima e carrega óleo ou troca de equipamento.

### 90. Corrosão galvânica [P2]
- **Regra:** dois metais diferentes em contato, com água entre eles, formam uma pilha. O menos nobre (lista abaixo) corrói e protege o mais nobre.
- **Fórmula:** a razão de áreas ânodo/cátodo afeta diretamente a taxa de corrosão, e a série padrão é medida em água do mar aerada, à temperatura ambiente ([Wikipedia: corrosão](https://en.wikipedia.org/wiki/Corrosion), aberta; a página também lista a salinidade entre os fatores). A corrosão cresce com `ΔV` e com `A_cátodo / A_ânodo` (a proporção exata é qualitativa). Rebite pequeno de ferro numa placa grande de cobre: razão alta, rebite some depressa. Qualitativo (a série não dá taxas).
- **Valores:** [série galvânica em água do mar](https://www.engineeringtoolbox.com/metals-galvanic-series-seawater-d_1495.html), do mais nobre ao menos: platina, ouro, grafite, titânio, prata, aço inox, níquel, cobre/latão, estanho, chumbo, ferro fundido, aço-carbono, alumínio, aço galvanizado, zinco, magnésio. Limiar de risco ~0,2 a 0,25 V `[fonte fraca]`.
- **Para o Ygg:** uma lista ordenada de "nobreza" por metal; ao encostar dois metais molhados, o de menor posição ganha `corrosão`. Barato, só tabela.
- **Ideia:** pregos de ferro numa armadura de bronze apodrecem; uma lasca de zinco de drop prende no casco do barco e o protege (reagente "sacrificial").

### 91. Ácidos e bases [P2]
- **Regra:** pH mede acidez numa escala logarítmica; cada passo é 10 vezes. Ácidos dissolvem metais e calcário; bases dissolvem gordura e queimam pele; juntos se neutralizam.
- **Fórmula:** `pH = −log10[H⁺]` (mol/L). Vinagre 0,1 N (pH 2,9) e soda cáustica 0,1 N (pH 13,0) diferem 10,1 passos, ou ~10¹⁰ em [H⁺].
- **Valores:** [bases, ToolBox](https://www.engineeringtoolbox.com/bases-ph-d_402.html): NaOH 1 N = 14,0; 0,1 N = 13,0; cal saturada 12,4; amônia 1 N = 11,5; bicarbonato 0,1 N = 8,4. Ácido acético (vinagre): 1 N = 2,4; 0,1 N = 2,9; 0,01 N = 3,4 ([ToolBox ácidos](https://www.engineeringtoolbox.com/acids-ph-d_401.html), aberta).
- **Para o Ygg:** `pH` de 0 a 14 por substância/poça; dano de contato = distância de 7; neutralizar = média ponderada pelo volume (simplificação, não é exato). Cor da poça mostra o pH.
- **Ideia:** ácido de monstro corrói a porta de ferro; jogar cinza ou cal (base) na poça a neutraliza antes de atravessar.

### 92. Lei de Arrhenius [P2]
- **Regra:** reações ficam mais rápidas com o calor; a regra de bolso é que "muitas vezes" dobram a cada 10 °C, mas a própria fonte avisa que isso não vale sempre, sobretudo quando é preciso romper uma ligação covalente forte ([LibreTexts](https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Supplemental_Modules_(Physical_and_Theoretical_Chemistry)/Kinetics/06%3A_Modeling_Reaction_Kinetics/6.02%3A_Temperature_Dependence_of_Reaction_Rates/6.2.03%3A_The_Arrhenius_Law/6.2.3.01%3A_Arrhenius_Equation), aberta).
- **Fórmula:** `k = A·e^(−Ea/RT)`; `R = 8,314 J/mol·K` (mesma fonte). Com Ea = 50 kJ/mol, de 300 K para 310 K: e^(6014 × 1,075×10⁻⁴) = e^0,647 ≈ 1,9x.
- **Valores:** Ea de reações reais: não encontrado em fonte aberta.
- **Para o Ygg:** `velocidade = 2^((T − T_base)/10)` com teto. Aplica-se à ferrugem, cura de resina, decomposição e reações de reagentes. Custo baixo, uma potência.
- **Ideia:** a poção de reagentes prepara em 10 s ao lado da fogueira e em 40 s no frio; o jogador entende por que "ferver" ajuda.

### 93. Reações exotérmicas e endotérmicas [P2]
- **Regra:** algumas reações liberam calor (cal viva com água), outras o absorvem (compressas frias).
- **Fórmula:** `ΔT = Q / (m × c)`. CaO + H₂O libera ≈ 64 kJ/mol (56 g de CaO); em 1 kg de água (c = 4,186 kJ/kg·K): 63,7/4,186 ≈ 15,2 °C. Em 100 g de água a conta daria ≈ 150 °C, ou seja, ferve (a conta ignora a evaporação).
- **Valores:** ΔH = −63,7 kJ/mol de CaO; na demonstração a temperatura "pode chegar a uns 300 °C"; a água pode liberar calor suficiente para acender combustíveis ([Wikipedia: óxido de cálcio](https://en.wikipedia.org/wiki/Calcium_oxide), aberta; a própria página pede fonte melhor para a frase da ignição). Divergência: um exercício de livro-texto dá −65,2 kJ/mol [fonte fraca, trecho de busca]; uma resposta online com −350 kJ/mol foi descartada.
- **Para o Ygg:** uma reação é um pacote de energia `±Q` somado ao calor do alvo; a água limita o aquecimento (calor específico, item 43). Já existe o calor acumulado, falta o "pacote".
- **Ideia:** pó de cal molhado esquenta o suficiente para acender palha seca: uma armadilha ou fogueira sem faísca, e seu inverso, o "pó frio", para resfriar metal antes do choque térmico.

### 94. Catalisadores [P2]
- **Regra:** o catalisador baixa a barreira de energia (Ea) da reação e não é consumido. Não muda o resultado final, só a velocidade.
- **Fórmula:** `k2/k1 = e^(ΔEa / RT)`, derivada da equação de Arrhenius. Se Ea cai 10 kJ/mol a 300 K: e^(10000/2494) = e^4,0 ≈ 55x.
- **Valores:** a fonte ([LibreTexts](https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Supplemental_Modules_(Physical_and_Theoretical_Chemistry)/Kinetics/06%3A_Modeling_Reaction_Kinetics/6.02%3A_Temperature_Dependence_of_Reaction_Rates/6.2.03%3A_The_Arrhenius_Law/6.2.3.01%3A_Arrhenius_Equation), aberta) confirma que o catalisador reduz a Ea. Quedas reais de Ea: não encontrado.
- **Para o Ygg:** um reagente com flag `catalisador`: multiplica a velocidade de uma reação, não é gasto, mas se "envenena" ou se perde (ex.: cai na água). Modelo: um multiplicador por receita.
- **Ideia:** uma pedra de drop pendurada num caldeirão faz a mistura andar 5x mais rápido, mas é inútil se molhada: reutilizável, mas com cuidado.

### 95. Solubilidade e diluição [P2]
- **Regra:** cada substância tem um teto do quanto dissolve (que cresce com o calor); o resto fica no fundo. Diluir baixa a concentração e, com ela, o efeito.
- **Fórmula:** concentração `C = m / V`. 5 g de toxina em 10 L = 0,5 g/L; num rio de 10.000 L, 0,0005 g/L, 1000 vezes menos.
- **Valores:** NaCl: 36 g por 100 g de água a 25 °C ([ToolBox](https://www.engineeringtoolbox.com/solubility-d_1283.html)); a página não traz outras substâncias.
- **Para o Ygg:** volume `V` por poça/corpo d'água e massa dissolvida; efeito = f(C). Reaproveita o dose-resposta do item 124.
- **Ideia:** envenenar um poço pequeno funciona; o mesmo veneno no rio não. Em compensação, uma gota de ácido forte numa poça pequena muda o pH e o resultado.

### 96. Princípio de Le Chatelier [P3]
- **Regra:** um sistema em equilíbrio reage a uma perturbação deslocando-se para reduzi-la; em reação exotérmica, subir a temperatura diminui K ([Wikipedia](https://en.wikipedia.org/wiki/Le_Chatelier%27s_principle), aberta). Exemplo visual: NO₂/N₂O₄, o frio clareia e o calor escurece o gás.
- **Fórmula:** `K = [produtos]/[reagentes]`; qualitativo. O exemplo do calcário que vira cal e volta não estava na página `[memória, a confirmar]`.
- **Valores:** não encontrado.
- **Para o Ygg:** só vale como regra de design: reações reversíveis por estado (`molhado/seco`, `quente/frio`). Custo baixo se for uma flag; não simular.
- **Ideia:** uma pedra reage ao fogo (vira cal) e ao esfriar na umidade volta a ser pedra; o jogador pode "reciclar" um material mas perde parte.

### 97. Polimerização e resinas [P3]
- **Regra:** moléculas pequenas se ligam em cadeias; resinas e breus endurecem com calor, frio ou ar, formando cola ou verniz.
- **Fórmula:** tempo de cura pelo item 92: `t_cura = t_ref / 2^((T − T_ref)/10)`; sem dados abertos para uma resina real: não encontrado. `[memória, a confirmar]`
- **Valores:** não encontrado em fonte aberta.
- **Para o Ygg:** estado `viscoso → endurecido` com temporizador; ao endurecer, prende peças (junta com limite de força). Pode reutilizar o conceito da Teia.
- **Ideia:** resina de árvore em fogo é combustível e cola ao mesmo tempo; usada sobre o chão, prende um inimigo, mas cede ao fogo ou ao calor, que a amolece.

### 98. Saponificação e gorduras [P3]
- **Regra:** gordura animal mais uma base forte (obtida, por exemplo, da cinza da madeira) vira sabão. O sabão reduz a tensão superficial da água e deixa tudo escorregadio. `[memória, a confirmar]`
- **Fórmula:** não há uma fórmula simples útil; é receita por proporção. Tensão da água ~72 mN/m, com sabão ~30 `[memória, a confirmar]`.
- **Valores:** não encontrado em fonte aberta.
- **Para o Ygg:** receita `gordura + cinza + água = sabão`; sabão em superfície = `friction` baixo (já existe como lama/gelo).
- **Ideia:** o jogador derrama sabão numa rampa de pedra e o inimigo desliza, o impacto aumenta (momento) quando bate num obstáculo.

### 99. Cimento e cal [P3]
- **Regra:** cal viva + água = cal hidratada (exotérmica, item 93). A argamassa de cal endurece devagar com o gás do ar. Cimento hidráulico endurece até debaixo d'água. Concreto atinge a resistência em cerca de 28 dias. `[memória, a confirmar]`
- **Fórmula:** não há fórmula única; concreto portland aos 28 dias: 35 MPa, e 43 MPa após mais de um ano ([ToolBox](https://www.engineeringtoolbox.com/compression-tension-strength-d_1352.html), aberta).
- **Valores:** ângulo de repouso do concreto fresco: 30° ([ToolBox](https://www.engineeringtoolbox.com/dumping-angles-d_1531.html)).
- **Para o Ygg:** mistura molhada = massa pastosa; após T segundos vira prop estático de pedra. Já há "pilares de pedra"; falta o estado intermediário.
- **Ideia:** o Elementalista (pilares) ou o artesão cimenta uma ponte de lama e cal em 30 s, mas ela só aguenta o peso se curou: ponte falha se for apressada.

## Bloco 10: geologia e terreno

Regra geral de escala para mundo aberto com terreno barato: guardar o terreno como mapa de alturas mais
um mapa de "tipo de solo" (poucas classes por célula), e rodar a física de terreno só em blocos perto do
jogador e dos feitiços; longe, vale o resultado já "assado". `[proposta do Sábio]`

### 110. Tipos de solo e capacidade de carga [P1]
- **Regra:** o solo aguenta uma pressão máxima; acima dela ele cede e o objeto afunda. Argila mole cede cedo; cascalho e rocha, só muito depois.
- **Fórmula:** `p = m·g / A` (kPa). Criatura de 5000 kg em 0,5 m² de pata: 49 050 N / 0,5 = 98 kPa, no limite da argila mole. Humano de 80 kg em 0,04 m²: ≈ 20 kPa. (a capacidade última real vem de Terzaghi: `q_ult = c'·Nc + σ'·Nq + 0,5·γ'·B·Nγ`, com fatores que dependem do ângulo de atrito φ'; [Wikipedia: capacidade de carga](https://en.wikipedia.org/wiki/Bearing_capacity), aberta. A página não traz tabela de valores presumidos.)
- **Valores:** pressão admissível, [ToolBox](https://www.engineeringtoolbox.com/bearing-load-soil-d_1896.html): argila mole 100 kPa; areia fina seca 200; areia grossa 300; argila dura seca 350; cascalho 400; rocha 1000 a 4000. Outras normas dão menos (argila firme 75 a 100 kPa, cascalho solto < 200) [fonte fraca: [Tensar](https://info.tensar.co.uk/blog/what-is-the-bearing-capacity-of-soil), trecho de busca]; mostre a divergência.
- **Para o Ygg:** cada classe de solo tem `carga_kPa`; se `p > carga`, a profundidade afundada cresce em proporção a (p/carga − 1). Barato: uma conta por corpo em contato.
- **Ideia:** pilares de pedra do Elementalista afundam no Lamaçal se pesados demais; num cascalho, ficam firmes. O jogador escolhe onde erguer.

### 111. Ângulo de repouso [P1]
- **Regra:** pilha de grãos soltos para de crescer no ângulo máximo em que não escorrega; acima dele, desliza.
- **Fórmula:** `θ = arctan(μ)`, com μ o atrito estático ([Wikipedia: ângulo de repouso](https://en.wikipedia.org/wiki/Angle_of_repose), aberta). Areia seca a 35° dá μ = tan 35° ≈ 0,70.
- **Valores:** [ToolBox](https://www.engineeringtoolbox.com/dumping-angles-d_1531.html): areia seca 35°; areia úmida 40°; cascalho 40°; argila 45°; terra solta 28°; terra compacta 50°; pedra britada 27 a 30°; cinzas úmidas 36°. Divergência, [Wikipedia](https://en.wikipedia.org/wiki/Angle_of_repose) (aberta, "tudo aproximado"): areia seca 34°; areia úmida 45° (ToolBox: 40°); areia com água 15 a 30°; argila seca em torrão 25 a 40°; argila úmida escavada 15° (ToolBox: argila 45°); brita 45° (ToolBox: 27 a 30°); cascalho natural com areia 25 a 30° (ToolBox: 40°). Molhar um pouco aumenta o ângulo, encharcar reduz.
- **Para o Ygg:** em mapa de alturas, se a inclinação entre células vizinhas passa de `tan θ`, transfere-se o excesso à vizinha (erosão térmica; algoritmo de gráficos `[memória, a confirmar]`). Barato, só nas células ativas.
- **Ideia:** pilha de areia feita pelo Elementalista escorre se alta demais; chuva ou Lamaçal encharcando baixam θ e o monte desaba.

### 112. Deslizamentos e avalanches [P2]
- **Regra:** a encosta cede quando as forças que empurram para baixo superam o atrito que segura. Gatilhos: chuva forte, terremoto, atividade vulcânica, mudança no lençol e obras.
- **Fórmula:** talude infinito seco, `FS = tan φ / tan β`. φ = 35°, β = 40°: 0,70/0,84 = 0,83 (< 1, cede). Com água: `FS = (1 − m·γw/γsat)·tan φ/tan β`; com m = 1 e γw/γsat ≈ 0,5 cai para ≈ 0,42. Fórmula de `FS` do talude infinito: não confirmada, a página tentada deu erro 404 `[memória, a confirmar]`. Gatilhos (chuva, pressão da água, terremoto, incêndio) confirmados em [Wikipedia: deslizamento](https://en.wikipedia.org/wiki/Landslide) (aberta, lida só em parte).
- **Valores:** fluxos de detritos andam normalmente 30 a 50 mph (13 a 22 m/s) e no extremo até 200 mph [USGS](https://www.usgs.gov/media/audio/what-landslide-and-what-causes-them) (transcrição de áudio; conversão do Sábio). Áreas queimadas deslizam com menos chuva [fonte fraca, trecho de busca USGS].
- **Para o Ygg:** `FS` por célula de encosta a partir de inclinação, ângulo do solo e `umidade`; `FS < 1` dispara um fluxo que arrasta props pelo declive. Custo baixo: só quando chove ou treme.
- **Ideia:** queimar a mata de uma encosta e depois fazer chover (ou explodir) derruba lama sobre o acampamento inimigo, em vez de só dar dano.

### 113. Liquefação do solo [P2]
- **Regra:** areia solta saturada, sacudida, perde o contato entre grãos porque a água assume a carga; o chão vira líquido por segundos.
- **Fórmula:** `σ' = σ − u` (tensão efetiva = total − pressão da água; a página da Wikipedia não escreve a fórmula, mas diz que a tensão efetiva cai a quase zero `[memória, a confirmar]` para a conta). A 3 m, γ = 19 kN/m³: σ = 57 kPa, u = 9,81 × 3 ≈ 29,4 kPa, σ' ≈ 27,6 kPa. Quando a vibração eleva `u` em 27,6 kPa, σ' chega a 0 e o solo flui.
- **Valores:** suscetíveis: solos granulares soltos e saturados, sobretudo areias e areias siltosas, depósitos jovens (últimos ~10 mil anos) bem selecionados e com vários metros de espessura (leitos de rio, praias, dunas); areias densas, cascalhos e argilas raramente ([Wikipedia](https://en.wikipedia.org/wiki/Soil_liquefaction), aberta, 100 mil primeiros caracteres). Não encontrei limiar numérico simples.
- **Para o Ygg:** estado `liquefeito` numa célula de solo saturado e arenoso, com temporizador de poucos segundos; durante ele, o chão funciona como fluido (empuxo, item 76). Ao fim, volta firme e mais denso.
- **Ideia:** um tremor local (martelada, explosão) perto da margem faz o chão engolir o inimigo pesado; o leve fica à tona. O Lamaçal já é o ensaio dessa mecânica.

### 114. Ciclo das rochas e propriedades [P2]
- **Regra:** ígneas (granito, basalto) vêm do magma; sedimentares (calcário, arenito, xisto) vêm de grãos compactados; metamórficas (mármore, ardósia) são outras rochas cozidas e prensadas. `[memória, a confirmar]`
- **Fórmula:** peso de um bloco `P = ρ·V·g`. 1 m³ de granito (≈ 2700 kg/m³): ≈ 26,5 kN.
- **Valores:** resistência à compressão ([ToolBox](https://www.engineeringtoolbox.com/compression-tension-strength-d_1352.html)): granito 130 MPa; calcário 60; arenito 60; concreto 28 dias 35. Densidade (kg/m³; [fonte fraca], calculadora online): arenito 2080 a 2400, calcário 2400 a 2720, granito 2560 a 2880, basalto 2720 a 3040, xisto 2240 a 2560. Rocha quebrada tem densidade aparente bem menor.
- **Para o Ygg:** cada rocha vira uma linha de material: densidade, dureza, tenacidade, e se dissolve em ácido (calcário) ou se esfarela (arenito). Já existe `pedra`; falta separar tipos.
- **Ideia:** o martelo trinca o arenito mas não o granito; ácido de monstro (item 91) corrói calcário, mas não o granito: o jogador escolhe a rota certa.

### 115. Erosão e sedimentação [P2]
- **Regra:** a água corrente arranca grãos quando passa de uma velocidade crítica e os deposita quando desacelera. Areia fina solta com menos velocidade que argila, que é coesa.
- **Fórmula:** tensão no leito `τ = ρ·g·h·S` (Pa). Rio de 0,5 m de fundo e declive 0,01: 1000 × 9,81 × 0,5 × 0,01 ≈ 49 Pa `[memória, a confirmar]`.
- **Valores:** curva de Hjulström: grão de 0,5 mm erode a ≈ 30 cm/s; de 1 mm, ≈ 20 cm/s; argila de 0,001 mm exige ≥ 500 cm/s [fonte fraca: [Wikipedia](https://en.wikipedia.org/wiki/Hjulstr%C3%B6m_curve), trecho de busca; as fontes divergem sobre o mínimo]. Curva sem profundidade e hoje só histórica.
- **Para o Ygg:** o rio "assado" no mapa; em tempo real, cada célula de água com velocidade `v` acima do limiar de seu solo perde altura e deposita a jusante. Só em trechos ativos.
- **Ideia:** barrar o rio com pilares provoca depósito a montante e erosão a jusante; o inimigo que acampava no banco de areia é varrido pela cheia.

### 116. Formação de cavernas (carste) [P3]
- **Regra:** chuva com CO₂ vira ácido fraco e dissolve calcário por fissuras; sal e gesso dissolvem mais rápido que calcário. Tetos finos desabam e criam dolinas.
- **Fórmula:** CaCO₃ + CO₂ + H₂O → Ca²⁺ + 2 HCO₃⁻ (como descrito em documento hospedado pelo USGS; [relatório](https://pubs.usgs.gov/of/1997/0536a/report.pdf), trecho de busca).
- **Valores:** formar um conduto leva de 10 mil a 1 milhão de anos [fonte fraca: notas de aula, trecho de busca]; bombear água e baixar o lençol acelera colapsos. Não encontrado número em fonte primária aberta.
- **Para o Ygg:** gerar cavernas antes, por ruído 3D só dentro de zonas de calcário; dolinas na superfície como buracos. O teto tem espessura e resistência (viga, item 36): se o peso supera, colapsa.
- **Ideia:** uma ponte de gelo ou de pilares segura o teto fino; remover o pilar derruba a caverna sobre quem está embaixo.

### 117. Vulcanismo: lava, gases, cinzas e obsidiana [P3]
- **Regra:** quanto mais sílica, mais viscosa é a lava. Basáltica flui; riolítica quase não anda. Lava esfria e forma crosta; água em contato vira vapor violento.
- **Fórmula:** velocidade média de filme newtoniano em rampa, `v = ρ·g·h²·sen θ / (3η)`. ρ = 2600, h = 1 m, θ = 5°, η = 1000 Pa·s: 25 506 × 0,0872 / 3000 ≈ 0,74 m/s (com η = 100 Pa·s, ≈ 7,4 m/s: a divergência entre fontes muda a ordem de grandeza) `[memória, a confirmar]`; lava real tem crosta e não é newtoniana.
- **Valores (as fontes divergem muito):** [URI](https://volcano.uri.edu/lava/MagmaProperties/viscosity.html), em poise (1 Pa·s = 10 poise): basalto 10² a 10⁴ Pa·s; riolito 10⁸ a 10¹³ Pa·s; andesita igual ao basalto, apesar de o texto dizer que é mais viscosa. [Wikipedia: lava](https://en.wikipedia.org/wiki/Lava): basalto 1100 a 1200 °C e ~10 a 100 Pa·s; andesita 850 a 1100 °C, ~3500 Pa·s (valor dado a 1200 °C, fora da faixa, então suspeito); riolito a partir de 800 °C e ~10⁵ (quente) a ~10⁸ Pa·s (frio). Ambas abertas. Uso sugerido: basalto 10 a 10⁴ Pa·s conforme a temperatura. Obsidiana: a Wikipedia só diz que fluxos félsicos "muitas vezes contêm obsidiana"; a formação por resfriamento rápido do vidro continua `[memória, a confirmar]`.
- **Para o Ygg:** lava = poça de material com `temperatura` que cai pela lei de Newton (item 45); viscosidade `η = η0·2^((T0−T)/ΔT)` (modelo de jogo) e, abaixo de ~700 °C, vira crosta/rocha. Uma poça por vez, escorrendo pela rampa.
- **Ideia:** água ou Lamaçal sobre lava forma crosta fina que sustenta pouco peso (item 110); jogar lava na água faz explodir em vapor (item 52).

### 118. Falhas e terremotos [P3]
- **Regra:** a falha escorrega, libera ondas P (rápidas, primeiro), S (cerca de 60% da P) e superficiais (mais lentas, mas as que mais balançam).
- **Fórmula:** cada grau de magnitude vale ≈ 31,6 vezes mais energia; 2 graus, 1000 vezes ([Wikipedia: escala Richter](https://en.wikipedia.org/wiki/Richter_magnitude_scale), aberta). O USGS (página de magnitude e energia, aberta) fala em "32 vezes" e dá `log E = 5,24 + 1,44·Mw`, que implica ≈ 27,5x por grau: divergência. A constante `log10 E = 1,5·M + 4,8` (J) não apareceu em nenhuma das duas `[memória, a confirmar]`; com ela, M 6 dá ≈ 6 × 10¹³ J. Distância pelo atraso S−P: `d = Δt·vp·vs/(vp − vs)`; vp = 6, vs = 3,6 km/s, Δt = 2 s: 18 km.
- **Valores:** P crustal ≈ 6 km/s; S ≈ 60% de P; Rayleigh mais lenta que Love ([USGS](https://earthquake.usgs.gov/earthquakes/events/1906calif/18april/earthwaves.php), trecho de busca). Velocidade de ruptura da falha: não encontrado.
- **Para o Ygg:** evento de mundo com aceleração do solo `a(t)` decaindo com a distância; dispara cadeia: tremor, liquefação, deslizamento, queda de pilhas. Sem simular falhas: só um ponto de origem e raio.
- **Ideia:** o jogador sente o tremor leve e depois o forte e sabe a distância; no Elementalista, um tremor local (limitado por mana e raio) derruba torres de madeira, mas não pedra bem apoiada.

### 119. Formação de minérios [P3]
- **Regra:** metais se concentram onde um processo os junta: veios quentes ao redor de intrusões ígneas, depósitos em leitos de rio (pesados, como o ouro), camadas de ferro em sedimentos, e crostas de intemperismo tropical. `[memória, a confirmar]`
- **Fórmula:** não há fórmula única de jogo. Útil: densidade separa pesados; ouro ≈ 19,3 g/cm³ contra areia ≈ 2,65 `[memória, a confirmar]`.
- **Valores:** teores médios por metal: não encontrado aqui (USGS tem, mas não abri).
- **Para o Ygg:** regras de contexto, não ruído: ouro e cobre perto de rocha ígnea e fendas; pepitas em córregos descendo daquela região; ferro em pântano e pedra. Custo baixo na geração.
- **Ideia:** o jogador segue pepitas pelo riacho até o veio na montanha; no Lamaçal, crostas de ferro sugerem veios por perto.

### 120. Lençol freático e fontes [P3]
- **Regra:** abaixo da superfície, o solo é saturado de água; a fronteira é o lençol. Fonte nasce onde a superfície corta o lençol, ou onde uma camada impermeável (argila, xisto) o desvia para a encosta.
- **Fórmula:** lei de Darcy, `Q = k·A·Δp/(μ·L)`, com `K = k·ρ·g/μ` ([Wikipedia: lei de Darcy](https://en.wikipedia.org/wiki/Darcy%27s_law), aberta); a forma `Q = K·A·(Δh/L)` é a mesma em carga hidráulica. K = 10⁻⁴ m/s (areia), A = 10 m², gradiente 0,01: 10⁻⁵ m³/s ≈ 0,01 L/s; o valor de K da areia `[memória, a confirmar]`.
- **Valores:** definição de fonte e a seca que a esgota: [USGS](https://www.usgs.gov/water-science-school/science/springs-and-water-cycle) [fonte fraca: trecho de busca, não abri]. K por solo: a [Wikipedia](https://en.wikipedia.org/wiki/Hydraulic_conductivity) só traz a tabela como imagem (cascalho e areia "permeáveis", argila "impermeável"; bentonita ≈ 1,3 × 10⁻⁹ m/s no limite de liquidez). Faixas numéricas por solo: não encontrado.
- **Para o Ygg:** um mapa de altura do lençol, suave e quase estático; onde `terreno < lençol` há lago, fonte ou poço. Muda devagar com seca e chuva (item 133). Custo baixo.
- **Ideia:** cavar até o lençol enche o buraco; secas baixam o lençol e as fontes secam, forçando o jogador a ir ao rio ou a cavar mais fundo.

## Itens pendentes e limites

Segunda passada (2026-11-02): páginas abertas de fato (ToolBox: carga, repouso, série galvânica, pH de bases e ácidos, solubilidade, compressão; URI; LibreTexts Arrhenius; Wikipedia: óxido de cálcio, ângulo de repouso, capacidade de carga, liquefação, lava, Richter, Le Chatelier, Darcy, condutividade hidráulica, corrosão, deslizamento; USGS magnitude e energia).

Ainda sem fonte aberta (mantidas as marcas):
- **88/89:** faixas ISO 9223 de aço (C1 ≤ 1,3 µm, C2 a C5 ≈ 1,3 a 200 µm/ano) e efeito numérico do sal; a tabela do MDPI bloqueou o acesso e a página de galvanização a quente não traz taxas de aço (só zinco C3: 0,7 a 2,1 µm/ano).
- **90:** limiar de 0,2 a 0,25 V.
- **92:** Ea de reações reais. **94:** quedas reais de Ea. **96:** exemplo do calcário.
- **97 e 98:** cura de resina, tensão superficial do sabão, receita. **99:** só a resistência foi confirmada.
- **112:** velocidades de fluxo de detritos (USGS, só trecho de busca) e fórmula do `FS`. **113:** `σ' = σ − u` escrito.
- **114:** densidades das rochas (calculadora online). **115:** curva de Hjulström (trecho de busca; fontes divergem).
- **116:** tempos de formação de cavernas. **117:** formação da obsidiana e velocidade em rampa. **118:** constante 4,8, rupturas e atraso S−P.
- **119:** teores e processos de minérios. **120:** K da areia e página USGS das fontes.

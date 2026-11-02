# Blocos 4 e 5: calor e fogo (itens 42 a 66)

> Criado em 2026-11-01 pelo Sábio. Pesquisa, não decisão: nada aqui muda o jogo sem aprovação do Liam.
> Marcas: sem marca = conferido na fonte citada; `[memória, a confirmar]`; `[fonte fraca]`.
> Estado atual do Ygg (lido no código): `add_heat` soma calor; sem fogo, perde `heat_decay`/s; em chamas, por
> `burn_time` s, aquece vizinhos com `fire_spread_heat x (1 - d/raio)` por s. Madeira: ignição 100, decay 15,
> queima 10 s, raio 1,4, espalha 45. Pólvora: ignição 60, decay 10, queima 3 s, raio 1,2, espalha 40.
> Fontes de manual usadas várias vezes: [ToolBox calor específico](https://www.engineeringtoolbox.com/specific-heat-capacity-d_391.html),
> [ToolBox condutividade](https://www.engineeringtoolbox.com/thermal-conductivity-d_429.html),
> [ToolBox autoignição](https://www.engineeringtoolbox.com/fuels-ignition-temperatures-d_171.html).

## Bloco 4: calor e mudança de fase

### 42. Leis da termodinâmica [P1]
- **Regra:** energia não some nem nasce, só passa de um corpo a outro (1ª lei); o calor vai sozinho do quente para o frio, nunca ao contrário (2ª lei).
- **Fórmula:** `Q = m x c x ΔT` (J = kg x J/kg·K x K). Aquecer 1 kg de madeira de 20 a 300 °C: 280 K x 1300 a 2400 J/kg·K = 0,36 a 0,67 MJ.
- **Valores:** c da madeira 1300–2400 J/kg·K, aço 490, granito 790, água 4182 ([ToolBox](https://www.engineeringtoolbox.com/specific-heat-capacity-d_391.html)).
- **Para o Ygg:** a 2ª lei já vale (só quem queima emite). A 1ª é mentida: o fogo emite o mesmo para 1 ou 10 vizinhos. É aceitável; o que importa é que o jogador veja que "quente passa para frio". Falta o inverso: receptor frio que tira calor (`cool()` já existe).
- **Ideia:** bloco de gelo ou criatura fria encostada numa chama "rouba" calor do vizinho, protegendo a caixa ao lado.

### 45. Lei de resfriamento de Newton [P1]
- **Regra:** quanto maior a diferença para o ambiente, mais rápido o corpo esfria. Resultado: queda exponencial, rápida no início e lenta no fim.
- **Fórmula:** `T(t) = T_amb + (T0 - T_amb) x e^(-t/τ)`, com `τ = m x c / (h x A)` em segundos. Exemplo: calor 100, k = 1/τ = 0,15/s: perde 15/s a 100, mas só 1,5/s a 10 ([Wikipedia](https://en.wikipedia.org/wiki/Newton%27s_law_of_cooling)).
- **Valores:** vale para Biot < ~0,1 e diferenças pequenas; com radiação (fogo) falha, e `h` sobe com a diferença (mesma fonte). `h` de ar: não encontrado.
- **Para o Ygg:** **o `heat_decay` linear é aceitável.** O limiar de ignição é idêntico se `k = decay / ignition_heat` (madeira: 15/100 = 0,15/s), então a "potência mínima para acender" (15/s) não muda. Diferenças: o linear zera rápido restos de calor (a 10, em 0,7 s) e pune fontes fracas; o proporcional deixa "morno" por mais tempo e dá `τ` por massa. Só troque se quiser brasas e objetos mornos visíveis (`heat -= heat x k x delta`, com corte em 1).
- **Ideia:** objeto pesado (pedra aquecida) esfria devagar: vira "bolsa térmica" que acende pavio depois.

### 46. Convecção [P2]
- **Regra:** ar quente é menos denso e sobe, levando fumaça e calor; o calor de uma chama vai mais para cima que para os lados.
- **Fórmula:** empuxo `F = ρ_fluido x V x g` ([Wikipedia](https://en.wikipedia.org/wiki/Buoyancy)); fluido aquecido se expande, fica menos denso e sobe, e o frio desce no lugar ([Wikipedia](https://en.wikipedia.org/wiki/Convection)). Correlação de pluma de chama (Heskestad): não encontrada.
- **Valores:** `h` do ar: a fonte só dá `Nu = 0,478 x Gr^0,25` para placa vertical, sem número pronto; velocidade de pluma: não encontrado. O `h` natural do ar aumenta com a diferença de temperatura ([Wikipedia](https://en.wikipedia.org/wiki/Newton%27s_law_of_cooling)).
- **Para o Ygg:** barato: o raio de espalhar fogo ser uma "elipse", com alcance vertical ~1,5x o horizontal, e a fumaça ter velocidade vertical constante. Hoje o raio é esférico.
- **Ideia:** caixa pendurada acima de uma fogueira acende antes de caixa ao lado; teto baixo "prende" o calor.

### 47. Radiação térmica (Stefan-Boltzmann) [P1]
- **Regra:** todo corpo quente irradia luz infravermelha, que aquece quem está à vista, sem tocar. Cresce com a 4ª potência da temperatura e cai com o quadrado da distância.
- **Fórmula:** `M = ε x σ x T⁴` (W/m²; σ = 5,67e-8 W/m²·K⁴; T em kelvin) ([Wikipedia](https://en.wikipedia.org/wiki/Stefan%E2%80%93Boltzmann_law)). Exemplo: ε 0,9 a 800 K: 0,9 x 5,67e-8 x 800⁴ = 20,9 kW/m². A intensidade de uma fonte pontual cai com o quadrado da distância ([Wikipedia](https://en.wikipedia.org/wiki/Inverse-square_law)); chama grande não é ponto, então vale só de longe.
- **Valores:** ε madeira 0,84–0,95; aço polido 0,07, oxidado 0,79; granito 0,96; água 0,95 ([ToolBox](https://www.engineeringtoolbox.com/emissivity-coefficients-d_447.html)).
- **Para o Ygg:** a queda linear `1 - d/raio` já é um bom truque. Falta só (a) linha de visão (parede bloqueia) e (b) metal polido refletir. Um raycast por receptor a cada 0,25 s basta.
- **Ideia:** escudo de metal polido ou parede de pedra bloqueia o calor, e o jogador se abriga atrás.

### 49. Pontos de fusão e ebulição [P2]
- **Regra:** a cada fase, a temperatura trava (calor latente, item 48) até todo o material mudar.
- **Fórmula:** `Q = m x L`. Exemplo: fundir 1 kg de cobre já a 1083 °C: 206 kJ ([ToolBox latente](https://www.engineeringtoolbox.com/latent-heat-melting-solids-d_96.html)).
- **Valores:** água ferve a 100 °C, etanol 78,3; cobre 1083, ouro 1063, prata 962, latão 930, alumínio 659, chumbo 328 °C ([ToolBox](https://www.engineeringtoolbox.com/melting-boiling-temperatures-d_392.html)). A página lista ferro a 1149 °C, que parece ferro fundido; o ferro puro derrete a 1538 °C ([Wikipedia](https://en.wikipedia.org/wiki/Iron)); as duas fontes divergem porque a ToolBox provavelmente mede ferro fundido. Aço, bronze e estanho: não encontrados nessa fonte.
- **Para o Ygg:** madeira e pedra não fundem; só metais importam, e só se houver forja ou lava. Um `melt_heat` por material, bem acima da ignição.
- **Ideia:** chumbo e estanho derretem num braseiro comum; cobre e ferro precisam de fole ou magia.

### 50. Dilatação térmica [P2]
- **Regra:** quase tudo cresce quando esquenta e encolhe quando esfria.
- **Fórmula:** `ΔL = α x L0 x ΔT`. Exemplo: barra de aço de 2 m (α 12e-6) aquecida em 500 K: 12e-6 x 2 x 500 = 12 mm.
- **Valores (x1e-6 /K):** aço 10,8–12,5; cobre 16–16,7; alumínio 23; granito 7,9–8,4; vidro 5,9–9; pinho 5; carvalho transversal ao veio 54 ([ToolBox](https://www.engineeringtoolbox.com/linear-expansion-coefficients-d_95.html)).
- **Para o Ygg:** cosmético quase sempre. Barato: ao passar de um limiar de calor, uma peça "encaixada" (anel, porta de metal) fica presa ou solta.
- **Ideia:** porta de ferro presa esquentada em um lado trava mais; esfriar com água a solta (liga com 51).

### 51. Choque térmico [P2]
- **Regra:** esfriar ou aquecer a superfície depressa cria tensão entre fora e dentro; o frágil trinca.
- **Fórmula:** `ΔT_máx ≈ σ_f / (α x E)` (K), com σ_f resistência, α dilatação, E rigidez. Pyrex tem α menor que vidro comum, então aguenta mais ([Wikipedia](https://en.wikipedia.org/wiki/Thermal_shock)). Exemplo: α 9e-6 (vidro plano, [ToolBox](https://www.engineeringtoolbox.com/linear-expansion-coefficients-d_95.html)) e E 70 GPa (faixa 50–90, [ToolBox](https://www.engineeringtoolbox.com/young-modulus-d_417.html)); σ 50 MPa é ordem de grandeza `[memória, a confirmar]` (a fonte só dá 50 MPa de compressão, não tração): 50e6 / (9e-6 x 70e9) = ~80 K.
- **Valores:** α em [ToolBox](https://www.engineeringtoolbox.com/linear-expansion-coefficients-d_95.html); σ_f e E por material: não conferidos.
- **Para o Ygg:** um campo `thermal_shock_limit` em materiais frágeis (pedra, vidro, cerâmica). Se `|heat - heat_anterior|` por segundo passar disso, quebra. Metal dúctil não quebra.
- **Ideia:** pedra aquecida pela fogueira e molhada rompe-se em fragmentos: forma de abrir parede de pedra sem explosivo.

### 52. Vapor e expansão da água [P2]
- **Regra:** água que vira vapor ocupa mais de mil vezes o volume e engole muito calor; em espaço fechado vira pressão, e o vapor queima mais que a água quente.
- **Fórmula:** `Q = m x L`; razão de volume = `v_vapor / v_líquido`. Exemplo: 1 kg de água de 20 a 100 °C: 4,18 x 80 = 334 kJ; evaporar: 2256 kJ. Evaporar custa 6,7x mais que aquecer.
- **Valores:** vapor saturado a 100 °C: 1,67 m³/kg (convertido de 26,8 ft³/lb) e L = 2256 kJ/kg ([ToolBox](https://www.engineeringtoolbox.com/saturated-steam-properties-d_273.html)). Água líquida a 100 °C: 958,35 kg/m³ ([ToolBox](https://www.engineeringtoolbox.com/water-density-specific-weight-d_595.html)), ou 0,001043 m³/kg; razão 1,67 / 0,001043 = ~1600x (conta minha).
- **Para o Ygg:** água em objeto quente: tira calor grande e gera um "puff" de neblina que bloqueia visão. Pressão de verdade só em recipiente fechado (barril, item 72).
- **Ideia:** jogar água em pedra de braseiro cria cortina de vapor para esconder o jogador.

### 53. Sublimação e geada [P3]
- **Regra:** gelo e neve evaporam sem virar líquido em ar frio e seco; o vapor do ar pode virar geada direto no sólido (deposição).
- **Fórmula:** sublima quando a pressão de vapor do sólido supera a do ar (`p_sólido > p_ar`); `ΔH_sub = ΔH_fusão + ΔH_vaporização` ([Wikipedia](https://en.wikipedia.org/wiki/Sublimation_(phase_transition))). Exemplo: 334 + 2256 = ~2590 kJ/kg para o gelo, conta com os valores da ToolBox.
- **Valores:** ponto triplo da água 612 Pa (mesma fonte). Taxa de perda da neve: não encontrado.
- **Para o Ygg:** só estética e um temporizador lento: gelo some sem poça em ar seco. Custo quase zero.
- **Ideia:** a trilha de gelo da magia some sozinha em horas; geada marca onde algo frio passou.

### 54. Isolamento térmico [P2]
- **Regra:** o que isola é, quase sempre, ar preso em fibras ou poros; molhar troca o ar por água e destrói o isolamento.
- **Fórmula:** `R = espessura / k` (m²·K/W). Exemplo: 5 cm de lã (k 0,04): R 1,25; 5 cm de aço inox (k 17): 0,003.
- **Valores (W/m·K):** ar 0,026; lã/feltro 0,04–0,07; neve 0,05–0,25; palha prensada 0,09; pinho 0,12; couro seco 0,14; carvalho 0,17; água 0,606; granito 1,7–4; inox 17 ([ToolBox](https://www.engineeringtoolbox.com/thermal-conductivity-d_429.html)). A razão água/ar (~23x) é conta minha.
- **Para o Ygg:** um multiplicador `heat_transfer` em materiais e roupas (feltro 0,3; metal 1,5) sobre o calor recebido; molhado sobe o multiplicador.
- **Ideia:** abrigo de neve segura calor; casaco de lã encharcado deixa de proteger do frio.

## Bloco 5: fogo e combustão

### 55. Triângulo do fogo [P1]
- **Regra:** chama precisa de calor, combustível e oxidante (oxigênio). Tirar um apaga. O modelo ampliado (tetraedro) soma a reação em cadeia ([Wikipedia](https://en.wikipedia.org/wiki/Fire_triangle)).
- **Fórmula:** não há equação única; é uma regra lógica `fogo = calor E combustível E oxigênio`.
- **Valores:** teor mínimo de oxigênio para chama: não encontrado nessa fonte.
- **Para o Ygg:** já existem dois lados: combustível (`burn_time` acaba) e calor (lama zera). **Falta o oxigênio:** abafar (lona, teia, terra sobre a chama, sala fechada, item 61). Seria um terceiro botão, `smothered`, que reduz o tempo de queima a cada segundo coberto.
- **Ideia:** a Teia sobre uma chama pequena a abafa; sobre uma grande, vira combustível e alimenta o fogo. O jogador escolhe qual lado do triângulo atacar.

### 57. Pirólise [P1]
- **Regra:** madeira aquecida se decompõe sem oxigênio em gases combustíveis, alcatrão e carvão; hemicelulose decompõe a 210–310 °C, celulose perto de 342–354 °C, lignina a partir de ~200 °C ([Wikipedia](https://en.wikipedia.org/wiki/Pyrolysis)). A chama que vemos é o gás queimando; o carvão que sobra brilha como brasa (mecanismo: [Wikipedia](https://en.wikipedia.org/wiki/Backdraft)).
- **Fórmula:** velocidade de reação tipo Arrhenius, `k = A x e^(-Ea/RT)`, cresce rápido com a temperatura (FPL Research Paper 69 trata a carbonização assim, resumo de busca, página não aberta).
- **Valores:** autoignição genérica da madeira 300 °C; carvalho seco 482; pinho seco 427; carvão vegetal 349 ([ToolBox](https://www.engineeringtoolbox.com/fuels-ignition-temperatures-d_171.html)). A fonte não explica a diferença; variam com o método de teste `[memória, a confirmar]`. Taxa de carbonização em mm/min: não encontrado.
- **Para o Ygg:** três fases por material: **aquecendo** (já existe), **chama** (`burn_time`), **brasa/carvão** (item 60). Hoje a cor já escurece até CHARRED.
- **Ideia:** vento forte arranca a chama de uma tora, que fica só em brasa e solta menos calor.

### 58. Velocidade de propagação do fogo [P1]
- **Regra:** o fogo anda mais depressa onde o calor chega pré-aquecendo o combustível: vento a favor e subida. Descendo ou contra o vento, é lento.
- **Fórmula (Rothermel):** `R = (I_R x ξ x (1 + φ_vento + φ_declive)) / (ρ_b x ε x Q_ig)` `[memória, a confirmar]`; a página do [FireBench](https://firebench.readthedocs.io/en/latest/fire_models_info/22_rate_of_spread_models/02_Rothermel.html) não traz a equação e remete a Andrews (2018, GTR-371), que não abri. Entradas confirmadas: carga, profundidade, razão superfície/volume, umidade, vento e declive ([resumo USU](https://digitalcommons.usu.edu/barkbeetles/438)).
- **Valores:** NWCG: triplicar o declive dobra a velocidade, e triplicar de novo multiplica por 4 a 6 (resumo de busca; página bloqueada para mim) ([NWCG](https://www.nwcg.gov/course/ffm/fire-behavior/firefighter-math-87-slope-effect-on-ros)). A [Wikipedia (Wildfire)](https://en.wikipedia.org/wiki/Wildfire) confirma o pré-aquecimento (ar à frente da frente chega a ~800 °C) e que declives fortes aceleram o fogo, sem regra numérica; velocidades citadas: ~10,8 km/h em floresta e 22 km/h em campo.
- **Para o Ygg:** `fire_spread_heat` hoje é igual em todas as direções. Barato: multiplicar o calor enviado por `1 + a x cos(ângulo com o vento) + b x subida`. Dois números novos em `.tres` ou em ambiente.
- **Ideia:** o jogador vê a fumaça inclinar e sabe para onde o fogo corre; construir a casa ao lado "corrente abaixo" do vento é ruim.

### 59. Razão área/volume [P1]
- **Regra:** quanto mais superfície por volume, mais rápido esquenta e acende. Fino aquece até o centro depressa; grosso demora.
- **Fórmula:** `SAV = A / V` (1/m); cilindro: `SAV = 4 / d`. Tempo de aquecimento `τ = ρ x c x V / (h x A)` é proporcional a `1/SAV`. Exemplo: graveto de 1 cm (SAV 400) esquenta 10x mais depressa que tora de 10 cm (SAV 40). Razão confirmada por conta; valores absolutos de ρ e h: não usados.
- **Valores:** SAV é entrada do modelo de Rothermel ([USU](https://digitalcommons.usu.edu/barkbeetles/438)); valores típicos de combustíveis: não encontrado.
- **Para o Ygg:** o `PhysicsProp` já conhece o tamanho. Escalar o calor recebido por `espessura_ref / espessura_menor`, com piso e teto (0,5 a 2). Sem dados novos.
- **Ideia:** gravetos ou serragem como isca para acender a tora; tora molhada e grossa quase não pega.

### 60. Combustão lenta (brasas) [P2]
- **Regra:** a queima sem chama ocorre na superfície do sólido, com temperatura e calor baixos, mas pode durar horas ou dias e reacender em chamas quando o ar chega ([Wikipedia](https://en.wikipedia.org/wiki/Smouldering)).
- **Fórmula:** avanço da brasa ~0,1 mm/s, cerca de 10x mais lento que a chama sobre sólido (mesma fonte). Exemplo: 0,1 mm/s x 3600 s = 36 cm por hora.
- **Valores:** fontes primárias citadas ali: Ohlemiller (SFPE) e Rein (2009), não abertas.
- **Para o Ygg:** novo estado `embers` depois de `burn_time`: 20–30% da emissão de calor, brilho fraco, sem fumaça densa. Reacende se receber calor menor que a ignição normal (ex.: 30% dela) ou vento/ar. Água o apaga de vez.
- **Ideia:** acampamento "apagado" que o jogador reacende soprando com magia de vento; o inimigo que chuta a fogueira a reacende.

### 61. Falta de oxigênio e reignição súbita (backdraft) [P2]
- **Regra, corrigida:** o PDF errou ao dizer que bloquear o oxigênio causa o backdraft. **Bloquear o oxigênio só abafa a chama.** O perigo vem de três coisas juntas, em sala fechada: (1) o fogo gastou o oxigênio e as chamas morreram; (2) o calor continua, e as paredes e a mobília seguem soltando gás combustível (pirólise, item 57), então a sala se enche de **gás quente, rico demais em combustível para queimar**; (3) alguém abre uma porta ou janela e o ar novo entra, mistura-se com esse gás e entra na faixa em que queima. Qualquer brasa acende, e a mistura queima de uma vez (deflagração), empurrando uma bola de fogo pela abertura. Definição: "deflagração por entrada súbita de ar num espaço confinado com produtos de combustão incompleta pobres em oxigênio" ([NFPA 921 via NIST](https://www.nist.gov/glossary-term/18991)). Passos e sinais: [Wikipedia](https://en.wikipedia.org/wiki/Backdraft). Diferença do flashover: este é térmico (tudo acende por calor, sem precisar de ar novo); o backdraft precisa do ar ([Wikipedia](https://en.wikipedia.org/wiki/Flashover)).
- **Fórmula:** `LFL ≤ fração_de_combustível ≤ UFL` para queimar. Limite inferior do metano: **4,4 %** (corrige minha memória de 5 %); acima do limite superior a mistura é "rica demais" e a entrada de ar pode trazê-la para a faixa que queima ([Wikipedia](https://en.wikipedia.org/wiki/Flammability_limit)). Limite superior do metano e da mistura de incêndio: não encontrados.
- **Divergência:** fontes divergem se o gatilho precisa ser uma mudança deliberada de ventilação (NFPA 921 ou 1700); não consegui confirmar no texto das normas.
- **Para o Ygg:** por sala selada, 3 números: `oxigênio`, `gás_combustível`, `calor`. Fogo baixa o oxigênio; chama morre abaixo de um limite, mas o gás sobe enquanto `calor` for alto. Evento "porta abre" com gás e calor altos dispara `Explosion` na abertura. Sinais legíveis (pilar 4): fumaça que pulsa, janela escura, assobio do ar entrando.
- **Ideia:** o jogador abre a porta de lado e se abaixa; ou arromba o teto para ventilar por cima antes e evitar a explosão.

### 62. Óleo em chamas e água [P1]
- **Regra:** água pesa mais que a maioria dos óleos, afunda sob eles, ferve ao tocar óleo bem acima de 100 °C e vira vapor em mil e tantas vezes o volume, lançando gotas de óleo em chamas. Além disso, a água sobe o nível e espalha o óleo em chamas.
- **Fórmula:** razão de volume ~1600x (item 52). Exemplo: 100 ml de água viram ~160 L de vapor.
- **Valores:** a regra "nunca use água em fogo de líquido inflamável" está na [OSHA](https://www.osha.gov/etools/evacuation-plans-procedures/emergency-standards/portable-extinguishers/about); o número 1700 de reportagens não tem fonte técnica `[fonte fraca]` ([ScienceABC](https://www.scienceabc.com/eyeopeners/does-water-make-a-grease-fire-worse-why.html)). Não achei a norma NFPA com o número.
- **Para o Ygg:** no material, um campo `water_response`: `extinguish` (madeira), `spread` (óleo: o fogo cresce), `flash` (óleo muito quente: bola de fogo). Hoje só existe lama que apaga.
- **Ideia:** a água errada piora o fogo. Soluções certas: abafar com terra ou lama espessa, ou cortar o ar.

### 63. Explosão de poeira [P2]
- **Regra:** pó fino de combustível (partículas abaixo de ~500 µm), em suspensão no ar, com faísca e algum confinamento, queima tão depressa que vira explosão; a grande superfície por volume explica a facilidade. Pó pousado pode ser levantado e gerar uma segunda explosão, mais perigosa, que atinge a estrutura inteira ([Wikipedia](https://en.wikipedia.org/wiki/Dust_explosion)). Cinco ingredientes: combustível, oxidante, ignição, dispersão e confinamento ([Dust Safety Science](https://dustsafetyscience.com/is-my-dust-combustible/), [HSA](https://hsa.ie/topics/atex/atex_delivery_guide/dust)).
- **Fórmula:** só o efeito observável: quanto mais fino o pó e mais fechado o espaço, mais rápida e forte a explosão. Removi a fórmula do Kst: não abri fonte para ela.
- **Valores:** St 1 (0–200): madeira, açúcar, carvão; St 2 (200–300): celulose, farinha de madeira; St 3 (>300): alumínio, magnésio ([Dust Safety Science](https://dustsafetyscience.com/is-my-dust-combustible/)). Outra fonte coloca St 3 até 800 e farinha em St 1 ([CSB/Didion](https://csb.gov/assets/1/20/Didion_Appendix_G_Dust_Explosibility_Testing_Report.pdf)). Concentração mínima: omitida de propósito (quantidade prática).
- **Para o Ygg:** nuvem como volume com `densidade_de_pó` que sobe quando algo é triturado ou batido e cai com o tempo. Faísca com densidade acima do mínimo chama `Explosion`; sem confinamento, só um clarão. Reaproveita `explosive.tres`.
- **Ideia:** sacos de farinha num moinho fechado são bomba; ao ar livre, só um clarão que acende o telhado.

### 64. Fumaça [P2]
- **Regra:** fumaça quente sobe, forma camada no teto e desce; reduz visão e traz CO, invisível.
- **Fórmula:** `visibilidade = K / C_ext` (m; C_ext em 1/m). K ≈ 3 para placas refletoras e 8 para luminosas (Jin; resumo de busca, página bloqueada) ([Fire Technology](https://link.springer.com/article/10.1007/s10694-021-01139-5)). Exemplo: C_ext 0,5 /m: 6 m ou 16 m.
- **Valores:** CO: IDLH 1200 ppm; 30 min a 1200 ppm dá 10–13 % de carboxi-hemoglobina; ~35 % atrapalha destreza; ~40 % causa confusão ([NIOSH](https://www.cdc.gov/niosh/idlh/630080.html)).
- **Para o Ygg:** um escalar `fumaça` por sala, alimentado por chamas, ligado a névoa volumétrica; camada no teto: quem se abaixa enxerga. Dano lento só dentro da camada.
- **Ideia:** fumaça entrega a posição do fogo e esconde o jogador; abrir o teto "puxa" a fumaça para cima.

### 65. Agentes de extinção [P2]
- **Regra:** cada agente ataca um lado do triângulo: água resfria; CO2 desloca o oxigênio; pó químico interrompe a reação; espuma e cobertura separam combustível e ar. Água só em sólidos comuns (classe A), nunca em líquidos inflamáveis (B), e metais combustíveis (D) pedem agente inerte ([OSHA](https://www.osha.gov/etools/evacuation-plans-procedures/emergency-standards/portable-extinguishers/about); areia seca em fogo de metal: [Wikipedia](https://en.wikipedia.org/wiki/Fire_triangle)).
- **Fórmula:** água precisa tirar o calor de aquecer e evaporar (item 52): ~2590 kJ por kg de água a 20 °C → vapor (334 + 2256).
- **Valores:** não há número de "eficácia" comparável nas fontes abertas.
- **Para o Ygg:** tabela abaixo. Lama já resfria e abafa.
- **Ideia:** lama + fogo de óleo: abafa; água + fogo de óleo: piora.

| Agente | Madeira/palha | Óleo | Pólvora acesa | Metal em pó |
|---|---|---|---|---|
| Água | apaga | espalha/bola de fogo | apaga e inutiliza | não use |
| Lama/terra/areia | apaga (abafa+resfria) | abafa | apaga | apaga (areia seca) |
| Abafar (lona) | apaga se pequeno | apaga se pequeno | — | — |
| Retirar combustível | apaga | apaga | — | — |

### 66. Incêndios florestais e aceiros [P3]
- **Regra:** o fogo avança onde há combustível contínuo; faixa limpa até o solo mineral o corta. Brasas levadas pelo vento criam focos novos, a quilômetros ([Wikipedia](https://en.wikipedia.org/wiki/Firebreak)).
- **Fórmula:** largura necessária de aceiro: não encontrada. Exemplo real: faixas de 5 a 10 m entre floresta e vila nas Filipinas; aceiros não são garantia, pois brasas e mudança de direção os atravessam ([Wikipedia](https://en.wikipedia.org/wiki/Wildfire)).
- **Valores:** Rothermel (item 58); brasas causaram focos a até 20 km da frente em incêndios australianos ([Wikipedia](https://en.wikipedia.org/wiki/Wildfire)).
- **Para o Ygg:** simulação de mundo em grade (item 139): cada célula tem `carga_de_combustível`, umidade e probabilidade de ignição por tick; pedra, lama e água têm carga zero. Longe do jogador (item 140), só a grade; perto, props físicos.
- **Ideia:** o jogador cava uma vala ou queima uma faixa de mato antes do fogo chegar; ou usa a lama como aceiro.

## Tabela de valores abstratos sugerida (proposta, não decisão)

**Escala:** 1 unidade de calor ≈ 3 °C acima do ambiente. Assim a madeira atual (100) equivale aos 300 °C genéricos da [ToolBox](https://www.engineeringtoolbox.com/fuels-ignition-temperatures-d_171.html). A escala é uma mentira consistente: serve para ordenar materiais.

| Material | Fonte (autoignição) | `ignition_heat` sugerido | Hoje no Ygg |
|---|---|---|---|
| Papel/pano/palha seca | papel 218–246 °C; palha: não encontrado | 70–80 | não existe |
| Pólvora | 288 °C | ~95 pelo calor lento; 60 só vale se for "sensível a faísca" | 60 |
| Madeira genérica | 300 °C | 100 | 100 |
| Madeira dura | carvalho seco 482 °C (divergência: ver 57) | 140–160 | não existe |
| Carvão vegetal | 349 °C | ~115 | não existe |
| Metal, pedra | não inflamáveis | ignora calor | ok |

**Achado-chave:** pela ToolBox, pólvora (288 °C) e madeira (300 °C) acendem quase na mesma temperatura. O que torna a pólvora perigosa é a sensibilidade à **faísca**, não o calor lento. Por isso, vale ter dois números separados (ligado ao item 56, de outro bloco): `ignition_heat` (calor lento) e `spark_sensitivity`.

**Parâmetros novos sugeridos:**

| Parâmetro | Valor inicial | Base |
|---|---|---|
| `ember_emission_factor` (brasa) | 0,25 | item 60, proposta |
| `ember_reignite_fraction` | 0,3 x ignição | item 60, proposta |
| `wet_heat_factor` | 0,5 | tabela-elementos-materiais |
| `smother_rate` (abafar) | 1 s de queima removido por s coberto | item 55, proposta |
| `wind_bias` / `slope_bias` | 0,5 / 0,5 | item 58, a testar |
| `thickness_scale` min/max | 0,5 / 2 | item 59, proposta |
| `water_response` | extinguish / spread / flash | item 62 |

**Conferência do contágio atual (conta, não testada no jogo):** um vizinho a distância `d` recebe `45 x (1 - d/1,4)` por s de uma madeira em chamas e perde 15/s. Para chegar a 100 em 10 s precisa de ganho líquido de 10/s, logo ganho de 25/s, ou `d ≤ 0,62 m`. Entre 0,62 e 1,4 m a caixa vizinha esquenta, mas **não acende** com uma única fonte. O raio 1,4 só vale com várias chamas somadas. Verificar se `DamageRules.distance_to` mede até a borda. Se o desenho pretende "raio = alcance do contágio", o raio efetivo é menos da metade.

## Itens cobertos e pendentes

Cobertos (21): 42, 45, 46, 47, 49, 50, 51, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66.
Não eram meus: 43, 44, 48, 56.

**Lacunas de fonte (não conferido, não fingir cobertura):**
- 46: convecção e empuxo agora confirmados; velocidade de pluma e `h` do ar continuam sem número.
- Continuam sem fonte aberta: σ_f (tração) do vidro (51), equação de Rothermel (58), regra de declive do NWCG (58) e o texto da NFPA 921/1700 e da NFCC sobre backdraft (61); a definição vem do NIST e o mecanismo, da Wikipedia.
- 51: valores σ_f e E dos materiais não conferidos; o exemplo do vidro é ordem de grandeza.
- 58: fórmula de Rothermel e regra de declive do NWCG vêm de resumo; o texto original (GTR-371/INT-115) e a página do NWCG deram 403.
- 61 e 64: o PDF da NFCC (backdraught) passou do limite de leitura; o texto de Jin (Springer) pediu login. Usei NIST, Wikipedia e resumos de busca.
- 63: concentração mínima omitida de propósito e Kst sem fonte (fórmula removida); tamanho de partícula e segunda explosão confirmados.
- 66: largura ideal de aceiro não encontrada (só o exemplo de 5 a 10 m).
- Taxa de carbonização da madeira (57) e velocidade de queima (`burn_time`) sem fonte; propõe-se escalar por espessura, não por número real.

# Blocos 11 e 12: biologia, atmosfera e simulação

> Criado em 2026-11-01 pelo Sábio. Material de pesquisa, não GDD: nada aqui vale como regra do jogo.
> Itens: 121, 122, 123, 125, 126, 127, 128, 129, 130, 131, 132, 133, 135, 136, 137, 140.
> Marcas: sem marca = conferido na fonte citada; `[memória, a confirmar]`; `[fonte fraca]` (só trecho de busca, página não aberta ou fonte secundária).
> Contas de exemplo são do Sábio. Venenos: só sintomas e categorias.
> Limite honesto: NCBI/StatPearls bloqueou a leitura (captcha); a Wikipédia foi usada como fonte secundária.

## Bloco 11: Biologia, bioquímica e monstros

### 121 Lei de Kleiber e alometria [P2]
- **Regra:** o gasto de energia em repouso cresce com a massa elevada a ~0,75, não com a massa inteira. Bicho grande gasta menos por kg. O expoente é discutido (2/3 se ajusta melhor abaixo de 10 kg).
- **Fórmula:** P = 3,4 x m^0,75 (P em W, m em kg; equivale a 70 x m^0,75 kcal/dia). 70 kg: 70^0,75 = 24,2, logo P ≈ 82 W. Inversa (conta minha): para 8x de potência, massa = 8^(1/0,75) ≈ 16x. Força muscular segue ~m^(2/3): 8x de força pede ~22x de massa [memória, a confirmar].
- **Valores:** coeficiente 3,4 W/kg^0,75 e expoente 0,75. A própria fonte diz que o expoente correto ainda é incerto; pequenos (aves abaixo de 10 kg, insetos) ajustam melhor a 2/3; medições: 0,73 (Brody, 1932) e 0,749 (mamíferos, 2004). [Wikipédia, Kleiber's law](https://en.wikipedia.org/wiki/Kleiber%27s_law) (aberta; fonte secundária).
- **Para o Ygg:** um expoente em `.tres` por criatura: fôlego/regeneração = k x massa^0,75. Barato (uma potência). Não há inimigos ainda.
- **Ideia:** monstro enorme quase não cansa, mas leva muito tempo para esquentar e esfriar; fogo lento nele é inútil, gelo também.

### 122 Exoesqueleto e respiração de insetos [P2]
- **Regra:** insetos respiram por tubos (traqueias) que levam ar por difusão e bombeamento; sem pulmões ativos, o tamanho é limitado. A velha ideia "mais oxigênio no Carbonífero = insetos gigantes" foi contestada em 2026: a densidade de traquéolas no músculo de voo quase não muda com o tamanho; outros gargalos podem existir. Muda (ecdise) deixa o bicho mole e frágil [memória, a confirmar].
- **Fórmula:** tempo de difusão t = x²/(2D). D do O2 no ar ≈ 0,2 cm²/s [memória, a confirmar]; x = 1 cm: 2,5 s; x = 5 cm: 62 s (inviável sem bombear).
- **Valores:** [Nature 2026 (Snelling et al.), via notícia](https://www.sci.news/paleontology/gigantic-griffinflies-14656.html) `[fonte fraca]`; paper original não aberto. O [PLoS ONE de Verberk e Bilton](https://pmc.ncbi.nlm.nih.gov/articles/PMC3144910) (aberto) mostra, em larvas aquáticas, limite térmico +1,53 °C com hiperóxia e -2,92 °C com hipóxia; é uma espécie, amostra pequena, e não traz coeficientes de difusão. Coeficiente de difusão do O2 no ar e dimensões de traqueia: **não encontrado** em fonte aberta; o D do exemplo segue de memória.
- **Para o Ygg:** a mentira aceitável: aranha gigante com "bombas" de ar (ventilação ativa) e carapaça pesada = lenta e com ponto fraco nas juntas.
- **Ideia:** monstro de carapaça tem janela de vulnerabilidade logo após a muda; fumaça densa o sufoca.

### 123 Seda de aranha: base da Teia [P2]
- **Regra:** a seda de arrasto é fina, leve, forte e elástica; molhada, encolhe até ~50% (supercontração) e vira um "elástico fraco"; a água amolece o fio (baixa a transição vítrea).
- **Fórmula:** F = σ x A. Fio de 1 mm² a 1,3 GPa: 1.300 N, ~132 kgf. Energia por volume ≈ 120 MJ/m³, então 1 cm³ absorve ~120 J (equivale a energia cinética de 1 kg a 15 m/s).
- **Valores:** resistência ~1,3 GPa (outra revisão cita ~1,8 GPa); módulo até 37 GPa (aço 208, Kevlar 112); alongamento até 5x em algumas sedas; Darwin's bark spider: 350 MJ/m³ e 65% de deformação; mantém resistência de -40 a 220 °C. Degradação: só um resumo secundário de busca (Kanazawa) diz "estável até ~250 °C" `[fonte fraca]`, e um estudo de ressonância (ESR) em *Argiope amoena* vê formação de radicais com pico perto de 170 °C (decomposição química começando); isso diverge um pouco dos 220 °C da Wikipédia, então use 170 a 250 °C como faixa de incerteza. Inflamabilidade: **não encontrado**. [Wikipédia](https://en.wikipedia.org/wiki/Spider_silk) `[fonte fraca]`; [revisão Sandstrom](https://jsr.org/hs/index.php/path/article/download/6087/2715/39851) (só trecho de busca); [Darwin's bark, NSF](https://par.nsf.gov/servlets/purl/10290460).
- **Para o Ygg:** `lab_web.gd` já tem `hold_damp`, `break_speed`, `duration` e casulo que arde. Falta: umidade encolhendo a teia (aperta o preso) e enfraquecendo-a; teto de rompimento por energia (m·v²/2) em vez de só velocidade.
- **Ideia:** chuva ou poça encolhe a Teia e aperta o alvo (prende mais, mas rompe mais fácil); fogo acima de ~170 a 250 °C é o limite honesto (fontes divergem), e queimar solta o preso com calor (já existe).

### 125 Neurotoxinas versus hemotoxinas (por sintomas) [P2]
- **Regra:** neurotóxico: paralisia, até a respiração; pouca dor e inchaço local. Hemotóxico: dor local forte, inchaço, manchas, fraqueza, vômito, sangramento (até por orifícios). Citotóxico: dano só no local. Miotóxico: destruição muscular e paralisia.
- **Fórmula:** sem doses. Modelo de jogo: intensidade s(t) = rampa de subida e queda, com teto por categoria; sintomas por limiares de s.
- **Valores:** viperídeos: fraqueza e vômito em ~1 a 3 h, inchaço em 12 a 24 h (tempos reais; no jogo, comprimir para segundos ou minutos). [Wikipédia, Snake venom](https://en.wikipedia.org/wiki/Snake_venom) `[fonte fraca]`.
- **Para o Ygg:** categorias viram estados: Paralisia (reduz velocidade e vigor), Sangramento (liga a 129), Necrose local (membro/ponto com penalidade).
- **Ideia:** o antídoto é do mesmo tipo do estado (pilar 4: o jogador lê o sintoma e escolhe o remédio); a Teia aplicada num alvo envenenado o impede de procurar cura.

### 126 Termorregulação [P2]
- **Regra:** o corpo mantém ~37 °C; frio tira o tremor e a lucidez, calor passa de 40 °C e confunde. Animais de sangue frio ficam mais lentos no frio.
- **Fórmula:** Q = m x c x ΔT. Humano 70 kg, c ≈ 3.470 J/(kg·K) [memória, a confirmar]: 1 °C = 243 kJ; com perda líquida de 100 W, ~40 min por °C. Sangue frio: velocidade x Q10^((T-T0)/10), Q10 ≈ 2 a 3 ([Wikipédia, Q10](https://en.wikipedia.org/wiki/Q10_(temperature_coefficient)), aberta; no músculo pode ir de abaixo de 1 a 4). O c do corpo humano (~3.470) não apareceu nas páginas abertas (água: 4.184 J/(kg·K) em [Wikipédia](https://en.wikipedia.org/wiki/Specific_heat_capacity)): segue de memória.
- **Valores:** núcleo normal 36,5 a 37,5 °C [Wikipédia](https://en.wikipedia.org/wiki/Human_body_temperature).  hipotermia: leve 32 a 35 °C (tremor), moderada 28 a 32 °C (para de tremer, sonolência), grave 20 a 28 °C (inconsciente). [Wikipédia, Hypothermia](https://en.wikipedia.org/wiki/Hypothermia). Insolação: núcleo acima de 40 °C com desorientação. [Wikipédia, Heat stroke](https://en.wikipedia.org/wiki/Heat_stroke).
- **Para o Ygg:** um número "temperatura do corpo" com resfriamento de Newton; faixas viram penalidades. O calor do jogo hoje é por objeto.
- **Ideia:** gelo em monstro de sangue frio o torna lento (a Teia faz o resto); fogueira vira refúgio, não só dano.

### 127 Gorduras e óleos de animais [P2]
- **Regra:** gordura é combustível denso, queima mais quente e por mais tempo que madeira; é a base de velas, tochas e unguentos.
- **Fórmula:** E = m x H. 1 kg de óleo vegetal = 40,5 MJ; a 1 MW de fogo, dura ~40 s. Madeira seca: 16,2 MJ/kg.
- **Valores (HHV, MJ/kg):** óleo vegetal 40,5; etanol 29,7; carvão 29,6; madeira seca 16,2 (varia 5 a 10%). Sebo/gordura animal e ponto de fulgor: **não encontrado** nesta página. [EngineeringToolbox](https://www.engineeringtoolbox.com/fuels-higher-calorific-values-d_169.html).
- **Para o Ygg:** drop "gordura" com `fuel_energy` (J/kg) e queima longa; usa a ignição e o espalhamento que já existem. Lembrar a regra do nº 62: água espalha óleo em chamas.
- **Ideia:** untar a Teia ou o alvo com gordura faz o casulo queimar mais, e mais tempo, mas o fogo vira difícil de apagar com água.

### 128 Queimaduras e cicatrização [P2]
- **Regra:** a gravidade depende de profundidade e de área do corpo atingida. Superficiais só afetam a pele externa; parciais e profundas custam semanas.
- **Fórmula:** área por "regra dos nove" (adulto: cabeça 9%, braço 9%...). Palma da mão com dedos ≈ 1% da superfície. Só queimaduras parciais e profundas entram no total.
- **Valores:** cura de superficial: 3 a 6 dias ou 5 a 10 dias (fontes divergem); parcial: até 8 semanas. [StatPearls, Regra dos nove](https://ncbi.nlm.nih.gov/books/NBK513287) `[fonte fraca]` (só trecho de busca; página bloqueada); [resumo de busca](https://asprtracie.hhs.gov/technical-resources/resource/12751/rule-of-nines).
- **Para o Ygg:** dano de fogo = calor x fração do corpo exposta; ferida que fica (marca) cura em tempo, e não de uma vez.
- **Ideia:** um pano molhado ou a Teia cobrindo reduz a área exposta ao fogo, mas arde junto se secar (liga ao nº 123).

### 129 Hemorragia e coagulação [P2]
- **Regra:** perda de sangue por classes: I até 15% (sinais normais), II 15 a 30% (pulso rápido, pele fria), III 30 a 40% (pressão cai, choque), IV acima de 40% (risco de morte). Hemorragia maciça: mais de 150 mL/min.
- **Fórmula:** tempo = volume perdido / taxa. Sangue ≈ 70 mL/kg em homens e 65 em mulheres ([Wikipédia, Blood volume](https://en.wikipedia.org/wiki/Blood_volume); uma tabela da mesma página traz 75 para homens): 70 kg = 4,9 L; 40% = 1,96 L; a 150 mL/min, ~13 min.
- **Valores:** classes de [Wikipédia, Bleeding](https://en.wikipedia.org/wiki/Bleeding) `[fonte fraca]`. Linha do tempo da coagulação: **não encontrado**.
- **Para o Ygg:** barra de "sangue" com taxa de perda por ferida; limiares das classes viram faixas de penalidade (visão, velocidade).
- **Ideia:** pressionar a ferida, enfaixar ou cauterizar com fogo estanca o sangramento, mas queima (liga a 128); hemotoxina (125) impede coagular.

### 130 Fermentação e decomposição [P3]
- **Regra:** leveduras transformam açúcar em álcool e CO2 sem ar; corpos apodrecem com calor e umidade, mais rápido no calor, e soltam gases.
- **Fórmula:** C6H12O6 → 2 C2H5OH + 2 CO2. 180 g de açúcar dão 92 g de etanol e 88 g de CO2 [memória, a confirmar; estequiometria de livro-texto]. Velocidade dobra a cada ~10 °C (regra de Arrhenius, nº 92).
- **Valores:** tempos de decomposição de cadáveres: **não encontrado**.
- **Para o Ygg:** recipiente fechado com grão/fruta acumula pressão com o tempo (relógio por `.tres`); cadáver como objeto com "idade".
- **Ideia:** barril fermentando perto de fogo vira bomba lenta (liga a 72, 73); carniça atrai predadores.

### 131 Bioluminescência e sentidos animais [P3]
- **Regra:** criaturas detectam por visão (cone), audição (som cai com a distância), olfato (rastro), calor (infravermelho em algumas cobras) e vibração (aranhas).
- **Fórmula:** intensidade sonora I = P / (4π r²): dobrar a distância dá -6 dB. Fonte de 1 W a 10 m: ≈ 8 x 10^-4 W/m².
- **Valores:** limiar de sensibilidade infravermelha de víboras: **não encontrado** (não pesquisei a fundo).
- **Para o Ygg:** quando houver IA: cada criatura com 1 a 2 sentidos em `.tres` (raio, ângulo, limiar). Custo baixo: ray e distância.
- **Ideia:** aranha sente vibração na teia: tocar a Teia alerta o dono; criatura de calor vê o jogador com a tocha, mas não o escondido na lama.

## Bloco 12: Atmosfera, som, luz e simulação

### 132 Vento e gradiente de pressão [P2]
- **Regra:** o ar vai da pressão alta para a baixa; o vento real é desviado (Coriolis) e freado pelo atrito do chão.
- **Fórmula:** a = -(1/ρ) x ∇p ([Wikipédia, Pressure-gradient force](https://en.wikipedia.org/wiki/Pressure-gradient_force), aberta). ρ = 1,225 kg/m³ ao nível do mar [memória, a confirmar; a página não traz]; 1 hPa por 100 km = 0,001 Pa/m, então a ≈ 8 x 10^-4 m/s² (conta minha).
- **Valores:** não pesquisei a escala de Beaufort; **não encontrado**.
- **Para o Ygg:** não verifiquei se há vento no código. Modelo barato: vetor global + ruído de baixa resolução, em m/s, aplicado à propagação de fogo, fumaça e arrasto de projéteis leves (nº 14).
- **Ideia:** vento muda a direção do fogo; o jogador cria correntes com magia e empurra a fumaça sobre a Teia.

### 133 Ciclo da água e chuva [P3]
- **Regra:** ar úmido sobe, esfria, condensa e vira nuvem; chuva molha tudo.
- **Fórmula:** base da nuvem h ≈ 125 m x (T - Td), pois h = (T - Td)/(Γseco - Γorvalho), com Γseco ≈ 9,8 K/km e Γorvalho ≈ 1,8 K/km. T = 25 °C, orvalho 15 °C: 1.250 m. [Wikipédia, Lifted condensation level](https://en.wikipedia.org/wiki/Lifted_condensation_level) (aberta).
- **Valores:** taxa de formação de chuva e precipitação por região: **não encontrado**.
- **Para o Ygg:** estado de clima global + "molhado" por material (ligações: ignição sobe, atrito cai, seda encolhe). Não simular nuvens.
- **Ideia:** chuva apaga a fogueira, afrouxa o fogo na floresta e transforma o chão em lama (já existe).

### 135 Incandescência e cor do calor [P3]
- **Regra:** quase todo sólido passa a brilhar a partir de ~525 °C (ponto de Draper); com mais calor, vai de vermelho a laranja, amarelo e branco.
- **Fórmula:** lei de Wien λ_máx = b/T, b = 2,8978 x 10^-3 m·K ([Wikipédia](https://en.wikipedia.org/wiki/Wien%27s_displacement_law), aberta). A 1.000 K: 2,9 µm (infravermelho); o brilho visível vem da cauda da curva.
- **Valores:** Draper point 525 °C. [Wikipédia](https://en.wikipedia.org/wiki/Draper_point). Cor subjetiva de corpo negro ([Wikipédia, Incandescence](https://en.wikipedia.org/wiki/Incandescence), aberta): 530 °C brilho vermelho fraco; 650 vermelho escuro; 760 vermelho vivo, quase laranja; 1.200 laranja vivo; 1.500 amarelo-alaranjado pálido; 3.300 branco-amarelado; acima de 5.000 branco. Isso corrige minha lista de memória (que dava amarelo a 1.100 e branco a 1.300 °C, valores não confirmados); "cereja" e "amarelo" puros não constam.
- **Para o Ygg:** gradiente de cor emissiva indexado pelo calor do objeto, abaixo de 525 °C sem brilho. Barato (uma textura 1D).
- **Ideia:** o jogador lê a temperatura pela cor (pilar 4) e sabe quando o metal vai acender a madeira ou a Teia.

### 136 Reflexão e refração da luz [P3]
- **Regra:** a luz curva ao mudar de meio; em ângulos rasos da água para o ar, reflete totalmente.
- **Fórmula:** n1 sin θ1 = n2 sin θ2. Ângulo crítico água→ar = asin(1/1,333) ≈ 48,6° (a versão anterior dizia 48,8°, por arredondar o índice).
- **Valores (589 nm):** ar 1,000293; água 1,333 (20 °C); gelo 1,31; vidro de janela 1,52; diamante 2,417. [Wikipédia, Refractive index](https://en.wikipedia.org/wiki/Refractive_index) (aberta; a página da ToolBox deu erro 404).
- **Para o Ygg:** só visual (shader de água, reflexo falso); para jogabilidade, uma lente é um raio que concentra a luz do sol num ponto.
- **Ideia:** gelo polido ou lente de vidro concentra luz e acende a Teia ou a pólvora ao sol; nublado não funciona.

### 137 Passo fixo e estabilidade numérica [P1]
- **Regra:** a física avança em passos de tempo iguais; renderizar mais rápido não muda a conta. O passo grande demais deixa o corpo atravessar paredes ou explodir.
- **Fórmula:** deslocamento por passo = v x dt. A 80 m/s e 60 Hz: 1,33 m por passo (mais que muitas paredes finas).
- **Godot:** física em taxa fixa (padrão 60 por segundo); `_physics_process` roda antes de cada passo, com `delta`; interpolação existe para evitar tremor entre taxa de física e de tela. [Introdução à física](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html), [Interpolação](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html). Limite de passos por quadro: padrão 8; se o FPS cair abaixo de ticks/8, o jogo parece em câmera lenta; raise junto com os ticks. [Godot, Engine](https://docs.godotengine.org/en/stable/classes/class_engine.html) (conferido via busca; a chave exata em ProjectSettings não foi vista).
- **Jolt:** estável a 60 Hz com 1 collision step; mais passos de colisão dividem o passo (2 passos a 60 Hz = 1/120 s cada). **O CCD roda na CPU**: após a integração, corpos que andam além de um limite ligado ao raio interno são agendados, e jobs paralelos fazem um linear cast. A documentação não menciona GPU; a "placa gráfica" do PDF está errada. Limite: objeto longo girando rápido ainda pode atravessar. [Jolt, documentação](https://jrouwe.github.io/JoltPhysics/). Configurações da Godot: `simulation/position_steps`, `velocity_steps`, `continuous_cd_movement_threshold`; padrões não conferidos. [Godot, Jolt](https://docs.godotengine.org/en/stable/tutorials/physics/using_jolt_physics.html). Palestra da GDC: não aberta (login e PDF ilegível).
- **Para o Ygg:** manter 60 Hz; CCD só em projéteis rápidos (já feito na Bola de Fogo e Dardo). Nunca ligar tudo com CCD. Simulações em grade devem usar passo próprio (nº 139).
- **Ideia:** teto de velocidade por material (pedra, espada) evita tunelamento e é coerente com Hill (nº 19).

### 140 Nível de detalhe na simulação [P1]
- **Regra:** o que está longe não precisa ser exato, só plausível ao voltar.
- **Fórmula:** custo = Σ (n_anel / período_anel) x c. Exemplo meu: 1.000 entidades a 0,01 ms; 50 perto (todo quadro), 200 médio (a cada 4), 750 longe (a cada 30): (50 + 50 + 25) x 0,01 = 1,25 ms contra 10 ms.
- **Valores:** números do exemplo são hipotéticos, não medidos. Na Godot, `RigidBody3D.can_sleep` permite dormir sem movimento, e corpo dormindo "não calcula forças até ser acordado"; `continuous_cd` é "mais preciso, mas mais lento" ([RigidBody3D](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html), aberta). Um sistema de LOD de simulação próprio não está documentado ali: **não encontrado**.
- **Para o Ygg:** três anéis por distância: simulação completa, taxa reduzida, e "fórmula de tempo decorrido" (fogo e clima avançam por conta quando o jogador volta). Falta ver se `can_sleep` está usado nos props.
- **Ideia:** o fogo que ficou queimando longe volta como cinzas ou brasas, calculado pelo tempo ausente: consistente e barato (pilar 1).

## Pendências e ressalvas (atualizado na segunda passada)
- Todos os 16 itens têm entrada.
- Fechado com fonte aberta na segunda passada: Kleiber (121), Q10 e núcleo normal (126), volume de sangue (129), vento (132, fórmula), base da nuvem (133), Wien e cores de incandescência (135), índices de refração (136), máximo de 8 passos (137), sono de corpos na Godot (140). Correção: ângulo crítico 48,6° e tabela de cores do aço.
- Seguem de memória: difusão do O2 no ar e dimensões de traqueia (122), calor específico do corpo (126), força ~m^(2/3) (121), densidade do ar (132), estequiometria da fermentação (130), regra de Arrhenius (130).
- Seguem fracos (só resumo de busca): degradação da seda (123), curas de queimadura (128; NCBI bloqueado), classes de hemorragia (129, Wikipédia), Nature 2026 de insetos (122).
- Não encontrado: inflamabilidade da seda, sebo e ponto de fulgor, coagulação no tempo, decomposição, sensibilidade infravermelha, padrões dos passos do Jolt na Godot, LOD de simulação documentado, palestra GDC de Jolt.
- Ao conferir 137, o Jolt exige passo de 60 Hz com 1 collision step; os padrões do Godot para `velocity_steps` e `position_steps` devem ser lidos no editor.

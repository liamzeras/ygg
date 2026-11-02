# Blocos 3 e 9: materiais, eletricidade e metais (pesquisa do Sábio)

> Criado em 2026-11-01. Conhecimento, não decisão: nada aqui muda o jogo sem aprovação.
> Marcas: sem marca = conferido na fonte citada; `[memória, a confirmar]`; `[fonte fraca]`.
> Fontes abertas por mim: [ToolBox densidades](https://www.engineeringtoolbox.com/density-solids-d_1265.html) · [ToolBox madeiras](https://www.engineeringtoolbox.com/wood-density-d_40.html) · [ToolBox módulo de Young](https://www.engineeringtoolbox.com/young-modulus-d_417.html) · [ToolBox resistividade](https://www.engineeringtoolbox.com/resistivity-conductivity-d_418.html) · Wikipedia (links nos itens). Não consegui abrir: Wood Handbook (USDA, 403), OSHA (403), ToolBox Mohs/rigidez dielétrica (404).
> Os itens 30 e 31 (fratura e tenacidade) não são deste arquivo; já têm ficha em `contexto-fisico.md`.

## Bloco 3: Materiais e resistência

### 28. Lei de Hooke e elasticidade [P1]
- **Regra:** dentro de um limite, a deformação é proporcional à força e o objeto volta ao normal ao soltar.
- **Fórmula:** `F = k·x`, com `k = E·A/L` (E em Pa, A em m², L em m). Barra de aço, 1 m, 1 cm²: k = 200e9 × 1e-4 / 1 = 2e7 N/m; 1000 N alongam 0,05 mm. `[memória, a confirmar]` (fórmula de livro-texto).
- **Valores:** E (GPa): aço 200; cobre 117; alumínio 69; vidro 50–90; granito 52; carvalho ao longo do veio 11; borracha 0,01–0,1 ([ToolBox](https://www.engineeringtoolbox.com/young-modulus-d_417.html)). Latão e bronze ~100–125 (mesma fonte).
- **Para o Ygg:** só vale para o que dobra de forma visível (galhos, cordas, arcos). Em objetos rígidos, ignore; use apenas o limite do item 29.
- **Ideia:** arco/galho "carrega" energia ao ser puxado e a devolve ao soltar, para catapultas improvisadas.

### 29. Tensão, deformação e limite de escoamento [P1]
- **Regra:** abaixo do limite de escoamento o material volta; acima, fica deformado para sempre; mais acima, rompe.
- **Fórmula:** `σ = F/A` (Pa). Barra de aço A36 de 1 cm² escoa com 250 MPa × 1e-4 m² = 25 kN (~2,5 t).
- **Valores:** escoamento / ruptura (MPa): aço A36 250 / 400; cobre 70 / 220; alumínio 95 / 110 ([ToolBox](https://www.engineeringtoolbox.com/young-modulus-d_417.html)). Latão, vidro, madeira: tabela sem coluna clara, "não encontrado" aqui.
- **Para o Ygg:** um número por material, `yield_threshold`; acima dele o objeto fica "entortado" (estado permanente) e abaixo volta. Barato: compara-se força de impacto ÷ área.
- **Ideia:** barra de ferro entortada por um golpe 8x deixa de caber no encaixe; o jogador a endireita na forja.

### 32. Dureza e escala de Mohs [P2]
- **Regra:** o mais duro risca o mais mole. A escala é de ordem, não linear.
- **Fórmula:** não há; compara-se por risco. O diamante é ~4x mais duro que o corindo, apesar de ser só 1 degrau acima.
- **Valores:** talco 1, gipsita 2, calcita 3, fluorita 4, apatita 5, ortoclásio 6, quartzo 7, topázio 8, corindo 9, diamante 10 ([Wikipedia](https://en.wikipedia.org/wiki/Mohs_scale_of_mineral_hardness)). Unha ~2,5, moeda de cobre ~3,5, vidro ~5,5: `[memória, a confirmar]`.
- **Para o Ygg:** campo `hardness` inteiro 1–10; "A risca B" se A > B; usar para pedra de amolar, vidro cortado por gema, ferramenta que gasta. Dureza não é tenacidade (ver contexto-fisico).
- **Ideia:** só uma ponta de quartzo ou melhor risca a vidraça de uma estufa mágica.

### 33. Densidades reais versus densidades de jogo [P1]
- **Regra:** densidade = massa/volume; madeira seca flutua, pedra e metal afundam.
- **Fórmula:** `ρ = m/V` (kg/m³). Razão de escala jogo/real = ρ_jogo ÷ ρ_real.
- **Valores (real, [ToolBox](https://www.engineeringtoolbox.com/density-solids-d_1265.html) e [madeiras](https://www.engineeringtoolbox.com/wood-density-d_40.html)) contra o jogo:**

| Material | Real (kg/m³) | Jogo | Razão |
|---|---|---|---|
| Madeira | carvalho 720 (600–900); pinho 350–850; balsa 110–140 | 90 | 0,125 (carvalho) |
| Metal | aço 7820; ferro fundido 7200; bronze 8740–8890; chumbo 11350 | 600 | 0,077 (aço) |
| Pedra | granito 2600–2800; calcário 2700–2800; arenito 2100–2400 | 350 | 0,13 (granito) |
| Pólvora | granulada solta: não encontrado (ToolBox e duas passadas na Wikipedia não trazem). Só há "blocos prensados de 1,7 g/cm³ = 1700 kg/m³" ([Wikipedia](https://en.wikipedia.org/wiki/Gunpowder)), que não é o grão solto | 110 | não comparável |

- **Para o Ygg:** a ordem real (metal > pedra > madeira) está certa e pedra/madeira (3,9 no jogo contra 3,75 real) também. **Metal está comprimido**: 6,7x a madeira no jogo contra 10,9x no real. Para a mesma escala de ~0,125, o aço seria ~980. Decisão do Liam; mudar afeta empurrões e dano (impacto = massa x velocidade). Pólvora real de lote fica fora desta pesquisa.
- **Ideia:** porta de ferro que só um 8x move, mas a mesma porta de madeira sai voando com um empurrão comum.

### 34. Fadiga de materiais [P2]
- **Regra:** dobrar muitas vezes abaixo do limite de ruptura ainda quebra, por trincas que crescem.
- **Fórmula:** regra de Miner: falha quando `Σ nᵢ/Nᵢ = 1` (n = ciclos feitos, N = ciclos até quebrar naquela tensão). Exemplo: 4e4 ciclos onde N = 1e5 gastam 0,4; sobram 60%. ([Wikipedia](https://en.wikipedia.org/wiki/Fatigue_(material)))
- **Valores:** a fonte não dá limite de resistência numérico; só diz que alguns aços têm limite de fadiga e que metais cúbicos de face centrada (como alumínio) em geral não. Valores: "não encontrado".
- **Para o Ygg:** um contador `desgaste` por item (acumula a cada golpe/uso, proporcional à tensão). Custa um float; já serve para equipamentos.
- **Ideia:** a espada que aguenta cem golpes fracos quebra em dez golpes 8x; ferreiro vê "trincas" no item.

### 35. Anisotropia da madeira [P2]
- **Regra:** madeira é muito mais forte ao longo do veio que atravessado; racha fácil a favor do veio.
- **Fórmula:** sem fórmula curta; usa-se razão `R = σ_perpendicular / σ_paralelo`. Razão numérica: não encontrado (Wood Handbook bloqueou por 403 em dois endereços; a [Wikipedia: Orthotropic](https://en.wikipedia.org/wiki/Orthotropic_material) confirma só que a madeira é mais rígida e forte ao longo do veio e cita a equação de Hankinson sem valores). Fonte aberta só confirma que a madeira é ortotrópica e que nós pioram o esforço perpendicular ([Wikipedia](https://en.wikipedia.org/wiki/Wood)).
- **Valores:** densidade a 12%: `ρ = G × 1120 kg/m³` (mesma fonte). Resistência à compressão 11,7–70,2 MPa e flexão 27–139 MPa conforme a espécie (sentido não informado pela fonte).
- **Para o Ygg:** cada madeira ganha um eixo de veio (um vetor). Golpe de machado alinhado racha em lascas longas; contra o veio, só amassa.
- **Ideia:** achar o veio de um tronco revela onde bater para partir sem esforço.

### 36. Flambagem e vigas [P2]
- **Regra:** coluna esbelta dobra de lado antes de esmagar.
- **Fórmula:** `P = π²·E·I / (K·L)²` (K = 1 para as duas pontas livres; outros K: não encontrados no texto) ([Wikipedia](https://en.wikipedia.org/wiki/Euler%27s_critical_load)). Pilar de carvalho 10×10 cm: `I = b·h³/12 = 8,33e-6 m⁴`; E = 11 GPa; L = 3 m: P ≈ 100 kN (~10 t). Com L = 6 m: 25 kN (um quarto).
- **Valores:** ver E no item 28.
- **Para o Ygg:** `capacidade ≈ E·I / L²` é uma conta; dobrar o comprimento divide a carga por 4.
- **Ideia:** a ponte improvisada com um tronco longo aguenta o jogador, mas falha com o inimigo gigante.

### 37. Compósitos e armaduras em camadas [P2]
- **Regra:** camada dura espalha e quebra o golpe; camada macia amortece; cada uma resolve um tipo de dano.
- **Fórmula:** não há modelo curto na fonte. Modelo de jogo: dano residual = dano × (1 − bloqueio_camada) por tipo (cortante, perfurante, contundente).
- **Valores:** malha de anéis de 1,0–1,6 mm de arame; o gibão (acolchoado) vai por baixo; malha não protege bem de contusão ([Wikipedia: Mail](https://en.wikipedia.org/wiki/Mail_(armour))). Dados quantitativos de penetração: não encontrado.
- **Para o Ygg:** lista de camadas; o dano passa pela camada externa e depois pela interna, cada uma com sua tabela por tipo. Cabe no sistema de equipamentos.
- **Ideia:** malha sem gibão deixa o golpe contundente passar quase inteiro; combinar camadas é escolha do jogador.

### 38. Propagação de trincas [P2]
- **Regra:** uma trinca concentra tensão na ponta e cresce sozinha quando passa de um valor crítico; vira pedaços.
- **Fórmula:** `K = Y·σ·√(π·a)`; quebra se `K ≥ K_Ic` (K_Ic do vidro 0,7–1,0 MPa·√m, conforme `contexto-fisico.md`, não reconferido) `[memória, a confirmar]`. Com a = 1 mm, Y = 1, K = 0,75: σ = 0,75 / √(π·0,001) ≈ 13 MPa.
- **Valores:** a lei de Paris descreve o crescimento por ciclos (citada em [Wikipedia: fadiga](https://en.wikipedia.org/wiki/Fatigue_(material)), sem constantes). Constantes: não encontrado.
- **Para o Ygg:** `dano_acumulado` guarda a "trinca" do objeto; quanto maior, menor a força para quebrar. Quebra em 2–4 pedaços por corte do mesh, não Voronoi.
- **Ideia:** rachar a parede com golpes pequenos para derrubá-la com um único golpe forte depois.

### 39. Corte, perfuração e impacto contra armaduras [P2]
- **Regra:** o que importa é a pressão na ponta: `p = F/A`. Ponta fina perfura, lâmina corta, martelo transmite energia sem furar.
- **Fórmula:** `E = ½·m·v²` e `p = F/A`. Maça de 1 kg a 10 m/s: 50 J; se a ponta tem 1 mm², 100 N geram 100 MPa (acima do escoamento do cobre) `[memória, a confirmar]` (conta de livro-texto).
- **Valores:** riveted mail resiste à maioria dos golpes de lâmina; lança forte, estoque, arcos fortes e besta podem penetrar; maças e martelos ferem sem penetrar ([Wikipedia: Mail](https://en.wikipedia.org/wiki/Mail_(armour))). Fonte cita testes informais de vídeo: `[fonte fraca]`.
- **Para o Ygg:** três canais de dano (corte, perfuração, contusão) × três de armadura. Equipamentos: escolher arma pela armadura do inimigo. Teto de velocidade de golpe (ver contexto-fisico) evita o "martelo hipersônico".
- **Ideia:** inimigo de placa pesada, imune a lâminas, cai com bastão pesado de um 8x.

### 40. Fibras e cordas [P3]
- **Regra:** a corda rompe pelo ponto mais fraco (nó, desgaste); molhar muda a resistência.
- **Fórmula:** atrito em volta de um cilindro (cabrestante): `T_carga = T_mão · e^(μ·θ)`. Com μ = 0,3 e 3 voltas (θ = 18,85 rad): e^5,65 ≈ 285x. `[memória, a confirmar]`
- **Valores:** náilon fica 10–15% mais fraco molhado; poliéster ~90% do náilon; no kernmantle o miolo dá ~70% da resistência ([Wikipedia](https://en.wikipedia.org/wiki/Rope)). Perda por nó: não encontrado.
- **Para o Ygg:** corda como cadeia de segmentos com `tensão_máxima`; molhada perde uma fração. Barato com juntas do Jolt.
- **Ideia:** amarrar a corda num tronco em duas voltas segura um gigante, e basta uma faísca para queimar o ponto fraco.

### 41. Vidro e cerâmica [P2]
- **Regra:** rígidos e duros, sem escoamento; fraturam de uma vez a partir de falhas na superfície.
- **Fórmula:** a mesma do item 38. Sem plasticidade, não há aviso antes de quebrar.
- **Valores:** vidro comum 2400–2800 kg/m³; E 50–90 GPa ([ToolBox](https://www.engineeringtoolbox.com/density-solids-d_1265.html), [E](https://www.engineeringtoolbox.com/young-modulus-d_417.html)). Rigidez dielétrica do vidro de janela 9,8–13,8 MV/m ([Wikipedia](https://en.wikipedia.org/wiki/Dielectric_strength)). Cerâmicas: não encontrado.
- **Para o Ygg:** `fracture_toughness` baixa, `yield` igual à fratura (sem estado "entortado"). Cacos como pedaços afiados no chão.
- **Ideia:** vidraça rachada por um som alto (ressonância mágica) estilhaça com um toque; atravessar descalço dá dano.

## Bloco 9: Eletricidade, magnetismo e metais

### 100. Lei de Ohm [P2]
- **Regra:** a corrente é proporcional à tensão e inversamente à resistência.
- **Fórmula:** `I = V/R` (A, V, Ω); `R = ρ·L/A`. Fio de cobre de 10 m e 1 mm² (ρ = 1,724e-8 Ω·m): R = 1,724e-8 × 10 / 1e-6 = 0,17 Ω. `[memória, a confirmar]` para a forma geral; ρ do cobre vem da fonte.
- **Valores:** ver item 101 ([ToolBox](https://www.engineeringtoolbox.com/resistivity-conductivity-d_418.html)).
- **Para o Ygg:** não simular circuitos. Grafo de condutores: cada objeto `conductive` liga a quem toca; a carga escolhe o caminho de menor resistência.
- **Ideia:** raio mágico segue uma corrente de ferro até quem está encostado nela, ignorando o escudo de madeira.

### 101. Condutividade de metais, água e corpo [P2]
- **Regra:** metais conduzem bem; madeira seca e borracha quase não; água pura pouco, água com sal muito mais.
- **Fórmula:** `σ = 1/ρ` (S/m).
- **Valores (ρ em Ω·m, [ToolBox](https://www.engineeringtoolbox.com/resistivity-conductivity-d_418.html)):** prata 1,59e-8; cobre 1,724e-8; alumínio 2,65e-8; ferro 9,71e-8; aço-carbono 15e-8; chumbo 20,6e-8; latão 5,9–7,1e-8; vidro 1e9–1e13; borracha dura 1e13–1e15. **Água:** ver correção abaixo; a leitura da ToolBox para água foi descartada. Corpo humano: ver item 104.
  **Correção (2ª passada):** a [Wikipedia](https://en.wikipedia.org/wiki/Electrical_resistivity_and_conductivity), a 20 °C, traz água do mar 0,21 Ω·m (4,8 S/m); água potável 20–2000 Ω·m (5e-4 a 5e-2 S/m); deionizada 1,8e5 Ω·m; madeira úmida 1e3–1e4 Ω·m; madeira seca em estufa 1e14–1e16 Ω·m; vidro 1e11–1e15 Ω·m. Divergência: o resumo da ToolBox (água salgada 4, doce 1e-2) estava invertido ou em outra unidade; use os valores da Wikipedia. Água do mar conduz ~100 a 10.000x mais que a potável.
- **Para o Ygg:** campo `conductive` (0 a 1 ou 3 classes: isolante, médio, bom). Água salgada > doce > pura; ferro conduz bem, mas menos que cobre (~5,6x resistivo).
- **Ideia:** poça salgada espalha o choque para o grupo todo; poça doce, só no ponto.

### 102. Efeito Joule [P2]
- **Regra:** corrente que passa por resistência vira calor.
- **Fórmula:** `P = I²·R`; `ΔT = P·t / (m·c)`. `P = I²R` confirmado em [Wikipedia: Joule heating](https://en.wikipedia.org/wiki/Joule_heating). Fio acima (0,17 Ω) com 30 A: P = 155 W. Massa 0,088 kg (8790 kg/m³ da ToolBox); c do cobre ≈ 385 J/kg·K (contexto-fisico, 🟡): sobe ~4,6 K/s se não perder calor.
- **Valores:** ρ dos metais no item 101.
- **Para o Ygg:** já existe calor acumulado até ignição; basta somar calor ∝ I²·R·dt ao objeto. Condutor fino aquece mais que o grosso.
- **Ideia:** raio sobre a cerca de arame fino a faz brilhar e acender a palha encostada.

### 103. Ruptura dielétrica e raios [P2]
- **Regra:** o ar vira condutor quando o campo passa de ~3 MV/m; a descarga procura o caminho mais fácil, em geral o ponto mais alto e pontudo.
- **Fórmula:** `V_ruptura ≈ E_ruptura × distância`. 1 cm de ar: 3e6 × 0,01 = 30 kV ([Wikipedia](https://en.wikipedia.org/wiki/Dielectric_strength)).
- **Valores:** raio negativo médio: ~30 kA, ~15 C, ~1 GJ; ar a ~30.000 °C; objetos altos e aterrados lançam canais que encontram o líder; a corrente no chão espalha tensão de passo e fere mais gente que o golpe direto ([Wikipedia: Lightning](https://en.wikipedia.org/wiki/Lightning)).
- **Para o Ygg:** para magia de raio, `raycast` do alvo ao mais alto condutor num raio e salto em arcos até um limite de distância.
- **Ideia:** cravar uma lança de ferro no chão atrai o raio longe do grupo, mas eletrifica o chão úmido ao redor.

### 104. Choque elétrico no corpo [P2]
- **Regra:** o efeito depende da corrente (não da tensão), do tempo e do caminho.
- **Fórmula:** `I = V/R_corpo`. 220 V com 1350 Ω (mediana, mão-mão, pele seca): 163 mA; pele molhada ~1000 Ω.
- **Valores:** ~1 mA percepção; ~10 mA contração forte, "limiar de soltar"; >30 mA pode causar fibrilação; DC precisa de ~90–130 mA para fibrilar. Resistência por tensão e percentil: 25 V 1750–6100 Ω; 220 V 1000–2125 Ω; 1000 V 700–1500 Ω; seca até 100.000 Ω, molhada ~1000 Ω ([Wikipedia](https://en.wikipedia.org/wiki/Electric_shock), que cita IEC 60479-1 e NIOSH). Limiar exato de paralisia: não encontrado.
- **Para o Ygg:** três faixas em estados: formigamento (leve), travado/paralisado, dano grave. Molhado e salgado sobe a faixa. Não precisa de ohms reais, só de faixas.
- **Ideia:** inimigo de armadura de ferro dentro de poça é paralisado por faísca fraca; fora da poça, a mesma faísca só irrita.

### 105. Gaiola de Faraday [P3]
- **Regra:** casca condutora desvia a corrente por fora e blinda o interior de campos elétricos.
- **Fórmula:** em malha, os furos devem ser menores que o comprimento de onda ([Wikipedia](https://en.wikipedia.org/wiki/Faraday_cage)).
- **Valores:** não bloqueia campos magnéticos estáticos ou lentos (a bússola funciona dentro); carros e aviões funcionam como gaiolas contra raios; casca grossa e fechada blinda mais.
- **Para o Ygg:** a regra "condutor fechado = isolado de raio" é barata: se o alvo estiver dentro de um volume `conductive` fechado, a descarga contorna.
- **Ideia:** carroça com revestimento de ferro é abrigo contra a magia de raio; ímãs ainda a puxam.

### 106. Ferromagnetismo e indução [P3]
- **Regra:** só ferro, aço, níquel e cobalto são fortemente atraídos; cobre e bronze não. Mover um ímã perto de um fio gera corrente.
- **Fórmula:** lei de Faraday `fem = −dΦ/dt` ([Wikipedia](https://en.wikipedia.org/wiki/Faraday%27s_law_of_induction)).
- **Valores:** temperatura de Curie: ferro ~770 °C, cobalto ~1130 °C, níquel ~354 °C ([Wikipedia](https://en.wikipedia.org/wiki/Curie_temperature)). Que cobre e bronze não são atraídos: `[memória, a confirmar]`.
- **Para o Ygg:** `ferromagnético` booleano por material; magia de atração aplica força só a quem tem a marca. Curie opcional.
- **Ideia:** ímã gigante puxa a armadura de aço do inimigo e deixa o de bronze intacto; metal em brasa solta o ímã.

### 107. Eletrólise [P3]
- **Regra:** corrente quebra a água em hidrogênio e oxigênio; com sal, aparece cloro.
- **Fórmula:** `n = I·t / (z·F)` (F = 96485 C/mol, `[memória, a confirmar]`). 10 A por 1 h = 36.000 C = 0,373 mol de elétrons → 0,187 mol de H₂ ≈ 4,2 L (gás ideal a 0 °C) `[memória, a confirmar]`.
- **Valores:** tensão mínima 1,23 V, prática >1,48 V; proporção 2:1 de hidrogênio para oxigênio; água salgada produz cloro tóxico e corrosivo; eficiência 70–80% ([Wikipedia](https://en.wikipedia.org/wiki/Electrolysis_of_water)).
- **Para o Ygg:** mecânica lenta e opcional: eletrodos na água soltam "gás inflamável" que se acumula. Reusa fogo/explosão.
- **Ideia:** raio caindo no lago produz bolhas de gás que explodem se uma tocha chegar perto.

### 108. Ligas metálicas [P2]
- **Regra:** misturar metais ou carbono muda dureza, ponto de fusão e resistência.
- **Fórmula:** não há; regras por composição.
- **Valores:** aço 0,02–2,14% de carbono; ferro fundido >2,1%, quebradiço; ferro forjado <0,1% C com 1–2% de escória; mais carbono = mais duro e menos dúctil; densidade do aço 7750–8050 kg/m³ ([Wikipedia: Steel](https://en.wikipedia.org/wiki/Steel)). Bronze ~88% cobre + 12% tin (4–20%); funde a ~950 °C; dureza Vickers 60–258 contra 30–80 do ferro forjado; resiste à corrosão ([Wikipedia: Bronze](https://en.wikipedia.org/wiki/Bronze)). Ferro funde a ~1540 °C (fonte Steel). Resistência/escoamento por liga: não encontrado nas duas páginas.
- **Para o Ygg:** tabela de ligas com tripla `(dureza, tenacidade, ponto de fusão)`. Bronze acessível em fogueira; ferro exige forno com sopro, o que dá progressão natural.
- **Ideia:** fornalha com foles sobe a temperatura e abre novos metais.

### 109. Têmpera, revenimento e encruamento [P2]
- **Regra:** esfriar rápido o aço quente o deixa duro e quebradiço (martensita); reaquecer um pouco (revenir) troca dureza por tenacidade; bater a frio endurece o metal, até rachar; recozer desfaz.
- **Fórmula:** não há curta. Qualitativo: dureza ↑ e tenacidade ↓ com a têmpera.
- **Valores:** aquecer a 815–900 °C e esfriar rápido; água dá mais dureza e mais risco de trinca/empenar; óleo é mais lento e seguro; fonte não dá temperaturas de revenimento ([Wikipedia: Quenching](https://en.wikipedia.org/wiki/Quenching)). Encruamento reduz ductilidade; cobre é recozido várias vezes durante a forja ([Wikipedia](https://en.wikipedia.org/wiki/Work_hardening)).
- **Para o Ygg:** estados da peça: `encruamento` (sobe ao bater, cai ao recozer) e `têmpera` (dureza vs tenacidade). Qualidade de arma/armadura = escolhas de forja.
- **Ideia:** espada temperada em água fica afiada demais e se parte no 8x; temperada em óleo e revenida, aguenta.

## Pendentes e limites (atualizado na 2ª passada)

- Todos os itens dos meus blocos (28, 29, 32 a 41, 100 a 109) têm ficha.
- **Fechado agora:** condutividade da água (corrigida), Curie, lei de Faraday, `P = I²R`.
- **Continua sem fonte:** densidade da pólvora solta; razão do veio da madeira (Wood Handbook 403); constantes da lei de Paris; perda de resistência por nó; temperaturas de revenimento; Mohs de unha/moeda/vidro; cobre e bronze não magnéticos; fórmulas de livro-texto dos itens 28, 36 (apenas Euler confirmado), 38, 39, 40 (cabrestante), 100, 107 (Faraday de eletrólise).
- Não consegui abrir: Wood Handbook (dois endereços), OSHA, ToolBox de Mohs, dielétrica e condutividade.
- Recomendações dependem da decisão do Liam sobre as densidades (item 33).

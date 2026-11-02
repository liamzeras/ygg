# Contexto físico: resposta do Gemini, auditada

> Origem: `Contexto Físico para RPG.pdf`, Deep Research do Gemini, recebido em 2026-11-01. Cobre 18 dos 140
> princípios; os outros estão em [faltantes.md](faltantes.md). Isto é conhecimento, não decisão: nada aqui
> muda o jogo sem aprovação.
> As fórmulas do PDF não sobreviveram à extração de texto; as abaixo foram reescritas na forma padrão,
> respeitando as variáveis descritas por ele.

**Confiança:** ✅ conferido em fonte primária ou no jogo · 🟡 plausível, só no PDF · ❌ erro ou exagero.

## O que importa para o Ygg

| Achado | Consequência | Situação no jogo |
|---|---|---|
| Massa cresce com o cubo; força, com o quadrado | Criatura grande é lenta, pesada e difícil de frear | Sem inimigos ainda; orienta `monstros` |
| Força não aumenta a velocidade de um golpe sem limite (Hill) | Teto de velocidade evita o "martelo hipersônico" | Sem esse teto para armas |
| Dureza não é tenacidade | Vidro e diamante resistem a riscos, mas estilhaçam | Materiais não quebram |
| Calor latente segura a temperatura | Água e gelo são escudos térmicos fortes | Calor é abstrato; não há reservatório |
| Fulgor e autoignição são coisas diferentes | Faísca acende álcool, mas não madeira; calor prolongado acende madeira | Só um limite: `ignition_heat` |
| Atrito não depende da massa | Pedra e pedrinha param na mesma distância | Já é assim pelo motor |
| CCD é necessário em projéteis rápidos | A 80 m/s, um projétil anda 1,3 m por quadro | ✅ Bola de Fogo e Dardo já usam |

## Fichas

### Mecânica

**Atrito (nº 6).** `F = μ x N`, então `a = μ x g`: a massa se cancela.

| Par | μ estático | μ dinâmico | Confiança |
|---|---|---|---|
| Madeira/madeira | 0,25–0,5 | carvalho: 0,32–0,48 | ✅ [ToolBox](https://www.engineeringtoolbox.com/friction-coefficients-d_778.html) |
| Aço/aço, seco | 0,5–0,8 | 0,42 | ✅ ToolBox |
| Gelo/gelo a 0 °C | 0,1 | 0,02 | ✅ ToolBox |
| Borracha/asfalto | 0,9 | 0,5–0,8 | ✅ ToolBox |
| Lama/pedra | 0,30 | 0,15 | ❌ o PDF cita a ToolBox, mas ela não traz esse par |

- ❌ **O PDF manda configurar atrito estático e dinâmico:** a Godot só tem um `friction`
  ([PhysicsMaterial](https://docs.godotengine.org/en/stable/classes/class_physicsmaterial.html)).
- ✅ **Regra de combinação:** a documentação diz que, sem `rough`, vale o menor atrito do par. A medição no
  nosso teste combina: metal (0,4) sobre o piso (1,0) perdeu 2 m/s em 0,5 s, ou μ ≈ 0,4. É uma medição só.

**Lei do quadrado-cubo (nº 17).** Com fator de escala `s`: `área = s²`, `massa = s³`. ✅ Conta correta: a 2x,
80 kg viram 640 kg; a 8x, 40.960 kg.

- **Não confundir:** o "8x" do PDF é tamanho. O teto de 8x do Ygg é de atributo, em um humano de tamanho
  normal.
- 🟡 Precedente citado: Shadow of the Colossus transmite peso pela lentidão. O nome da tabela no PDF é
  impreciso, mas a ideia serve.

**Efeito Magnus (nº 15).** `F ≈ ½ x C_L x ρ x A x r x (ω × v)`. No jogo: `F = k x (ω × v)`, um produto vetorial
por quadro. 🟡 Coeficientes da tabela não confirmados. Prioridade baixa no Ygg.

### Corpo

**Força muscular (nº 19 e 21).** `F = PCSA x σ`; curva de Hill: `(F + a)(v + b) = (F0 + a) x b`.

- 🟡 Tensão específica: fibras lentas 10–20 N/cm²; rápidas 25–40. Exemplo: 150 cm² x 30 N/cm² = 4.500 N.
- **Ideia central:** força acelera até um teto; ela não eleva o teto sem limite. Uma adaga e uma viga atingem
  velocidades próximas para quem é muito forte, e a viga carrega muito mais momento.
- 🟡 O teto de 25 m/s é sugestão do PDF, não dado medido. Precisa ser comparado aos limites humanos reais do
  nº 18, ainda pendente, e às velocidades de arremesso atuais do jogo.
- ❌ "Chegar a 25 m/s em um frame" não combina com o pilar de credibilidade: precisa de tempo de aceleração.

### Materiais

**Tenacidade e fratura (nº 30 e 31).** `K_I = Y x σ x √(π x a)`; quebra quando `K_I ≥ K_Ic`.

| Material | Módulo E | K_Ic (MPa·√m) | Comportamento |
|---|---|---|---|
| Vidro | ~70 GPa | 0,7–1,0 | Estilhaça sem aviso |
| Madeira | ~11–13 GPa | 1,0–1,5 | Entorta e racha no veio |
| Aço | ~200 GPa | 50–100 | Amassa antes de quebrar |
| Diamante | ~1200 GPa | 2–4 | Duro, mas estilhaça com impacto |

- ❌ **Erro na síntese do PDF:** usa 200 GPa e 70 GPa como "ruptura". Isso é rigidez (módulo E), não tenacidade.
- **Para o Ygg:** dois números por material, `yield_threshold` e `fracture_toughness`. A trinca `a` da fórmula
  sugere uma mecânica boa: danificar antes facilita quebrar depois.
- 🟡 Frio reduzir a tenacidade do aço é fenômeno real, mas "como vidro" é exagero a calibrar.

### Calor

**Calor específico, condução e latente (nº 43, 44 e 48).** `Q = m x c x ΔT` · `q = k x A x ΔT / d` · `Q = m x L`.

| Substância | c (kJ/kg·K) | k (W/m·K) | L (kJ/kg) |
|---|---|---|---|
| Água líquida | 4,18 | 0,60 | 2257 (evaporar) |
| Gelo a 0 °C | 2,05–2,09 | 2,22 | 334 (fundir) |
| Cobre | 0,38–0,39 | 386–401 | 206 (fundir) |
| Ar seco | 1,00–1,01 | 0,026 | — |
| Madeira | ~1,5 | 0,16 | não funde; pirólise |

🟡 Valores de manual, compatíveis com o que se conhece, não reconferidos um a um.

- **Para o Ygg:** o PDF sugere trocar o calor por Joules. **Recomendo manter o calor abstrato atual** e adicionar
  só um reservatório de mudança de fase em água e gelo.
- ❌ "Armadura supercondutora" está errado: é condutora. A ideia de metal passar queimadura e couro proteger vale.

### Fogo

**Fulgor e autoignição (nº 56).** Com faísca, acende acima de `T_fulgor`; sem faísca, acima de `T_autoignição`.

| Substância | Fulgor | Autoignição |
|---|---|---|
| Etanol | ~16 °C | ~365 °C |
| Diesel/querosene | ~50–60 °C | ~210 °C |
| Madeira seca | — | ~300 °C |

- 🟡 O PDF cita uma página de pontos de ebulição; a fonte adequada é a [nº 38](https://www.engineeringtoolbox.com/flash-point-autoignition-temperature-kindling-hydrocarbons-alkane-alkene-d_1941.html).
- **Para o Ygg:** o melhor achado do bloco. Faísca e calor prolongado passam a ser ferramentas diferentes.
- ❌ Backdraft "só por bloquear o oxigênio" está mal explicado. Correção no nº 61 de
  [blocos 4 e 5](blocos-04-05-calor-fogo.md).
- 🟡 Crítica a Divinity e BG3 sobre aquecimento prévio é opinião do PDF, sem fonte.

### Explosões

**Hopkinson-Cranz e Friedlander (nº 68 e 69).** `Z = R / W^(1/3)` · `p(t) = ps x (1 − t/td) x e^(−b x t/td)`.

- ✅ Conta: 1 kg a 2 m equivale a 8 kg a 4 m.
- 🟡 Faixas: Z < 1,5, mais de 100 kPa; Z de 3 a 4,5, 30–50 kPa; Z de 15 a 30, 1–3 kPa.
- ❌ **"Decai com o cubo da distância" é falso:** a lei relaciona carga e distância. Na tabela do IATG, a pressão
  cai com expoente ~2,3 a 2 perto e ~1,4 longe. Ver [blocos 6 e 7](blocos-06-07-explosoes-fluidos.md).
- ❌ **"Aspirando a matéria brutalmente" é exagero:** a subpressão fica em torno de 28 kPa no máximo, segundo
  Glasstone e Dolan `[fonte fraca]`, lido em espelho. Um puxão de volta seria licença de jogo, e não física.
- **Para o Ygg:** `explosion.gd` usa queda linear. A oclusão por parede estava em andamento na conversa principal em
  2026-11-02; medição em [resultado-formulas.md](resultado-formulas.md).

**Fragmentação de Mott (nº 71).** `N(m) = N_T x exp(−√(m/μ))`. ✅ [Mazonka, 2012](https://arxiv.org/pdf/1304.2285).

- ❌ **Fonte errada:** o PDF cita uma tese sobre estrelas de nêutrons (ref. 49). ❌ "Aço fundido" e "milhões" também
  não têm base no texto.
- **Para o Ygg:** poucos raycasts por explosão e alguns pedaços visíveis.

### Biologia

**Dose-resposta (nº 124).** `efeito = dose / massa do alvo`, com limiar. Serve como regra, e o motor já tem massa.

- ❌ O exemplo dos litros de cianeto contradiz a própria tabela. ❌ Escalar por massa de forma linear entre espécies
  simplifica demais; a alometria está no nº 121.
- 🟡 Fontes fracas para a regra geral (tramadol, T-2). **Removi desta base os valores de agentes de guerra**: o jogo
  não precisa deles, só da forma da curva.
- 🟡 Precedente citado: narcóticos de Ark, em que criaturas maiores exigem mais flechas.

### Som e simulação

**Som (nº 134).** `atraso = distância / velocidade`. Ar ~343 m/s, água ~1433–1500, aço ~5800–5900. 🟡
❌ "Gás oxigênio" está errado: o valor é do ar. **Para o Ygg:** atraso barato em eventos-chave e reação de IA
quando o som chega. Espera áudio e IA.

**Tunelamento e autômatos (nº 138 e 139).** Risco quando `v x Δt > espessura`.

| Corpo | Velocidade | Por quadro a 60 fps | Solução |
|---|---|---|---|
| Humano | 7–9 m/s | ~0,14 m | Padrão |
| Flecha | 70–90 m/s | 1,2–1,5 m | CCD |
| Estilhaço | > 500 m/s | > 8 m | Raycast |

- ✅ Contas corretas; ✅ a Bola de Fogo e o Dardo já têm `continuous_cd`.
- ❌ **"Varredura pela placa gráfica" está errado:** o CCD da Jolt roda na CPU, conforme a documentação oficial.
  Ver [blocos 11 e 12](blocos-11-12-biologia-simulacao.md).
- ❌ A afirmação sobre Minecraft cita uma palestra sobre renderização, que não sustenta a simulação de fogo.
- ✅ Jolt em Horizon Forbidden West é real: [GDC 2022](https://gdcvault.com/play/1027560/Architecting-Jolt-Physics-for-Horizon).

## Qualidade das fontes do PDF

- **Boas:** Engineering ToolBox para valores de manual, arXiv, PubMed, GDC, IATG.
- **Fracas:** Reddit (10), FactMyth (8), blog Wiser Daily (9), página de vendas de cerâmica (19), Scribd (21) e
  glossário ForensicSpot (39, bloqueado quando tentei ler).
- **Sem relação com o que sustentam:** tese de estrelas de nêutrons (49), Minecraft (60), listagem do arXiv (63).
- **Precedentes de jogos** quase nunca têm fonte. Trate como pista, não como fato.

## Ideias aproveitáveis

| Ideia | Princípio | Risco para os pilares |
|---|---|---|
| Faísca acende vapores, mas não lenha | Fulgor | Nenhum |
| Poça transforma fogo em neblina que bloqueia visão | Calor latente | Nenhum |
| Metal conduz queimadura; couro protege | Condução | Exige estado em personagens |
| Danificar a parede antes facilita derrubá-la | Fratura | Exige materiais quebráveis |
| Som chega depois: guardas demoram a reagir | Velocidade do som | Exige IA |
| Veneno diluído em lago ou concentrado em eclusa | Dose | Exige água e criaturas |
| Inimigo gigante não consegue frear e cai no abismo | Quadrado-cubo | Exige IA |
| Ampliar um barril sobre uma ponte | Quadrado-cubo | Magia cara, conforme o pilar 2 |

Descartadas por ferirem os pilares ou por custo: flechas com giro mágico infinito, saltos que demolem o chão e
Voronoi em todos os objetos.

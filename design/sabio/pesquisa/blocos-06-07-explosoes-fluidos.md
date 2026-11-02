# Blocos 6 e 7: explosões, gases e fluidos (itens 67, 70, 72-87)

> Criado em 2026-11-01 pelo Sábio. Pesquisa, não decisão. Só efeitos observáveis e modelos simplificados.
> Marcas: sem marca = conferido na fonte; `[memória, a confirmar]`; `[fonte fraca]`.


## Auditoria das duas afirmações do PDF

Fontes abertas e lidas: [IATG 01.80 (ONU, 2021)](https://data.unsaferguard.org/iatg/en/IATG-01.80-Formulae-ammunition-management-IATG-V.3.pdf), [ARL-TR-9924](https://arl.devcom.army.mil/wp-content/uploads/sites/3/ARL-TR-9924.pdf) e o capítulo III de Glasstone e Dolan, *Effects of Nuclear Weapons* (espelho: [bkardell.com](https://bkardell.com/effects-of-nuclear-math/html/chapter3.html), `[fonte fraca]` por ser espelho, mas o texto citado confere com o livro, que não abri no original).

### A) "A sobrepressão decai com o cubo da distância": FALSO como regra geral

- O cubo aparece em outro lugar: a **raiz cúbica da carga** (`R = Z x W^(1/3)`, IATG tabela 1). Isso relaciona carga e distância, não diz como a pressão cai.
- Com a tabela 5 do IATG (pressão incidente, explosão na superfície) dá para calcular o expoente `n` em `p ~ Z^(-n)`:

| Faixa de Z (m/kg^(1/3)) | Pressão | n calculado |
|---|---|---|
| 1,08 a 2,32 | 11,5 -> 2,02 bar | ~2,3 (campo próximo) |
| 2,32 a 5 | 2,02 -> 0,43 bar | ~2,0 |
| 5 a 22,2 (tabela 3) | 0,43 -> 0,054 bar | ~1,4 (campo distante) |

- Conclusão: a queda é **mais forte que o quadrado perto** e **mais fraca que o quadrado longe**; o expoente diminui com a distância (tende a ~1 no regime acústico `[memória, a confirmar]`). Nunca chega a 3 nesses dados. Contas do Sábio sobre números da fonte.
- Obs.: os 3 pontos próximos vêm de cargas diferentes à mesma distância (1000, 10000, 100000 kg a 50 m); como a pressão só depende de Z, serve para a pressão, não para o impulso.

### B) "A fase negativa aspira matéria brutalmente": EXAGERO

- Glasstone e Dolan §3.05: a fase negativa é "um pouco mais longa" que a positiva (§3.12: pode durar vários segundos em armas nucleares), mas a subpressão máxima é "geralmente não mais que ~4 psi (~28 kPa) abaixo do ambiente" e "bem pequena" perto do pico do choque (§3.20). Os dois picos caem com a distância, o positivo mais rápido, e se aproximam em valor longe.
- Vento: após o choque o ar ainda sopra para fora por inércia (§3.13); na fase negativa inverte para dentro "com velocidade relativamente pequena" (§3.16).
- Teto físico: pressão absoluta não fica abaixo de 0; subpressão <= 101 kPa, e na prática bem menos. ARL-TR-9924 usa a Friedlander só até o primeiro cruzamento por zero (`t*`, a "duração A"); ex.: 13 g de pentolito a 1,5 m, pico de 23,3 kPa de sobrepressão durando 0,89 ms (dado da fonte, usado só como escala de tempo).
- Sielicki et al. 2015 ([PDF](https://eprints.whiterose.ac.uk/87266/12/Sielicki%2C%20Rigby%2C%20Sumelka%20-%202015%20-%20Numerical%20predictions%20of%20the%20negative%20phase.pdf)) dizem que ela importa em alvos leves e pequenas cargas, mas não dão a razão numérica no texto que extraí: razão exata, **não encontrada**.
- Para o Ygg: um "puxão de volta" fraco e lento é licença de jogo aceitável (poeira e objetos leves voltando um pouco), mas não "aspira brutalmente".

## Recomendação: curva barata de queda e paredes

**Estado atual:** `f = clamp(1 - d/R)`, linear. Contra a tabela acima, ela é **generosa demais no meio e dura demais no fim**: perto do centro cai pouco, e em `d = R/2` ainda entrega 50%, enquanto uma lei de expoente 2 daria, em relação a `R/5`, só `(0,2/0,5)^2 = 16%` (conta do Sábio).

**Curva proposta (1 divisão por corpo, sem raiz extra além da distância já calculada):**

`f(d) = clamp( (d0^2 / max(d, d0)^2 - k) / (1 - k), 0, 1 )`, com `k = d0^2 / R^2`

- `d0` = raio do "núcleo" (fração de `R`, ex. 0,2 x R: dentro dele vale 100%); `k` faz a curva chegar a 0 exatamente em `R`. Expoente 2 vem da faixa próxima (n ~ 2 a 2,3).
- Exemplo: R = 8 m, d0 = 1,6 m, k = 0,04. Em d = 4 m: (0,16 - 0,04)/0,96 = **0,125** (linear daria 0,5). Em d = 2 m: (0,64-0,04)/0,96 = 0,625.
- Dois botões em `.tres`: `core_fraction` (d0/R) e `exponent` (2). Dá para manter a curva linear como opção.
- Escala por carga: se um dia o dano variar com a carga W, use `R proporcional a W^(1/3)` (Hopkinson-Cranz, IATG tabela 1), e não R fixo.

**Paredes (modelo de 3 níveis, do mais barato ao mais fiel):**
1. **Oclusão por raycast:** da origem até 1 ponto (centro de massa) de cada corpo; se acerta algo que não seja o corpo, `f x= transmissao` do material do bloqueio (rocha ~0,1; madeira ~0,4; vidro ~0,6; valores de jogo, **sem fonte**, a calibrar). Custo: 1 raycast por corpo, já são <= 64.
2. **Confinamento:** contar quantos de 6 raios (+-X, +-Y, +-Z) a partir da origem batem em parede dentro de `R`. Cada raio que bate multiplica o impulso por um fator de reforço, até um teto. Base real: a onda refletida numa superfície perpendicular é bem maior que a incidente: no IATG tabela 5, refletida/incidente = 2,3 (Z=5), 3,4 (Z=2,32), 5,8 (Z=1,08). Em corredor, o teto de jogo pode ser 2x a 3x (valor de jogo, sem fonte).
3. **Sombra com 3 a 5 raios por corpo** (pé, tronco, cabeça) e `f` = fração livre. Só para o jogador.

Cuidado de consistência: a parede que protege também deve receber o impulso (aplicar `register_hit` no bloco). Chamar o lado do jogador de "cobertura".

---

## Bloco 6

### 67 Deflagração versus detonação [P1]
- **Regra:** na deflagração a chama avança por calor e difusão, abaixo da velocidade do som (cerca de 1 m/s em gases, [EPFL](https://graphsearch.epfl.ch/concept/306685), `[fonte fraca]`); na detonação uma onda de choque supersônica acende o material (km/s; 7,4 km/s num exemplo sólido em [ARL-TR-9924](https://arl.devcom.army.mil/wp-content/uploads/sites/3/ARL-TR-9924.pdf)). Deflagração com saída livre é bem menos violenta que contida ([Wikipedia](https://en.wikipedia.org/wiki/Deflagration), `[fonte fraca]`).
- **Fórmula:** não há uma só; critério: subsônica se `v_frente < c` (c ~343 m/s no ar).
- **Valores:** acima. Pressões de projeto de alívio: não encontrado em fonte aberta.
- **Para o Ygg:** dois perfis em `.tres`: `rise_time` longo (empurra: impulso espalhado em ~6 quadros) e curto (estilha: um quadro, mais pico). `Explosion.detonate` hoje só tem o curto.
- **Ideia:** pólvora solta faz fogaréu; trancada num barril vira estouro.

### 70 Efeitos de parede e confinamento [P1]
- **Regra:** a onda que bate perpendicular numa parede reflete e fica bem mais forte que a incidente ([ARL-TR-9924](https://arl.devcom.army.mil/wp-content/uploads/sites/3/ARL-TR-9924.pdf) §2). Parede paralela à onda deixa o ar passar (mínimo de energia).
- **Fórmula:** razão `p_refletida / p_incidente`.
- **Valores:** [IATG 01.80 tabela 5](https://data.unsaferguard.org/iatg/en/IATG-01.80-Formulae-ammunition-management-IATG-V.3.pdf): 2,3 (Z=5), 3,4 (Z=2,32), 5,8 (Z=1,08). Divisões do Sábio: 1,01/0,43 etc.
- **Para o Ygg:** ver "Recomendação" acima (raycast de oclusão, 6 raios de confinamento). Hoje `explosion.gd` não faz nenhum.
- **Ideia:** corredor estreito concentra o estouro; recuar para um canto com cobertura vira tática, e a parede rachada explica o resultado.

### 72 Ruptura de vasos pressurizados (BLEVE) [P2]
- **Regra:** o recipiente aquecido sobe de pressão; se rompe, o líquido superaquecido vira vapor quase de uma vez (cerca de 1 ms) e produz onda, estilhaços e, se inflamável, bola de fogo ([Wikipedia](https://en.wikipedia.org/wiki/Boiling_liquid_expanding_vapor_explosion), aberta e confere: "típico dentro de 1 ms"; três efeitos: onda, fragmentos e bola de fogo; `[fonte fraca]` por ser enciclopédia, mas cita casos reais). Para inflamáveis, o dano térmico costuma superar o da onda (mesma página, qualitativo; sem números comparativos).
- **Fórmula:** estoura quando `p_interna > p_ruptura` (ver 73).
- **Valores:** pressão de ruptura por material: não encontrado.
- **Para o Ygg:** barril com `pressure` que sobe com o calor; limiar em `.tres`. Ao romper: `Explosion` + fogo se inflamável + 2 a 4 pedaços.
- **Ideia:** tampa vibrando e vapor avisam antes (pilar 4); esfriar com água ou lama evita.

### 73 Lei dos gases ideais [P2]
- **Regra:** em volume fixo, aquecer sobe a pressão na mesma proporção da temperatura absoluta.
- **Fórmula:** `p V = n R T`, R = 8,3145 J/(mol·K) ([ToolBox](https://www.engineeringtoolbox.com/ideal-gas-law-d_157.html)). Fechado: `p2 = p1 x T2/T1`. Ex.: 101,3 kPa a 293 K, aquecido a 600 K: 207 kPa (2,05x).
- **Valores:** vale melhor em baixa pressão e alta temperatura (mesma página).
- **Para o Ygg:** um escalar `pressure_ratio = T/T0` por recipiente fechado, sem moles. Custo mínimo; já existe calor, falta o recipiente.
- **Ideia:** garrafa selada ao fogo estoura; um furo abre o alívio (vira assobio em vez de estouro).

### 74 Pressão atmosférica e vácuo [P2]
- **Regra:** o ar empurra com cerca de 101 kPa; sucção é diferença de pressão, não "puxão" ([ARL-TR-9924](https://arl.devcom.army.mil/wp-content/uploads/sites/3/ARL-TR-9924.pdf): 101,325 kPa).
- **Fórmula:** `F = Δp x A` `[memória, a confirmar]`. Ventosa de 10 cm de diâmetro, Δp 50 kPa: 0,00785 m² x 50.000 = 393 N (cerca de 40 kg).
- **Valores:** o teto é 101 kPa; na prática, menos.
- **Para o Ygg:** estado "selado" com `Δp` fixo e força máxima; sem gás real.
- **Ideia:** magia de sucção segura até uma massa limitada (pilar 2); superfície molhada sela melhor, poeira solta falha.

### 75 Vazamento e difusão de gases [P3]
- **Regra:** o gás se espalha de onde há mais para onde há menos; o mais pesado que o ar rasteja e acumula embaixo.
- **Fórmula:** 1ª lei de Fick, `J = -D dC/dx` ([ToolBox](https://www.engineeringtoolbox.com/air-diffusion-coefficient-gas-mixture-temperature-d_2010.html)). Limites de inflamabilidade: não encontrado.
- **Valores:** D no ar a 20 °C, 1 atm (mesma página): hidrogênio 7,56e-5 m²/s; metano 2,1e-5; CO2 1,6e-5. A própria página não esclarece uma coluna de temperatura nas linhas de metano e CO2; tomei a primeira como 20 °C. Ex.: `t ~ L²/D` (estimativa do Sábio): metano espalha 1 m em ~13 h só por difusão, ou seja, o vento e a convecção dominam e a difusão pura é irrelevante em escala de jogo.
- **Para o Ygg:** grade 3D grossa (célula ~1 m), difusão a cada 0,25 s, como no nº 139. Só vale se houver vazamento de verdade.
- **Ideia:** barril rachado solta nuvem baixa; tocha longe não acende, tocha na nuvem sim.

---

## Bloco 7

### 76 Empuxo (Arquimedes) [P1]
- **Regra:** o fluido empurra para cima com o peso do fluido deslocado. Boia se a densidade média for menor que a do fluido.
- **Fórmula:** `F = ρ_fluido x V_submerso x g`; fração submersa `= ρ_objeto/ρ_fluido`. Tronco de carvalho (720 kg/m³) na água (1000): 72% submerso e aguenta 280 kg extra por m³.
- **Valores** ([ToolBox](https://www.engineeringtoolbox.com/density-solids-d_1265.html), kg/m³): cortiça 200-250; carvalho 720; gelo 917; osso 1700-2000; granito 2600-2800; aço 7820. Água 999,8 ([ToolBox](https://www.engineeringtoolbox.com/ice-thermal-properties-d_576.html)).
- **Para o Ygg:** `Area3D` de água: para cada corpo, força para cima proporcional ao volume abaixo da superfície (caixa aproximada). Você já tem massa x densidade, então a flutuação sai quase de graça. Casca oca (barril, barco) precisa de densidade média própria. A Jolt não traz flutuação pronta `[memória, a confirmar]`.
- **Ideia:** ponte de troncos aguenta o peso; gelo boia com 92% submerso.

### 77 Viscosidade [P1]
- **Regra:** quanto mais viscoso, maior o arrasto e mais lento escoa.
- **Fórmula:** arrasto linear `F = -k v`, com `k` crescente com a viscosidade: lei de Stokes `F = 6π μ R v` ([Wikipedia](https://en.wikipedia.org/wiki/Stokes%27_law), aberta, `[fonte fraca]`), válida só para Reynolds < 1 (esfera pequena, fluido muito viscoso, como mel). Para corpo grande na água o arrasto é quadrático (item 84); o linear é aproximação de jogo. A velocidade cai como `v0 x e^(-d t)`; `d = 3 /s` (o `MudPatch.drag`) corta pela metade em 0,23 s (conta do Sábio).
- **Valores** ([ToolBox](https://www.engineeringtoolbox.com/dynamic-absolute-kinematic-viscosity-d_412.html)): ar 0,0198 mPa·s; água 1; azeite 100; glicerol 1.000; mel 10.000. **Divergência:** [LibreTexts](https://geo.libretexts.org/Courses/University_of_California_Davis/GEL_56:_Introduction_to_Geophysics_(Billen)/01:_Rheology_of_Rocks/1.05:_Viscous_Deformation), a 20 °C: água 0,001 Pa·s, leite 0,002, azeite **0,010** (10 mPa·s, não 100), mel 10, alcatrão 100. A ToolBox dá ordens de grandeza (potências de 10); a LibreTexts parece mais específica. Mel concorda (10 Pa·s). Lava: 10² a 10⁶ Pa·s, sem temperatura (LibreTexts, mesma página), ou seja, de 10 a 100.000 vezes o mel.
- **Para o Ygg:** um `damp` por fluido em `.tres`; o Lamaçal já faz isso. Usar a ordem real (óleo muito mais viscoso que água, mel mais que óleo), mas comprimida: o jogador distingue 4 a 5 níveis.
- **Ideia:** óleo escorre devagar pela rampa e o mel prende; a ordem das poças importa.

### 78 Fluidos não newtonianos (lama, areia movediça) [P1]
- **Regra:** a viscosidade depende da agitação. A areia movediça é "afinante": parada parece sólida; uma pequena perturbação a liquefaz e o corpo cede ([Wikipedia](https://en.wikipedia.org/wiki/Quicksand), aberta, `[fonte fraca]` por ser enciclopédia e a própria página pedir mais citações: classifica como "shear thinning"; parada parece sólida e "uma mudança de menos de 1% na tensão" derruba a viscosidade de repente; cita Khaldoun et al., Nature, 2005, não aberto. O fator "~10⁶" que eu tinha anotado veio só de resumo de busca de uma matéria de divulgação e **não está nessa página**: removido, valor quantitativo segue não encontrado). Para sair, mexer as pernas dá espaço à água.
- **Fórmula:** `damp = f(velocidade)`; ex.: `damp = d0 / (1 + s x |v|)` (proposta do Sábio).
- **Valores:** viscosidade medida: não encontrado.
- **Para o Ygg:** ligar o `damp` do Lamaçal à velocidade do corpo, em vez de constante; parado afunda.
- **Ideia:** mexer devagar escapa; calor ou gelo endurecem a lama.

### 79 Princípio de Pascal [P2]
- **Regra:** a pressão aplicada a um fluido fechado se transmite igual por ele; área maior multiplica a força.
- **Fórmula:** `F2 = F1 x A2/A1`; o trabalho se conserva, então `d2 = d1 x A1/A2`. Ex.: pistões de 10 e 1000 cm²: 400 N viram 40.000 N, com 1/100 do curso. Conferido em [ToolBox](https://www.engineeringtoolbox.com/pascal-laws-d_1274.html): `Fs/As = Fl/Al` (pressão igual nos dois cilindros, líquido incompressível, peso do fluido desprezado); o exemplo da página usa razão 0,1 (981 N levantam 9.810 N). A conservação do trabalho (`d2 = d1 x A1/A2`) é consequência da conservação de energia, não da página.
- **Valores:** não aplicável.
- **Para o Ygg:** dois pistões ligados por um `ratio`; sem fluido simulado. Mecânica de quebra-cabeça.
- **Ideia:** a alavanca hidráulica ergue a porta de pedra; furar o tubo vaza e perde a força.

### 80 Continuidade e Bernoulli [P2]
- **Regra:** a vazão se conserva; onde o canal estreita, a água acelera e a pressão cai.
- **Fórmula:** `A1 v1 = A2 v2`; `p + ½ρv² + ρgh = const` (sem atrito). Ex.: rio de 10 m a 1 m/s que passa a 5 m: 2 m/s; `½ρv²` vai de 500 a 2000 Pa. Conferido: [continuidade](https://www.engineeringtoolbox.com/equation-continuity-d_180.html) (`v_out = v_in x A_in/A_out`; exemplo da página: 0,35 para 0,55 m/s ao reduzir o tubo de 100 para 80 mm) e [Bernoulli](https://www.engineeringtoolbox.com/bernouilli-equation-d_183.html). Condições da página: regime permanente, incompressível, sem viscosidade (perdas entram como termo `p_loss`), ao longo de uma linha de corrente. A forma sem altura é `p + ρv²/2 = const - p_loss`.
- **Valores:** não aplicável.
- **Para o Ygg:** corrente = vetor de velocidade por trecho do rio, `v = Q/A`; empurra com `F = k (v_água - v_corpo)`. Descartar a pressão.
- **Ideia:** o trecho estreito do rio é onde o jogador não atravessa a nado.

### 81 Pressão hidrostática [P2]
- **Regra:** a pressão cresce com a profundidade e age em todas as direções.
- **Fórmula:** `p = ρ g h` ([ToolBox](https://www.engineeringtoolbox.com/hydrostatic-pressure-water-d_1632.html): 10 m = 98,1 kPa). Porta de 1x2 m, centro a 4 m: 39,2 kPa x 2 m² = 78,5 kN (cerca de 8 t; conta do Sábio). Jato por furo: `v = √(2gh)` ([Wikipedia, lei de Torricelli](https://en.wikipedia.org/wiki/Torricelli%27s_law), aberta; `[fonte fraca]` por ser enciclopédia): furo a 5 m de profundidade, 9,9 m/s.
- **Valores:** acima.
- **Para o Ygg:** `P = k x profundidade` só para portas e comportas (um número). Descartar para o jogador.
- **Ideia:** porta submersa só abre quando o nível dos dois lados iguala.

### 82 Tensão superficial e molhamento [P1]
- **Regra:** o líquido puxa a própria superfície; gotas se unem e poças pequenas ficam redondas.
- **Fórmula:** comprimento capilar `√(σ/(ρ g))`: água a 20 °C, 2,7 mm (conta do Sábio); acima disso a gravidade achata a poça.
- **Valores** ([ToolBox](https://www.engineeringtoolbox.com/surface-tension-d_962.html), N/m): água 0,0757 a 0 °C, 0,0728 a 20 °C, 0,0588 a 100 °C; hidrocarbonetos 0,018-0,027; mercúrio 0,485. Molhado reduz o atrito ([ToolBox](https://www.engineeringtoolbox.com/friction-coefficients-d_778.html)): borracha/concreto 0,6-0,85 seco, 0,45-0,75 molhado (cerca de 75 a 88%).
- **Para o Ygg:** `wetness` 0..1 por superfície, fator de atrito ~0,8; sem gotas.
- **Ideia:** molhado apaga fogo e conduz; água quente espalha mais.

### 83 Capilaridade e absorção [P2]
- **Regra:** em poros finos o líquido sobe contra a gravidade.
- **Fórmula:** `h = 2 σ cosθ / (ρ g r)` ([ToolBox](https://www.engineeringtoolbox.com/capillarity-d_961.html), aberta). Água, poro de r = 1 mm: 14,8 mm (σ = 0,0728, ρ = 1000); r = 0,1 mm: ~148 mm (conta do Sábio). **Divergência:** o exemplo da própria página dá 7,4 mm para tubo de 2 mm de diâmetro, pois usa o diâmetro no lugar do raio; a página reconhece a fórmula com raio, e o valor correto é 14,8 mm.
- **Valores:** retenção de água em pano, madeira e solo: não encontrado.
- **Para o Ygg:** `absorbency` por material; `wetness` sobe com o contato e se espalha pelo pano.
- **Ideia:** corda ou pano embebido em óleo vira pavio e leva o fogo ao barril.

### 84 Ondas e arrasto na água [P3]
- **Regra:** a água (999,8 kg/m³) é cerca de 830x mais densa que o ar (1,204 kg/m³ a 20 °C, 1 atm, [ToolBox](https://www.engineeringtoolbox.com/air-density-specific-weight-d_600.html)), então o arrasto é grande.
- **Fórmula:** `F = ½ ρ C_d A v²`. Ilustração do Sábio (não é medição): A = 0,1 m², C_d = 0,7, v = 2 m/s: 140 N. Ondas rasas: `c = √(g h)` ([Wikipedia](https://en.wikipedia.org/wiki/Shallow_water_equations), aberta, `[fonte fraca]`; canal retangular); h = 1 m: 3,1 m/s.
- **Valores:** C_d humano: não encontrado.
- **Para o Ygg:** o `damp` de água basta; sem ondas.
- **Ideia:** armadura pesada afunda; couro e cortiça sustentam.

### 85 Evaporação e secagem [P2]
- **Regra:** a água evapora mais com ar seco, quente e com vento.
- **Fórmula:** `taxa = (25 + 19 v) x A x (Ws - Wa)` kg/h, `v` em m/s, `A` em m² ([ToolBox](https://www.engineeringtoolbox.com/evaporation-water-surface-d_690.html), aberta). A página avisa que as unidades de Θ não batem, pois a equação é empírica. Com Ws = 0,014659 (água a 20 °C) e Wa = 0,0098 (ar a 25 °C, 50% UR), ambos da página, v = 0,5 m/s: 34,5 x 0,004859 = 0,168 kg/h por m², ou ~0,17 mm/h (corrigi de 0,16). Exemplo da página: piscina de 1000 m², 0,047 kg/s.
- **Valores:** calor de evaporação 2.454 kJ/kg a 20 °C (mesma página): 115 kW para a piscina.
- **Para o Ygg:** `wetness -= dry_rate x delta`, maior ao sol e perto de fogo; evaporar consome calor.
- **Ideia:** a poça ao sol some; no frio dura e congela.

### 86 Congelamento [P2]
- **Regra:** a água expande ao virar gelo; o gelo boia.
- **Fórmula:** `V_gelo/V_água = ρ_água/ρ_gelo` = 999,8/916,2 = 1,091 (+9,1%) ([ToolBox](https://www.engineeringtoolbox.com/ice-thermal-properties-d_576.html)). Fusão: 334 kJ/kg (ver `contexto-fisico.md`).
- **Valores:** pressão de ruptura de recipientes: não encontrado.
- **Para o Ygg:** `água -> gelo` em recipiente fechado ganha +9% de volume; se o vaso é frágil, trinca (liga ao nº 38). Gelo boia.
- **Ideia:** congelar a água da fenda para rachar a rocha, ou o odre.

### 87 Atrito no gelo e aquaplanagem [P1]
- **Regra:** o gelo perto de 0 °C é mais escorregadio que o gelo frio; óleo e água formam película.
- **Fórmula:** `a = μ g` (a massa se cancela). Aquaplanagem de carro: `Vp (mph) = 10,35 √p (psi)`, aproximação grosseira ([Wikipedia](https://en.wikipedia.org/wiki/Aquaplaning), aberta e confere; `[fonte fraca]` por ser enciclopédia); 35 psi: 61 mph.
- **Valores** ([ToolBox](https://www.engineeringtoolbox.com/friction-coefficients-d_778.html), μ estático/cinético): gelo/gelo 0 °C 0,1/0,02; -12 °C 0,3/0,035; -80 °C 0,5/0,09; gelo/aço 0,03; aço/aço com óleo mineral leve 0,23; óleo de rícino 0,15/0,081.
- **Para o Ygg:** `friction` por mancha (a Godot tem um só atrito e usa o menor do par, ver `contexto-fisico.md`). Gelo e óleo ~0,03-0,1; gelo muito frio segura mais.
- **Ideia:** aquecer o gelo perto de 0 °C o torna perigoso; esfriá-lo o torna andável.

---

## Pendentes e limites (atualizado na 2ª passada)

- Todos os itens do meu recorte (67, 70, 72 a 87) têm ficha. Fora do meu recorte: 68, 69, 71.
- Abertos e conferidos na 2ª passada: Bernoulli, continuidade, Pascal, evaporação, capilaridade, difusão, densidade do ar, viscosidade (ToolBox e LibreTexts), Wikipedia de BLEVE, areia movediça, Stokes, Torricelli, ondas rasas e aquaplanagem. As Wikipedias seguem `[fonte fraca]`.
- Divergências achadas: azeite 100 mPa·s (ToolBox) contra 10 mPa·s (LibreTexts); exemplo de capilaridade da ToolBox usa diâmetro no lugar do raio (7,4 mm contra 14,8 mm); evaporação 0,168 kg/h/m² (antes 0,16); "10⁶" da areia movediça não consta na Wikipedia.
- Ainda `[memória, a confirmar]`: `F = Δp x A` (74); flutuação não vem pronta na Jolt (76).
- Ainda `[fonte fraca]` e não abertas: EPFL e Wikipedia "Deflagration" (67).
- Ainda não encontrado: razão numérica da fase negativa (tentei Wikipedia "Blast wave", Dlubal, Sielicki 2015 e um review do DRDO, que não abriu; Kinney e Graham, *Explosive Shocks in Air*, e Needham, *Blast Waves*, são os livros que a literatura cita); limites de inflamabilidade; viscosidade medida da areia movediça; C_d humano; retenção de água em materiais; pressão de ruptura de vasos e de recipientes que congelam.
- Fatores de transmissão de paredes e tetos de confinamento são valores de jogo, a calibrar no teste.

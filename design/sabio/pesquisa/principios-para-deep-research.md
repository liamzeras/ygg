# Princípios científicos para o Deep Research

> Criado em 2026-11-01 pelo Sábio. Copie o prompt abaixo e **um bloco por vez** para o Gemini: pedir os
> 140 de uma só vez tende a render respostas rasas. As respostas voltam para `design/sabio/pesquisa/`.
> Prioridade: **P1** afeta sistemas que já existem · **P2** próximos sistemas · **P3** mundo aberto e futuro.

## Prompt (colar antes de cada bloco)

```text
Você vai pesquisar princípios científicos reais para orientar o design de um jogo.

O JOGO: Ygg é um RPG de mundo aberto em primeira pessoa para PC, feito na Godot 4 com física Jolt, a
60 quadros por segundo, com orçamento de estúdio independente. Tudo no mundo é um material com
propriedades, e magias e habilidades são forças e estados aplicados à física. Pilares: (1) crível antes
de espetacular; (2) quanto mais surreal, mais limitado; (3) criatividade vale mais que números; (4) o
jogador precisa entender por que algo aconteceu. Um personagem no auge chega a cerca de 8 vezes um
humano comum em qualquer atributo. Já existem: massa por volume x densidade, calor acumulado até a
ignição, fogo que se espalha, explosões com queda por distância, impacto = massa x velocidade, lama,
pedra, madeira, metal e pólvora. A física do jogo pode mentir, desde que seja consistente.

PARA CADA PRINCÍPIO DO BLOCO, entregue:
1. Como funciona na realidade, em linguagem simples.
2. A fórmula principal, com variáveis, unidades e um exemplo calculado.
3. Valores reais em tabela para materiais ou seres relevantes, com faixas e unidades SI.
4. Intuição do jogador: o que uma pessoa comum espera que aconteça, e onde essa intuição está errada.
5. Versão simplificada para o jogo: modelo barato para rodar a 60 fps, com o que manter e o que descartar.
6. Três ideias de mecânica emergente, combinando este princípio com outros sistemas.
7. Precedentes: jogos que usaram o princípio, com o que funcionou e o que falhou.
8. Fontes com link. Prefira manuais técnicos, artigos revisados e palestras de desenvolvedores.

REGRAS:
- Não invente números. Sem fonte, escreva "não encontrado".
- Separe fato científico, de um lado, de sugestão de design, de outro.
- Mostre quando as fontes divergirem.
- Evite instruções práticas de fabricação de explosivos, venenos ou armas reais: interessam só os
  efeitos observáveis e os modelos simplificados.
- Responda em português do Brasil, em Markdown, seguindo a numeração original.
- Termine com uma tabela: princípio | variáveis para o jogo | valor sugerido | custo de implementar
  (baixo, médio ou alto) | impacto no jogo (baixo, médio ou alto).
```

## Bloco 1: Mecânica e movimento

1. **P1** Leis de Newton: base de empurrões, arremessos e colisões.
2. **P1** Conservação do momento linear: define quem voa e quem mal se mexe após um impacto.
3. **P1** Impulso e tempo de contato: por que um golpe seco difere de um empurrão longo.
4. **P1** Energia cinética (½mv²) versus momento (mv): qual dos dois deve decidir o dano.
5. **P1** Coeficiente de restituição: quanto cada material quica.
6. **P1** Atrito estático e dinâmico: deslizar, frear e escorregar em gelo, óleo e lama.
7. **P2** Atrito de rolamento: barris, pedras redondas e carrinhos.
8. **P1** Centro de massa e tombamento: pilhas, torres e quedas de objetos.
9. **P2** Torque e momento de inércia: giro de objetos e de armas longas.
10. **P2** Conservação do momento angular: rotação no ar e objetos arremessados.
11. **P2** Alavancas, polias e vantagem mecânica: soluções criativas sem força bruta.
12. **P2** Trabalho e potência: esforço para erguer, carregar e correr.
13. **P1** Balística com gravidade: arco de projéteis e flechas.
14. **P1** Arrasto e velocidade terminal: queda, projéteis leves e pesados.
15. **P3** Efeito Magnus: curva de projéteis giratórios.
16. **P2** Pressão como força por área: por que a ponta perfura e o martelo amassa.
17. **P1** Lei do quadrado-cubo: por que escala muda força, peso e fragilidade.

## Bloco 2: Corpo e limites humanos

18. **P1** Limites humanos de salto, sprint, levantamento e arremesso: régua do "1x".
19. **P1** Força muscular por área de seção: como escalar um atributo até 8x de forma crível.
20. **P1** Tolerância do corpo à aceleração e à queda: dano de impacto e de queda.
21. **P2** Biomecânica do golpe e do arremesso: cadeia cinética, massa da arma e velocidade.
22. **P2** Centro de gravidade e equilíbrio humano: empurrões, atordoamento e carga.
23. **P2** Custo energético de correr e carregar peso: base do Vigor.
24. **P2** Metabolismo energético e ATP: fadiga rápida versus resistência.
25. **P2** Ácido lático e recuperação muscular: curvas de cansaço e descanso.
26. **P2** Lesões por impacto, corte e perfuração: tipos de dano que fazem sentido.
27. **P3** Tempo de reação humano e percepção: limite de esquiva e bloqueio.

## Bloco 3: Materiais e resistência

28. **P1** Lei de Hooke e elasticidade: deformar e voltar.
29. **P1** Tensão, deformação e limite de escoamento: quando algo cede.
30. **P1** Fratura frágil versus dúctil: vidro estilhaça, cobre entorta.
31. **P1** Tenacidade: quanta energia um material absorve antes de quebrar.
32. **P2** Dureza e escala de Mohs: o que risca, corta ou lasca o quê.
33. **P1** Densidades reais: referência para as densidades "de jogo".
34. **P2** Fadiga de materiais: desgaste de equipamentos por uso.
35. **P2** Anisotropia da madeira: rachar a favor do veio versus contra.
36. **P2** Flambagem e resistência de vigas: pilares, pontes e estruturas improvisadas.
37. **P2** Compósitos e armaduras em camadas: couro, malha, placa.
38. **P2** Propagação de trincas: quebra em pedaços, em vez de sumir.
39. **P2** Corte, perfuração e impacto contra armaduras: física das armas contra proteção.
40. **P3** Fibras e cordas: tração, nós e rompimento.
41. **P2** Vidro e cerâmica: fragilidade e estilhaços.

## Bloco 4: Calor e mudança de fase

42. **P1** Leis da termodinâmica: conservação de energia e sentido do calor.
43. **P1** Calor específico: por que alguns materiais esquentam mais rápido.
44. **P1** Condução de calor (Fourier): metal transmite, madeira isola.
45. **P1** Lei de resfriamento de Newton: base do `heat_decay` do jogo.
46. **P2** Convecção: fumaça e ar quente sobem.
47. **P1** Radiação térmica (Stefan-Boltzmann): calor a distância de uma fogueira.
48. **P1** Calor latente: água e gelo seguram a temperatura ao mudar de estado.
49. **P2** Pontos de fusão e ebulição dos materiais do jogo.
50. **P2** Dilatação térmica: travar, rachar e soltar peças.
51. **P2** Choque térmico: rocha ou metal quente que racha com água fria.
52. **P2** Vapor e expansão da água: pressão, queimadura e neblina.
53. **P3** Sublimação e geada: gelo sem líquido, clima frio.
54. **P2** Isolamento térmico: roupas, neve e abrigos.

## Bloco 5: Fogo e combustão

55. **P1** Triângulo do fogo: combustível, calor e oxigênio, e as formas de apagar.
56. **P1** Pontos de fulgor e de autoignição: como definir `ignition_heat` por material.
57. **P1** Pirólise: por que a madeira libera gás e depois vira carvão.
58. **P1** Velocidade de propagação do fogo: direção, inclinação e vento.
59. **P1** Razão área/volume: gravetos pegam fogo antes de toras.
60. **P2** Combustão lenta (brasas): objetos que parecem apagados e reacendem.
61. **P2** Falta de oxigênio e reignição súbita: ambientes fechados.
62. **P1** Óleo em chamas e água: por que água pode espalhar o fogo.
63. **P2** Explosão de poeira: farinha, serragem e minas.
64. **P2** Fumaça: visibilidade, asfixia e movimento.
65. **P2** Agentes de extinção: água, areia, lama e abafamento.
66. **P3** Incêndios florestais e aceiros: fogo em escala de mundo aberto.

## Bloco 6: Explosões, pressão e gases

67. **P1** Deflagração versus detonação: pólvora empurra, explosivo forte estilhaça.
68. **P1** Onda de choque e curva de Friedlander: pressão e impulso no tempo.
69. **P1** Escala de Hopkinson-Cranz: raio e força conforme a carga, para calibrar `explosion_*`.
70. **P1** Efeitos de parede e confinamento: explosão em corredor versus campo aberto.
71. **P2** Fragmentação e estilhaços: dano além da onda de choque.
72. **P2** Ruptura de vasos pressurizados (BLEVE): barris e caldeiras.
73. **P2** Lei dos gases ideais: pressão, volume e temperatura em recipientes.
74. **P2** Pressão atmosférica e vácuo: sucção e selamento.
75. **P3** Vazamento e difusão de gases: nuvens tóxicas ou inflamáveis.

## Bloco 7: Água e outros fluidos

76. **P1** Empuxo (Arquimedes): o que boia e o que afunda.
77. **P1** Viscosidade: água, óleo, mel e lava.
78. **P1** Fluidos não newtonianos: lama e areia movediça.
79. **P2** Princípio de Pascal: mecanismos hidráulicos.
80. **P2** Equação da continuidade e Bernoulli: correntezas e estreitamentos.
81. **P2** Pressão hidrostática: profundidade, represas e portas submersas.
82. **P1** Tensão superficial e molhamento: poças, gotas e superfícies molhadas.
83. **P2** Capilaridade e absorção: pano, madeira e solo molhados.
84. **P3** Ondas e arrasto na água: nadar, barcos e impactos.
85. **P2** Evaporação e secagem: quanto tempo algo fica molhado.
86. **P2** Congelamento: gelo menos denso que a água e rachaduras por expansão.
87. **P1** Atrito no gelo e aquaplanagem: por que ele escorrega tanto.

## Bloco 8: Química prática

88. **P1** Oxidação e redução: base do fogo e da ferrugem.
89. **P2** Corrosão e ferrugem: desgaste de metais com água e sal.
90. **P2** Corrosão galvânica: metais diferentes em contato.
91. **P2** Ácidos e bases: dissolver, neutralizar e queimar.
92. **P2** Lei de Arrhenius: calor acelera reações.
93. **P2** Reações exotérmicas e endotérmicas: cal virgem, compressas e fontes de calor.
94. **P2** Catalisadores: pouca substância, grande efeito, inspiração para reagentes.
95. **P2** Solubilidade e diluição: venenos, sais e água contaminada.
96. **P3** Princípio de Le Chatelier: equilíbrios que reagem a mudanças.
97. **P3** Polimerização e resinas: colas, breu e substâncias que endurecem.
98. **P3** Saponificação e gorduras: da gordura de monstro ao sabão.
99. **P3** Cimento e cal: materiais que endurecem com água.

## Bloco 9: Eletricidade, magnetismo e metais

100. **P2** Lei de Ohm: tensão, corrente e resistência.
101. **P2** Condutividade de metais, água doce, água salgada e corpo humano.
102. **P2** Efeito Joule: corrente gera calor e pode acender coisas.
103. **P2** Ruptura dielétrica e raios: como a eletricidade escolhe o caminho.
104. **P2** Choque elétrico no corpo: contrações e paralisia, em termos de jogo.
105. **P3** Gaiola de Faraday: proteção por metal.
106. **P3** Ferromagnetismo e indução: atrair metais e gerar corrente.
107. **P3** Eletrólise: água, gases e reações.
108. **P2** Ligas metálicas: bronze, ferro e aço, com seus pontos fortes.
109. **P2** Têmpera, revenimento e encruamento: qualidade de armas e armaduras.

## Bloco 10: Geologia e terreno

110. **P1** Tipos de solo e capacidade de carga: firme, areia, argila e lama.
111. **P1** Ângulo de repouso: pilhas de areia e cascalho que escorrem.
112. **P2** Deslizamentos e avalanches: o que os dispara e como se movem.
113. **P2** Liquefação do solo: o chão que vira líquido.
114. **P2** Ciclo das rochas e propriedades de cada tipo: ígneas, sedimentares e metamórficas.
115. **P2** Erosão e sedimentação: como água e vento desenham o terreno.
116. **P3** Formação de cavernas (carste): espaços subterrâneos críveis.
117. **P3** Vulcanismo: lava, gases, cinzas e obsidiana.
118. **P3** Falhas e terremotos: propagação e efeito em estruturas.
119. **P3** Formação de minérios: onde encontrar cada metal, de forma crível.
120. **P3** Lençol freático e fontes: onde há água no mundo.

## Bloco 11: Biologia, bioquímica e monstros

121. **P2** Lei de Kleiber e alometria: metabolismo, força e fôlego por tamanho.
122. **P2** Limites do exoesqueleto e respiração de insetos: quão grande uma aranha pode ser, e a mentira aceitável.
123. **P2** Seda de aranha: resistência, adesão, inflamabilidade e sensibilidade à água, base da Teia.
124. **P2** Dose-resposta e DL50: curva de efeito dos venenos, por massa do alvo.
125. **P2** Neurotoxinas versus hemotoxinas: sintomas distintos que viram estados de jogo.
126. **P2** Termorregulação: hipotermia, insolação, animais de sangue frio e de sangue quente.
127. **P2** Gorduras e óleos animais: combustível e reagente vindo de drops.
128. **P2** Queimaduras e cicatrização: gravidade, tempo e recuperação.
129. **P2** Hemorragia e coagulação: perda contínua de vida.
130. **P3** Fermentação e decomposição: comida, álcool, gases e cadáveres no mundo.
131. **P3** Bioluminescência e sentidos animais: como criaturas detectam o jogador.

## Bloco 12: Atmosfera, som, luz e simulação

132. **P2** Formação de vento e gradiente de pressão: fogo, projéteis e fumaça.
133. **P3** Ciclo da água e formação de chuva: clima sistêmico.
134. **P2** Velocidade do som e atenuação: furtividade e leitura de explosões.
135. **P3** Incandescência e cor do calor: metal e fogo que mostram a temperatura.
136. **P3** Reflexão e refração da luz: água, gelo, espelhos e lentes.
137. **P1** Passo fixo e estabilidade numérica: limites de simulações a 60 fps.
138. **P1** Tunelamento e detecção contínua de colisão: projéteis rápidos atravessando objetos.
139. **P1** Autômatos celulares e campos em grade: fogo, gás e água de forma barata.
140. **P1** Nível de detalhe na simulação: o que deixa de ser simulado longe do jogador.

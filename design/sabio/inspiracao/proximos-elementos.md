# Próximos elementos: Água, Ar, Natureza e Eletricidade

> Sábio, 2026-11-17. Proposta, não decisão. Segue o formato da fatia ([mage-fire.md](../../gdd/mage-fire.md))
> e as tabelas rascunho de [magos-elementais.md](magos-elementais.md). As maestrias seguem os 7 critérios de
> [maestrias.md](maestrias.md). Só o Liam decide; GDD e código são de outras frentes.
>
> **Marcas:** `[memória, a confirmar]` = fato físico sem fonte conferida. `[fonte fraca]` = fonte de
> wiki ou fã. Nenhuma fonte externa nova foi pesquisada: tudo que é física aqui é conhecimento comum e leva a
> marca. O que é do Ygg vem de arquivos do projeto.

## Conclusão

1. **Água** está ~40% pronta: poça, molhado, frio e gelo existem como módulos do laboratório. Falta o que é
   "do mago": a Maré inteira (onda, jato, bolha) e o gelo como construção.
2. **Os verbos de movimento do rascunho esbarram** em 3 pontos (seção "Verbos"). Proponho 3 trocas pequenas.
3. **Eletricidade só funciona com uma regra do mundo nova**: o campo `conductive` (reservado) precisa
   ser ligado, e "molhado conduz" precisa existir para personagens. Sem isso, a lei é só texto.
4. **A lente de design** (a skill game-design-philosophy: sistemas que conversam, "o relacionamento é o jogo")
   favorece o que está abaixo: cada elemento deixa um rastro que outro usa, sempre com custo para quem deixou.

## Leis do mundo que já existem e que os 4 elementos usam

Fonte: [physics-magic-system.md](../../gdd/physics-magic-system.md).

- **Calor com dono:** quem conjura não se queima com o que criou. **Regra para os novos:** o dono da poça não se
  eletrocuta com a própria poça? Proposta: **não vale** para Eletricidade (ver pilar 2): o dono que ficar
  na poça que ele eletrificou leva. Isso é o "custo físico" dela. Decisão do Liam (Proposta 4).
- **Quebrável em estágios** (3 rachaduras, `take_hit`, `shatter`): gelo e madeira viva entram nessa regra.
- **Cenário volta em 30 s:** vale para o que o mago constrói? Proposta: construção de mago tem duração própria
  e não volta; só o cenário original volta.
- **Concreto** e **gravidade só em objetos e monstros:** o mago não é puxado por Peso inimigo a não ser que
  a classe diga. Eletricidade e Ar seguem o mesmo cuidado: ver cada elemento.

---

## 1. Água (próxima da fila)

**Lei:** a água escorre para baixo, ocupa o desnível, **molha**, e muda de estado com o calor (gelo, líquido, vapor).
Molhado: demora a pegar fogo e conduz eletricidade. (Já é regra do Ygg: módulo 1 do laboratório.) Vapor é
água + calor `[memória, a confirmar: ponto de ebulição e calor latente não entram; só o efeito visual de vapor]`.

**Eixo:** temperatura. **Gelo** (sólido: massa, dureza, escorrega) ↔ **Maré** (líquido: pressão, fluxo, empurra).

| Função | Gelo | Maré | Reaproveita |
|---|---|---|---|
| Movimento | **Trilho de gelo:** cria uma pista que acelera quem desliza | **Onda:** uma onda sob os pés carrega você pelo chão molhado | Gelo: `lab_ice` (atrito 0,02). Maré: poça (`lab_puddle`) |
| Ataque | **Lança de gelo:** projétil pesado que perfura e racha | **Jato d'água:** empurra e deixa o alvo Molhado | Lança: `materialized_projectile` + `take_hit`. Jato: `apply_air`-like (empurrão) + `lab_wet_status` |
| Defesa | **Parede de gelo:** bloqueia, racha em 3 estágios, derrete com fogo | **Bolha d'água:** freia projéteis e apaga fogo que passa | Parede: quebrável em estágios + `prop.cool`. Bolha: lógica da Almôndega ao contrário |
| Terreno | **Congelar o chão:** poça vira gelo, escorrega | **Alagar:** poça grande que molha; com terra vira lama | `frost_module._freeze`, `water_module`, `mud_fire_module` |

### O que do laboratório vira habilidade quase direto e o que falta

| Peça | Estado hoje | Falta | Custo |
|---|---|---|---|
| Alagar (terreno Maré) | `water_module`: poça sob a mira, Molhado em objetos | Número de uso, Mana, recarga, dono; poça virar lama com Terra | **Baixo** |
| Congelar o chão (terreno Gelo) | `frost_module`: poça vira gelo, calor retirado | Mesmas coisas + gelo derrete virando poça (hoje "some") | **Baixo** |
| Molhado em personagem | Só objetos; "jogador e boneco não ficam Molhados" | Status em `player.gd` e nos monstros (frente dona) | **Médio** |
| Escorregar no gelo (jogador) | Gelo só afeta objetos | Atrito variável no jogador (`player.gd`) | **Médio** |
| Jato d'água (ataque Maré) | Não existe | Projétil contínuo + empurrão + Molhado | **Médio** |
| Lança de gelo (ataque Gelo) | Não existe | Projétil pesado que causa dano de massa e gruda | **Médio** |
| Parede de gelo / Bolha | Não existe | Construção quebrável com estágios; bolha com filtro de projétil | **Médio** |
| Trilho de gelo / Onda (movimento) | Não existe | Movimento guiado no chão, mexe no controle do jogador | **Alto** |

### Maestrias da Água

#### Gelo → **Congelamento profundo**
- **Regra (extremo físico do Gelo):** tudo que o mago de gelo congela fica **cristal**: não se mexe, mas
  **qualquer pancada o quebra em pedaços que cortam** `[memória, a confirmar: gelo é duro e frágil]`. Quem tomou
  Lança, Parede, trilho e chão congelado vira "alvo de impacto".
- **Junta as 4:** a Lança congela no impacto, a Parede e o chão são cristal, o trilho congela o que toca.
- **Custo físico:** o cristal pesa e **conduz o calor para fora**: o mago perde Vigor perto de muito gelo? Proposta
  mais simples: o gelo derrete com fogo e solta poça, e a poça molha **você** também.
- **Sinal:** cristal azul com brilho + som de vidro trincando; estilhaço visível ao quebrar.
- **Teste:** congelar o boneco e acertar uma caixa: quebra em 3 estágios; fogo derrete e vira poça.
- **Controle (critério 6):** monstro congelado fica parado por mais tempo; **jogador** só é "travado" por
  1 s (pilar de duração menor contra jogadores).

#### Maré → **Maré viva**
- **Regra:** todo líquido que você deixa (poças, bolha, jato) **flui pela inclinação** e **se junta**. Poças
  próximas se fundem numa só, maior e mais funda. Você pode **puxar a água** de volta para o mago.
- **Junta as 4:** a onda precisa de poça; o jato a deixa; a bolha a junta; o alagar a espalha.
- **Custo físico:** água fundida **conduz** para qualquer raio e atrai fogo para o vapor: o mago de
  eletricidade vira ameaça maior. O dono molhado também conduz.
- **Sinal:** ondas visíveis entre as poças, som de água.
- **Teste:** duas poças perto fundem em uma; a Onda anda mais longe nela.

**Verbo de movimento:** surfar (Maré) e deslizar (Gelo). Único: Terra "elevador/túnel", Fogo "propulsão".

---

## 2. Ar

**Lei:** pressão. Empurra sem tocar, carrega o leve (fumaça, vapor, esporos, faíscas) e **alimenta o fogo**. Não tem
massa própria. A onda de choque precisa de ar para viajar `[memória, a confirmar]`.

**Eixo:** **Vento** (fluxo) ↔ **Vácuo** (pressão parada: comprimir ou tirar o ar).

| Função | Vento | Vácuo | Reaproveita |
|---|---|---|---|
| Movimento | **Planar:** sobe em correntes, e o calor cria corrente para cima | **Sucção:** abre um bolsão à frente e é puxado para ele (arrancada curta, horizontal) | `apply_air` + calor (`HeatZone`) |
| Ataque | **Rajada em cone:** empurra tudo e espalha o leve | **Bolha comprimida:** estoura em concussão | Dardo Cinético (estoura), `apply_air` |
| Defesa | **Redemoinho:** desvia projéteis leves | **Bolha sem ar:** apaga fogo e corta a onda de explosão | Almôndega (filtro de projétil); lama como "zona sem ar" |
| Terreno | **Vento constante** numa área | **Bolsão sem ar** onde fogo não acende | `HeatZone` e a regra "lama sem ar" |

**Reaproveita muito:** o código já tem `apply_air` em `PhysicsProp` e "zona sem ar" (lama). O Ar é o elemento que
**mais conversa com o que existe**. Custo geral: **médio**.

### Maestrias do Ar

#### Vento → **Tempestade**
- **Regra:** o vento que você cria **fica**: a rajada e o redemoinho deixam uma **corrente** que dura alguns
  segundos e carrega tudo que for leve (fumaça, esporos, faíscas) e **qualquer projétil mágico lento**, inclusive
  o seu e o do inimigo.
- **Junta as 4:** planar usa a corrente, a rajada a cria, o redemoinho a gira, o vento fixo a prende.
- **Custo físico:** a corrente leva **tudo o que é leve**, inclusive o fogo do seu aliado para o seu lado.
- **Sinal:** partículas de poeira e folhas girando; assobio.
- **Teste:** Bola de Fogo do bot entra na corrente e **curva**; fumaça segue a corrente.

#### Vácuo → **Silêncio**
- **Regra:** nos bolsões sem ar **nada acende, nada explode e nada soa**; o fogo e a eletricidade
  (que precisam de ar para ionizar `[memória, a confirmar]`) **se enfraquecem**. Vira zona de "magia
  desligada" curta.
- **Junta as 4:** sucção, bolha comprimida, bolha sem ar e bolsão alimentam a mesma zona.
- **Custo físico:** **você também** não respira lá: gasta Vigor como fôlego; e a bolsão **suga** objetos leves
  para dentro (fica bagunça).
- **Sinal:** distorção do ar e **silêncio total do som dentro** (o sinal é o áudio sumindo).
- **Teste:** Bola de Fogo dentro do bolsão não explode; barril não acende.
- **Pilar 2:** não anula magia por completo: só fogo, explosão e raio. Água e Terra funcionam.

**Verbo de movimento:** planar (Vento), sucção (Vácuo). **Atenção:** o rascunho tinha "super salto" e colidia com o
"trampolim" da Natureza. Troquei por sucção horizontal.

---

## 3. Natureza

**Lei:** crescimento leva tempo e precisa de solo. Água acelera, fogo destrói. Tudo que cresce é madeira e pega
fogo. Apodrecer solta gás `[memória, a confirmar: metano de matéria orgânica em pântano]`.

**Eixo:** **Crescimento** (raiz, cipó, árvore) ↔ **Podridão** (fungo, esporo, apodrecer).

| Função | Crescimento | Podridão | Reaproveita |
|---|---|---|---|
| Movimento | **Cipó pêndulo:** prende em árvore ou teto e balança | **Cogumelo trampolim:** cresce e lança para cima | Teia (`lab_web`), cogumelo = quebrável + empurrão |
| Ataque | **Espinhos / sementes** como projétil | **Nuvem de esporos:** veneno ao longo do tempo, levada pelo vento | `materialized_projectile`; veneno = calor ao longo do tempo (dano) |
| Defesa | **Muro de raízes:** bloqueia, mas queima | **Apodrecer a madeira inimiga:** estruturas e armas de madeira racham sozinhas | Quebrável em estágios (`add_damage`) |
| Terreno | **Mato e árvores:** cobertura | **Pântano:** solta gás inflamável | `lab_oil` (gás/óleo inflamável), `lab_arsonist` |

**Reaproveita:** a **Teia** do laboratório vira o cipó. O **Óleo** vira o gás do pântano (mesma regra: líquido ou
gás inflamável perto de fogo). Custo: **médio**.

### Maestrias da Natureza

#### Crescimento → **Floresta viva**
- **Regra:** o que você planta **cresce com o tempo** (cada estágio fica maior e mais forte) e **se liga às raízes
  vizinhas**: o mato vira muro, o muro vira árvore; **a água acelera**.
- **Junta as 4:** o cipó prende na árvore, os espinhos nascem dela, o muro cresce e o mato é o começo.
- **Custo físico:** tudo é **madeira**: um incêndio queima a floresta inteira; o fogo corre pelas raízes ligadas.
- **Sinal:** brotos que crescem visivelmente; folhas balançando; som de madeira rangendo.
- **Teste:** plantar uma semente; 10 s depois é uma árvore. Fogo queima a cadeia.

#### Podridão → **Decomposição**
- **Regra:** o que apodrece **perde dureza com o tempo** e **solta gás e esporos**: madeira, comida, construção
  rachando sozinha. Vítimas **contagiam** o vizinho de material orgânico.
- **Junta as 4:** o cogumelo é onde ela começa, os esporos são o gás, apodrecer a madeira é o efeito e o
  pântano é o chão.
- **Custo físico:** o gás é **inflamável**: o próprio mago de Podridão fica exposto a uma faísca. Dono molhado
  apodrece mais devagar `[memória, a confirmar: umidade acelera fungo]`.
- **Sinal:** madeira escurece, esporos visíveis, cheiro verde (cor e fumaça verde).
- **Teste:** uma caixa de madeira apodrece em 3 estágios sozinha; um raio no pântano o faz explodir.
- **Controle:** esporos "enfraquecem" mais que prendem: nada de atordoar jogador.

**Verbo de movimento:** balançar (Crescimento), trampolim (Podridão).

---

## 4. Eletricidade (o mais surreal: ver limites)

**Lei:** a corrente segue o condutor (metal, água, o que está molhado) até o chão. Instantânea, mas só onde
existe caminho. No ar seco o alcance é curto. O campo `conductive` dos materiais existe, mas **está reservado
e sem uso** ([physics-magic-system.md](../../gdd/physics-magic-system.md), linha 36).

**Eixo:** **Descarga** (corrente: dano, choque, cadeia) ↔ **Magnetismo** (campo: atrair e repelir metal).

| Função | Descarga | Magnetismo | Reaproveita |
|---|---|---|---|
| Movimento | **Salto relâmpago:** salta até o condutor mais próximo | **Repulsão:** placa de metal que empurra você para o lado (quique) | `conductive`, `get_weight` |
| Ataque | **Raio em cadeia** entre condutores | **Arremesso de metal** em alta velocidade | Telecinese (arremesso) |
| Defesa | **Para-raios:** estaca que atrai as descargas | **Campo magnético** que desvia projéteis de metal | Almôndega (filtro) |
| Terreno | **Eletrificar** poça ou metal (área perigosa) | **Magnetizar metal** para montar cobertura | `lab_puddle` (+ Molhado) |

**Atenção:** o rascunho dava "gancho magnético" ao Magnetismo, mas o "gancho" é verbo da Natureza (cipó). Troquei
por **repulsão** (empurra) e deixei puxar só no ataque. Custo geral: **alto** (precisa de regras novas).

### Limites do pilar 2 (Eletricidade)
- **Só com condutor:** sem poça, metal ou molhado por perto, o raio **cai para um estalo curto**: nada de raio
  no vazio. Isso é o custo físico e o que a torna legível (pilar 4).
- **Dono também conduz:** estar molhado no meio da própria poça elétrica machuca você (exceção à regra do calor
  com dono; decisão do Liam).
- **Alcance e cadeia curtos:** a cadeia tem **no máximo N saltos** e perde força a cada um.
- **Sem ver, sem conhecer:** monstros de metal conduzem, monstros de madeira isolam.

### Maestrias da Eletricidade

#### Descarga → **Tempestade de arcos** (ou "Circuito")
- **Regra:** tudo que você eletrifica **vira um nó de uma rede**: raio, poça, estaca e salto passam a **ligar
  os nós automaticamente** e a descarga corre pela rede inteira, sem precisar mirar.
- **Junta as 4:** o salto cria nós, o raio os liga, o para-raios atrai, o terreno eletrificado é o chão.
- **Custo físico:** a rede **não escolhe lado**: se você está dentro dela (molhado, em metal), você é atingido.
- **Sinal:** arcos azuis visíveis entre nós, estalo; os nós brilham 0,2 s antes da descarga.
- **Teste:** 3 poças ligadas + um boneco no meio: um raio no primeiro as atinge todas.

#### Magnetismo → **Campo magnético**
- **Regra:** todo metal perto de você **orbita ou gruda** conforme o campo que você escolhe (atrair/repelir):
  armaduras, armas e projéteis de metal do **inimigo** também.
- **Junta as 4:** a repulsão cria o campo, o arremesso lança o metal, o campo desvia, o metal magnetizado
  vira cobertura.
- **Custo físico:** o campo **também puxa o seu metal** (se você usa), e arrasta seu aliado de armadura.
- **Sinal:** limalha ou faíscas em linhas de campo; zumbido grave.
- **Teste:** 5 projéteis de metal disparados: desviam; caixas de ferro grudam no campo.

**Verbo de movimento:** salto relâmpago (Descarga), repulsão (Magnetismo).

---

## Verbos de movimento: conferência contra os outros 6

| Fogo | Água | Terra | Ar | Natureza | Eletricidade | Gravidade |
|---|---|---|---|---|---|---|
| Propulsão / trilha | Surfar / deslizar | Elevador / túnel | Planar / **sucção** | Balançar / trampolim | Salto a condutor / **repulsão** | Flutuar / meteoro |

Choques que o rascunho tinha (e a troca):

1. **Ar "super salto" × Natureza "trampolim":** os dois lançam para cima. Ar passa a ser **sucção horizontal**.
2. **Natureza "gancho" × Eletricidade "gancho magnético":** mesmo verbo de puxar. Natureza fica com **balançar**
   (pêndulo); Eletricidade vira **repulsão**.
3. **Ar "planar" × Gravidade "flutuar":** não colidem. Planar depende de vento/calor e é barato; flutuar
   é controle total e caro (já decidido em magos-elementais.md).
4. **Água "surfar" × Fogo "trilha":** diferentes (um depende de poça, o outro cria rastro de calor).

## Ganchos com Fogo, Terra e Gravidade (sempre com dois lados)

| Rastro de um | Gancho do outro | O que acontece | O outro lado |
|---|---|---|---|
| Água: poça / molhado | Fogo | Apaga; vira vapor | O vapor tira a visão de **quem usa água** também |
| Fogo: calor | Água: Gelo | Derrete a parede e vira poça | Vira poça: **conduz** para o raio |
| Água + Terra | Lama | Atola e apaga o fogo | O mago de Terra perde o tempo do terreno seco |
| Gravidade: Peso | Água: Gelo | O peso quebra o gelo | O gelo quebrado vira estilhaço que **volta** contra quem usou Peso |
| Ar: vento | Fogo | Alimenta e espalha | O fogo voltado contra o aliado |
| Fogo: calor | Ar | Corrente que faz planar | O mago de Ar fica exposto ao fogo que o ergue |
| Ar: vácuo | Fogo e Eletricidade | Apaga/enfraquece | Vácuo sufoca **você** também |
| Gravidade: leveza | Ar | Objetos leves viram "folhas" para o vento | Leva também seu próprio projétil |
| Natureza: pântano | Fogo | O gás explode | O mago de Natureza perde o terreno |
| Natureza: madeira | Fogo | Muro queima | Quem acende se expõe ao incêndio |
| Natureza: raízes | Terra | Raiz racha pedra; pedra prende raiz | Terra seca a planta |
| Natureza | Gravidade: Peso | Árvore pesada cai e esmaga | Esmaga também o aliado |
| Eletricidade: raio | Água: poça | Conduz | O mago de Água também conduz |
| Eletricidade: metal | Terra | Pedra metálica vira cobertura magnética | O metal exposto atrai o raio |
| Eletricidade: campo | Gravidade: Leveza | Metal flutua e orbita | Atrai também o **seu** metal |

## Riscos

- **Meta fixa:** Água > Fogo, Eletricidade > Água, Fogo > Natureza forma uma tabela. Cada linha acima tem um
  "outro lado" justamente para evitar isso (lição do Spellbreak em [magos-elementais.md](magos-elementais.md)).
- **Eletricidade:** se as regras de condução não forem claras na tela, parece "raio aleatório". Precisa de sinal
  visual forte antes do raio.
- **Natureza vs. cenário que volta em 30 s:** o que o mago planta cresce em segundos; é preciso decidir se volta ao
  original (proposta: não, duração própria).

## Propostas (resposta sim/não, em ordem de prioridade)

1. **Água é a quarta da fila e entra como "classes" com os 8 itens da tabela?** Frente: **classes**.
   Começar pelo que custa baixo (Alagar e Congelar o chão) e deixar Trilho/Onda por último.
2. **Ligar a lei "Molhado conduz" (e o `conductive`) como regra do mundo, em personagens e monstros também?**
   É o que faz Água, Eletricidade e a lama conversarem. Frente: **gameplay**.
3. **Aceitar as 3 trocas de verbo** (Ar: sucção em vez de super salto; Natureza: balançar; Eletricidade: repulsão)?
   Frente: **classes**.
4. **O dono da poça elétrica leva choque se estiver nela (exceção à regra do calor com dono)?** É o custo
   físico da Eletricidade. Frente: **gameplay**.
5. **Criar os efeitos-chave visuais** (arcos azuis, cristal de gelo, vento visível, brotos que crescem) antes de
   codificar? Frente: **arte**. Sem esses sinais, os 4 elementos não passam no critério 4.

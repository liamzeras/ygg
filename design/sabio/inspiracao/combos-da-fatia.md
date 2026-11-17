# Combos da fatia: Fogo, Terra e Gravidade

> Sábio, 2026-11-17. Auditoria dos combos que existem, dos que quase existem e dos rastros entre os três magos.
> É pesquisa e proposta, não GDD. Nada aqui muda regra até o Liam aprovar.
>
> **Como li:** só o código e os `.tres` (sem jogar). Cada afirmação traz `arquivo:linha`. Quando "o jogador percebe"
> é só leitura dos sinais visíveis, digo que é leitura, não playtest. O que não consegui confirmar vem marcado
> **[não verificado]**.
>
> **Lente (skill game-design-philosophy):** a pergunta-chave de sistemas é "o que acontece quando estes dois
> sistemas se tocam? Foi planejado?". Aqui a resposta é sempre uma de três: planejado, acidente feliz ou acidente
> perigoso. A separação abaixo segue isso.

## Conclusão

1. **A base é boa:** a maior parte dos combos entre elementos já nasce da física (calor, lama, peso, quebra), sem
   código especial. Isso é o princípio "troque pilhas por grandezas" funcionando.
2. **Dois combos acidentais precisam de decisão:** o **Gravidash carrega qualquer objeto na velocidade da
   arrancada, sem olhar a massa** (um barril de pólvora carregado detona; um bloco de 605 kg vira aríete), e o
   **tiro rebatido pelo Push-Pull atravessa quem o lançou**.
3. **A Terra tem um buraco:** a **explosão não racha a Escada nem o Terremoto** (só servem de cobertura), apesar
   de o GDD dizer o contrário, e a Terra **não empilha** em cima do próprio relevo.
4. **Falta sinal:** a lava apagada pela lama continua vermelha, o Fogo-Fátuo tem quase a mesma cor azul do Dardo
   Cinético, e nada mostra que um objeto ficou "pesado" ou "quente demais".

## 0. Nota sobre o que está em cada kit

Conferido em `assets/data/classes/*.tres`:

- **Fogo** (`fire.tres`): Bola de Fogo, Fogo-Fátuo, Chão de Lava, Almôndega de Fogo, Jatos de Fogo.
- **Terra** (`earth.tres`): Soco, Chute, Escada de Pedra, Terremoto, Lamaçal.
- **Gravidade** (`gravity.tres`): Push-Pull, Mibune, Gravidade dos Sonhos, Gravidash, Zona Nula (e, dentro dela,
  socos, chutes e Agarrar).
- **Dardo Cinético, Campo Lento, Telecinese e Flutuar não estão no Mago da Gravidade.** Só estão em `psionic.tres`
  (a ficha do bot do F6). Entram aqui na seção 4 como "ferramentas guardadas", porque o `magos-elementais.md` as
  prevê para a Leveza da Gravidade.

Lembrete de valores: Mibune com puxão 15 m/s² (`gravity.tres:40`; o padrão do script é 30, `mibune_ability.gd:13`).

## 1. Combos que já existem por acidente

"Percebe?" é leitura dos sinais visíveis no código, não playtest.

### Dentro do Fogo

**F1. Voar dentro da Almôndega e atropelar com fogo.**
A bola é filha do mago (`fire_shield_ability.gd:33`) e consulta a posição dele a cada quadro
(`fire_shield.gd:60-62`). Quem o mago atravessa voando recebe calor (`fire_shield.gd:82-85`).
Percebe? Talvez. A bola dura 3 s e o voo, no nível 50, 7,6 s.

**F2. Fogo-Fátuo em pedra = pedra em brasa que acende madeira.**
O fátuo anexa uma queimadura mesmo em material que não pega fogo (`fire_wisp_projectile.gd:58`). A queimadura
entrega 20 de calor por segundo ao objeto (`burn_effect.gd:53-56`); pedra guarda calor (`physics_prop.gd:165-178`)
e acima de 50 irradia para vizinhos (`physics_prop.gd:284-289`).
Percebe? Sim para "em chamas" (aparece fogo). Para "a pedra vira brasa e acende a caixa do lado": talvez, a pedra
só fica avermelhada (`physics_prop.gd`, cor `RED_HOT`).

**F3. Chão de Lava acende o que é inflamável, inclusive barril.**
`lava_pool.gd:58-61` dá calor a tudo em cima, menos o dono. Caixa e barril acendem. Percebe? Sim, é visível.

### Dentro da Terra

**T1. Terremoto vira munição para o Soco.**
Os pedregulhos do Terremoto são `PhysicsProp` de pedra (`earthquake_zone.gd:116-126`). O Soco os trata como
objeto solto de terra e dobra o impulso (`stone_strike_ability.gd:70`, `:95-97`). Somem quando o Terremoto acaba
(`earthquake_zone.gd:72-74`). Percebe? Talvez: as pedras caem do alto do relevo, mas o jogador pode não ligar
"soca a pedra" ao Terremoto.

**T2. Escada, soco no pilar, mãos de pedra, pedregulho.**
Socar a própria escada a racha e **reveste as mãos** (`stone_strike_ability.gd:104-111`); com mãos revestidas,
socar o ar arremessa pedregulho (`:83-85`). Percebe? Sim: o HUD mostra "Pedra 6s" (`:61-63`).

### Dentro da Gravidade

**G1. Gravidash carrega tudo ao redor sem olhar a massa.**
Num raio de 2,5 m, todo objeto solto recebe `velocidade_da_arrancada x 0,8` por atribuição direta
(`gravidash_ability.gd:78-80`). A arrancada é 4 m / 0,2 s = 20 m/s, então o objeto sai a 16 m/s, seja caixa de 19 kg
ou bloco de pedra de 605 kg. Pela leitura:
- barril de pólvora carregado passa de 9 m/s e **detona ao bater** (`physics_prop.gd:609-630`);
- bloco de 605 kg a 16 m/s dá `massa x velocidade` de quase 9.700, vezes 0,1 de dano por impulso (aprox. 970 de dano)
  **[não verificado em jogo; conta feita à mão com `damage_rules.tres`]**.
Percebe? Provavelmente sim (o objeto voa junto), mas ninguém avisa que o peso não importa. É um combo
poderoso e provavelmente quebrado: ver Proposta 2.

**G2. Mibune junta os objetos num ponto.**
É uma área de gravidade do mundo (`mibune.gd:38-46`); objetos soltos caem para o centro. Efeito colateral útil:
caixas, pedregulhos e barris ficam agrupados. Percebe? Sim para "puxa"; não para "agrupa de propósito".

**G3. Mibune dentro da Gravidade dos Sonhos soma os pesos.**
As duas são áreas de gravidade em modo "somar" (`mibune.gd:42`, `dream_gravity_zone.gd:17-19`): o objeto cai mais
rápido para o Mibune. Percebe? Não. Nenhum sinal mostra o peso.

### Entre kits (já funcionam)

**X1. Lama apaga lava, fátuo e braseiro (Terra apaga Fogo).**
Lamaçal chama `extinguish_on` em tudo que toca (`mud_patch.gd:65`); a queimadura se desfaz sem ar
(`burn_effect.gd:49-52`); a lava para de aquecer sob lama (`lava_pool.gd:54`).
**Discrepância com o GDD:** `mage-fire.md:98-99` diz que a queimadura do fátuo *continua* sob a lama; o código a
**apaga**. Ou o texto ou o código está desatualizado.
Percebe? Para o alvo em chamas, sim (o fogo some). Para a lava, **não**: ela só para de aquecer e continua
vermelha e brilhante (`lava_pool.gd:54` retorna sem mudar a malha).

**X2. Almôndega para e esquenta o que vem arremessado.**
Objetos soltos a mais de 4 m/s na direção do mago são zerados e recebem 60 de calor
(`fire_shield.gd:77-81`). O pedregulho socado pela Terra vira pedra quente no chão. Percebe? Talvez.

**X3. Terremoto + lava = pedregulhos quentes.**
Lava e braseiro dão calor a qualquer `PhysicsProp` na área (`heat_zone.gd:28-29`). Pedregulho de pedra guarda.
Percebe? Talvez (a cor vermelha).

**X4. Mibune junta, fogo se espalha (Gravidade e Fogo).**
Caixas acesas ficam juntas no centro. O fogo passa por 1,4 m (`fire_spread_radius`, com limiar em 0,62 m entre
centros segundo `physics-magic-system.md`). Perto assim, acende rápido. **[não verificado em jogo]**.

**X5. Gravidash leva barril/caixa acesa (Gravidade e Fogo).** É o G1 visto do lado do Fogo.

**X6. Push-Pull rebate Bola e Fátuo (Gravidade e Fogo).**
Rebate se o impulso do Push-Pull for maior ou igual ao do projétil (`push_pull_ability.gd:70-78`). Contas com
`materialized_scale` 200: Bola de Fogo carregada 0,01 x 30 x 200 = 60; Fátuo 0,01 x 6 x 200 = 12; Dardo
0,007 x 60 x 200 = 84; Push-Pull 120 (os dois lados multiplicam por `power`, não conferi os valores finais).

**X7. Zona Nula apaga Bola, Fátuo e Dardo, e tranca o kit de todos (Gravidade e Fogo/Terra).**
`null_zone.gd:33-37` só apaga `MaterializedProjectile`. **Lava, lama, pilares, relevo, Mibune e queimadura em
andamento continuam** (coerente com o GDD: "a zona não desfaz o que já existe").

**X8. Mibune disparado racha a Escada e o Terremoto (Gravidade e Terra).**
`mibune.gd:135-137` chama `take_hit` em tudo no raio, e o pilar aceita (`stone_pillar.gd:192`).

**X9. Soco da Zona Nula não reveste.**
O soco sem magia usa o mesmo script de golpe, mas com `coat_duration = 0` (`gravity.tres:90`). Socar parede de
pedra na zona não dá mãos de pedra. Isso é proposital e funciona.

## 2. Combos que quase existem (o que falta)

| # | Combo | Falta | Onde | Tamanho |
|---|---|---|---|---|
| Q1 | Bola de Fogo ou explosão rachar a Escada e o Terremoto | `_can_be_affected` só aceita corpo rígido, estrutura, `apply_knockback`, `register_hit` ou `add_heat` (`explosion.gd:79`); o pilar só tem `take_hit` | `explosion.gd` (frente gameplay) | 1 regra |
| Q2 | Escada ou Lamaçal em cima do relevo do Terremoto | `_is_ground` só aceita `StaticBody3D` e recusa `AnimatableBody3D` (`terrain_ability.gd:45`), e o pilar é `AnimatableBody3D` | `terrain_ability.gd` (classes) | 1 regra |
| Q3 | Mibune ou Sonhos curvarem o Fogo-Fátuo | O fátuo tem `gravity_scale = 0` (`fire_wisp_projectile.gd:17`), então ignora áreas de gravidade; a Bola tem 0,2 (`fire.tres:24`) e quase não curva | `materialized_projectile.gd` + `.tres` (classes) | 1 regra |
| Q4 | Rebater o tiro **de volta ao dono** | O projétil guarda `caster` e a exceção de colisão (`fireball_ability.gd:50`, `fire_wisp_ability.gd:25`); `launch` não troca o dono (`push_pull_ability.gd:77`); a explosão exclui o dono (`fireball_projectile.gd:61-63`) | `push_pull_ability.gd` + projéteis (classes) | 1 regra + 1 sinal |
| Q5 | Pilar quente (Fogo esquentar a Terra) | `StonePillar` não tem `add_heat` nem guarda calor; só `PhysicsProp` guarda | `stone_pillar.gd` (classes) | 1 regra + 1 número |
| Q6 | Lava apagada pela lama virar crosta de pedra | Falta um sinal e uma regra: hoje só pára de aquecer (`lava_pool.gd:54`) | `lava_pool.gd` (classes) + arte | 1 regra + 1 sinal |
| Q7 | Mão de pedra herdar o calor da pedra socada | Falta ligar `PhysicsProp.heat` ao revestimento (`stone_strike_ability.gd:106-110`) | classes + gameplay | 1 regra + 1 sinal |
| Q8 | Gravidash respeitar massa | Falta limitar pela massa, como a Telecinese faz (`telekinesis_ability.gd:31`, `carry_mass`) | `gravidash_ability.gd` | 1 número |
| Q9 | Almôndega filtrar dano por origem | Hoje usa a invencibilidade da vida (`fire_shield.gd:91-96`), que também bloqueia golpe de quem está dentro | frente monstros (já pedido) | 1 regra |
| Q10 | Maestria "Reação em cadeia" do Fogo | Bola detona Bolas no ar; está no laboratório como módulo 8 (`maestrias.md`) | ainda não no kit | já planejada |

**Contradição de documento (importante):** `physics-magic-system.md` diz que "a onda de choque é golpe: racha e
parte caixas e construções" e que "a cobertura de pedra de quem se escondeu também se desfaz". Isso vale para
`BreakableStructure` (`explosion.gd:51-58`) e para objetos soltos, mas **não para a Escada nem o Terremoto**. Ou o
texto diz "construções do cenário", ou o código ganha o Q1.

## 3. Rastros entre elementos

Legenda do estado: **funciona** (lido no código), **metade** (um lado funciona), **não** (não existe).

### Fogo x Terra

| Rastro | Gancho | Lado que ajuda | Outro lado | Estado |
|---|---|---|---|---|
| Lama (Terra) | Lava, fátuo, braseiro (Fogo) | Terra desliga o fogo | A lama também atrasa a Terra (`mud_patch.gd:85-88`, sem isenção do dono) | **funciona** (falta sinal na lava) |
| Calor (Fogo) | Pedra solta, pedregulho (Terra) | Pedra em brasa acende madeira | A Terra arremessa a pedra quente; quem não é dono do calor se queima | **funciona** em `PhysicsProp` |
| Calor (Fogo) | Escada e relevo (Terra) | Pilar em brasa | A Terra ganha arma quente | **não** (Q5) |
| Pilar e relevo (Terra) | Explosão (Fogo) | Cobertura contra a explosão (`explosion.gd:100+`, oclusão) | Se a Bola racha a escada, o Fogo derruba a cobertura da Terra | **metade** (cobre, mas não racha: Q1) |
| Soco (Terra) | Objeto em chamas (Fogo) | Pedaços herdam fogo e calor (`physics-magic-system.md`, Quebrável 8) | Os pedaços acesos também voam na cara de quem socou | **funciona** (pelo GDD e pelos testes de herança) |
| Almôndega (Fogo) | Pedra arremessada (Terra) | Para a pedra e a esquenta (`fire_shield.gd:77-81`) | A pedra quente cai aos pés do Fogo, mas ele é o dono e não se queima: só pune aliados | **funciona** |
| Lava (Fogo) | Escada (Terra) | A lava cobre 1 m de altura (`lava_pool.gd:10`) | Degraus de 1,7 m e 2,55 m escapam; o de 0,85 m fica dentro da lava **[não verificado]** | **funciona** por acidente |
| Fátuo (Fogo) | Pilar (Terra) | Pilar pegar fogo | Nada: só aparece o fogo visual (`burn_effect.gd:19-31`) | **não** |
| Revestimento (Terra) | Pedra quente (Fogo) | Soco queima | A mão também queima | **não** (Q7) |

### Fogo x Gravidade

| Rastro | Gancho | Lado que ajuda | Outro lado | Estado |
|---|---|---|---|---|
| Queimar (Fogo) | Peso (Gravidade) | Objeto queimado perde até 60% da massa (`burnt_mass_fraction` 0,4) e voa mais longe com Push-Pull ou Gravidash | O inimigo o devolve do mesmo jeito | **funciona** (sem sinal) |
| Peso (Sonhos) | Pólvora (Fogo) | Barril cai mais rápido e detona | Detona perto de quem pesou | **funciona, mas estreito:** com 1,4x a queda mínima para detonar cai de ~4,1 m para ~3 m (conta de `physics-magic-system.md`); o mago não pesa mais (`dream_gravity_zone.gd:38`) |
| Mibune (Gravidade) | Fogo espalhando | Junta lenha: fogo acelera | Todo o grupo acende junto, inclusive o da Gravidade | **funciona** (acidente feliz, não verificado) |
| Gravidash (Gravidade) | Barril e caixa acesa | Aríete de fogo | Detona em cima de quem lançou | **funciona** (acidente perigoso: Q8) |
| Push-Pull (Gravidade) | Bola e Fátuo (Fogo) | Rebate o tiro | O tiro devolvido atravessa o dono (Q4) | **metade** |
| Mibune e Sonhos | Fátuo e Bola | Curvar o tiro | O mago de Fogo precisa se preocupar | **quase não** (Q3: fátuo imune, Bola a 20%) |
| Zona Nula (Gravidade) | Tiros e lava (Fogo) | Apaga o tiro, tranca o kit | Lava e queimadura continuam: o Fogo preso na zona não se salva | **funciona** |
| Almôndega (Fogo) | Mibune (Gravidade) | — | O Mibune não é projétil, então atravessa a bola (`fire_shield.gd:70`); o dano só é barrado pela invencibilidade provisória | **funciona sem querer** |

### Terra x Gravidade

| Rastro | Gancho | Lado que ajuda | Outro lado | Estado |
|---|---|---|---|---|
| Pedregulho (Terra) | Mibune, Push-Pull, Gravidash (Gravidade) | Pedras viram munição e plataforma | Os pedregulhos voam na cara do Terra | **funciona** (pedregulho do Terremoto: ~12 kg) |
| Mibune (Gravidade) | Escada e Terremoto (Terra) | Racha a construção (`mibune.gd:135-137`) | A Terra racha a do outro; a Gravidade perde cobertura | **funciona** |
| Pilar e relevo (Terra) | Push-Pull, Gravidash, Mibune (puxão) | Mover construção | — | **não**: é `AnimatableBody3D`, nenhum puxão o move. O "Esmagar" do eixo Peso não existe |
| Zona Nula (Gravidade) | Soco e Chute da Terra | Trava o kit da Terra | A Terra ainda tem a escada, o relevo e a lama feitos antes | **funciona** |
| Terremoto (Terra) | Sonhos (Gravidade) | Quem sobe volta mais rápido | O mago não é afetado pelo peso extra | **funciona** em objetos e monstros |
| Peso (Sonhos) | Soco da Terra | A tabela diz "mais difícil arremessar" | Na verdade o soco dá impulso e o peso só curva a trajetória: a massa não muda (`physics-magic-system.md`, Lei da Gravidade 2) | **funciona**, mas o texto da tabela exagera |

## 4. Melhorias por habilidade

Custo: baixo (um número ou uma linha), médio (regra nova num arquivo), alto (sistema novo).

### Fogo

- **Bola de Fogo.** Mudar: nada na regra; deixar a explosão rachar pilares da Terra (Q1). Por quê: fecha o
  buraco do GDD e dá ao Fogo o papel de "quebra-cobertura". Custo baixo. Risco: baixo; a Terra passa a perder
  a escada para qualquer explosão, o que é o "outro lado" que queremos.
- **Fogo-Fátuo.** Mudar: (a) cor do fátuo longe do azul do Dardo (`fire_wisp_projectile.gd:6` usa
  (0,55; 0,9; 1,0) e o Dardo (0,55; 0,95; 1,0), `kinetic_dart_projectile.gd:6`); (b) fazê-lo responder a áreas de
  gravidade (Q3). Por quê: legibilidade e gancho com a Gravidade. Custo baixo (a) e médio (b). Risco: (b) o
  Mibune vira escudo contra tiros lentos; limitar com uma fração da gravidade da área.
- **Chão de Lava.** Mudar: quando a lama a cobre, escurecer a malha e baixar o brilho; opcional, virar crosta
  de pedra quente (Q6). Por quê: hoje o jogador não vê que a lava "morreu" (`lava_pool.gd:54`). Custo baixo
  (sinal) e médio (crosta). Risco: crosta cria pedra no mundo; contar como pedaços e respeitar o limite de objetos.
- **Almôndega de Fogo.** Mudar: a bola encolhe conforme o tempo, e o filtro de dano por origem (Q9). Por quê: o
  jogador não sabe quanto falta; a invencibilidade provisória bloqueia golpes de quem está dentro
  (`mage-fire.md:64-65`). Custo baixo (sinal) e médio (filtro, é da frente monstros). Risco: a regra "absorve tudo
  de fora" fica mais clara, não mais fraca.
- **Jatos de Fogo.** Mudar: deixar calor leve no que o mago sobrevoa (rastro de movimento, lado "Chama" do eixo).
  Por quê: hoje o voo não deixa nada no mundo e é o único movimento sem rastro. Custo médio. Risco: incêndio
  fora de controle; usar calor baixo e valer só abaixo de 2 m. Não conferi o que o voo faz sob a Zona Nula
  **[não verificado]**.

### Terra

- **Soco de Pedra.** Mudar: dar sinal quando se soca o ar sem revestimento (hoje só gasta Vigor,
  `stone_strike_ability.gd:83-86`). Por quê: parece bug. Custo baixo. Risco: nenhum. Opcional: herdar calor da pedra
  quente socada (Q7), custo médio, risco de confundir (o mago se queima).
- **Chute de Pedra.** Mudar: nada na regra. Por quê: a faixa baixa já resolve "caixa no chão". Mostrar a faixa na
  mira ajuda a aprender. Custo baixo (arte/HUD).
- **Escada de Pedra.** Mudar: aceitar pilar de pé como chão (Q2). Por quê: Escada sobre o relevo do Terremoto é a
  melhor combinação interna da Terra. Custo baixo. Risco: torre infinita; limitar a um número de camadas ou a uma
  altura máxima.
- **Terremoto.** Mudar: aviso de 0,5 s no chão antes de subir. Por quê: acerta de uma vez
  (`earthquake_zone.gd:62`), e o GDD já marca o dano como o número mais forte a revisar (54,6 no boneco). O aviso
  deixa o golpe legível e justo. Custo baixo. Risco: diminui a surpresa contra monstros parados; pode valer só
  contra jogadores.
- **Lamaçal.** Mudar: decidir se o dono fica isento. Hoje ele também atrasa o mago (`mud_patch.gd:85-88`), enquanto
  lava e Almôndega o isentam. Por quê: é a única magia de terreno que pune o dono. Custo baixo. Risco: se isentar,
  a lama deixa de ser "armadilha dos dois lados". Pergunta para o Liam.

### Gravidade

- **Push-Pull.** Mudar: o projétil rebatido troca de dono e perde a exceção de colisão com o dono antigo (Q4).
  Por quê: "devolver o tiro" é a fantasia; hoje o tiro atravessa quem o lançou. Custo médio. Risco: devolução
  perfeita vira meta; a regra de impulso mínimo já limita. Mostrar um sinal "rebateu" ou "forte demais"
  (`last_deflected` já existe, `push_pull_ability.gd:18`).
- **Mibune.** Mudar: deixar projétil lento ser curvado (Q3). Por quê: gancho com o Fogo. Custo médio. Risco: ver
  Fátuo. Outro: avisar que o Mibune puxa "mais forte perto do centro" (hoje é igual em todo o raio,
  `mibune.gd:44-46`).
- **Gravidade dos Sonhos.** Mudar: tingir levemente o que está "pesado" dentro da zona. Por quê: o peso não tem
  sinal (G3). Custo baixo (arte). Não conferi o que `EFFECT_HASTE` faz **[não verificado]**; o GDD diz que é a
  recarga mais curta. Risco: baixo.
- **Gravidash.** Mudar: o objeto carregado perde velocidade com a massa, como a Telecinese
  (`arremesso = vel x clamp(1 - massa / (carga x 1,5), 0,3, 1)` em `physics-magic-system.md`) (Q8). Por quê: sem
  isso, bloco de 605 kg e barril de pólvora viram arma. Custo baixo. Risco: perde o "aríete"; dá para manter com
  carga alta.
- **Zona Nula.** Mudar: ícone claro de "sem magia" em quem está dentro, e de "kit trocado" já existe no HUD
  (`mage-gravity.md`, Dependencies). Por quê: legibilidade do estado mais forte do jogo. Custo baixo (interface).
  Risco: nenhum.
- **Agarrar.** Mudar: nada agora. Por quê: 0,3 s é curto, mas é o gancho para o golpe grátis; precisa de playtest.

### Ferramentas guardadas (fora do kit hoje)

- **Dardo Cinético:** cor próxima ao Fátuo (ver acima). Passa pelo Push-Pull com 84 contra 120.
- **Campo Lento:** limita a velocidade de todo corpo rígido a 1,5 m/s e não devolve (`slow_field.gd:61-62`). Em cima
  de um Fátuo vira uma mina que ainda anda. Combo bonito, mas fora do kit.
- **Telecinese e Flutuar:** sem acidentes relevantes lidos.

## 5. Propostas

Todas são sim/não. Em ordem de prioridade (do que mais pesa em jogo para o que menos pesa).

1. **Gravidash respeita a massa do que carrega** (a velocidade do objeto cai com a massa, como a Telecinese).
   Frente dona: **classes** (`gravidash_ability.gd`). Custo baixo. Evita barril e bloco de 605 kg como arma de graça. Sim ou não?
2. **A explosão racha a Escada e o Terremoto da Terra** (e o GDD continua como está). Frente dona: **gameplay**
   (`explosion.gd:79`), com a frente **classes** conferindo o pilar. Custo baixo. Sim ou não?
3. **O tiro rebatido pelo Push-Pull passa a ser do mago que rebateu** (e pode atingir o dono antigo). Frente
   dona: **classes** (`push_pull_ability.gd`, projéteis). Custo médio. Sim ou não?
4. **A Escada e o Lamaçal podem ser lançados em cima do relevo de pé do Terremoto.** Frente dona: **classes**
   (`terrain_ability.gd:45`). Custo baixo, com limite de altura. Sim ou não?
5. **Mibune e Gravidade dos Sonhos passam a curvar tiros lentos (Fogo-Fátuo e Bola de Fogo) por uma fração da
   gravidade da área.** Frente dona: **classes**, com os números em **gameplay** (leis). Custo médio. Sim ou não?
6. **Três sinais de legibilidade:** (a) lava coberta por lama escurece; (b) Fogo-Fátuo ganha cor própria, longe
   do Dardo; (c) objetos pesados (Sonhos) e quentes ganham tom visível. Frente dona: **arte**; o ícone de "sem
   magia" da Zona Nula fica com **interface**. Custo baixo. Sim ou não?

**Perguntas abertas que não entram nas 6 (resposta rápida):**

- A lama do Terra deve **apagar** a queimadura do Fátuo (como o código faz hoje) ou **deixar continuar** (como diz
  `mage-fire.md:98-99`)? A resposta corrige o texto ou o código.
- O Lamaçal deve **isentar o dono**, como a lava e a Almôndega fazem?

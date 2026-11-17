# Sistema de física, materiais e magia

> Status: v0.2 (2026-11-17) · leis de Fogo, Terra e Gravidade no mundo · implementado em `src/gameplay/world/`
> Fontes: `game-concept.md` (visão dos magos de um elemento), `mage-fire.md`, `mage-earth.md`, `mage-gravity.md`,
> e o material do Sábio `design/sabio/inspiracao/magos-elementais.md` e `tabela-elementos-materiais.md`.

## Overview (Visão geral)

Todo objeto interativo é um `PhysicsProp` feito de um `PropMaterial`. A massa vem do volume x densidade. Cada
elemento tem uma **lei**: uma regra física sempre ligada que **mora no mundo, não no mago**. Por isso magos,
monstros, objetos e o braseiro obedecem às mesmas regras, e o que um mago deixa para trás (calor, lama, peso)
vira gancho para o outro. Este documento define as leis da fatia vertical (Fogo, Terra e Gravidade), como elas
conversam entre si e com os materiais, e as regras de calor e explosão que já existiam.

## Player Fantasy (Fantasia do jogador)

"Se parece que deveria funcionar, funciona, e funciona sempre igual." Jogar uma caixa no barril de pólvora faz
explodir. A pedra que levou fogo fica em brasa e acende a caixa encostada nela, seja de quem for. A lama apaga o
braseiro. Um barril que cai de pouca altura não explode, mas o mesmo barril onde tudo pesa três vezes mais
explode ao bater no chão. O jogador aprende a lei uma vez e usa contra monstros e jogadores.

## Detailed Rules (Regras)

### Materiais atuais

| Material | Densidade de jogo | Exemplo | Fogo | Calor guardado | Terra |
|---|---|---|---|---|---|
| Madeira | 90 kg/m³ | caixa 0,6 m = 19 kg | queima 10 s, espalha num raio de 1,4 m | não (perde 15/s) | não trabalha · força 1x |
| Metal | 600 kg/m³ | caixa 0,5 m = 75 kg | não queima | até 300, perde 25/s | não trabalha · força 1x |
| Pedra | 350 kg/m³ | bloco 0,6 m = 76 kg; 1,2 m = 605 kg | não queima | até 400, perde 3/s | trabalha · força 2x |
| Pólvora | 110 kg/m³ | barril = 28 kg | pavio 1,5 s; detona com impacto ≥ 9 m/s | não | não trabalha · força 1x |
| Solo | 160 kg/m³ | chão sem material declarado | não queima | não | trabalha · força 1x |

A densidade "de jogo" é mais baixa que a real (madeira real ~600) para que caixas comuns sejam carregáveis.
Consistência entre materiais importa mais que o valor absoluto. `conductive` (metal) segue reservado para a
Eletricidade.

### Regra de ouro das interações

Toda interação tem **dois lados**: ela ajuda quem a provoca e pode ser usada contra ele, por aliados, inimigos e
monstros. Nenhuma lei sabe quem é o dono do calor, da lama ou do peso. A tabela de interações abaixo traz, em cada
linha, o lado que ajuda e o lado que pune.

### Lei do Fogo: o calor acumula, espalha e consome combustível; precisa de ar

1. `add_heat(q)` soma calor. Inflamável com calor ≥ `ignition_heat` → pega fogo.
2. Fora do fogo, o calor cai `heat_decay` por segundo (um toque rápido de fogo não basta).
3. **Combustível:** cada material inflamável tem `burn_time` segundos de combustível. Queimando, gasta
   combustível na proporção do ar. Apagar e reacender **continua do que sobrou**; não há combustível novo.
4. **O fogo consome o objeto:** a massa cai de 100% até `burnt_mass_fraction` (40%) conforme o combustível
   acaba. Uma caixa meio queimada voa mais longe com o mesmo empurrão. Sem combustível, vira cinzas e some.
5. **Ar:** cada ponto do mundo tem ar entre 0 e 1 (normal = 1). Zonas sem ar (`HeatZone` com `air_factor` 0;
   lama e, no futuro, água) **apagam** o que queima dentro, **impedem o calor de entrar** e impedem de acender.
   Uma fonte de calor (braseiro) tocada por uma zona sem ar também para de aquecer enquanto estiver tocada.
   No mesmo tick, vale o menor ar: **sem ar sempre vence o fogo**, não importa a ordem.
6. Pólvora em chamas: após `fuse_time`, explode. Apagar para o pavio.
7. **Pedra e metal guardam calor:** não queimam, mas acumulam calor até `max_heat` e perdem devagar
   (`heat_decay`). Acima de `radiate_threshold`, aquecem os vizinhos no raio `radiate_radius` e **perdem o calor
   que entregam** (o calor não se multiplica entre duas pedras). A cor vai para o vermelho conforme o calor.

### Lei da Terra: massa e permanência; só trabalha o solo e a pedra que existem ali

1. O mundo responde **qual material está sob um ponto** (`PropMaterial.ground_under`): o material do objeto,
   ou **solo** para chão e paredes estáticos sem material declarado, ou **nada** (ar, vazio).
2. Só materiais com `earth_workable` servem de base para a Terra (erguer pilar, abrir lama, revestir o golpe).
   Hoje: solo e pedra. Em cima de madeira, metal ou no ar, a Terra não tem com o que trabalhar.
3. A força da Terra sobre um material é multiplicada por `earth_force_factor`: a pedra responde 2x.
4. O que a Terra ergue tem a massa do material de que é feito (volume x densidade da pedra) e fica até alguém
   destruir. A densidade vem sempre do `.tres` do material, nunca de um número dentro da habilidade.
5. Qualquer cena pode declarar o material de um corpo com o metadado `material_data` (ex.: um chão de madeira,
   uma ponte de metal). Assim, a fase decide onde a Terra funciona sem código novo.

### Lei da Gravidade: muda o peso e a direção da queda de tudo que tem massa; não cria matéria

1. A gravidade de um lugar é definida por **áreas de gravidade** do mundo (`Area3D` com substituição de
   gravidade): intensidade e direção, ou um ponto que atrai.
2. **Peso = massa x gravidade do lugar x escala de gravidade do corpo** (`PhysicsProp.get_weight()`). A massa
   não muda: a Gravidade nunca cria nem tira matéria; ela só move o que já existe.
3. Tudo que tem massa responde igual: objetos, projéteis com corpo, pedregulhos da Terra, barris. Personagens:
   ver "Perguntas abertas".
4. Mais peso significa queda mais rápida e impactos mais fortes; menos peso, objetos que flutuam e voam mais
   longe com o mesmo empurrão. As regras de impacto (dano por massa x velocidade, pólvora a 9 m/s) não mudam:
   a gravidade só muda a velocidade com que as coisas chegam.

### Interações da fatia (rastro de um, gancho do outro)

| Rastro | Gancho | O que acontece | O lado que ajuda | O outro lado |
|---|---|---|---|---|
| Fogo: calor | Pedra (Terra) | Pedra em brasa guarda calor e acende madeira encostada | O Fogo transforma pilares e pedregulhos em armadilhas | O mago da Terra pode arremessar a pedra quente; e quem a aqueceu também se queima perto dela |
| Terra: lama | Fogo | Lama é zona sem ar: apaga, bloqueia calor e abafa o braseiro | Terra desliga a área do Fogo | A lama também apaga o fogo que protegia o mago da Terra e para o pavio de um barril que ele queria explodir |
| Fogo: queima | Gravidade | Queimar tira massa: o objeto fica mais leve | Gravidade arremessa mais longe o que já queimou | O mesmo vale para o inimigo arremessar de volta |
| Gravidade: peso | Pólvora (Fogo) | Mais peso → queda mais rápida → impacto passa de 9 m/s e detona | Gravidade vira detonador à distância | O barril explode onde cair, inclusive perto de quem pesou |
| Gravidade: leveza | Terra | Pedras leves flutuam e viram projéteis e plataformas | Os dois usam as pedras | O inimigo também sobe nas plataformas e pega os projéteis |
| Gravidade: peso | Terra | Pedra é a mais densa: no peso alto, esmaga mais | Terra ganha força | Mais difícil para a própria Terra arremessar |
| Explosão | Pedra | A explosão aquece a pedra próxima | Rastro duradouro do Fogo | Fica quente para os dois lados |

### Explosões

Esfera de raio R a partir da origem. Quem leva o acerto direto recebe tudo. Os demais perdem força com a distância
d até a superfície do corpo. A explosão não depende de ar (a pólvora traz o que precisa); só o pavio para quando
o fogo é apagado.

**Cobertura:** um raio vai da explosão até o centro de cada corpo. Se uma parede ou um pilar estiver no caminho,
só 15% do impulso e do calor passam. Objetos soltos, personagens e o boneco não bloqueiam, para uma caixa não
virar escudo total. O raio é um só: quem está com o centro do corpo coberto conta como protegido.

### Alcance real do fogo (medido no teste de fumaça, caixas de madeira)

`fire_spread_radius` (1,4 m) é só onde o calor começa a chegar. Para acender, o calor precisa vencer o
resfriamento (15/s) antes de a vizinha acabar de queimar (10 s).

| Situação | Resultado |
|---|---|
| Uma caixa em chamas a 0,50 m entre centros | acende em 7,2 s |
| Uma a 0,62 m (distância da pirâmide) | acende em 9,9 s, quase no limite |
| Uma a 0,70 m ou mais | não acende |
| Três a 0,90 m | acende em 3,0 s (o calor soma) |
| Pirâmide de 10 caixas, acesa por uma da base | todas em 18,9 s |
| Pedra em brasa (400) e caixa a 0,8 m entre centros | acende em 1,6 s; a pedra cai para ~270 |
| Barril solto de 2,5 m (base) | gravidade normal: não detona · gravidade 3x: detona |

## Formulas (Fórmulas)

```
massa             = volume x densidade
peso              = massa x |gravidade_local| x gravity_scale
combustível/s     = ar                                   (ar: 0 a 1; 0 apaga)
calor_vizinho/s   = fire_spread_heat x ar x (1 - d / fire_spread_radius)
massa_queimando   = massa_inicial x lerp(1, burnt_mass_fraction, queimado)     queimado = 1 - combustível / burn_time
calor_guardado    = min(calor + q, max_heat)                                    (pedra, metal)
irradiado/s       = (calor - radiate_threshold) x radiate_rate x (1 - d / radiate_radius)   por vizinho, se calor > limiar
calor_emissor    -= soma do irradiado                                           (conservação)
tempo_para_acender = ignition_heat / (calor_recebido/s - heat_decay)            (nunca, se o divisor ≤ 0)
queda             = clamp(1 - d / R, 0, 1)      (x 0,15 atrás de parede ou pilar; 1 no acerto direto)
impulso_corpo     = impulso_explosão x queda    (direção: para fora + 40% para cima)
calor_corpo       = calor_explosão x queda
vel_jogador      += impulso / massa_jogador
impacto_no_boneco = massa x velocidade          (N·s, quantidade de movimento)
vel_impacto       = raiz(2 x g_local x altura)  (detona pólvora se ≥ impact_detonation_speed)
força_terra       = força_base x earth_force_factor
arremesso         = vel_arremesso x clamp(1 - massa / (carga x 1,5), 0,3, 1)
```

| Variável | Significado | Faixa | Origem |
|---|---|---|---|
| `ar` | Ar no ponto | 0 a 1 (acima de 1 reservado ao Ar/vento) | `HeatZone.air_factor` |
| `burn_time` | Combustível em segundos com ar normal | 3 a 10 | `materials/*.tres` |
| `burnt_mass_fraction` | Massa que sobra no fim da queima | 0,05 a 1 (0,4) | `materials/*.tres` |
| `max_heat` | Calor máximo guardado | pedra 400, metal 300 | `materials/*.tres` |
| `radiate_threshold` | Calor a partir do qual irradia | pedra 50, metal 80 | `materials/*.tres` |
| `radiate_rate` | Fração do excesso entregue por segundo | pedra 0,6, metal 0,4 | `materials/*.tres` |
| `earth_force_factor` | Multiplicador da Terra | pedra 2, demais 1 | `materials/*.tres` |

`d` é sempre a distância até a superfície do vizinho, não até o centro.

**Exemplos:** madeira a 1 m (superfície) de uma pedra em 400 de calor recebe `350 x 0,6 x (1 - 1/1,5) = 70/s`;
descontado o resfriamento de 15/s, acende em ~1,8 s, um pouco mais porque a pedra esfria ao entregar. Barril de 2,5 m: `raiz(2 x 9,8 x 2,5) = 7 m/s` (não detona);
`raiz(2 x 29,4 x 2,5) = 12,1 m/s` (detona).

## Edge Cases (Casos-limite)

- Explosão perto de outros barris: eles aquecem, acendem e explodem em cadeia (com atraso do pavio).
- Objeto em chamas sendo segurado continua queimando e espalhando calor.
- Barril jogado contra parede a ≥ 9 m/s explode na hora.
- Consultas de física nunca rodam dentro de callbacks de colisão (usamos `call_deferred`).
- Explosão rente ao chão ou colada numa parede: o raio começa 10 cm acima da origem.
- **Objeto dentro da lama e do braseiro ao mesmo tempo:** sem ar vence; o calor é ignorado e ele não acende
  (fecha a lacuna 2 do Sábio, de acender e apagar em ciclo).
- **Braseiro dentro da lama:** para de aquecer enquanto a lama o tocar e volta sozinho quando ela some (lacuna 1).
- **Objeto sem combustível:** não reacende, mesmo com calor.
- **Duas pedras quentes lado a lado:** trocam calor, mas cada uma perde o que entrega e o resfriamento continua;
  as duas esfriam até o limiar.
- **Pedra quente dentro de zona sem ar:** não recebe calor novo, mas continua irradiando o que guardou (calor
  guardado não é chama).
- **Explosão em zona sem ar:** empurra normalmente, mas o calor dela não entra em quem está sem ar (a lama
  protege do fogo, não da onda de choque).
- **Gravidade apontando para cima ou de lado:** os objetos "caem" naquela direção; o impacto conta igual.
- **Gravidade zero:** peso 0; o objeto mantém a velocidade que tinha. Nada cai, nada detona por queda.
- **Terra sobre o vazio, madeira ou metal:** `ground_under` devolve nada ou um material não trabalhável; a
  habilidade deve recusar sem gastar recurso.

## Dependencies (Dependências)

| Sistema | Relação |
|---|---|
| `PropMaterial` (`prop_material.gd`) | Dados de todas as leis; `of()` e `ground_under()` respondem o material de um corpo e do chão |
| `PhysicsProp` (`physics_prop.gd`) | Calor, combustível, ar (`apply_air`), calor guardado, irradiação, peso (`get_weight`) |
| `HeatZone` (`heat_zone.gd`) | Zona de ambiente: calor por segundo e ar; braseiro e zonas sem ar |
| `Explosion` (`explosion.gd`) | Onda de choque; o calor dela também esquenta pedra e metal |
| Áreas de gravidade (`Area3D` do Godot) | Gravidade local; usadas por `SlowField` (frente classes) e pelos testes |
| Habilidades (frente classes) | Usam as leis: Bola de Fogo, Fogo-Fátuo, Chão de Lava e Almôndega chamam `add_heat`/`ignite`; Terra consulta o chão; Gravidade muda peso e direção |
| `MudPatch` (frente classes) | Hoje apaga e esfria os objetos por conta própria; deve passar a usar o ar do mundo (pedido registrado) |
| `TrainingDummy`, `FlyingTarget` (frente monstros) | Recebem calor (inclusive de pedra em brasa) e impacto |
| Tabela do Sábio | `tabela-elementos-materiais.md` é a origem das interações; este documento é a versão em vigor da fatia |

## Tuning Knobs (Ajustes)

Todos em `assets/data/materials/*.tres`: densidade, atrito, ignição, `heat_decay`, `burn_time`,
`burnt_mass_fraction`, `max_heat`, `radiate_threshold`, `radiate_radius`, `radiate_rate`, `earth_workable`,
`earth_force_factor` e os campos de explosão. `heat_per_second` e `air_factor` de cada `HeatZone` (o braseiro fica
em `test_arena.gd`). `blocked_explosion_factor` em `assets/data/damage_rules.tres` (0,15; faixa segura 0–0,5).

| Ajuste | Inicial | Faixa segura | Efeito de mexer |
|---|---|---|---|
| `radiate_rate` (pedra) | 0,6 | 0,2–1,0 | Abaixo de 0,3 a pedra quente quase não acende nada; acima de 1 vira lança-chamas |
| `max_heat` (pedra) | 400 | 150–600 | Quanto tempo a pedra fica perigosa depois do fogo |
| `heat_decay` (pedra) | 3/s | 1–10 | Quanto a pedra guarda sozinha; 3/s = ~2 min de 400 até o limiar |
| `burnt_mass_fraction` | 0,4 | 0,2–0,8 | O quanto queimar muda o arremesso |
| `earth_force_factor` (pedra) | 2 | 1,5–3 | Quanto a Terra prefere pedra |

## Acceptance Criteria (Critérios de aceite)

Testes automáticos em `tests/suites/gameplay.gd` (nenhum usa habilidade):

- [x] Madeira com calor suficiente pega fogo; barril explode e some.
- [x] Parede e pilar cortam impulso e calor; caixa solta e chão não bloqueiam; acerto direto ignora parede.
- [x] Fogo se espalha pela pirâmide de caixas em menos de 20 s (medido: 18,9 s).
- [x] **Fogo · combustível:** 3 s queimando deixam 7 s de 10; reacender continua do que sobrou; a massa cai.
- [x] **Fogo · ar:** zona sem ar apaga, impede calor e impede de acender.
- [x] **Fogo · braseiro abafado:** braseiro tocado por zona sem ar não aquece; sem a zona, volta a acender.
- [x] **Fogo · pedra:** pedra esquenta até 400 sem pegar fogo; guarda mais de 150 de 200 em 5 s enquanto a madeira
  perde tudo; pedra em brasa acende madeira a 0,8 m e esfria ao entregar calor.
- [x] **Terra:** chão da arena é solo trabalhável; madeira não; pedra sim; no ar não há material; pedra 2x.
- [x] **Gravidade:** gravidade 3x triplica o peso sem mudar a massa; o objeto mais pesado cai mais rápido;
  gravidade de lado faz cair para o lado.
- [x] **Gravidade x Fogo:** barril solto de 2,5 m só detona na gravidade 3x.
- [ ] Playtest: ficar atrás de parede ou da Escada de Pedra protege de um barril de um jeito fácil de entender.
- [ ] Playtest: o jogador percebe que a pedra está quente antes de encostar (cor e, no futuro, som e vapor).
- [ ] Playtest: lama sobre o braseiro é entendida como "abafou", não como bug.
- [ ] Mago e monstros obedecem às áreas de gravidade (depende das perguntas abertas).

## Perguntas abertas (para o Liam)

1. **O mago obedece às áreas de gravidade?** A lei diz que sim ("inclusive o próprio mago"). Testado: com isso
   ligado, o Psiônico dentro do próprio Campo Lento (gravidade 0,1x) chega a 4 m no pulo duplo, e o teste da
   frente classes reprova. Opções: (a) sim, para todos, e o Campo Lento passa a deixar leve quem está dentro,
   inclusive o dono; (b) sim, mas o Campo Lento deixa de ser área de gravidade e vira só freio; (c) não, o mago
   só muda de peso pelas próprias habilidades. A mudança no `player.gd` é de uma linha e está descrita no relatório.
2. **Personagem recebe calor?** Hoje só objetos, boneco e alvos recebem. Pedra em brasa e lava ficam mais
   claras se queimarem o mago também, mas isso depende do sistema de vida (frente monstros/classes).
3. **Chão padrão é solo?** Decidido aqui só como ponto de partida (para a Terra funcionar na arena). Uma fase
   pode declarar outro material. Confirma que o chão "sem material" é terra?
4. **Ar acima de 1 (vento)** fica reservado para o elemento Ar: alimenta o fogo (mais calor, consome mais
   rápido). Nada disso está ligado agora.

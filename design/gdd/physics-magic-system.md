# Sistema de física, materiais e magia

> Status: rascunho v0.1 · implementado em `src/gameplay/world/` e `src/gameplay/abilities/`

## Overview (Visão geral)

Todo objeto interativo é um `PhysicsProp` feito de um `PropMaterial`. A massa vem do
volume x densidade. Fogo funciona por **calor acumulado**: fontes de calor (Bola de Fogo,
braseiro, objetos em chamas, explosões) aquecem materiais inflamáveis até pegarem fogo.
Explosões são ondas de choque que empurram, aquecem e arremessam.

## Player Fantasy (Fantasia do jogador)

"Se parece que deveria funcionar, funciona." Jogar uma caixa no barril de pólvora faz
explodir. Carregar uma caixa até o braseiro e jogar na pilha incendeia a pilha.

## Detailed Rules (Regras)

### Materiais atuais

| Material | Densidade de jogo | Exemplo | Queima | Especial |
|---|---|---|---|---|
| Madeira | 90 kg/m³ | caixa 0,6 m = 19 kg | sim, 10 s | espalha fogo num raio de 1,4 m |
| Metal | 600 kg/m³ | caixa 0,5 m = 75 kg | não | `conductive` (reservado para eletricidade) |
| Pedra | 350 kg/m³ | bloco 0,6 m = 76 kg; 1,2 m = 605 kg | não | muito atrito |
| Pólvora | 110 kg/m³ | barril = 28 kg | sim, pavio 1,5 s | explode ao queimar ou com impacto ≥ 9 m/s |

A densidade "de jogo" é mais baixa que a real (madeira real ~600) para que caixas comuns
sejam carregáveis. Consistência entre materiais importa mais que o valor absoluto.

### Calor e fogo

1. `add_heat(q)` soma calor. Se calor ≥ `ignition_heat` → pega fogo.
2. Fora do fogo, o calor cai `heat_decay` por segundo (um toque rápido de fogo não basta).
3. Em chamas: por `burn_time` segundos aquece os vizinhos e escurece; depois vira cinzas.
4. Pólvora em chamas: após `fuse_time`, explode.

### Explosões

Esfera de raio R a partir da origem. Quem leva o acerto direto recebe tudo. Os demais perdem força
com a distância d até a superfície do corpo.

**Cobertura:** um raio vai da explosão até o centro de cada corpo. Se uma parede ou um pilar estiver
no caminho, só 15% do impulso e do calor passam. Objetos soltos, personagens e o boneco não bloqueiam,
para uma caixa não virar escudo total. O raio é um só: quem está com o centro do corpo coberto conta
como protegido, mesmo meio exposto.

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

## Formulas (Fórmulas)

```
massa            = volume x densidade
queda            = clamp(1 - d / R, 0, 1)      (x 0,15 atrás de parede ou pilar; 1 no acerto direto)
impulso_corpo    = impulso_explosão x queda    (direção: para fora + 40% para cima)
calor_corpo      = calor_explosão x queda
vel_jogador      += impulso / massa_jogador    (x 0,15 se em Postura de Muralha)
calor_vizinho/s  = calor_espalhamento x (1 - d / raio_espalhamento)
impacto_no_boneco = massa x velocidade         (N·s, quantidade de movimento)
Investida        = massa_cavaleiro x velocidade x 0,4
arremesso        = vel_arremesso x clamp(1 - massa / (carga x 1,5), 0,3, 1)
```

## Edge Cases (Casos-limite)

- Explosão perto de outros barris: eles aquecem, acendem e explodem em cadeia (com atraso
  do pavio).
- Objeto em chamas sendo segurado continua queimando e espalhando calor.
- Barril jogado contra parede a ≥ 9 m/s explode na hora.
- Consultas de física nunca rodam dentro de callbacks de colisão (usamos `call_deferred`).
- Explosão rente ao chão ou colada numa parede: o raio começa 10 cm acima da origem. No chão, isso
  evita que ele bloqueie a explosão; numa parede, o raio começa no centro do projétil, fora dela.

## Dependencies (Dependências)

`MudPatch` (Lamaçal do Elementalista, `mage-elementalist.md`) freia props, retira calor e
apaga o fogo (`PhysicsProp.extinguish()`); o pavio de pólvora para. `StonePillar` é terreno
animado: empurra e arremessa props.
`SlowField` (Campo Lento do Psiônico, `mage-psionic.md`) limita a velocidade de props e
projéteis dentro dele e reduz a gravidade ali.
`PropMaterial` → `PhysicsProp` ↔ `Explosion` ↔ `HeatZone`; habilidades usam `Explosion`
e consultas de forma; `TrainingDummy` recebe `register_hit` e `add_heat`.

## Tuning Knobs (Ajustes)

`assets/data/materials/*.tres` (todos os campos), parâmetros de cada habilidade dentro
de `assets/data/classes/*.tres`, `heat_per_second` do braseiro em `test_arena.gd`.
`blocked_explosion_factor` em `assets/data/damage_rules.tres` (0,15; faixa segura 0–0,5): quanto de uma
explosão passa por paredes e pilares.

## Acceptance Criteria (Critérios de aceite)

- [x] Madeira com calor suficiente pega fogo (teste de fumaça).
- [x] Barril explode e some (teste de fumaça).
- [x] Parede e pilar cortam impulso e calor; caixa solta e chão não bloqueiam; acerto direto ignora parede (teste de fumaça).
- [x] Fogo se espalha pela pirâmide de caixas em menos de 20 s (medido: 18,9 s; o teste mostra o tempo, mas não falha se passar de 20 s).
- [ ] Playtest: ficar atrás de parede ou da Escada de Pedra protege de um barril de um jeito fácil de entender.
- [ ] Barril perto da pirâmide causa reação em cadeia visível.
- [ ] Cavaleiro sem magia consegue incendiar a pirâmide usando o braseiro.

## Próximas ideias (respeitando "quanto mais surreal, mais limitado")

- Água/umidade: apaga fogo, molhado demora a aquecer.
- Eletricidade: só viaja por `conductive`; poça d'água conduz.
- Fragilidade: madeira quebra em pedaços com impacto alto, em vez de só voar.
- Gelo: deixa o chão escorregadio (atrito baixo), não "congela no ar".

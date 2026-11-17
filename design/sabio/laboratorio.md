# Laboratório do Sábio

> Protótipos para o Liam avaliar. Nada aqui é decisão de design: cada módulo pode ser mantido,
> ajustado ou apagado. A arena normal e o menu do jogo continuam iguais.
> Criado em 2026-11-01.

## Como abrir

Na pasta `Ygg`, escolhendo a classe no final (`fire`, `earth` ou `psionic`, que é o Mago da Gravidade):

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" --path . res://src/levels/sabio_lab.tscn -- --class=fire
```

| Tecla | O que faz |
|---|---|
| **1 a 9** | Usa o módulo, no ponto da mira |
| **Alt + número** | Liga ou desliga o módulo na hora; desligar remove o que ele criou |
| **F5** | Recarrega o laboratório e repõe as Teias |

Ligar e desligar vale só para a sessão. Para deixar desligado por padrão, abra o `.tres` do módulo no
Godot e desmarque `Enabled`.

## Módulos

Os números de ajuste ficam no `.tres` de cada módulo, em `assets/data/lab/`. Todos são chutes iniciais.

| # | Módulo | Origem | Experimente | Pergunta para avaliar |
|---|---|---|---|---|
| 1 | **Água e Molhado** | Tabela de elementos | Crie uma poça sob uma caixa e acerte Bola de Fogo cheia. Depois, sob um barril | Dá para ver que está molhado? A proteção contra fogo parece justa? |
| 2 | **Teia** | Prisão na Teia | Prenda o boneco e acerte fogo; compare o dano. Prenda uma caixa e um alvo voador (F7) | O bônus é perceptível? Dá vontade de guardar a teia para o momento certo? |
| 3 | **Óleo** | Tabela de elementos | Crie óleo perto de um barril e acenda | O fogo se espalhando é legível? Parece injusto ou empolgante? |
| 4 | **Frio e Gelo** | Tabela de elementos | Crie uma poça, congele e arremesse uma caixa em cima | Deslizar é divertido? Combinar 2 módulos parece natural? |
| 5 | **Terra Morta** | Terra Magnética | Lance Lamaçal ou Bola de Fogo na área | "Magia some, objeto continua" se entende sem explicação? |
| 6 | **Incendiário** | Divinity 2 | Crie um perto dos barris e observe | Você aprende algo só de assistir? |
| 7 | **Lama e fogo** (passivo) | Lacunas 1 e 2 da tabela | Lance Lamaçal no braseiro; coloque uma caixa na lama e perto do fogo | O braseiro apagar faz sentido? |
| 8 | **Reação em cadeia** (passivo, classe `fire`) | [Maestrias](inspiracao/maestrias.md): Explosão | Lance 3 Bolas de Fogo seguidas, mirando perto umas das outras: quando a primeira estourar, as próximas no raio estouram junto. Depois, uma perto de um barril de pólvora | Dá para ver cada elo? A cadeia parece sua ou fora de controle? O risco de ser atingido é justo? |
| 9 | **Inércia guardada** (passivo, classe `psionic`) | [Maestrias](inspiracao/maestrias.md): Leveza | Lance o Campo Lento, dispare dardos e arremesse caixas para dentro dele e espere o Campo acabar | O brilho e a piscada avisam a tempo? Montar a "armadilha" é divertido? O gasto de Mana pesa? |

## Limites conhecidos

- **Só existem no laboratório.** O jogo normal não muda.
- **Sem custo:** nenhuma ação gasta Mana ou tem recarga, para facilitar o teste. A Inércia guardada é a exceção: drena Mana enquanto guarda algo. Só a Teia tem limite,
  8 por partida.
- **Sem espaço no HUD:** as teclas aparecem só no painel à esquerda.
- **Objetos, não personagens:** jogador e boneco não ficam Molhados, e o jogador não escorrega no gelo
  nem no óleo. Isso exigiria mudar `player.gd`, que hoje está reservado.
- **Terra Morta:** não impede lançar magia, só desfaz projéteis e áreas mágicas cujo centro esteja
  dentro dela. A Telecinese não é afetada.
- **Gelo:** ao derreter, some em vez de virar poça, para o módulo não depender do módulo de Água.
- **Pólvora Molhada:** não recebe calor nenhum, valor mais forte que o fator comum de Molhado.
- **Maestrias só pela metade:** a Reação em cadeia liga Bolas de Fogo e pólvora, mas ainda não a propulsão, a detonação no ar e a cratera, que não existem. A Inércia guardada vale só para o Campo Lento; Telecinese, Flutuar e pedras flutuantes ficam de fora. Os dois valem para qualquer jogador da classe, sem exigir as 4 versões, porque a escolha de versões ainda não existe.

## Como remover

| Quero | Faço |
|---|---|
| Tirar um módulo do jogo | Apago o `.tres` dele em `assets/data/lab/` |
| Remover o código dele | Também apago os scripts em `src/gameplay/lab/modules/` e o teste em `tests/lab_test.gd` |
| Remover tudo | Apago `src/gameplay/lab/`, `assets/data/lab/`, `src/levels/sabio_lab.tscn` e `tests/lab_test.*` |

| Módulo | Dados (`assets/data/lab/`) | Scripts (`src/gameplay/lab/modules/`) |
|---|---|---|
| Água e Molhado | `1_agua.tres` | `water_module`, `lab_puddle`, `lab_wet_status` |
| Teia | `2_teia.tres` | `web_module`, `lab_web` |
| Óleo | `3_oleo.tres` | `oil_module`, `lab_oil` |
| Frio e Gelo | `4_frio.tres` | `frost_module`, `lab_ice` |
| Terra Morta | `5_terra_morta.tres` | `dead_ground_module`, `lab_dead_ground` |
| Incendiário | `6_incendiario.tres` | `arsonist_module`, `lab_arsonist` |
| Lama e fogo | `7_lama_e_fogo.tres` | `mud_fire_module` |
| Reação em cadeia | `8_reacao_em_cadeia.tres` | `chain_reaction_module` |
| Inércia guardada | `9_inercia_guardada.tres` | `stored_inertia_module` |

O módulo aprovado **não deve ficar aqui para sempre**: ele vira GDD e é refeito no sistema definitivo
pela frente dona.

## Ideias que não viraram módulo

- **Ideia 4, drops como ingredientes:** precisa de inimigos que deixem itens e de inventário. A Teia
  simula só o custo.
- **Ideia 6, autoria do dano:** sem XP e sem inimigos que reajam, não há o que avaliar.
- **Eletricidade:** prevista para a fase 4 da tabela. O `conductive` continua reservado.

## Teste automático

Verifica todos os módulos presentes e pula os que tiveram o `.tres` apagado:

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://tests/lab_test.tscn
```

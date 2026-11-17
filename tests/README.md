# Testes

## Teste de fumaça (automático)

Carrega a arena com os magos do Fogo, da Terra e da Gravidade (e a ficha do Psiônico, que é a do bot), usa as habilidades de cada, pega e arremessa
uma caixa, testa fogo, explosão, Dardo Cinético, Campo Lento, Flutuar, Bola de Fogo carregável,
Escada de Pedra, Lamaçal, teto de pulo, degraus, Soco e Chute de Pedra, Terremoto, Jatos de Fogo, Fogo-Fátuo, Chão de Lava, Almôndega de Fogo, Push-Pull, Mibune, Gravidade dos Sonhos, Gravidash, Zona Nula, pegar com E, alvos voadores, impacto por massa e
velocidade e as fórmulas de atributos.
Leva ~1 minuto e não abre janela. O comando é sempre o mesmo, não importa quantas suítes existam.

No terminal, dentro da pasta `Ygg`:

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://tests/smoke_test.tscn
```

Numa cópia de frente (sessão paralela), use `bash tools/frentes.sh teste`, que acha o Godot sozinho.

O fim da saída mostra `=== SMOKE TEST: N verificações, 0 falhas ===` quando tudo passou. Cada
verificação que falha aparece numa linha com `FALHA`, e o programa sai com código 1.

### Como os testes estão organizados

| Arquivo | O que faz |
|---|---|
| `smoke_test.gd` | Executor: acha as suítes, roda uma por vez (em ordem alfabética) e soma o resultado. Não contém testes. |
| `suite_base.gd` | Auxiliares comuns: `_check`, `_frames`, `_load_arena`, `_unload`, `_nearest_crate`, `_first_prop`, `_press_key`, `_walk_toward`, `_peak_until_landing`. |
| `suites/classes.gd` | Frente `classes`: percurso de cada classe, Gravidade, Fogo, Terra, atributos e progressão. |
| `suites/gameplay.gd` | Frente `gameplay`: degraus, rampa, explosões, fogo, pegar e arremessar com E. |
| `suites/monstros.gd` | Frente `monstros`: regras de dano, impacto, boneco de treino e alvos voadores. |

### Como acrescentar testes

**Sua frente já tem suíte:** edite só o arquivo dela em `suites/`.

1. Escreva uma função `_test_alguma_coisa()`.
2. Chame essa função dentro de `run()`. Use `await` se ela esperar quadros do jogo.

```gdscript
func run() -> void:
	await _test_grab_and_throw()
	await _test_alguma_coisa()


func _test_alguma_coisa() -> void:
	print("\n--- Alguma coisa ---")
	var arena := await _load_arena("fire")
	var player: Player = arena.player
	await _frames(10)
	_check(player.is_on_floor(), "jogador no chão")
	await _unload(arena)
```

**Sua frente ainda não tem suíte:** crie `suites/<sua_frente>.gd`. Não é preciso registrar o
arquivo em lugar nenhum: o executor encontra sozinho tudo o que estiver nessa pasta.

```gdscript
extends "res://tests/suite_base.gd"
## Suíte da frente <sua_frente>: o que ela cobre.


func run() -> void:
	_check(true, "troque por uma verificação de verdade")
```

Regras:

- Um auxiliar usado só pela sua suíte fica na sua suíte. Vá para `suite_base.gd` só o que
  várias frentes usam, e esse arquivo é da frente `qualidade`.
- Descreva a verificação no texto do `_check`: é ele que o QA lê quando algo falha.
- Teste que carrega a arena termina com `await _unload(arena)`.
- Não remova nem afrouxe uma verificação para fazer o teste passar. Se o jogo mudou de
  propósito, explique a mudança no commit.
- Suíte que não compila, não estende `suite_base.gd` ou não faz nenhuma verificação conta como falha.
- Qualquer erro de script durante uma suíte (no teste ou no jogo) também conta como falha e mostra
  o arquivo e a linha do erro. O erro pode ter vindo da suíte anterior, se aconteceu logo no fim dela.
- Ao mexer numa suíte, confira se `N` subiu ou ficou igual: o teste não sabe quantas verificações
  deveriam existir, então uma verificação apagada não aparece como falha.

## Capturas de tela (revisão visual)

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" --path . --resolution 1600x900 res://tests/screenshot.tscn -- --scene=res://src/ui/main_menu.tscn --out=C:/temp/menu.png
```

## Abrir a arena direto com uma classe

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" --path . res://src/levels/test_arena.tscn -- --class=fire
```

## Roteiro de playtest manual (QA)

1. Menu → Configurações: mude cada opção, saia e volte. Os valores ficaram salvos?
2. Novo Jogo → cada classe. O texto dos cartões cabe e é claro?
3. Pista de mobilidade: até que degrau cada classe sobe? Qual o maior vão que cada uma cruza?
4. Boneco: compare o impulso de cada habilidade (o boneco mostra "x empurrão humano").
5. Laboratório: incendeie a pirâmide **sem** Bola de Fogo (Terra ou Gravidade + braseiro).
6. Exploda um barril perto da pirâmide. A reação em cadeia é legível?
7. Esc durante o jogo: pausa, configurações e voltar ao menu funcionam?

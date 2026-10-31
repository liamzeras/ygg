# Testes

## Teste de fumaça (automático)

Carrega a arena com o Cavaleiro e o Mago, usa as 3 habilidades de cada, pega e arremessa
uma caixa, testa fogo, explosão e as fórmulas de atributos. Leva ~15 segundos e não abre janela.

No terminal, dentro da pasta `Ygg`:

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://tests/smoke_test.tscn
```

O fim da saída mostra `=== SMOKE TEST: N verificações, 0 falhas ===` quando tudo passou.

## Capturas de tela (revisão visual)

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" --path . --resolution 1600x900 res://tests/screenshot.tscn -- --scene=res://src/ui/main_menu.tscn --out=C:/temp/menu.png
```

## Abrir a arena direto com uma classe

```bash
"./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64.exe" --path . res://src/levels/test_arena.tscn -- --class=mage
```

## Roteiro de playtest manual (QA)

1. Menu → Configurações: mude cada opção, saia e volte. Os valores ficaram salvos?
2. Novo Jogo → cada classe. O texto dos cartões cabe e é claro?
3. Pista de mobilidade: até que degrau cada classe sobe? Qual o maior vão que cada uma cruza?
4. Boneco: compare o impulso de cada habilidade (o boneco mostra "x empurrão humano").
5. Laboratório: incendeie a pirâmide **sem** Bola de Fogo (cavaleiro + braseiro).
6. Exploda um barril perto da pirâmide. A reação em cadeia é legível?
7. Esc durante o jogo: pausa, configurações e voltar ao menu funcionam?

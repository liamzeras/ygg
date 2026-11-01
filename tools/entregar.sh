#!/usr/bin/env bash
# Entrega da conversa principal: roda os testes e, se passarem, faz commit só dos
# arquivos listados e envia para o GitHub. Listar os arquivos evita levar junto o trabalho
# de outras sessões que usam a mesma pasta. Frentes em ramo não usam isto: quem junta é o orquestrador.
#
# Uso: bash tools/entregar.sh "mensagem do commit" arquivo [arquivo...]
set -u

GODOT="./Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
TESTS="res://tests/smoke_test.tscn res://tests/escadas_test.tscn"

if [ "$#" -lt 2 ]; then
	echo "Uso: bash tools/entregar.sh \"mensagem\" arquivo [arquivo...]" >&2
	exit 2
fi
message="$1"
shift

cd "$(git rev-parse --show-toplevel)" || exit 2

branch="$(git branch --show-current)"
if [ "$branch" != "main" ]; then
	echo "Parado: esta entrega é só para a main (ramo atual: $branch)." >&2
	exit 2
fi

for scene in $TESTS; do
	echo "Rodando $scene..."
	output="$(timeout 600 "$GODOT" --headless --path . "$scene" 2>&1)"
	status=$?
	echo "$output" | grep -E "FALHA|==="
	if [ "$status" -ne 0 ] || echo "$output" | grep -qE "SCRIPT ERROR|Parse Error"; then
		echo "$output" | grep -E -A3 "SCRIPT ERROR|Parse Error"
		echo "Parado: $scene falhou (código $status). Nada foi commitado." >&2
		exit 1
	fi
done

git add -- "$@" || exit 1
if git diff --cached --quiet -- "$@"; then
	echo "Nada novo nesses arquivos; sem commit."
else
	git commit -q -m "$message" -- "$@" || exit 1
	git log --oneline -1
fi

if ! git push -q origin main; then
	echo "Parado: o envio foi recusado. O commit ficou só neste computador." >&2
	exit 1
fi
git status -sb | head -1

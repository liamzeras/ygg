#!/bin/bash
# Ferramenta das frentes paralelas do Ygg. Rode "bash tools/frentes.sh" para ver os comandos.

RAIZ="$(git rev-parse --show-toplevel)" || exit 1
DONOS="$RAIZ/.claude/frentes/donos.txt"

# Imprime "<frente> [trava]" do primeiro padrão que casar com o arquivo.
dono_de() {
	local alvo="${1%.uid}"
	alvo="${alvo%.import}"
	local padrao frente trava
	while read -r padrao frente trava; do
		[ -z "$padrao" ] && continue
		case "$padrao" in \#*) continue ;; esac
		# shellcheck disable=SC2254
		case "$alvo" in
			$padrao) echo "$frente $trava"; return 0 ;;
		esac
	done < "$DONOS"
	return 1
}

# Arquivos que o ramo mudou desde que saiu da base, mais o que ainda está sem commit na cópia atual.
arquivos_mudados() {
	local base="$1"
	{
		git diff --name-only "$(git merge-base "$base" HEAD)" HEAD
		git diff --name-only HEAD
		git ls-files --others --exclude-standard
	} | sort -u
}

cmd_dono() {
	local resultado
	if resultado="$(dono_de "$1")"; then echo "$1 -> $resultado"; else echo "$1 -> SEM DONO"; return 1; fi
}

# Confere se todo arquivo do jogo tem dono e mostra quantos cada frente tem.
cmd_verificar() {
	local orfaos=0 arquivo resultado
	local lista
	lista="$(cd "$RAIZ" && git ls-files -co --exclude-standard src assets tests design docs/architecture project.godot CLAUDE.md | grep -vE '\.(uid|import)$')"
	while read -r arquivo; do
		[ -z "$arquivo" ] && continue
		if resultado="$(dono_de "$arquivo")"; then
			echo "${resultado%% *}"
		else
			echo "SEM DONO: $arquivo" >&2
			orfaos=$((orfaos + 1))
		fi
	done <<< "$lista" | sort | uniq -c | sort -rn
	# O laço roda em subshell por causa do pipe, então a contagem final é refeita aqui.
	orfaos=0
	while read -r arquivo; do
		[ -z "$arquivo" ] && continue
		dono_de "$arquivo" > /dev/null || orfaos=$((orfaos + 1))
	done <<< "$lista"
	echo "Arquivos sem dono: $orfaos"
	[ "$orfaos" -eq 0 ]
}

# Lista o que a frente mexeu fora da própria área e quais travas ela tocou.
cmd_fora() {
	local frente="$1" base="${2:-main}" problemas=0 arquivo resultado dono trava
	while read -r arquivo; do
		[ -z "$arquivo" ] && continue
		resultado="$(dono_de "$arquivo")" || { echo "SEM DONO: $arquivo"; problemas=$((problemas + 1)); continue; }
		read -r dono trava <<< "$resultado"
		if [ "$trava" = "trava" ]; then
			echo "TRAVA:    $arquivo (dono: $dono) -> precisa de reserva no quadro"
			problemas=$((problemas + 1))
		elif [ "$dono" != "$frente" ]; then
			echo "FORA:     $arquivo (dono: $dono)"
			problemas=$((problemas + 1))
		fi
	done <<< "$(arquivos_mudados "$base")"
	echo "Avisos da frente $frente: $problemas"
	[ "$problemas" -eq 0 ]
}

# Mostra os arquivos alterados por mais de um ramo ainda não juntado à base.
cmd_colisoes() {
	local base="${1:-main}" ramo
	local repetidos
	repetidos="$(
		for ramo in $(git for-each-ref --format='%(refname)' --no-merged "$base" refs/heads/); do
			git diff --name-only "$(git merge-base "$base" "$ramo")" "$ramo" | sed "s|\$| ${ramo#refs/heads/}|"
		done | sort | awk '{ ramos[$1] = ramos[$1] " " $2; total[$1]++ } END { for (a in total) if (total[a] > 1) print a " ->" ramos[a] }'
	)"
	if [ -z "$repetidos" ]; then
		echo "Nenhuma colisão entre ramos abertos."
		return 0
	fi
	echo "$repetidos"
	return 1
}

# O executável do Godot não vai para o git, então fica só na pasta principal do projeto.
caminho_godot() {
	local principal
	principal="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
	echo "$principal/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
}

# Sem a pasta .godot, ou com o cache de classes mais velho que algum script, o Godot não
# encontra as classes novas e o teste quebra inteiro. Por isso importa de novo nesses casos.
cmd_preparar() {
	local cache="$RAIZ/.godot/global_script_class_cache.cfg"
	if [ -f "$cache" ] && [ -z "$(find "$RAIZ/src" "$RAIZ/tests" -name "*.gd" -newer "$cache" -print -quit)" ]; then
		return 0
	fi
	echo "Importando o projeto nesta cópia..."
	"$(caminho_godot)" --headless --path "$RAIZ" --import > /dev/null 2>&1
	[ -f "$RAIZ/.godot/global_script_class_cache.cfg" ]
}

cmd_teste() {
	cmd_preparar || { echo "Falha ao importar o projeto."; return 1; }
	local saida
	saida="$("$(caminho_godot)" --headless --path "$RAIZ" res://tests/smoke_test.tscn 2>&1)"
	echo "$saida" | grep -E 'FALHA|=== SMOKE TEST'
	# Segunda proteção: o próprio teste já conta erro de script como falha nas suítes.
	if echo "$saida" | grep -qE 'SCRIPT ERROR|Parse Error'; then
		echo "$saida" | grep -E -A3 'SCRIPT ERROR|Parse Error'
		return 1
	fi
	echo "$saida" | grep -qE '=== SMOKE TEST: [0-9]+ verificações, 0 falhas ==='
}

case "$1" in
	dono) cmd_dono "$2" ;;
	verificar) cmd_verificar ;;
	fora) cmd_fora "$2" "$3" ;;
	colisoes) cmd_colisoes "$2" ;;
	preparar) cmd_preparar ;;
	teste) cmd_teste ;;
	*)
		echo "Uso: bash tools/frentes.sh <comando>"
		echo "  dono <arquivo>         diz de qual frente é o arquivo"
		echo "  verificar              confere se todo arquivo do jogo tem dono"
		echo "  fora <frente> [base]   lista o que a frente mexeu fora da área dela"
		echo "  colisoes [base]        lista arquivos alterados por mais de um ramo aberto"
		echo "  preparar               importa o projeto numa cópia nova"
		echo "  teste                  roda o teste de fumaça nesta cópia"
		exit 2
		;;
esac

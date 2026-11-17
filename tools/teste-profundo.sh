#!/bin/bash
# Teste profundo do Ygg (.claude/skills/teste-profundo/SKILL.md). Só roda quando o Liam pede.
#
#   bash tools/teste-profundo.sh medir     abre o jogo com janela e mede os quadros (~2,5 min)
#   bash tools/teste-profundo.sh auditar   revisa código e estrutura de arquivos, sem abrir o jogo
#   bash tools/teste-profundo.sh tudo      os dois
#
# Os resultados ficam em production/perf/ (os .json e .md brutos não vão para o git).

RAIZ="$(git rev-parse --show-toplevel)" || exit 1
cd "$RAIZ" || exit 1
SAIDA="production/perf"
mkdir -p "$SAIDA"
CARIMBO="$(date +%Y%m%d-%H%M)"

# Limites da auditoria. Ajuste aqui, não espalhados pelo script.
MAX_LINHAS_ARQUIVO=400
MAX_LINHAS_FUNCAO=60

acha_godot() {
	local exe
	exe="$(ls "$RAIZ"/Godot_v*/Godot_v*_console.exe 2>/dev/null | head -1)"
	[ -z "$exe" ] && exe="$(ls "$(git worktree list | head -1 | cut -d' ' -f1)"/Godot_v*/Godot_v*_console.exe 2>/dev/null | head -1)"
	echo "$exe"
}

# Quantos processos do Godot estão abertos (jogo, editor ou teste de outra sessão).
godots_abertos() {
	if command -v tasklist > /dev/null 2>&1; then
		tasklist 2>/dev/null | grep -ci '^godot'
	else
		pgrep -ci godot
	fi
}

cmd_medir() {
	local godot abertos codigo
	godot="$(acha_godot)"
	if [ -z "$godot" ]; then
		echo "Godot não encontrado." >&2
		return 1
	fi
	# Medir junto com outro Godot dá número errado e já travou o computador do Liam.
	abertos="$(godots_abertos)"
	if [ "${abertos:-0}" -gt 0 ]; then
		echo "Há $abertos processo(s) do Godot abertos (jogo, editor ou outra sessão). Feche-os e meça de novo." >&2
		return 1
	fi
	echo "Abrindo o jogo com janela para medir os quadros. Não mexa no mouse até fechar (~2,5 min)."
	# Sem --headless: o tempo de quadro só vale com renderização de verdade.
	timeout 300 "$godot" --path . res://tests/perf_test.tscn "$@" 2>&1 | grep -E "===|fase|^[a-z]+ +[0-9]|gravado|SCRIPT ERROR|Parse Error"
	# Código do Godot, não do grep: 1 = medição reprovada; 124 = passou do tempo.
	codigo=${PIPESTATUS[0]}
	[ "$codigo" -eq 124 ] && echo "A medição passou de 5 min e foi interrompida." >&2
	return "$codigo"
}

# Lista arquivos .gd do jogo (sem testes nem ferramentas).
gd_do_jogo() {
	git ls-files 'src/*.gd'
}

cmd_auditar() {
	local relatorio="$SAIDA/auditoria-$CARIMBO.md"
	{
		echo "# Auditoria do teste profundo ($CARIMBO, commit $(git rev-parse --short HEAD))"
		echo
		echo "## 1. Arquivos grandes (mais de $MAX_LINHAS_ARQUIVO linhas)"
		echo
		for f in $(gd_do_jogo); do
			local n
			n=$(wc -l < "$f")
			[ "$n" -gt "$MAX_LINHAS_ARQUIVO" ] && echo "- \`$f\`: $n linhas"
		done
		echo
		echo "## 2. Funções longas (mais de $MAX_LINHAS_FUNCAO linhas)"
		echo
		for f in $(gd_do_jogo); do
			awk -v max="$MAX_LINHAS_FUNCAO" -v arq="$f" '
				function fecha() { if (nome != "" && (NR - inicio) > max) printf "- `%s`: %s (%d linhas)\n", arq, nome, NR - inicio }
				/^(static )?func / { fecha(); nome = $0; sub(/\(.*/, "", nome); sub(/^(static )?func /, "", nome); inicio = NR }
				/^[^\t# ]/ && !/^(static )?func / { fecha(); nome = "" }
				END { NR++; fecha() }
			' "$f"
		done
		echo
		echo "## 3. Tipagem estática faltando"
		echo
		echo "Variáveis sem tipo e funções sem tipo de retorno (regra do CLAUDE.md: GDScript tipado)."
		echo
		grep -nE '^\s*var [a-zA-Z_]+ = ' $(gd_do_jogo) | sed 's/^/- /' | head -40
		grep -nE '^(static )?func [^(]+\(.*\)\s*:' $(gd_do_jogo) | grep -v -- '->' | sed 's/^/- /' | head -40
		echo
		echo "## 4. Custo por quadro"
		echo
		echo "Scripts que rodam todo quadro e fazem buscas caras (grupos, árvore, física). São os primeiros suspeitos de queda de quadros."
		echo
		for f in $(gd_do_jogo); do
			if grep -qE 'func _(physics_)?process' "$f"; then
				local caros
				caros=$(grep -cE 'get_nodes_in_group|find_children|get_overlapping_bodies|intersect_(ray|shape)|get_children\(\)' "$f")
				[ "$caros" -gt 0 ] && echo "- \`$f\`: $caros buscas"
			fi
		done
		echo
		echo "## 5. print() esquecido no código do jogo"
		echo
		grep -nE '^\s*print(_debug)?\(' $(gd_do_jogo) | sed 's/^/- /' | head -30
		echo
		echo "## 6. Scripts sem comentário de documentação no topo"
		echo
		for f in $(gd_do_jogo); do
			head -6 "$f" | grep -q '^##' || echo "- \`$f\`"
		done
		echo
		echo "## 7. Organização das pastas"
		echo
		echo "Dados (.tres) fora de \`assets/\`, scripts fora de \`src/\` e \`tests/\`, e .uid sem o arquivo original."
		echo
		git ls-files '*.tres' | grep -vE '^assets/' | sed 's/^/- dado fora de assets: /'
		git ls-files '*.gd' | grep -vE '^(src|tests)/' | sed 's/^/- script fora de src: /'
		for u in $(git ls-files '*.uid'); do [ -f "${u%.uid}" ] || echo "- .uid órfão: $u"; done
		echo
		echo "## 8. Arquivos sem dono no mapa das frentes"
		echo
		bash tools/frentes.sh verificar 2>&1 | grep -iE 'sem dono' | grep -vE ': 0$' | sed 's/^/- /' | head -20
		echo
		echo "## 9. O que entra no jogo instalado"
		echo
		if [ -f export_presets.cfg ]; then
			echo "Filtros de exportação atuais:"
			grep -E '^(include_filter|exclude_filter)=' export_presets.cfg | sed 's/^/- /'
		else
			echo "**Não existe \`export_presets.cfg\`.** Sem ele, uma exportação levaria tudo o que o Godot enxerga."
		fi
		echo
		echo "Pastas do projeto e se deveriam ir para o jogo instalado:"
		echo
		echo "| Pasta | Tamanho | No instalador? |"
		echo "|---|---|---|"
		for d in $(git ls-files | cut -d/ -f1 | sort -u); do
			[ -d "$d" ] || continue
			local tam dest
			tam=$(du -sh "$d" 2>/dev/null | cut -f1)
			case "$d" in
				src|assets) dest="sim" ;;
				tests|design|production|tools|docs|.claude) dest="**não** (desenvolvimento)" ;;
				*) dest="conferir" ;;
			esac
			echo "| \`$d\` | $tam | $dest |"
		done
		echo
		echo "Dentro de \`src\` e \`assets\`, também ficam fora do instalador: \`src/gameplay/lab\`, \`assets/data/lab\` e \`src/levels/sabio_lab*\` (laboratório do Sábio)."
	} > "$relatorio"
	echo "Auditoria gravada em $relatorio"
	grep -E '^## ' "$relatorio" | while read -r titulo; do
		local secao contagem
		secao="${titulo#\#\# }"
		contagem=$(awk -v t="$titulo" '$0 == t { dentro = 1; next } /^## / { dentro = 0 } dentro && /^- / { n++ } END { print n + 0 }' "$relatorio")
		printf '  %-55s %s itens\n' "$secao" "$contagem"
	done
}

case "${1:-}" in
	medir) shift; cmd_medir "$@" ;;
	auditar) cmd_auditar ;;
	tudo) cmd_auditar; cmd_medir ;;
	*) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' ; exit 2 ;;
esac

vincular_branch() {
  local titulo="$1"
  local branch="$2"
  local num
  num=$(gh issue list --state all --search "\"$titulo\" in:title" --json number,title -q ".[] | select(.title == \"$titulo\") | .number")
  if [ -n "$num" ]; then
    echo "Vinculando branch '$branch' na issue #$num ($titulo)..."
    gh issue develop "$num" --name "$branch" 2>/dev/null || echo "  -> Branch '$branch' ja vinculada ou indisponivel."
  else
    echo "[AVISO] Issue nao encontrada: $titulo"
  fi
}

vincular_branch "Fase 0: pamella-estrutura (Pamella)" "fase-0/pamella-estrutura"
vincular_branch "Fase 0: pamella-manuais (Pamella)" "fase-0/pamella-manuais"
vincular_branch "Fase 1: nauan-casos-teste (Nauan)" "fase-1/nauan-casos-teste"
vincular_branch "Fase 1: cinara-leitura (Cinara)" "fase-1/cinara-leitura"
vincular_branch "Fase 1: leandro-ciclos (Leandro)" "fase-1/leandro-ciclos"
vincular_branch "Fase 1: raony-geometria (Raony)" "fase-1/raony-geometria"
vincular_branch "Fase 2: nicolas-dfs (Nicolas)" "fase-2/nicolas-dfs"
vincular_branch "Fase 3: pamella-desenho (Pamella)" "fase-3/pamella-desenho"
vincular_branch "Fase 3: nauan-gabarito (Nauan)" "fase-3/nauan-gabarito"
vincular_branch "Fase 4: integracao (Pamella)" "fase-4/integracao"
vincular_branch "Fase 5: notebook (Pamella)" "fase-5/notebook"
vincular_branch "Fase 6: pamella-readme (Pamella)" "fase-6/pamella-readme"

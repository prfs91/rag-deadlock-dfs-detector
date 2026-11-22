#!/usr/bin/env bash
# =============================================================================
# configurar_milestones.sh
# Cria os 7 milestones das fases (caso ainda nao existam) e vincula cada
# issue mae e sub-issue correspondente no repositorio.
# =============================================================================
set -euo pipefail

REPO="prfs91/rag-deadlock-dfs-detector"

command -v gh >/dev/null || { echo "ERRO: gh CLI nao encontrado."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: rode primeiro: gh auth login"; exit 1; }

echo "Verificando milestones existentes em $REPO..."
MILESTONES_EXISTENTES=$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq '.[].title')

criar_milestone_se_nao_existir() {
  local titulo="$1"
  local descricao="$2"

  if echo "$MILESTONES_EXISTENTES" | grep -Fxq "$titulo"; then
    echo "  [MANTIDO] Milestone ja existe: $titulo"
  else
    gh api --method POST "repos/$REPO/milestones" \
      -f title="$titulo" \
      -f description="$descricao" >/dev/null
    echo "  [CRIADO] Milestone: $titulo"
  fi
}

echo "Criando milestones das fases..."
criar_milestone_se_nao_existir "Fase 0: Infraestrutura e Manuais" "Configuração inicial do repositório, dependências, ambiente Python e manuais de operação da equipe."
criar_milestone_se_nao_existir "Fase 1: Módulos Base e Casos de Teste" "Desenvolvimento independente dos módulos de leitura, ciclos, geometria anticolisão e criação dos casos de teste T1 a T7."
criar_milestone_se_nao_existir "Fase 2: Motor de Busca em Profundidade (DFS)" "Implementação do algoritmo principal de detecção de impasses e ciclos no grafo de alocação de recursos."
criar_milestone_se_nao_existir "Fase 3: Visualização e Validação de Gabarito" "Geração gráfica dos grafos de alocação e detecção e implementação da suíte de validação automática."
criar_milestone_se_nao_existir "Fase 4: Integração e Interface CLI" "Unificação dos módulos de todos os seis integrantes no integrador principal e criação da execução via linha de comando."
criar_milestone_se_nao_existir "Fase 5: Relatório Técnico e Figuras" "Elaboração do notebook interativo com análise dos cenários e geração das 21 figuras oficiais do projeto."
criar_milestone_se_nao_existir "Fase 6: Documentação Final e Entrega" "Atualização final do README com a arquitetura modular consolidada e revisão geral do repositório."

echo
echo "Carregando issues e sub-issues existentes..."
ISSUES_JSON=$(gh issue list -R "$REPO" --state all --limit 200 --json number,title)

vincular_milestone_por_prefixo() {
  local milestone="$1"
  local regex="$2"

  local numeros
  numeros=$(echo "$ISSUES_JSON" | python3 -c "
import sys, json, re
padrao = re.compile(sys.argv[1])
for item in json.load(sys.stdin):
    if padrao.search(item['title']):
        print(item['number'])
" "$regex")

  if [ -z "$numeros" ]; then
    echo "  [AVISO] Nenhuma issue encontrada para: $milestone"
    return
  fi

  for num in $numeros; do
    gh issue edit "$num" -R "$REPO" --milestone "$milestone" >/dev/null
    echo "  [OK] Issue #$num vinculada a '$milestone'"
  done
}

echo
echo "Vinculando issues e sub-issues aos milestones..."
vincular_milestone_por_prefixo "Fase 0: Infraestrutura e Manuais" "^(Fase 0:|Passo 0\.)"
vincular_milestone_por_prefixo "Fase 1: Módulos Base e Casos de Teste" "^(Fase 1:|Passo 1\.)"
vincular_milestone_por_prefixo "Fase 2: Motor de Busca em Profundidade (DFS)" "^(Fase 2:|Passo 2\.)"
vincular_milestone_por_prefixo "Fase 3: Visualização e Validação de Gabarito" "^(Fase 3:|Passo 3\.)"
vincular_milestone_por_prefixo "Fase 4: Integração e Interface CLI" "^(Fase 4:|Passo 4\.)"
vincular_milestone_por_prefixo "Fase 5: Relatório Técnico e Figuras" "^(Fase 5:|Passo 5\.)"
vincular_milestone_por_prefixo "Fase 6: Documentação Final e Entrega" "^(Fase 6:|Passo 6\.)"

echo
echo "Concluido! Todos os milestones foram criados e vinculados."

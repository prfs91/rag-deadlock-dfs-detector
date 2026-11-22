# 1. Cria ou atualiza as labels personalizadas no repositorio
gh label create "feat" --color "0e8a16" --description "Nova funcionalidade, algoritmo, interface visual ou modulo de codigo" --force
gh label create "test" --color "fbca04" --description "Casos de teste, validacao de gabarito e verificacao de cenarios" --force
gh label create "chore" --color "cfd3d7" --description "Configuracao de ambiente, dependencias, estrutura e arquivos auxiliares" --force
gh label create "refactor" --color "1d76db" --description "Reestruturacao, modularizacao ou melhoria interna de codigo existente" --force

# 2. Carrega todas as issues e sub-issues existentes de uma so vez (rapido)
ISSUES_JSON=$(gh issue list --state all --limit 200 --json number,title)

aplicar_label() {
  local titulo="$1"
  local labels="$2"
  local num
  num=$(echo "$ISSUES_JSON" | python3 -c "
import sys, json
for i in json.load(sys.stdin):
    if i['title'] == sys.argv[1]:
        print(i['number'])
        break
" "$titulo")

  if [ -n "$num" ]; then
    gh issue edit "$num" --add-label "$labels" >/dev/null
    echo "[OK] #$num ($titulo) -> [$labels]"
  else
    echo "[PULADA] Ainda nao criada: $titulo"
  fi
}

echo "Aplicando labels nas issues e sub-issues..."

# --- FASE 0 ---
aplicar_label "Fase 0: pamella-estrutura (Pamella)" "chore,feat"
aplicar_label "Passo 0.1: requirements.txt" "chore,good first issue"
aplicar_label "Passo 0.2: src/__init__.py" "chore,good first issue"
aplicar_label "Passo 0.3: etapa1 (imports e caminhos)" "feat"
aplicar_label "Passo 0.4: etapa1 (paleta de cores)" "feat"

aplicar_label "Fase 0: pamella-manuais (Pamella)" "documentation"
aplicar_label "Passo 0.5: docs/MANUAL_CLONAGEM_LINUX.md" "documentation"
aplicar_label "Passo 0.6: docs/MANUAL_CLONAGEM_WINDOWS11.md" "documentation"
aplicar_label "Passo 0.7: docs/MANUAL_AMBIENTE_E_EXECUCAO.md" "documentation"
aplicar_label "Passo 0.8: docs/MANUAL_PULL_REQUEST_EQUIPE.md" "documentation"
aplicar_label "Passo 0.9: docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md" "documentation"
aplicar_label "Passo 0.10: PLANO_DE_BRANCHES.md e MAPA_DE_TRECHOS.md" "documentation"

# --- FASE 1 ---
aplicar_label "Fase 1: nauan-casos-teste (Nauan)" "test"
aplicar_label "Passo 1.N1: tests/caso_slide40_multiplos_nos.txt" "test,good first issue"
aplicar_label "Passo 1.N2: tests/caso_grafo1_concorrente_seguro.txt" "test,good first issue"
aplicar_label "Passo 1.N3: tests/caso_grafo2_espera_circular.txt" "test,good first issue"
aplicar_label "Passo 1.N4: tests/caso_extra_multiplos_ciclos.txt" "test"
aplicar_label "Passo 1.N5: tests/caso_ciclo_com_processo_em_espera.txt" "test"
aplicar_label "Passo 1.N6: tests/caso_cadeia_sem_ciclo.txt" "test"
aplicar_label "Passo 1.N7: tests/caso_dois_impasses_com_ramo_livre.txt" "test"

aplicar_label "Fase 1: cinara-leitura (Cinara)" "feat"
aplicar_label "Passo 1.C1: etapa2 (cabeçalho e assinatura)" "feat"
aplicar_label "Passo 1.C2: etapa2 (laço de leitura)" "feat"
aplicar_label "Passo 1.C3: etapa2 (disjunção e adjacência)" "feat"
aplicar_label "Passo 1.C4: etapa2 (bipartição e instância única)" "feat"

aplicar_label "Fase 1: leandro-ciclos (Leandro)" "feat"
aplicar_label "Passo 1.L1: etapa4 (isolar_ciclo_elementar)" "feat"
aplicar_label "Passo 1.L2: etapa4 (normalizar_ciclo)" "feat"
aplicar_label "Passo 1.L3: etapa4 (formatar_resultado)" "feat"

aplicar_label "Fase 1: raony-geometria (Raony)" "feat"
aplicar_label "Passo 1.R1: etapa5 (distancia_ponto_segmento)" "feat"
aplicar_label "Passo 1.R2: etapa5 (constantes e primitivas)" "feat"
aplicar_label "Passo 1.R3: etapa5 (conflito entre segmentos)" "feat"
aplicar_label "Passo 1.R4: etapa5 (rotas candidatas)" "feat"
aplicar_label "Passo 1.R5: etapa5 (avaliação e roteamento)" "feat"
aplicar_label "Passo 1.R6: etapa5 (custo e construção gulosa)" "feat"
aplicar_label "Passo 1.R7: etapa5 (otimização)" "feat"
aplicar_label "Passo 1.R8: etapa5 (ciclos disjuntos)" "feat"
aplicar_label "Passo 1.R9: etapa5 (calcular_layout_e_rotas)" "feat"
aplicar_label "Passo 1.R10: etapa5 (auditoria)" "feat"

# --- FASE 2 ---
aplicar_label "Fase 2: nicolas-dfs (Nicolas)" "feat"
aplicar_label "Passo 2.1: etapa3 (estrutura)" "feat"
aplicar_label "Passo 2.2: etapa3 (detecção do ciclo)" "feat"
aplicar_label "Passo 2.3: etapa3 (avanço e marcação)" "feat"
aplicar_label "Passo 2.4: etapa3 (retrocesso e raízes)" "feat"

# --- FASE 3 ---
aplicar_label "Fase 3: pamella-desenho (Pamella)" "feat"
aplicar_label "Passo 3.P1: etapa1 (recorte e seta)" "feat"
aplicar_label "Passo 3.P2: etapa1 (nós e tela)" "feat"
aplicar_label "Passo 3.P3: etapa1 (grafo de alocação)" "feat"
aplicar_label "Passo 3.P4: etapa1 (grafo da detecção)" "feat"
aplicar_label "Passo 3.P5: etapa1 (cartão)" "feat"

aplicar_label "Fase 3: nauan-gabarito (Nauan)" "test"
aplicar_label "Passo 3.N1: etapa6 (casos oficiais)" "test"
aplicar_label "Passo 3.N2: etapa6 (validar_gabarito_caso)" "test"

# --- FASE 4 ---
aplicar_label "Fase 4: integracao (Pamella)" "feat,refactor"
aplicar_label "Passo 4.1: detector_integrado_equipe.py (imports)" "feat,refactor"
aplicar_label "Passo 4.2: detector_integrado_equipe.py (nome das figuras e geração)" "feat"
aplicar_label "Passo 4.3: detector_integrado_equipe.py (executar_analise_completa_caso)" "feat"
aplicar_label "Passo 4.4: detector_integrado_equipe.py (bateria completa)" "feat"
aplicar_label "Passo 4.5: main.py (argumentos)" "feat"
aplicar_label "Passo 4.6: main.py (execução)" "feat"

# --- FASE 5 ---
aplicar_label "Fase 5: notebook (Pamella)" "documentation"
aplicar_label "Passo 5.1: notebook (células 0–3)" "documentation"
aplicar_label "Passo 5.2: notebook (células 4–5)" "documentation"
aplicar_label "Passo 5.3: notebook (células 6–11)" "documentation"
aplicar_label "Passo 5.4: notebook (células 12–13)" "documentation"
aplicar_label "Passo 5.5: notebook (células 14–15)" "documentation"
aplicar_label "Passo 5.6: output/figures/ (21 PNG)" "chore,documentation"

# --- FASE 6 ---
aplicar_label "Fase 6: pamella-readme (Pamella)" "documentation"
aplicar_label "Passo 6.1: README.md" "documentation"

echo "Concluido!"

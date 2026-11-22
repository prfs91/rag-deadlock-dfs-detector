#!/usr/bin/env bash
# =============================================================================
# criar_subissues.sh
# Cria as 58 sub-issues do plano de reconstrucao e vincula cada uma a sua
# issue mae correspondente no repositorio prfs91/rag-deadlock-dfs-detector.
# =============================================================================
set -euo pipefail

REPO="prfs91/rag-deadlock-dfs-detector"

# --- 1) Usuarios do GitHub (preencha se ja tiverem aceitado o convite) ------
GH_PAMELLA="prfs91"
#GH_RAONY=""
#GH_NAUAN=""
#GH_NICOLAS=""
#GH_LEANDRO=""
#GH_CINARA=""

# --- 2) Verificacoes --------------------------------------------------------
command -v gh >/dev/null || { echo "ERRO: gh CLI nao encontrado."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: rode primeiro: gh auth login"; exit 1; }

echo "Carregando issues existentes em $REPO..."
ISSUES_JSON=$(gh issue list -R "$REPO" --state all --limit 200 --json number,title,id)

# Funcao auxiliar: encontra o numero da issue mae pelo titulo exato
obter_num_pai() {
  local titulo_pai="$1"
  echo "$ISSUES_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data:
    if item['title'] == sys.argv[1]:
        print(item['number'])
        break
" "$titulo_pai"
}

# Funcao auxiliar: verifica se uma sub-issue com esse titulo ja existe
issue_ja_existe() {
  local titulo="$1"
  echo "$ISSUES_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print('1' if any(i['title'] == sys.argv[1] for i in data) else '0')
" "$titulo"
}

# Cria a sub-issue e vincula a issue mae via API REST do GitHub
criar_subissue() {
  local titulo_pai="$1"
  local titulo_sub="$2"
  local responsavel="$3"
  local corpo="$4"

  local num_pai
  num_pai=$(obter_num_pai "$titulo_pai")

  if [ -z "$num_pai" ]; then
    echo "  [AVISO] Issue mae nao encontrada: '$titulo_pai'. Pulando '$titulo_sub'."
    return
  fi

  if [ "$(issue_ja_existe "$titulo_sub")" = "1" ]; then
    echo "  [MANTIDA] Sub-issue ja existe: $titulo_sub"
    return
  fi

  local arquivo_corpo
  arquivo_corpo=$(mktemp)
  printf "%s\n" "$corpo" > "$arquivo_corpo"

  local url_nova
  if [ -n "$responsavel" ]; then
    url_nova=$(gh issue create -R "$REPO" --title "$titulo_sub" --assignee "$responsavel" --body-file "$arquivo_corpo")
  else
    url_nova=$(gh issue create -R "$REPO" --title "$titulo_sub" --body-file "$arquivo_corpo")
  fi
  rm -f "$arquivo_corpo"

  local num_sub
  num_sub=$(basename "$url_nova")

  # Busca o ID numerico interno da sub-issue (exigido pelo endpoint /sub_issues)
  local id_interno_sub
  id_interno_sub=$(gh api "repos/$REPO/issues/$num_sub" --jq '.id')

  # Vincula a sub-issue na issue mae
  gh api --method POST "repos/$REPO/issues/$num_pai/sub_issues" \
    -F "sub_issue_id=$id_interno_sub" >/dev/null

  echo "  [OK] #$num_sub vinculada a #$num_pai -> $titulo_sub"
}

echo "Criando e vinculando sub-issues..."

# ============================================================================
# FASE 0: pamella-estrutura
# ============================================================================
PAI="Fase 0: pamella-estrutura (Pamella)"
criar_subissue "$PAI" "Passo 0.1: requirements.txt" "$GH_PAMELLA" \
"**Arquivo:** \`requirements.txt\`
**Commit:** \`chore(infra): adiciona requirements.txt\`
Declara as dependências do projeto: \`matplotlib\`, \`ipython\` e \`jupyter\` (sem \`networkx\`)."

criar_subissue "$PAI" "Passo 0.2: src/__init__.py" "$GH_PAMELLA" \
"**Arquivo:** \`src/__init__.py\`
**Commit:** \`chore(infra): cria o pacote src\`
Cria \`src/__init__.py\` com o cabeçalho de identificação do projeto."

criar_subissue "$PAI" "Passo 0.3: etapa1 (imports e caminhos)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 13–46)
**Commit:** \`feat(etapa1): imports base e resolução portável de diretórios\`
Implementa \`obter_caminhos_portaveis_repositorio()\` e as constantes \`DIRETORIO_RAIZ\`, \`PASTA_TESTES\` e \`PASTA_FIGURAS\`."

criar_subissue "$PAI" "Passo 0.4: etapa1 (paleta de cores)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 52–60)
**Commit:** \`feat(etapa1): paleta de cores dos grafos\`
Define as constantes de cores dos nós, arestas e medidas (\`DPI_FIGURAS\`, \`RAIO_CIRCULO_PROCESSO\`, \`MEIO_LADO_QUADRADO\`)."

# ============================================================================
# FASE 0: pamella-manuais
# ============================================================================
PAI="Fase 0: pamella-manuais (Pamella)"
criar_subissue "$PAI" "Passo 0.5: docs/MANUAL_CLONAGEM_LINUX.md" "$GH_PAMELLA" \
"**Arquivo:** \`docs/MANUAL_CLONAGEM_LINUX.md\`
**Commit:** \`docs(manuais): adiciona o manual de clonagem no Linux\`
Guia de clonagem no Linux ajustado para o repositório \`rag-deadlock-dfs-detector\`."

criar_subissue "$PAI" "Passo 0.6: docs/MANUAL_CLONAGEM_WINDOWS11.md" "$GH_PAMELLA" \
"**Arquivo:** \`docs/MANUAL_CLONAGEM_WINDOWS11.md\`
**Commit:** \`docs(manuais): adiciona o manual de clonagem no Windows 11\`
Guia de clonagem no Windows 11 ajustado para o repositório \`rag-deadlock-dfs-detector\`."

criar_subissue "$PAI" "Passo 0.7: docs/MANUAL_AMBIENTE_E_EXECUCAO.md" "$GH_PAMELLA" \
"**Arquivo:** \`docs/MANUAL_AMBIENTE_E_EXECUCAO.md\`
**Commit:** \`docs(manuais): adiciona o manual de ambiente Python e execução\`
Passo a passo de criação de \`venv\`, instalação de dependências e execução."

criar_subissue "$PAI" "Passo 0.8: docs/MANUAL_PULL_REQUEST_EQUIPE.md" "$GH_PAMELLA" \
"**Arquivo:** \`docs/MANUAL_PULL_REQUEST_EQUIPE.md\`
**Commit:** \`docs(manuais): adiciona o manual de branches e Pull Requests\`
Fluxo de branches (\`fase-N/integrante-assunto\`) e abertura de Pull Requests."

criar_subissue "$PAI" "Passo 0.9: docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md" "$GH_PAMELLA" \
"**Arquivo:** \`docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md\`
**Commit:** \`docs(manuais): adiciona o manual de sincronização e resolução de conflitos no Git\`
Sincronização com \`git merge origin/main\` e resolução de conflitos."

criar_subissue "$PAI" "Passo 0.10: PLANO_DE_BRANCHES.md e MAPA_DE_TRECHOS.md" "$GH_PAMELLA" \
"**Arquivos:** \`docs/PLANO_DE_BRANCHES.md\` e \`docs/MAPA_DE_TRECHOS.md\`
**Commit:** \`docs(planejamento): adiciona o plano de branches e o mapa de trechos\`
Documentação oficial do planejamento e mapa de linhas da reconstrução."

# ============================================================================
# FASE 1: nauan-casos-teste
# ============================================================================
# PAI="Fase 1: nauan-casos-teste (Nauan)"
# criar_subissue "$PAI" "Passo 1.N1: tests/caso_slide40_multiplos_nos.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_slide40_multiplos_nos.txt\`
# **Commit:** \`test(casos): padroniza o cabeçalho do T1 - grafo do Slide 40\`"

# criar_subissue "$PAI" "Passo 1.N2: tests/caso_grafo1_concorrente_seguro.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_grafo1_concorrente_seguro.txt\`
# **Commit:** \`test(casos): atualiza o T2 para o Grafo 1 do enunciado do Trabalho 2\`"

# criar_subissue "$PAI" "Passo 1.N3: tests/caso_grafo2_espera_circular.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_grafo2_espera_circular.txt\`
# **Commit:** \`test(casos): atualiza o T3 para o Grafo 2 do enunciado do Trabalho 2\`"

# criar_subissue "$PAI" "Passo 1.N4: tests/caso_extra_multiplos_ciclos.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_extra_multiplos_ciclos.txt\`
# **Commit:** \`test(casos): adiciona T4 - dois ciclos disjuntos simultâneos\`"

# criar_subissue "$PAI" "Passo 1.N5: tests/caso_ciclo_com_processo_em_espera.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_ciclo_com_processo_em_espera.txt\`
# **Commit:** \`test(casos): adiciona T5 - ciclo com processo esperando de fora\`"

# criar_subissue "$PAI" "Passo 1.N6: tests/caso_cadeia_sem_ciclo.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_cadeia_sem_ciclo.txt\`
# **Commit:** \`test(casos): adiciona T6 - cadeia longa de espera sem deadlock\`"

# criar_subissue "$PAI" "Passo 1.N7: tests/caso_dois_impasses_com_ramo_livre.txt" "$GH_NAUAN" \
# "**Arquivo:** \`tests/caso_dois_impasses_com_ramo_livre.txt\`
# **Commit:** \`test(casos): adiciona T7 - dois impasses com ramo livre\`"

# ============================================================================
# FASE 1: cinara-leitura
# ============================================================================
# PAI="Fase 1: cinara-leitura (Cinara)"
# criar_subissue "$PAI" "Passo 1.C1: etapa2 (cabeçalho e assinatura)" "$GH_CINARA" \
# "**Arquivo:** \`src/etapa2_leitura_validacao_cinara.py\` (linhas 1–30)
# **Commit:** \`feat(etapa2): cria o módulo de leitura e a assinatura de carregar_e_validar_grafo\`"

# criar_subissue "$PAI" "Passo 1.C2: etapa2 (laço de leitura)" "$GH_CINARA" \
# "**Arquivo:** \`src/etapa2_leitura_validacao_cinara.py\` (linhas 31–50)
# **Commit:** \`feat(etapa2): leitura dos cabeçalhos PROCESSOS, RECURSOS e ARESTAS\`"

# criar_subissue "$PAI" "Passo 1.C3: etapa2 (disjunção e adjacência)" "$GH_CINARA" \
# "**Arquivo:** \`src/etapa2_leitura_validacao_cinara.py\` (linhas 51–59)
# **Commit:** \`feat(etapa2): valida conjuntos disjuntos e monta a adjacência\`"

# criar_subissue "$PAI" "Passo 1.C4: etapa2 (bipartição e instância única)" "$GH_CINARA" \
# "**Arquivo:** \`src/etapa2_leitura_validacao_cinara.py\` (linhas 61–76)
# **Commit:** \`feat(etapa2): valida bipartição e instância única de recurso\`"

# ============================================================================
# FASE 1: leandro-ciclos
# ============================================================================
# PAI="Fase 1: leandro-ciclos (Leandro)"
# criar_subissue "$PAI" "Passo 1.L1: etapa4 (isolar_ciclo_elementar)" "$GH_LEANDRO" \
# "**Arquivo:** \`src/etapa4_ciclos_e_saida_leandro.py\` (linhas 1–29)
# **Commit:** \`feat(etapa4): cria o módulo de ciclos com isolar_ciclo_elementar\`"

# criar_subissue "$PAI" "Passo 1.L2: etapa4 (normalizar_ciclo)" "$GH_LEANDRO" \
# "**Arquivo:** \`src/etapa4_ciclos_e_saida_leandro.py\` (linhas 32–41)
# **Commit:** \`feat(etapa4): normalizar_ciclo para evitar ciclos duplicados\`"

# criar_subissue "$PAI" "Passo 1.L3: etapa4 (formatar_resultado)" "$GH_LEANDRO" \
# "**Arquivo:** \`src/etapa4_ciclos_e_saida_leandro.py\` (linhas 44–57)
# **Commit:** \`feat(etapa4): formatar_resultado com a saída oficial do trabalho\`"

# ============================================================================
# FASE 1: raony-geometria
# ============================================================================
# PAI="Fase 1: raony-geometria (Raony)"
# criar_subissue "$PAI" "Passo 1.R1: etapa5 (distancia_ponto_segmento)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 1–32)
# **Commit:** \`feat(etapa5): cria o módulo geométrico com distancia_ponto_segmento\`"

# criar_subissue "$PAI" "Passo 1.R2: etapa5 (constantes e primitivas)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 141–161)
# **Commit:** \`feat(etapa5): constantes da grade e primitivas geométricas\`"

# criar_subissue "$PAI" "Passo 1.R3: etapa5 (conflito entre segmentos)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 163–195)
# **Commit:** \`feat(etapa5): detecção de conflito entre segmentos\`"

# criar_subissue "$PAI" "Passo 1.R4: etapa5 (rotas candidatas)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 198–225)
# **Commit:** \`feat(etapa5): rotas ortogonais candidatas\`"

# criar_subissue "$PAI" "Passo 1.R5: etapa5 (avaliação e roteamento)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 227–286)
# **Commit:** \`feat(etapa5): avaliação de rota e roteamento das setas na grade\`"

# criar_subissue "$PAI" "Passo 1.R6: etapa5 (custo e construção gulosa)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 289–323)
# **Commit:** \`feat(etapa5): custo da disposição e construção gulosa\`"

# criar_subissue "$PAI" "Passo 1.R7: etapa5 (otimização)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 325–381)
# **Commit:** \`feat(etapa5): otimização por recozimento simulado e descida exaustiva\`"

# criar_subissue "$PAI" "Passo 1.R8: etapa5 (ciclos disjuntos)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 383–409)
# **Commit:** \`feat(etapa5): círculo trigonométrico para ciclos disjuntos\`"

# criar_subissue "$PAI" "Passo 1.R9: etapa5 (calcular_layout_e_rotas)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 411–462)
# **Commit:** \`feat(etapa5): calcular_layout_e_rotas, ponto de entrada do motor\`"

# criar_subissue "$PAI" "Passo 1.R10: etapa5 (auditoria)" "$GH_RAONY" \
# "**Arquivo:** \`src/etapa5_geometria_anticolisao_raony.py\` (linhas 465–495)
# **Commit:** \`feat(etapa5): auditoria contar_colisoes_desenho\`"

# ============================================================================
# FASE 2: nicolas-dfs
# ============================================================================
# PAI="Fase 2: nicolas-dfs (Nicolas)"
# criar_subissue "$PAI" "Passo 2.1: etapa3 (estrutura)" "$GH_NICOLAS" \
# "**Arquivo:** \`src/etapa3_motor_dfs_nicolas.py\` (linhas 1–34)
# **Commit:** \`feat(etapa3): cria o motor DFS e a estrutura de detectar_impasses_dfs\`"

# criar_subissue "$PAI" "Passo 2.2: etapa3 (detecção do ciclo)" "$GH_NICOLAS" \
# "**Arquivo:** \`src/etapa3_motor_dfs_nicolas.py\` (linhas 36–51)
# **Commit:** \`feat(etapa3): detecção do ciclo na lista L\`"

# criar_subissue "$PAI" "Passo 2.3: etapa3 (avanço e marcação)" "$GH_NICOLAS" \
# "**Arquivo:** \`src/etapa3_motor_dfs_nicolas.py\` (linhas 53–63)
# **Commit:** \`feat(etapa3): avanço e marcação de arcos inspecionados\`"

# criar_subissue "$PAI" "Passo 2.4: etapa3 (retrocesso e raízes)" "$GH_NICOLAS" \
# "**Arquivo:** \`src/etapa3_motor_dfs_nicolas.py\` (linhas 65–75)
# **Commit:** \`feat(etapa3): retrocesso em beco sem saída e laço sobre todas as raízes\`"

# ============================================================================
# FASE 3: pamella-desenho
# ============================================================================
PAI="Fase 3: pamella-desenho (Pamella)"
criar_subissue "$PAI" "Passo 3.P1: etapa1 (recorte e seta)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 74–137)
**Commit:** \`feat(etapa1): recorte da seta na borda do nó e desenho sobre a rota\`"

criar_subissue "$PAI" "Passo 3.P2: etapa1 (nós e tela)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 139–183)
**Commit:** \`feat(etapa1): desenho dos nós e tela comum aos dois grafos\`"

criar_subissue "$PAI" "Passo 3.P3: etapa1 (grafo de alocação)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 185–220)
**Commit:** \`feat(etapa1): imagem do grafo de alocação de recursos\`"

criar_subissue "$PAI" "Passo 3.P4: etapa1 (grafo da detecção)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 222–273)
**Commit:** \`feat(etapa1): imagem do resultado da busca em profundidade\`"

criar_subissue "$PAI" "Passo 3.P5: etapa1 (cartão)" "$GH_PAMELLA" \
"**Arquivo:** \`src/etapa1_infra_e_estilo_visual_pamella.py\` (linhas 275–386)
**Commit:** \`feat(etapa1): explicação dinâmica do resultado e cartão do caso\`"

# ============================================================================
# FASE 3: nauan-gabarito
# ============================================================================
# PAI="Fase 3: nauan-gabarito (Nauan)"
# criar_subissue "$PAI" "Passo 3.N1: etapa6 (casos oficiais)" "$GH_NAUAN" \
# "**Arquivo:** \`src/etapa6_testes_validacao_nauan.py\` (linhas 1–43)
# **Commit:** \`test(etapa6): cria o módulo de validação com a lista dos casos oficiais\`"

# criar_subissue "$PAI" "Passo 3.N2: etapa6 (validar_gabarito_caso)" "$GH_NAUAN" \
# "**Arquivo:** \`src/etapa6_testes_validacao_nauan.py\` (linhas 45–58)
# **Commit:** \`test(etapa6): validar_gabarito_caso\`"

# ============================================================================
# FASE 4: integracao
# ============================================================================
PAI="Fase 4: integracao (Pamella)"
criar_subissue "$PAI" "Passo 4.1: detector_integrado_equipe.py (imports)" "$GH_PAMELLA" \
"**Arquivo:** \`src/detector_integrado_equipe.py\` (linhas 1–54)
**Commit:** \`feat(integracao): cria o integrador e importa os módulos dos 6 integrantes\`"

criar_subissue "$PAI" "Passo 4.2: detector_integrado_equipe.py (nome das figuras e geração)" "$GH_PAMELLA" \
"**Arquivo:** \`src/detector_integrado_equipe.py\` (linhas 56–118)
**Commit:** \`feat(integracao): nome descritivo das figuras e geração das três imagens\`"

criar_subissue "$PAI" "Passo 4.3: detector_integrado_equipe.py (executar_analise_completa_caso)" "$GH_PAMELLA" \
"**Arquivo:** \`src/detector_integrado_equipe.py\` (linhas 87–139)
**Commit:** \`feat(integracao): executar_analise_completa_caso\`"

criar_subissue "$PAI" "Passo 4.4: detector_integrado_equipe.py (bateria completa)" "$GH_PAMELLA" \
"**Arquivo:** \`src/detector_integrado_equipe.py\` (linhas 142–169)
**Commit:** \`feat(integracao): bateria completa de testes\`"

criar_subissue "$PAI" "Passo 4.5: main.py (argumentos)" "$GH_PAMELLA" \
"**Arquivo:** \`main.py\` (linhas 1–48)
**Commit:** \`feat(cli): cria o main.py com argparse\`"

criar_subissue "$PAI" "Passo 4.6: main.py (execução)" "$GH_PAMELLA" \
"**Arquivo:** \`main.py\` (linhas 49–73)
**Commit:** \`feat(cli): modo de arquivo único e bateria completa\`"

# ============================================================================
# FASE 5: notebook
# ============================================================================
PAI="Fase 5: notebook (Pamella)"
criar_subissue "$PAI" "Passo 5.1: notebook (células 0–3)" "$GH_PAMELLA" \
"**Arquivo:** \`relatorio_analise_impasses_rag.ipynb\` (células 0–3)
**Commit:** \`docs(notebook): apresentação, enunciado, cores e imports\`"

criar_subissue "$PAI" "Passo 5.2: notebook (células 4–5)" "$GH_PAMELLA" \
"**Arquivo:** \`relatorio_analise_impasses_rag.ipynb\` (células 4–5)
**Commit:** \`docs(notebook): demonstração encadeada das etapas 2 a 5\`"

criar_subissue "$PAI" "Passo 5.3: notebook (células 6–11)" "$GH_PAMELLA" \
"**Arquivo:** \`relatorio_analise_impasses_rag.ipynb\` (células 6–11)
**Commit:** \`docs(notebook): execução dos casos obrigatórios T1, T2 e T3\`"

criar_subissue "$PAI" "Passo 5.4: notebook (células 12–13)" "$GH_PAMELLA" \
"**Arquivo:** \`relatorio_analise_impasses_rag.ipynb\` (células 12–13)
**Commit:** \`docs(notebook): execução dos casos opcionais T4 a T7 em laço\`"

criar_subissue "$PAI" "Passo 5.5: notebook (células 14–15)" "$GH_PAMELLA" \
"**Arquivo:** \`relatorio_analise_impasses_rag.ipynb\` (células 14–15)
**Commit:** \`docs(notebook): validação automática do gabarito\`"

criar_subissue "$PAI" "Passo 5.6: output/figures/ (21 PNG)" "$GH_PAMELLA" \
"**Arquivos:** \`output/figures/*.png\`
**Commit:** \`chore(figuras): adiciona as 21 figuras geradas pela execução\`"

# ============================================================================
# FASE 6: pamella-readme
# ============================================================================
PAI="Fase 6: pamella-readme (Pamella)"
criar_subissue "$PAI" "Passo 6.1: README.md" "$GH_PAMELLA" \
"**Arquivo:** \`README.md\`
**Commit:** \`docs: reescreve o README para a arquitetura modular final\`"

echo
echo "Concluido! Atualize a pagina de Issues no GitHub para ver as barras de progresso."

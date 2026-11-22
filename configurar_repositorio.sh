#!/usr/bin/env bash
# =============================================================================
# configurar_repositorio.sh
# Script unico e idempotente que deixa o repositorio prfs91/rag-deadlock-dfs-detector
# inteiramente configurado para a equipe:
#   1. labels personalizadas;
#   2. os 7 milestones das fases;
#   3. as 12 branches de trabalho (a partir da main);
#   4. as 12 issues-mae, com o briefing completo de cada etapa;
#   5. as 58 sub-issues (uma por passo/commit), vinculadas as issues-mae;
#   6. labels, milestone e responsavel em tudo.
#
# Nao duplica nada: o que ja existe e ATUALIZADO, nao recriado.
# Nao altera a main e nao envia codigo do projeto.
# Quem ainda nao aceitou o convite de colaborador fica SEM atribuicao,
# e todo o resto (branch, issue, label, milestone) e criado normalmente.
#
# COMO USAR:
#   1. gh auth login                  (autenticar como dona do repositorio)
#   2. git clone https://github.com/prfs91/rag-deadlock-dfs-detector.git
#   3. cd rag-deadlock-dfs-detector   (rodar aqui, na branch main)
#   4. bash configurar_repositorio.sh
# =============================================================================
set -euo pipefail
REPO="prfs91/rag-deadlock-dfs-detector"

# --- 1) Usuarios do GitHub de cada integrante -------------------------------
#     Deixe vazio ("") quem ainda nao tem conta informada.
GH_PAMELLA="prfs91"
GH_RAONY="rahoneeeh"
GH_NAUAN="Nauanx1"
GH_NICOLAS="Nico885-svg"
GH_LEANDRO="Vitorioln"
GH_CINARA="ciinara"

# --- 2) Verificacoes --------------------------------------------------------
command -v git >/dev/null || { echo "ERRO: git nao encontrado."; exit 1; }
command -v gh  >/dev/null || { echo "ERRO: GitHub CLI (gh) nao encontrado: https://cli.github.com"; exit 1; }
command -v python3 >/dev/null || { echo "ERRO: python3 nao encontrado."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: rode primeiro: gh auth login"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "ERRO: rode dentro do clone de $REPO."; exit 1; }
git remote get-url origin | grep -q "rag-deadlock-dfs-detector" || { echo "ERRO: este clone nao aponta para $REPO."; exit 1; }
[ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] || { echo "ERRO: mude para a main: git switch main"; exit 1; }
git fetch -q origin main
echo "Repositorio: $REPO"

# --- 3) Quem pode ser atribuido --------------------------------------------
pode_atribuir() {   # $1 = login; vazio ou nao-colaborador => nao atribui
  [ -n "$1" ] || return 1
  gh api "repos/$REPO/assignees/$1" --silent >/dev/null 2>&1
}
resolver_responsavel() {   # imprime o login se ele puder ser atribuido
  if pode_atribuir "$1"; then echo "$1"; else echo ""; fi
}
echo "Conferindo quem ja aceitou o convite de colaborador..."
RESP_PAMELLA=$(resolver_responsavel "$GH_PAMELLA")
if [ -n "$RESP_PAMELLA" ]; then echo "  Pamella: $RESP_PAMELLA (sera atribuido)"; elif [ -n "$GH_PAMELLA" ]; then echo "  Pamella: $GH_PAMELLA ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Pamella: usuario nao informado - issues ficarao sem responsavel"; fi
RESP_RAONY=$(resolver_responsavel "$GH_RAONY")
if [ -n "$RESP_RAONY" ]; then echo "  Raony: $RESP_RAONY (sera atribuido)"; elif [ -n "$GH_RAONY" ]; then echo "  Raony: $GH_RAONY ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Raony: usuario nao informado - issues ficarao sem responsavel"; fi
RESP_NAUAN=$(resolver_responsavel "$GH_NAUAN")
if [ -n "$RESP_NAUAN" ]; then echo "  Nauan: $RESP_NAUAN (sera atribuido)"; elif [ -n "$GH_NAUAN" ]; then echo "  Nauan: $GH_NAUAN ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Nauan: usuario nao informado - issues ficarao sem responsavel"; fi
RESP_NICOLAS=$(resolver_responsavel "$GH_NICOLAS")
if [ -n "$RESP_NICOLAS" ]; then echo "  Nicolas: $RESP_NICOLAS (sera atribuido)"; elif [ -n "$GH_NICOLAS" ]; then echo "  Nicolas: $GH_NICOLAS ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Nicolas: usuario nao informado - issues ficarao sem responsavel"; fi
RESP_LEANDRO=$(resolver_responsavel "$GH_LEANDRO")
if [ -n "$RESP_LEANDRO" ]; then echo "  Leandro: $RESP_LEANDRO (sera atribuido)"; elif [ -n "$GH_LEANDRO" ]; then echo "  Leandro: $GH_LEANDRO ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Leandro: usuario nao informado - issues ficarao sem responsavel"; fi
RESP_CINARA=$(resolver_responsavel "$GH_CINARA")
if [ -n "$RESP_CINARA" ]; then echo "  Cinara: $RESP_CINARA (sera atribuido)"; elif [ -n "$GH_CINARA" ]; then echo "  Cinara: $GH_CINARA ainda NAO e colaborador - issues ficarao sem responsavel"; else echo "  Cinara: usuario nao informado - issues ficarao sem responsavel"; fi

# --- 4) Labels ---------------------------------------------------------------
echo; echo "Labels..."
gh label create "feat" -R "$REPO" --color "0e8a16" --description "Nova funcionalidade, algoritmo, interface visual ou modulo de codigo" --force >/dev/null && echo "  label feat ok"
gh label create "test" -R "$REPO" --color "fbca04" --description "Casos de teste, validacao de gabarito e verificacao de cenarios" --force >/dev/null && echo "  label test ok"
gh label create "chore" -R "$REPO" --color "cfd3d7" --description "Configuracao de ambiente, dependencias, estrutura e arquivos auxiliares" --force >/dev/null && echo "  label chore ok"
gh label create "refactor" -R "$REPO" --color "1d76db" --description "Reestruturacao, modularizacao ou melhoria interna de codigo existente" --force >/dev/null && echo "  label refactor ok"
gh label create "documentation" -R "$REPO" --color "0075ca" --description "Documentacao, manuais, README e relatorio interativo" --force >/dev/null && echo "  label documentation ok"

# --- 5) Milestones -----------------------------------------------------------
echo; echo "Milestones..."
MILESTONES_EXISTENTES=$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq ".[].title")
criar_milestone() {   # $1 = titulo | $2 = descricao
  if echo "$MILESTONES_EXISTENTES" | grep -Fxq "$1"; then
    echo "  [mantido] $1"
  else
    gh api --method POST "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null
    echo "  [criado]  $1"
  fi
}
criar_milestone "Fase 0: Infraestrutura e Manuais" "Configuracao inicial do repositorio, dependencias, ambiente Python e manuais de operacao da equipe."
criar_milestone "Fase 1: Modulos Base e Casos de Teste" "Desenvolvimento independente dos modulos de leitura, ciclos e geometria anticolisao, e criacao dos casos de teste T1 a T7."
criar_milestone "Fase 2: Motor de Busca em Profundidade (DFS)" "Implementacao do algoritmo principal de deteccao de impasses no grafo de alocacao de recursos."
criar_milestone "Fase 3: Visualizacao e Validacao de Gabarito" "Geracao das tres imagens de cada caso e implementacao da suite de validacao automatica."
criar_milestone "Fase 4: Integracao e Interface CLI" "Unificacao dos modulos dos seis integrantes no integrador principal e execucao por linha de comando."
criar_milestone "Fase 5: Relatorio Tecnico e Figuras" "Notebook interativo com a analise dos sete casos e as 21 figuras oficiais do projeto."
criar_milestone "Fase 6: Documentacao Final e Entrega" "Reescrita do README para a arquitetura modular consolidada e revisao geral do repositorio."

# --- 6) Branches -------------------------------------------------------------
echo; echo "Branches..."
criar_branch() {
  if git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1; then
    echo "  [mantida] $1"
  else
    git push -q origin "refs/remotes/origin/main:refs/heads/$1" && echo "  [criada]  $1"
  fi
}
criar_branch "fase-0/pamella-estrutura"
criar_branch "fase-0/pamella-manuais"
criar_branch "fase-1/nauan-casos-teste"
criar_branch "fase-1/cinara-leitura"
criar_branch "fase-1/leandro-ciclos"
criar_branch "fase-1/raony-geometria"
criar_branch "fase-2/nicolas-dfs"
criar_branch "fase-3/pamella-desenho"
criar_branch "fase-3/nauan-gabarito"
criar_branch "fase-4/integracao"
criar_branch "fase-5/notebook"
criar_branch "fase-6/pamella-readme"

# --- 7) Issues: criar o que falta, atualizar o que ja existe ------------------
echo; echo "Carregando issues ja existentes..."
ISSUES_JSON=$(mktemp)
gh api "repos/$REPO/issues?state=all&per_page=100" --paginate --jq '[.[] | select(.pull_request == null) | {number, title}]' > "$ISSUES_JSON"

numero_por_titulo() {   # $1 = titulo exato
  python3 -c "
import sys, json
dados = json.load(open(sys.argv[1]))
for it in dados:
    if it['title'] == sys.argv[2]:
        print(it['number']); break
" "$ISSUES_JSON" "$1"
}

# cria a issue (ou atualiza a existente) e imprime o numero dela
criar_ou_atualizar() {   # $1 titulo | $2 responsavel | $3 labels | $4 milestone | corpo: stdin
  local titulo="$1" resp="$2" labels="$3" marco="$4" corpo num url
  corpo=$(mktemp); cat > "$corpo"
  num=$(numero_por_titulo "$titulo")
  if [ -n "$num" ]; then
    gh issue edit "$num" -R "$REPO" --body-file "$corpo" --add-label "$labels" --milestone "$marco" >/dev/null
    [ -n "$resp" ] && gh issue edit "$num" -R "$REPO" --add-assignee "$resp" >/dev/null || true
    echo "  [atualizada] #$num $titulo" >&2
  else
    if [ -n "$resp" ]; then
      url=$(gh issue create -R "$REPO" --title "$titulo" --body-file "$corpo" --label "$labels" --milestone "$marco" --assignee "$resp")
    else
      url=$(gh issue create -R "$REPO" --title "$titulo" --body-file "$corpo" --label "$labels" --milestone "$marco")
    fi
    num=$(basename "$url")
    echo "  [criada]     #$num $titulo" >&2
  fi
  rm -f "$corpo"
  echo "$num"
}

# vincula a sub-issue a issue-mae, sem repetir vinculo existente
vincular_sub() {   # $1 = numero do pai | $2 = numero da sub
  local ja id
  ja=$(gh api "repos/$REPO/issues/$1/sub_issues" --jq "[.[].number] | index($2)" 2>/dev/null || echo "null")
  if [ "$ja" != "null" ] && [ -n "$ja" ]; then return 0; fi
  id=$(gh api "repos/$REPO/issues/$2" --jq ".id")
  gh api --method POST "repos/$REPO/issues/$1/sub_issues" -F "sub_issue_id=$id" >/dev/null 2>&1 \
    || echo "    [aviso] nao consegui vincular #$2 a #$1 (vincule pela pagina da issue)" >&2
}

echo; echo "== Fase 0 | fase-0/pamella-estrutura =="
PAI=$(criar_ou_atualizar "Fase 0: pamella-estrutura (Pamella)" "$RESP_PAMELLA" "chore,feat" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Preparar o esqueleto do projeto: dependências, pacote `src/` e a base visual que todas as figuras vão usar. Enquanto esta branch não entrar na `main`, ninguém mais consegue importar nada.

### Pré-requisitos
- Nenhuma branch anterior. Esta é a primeira a ser integrada.

### Arquivos desta etapa
- **Criar:** `requirements.txt`
- **Criar:** `src/__init__.py`
- **Criar (início):** `src/etapa1_infra_e_estilo_visual_pamella.py`

### Antes de começar, confira
- O `.gitignore` **já existe** no repositório e ignora `__pycache__/`, `venv/` e `sandbox_local/`. Não precisa mexer.
- A pasta `output/figures/` não existe ainda: ela é criada em tempo de execução por `obter_caminhos_portaveis_repositorio()`.

### O que você vai escrever
- `obter_caminhos_portaveis_repositorio() -> Tuple[str, str, str]` — descobre a raiz do repositório a partir de `__file__`, monta `tests/` e `output/figures/`, cria a pasta de figuras com `os.makedirs(..., exist_ok=True)` e devolve os três caminhos.
- As constantes `DIRETORIO_RAIZ`, `PASTA_TESTES` e `PASTA_FIGURAS`, preenchidas por essa função.
- A paleta de cores: `COR_NO_DEADLOCK`, `COR_NO_SEGURO`, `COR_PROCESSO_CIRCULO`, `COR_RECURSO_QUADRADO`, `COR_BORDA_PROCESSO`, `COR_BORDA_RECURSO`, `COR_ARESTA_NORMAL`, `COR_ARESTA_CICLO` e `COR_ARESTA_SEGURA`.
- As constantes de medida: `DPI_FIGURAS` (resolução única de todas as imagens), `RAIO_CIRCULO_PROCESSO` e `MEIO_LADO_QUADRADO`.

### Pontos de atenção
- Use `matplotlib.use("Agg")` **antes** de importar o `pyplot`: sem isso o projeto quebra em máquina sem interface gráfica.
- Não use caminho absoluto da sua máquina em lugar nenhum: o projeto tem de rodar no Linux e no Windows 11 de quem clonar.
- `DPI_FIGURAS` tem de ser o **único** lugar onde a resolução aparece. Nenhuma função deve escrever `dpi=300` direto.

### Passos — um commit por item
- [ ] **0.1** — `requirements.txt` — commit `chore(infra): adiciona requirements.txt`
- [ ] **0.2** — `src/__init__.py` — commit `chore(infra): cria o pacote src`
- [ ] **0.3** — `src/etapa1_infra_e_estilo_visual_pamella.py (imports e caminhos)` — commit `feat(etapa1): imports base e resolução portável de diretórios`
- [ ] **0.4** — `src/etapa1_infra_e_estilo_visual_pamella.py (paleta de cores)` — commit `feat(etapa1): paleta de cores dos grafos`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Portabilidade de caminhos (`os.path`), *backend* não interativo do Matplotlib, paleta cromática semântica, constantes de configuração centralizadas.

### Como conferir que funcionou
```bash
python -c "from src.etapa1_infra_e_estilo_visual_pamella import PASTA_FIGURAS; print(PASTA_FIGURAS)"
```
Deve imprimir o caminho de `output/figures/` e a pasta deve passar a existir.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-0/pamella-estrutura` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 0.1: requirements.txt" "$RESP_PAMELLA" "chore,good first issue" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-estrutura` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `requirements.txt`

### O que fazer neste passo
Declara as dependências do projeto: matplotlib (desenho dos grafos), ipython e jupyter (relatório interativo). Primeiro commit da reconstrução, porque todos os módulos dependem do ambiente instalado.

> Observação: o networkx, listado no repo base, não entra: nenhum módulo usa a biblioteca.

> Observação: o .gitignore já existe neste repositório e está correto (ignora __pycache__/, venv/ e sandbox_local/), portanto não precisa de commit.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
chore(infra): adiciona requirements.txt
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Declara as dependências do projeto: matplotlib (desenho dos grafos), ipython e jupyter (relatório interativo). Primeiro commit da reconstrução, porque todos os módulos dependem do ambiente instalado.

Observação: o networkx, listado no repo base, não entra: nenhum módulo usa a biblioteca.

Observação: o .gitignore já existe neste repositório e está correto (ignora __pycache__/, venv/ e sandbox_local/), portanto não precisa de commit.
```

### Como subir este passo
```bash
git switch fase-0/pamella-estrutura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-estrutura
```

Quando **todos** os passos de `fase-0/pamella-estrutura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.2: src/__init__.py" "$RESP_PAMELLA" "chore,good first issue" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-estrutura` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `src/__init__.py`

### O que fazer neste passo
Cria src/__init__.py com o cabeçalho de identificação do projeto, para que os módulos de cada integrante sejam importados como src.etapaX. É esse pacote que permite os imports usados pelo integrador, pelo main.py e pelo notebook.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
chore(infra): cria o pacote src
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria src/__init__.py com o cabeçalho de identificação do projeto, para que os módulos de cada integrante sejam importados como src.etapaX. É esse pacote que permite os imports usados pelo integrador, pelo main.py e pelo notebook.
```

### Como subir este passo
```bash
git switch fase-0/pamella-estrutura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-estrutura
```

Quando **todos** os passos de `fase-0/pamella-estrutura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.3: etapa1 (imports e caminhos)" "$RESP_PAMELLA" "feat" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-estrutura` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (imports e caminhos)`

### O que fazer neste passo
Adiciona os imports (os, math, typing e matplotlib com backend Agg) e a função obter_caminhos_portaveis_repositorio(), que define DIRETORIO_RAIZ, PASTA_TESTES e PASTA_FIGURAS e cria output/figures/. Permite executar o projeto em qualquer máquina, sem caminhos fixos.

> Observação: não copiar do repo base o import sys, o Optional do typing, o import matplotlib.path.Path nem o try/except do networkx: nenhum deles é usado.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): imports base e resolução portável de diretórios
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Adiciona os imports (os, math, typing e matplotlib com backend Agg) e a função obter_caminhos_portaveis_repositorio(), que define DIRETORIO_RAIZ, PASTA_TESTES e PASTA_FIGURAS e cria output/figures/. Permite executar o projeto em qualquer máquina, sem caminhos fixos.

Observação: não copiar do repo base o import sys, o Optional do typing, o import matplotlib.path.Path nem o try/except do networkx: nenhum deles é usado.
```

### Como subir este passo
```bash
git switch fase-0/pamella-estrutura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-estrutura
```

Quando **todos** os passos de `fase-0/pamella-estrutura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.4: etapa1 (paleta de cores)" "$RESP_PAMELLA" "feat" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-estrutura` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (paleta de cores)`

### O que fazer neste passo
Define as cores de processos (círculos), recursos (quadrados), nós em deadlock e seguros, e das arestas normais, do ciclo e seguras. É a identidade visual usada pelo cartão de diagnóstico e pelos painéis.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): paleta de cores dos grafos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Define as cores de processos (círculos), recursos (quadrados), nós em deadlock e seguros, e das arestas normais, do ciclo e seguras. É a identidade visual usada pelo cartão de diagnóstico e pelos painéis.
```

### Como subir este passo
```bash
git switch fase-0/pamella-estrutura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-estrutura
```

Quando **todos** os passos de `fase-0/pamella-estrutura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 0 | fase-0/pamella-manuais =="
PAI=$(criar_ou_atualizar "Fase 0: pamella-manuais (Pamella)" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Escrever a documentação de uso do repositório, para que cada integrante consiga clonar, montar o ambiente e enviar o próprio trabalho sem travar.

### Pré-requisitos
- Nenhuma. Pode ser feita ao mesmo tempo que a `fase-0/pamella-estrutura`.

### Arquivos desta etapa
- **Criar:** `docs/MANUAL_CLONAGEM_LINUX.md`, `docs/MANUAL_CLONAGEM_WINDOWS11.md`, `docs/MANUAL_AMBIENTE_E_EXECUCAO.md`, `docs/MANUAL_PULL_REQUEST_EQUIPE.md`, `docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md`
- **Criar:** `docs/PLANO_DE_BRANCHES.md` e `docs/MAPA_DE_TRECHOS.md`

### Antes de começar, confira
- O manual de ambiente cita o `requirements.txt`, criado no passo 0.1 da outra branch da Fase 0. Mantenha a lista de dependências coerente: `matplotlib`, `ipython` e `jupyter`.
- Nenhum manual deve citar o repositório antigo `rag-deadlock-dfs-detector-tests`.

### O que você vai escrever
- Dois guias de clonagem (um por sistema operacional), cobrindo escolha da pasta, `git clone` e o que a pasta `.git` passa a rastrear.
- Um guia de ambiente: criação do `venv`, ativação em cada sistema, `pip install -r requirements.txt` e execução do `python main.py`.
- Um guia de *Pull Request*: nunca alterar a `main` direto, trabalhar na própria branch (padrão `fase-N/integrante-assunto`) e abrir PR para revisão.
- Um guia de sincronização: `git fetch`, `git merge origin/main` antes de cada fase, resolução de conflitos e como desfazer alterações locais.

### Pontos de atenção
- Os exemplos de nome de branch devem seguir o padrão real deste projeto, e apontar o `docs/PLANO_DE_BRANCHES.md` como lista oficial.
- Os comandos precisam funcionar nos dois sistemas; quando diferirem, mostre as duas versões.

### Passos — um commit por item
- [ ] **0.5** — `docs/MANUAL_CLONAGEM_LINUX.md` — commit `docs(manuais): adiciona o manual de clonagem no Linux`
- [ ] **0.6** — `docs/MANUAL_CLONAGEM_WINDOWS11.md` — commit `docs(manuais): adiciona o manual de clonagem no Windows 11`
- [ ] **0.7** — `docs/MANUAL_AMBIENTE_E_EXECUCAO.md` — commit `docs(manuais): adiciona o manual de ambiente Python e execução`
- [ ] **0.8** — `docs/MANUAL_PULL_REQUEST_EQUIPE.md` — commit `docs(manuais): adiciona o manual de branches e Pull Requests`
- [ ] **0.9** — `docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md` — commit `docs(manuais): adiciona o manual de sincronização e resolução de conflitos no Git`
- [ ] **0.10** — `docs/PLANO_DE_BRANCHES.md e docs/MAPA_DE_TRECHOS.md` — commit `docs(planejamento): adiciona o plano de branches e o mapa de trechos`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Documentação técnica, fluxo de trabalho com *branches*, *Pull Request*, ambiente virtual Python.

### Como conferir que funcionou
Peça a um integrante para seguir o manual do zero, numa pasta nova, até rodar `python main.py`. Se ele travar em algum passo, o manual precisa de ajuste.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-0/pamella-manuais` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 0.5: docs/MANUAL_CLONAGEM_LINUX.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/MANUAL_CLONAGEM_LINUX.md`

### O que fazer neste passo
Guia de clonagem e configuração local no Linux pelo terminal do VS Code: escolha do diretório, git clone, rastreamento pela pasta .git e verificação da cópia local.

> Adaptação necessária: o texto do repo base cita o repositório rag-deadlock-dfs-detector-tests em 5 trechos; todos passam a citar rag-deadlock-dfs-detector.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(manuais): adiciona o manual de clonagem no Linux
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Guia de clonagem e configuração local no Linux pelo terminal do VS Code: escolha do diretório, git clone, rastreamento pela pasta .git e verificação da cópia local.

Adaptação necessária: o texto do repo base cita o repositório rag-deadlock-dfs-detector-tests em 5 trechos; todos passam a citar rag-deadlock-dfs-detector.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.6: docs/MANUAL_CLONAGEM_WINDOWS11.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/MANUAL_CLONAGEM_WINDOWS11.md`

### O que fazer neste passo
Mesmo guia de clonagem para o Windows 11 (PowerShell ou Prompt de Comando no VS Code), com os caminhos e particularidades do sistema.

> Adaptação necessária: trocar as 5 citações de rag-deadlock-dfs-detector-tests por rag-deadlock-dfs-detector.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(manuais): adiciona o manual de clonagem no Windows 11
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Mesmo guia de clonagem para o Windows 11 (PowerShell ou Prompt de Comando no VS Code), com os caminhos e particularidades do sistema.

Adaptação necessária: trocar as 5 citações de rag-deadlock-dfs-detector-tests por rag-deadlock-dfs-detector.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.7: docs/MANUAL_AMBIENTE_E_EXECUCAO.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/MANUAL_AMBIENTE_E_EXECUCAO.md`

### O que fazer neste passo
Passo a passo após a clonagem: criação do ambiente virtual (venv), instalação das dependências do requirements.txt e execução do detector no Linux e no Windows 11. Complementa o passo 0.1, que cria o requirements.txt.

> Adaptação necessária: trocar a citação de rag-deadlock-dfs-detector-tests por rag-deadlock-dfs-detector.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(manuais): adiciona o manual de ambiente Python e execução
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Passo a passo após a clonagem: criação do ambiente virtual (venv), instalação das dependências do requirements.txt e execução do detector no Linux e no Windows 11. Complementa o passo 0.1, que cria o requirements.txt.

Adaptação necessária: trocar a citação de rag-deadlock-dfs-detector-tests por rag-deadlock-dfs-detector.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.8: docs/MANUAL_PULL_REQUEST_EQUIPE.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/MANUAL_PULL_REQUEST_EQUIPE.md`

### O que fazer neste passo
Fluxo obrigatório da equipe: nunca alterar a main diretamente, trabalhar na própria branch e submeter Pull Request para revisão.

> Adaptações necessárias: trocar a citação do repositório antigo e ajustar os exemplos de nome de branch para o padrão desta reconstrução (fase-N/integrante-assunto), citando docs/PLANO_DE_BRANCHES.md como a lista oficial de branches e commits.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(manuais): adiciona o manual de branches e Pull Requests
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Fluxo obrigatório da equipe: nunca alterar a main diretamente, trabalhar na própria branch e submeter Pull Request para revisão.

Adaptações necessárias: trocar a citação do repositório antigo e ajustar os exemplos de nome de branch para o padrão desta reconstrução (fase-N/integrante-assunto), citando docs/PLANO_DE_BRANCHES.md como a lista oficial de branches e commits.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.9: docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/MANUAL_ATUALIZACAO_E_SINCRONIZACAO_GIT.md`

### O que fazer neste passo
Como verificar se a cópia local está atualizada antes de editar, e como resolver conflitos, trocar de branch e desfazer alterações locais, no Linux e no Windows 11.

> Adaptações necessárias: trocar as 2 citações do repositório antigo e alinhar as instruções ao fluxo desta reconstrução, em que cada integrante roda git merge origin/main na sua branch antes de começar cada fase.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(manuais): adiciona o manual de sincronização e resolução de conflitos no Git
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Como verificar se a cópia local está atualizada antes de editar, e como resolver conflitos, trocar de branch e desfazer alterações locais, no Linux e no Windows 11.

Adaptações necessárias: trocar as 2 citações do repositório antigo e alinhar as instruções ao fluxo desta reconstrução, em que cada integrante roda git merge origin/main na sua branch antes de começar cada fase.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 0.10: PLANO_DE_BRANCHES.md e MAPA_DE_TRECHOS.md" "$RESP_PAMELLA" "documentation" "Fase 0: Infraestrutura e Manuais" <<'FIM_DO_CORPO'
**Branch:** `fase-0/pamella-manuais` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 0**
**Arquivo deste passo:** `docs/PLANO_DE_BRANCHES.md e docs/MAPA_DE_TRECHOS.md`

### O que fazer neste passo
Registra no repositório o planejamento da reconstrução: PLANO_DE_BRANCHES.md com as branches, os passos e as mensagens de commit de cada integrante, e MAPA_DE_TRECHOS.md com a linha exata de cada trecho em cada arquivo, o responsável e o código do repo base que não foi copiado.

> São os dois documentos que os manuais 0.8 e 0.9 citam; sobem antes de qualquer código para a equipe poder trabalhar.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(planejamento): adiciona o plano de branches e o mapa de trechos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Registra no repositório o planejamento da reconstrução: PLANO_DE_BRANCHES.md com as branches, os passos e as mensagens de commit de cada integrante, e MAPA_DE_TRECHOS.md com a linha exata de cada trecho em cada arquivo, o responsável e o código do repo base que não foi copiado.

São os dois documentos que os manuais 0.8 e 0.9 citam; sobem antes de qualquer código para a equipe poder trabalhar.
```

### Como subir este passo
```bash
git switch fase-0/pamella-manuais
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-0/pamella-manuais
```

Quando **todos** os passos de `fase-0/pamella-manuais` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 1 | fase-1/nauan-casos-teste =="
PAI=$(criar_ou_atualizar "Fase 1: nauan-casos-teste (Nauan)" "$RESP_NAUAN" "test" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Modelar os grafos de entrada do trabalho no formato **Opção 1 — Lista de Arestas**. São esses arquivos que todo o resto do projeto vai ler.

### Pré-requisitos
- `fase-0/pamella-estrutura` integrada na `main`.
- Antes de começar: `git switch fase-1/nauan-casos-teste` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Conferir e ajustar:** `tests/caso_slide40_multiplos_nos.txt`
- **Substituir o conteúdo:** `tests/caso_grafo1_concorrente_seguro.txt` e `tests/caso_grafo2_espera_circular.txt`
- **Criar:** `tests/caso_extra_multiplos_ciclos.txt`, `tests/caso_ciclo_com_processo_em_espera.txt`, `tests/caso_cadeia_sem_ciclo.txt`, `tests/caso_dois_impasses_com_ramo_livre.txt`

### Antes de começar, confira
- Os três primeiros arquivos **já existem** no repositório, mas dois deles guardam os grafos antigos (`A`, `B`, `C` com `R`, `S`, `T`), que não são os do enunciado do Trabalho 2.
- Confira o enunciado e os *Slides* da Aula 07 antes de redesenhar cada grafo.

### O que você vai escrever
- Sete arquivos `.txt`, cada um com: linhas de comentário iniciadas por `#` (responsável, formato e resultado esperado), a linha `PROCESSOS ...`, a linha `RECURSOS ...`, a palavra `ARESTAS` e uma aresta `ORIGEM DESTINO` por linha.
- **Convenção obrigatória:** `recurso processo` significa **posse** (o recurso está alocado); `processo recurso` significa **solicitação** (o processo espera). A seta sempre aponta para o segundo nome.

### Pontos de atenção
- O grafo tem de ser **bipartido**: nunca ligue processo com processo nem recurso com recurso.
- **Uma instância por recurso**: cada recurso pode aparecer como origem de posse no máximo uma vez.
- Nenhum nome pode ser processo e recurso ao mesmo tempo.
- Use nomes curtos (uma letra) como nos slides: o desenho fica mais legível.

### Passos — um commit por item
- [ ] **1.N1** — `tests/caso_slide40_multiplos_nos.txt` — commit `test(casos): padroniza o cabeçalho do T1 - grafo do Slide 40`
- [ ] **1.N2** — `tests/caso_grafo1_concorrente_seguro.txt` — commit `test(casos): atualiza o T2 para o Grafo 1 do enunciado do Trabalho 2`
- [ ] **1.N3** — `tests/caso_grafo2_espera_circular.txt` — commit `test(casos): atualiza o T3 para o Grafo 2 do enunciado do Trabalho 2`
- [ ] **1.N4** — `tests/caso_extra_multiplos_ciclos.txt` — commit `test(casos): adiciona T4 - dois ciclos disjuntos simultâneos`
- [ ] **1.N5** — `tests/caso_ciclo_com_processo_em_espera.txt` — commit `test(casos): adiciona T5 - ciclo com processo esperando de fora`
- [ ] **1.N6** — `tests/caso_cadeia_sem_ciclo.txt` — commit `test(casos): adiciona T6 - cadeia longa de espera sem deadlock`
- [ ] **1.N7** — `tests/caso_dois_impasses_com_ramo_livre.txt` — commit `test(casos): adiciona T7 - dois impasses com ramo livre`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Grafo de alocação de recursos (Holt, 1972), grafo dirigido bipartido, posse e solicitação, espera circular, instância única de recurso.

### Como conferir que funcionou
Depois que a Etapa 2 (Cinara) estiver na `main`, cada arquivo precisa ser lido sem erro:
```bash
python -c "from src.etapa2_leitura_validacao_cinara import carregar_e_validar_grafo as ler; print(ler('tests/caso_cadeia_sem_ciclo.txt'))"
```

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-1/nauan-casos-teste` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 1.N1: tests/caso_slide40_multiplos_nos.txt" "$RESP_NAUAN" "test,good first issue" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_slide40_multiplos_nos.txt`

### O que fazer neste passo
O grafo do Slide 40 (7 processos e 6 recursos) já está correto neste repositório; o commit apenas padroniza o cabeçalho de comentários com o responsável pela modelagem, o formato (Opção 1) e o resultado esperado: Há deadlock (D -> T -> E -> V -> G -> U -> D).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): padroniza o cabeçalho do T1 - grafo do Slide 40
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
O grafo do Slide 40 (7 processos e 6 recursos) já está correto neste repositório; o commit apenas padroniza o cabeçalho de comentários com o responsável pela modelagem, o formato (Opção 1) e o resultado esperado: Há deadlock (D -> T -> E -> V -> G -> U -> D).
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N2: tests/caso_grafo1_concorrente_seguro.txt" "$RESP_NAUAN" "test,good first issue" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_grafo1_concorrente_seguro.txt`

### O que fazer neste passo
Substitui o grafo antigo (A, B, C com R, S, T) pelo Grafo 1 do enunciado: processos B, D, E, Z e F e recursos T, U, V, W e S. Resultado esperado: Há deadlock (D -> T -> E -> V -> Z -> U -> D).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): atualiza o T2 para o Grafo 1 do enunciado do Trabalho 2
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Substitui o grafo antigo (A, B, C com R, S, T) pelo Grafo 1 do enunciado: processos B, D, E, Z e F e recursos T, U, V, W e S. Resultado esperado: Há deadlock (D -> T -> E -> V -> Z -> U -> D).
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N3: tests/caso_grafo2_espera_circular.txt" "$RESP_NAUAN" "test,good first issue" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_grafo2_espera_circular.txt`

### O que fazer neste passo
Substitui o grafo antigo (espera circular entre A, B, C) pelo Grafo 2 do enunciado: 8 processos (A, B, C, D, E, F, G e Z) e 6 recursos (R, S, T, U, V e W), com posses R->A, W->F, S->D, U->D, T->E e V->E e solicitações A->S, C->S, F->S, G->U, D->T, B->T e Z->V. Resultado esperado: Sem deadlock.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): atualiza o T3 para o Grafo 2 do enunciado do Trabalho 2
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Substitui o grafo antigo (espera circular entre A, B, C) pelo Grafo 2 do enunciado: 8 processos (A, B, C, D, E, F, G e Z) e 6 recursos (R, S, T, U, V e W), com posses R->A, W->F, S->D, U->D, T->E e V->E e solicitações A->S, C->S, F->S, G->U, D->T, B->T e Z->V. Resultado esperado: Sem deadlock.
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N4: tests/caso_extra_multiplos_ciclos.txt" "$RESP_NAUAN" "test" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_extra_multiplos_ciclos.txt`

### O que fazer neste passo
Caso extra com dois deadlocks independentes ao mesmo tempo (Slides 30(c) e 36), usado para exercitar a busca de todos os ciclos (--todos) e o desenho em círculos.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): adiciona T4 - dois ciclos disjuntos simultâneos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Caso extra com dois deadlocks independentes ao mesmo tempo (Slides 30(c) e 36), usado para exercitar a busca de todos os ciclos (--todos) e o desenho em círculos.
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N5: tests/caso_ciclo_com_processo_em_espera.txt" "$RESP_NAUAN" "test" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_ciclo_com_processo_em_espera.txt`

### O que fazer neste passo
Caso opcional: três processos em espera circular (A, B, C sobre R, S, T) e um quarto processo D esperando por um recurso do ciclo sem fazer parte dele. Mostra que o isolamento do ciclo elementar descarta corretamente quem está fora do laço.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): adiciona T5 - ciclo com processo esperando de fora
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Caso opcional: três processos em espera circular (A, B, C sobre R, S, T) e um quarto processo D esperando por um recurso do ciclo sem fazer parte dele. Mostra que o isolamento do ciclo elementar descarta corretamente quem está fora do laço.
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N6: tests/caso_cadeia_sem_ciclo.txt" "$RESP_NAUAN" "test" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_cadeia_sem_ciclo.txt`

### O que fazer neste passo
Caso opcional sem impasse: quatro processos encadeados em espera, terminando em um processo que possui um recurso e nada solicita, o que desfaz a cadeia. Resultado esperado: Sem deadlock.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): adiciona T6 - cadeia longa de espera sem deadlock
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Caso opcional sem impasse: quatro processos encadeados em espera, terminando em um processo que possui um recurso e nada solicita, o que desfaz a cadeia. Resultado esperado: Sem deadlock.
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.N7: tests/caso_dois_impasses_com_ramo_livre.txt" "$RESP_NAUAN" "test" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/nauan-casos-teste` · **Responsável:** Nauan Christo de Aquino · **Fase 1**
**Arquivo deste passo:** `tests/caso_dois_impasses_com_ramo_livre.txt`

### O que fazer neste passo
Caso opcional com dois ciclos simultâneos convivendo com um ramo livre. Diferente do T4, o grafo não é só de ciclos, então exercita o motor ortogonal em um grafo com impasse múltiplo.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(casos): adiciona T7 - dois impasses com ramo livre
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Caso opcional com dois ciclos simultâneos convivendo com um ramo livre. Diferente do T4, o grafo não é só de ciclos, então exercita o motor ortogonal em um grafo com impasse múltiplo.
```

### Como subir este passo
```bash
git switch fase-1/nauan-casos-teste
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/nauan-casos-teste
```

Quando **todos** os passos de `fase-1/nauan-casos-teste` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 1 | fase-1/cinara-leitura =="
PAI=$(criar_ou_atualizar "Fase 1: cinara-leitura (Cinara)" "$RESP_CINARA" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Escrever o leitor dos arquivos `.txt` e as validações formais do grafo. É a porta de entrada do projeto: todo o resto consome o que esta etapa devolve.

### Pré-requisitos
- `fase-0/pamella-estrutura` integrada na `main`.
- Os arquivos de `tests/` são do Nauan, mas você **não precisa esperar** por eles: pode testar com um `.txt` escrito à mão no formato da Opção 1.
- Antes de começar: `git switch fase-1/cinara-leitura` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/etapa2_leitura_validacao_cinara.py`

### Antes de começar, confira
- O formato de entrada está descrito no `README.md` e nos comentários dos arquivos de `tests/`.

### O que você vai escrever
- Uma única função pública:
```python
def carregar_e_validar_grafo(
    caminho_arquivo: str
) -> Tuple[List[str], List[str], Dict[str, List[str]], List[Tuple[str, str]]]:
```
**Contrato de saída** (toda a equipe depende dele, não mude sem avisar):
- `processos` — lista de nomes, na ordem em que aparecem no arquivo;
- `recursos` — idem;
- `adjacencia` — dicionário `{no: [vizinhos de saída]}`, com **todos** os nós declarados como chave, mesmo os sem saída;
- `arestas` — lista de pares `(origem, destino)` na ordem do arquivo.

### Pontos de atenção
- Descarte o que vier depois de `#` em cada linha e ignore linhas em branco.
- Valide, nesta ordem, levantando `ValueError` com mensagem clara: (1) **disjunção** $P \cap R = \emptyset$; (2) vértice usado numa aresta mas não declarado; (3) **bipartição**, rejeitando `P -> P` e `R -> R`; (4) **instância única**, rejeitando um recurso alocado a mais de um processo.
- Informe o **número da linha** nos erros de sintaxe: isso economiza muito tempo de quem estiver modelando um grafo novo.

### Passos — um commit por item
- [ ] **1.C1** — `src/etapa2_leitura_validacao_cinara.py (cabeçalho e assinatura)` — commit `feat(etapa2): cria o módulo de leitura e a assinatura de carregar_e_validar_grafo`
- [ ] **1.C2** — `src/etapa2_leitura_validacao_cinara.py (laço de leitura)` — commit `feat(etapa2): leitura dos cabeçalhos PROCESSOS, RECURSOS e ARESTAS`
- [ ] **1.C3** — `src/etapa2_leitura_validacao_cinara.py (disjunção e adjacência)` — commit `feat(etapa2): valida conjuntos disjuntos e monta a adjacência`
- [ ] **1.C4** — `src/etapa2_leitura_validacao_cinara.py (bipartição e instância única)` — commit `feat(etapa2): valida bipartição e instância única de recurso`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
*Parsing* de arquivo texto, validação semântica, grafo dirigido bipartido, lista de adjacência, disjunção de conjuntos, tratamento de exceções com `ValueError`.

### Como conferir que funcionou
```bash
python -c "from src.etapa2_leitura_validacao_cinara import carregar_e_validar_grafo as ler; print(ler('tests/caso_slide40_multiplos_nos.txt'))"
```
Teste também um arquivo propositalmente errado (uma aresta `A B` entre dois processos) e confirme que o `ValueError` aparece com a linha certa.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-1/cinara-leitura` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 1.C1: etapa2 (cabeçalho e assinatura)" "$RESP_CINARA" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/cinara-leitura` · **Responsável:** Cinara Oliveira da Silva · **Fase 1**
**Arquivo deste passo:** `src/etapa2_leitura_validacao_cinara.py (cabeçalho e assinatura)`

### O que fazer neste passo
Cria o módulo da Etapa 2 com o cabeçalho de autoria e a função de leitura do formato Opção 1 (lista de arestas), com as variáveis de estado iniciais. Fixa o contrato de saída usado por toda a equipe: (processos, recursos, adjacencia, arestas).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa2): cria o módulo de leitura e a assinatura de carregar_e_validar_grafo
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria o módulo da Etapa 2 com o cabeçalho de autoria e a função de leitura do formato Opção 1 (lista de arestas), com as variáveis de estado iniciais. Fixa o contrato de saída usado por toda a equipe: (processos, recursos, adjacencia, arestas).
```

### Como subir este passo
```bash
git switch fase-1/cinara-leitura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/cinara-leitura
```

Quando **todos** os passos de `fase-1/cinara-leitura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.C2: etapa2 (laço de leitura)" "$RESP_CINARA" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/cinara-leitura` · **Responsável:** Cinara Oliveira da Silva · **Fase 1**
**Arquivo deste passo:** `src/etapa2_leitura_validacao_cinara.py (laço de leitura)`

### O que fazer neste passo
Percorre o arquivo linha a linha, descarta comentários iniciados por # e linhas vazias, lê os dois conjuntos de nós e a lista de arestas, e lança erro sintático informando o número da linha inválida.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa2): leitura dos cabeçalhos PROCESSOS, RECURSOS e ARESTAS
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Percorre o arquivo linha a linha, descarta comentários iniciados por # e linhas vazias, lê os dois conjuntos de nós e a lista de arestas, e lança erro sintático informando o número da linha inválida.
```

### Como subir este passo
```bash
git switch fase-1/cinara-leitura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/cinara-leitura
```

Quando **todos** os passos de `fase-1/cinara-leitura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.C3: etapa2 (disjunção e adjacência)" "$RESP_CINARA" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/cinara-leitura` · **Responsável:** Cinara Oliveira da Silva · **Fase 1**
**Arquivo deste passo:** `src/etapa2_leitura_validacao_cinara.py (disjunção e adjacência)`

### O que fazer neste passo
Garante que nenhum nome seja processo e recurso ao mesmo tempo (P ∩ R = ∅) e cria o dicionário de adjacência com todos os nós declarados, base para a busca em profundidade.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa2): valida conjuntos disjuntos e monta a adjacência
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Garante que nenhum nome seja processo e recurso ao mesmo tempo (P ∩ R = ∅) e cria o dicionário de adjacência com todos os nós declarados, base para a busca em profundidade.
```

### Como subir este passo
```bash
git switch fase-1/cinara-leitura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/cinara-leitura
```

Quando **todos** os passos de `fase-1/cinara-leitura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.C4: etapa2 (bipartição e instância única)" "$RESP_CINARA" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/cinara-leitura` · **Responsável:** Cinara Oliveira da Silva · **Fase 1**
**Arquivo deste passo:** `src/etapa2_leitura_validacao_cinara.py (bipartição e instância única)`

### O que fazer neste passo
Rejeita aresta com vértice não declarado, aresta P->P ou R->R (o grafo tem de ser bipartido) e recurso alocado a mais de um processo, respeitando a restrição de 1 recurso de cada tipo exigida pelo algoritmo da aula.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa2): valida bipartição e instância única de recurso
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Rejeita aresta com vértice não declarado, aresta P->P ou R->R (o grafo tem de ser bipartido) e recurso alocado a mais de um processo, respeitando a restrição de 1 recurso de cada tipo exigida pelo algoritmo da aula.
```

### Como subir este passo
```bash
git switch fase-1/cinara-leitura
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/cinara-leitura
```

Quando **todos** os passos de `fase-1/cinara-leitura` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 1 | fase-1/leandro-ciclos =="
PAI=$(criar_ou_atualizar "Fase 1: leandro-ciclos (Leandro)" "$RESP_LEANDRO" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Transformar a lista $L$ bruta da busca em um ciclo limpo e no texto oficial de resposta do trabalho. **Faça o primeiro passo logo:** o Nicolas não consegue começar a Etapa 3 sem as suas duas primeiras funções.

### Pré-requisitos
- `fase-0/pamella-estrutura` integrada na `main`.
- Antes de começar: `git switch fase-1/leandro-ciclos` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/etapa4_ciclos_e_saida_leandro.py`

### Antes de começar, confira
- O formato exato da saída está no enunciado do trabalho: `Há deadlock (...)` ou `Sem deadlock`. O Nauan vai comparar o texto caractere a caractere no gabarito da Etapa 6.

### O que você vai escrever
```python
def isolar_ciclo_elementar(lista_L: List[str], no_repetido: str, ordem_nos: Dict[str, int]) -> List[str]:
```
- Recebe a lista $L$ no momento em que um nó se repetiu, descarta o **prefixo** que só levou até o ciclo e gira o ciclo para começar pelo nó de menor ordem de declaração. Deve devolver o ciclo fechado, repetindo o primeiro nó no fim.
```python
def normalizar_ciclo(ciclo: List[str]) -> Tuple[str, ...]:
```
- Devolve uma assinatura canônica do ciclo, para que o mesmo laço encontrado por caminhos diferentes não seja contado duas vezes.
```python
def formatar_resultado(ciclos: List[List[str]]) -> str:
```
- Sem ciclos → `Sem deadlock`. Um ciclo → `Há deadlock (A -> B -> ... -> A)`. Vários → `Há deadlock (N ciclos encontrados):` e uma linha indentada por ciclo.

### Pontos de atenção
- Exemplo do *Slide* 40: com `L = [B, T, E, V, G, U, D, T]` e o nó repetido `T`, o resultado tem de ser `D -> T -> E -> V -> G -> U -> D`; o `B` é prefixo e sai.
- `formatar_resultado` é a **única** fonte do texto de resposta. Não repita esse texto em outro módulo.

### Passos — um commit por item
- [ ] **1.L1** — `src/etapa4_ciclos_e_saida_leandro.py (isolar_ciclo_elementar)` — commit `feat(etapa4): cria o módulo de ciclos com isolar_ciclo_elementar`
- [ ] **1.L2** — `src/etapa4_ciclos_e_saida_leandro.py (normalizar_ciclo)` — commit `feat(etapa4): normalizar_ciclo para evitar ciclos duplicados`
- [ ] **1.L3** — `src/etapa4_ciclos_e_saida_leandro.py (formatar_resultado)` — commit `feat(etapa4): formatar_resultado com a saída oficial do trabalho`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Ciclo elementar, poda de prefixo, rotação canônica, assinatura de ciclo, formatação de saída oficial.

### Como conferir que funcionou
```bash
python -c "from src.etapa4_ciclos_e_saida_leandro import *; print(isolar_ciclo_elementar(['B','T','E','V','G','U','D'],'T',{n:i for i,n in enumerate('BDEGTUV')}))"
```
Confira que sai `['D','T','E','V','G','U','D']` e que `formatar_resultado([])` devolve exatamente `Sem deadlock`.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-1/leandro-ciclos` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 1.L1: etapa4 (isolar_ciclo_elementar)" "$RESP_LEANDRO" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/leandro-ciclos` · **Responsável:** Leandro Nascimento Vitório · **Fase 1**
**Arquivo deste passo:** `src/etapa4_ciclos_e_saida_leandro.py (isolar_ciclo_elementar)`

### O que fazer neste passo
Cria o módulo da Etapa 4 e a função que recebe a lista L e o nó repetido, descarta o prefixo que não faz parte do ciclo e rotaciona o ciclo para começar no nó de menor ordem. É o primeiro passo desta branch porque desbloqueia a Etapa 3 (Nicolas).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa4): cria o módulo de ciclos com isolar_ciclo_elementar
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria o módulo da Etapa 4 e a função que recebe a lista L e o nó repetido, descarta o prefixo que não faz parte do ciclo e rotaciona o ciclo para começar no nó de menor ordem. É o primeiro passo desta branch porque desbloqueia a Etapa 3 (Nicolas).
```

### Como subir este passo
```bash
git switch fase-1/leandro-ciclos
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/leandro-ciclos
```

Quando **todos** os passos de `fase-1/leandro-ciclos` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.L2: etapa4 (normalizar_ciclo)" "$RESP_LEANDRO" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/leandro-ciclos` · **Responsável:** Leandro Nascimento Vitório · **Fase 1**
**Arquivo deste passo:** `src/etapa4_ciclos_e_saida_leandro.py (normalizar_ciclo)`

### O que fazer neste passo
Gera uma assinatura canônica (tupla) do ciclo, usada pela busca em profundidade para não registrar o mesmo ciclo duas vezes quando procura todos os ciclos do grafo.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa4): normalizar_ciclo para evitar ciclos duplicados
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Gera uma assinatura canônica (tupla) do ciclo, usada pela busca em profundidade para não registrar o mesmo ciclo duas vezes quando procura todos os ciclos do grafo.
```

### Como subir este passo
```bash
git switch fase-1/leandro-ciclos
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/leandro-ciclos
```

Quando **todos** os passos de `fase-1/leandro-ciclos` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.L3: etapa4 (formatar_resultado)" "$RESP_LEANDRO" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/leandro-ciclos` · **Responsável:** Leandro Nascimento Vitório · **Fase 1**
**Arquivo deste passo:** `src/etapa4_ciclos_e_saida_leandro.py (formatar_resultado)`

### O que fazer neste passo
Produz o texto exigido pelo enunciado: Sem deadlock, Há deadlock (A -> ... -> A) ou Há deadlock (N ciclos encontrados). Esse texto é o gabarito usado pela Etapa 6 e o veredito impresso nos cartões e painéis.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa4): formatar_resultado com a saída oficial do trabalho
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Produz o texto exigido pelo enunciado: Sem deadlock, Há deadlock (A -> ... -> A) ou Há deadlock (N ciclos encontrados). Esse texto é o gabarito usado pela Etapa 6 e o veredito impresso nos cartões e painéis.
```

### Como subir este passo
```bash
git switch fase-1/leandro-ciclos
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/leandro-ciclos
```

Quando **todos** os passos de `fase-1/leandro-ciclos` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 1 | fase-1/raony-geometria =="
PAI=$(criar_ou_atualizar "Fase 1: raony-geometria (Raony)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Escrever o motor que decide **onde** cada processo e recurso fica desenhado e **por onde** cada seta passa, sem que nada se cruze ou passe por cima de um nó. É a etapa mais longa da Fase 1; faça um commit por bloco de funções.

### Pré-requisitos
- `fase-0/pamella-estrutura` integrada na `main`.
- Antes de começar: `git switch fase-1/raony-geometria` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/etapa5_geometria_anticolisao_raony.py`

### Antes de começar, confira
- Compare o resultado com as figuras do enunciado e com o *Slide* 40: os nós ficam em uma grade e as setas são retas ou em `L`.

### O que você vai escrever
- **Função de base:** `distancia_ponto_segmento(px, py, x1, y1, x2, y2) -> float`, por projeção vetorial com $t$ limitado a $[0, 1]$.
- **Constantes:** `ESPACAMENTO_GRADE`, `RAIO_EXCLUSAO_NO`, `PENALIDADE_PROIBIDA`, `PENALIDADE_CRUZAMENTO`, `PESO_AREA`, `PESO_LADO`.
- **Primitivas:** `_orientacao` (produto vetorial), `_ponto_no_retangulo`, `_caixas_se_tocam` e `_conflito_entre_segmentos`, que classifica o encontro de duas setas em livre, cruzamento em X ou sobreposição proibida.
- **Roteamento:** `_rotas_candidatas` (reta, `L` com uma dobra, desvio em `U`/`Z` por faixas livres), `_direcao_unitaria`, `_avaliar_rota` e `rotear_arestas_na_grade`.
- **Disposição:** `_custo_disposicao`, `_construcao_gulosa`, `_trocar`, `_desfazer`, `_recozimento_simulado` e `_descida_exaustiva`.
- **Caso circular:** `_componentes_sao_ciclos_disjuntos` e `_arco_circular`, para grafos formados só por ciclos simples disjuntos.
- **Ponto de entrada:**
```python
def calcular_layout_e_rotas(processos, recursos, arestas) -> Tuple[Dict[str, Tuple[float, float]], Dict[Tuple[str, str], List[Tuple[float, float]]]]:
```
- Devolve `pos[no] = (x, y)` e `rotas[(u, v)] = [ponto inicial, ..., ponto final]`, do centro de `u` ao centro de `v`.
- **Auditoria:** `contar_colisoes_desenho(pos, rotas) -> Dict[str, int]`, com as chaves `arestas_sobre_nos` e `pares_de_arestas_em_conflito`.

### Pontos de atenção
- **Nada de nome de nó ou de caso fixado no código.** O motor tem de funcionar com qualquer `.txt` que a equipe criar depois.
- Ordem de gravidade no custo: seta sobre nó, setas sobrepostas e duas setas chegando pelo mesmo lado de um nó são **proibidas**; cruzamento em X é penalizado; comprimento, dobras e área medem a compacidade.
- Use **semente fixa** no sorteio: a mesma entrada tem de gerar sempre o mesmo desenho.
- A seta aponta sempre para o segundo nome da aresta, nunca o contrário.

### Passos — um commit por item
- [ ] **1.R1** — `src/etapa5_geometria_anticolisao_raony.py (distancia_ponto_segmento)` — commit `feat(etapa5): cria o módulo geométrico com distancia_ponto_segmento`
- [ ] **1.R2** — `src/etapa5_geometria_anticolisao_raony.py (constantes e primitivas)` — commit `feat(etapa5): constantes da grade e primitivas geométricas`
- [ ] **1.R3** — `src/etapa5_geometria_anticolisao_raony.py (conflito entre segmentos)` — commit `feat(etapa5): detecção de conflito entre segmentos`
- [ ] **1.R4** — `src/etapa5_geometria_anticolisao_raony.py (rotas candidatas)` — commit `feat(etapa5): rotas ortogonais candidatas`
- [ ] **1.R5** — `src/etapa5_geometria_anticolisao_raony.py (avaliação e roteamento)` — commit `feat(etapa5): avaliação de rota e roteamento das setas na grade`
- [ ] **1.R6** — `src/etapa5_geometria_anticolisao_raony.py (custo e construção gulosa)` — commit `feat(etapa5): custo da disposição e construção gulosa`
- [ ] **1.R7** — `src/etapa5_geometria_anticolisao_raony.py (otimização)` — commit `feat(etapa5): otimização por recozimento simulado e descida exaustiva`
- [ ] **1.R8** — `src/etapa5_geometria_anticolisao_raony.py (ciclos disjuntos)` — commit `feat(etapa5): círculo trigonométrico para ciclos disjuntos`
- [ ] **1.R9** — `src/etapa5_geometria_anticolisao_raony.py (calcular_layout_e_rotas)` — commit `feat(etapa5): calcular_layout_e_rotas, ponto de entrada do motor`
- [ ] **1.R10** — `src/etapa5_geometria_anticolisao_raony.py (auditoria)` — commit `feat(etapa5): auditoria contar_colisoes_desenho`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Projeção vetorial ponto-segmento, orientação por produto vetorial, interseção de segmentos, roteamento ortogonal em grade, função de custo com penalidades, construção gulosa, recozimento simulado (*simulated annealing*), descida exaustiva, círculo trigonométrico.

### Como conferir que funcionou
```bash
python -c "from src.etapa2_leitura_validacao_cinara import carregar_e_validar_grafo as ler; from src.etapa5_geometria_anticolisao_raony import *; p,r,a,ar=ler('tests/caso_slide40_multiplos_nos.txt'); pos,rot=calcular_layout_e_rotas(p,r,ar); print(contar_colisoes_desenho(pos,rot))"
```
O resultado tem de ser `{'arestas_sobre_nos': 0, 'pares_de_arestas_em_conflito': 0}` em **todos** os arquivos de `tests/`.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-1/raony-geometria` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 1.R1: etapa5 (distancia_ponto_segmento)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (distancia_ponto_segmento)`

### O que fazer neste passo
Cria o módulo da Etapa 5 com os três imports no topo (math, random e typing) e a distância mínima ponto–segmento por projeção vetorial, base de toda a verificação de setas passando sobre processos e recursos.

> Observação: no repo base o import random fica solto no meio do arquivo e o typing traz um Set que não é usado; aqui os imports ficam todos no topo e sem o Set.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): cria o módulo geométrico com distancia_ponto_segmento
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria o módulo da Etapa 5 com os três imports no topo (math, random e typing) e a distância mínima ponto–segmento por projeção vetorial, base de toda a verificação de setas passando sobre processos e recursos.

Observação: no repo base o import random fica solto no meio do arquivo e o typing traz um Set que não é usado; aqui os imports ficam todos no topo e sem o Set.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R2: etapa5 (constantes e primitivas)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (constantes e primitivas)`

### O que fazer neste passo
Acrescenta o cabeçalho que explica o motor, o espaçamento da grade, o raio de exclusão dos nós, as penalidades e os pesos de área, e as primitivas _orientacao (produto vetorial), _ponto_no_retangulo e _caixas_se_tocam.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): constantes da grade e primitivas geométricas
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Acrescenta o cabeçalho que explica o motor, o espaçamento da grade, o raio de exclusão dos nós, as penalidades e os pesos de área, e as primitivas _orientacao (produto vetorial), _ponto_no_retangulo e _caixas_se_tocam.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R3: etapa5 (conflito entre segmentos)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (conflito entre segmentos)`

### O que fazer neste passo
_conflito_entre_segmentos classifica o encontro de duas setas: livre, cruzamento em X (penalizado) ou sobreposição e toque fora de um nó comum (proibido).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): detecção de conflito entre segmentos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_conflito_entre_segmentos classifica o encontro de duas setas: livre, cruzamento em X (penalizado) ou sobreposição e toque fora de um nó comum (proibido).
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R4: etapa5 (rotas candidatas)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (rotas candidatas)`

### O que fazer neste passo
_rotas_candidatas gera as rotas possíveis de uma seta: reta, L com uma dobra e desvios em U ou Z por faixas livres entre as fileiras. _direcao_unitaria identifica por qual lado do nó a seta sai e chega.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): rotas ortogonais candidatas
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_rotas_candidatas gera as rotas possíveis de uma seta: reta, L com uma dobra e desvios em U ou Z por faixas livres entre as fileiras. _direcao_unitaria identifica por qual lado do nó a seta sai e chega.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R5: etapa5 (avaliação e roteamento)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (avaliação e roteamento)`

### O que fazer neste passo
_avaliar_rota calcula o custo de uma rota (seta sobre nó, conflito com outra seta e duas setas no mesmo lado de um nó) e rotear_arestas_na_grade escolhe a melhor rota de cada seta, das mais curtas para as mais longas.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): avaliação de rota e roteamento das setas na grade
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_avaliar_rota calcula o custo de uma rota (seta sobre nó, conflito com outra seta e duas setas no mesmo lado de um nó) e rotear_arestas_na_grade escolhe a melhor rota de cada seta, das mais curtas para as mais longas.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R6: etapa5 (custo e construção gulosa)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (custo e construção gulosa)`

### O que fazer neste passo
_custo_disposicao soma o custo das rotas com a área e a proporção do desenho; _construcao_gulosa posiciona os nós um a um, sempre ao lado dos vizinhos já colocados.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): custo da disposição e construção gulosa
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_custo_disposicao soma o custo das rotas com a área e a proporção do desenho; _construcao_gulosa posiciona os nós um a um, sempre ao lado dos vizinhos já colocados.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R7: etapa5 (otimização)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (otimização)`

### O que fazer neste passo
Adiciona os movimentos _trocar e _desfazer e as duas fases de otimização da disposição, com semente fixa, de modo que a mesma entrada gere sempre o mesmo desenho.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): otimização por recozimento simulado e descida exaustiva
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Adiciona os movimentos _trocar e _desfazer e as duas fases de otimização da disposição, com semente fixa, de modo que a mesma entrada gere sempre o mesmo desenho.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R8: etapa5 (ciclos disjuntos)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (ciclos disjuntos)`

### O que fazer neste passo
_componentes_sao_ciclos_disjuntos detecta pela estrutura do grafo quando ele é formado apenas por ciclos simples disjuntos (caso T4) e _arco_circular gera os arcos em sentido horário.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): círculo trigonométrico para ciclos disjuntos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_componentes_sao_ciclos_disjuntos detecta pela estrutura do grafo quando ele é formado apenas por ciclos simples disjuntos (caso T4) e _arco_circular gera os arcos em sentido horário.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R9: etapa5 (calcular_layout_e_rotas)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (calcular_layout_e_rotas)`

### O que fazer neste passo
Devolve pos[no] com a posição de cada processo e recurso e rotas[(u, v)] com os pontos por onde cada seta passa. É o contrato consumido pela Etapa 1. A seta sempre aponta para o segundo nome da linha do arquivo: P -> R é solicitação e R -> P é posse.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): calcular_layout_e_rotas, ponto de entrada do motor
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Devolve pos[no] com a posição de cada processo e recurso e rotas[(u, v)] com os pontos por onde cada seta passa. É o contrato consumido pela Etapa 1. A seta sempre aponta para o segundo nome da linha do arquivo: P -> R é solicitação e R -> P é posse.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 1.R10: etapa5 (auditoria)" "$RESP_RAONY" "feat" "Fase 1: Modulos Base e Casos de Teste" <<'FIM_DO_CORPO'
**Branch:** `fase-1/raony-geometria` · **Responsável:** Raony Olivio Dias Capela · **Fase 1**
**Arquivo deste passo:** `src/etapa5_geometria_anticolisao_raony.py (auditoria)`

### O que fazer neste passo
Verificação independente do otimizador: conta setas que passam sobre nós alheios e pares de setas em conflito, permitindo provar que o desenho saiu sem colisões.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa5): auditoria contar_colisoes_desenho
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Verificação independente do otimizador: conta setas que passam sobre nós alheios e pares de setas em conflito, permitindo provar que o desenho saiu sem colisões.
```

### Como subir este passo
```bash
git switch fase-1/raony-geometria
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-1/raony-geometria
```

Quando **todos** os passos de `fase-1/raony-geometria` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 2 | fase-2/nicolas-dfs =="
PAI=$(criar_ou_atualizar "Fase 2: nicolas-dfs (Nicolas)" "$RESP_NICOLAS" "feat" "Fase 2: Motor de Busca em Profundidade (DFS)" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Implementar o coração do trabalho: a detecção de impasse por **busca em profundidade**, seguindo passo a passo o algoritmo da Aula 07.

### Pré-requisitos
- `fase-1/leandro-ciclos` integrada na `main` — você importa duas funções dela.
- `fase-1/cinara-leitura` integrada na `main` — é ela que produz a lista de adjacência que você percorre.
- Antes de começar: `git switch fase-2/nicolas-dfs` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/etapa3_motor_dfs_nicolas.py`

### Antes de começar, confira
- Confira os passos 1 a 6 do algoritmo nos *Slides* 41 a 48 antes de escrever: a ordem das operações importa para o rastreamento sair igual ao da aula.

### O que você vai escrever
```python
from src.etapa4_ciclos_e_saida_leandro import isolar_ciclo_elementar, normalizar_ciclo

def detectar_impasses_dfs(
    processos: List[str],
    recursos: List[str],
    adjacencia: Dict[str, List[str]],
    buscar_todos: bool = False
) -> Tuple[List[List[str]], List[str]]:
```
- Devolve `(ciclos, log_passos)`: a lista de ciclos encontrados e o rastreamento em texto, uma linha por avanço, marcação de arco, detecção de ciclo e retrocesso.
- Dentro dela, a sub-rotina recursiva `percorrer_ramo_dfs_recursivo(no_atual, lista_L, arcos_marcados)`.

### Pontos de atenção
- **Passo 1:** repita a busca tomando **cada** nó do grafo como raiz, com a lista $L$ vazia e o conjunto de arcos marcados vazio a cada raiz.
- **Passo 3:** se o nó visitado já está em $L$, há ciclo. Chame `isolar_ciclo_elementar` e registre o ciclo só se `normalizar_ciclo` ainda não tiver aparecido.
- **Passos 4 e 5:** avance pelo **primeiro arco de saída ainda não marcado** e marque-o.
- **Passo 6:** em beco sem saída, remova o nó do fim de $L$ (`pop`) e retroceda ao pai.
- Com `buscar_todos=False`, pare no primeiro ciclo; com `True`, continue até varrer o grafo inteiro.
- Não formate texto de resultado aqui: isso é da Etapa 4.

### Passos — um commit por item
- [ ] **2.1** — `src/etapa3_motor_dfs_nicolas.py (estrutura)` — commit `feat(etapa3): cria o motor DFS e a estrutura de detectar_impasses_dfs`
- [ ] **2.2** — `src/etapa3_motor_dfs_nicolas.py (detecção do ciclo)` — commit `feat(etapa3): detecção do ciclo na lista L`
- [ ] **2.3** — `src/etapa3_motor_dfs_nicolas.py (avanço e marcação)` — commit `feat(etapa3): avanço e marcação de arcos inspecionados`
- [ ] **2.4** — `src/etapa3_motor_dfs_nicolas.py (retrocesso e raízes)` — commit `feat(etapa3): retrocesso em beco sem saída e laço sobre todas as raízes`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Busca em profundidade (*depth-first search*), recursão, lista $L$, marcação de arcos inspecionados, retrocesso (*backtracking*), detecção de ciclo em grafo dirigido.

### Como conferir que funcionou
```bash
python -c "from src.etapa2_leitura_validacao_cinara import carregar_e_validar_grafo as ler; from src.etapa3_motor_dfs_nicolas import detectar_impasses_dfs; from src.etapa4_ciclos_e_saida_leandro import formatar_resultado; p,r,adj,a=ler('tests/caso_slide40_multiplos_nos.txt'); c,log=detectar_impasses_dfs(p,r,adj); print(formatar_resultado(c))"
```
Deve sair `Há deadlock (D -> T -> E -> V -> G -> U -> D)`. No `caso_grafo2_espera_circular.txt`, deve sair `Sem deadlock`.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-2/nicolas-dfs` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 2.1: etapa3 (estrutura)" "$RESP_NICOLAS" "feat" "Fase 2: Motor de Busca em Profundidade (DFS)" <<'FIM_DO_CORPO'
**Branch:** `fase-2/nicolas-dfs` · **Responsável:** Nicolas Martins Sousa · **Fase 2**
**Arquivo deste passo:** `src/etapa3_motor_dfs_nicolas.py (estrutura)`

### O que fazer neste passo
Cria o módulo da Etapa 3, importa isolar_ciclo_elementar e normalizar_ciclo da Etapa 4 e monta a função com o estado da busca: lista de ciclos, assinaturas já vistas, log de passos e ordem dos nós.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa3): cria o motor DFS e a estrutura de detectar_impasses_dfs
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria o módulo da Etapa 3, importa isolar_ciclo_elementar e normalizar_ciclo da Etapa 4 e monta a função com o estado da busca: lista de ciclos, assinaturas já vistas, log de passos e ordem dos nós.
```

### Como subir este passo
```bash
git switch fase-2/nicolas-dfs
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-2/nicolas-dfs
```

Quando **todos** os passos de `fase-2/nicolas-dfs` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 2.2: etapa3 (detecção do ciclo)" "$RESP_NICOLAS" "feat" "Fase 2: Motor de Busca em Profundidade (DFS)" <<'FIM_DO_CORPO'
**Branch:** `fase-2/nicolas-dfs` · **Responsável:** Nicolas Martins Sousa · **Fase 2**
**Arquivo deste passo:** `src/etapa3_motor_dfs_nicolas.py (detecção do ciclo)`

### O que fazer neste passo
Sub-rotina recursiva percorrer_ramo_dfs_recursivo. Implementa o passo 3 do algoritmo da aula: se o nó visitado já está na lista L, há ciclo; ele é isolado pela Etapa 4 e registrado sem duplicatas.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa3): detecção do ciclo na lista L
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Sub-rotina recursiva percorrer_ramo_dfs_recursivo. Implementa o passo 3 do algoritmo da aula: se o nó visitado já está na lista L, há ciclo; ele é isolado pela Etapa 4 e registrado sem duplicatas.
```

### Como subir este passo
```bash
git switch fase-2/nicolas-dfs
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-2/nicolas-dfs
```

Quando **todos** os passos de `fase-2/nicolas-dfs` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 2.3: etapa3 (avanço e marcação)" "$RESP_NICOLAS" "feat" "Fase 2: Motor de Busca em Profundidade (DFS)" <<'FIM_DO_CORPO'
**Branch:** `fase-2/nicolas-dfs` · **Responsável:** Nicolas Martins Sousa · **Fase 2**
**Arquivo deste passo:** `src/etapa3_motor_dfs_nicolas.py (avanço e marcação)`

### O que fazer neste passo
Passos 4 e 5 do algoritmo: coloca o nó atual no fim da lista L, marca o primeiro arco de saída ainda não marcado e desce recursivamente por ele.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa3): avanço e marcação de arcos inspecionados
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Passos 4 e 5 do algoritmo: coloca o nó atual no fim da lista L, marca o primeiro arco de saída ainda não marcado e desce recursivamente por ele.
```

### Como subir este passo
```bash
git switch fase-2/nicolas-dfs
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-2/nicolas-dfs
```

Quando **todos** os passos de `fase-2/nicolas-dfs` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 2.4: etapa3 (retrocesso e raízes)" "$RESP_NICOLAS" "feat" "Fase 2: Motor de Busca em Profundidade (DFS)" <<'FIM_DO_CORPO'
**Branch:** `fase-2/nicolas-dfs` · **Responsável:** Nicolas Martins Sousa · **Fase 2**
**Arquivo deste passo:** `src/etapa3_motor_dfs_nicolas.py (retrocesso e raízes)`

### O que fazer neste passo
Passo 6: em beco sem saída, remove o nó da lista L e retrocede ao pai. Passo 1: repete a busca tomando cada nó do grafo como raiz e devolve (ciclos, log_passos) para o rastreamento didático.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa3): retrocesso em beco sem saída e laço sobre todas as raízes
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Passo 6: em beco sem saída, remove o nó da lista L e retrocede ao pai. Passo 1: repete a busca tomando cada nó do grafo como raiz e devolve (ciclos, log_passos) para o rastreamento didático.
```

### Como subir este passo
```bash
git switch fase-2/nicolas-dfs
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-2/nicolas-dfs
```

Quando **todos** os passos de `fase-2/nicolas-dfs` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 3 | fase-3/pamella-desenho =="
PAI=$(criar_ou_atualizar "Fase 3: pamella-desenho (Pamella)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Transformar as posições e rotas da Etapa 5 em três imagens por caso: o cartão-relatório, o grafo de alocação e o grafo com o resultado da busca.

### Pré-requisitos
- `fase-1/raony-geometria` integrada na `main` — você consome `pos` e `rotas` dela.
- `fase-1/leandro-ciclos` integrada na `main` — o veredito impresso vem de `formatar_resultado`.
- Antes de começar: `git switch fase-3/pamella-desenho` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Continuar:** `src/etapa1_infra_e_estilo_visual_pamella.py` (a parte de desenho, depois da paleta criada na Fase 0)

### Antes de começar, confira
- As constantes `DPI_FIGURAS`, `RAIO_CIRCULO_PROCESSO`, `MEIO_LADO_QUADRADO` e a paleta **já existem** no arquivo, criadas no passo 0.4.

### O que você vai escrever
- **Recorte e seta:** `_dentro_do_no`, `_recortar_inicio` e `desenhar_aresta_estilizada(ax, pontos, origem_eh_processo, destino_eh_processo, cor, largura, estilo, tamanho_seta)`.
- **Tela comum:** `_desenhar_nos`, `_criar_tela(pos, rotas)` e `_salvar(fig, nome_png)`.
- **Imagem 1:** `salvar_grafo_alocacao(titulo, processos, recursos, arestas, pos, rotas, nome_png) -> str`.
- **Imagem 2:** `salvar_grafo_deteccao_dfs(titulo, processos, recursos, arestas, ciclos, texto_veredito, pos, rotas, nome_png) -> str`.
- **Texto dinâmico:** `descrever_diagnostico(processos, recursos, arestas, ciclos) -> List[str]`.
- **Imagem 3:** `salvar_cartao_diagnostico(titulo, processos, recursos, arestas, ciclos, texto_veredito, nome_png) -> str`.

### Pontos de atenção
- São **três imagens separadas**. Não monte painel com dois gráficos lado a lado, e não use rótulos `(a)` e `(b)`.
- Os dois grafos recebem o **mesmo** `pos` e o mesmo `rotas`, para que possam ser comparados lado a lado pelo leitor.
- A ponta da seta tem de ser sempre sólida, mesmo quando a linha é tracejada.
- Exporte sempre com `dpi=DPI_FIGURAS`. Não escreva o número 300 em nenhuma função.
- Nenhum texto pode ser fixo por caso de teste: `descrever_diagnostico` monta a explicação a partir do grafo recebido (quantos e quais processos e recursos estão presos, quem segue livre e como quebrar o ciclo).
- O cartão precisa se ajustar ao tamanho do conteúdo: calcule a largura da figura a partir da linha mais longa.

### Passos — um commit por item
- [ ] **3.P1** — `src/etapa1_infra_e_estilo_visual_pamella.py (recorte e seta)` — commit `feat(etapa1): recorte da seta na borda do nó e desenho sobre a rota`
- [ ] **3.P2** — `src/etapa1_infra_e_estilo_visual_pamella.py (nós e tela)` — commit `feat(etapa1): desenho dos nós e tela comum aos dois grafos`
- [ ] **3.P3** — `src/etapa1_infra_e_estilo_visual_pamella.py (grafo de alocação)` — commit `feat(etapa1): imagem do grafo de alocação de recursos`
- [ ] **3.P4** — `src/etapa1_infra_e_estilo_visual_pamella.py (grafo da detecção)` — commit `feat(etapa1): imagem do resultado da busca em profundidade`
- [ ] **3.P5** — `src/etapa1_infra_e_estilo_visual_pamella.py (cartão)` — commit `feat(etapa1): explicação dinâmica do resultado e cartão do caso`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Matplotlib (`Circle`, `Rectangle`, `FancyArrowPatch`), recorte na borda por bisseção, polilinha, exportação em alta resolução, geração dinâmica de texto, `textwrap`.

### Como conferir que funcionou
Gere as imagens de um caso e abra as três; depois confira que a resolução muda em todas ao alterar só `DPI_FIGURAS`.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-3/pamella-desenho` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 3.P1: etapa1 (recorte e seta)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/pamella-desenho` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 3**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (recorte e seta)`

### O que fazer neste passo
_dentro_do_no e _recortar_inicio cortam a rota exatamente na borda do círculo ou do quadrado; desenhar_aresta_estilizada desenha a polilinha devolvida pela Etapa 5 e acrescenta a ponta da seta sempre sólida, inclusive nas setas tracejadas.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): recorte da seta na borda do nó e desenho sobre a rota
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_dentro_do_no e _recortar_inicio cortam a rota exatamente na borda do círculo ou do quadrado; desenhar_aresta_estilizada desenha a polilinha devolvida pela Etapa 5 e acrescenta a ponta da seta sempre sólida, inclusive nas setas tracejadas.
```

### Como subir este passo
```bash
git switch fase-3/pamella-desenho
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/pamella-desenho
```

Quando **todos** os passos de `fase-3/pamella-desenho` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 3.P2: etapa1 (nós e tela)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/pamella-desenho` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 3**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (nós e tela)`

### O que fazer neste passo
_desenhar_nos desenha processos como círculos e recursos como quadrados; _criar_tela ajusta tamanho e enquadramento ao próprio grafo; _salvar exporta usando a constante única DPI_FIGURAS.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): desenho dos nós e tela comum aos dois grafos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
_desenhar_nos desenha processos como círculos e recursos como quadrados; _criar_tela ajusta tamanho e enquadramento ao próprio grafo; _salvar exporta usando a constante única DPI_FIGURAS.
```

### Como subir este passo
```bash
git switch fase-3/pamella-desenho
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/pamella-desenho
```

Quando **todos** os passos de `fase-3/pamella-desenho` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 3.P3: etapa1 (grafo de alocação)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/pamella-desenho` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 3**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (grafo de alocação)`

### O que fazer neste passo
salvar_grafo_alocacao gera a primeira imagem do caso: o grafo como foi lido do arquivo, em azul e ciano, com todas as setas em grafite.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): imagem do grafo de alocação de recursos
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
salvar_grafo_alocacao gera a primeira imagem do caso: o grafo como foi lido do arquivo, em azul e ciano, com todas as setas em grafite.
```

### Como subir este passo
```bash
git switch fase-3/pamella-desenho
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/pamella-desenho
```

Quando **todos** os passos de `fase-3/pamella-desenho` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 3.P4: etapa1 (grafo da detecção)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/pamella-desenho` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 3**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (grafo da detecção)`

### O que fazer neste passo
salvar_grafo_deteccao_dfs gera a segunda imagem, sobre a MESMA disposição de nós: em vermelho sólido o que pertence ao ciclo e em verde com traço cinza o que a busca liberou. As duas imagens são separadas, sem os rótulos (a) e (b).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): imagem do resultado da busca em profundidade
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
salvar_grafo_deteccao_dfs gera a segunda imagem, sobre a MESMA disposição de nós: em vermelho sólido o que pertence ao ciclo e em verde com traço cinza o que a busca liberou. As duas imagens são separadas, sem os rótulos (a) e (b).
```

### Como subir este passo
```bash
git switch fase-3/pamella-desenho
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/pamella-desenho
```

Quando **todos** os passos de `fase-3/pamella-desenho` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 3.P5: etapa1 (cartão)" "$RESP_PAMELLA" "feat" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/pamella-desenho` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 3**
**Arquivo deste passo:** `src/etapa1_infra_e_estilo_visual_pamella.py (cartão)`

### O que fazer neste passo
descrever_diagnostico monta a explicação do resultado a partir do próprio grafo (quais processos e recursos estão presos, quem segue livre e como quebrar o ciclo) e salvar_cartao_diagnostico exporta o cartão-relatório, que se ajusta sozinho ao tamanho do texto. Nenhum texto é fixo por caso de teste.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(etapa1): explicação dinâmica do resultado e cartão do caso
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
descrever_diagnostico monta a explicação do resultado a partir do próprio grafo (quais processos e recursos estão presos, quem segue livre e como quebrar o ciclo) e salvar_cartao_diagnostico exporta o cartão-relatório, que se ajusta sozinho ao tamanho do texto. Nenhum texto é fixo por caso de teste.
```

### Como subir este passo
```bash
git switch fase-3/pamella-desenho
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/pamella-desenho
```

Quando **todos** os passos de `fase-3/pamella-desenho` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 3 | fase-3/nauan-gabarito =="
PAI=$(criar_ou_atualizar "Fase 3: nauan-gabarito (Nauan)" "$RESP_NAUAN" "test" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Declarar os casos de teste oficiais e a verificação automática do resultado de cada um.

### Pré-requisitos
- `fase-1/nauan-casos-teste` integrada na `main` — os arquivos `.txt` precisam existir.
- `fase-1/leandro-ciclos` integrada na `main` — o gabarito tem de ser escrito no formato exato de `formatar_resultado`.
- Antes de começar: `git switch fase-3/nauan-gabarito` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/etapa6_testes_validacao_nauan.py`

### Antes de começar, confira
- Rode a busca em cada `.txt` e **copie** a saída para o gabarito, em vez de digitá-la: um espaço a mais reprova o caso.

### O que você vai escrever
```python
class CasoDeTeste(NamedTuple):
    sigla: str            # T1, T2, ... — vai no nome das imagens
    titulo: str           # situação e, se der, identificação do grafo
    arquivo: str          # nome do .txt em tests/
    buscar_todos: bool    # True procura todos os ciclos
    esperado: str         # saída exata de formatar_resultado()
    obrigatorio: bool     # True para T1, T2 e T3
```
- A lista `CASOS_DE_TESTE_OFICIAIS`, com os **3 casos obrigatórios** do enunciado (T1 a T3) e os **4 opcionais** da equipe (T4 a T7).
```python
def validar_gabarito_caso(sigla: str, saida_obtida: str, saida_esperada: str) -> Dict[str, str]:
```
- Devolve `sigla`, `status` (`APROVADO (PASS)` ou `FALHOU (FAIL)`), `saida_obtida` e `saida_esperada`.

### Pontos de atenção
- O campo `titulo` vira o **nome do arquivo das imagens**: escreva algo descritivo, como `Grafo 1 do Enunciado com Deadlock`.
- Casos com mais de um ciclo precisam de `buscar_todos=True`, senão a busca para no primeiro.
- Compare ignorando só os espaços das pontas (`.strip()`).

### Passos — um commit por item
- [ ] **3.N1** — `src/etapa6_testes_validacao_nauan.py (casos oficiais)` — commit `test(etapa6): cria o módulo de validação com a lista dos casos oficiais`
- [ ] **3.N2** — `src/etapa6_testes_validacao_nauan.py (validar_gabarito_caso)` — commit `test(etapa6): validar_gabarito_caso`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
`NamedTuple`, tabela de casos de teste, gabarito esperado, teste de regressão.

### Como conferir que funcionou
Depois da Fase 4, `python main.py` tem de imprimir `APROVADO (PASS)` nos sete casos.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-3/nauan-gabarito` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 3.N1: etapa6 (casos oficiais)" "$RESP_NAUAN" "test" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/nauan-gabarito` · **Responsável:** Nauan Christo de Aquino · **Fase 3**
**Arquivo deste passo:** `src/etapa6_testes_validacao_nauan.py (casos oficiais)`

### O que fazer neste passo
Cria a estrutura CasoDeTeste (sigla, título, arquivo, modo de busca, saída esperada e se é obrigatório) e a lista CASOS_DE_TESTE_OFICIAIS com os 3 casos exigidos pelo enunciado (T1 a T3) e os 4 opcionais da equipe (T4 a T7). O título de cada caso é o que dá nome às três imagens geradas.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(etapa6): cria o módulo de validação com a lista dos casos oficiais
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria a estrutura CasoDeTeste (sigla, título, arquivo, modo de busca, saída esperada e se é obrigatório) e a lista CASOS_DE_TESTE_OFICIAIS com os 3 casos exigidos pelo enunciado (T1 a T3) e os 4 opcionais da equipe (T4 a T7). O título de cada caso é o que dá nome às três imagens geradas.
```

### Como subir este passo
```bash
git switch fase-3/nauan-gabarito
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/nauan-gabarito
```

Quando **todos** os passos de `fase-3/nauan-gabarito` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 3.N2: etapa6 (validar_gabarito_caso)" "$RESP_NAUAN" "test" "Fase 3: Visualizacao e Validacao de Gabarito" <<'FIM_DO_CORPO'
**Branch:** `fase-3/nauan-gabarito` · **Responsável:** Nauan Christo de Aquino · **Fase 3**
**Arquivo deste passo:** `src/etapa6_testes_validacao_nauan.py (validar_gabarito_caso)`

### O que fazer neste passo
Compara a saída obtida pelo detector com a saída esperada e devolve APROVADO (PASS) ou FALHOU (FAIL), com os dois textos para conferência.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
test(etapa6): validar_gabarito_caso
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Compara a saída obtida pelo detector com a saída esperada e devolve APROVADO (PASS) ou FALHOU (FAIL), com os dois textos para conferência.
```

### Como subir este passo
```bash
git switch fase-3/nauan-gabarito
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-3/nauan-gabarito
```

Quando **todos** os passos de `fase-3/nauan-gabarito` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 4 | fase-4/integracao =="
PAI=$(criar_ou_atualizar "Fase 4: integracao (Pamella)" "$RESP_PAMELLA" "feat,refactor" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Ligar as seis etapas em um pipeline único e dar ao projeto uma linha de comando. É aqui que o trabalho roda inteiro pela primeira vez.

### Pré-requisitos
- `fase-2/nicolas-dfs`, `fase-3/pamella-desenho` e `fase-3/nauan-gabarito` integradas na `main`.
- Antes de começar: `git switch fase-4/integracao` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `src/detector_integrado_equipe.py`
- **Criar:** `main.py`

### Antes de começar, confira
- Importe de cada etapa **apenas** o que o integrador realmente chama: import sem uso polui o módulo e confunde a revisão.

### O que você vai escrever
```python
def montar_nome_figura(sigla: str, titulo: str, tipo: str) -> str:
```
- Monta o nome do PNG a partir da sigla, do título sem acento e do tipo (`cartao`, `grafo_alocacao`, `grafo_deteccao_dfs`).
```python
def gerar_figuras_do_caso(sigla, titulo, processos, recursos, arestas, ciclos, veredito) -> Dict[str, str]:
```
- Calcula a geometria **uma vez só**, roda `contar_colisoes_desenho` e gera as três imagens. Devolve o caminho de cada uma.
```python
def executar_analise_completa_caso(sigla, titulo, nome_arquivo_txt, buscar_todos=False, exibir_rastreamento_dfs=True, exibir_no_notebook=True) -> Dict[str, Any]:
```
- Orquestra: leitura (Etapa 2) → busca (Etapa 3) → veredito (Etapa 4) → figuras (Etapas 5 e 1).
```python
def executar_bateria_completa_cli(somente_obrigatorios: bool = False) -> List[Dict[str, Any]]:
```
- Percorre `CASOS_DE_TESTE_OFICIAIS`, executa cada caso e valida o gabarito.
- No `main.py`, o `argparse` com `--arquivo`, `--todos`, `--rastreamento` e `--obrigatorios`, e o bloco `if __name__ == "__main__":`.

### Pontos de atenção
- Chame `calcular_layout_e_rotas` **uma vez por caso** e passe o mesmo resultado para as duas imagens de grafo.
- Se a auditoria de colisões devolver algo diferente de zero, imprima um `[AVISO]` em vez de falhar: a execução não pode parar por causa do desenho.
- O `import` do `IPython.display` tem de ficar em `try/except`, para o projeto rodar no terminal sem Jupyter instalado.

### Passos — um commit por item
- [ ] **4.1** — `src/detector_integrado_equipe.py (imports)` — commit `feat(integracao): cria o integrador e importa os módulos dos 6 integrantes`
- [ ] **4.2** — `src/detector_integrado_equipe.py (nome das figuras e geração)` — commit `feat(integracao): nome descritivo das figuras e geração das três imagens`
- [ ] **4.3** — `src/detector_integrado_equipe.py (executar_analise_completa_caso)` — commit `feat(integracao): executar_analise_completa_caso`
- [ ] **4.4** — `src/detector_integrado_equipe.py (bateria completa)` — commit `feat(integracao): bateria completa de testes`
- [ ] **4.5** — `main.py (argumentos)` — commit `feat(cli): cria o main.py com argparse`
- [ ] **4.6** — `main.py (execução)` — commit `feat(cli): modo de arquivo único e bateria completa`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Integração de módulos, orquestração de pipeline, `argparse`, normalização de texto para nome de arquivo (`unicodedata`, `re`), importação opcional.

### Como conferir que funcionou
```bash
python main.py
```
Tem de terminar com `7 de 7 casos aprovados` e gravar 21 imagens em `output/figures/`.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-4/integracao` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 4.1: detector_integrado_equipe.py (imports)" "$RESP_PAMELLA" "feat,refactor" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `src/detector_integrado_equipe.py (imports)`

### O que fazer neste passo
Cria src/detector_integrado_equipe.py com o import opcional do IPython.display (exibição das figuras no notebook) e os imports das Etapas 1 a 6.

> Observação: importar apenas o que o integrador usa. Da Etapa 1, DIRETORIO_RAIZ, PASTA_TESTES, salvar_cartao_diagnostico e renderizar_painel_duplo_estilizado; da Etapa 4, só formatar_resultado; da Etapa 5, só calcular_layout_e_rotas e contar_colisoes_desenho. O repo base importa ainda PASTA_FIGURAS, isolar_ciclo_elementar, normalizar_ciclo, distancia_ponto_segmento e as 3 funções legadas, que nunca são chamadas.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(integracao): cria o integrador e importa os módulos dos 6 integrantes
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria src/detector_integrado_equipe.py com o import opcional do IPython.display (exibição das figuras no notebook) e os imports das Etapas 1 a 6.

Observação: importar apenas o que o integrador usa. Da Etapa 1, DIRETORIO_RAIZ, PASTA_TESTES, salvar_cartao_diagnostico e renderizar_painel_duplo_estilizado; da Etapa 4, só formatar_resultado; da Etapa 5, só calcular_layout_e_rotas e contar_colisoes_desenho. O repo base importa ainda PASTA_FIGURAS, isolar_ciclo_elementar, normalizar_ciclo, distancia_ponto_segmento e as 3 funções legadas, que nunca são chamadas.
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 4.2: detector_integrado_equipe.py (nome das figuras e geração)" "$RESP_PAMELLA" "feat" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `src/detector_integrado_equipe.py (nome das figuras e geração)`

### O que fazer neste passo
montar_nome_figura monta o nome descritivo de cada PNG (sigla, título do caso e tipo da imagem) e gerar_figuras_do_caso calcula a geometria uma única vez, roda a auditoria de colisões e gera as três imagens do caso: cartão, grafo de alocação e grafo da detecção, os dois últimos sobre a mesma disposição de nós.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(integracao): nome descritivo das figuras e geração das três imagens
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
montar_nome_figura monta o nome descritivo de cada PNG (sigla, título do caso e tipo da imagem) e gerar_figuras_do_caso calcula a geometria uma única vez, roda a auditoria de colisões e gera as três imagens do caso: cartão, grafo de alocação e grafo da detecção, os dois últimos sobre a mesma disposição de nós.

Co-authored-by: Raony Olivio Dias Capela <294894058+rahoneeeh@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 4.3: detector_integrado_equipe.py (executar_analise_completa_caso)" "$RESP_PAMELLA" "feat" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `src/detector_integrado_equipe.py (executar_analise_completa_caso)`

### O que fazer neste passo
Orquestra o pipeline de um caso de ponta a ponta: leitura (Etapa 2), busca em profundidade (Etapa 3), veredito (Etapa 4) e as três imagens (Etapas 5 e 1), exibindo o rastreamento da lista L quando pedido.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(integracao): executar_analise_completa_caso
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Orquestra o pipeline de um caso de ponta a ponta: leitura (Etapa 2), busca em profundidade (Etapa 3), veredito (Etapa 4) e as três imagens (Etapas 5 e 1), exibindo o rastreamento da lista L quando pedido.
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 4.4: detector_integrado_equipe.py (bateria completa)" "$RESP_PAMELLA" "feat" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `src/detector_integrado_equipe.py (bateria completa)`

### O que fazer neste passo
executar_bateria_completa_cli percorre CASOS_DE_TESTE_OFICIAIS, executa todos os casos, valida cada gabarito e imprime o resumo final. Com somente_obrigatorios=True roda apenas T1 a T3.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(integracao): bateria completa de testes
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
executar_bateria_completa_cli percorre CASOS_DE_TESTE_OFICIAIS, executa todos os casos, valida cada gabarito e imprime o resumo final. Com somente_obrigatorios=True roda apenas T1 a T3.

Co-authored-by: Nauan Christo de Aquino <278500513+Nauanx1@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 4.5: main.py (argumentos)" "$RESP_PAMELLA" "feat" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `main.py (argumentos)`

### O que fazer neste passo
Ponto de entrada por linha de comando, com as opções --arquivo (analisar um grafo específico), --rastreamento (exibir a lista L passo a passo), --todos (buscar todos os ciclos) e --obrigatorios (rodar apenas T1 a T3).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(cli): cria o main.py com argparse
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Ponto de entrada por linha de comando, com as opções --arquivo (analisar um grafo específico), --rastreamento (exibir a lista L passo a passo), --todos (buscar todos os ciclos) e --obrigatorios (rodar apenas T1 a T3).
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 4.6: main.py (execução)" "$RESP_PAMELLA" "feat" "Fase 4: Integracao e Interface CLI" <<'FIM_DO_CORPO'
**Branch:** `fase-4/integracao` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 4**
**Arquivo deste passo:** `main.py (execução)`

### O que fazer neste passo
Com --arquivo, analisa qualquer grafo de tests/ e gera as figuras; sem argumentos, executa a bateria completa T1 a T4. Primeiro ponto em que o projeto roda inteiro: python main.py deve aprovar os 4 casos.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
feat(cli): modo de arquivo único e bateria completa
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Com --arquivo, analisa qualquer grafo de tests/ e gera as figuras; sem argumentos, executa a bateria completa T1 a T4. Primeiro ponto em que o projeto roda inteiro: python main.py deve aprovar os 4 casos.
```

### Como subir este passo
```bash
git switch fase-4/integracao
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-4/integracao
```

Quando **todos** os passos de `fase-4/integracao` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 5 | fase-5/notebook =="
PAI=$(criar_ou_atualizar "Fase 5: notebook (Pamella)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Montar o relatório interativo usado na apresentação, importando os módulos de todos os integrantes e executando os casos ao vivo.

### Pré-requisitos
- `fase-4/integracao` integrada na `main` — o notebook chama o integrador.
- Antes de começar: `git switch fase-5/notebook` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Criar:** `relatorio_analise_impasses_rag.ipynb`
- **Versionar:** as imagens geradas em `output/figures/`

### Antes de começar, confira
- Rode todas as células de cima para baixo antes de salvar: o notebook é entregue **com as saídas**.

### O que você vai escrever
- Célula de apresentação com instituição, disciplina, trabalho escolhido, o enunciado resumido, a tabela da equipe por etapa, a tabela dos casos obrigatórios e opcionais e **a legenda de cores** das figuras.
- Célula de fundamentação: condições de Coffman, grafo de alocação e as fórmulas realmente usadas pelo código.
- Célula de imports, trazendo de cada um dos 6 módulos só o que as células usam.
- Célula de demonstração encadeada das Etapas 2 a 5 sobre um caso.
- Três pares de células para os casos obrigatórios T1, T2 e T3, com rastreamento da lista $L$.
- Um par de células que roda os casos **opcionais em laço** sobre `CASOS_DE_TESTE_OFICIAIS`.
- Par final de células validando os sete gabaritos e listando as figuras.

### Pontos de atenção
- Não escreva o título do caso à mão nas chamadas: use o que está em `CASOS_DE_TESTE_OFICIAIS`, para o notebook não divergir do gabarito.
- O laço dos opcionais tem de funcionar sozinho quando alguém acrescentar um oitavo caso.
- Cada cor da legenda precisa corresponder a uma constante real da paleta da Etapa 1.

### Passos — um commit por item
- [ ] **5.1** — `relatorio_analise_impasses_rag.ipynb (células 0–3)` — commit `docs(notebook): apresentação, enunciado, cores e imports`
- [ ] **5.2** — `relatorio_analise_impasses_rag.ipynb (células 4–5)` — commit `docs(notebook): demonstração encadeada das etapas 2 a 5`
- [ ] **5.3** — `relatorio_analise_impasses_rag.ipynb (células 6–11)` — commit `docs(notebook): execução dos casos obrigatórios T1, T2 e T3`
- [ ] **5.4** — `relatorio_analise_impasses_rag.ipynb (células 12–13)` — commit `docs(notebook): execução dos casos opcionais T4 a T7 em laço`
- [ ] **5.5** — `relatorio_analise_impasses_rag.ipynb (células 14–15)` — commit `docs(notebook): validação automática do gabarito`
- [ ] **5.6** — `output/figures/ (21 PNG)` — commit `chore(figuras): adiciona as 21 figuras geradas pela execução`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Jupyter Notebook, Markdown com LaTeX, demonstração reproduzível, legenda de cores, laço sobre a tabela de casos.

### Como conferir que funcionou
Reinicie o kernel e rode tudo (*Restart & Run All*). Nenhuma célula pode dar erro e a última tem de listar as 21 figuras.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-5/notebook` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 5.1: notebook (células 0–3)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `relatorio_analise_impasses_rag.ipynb (células 0–3)`

### O que fazer neste passo
Cria o relatório interativo com a identificação do trabalho, a seção do enunciado (o que foi pedido, com a tabela dos 3 casos obrigatórios e dos 4 opcionais), a seção 0.1 com as três imagens geradas por caso e o significado de cada cor usada nas figuras, a arquitetura modular da equipe, a fundamentação teórica e a célula que importa os módulos dos 6 integrantes.

> Observação: a célula de imports traz apenas o que as células usam, mais a constante DPI_FIGURAS, exibida no resumo do ambiente.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(notebook): apresentação, enunciado, cores e imports
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Cria o relatório interativo com a identificação do trabalho, a seção do enunciado (o que foi pedido, com a tabela dos 3 casos obrigatórios e dos 4 opcionais), a seção 0.1 com as três imagens geradas por caso e o significado de cada cor usada nas figuras, a arquitetura modular da equipe, a fundamentação teórica e a célula que importa os módulos dos 6 integrantes.

Observação: a célula de imports traz apenas o que as células usam, mais a constante DPI_FIGURAS, exibida no resumo do ambiente.

Co-authored-by: Cinara Oliveira da Silva <215228614+ciinara@users.noreply.github.com>
Co-authored-by: Nicolas Martins Sousa <EMAIL_NICOLAS>
Co-authored-by: Leandro Nascimento Vitório <262035625+Vitorioln@users.noreply.github.com>
Co-authored-by: Raony Olivio Dias Capela <294894058+rahoneeeh@users.noreply.github.com>
Co-authored-by: Nauan Christo de Aquino <278500513+Nauanx1@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 5.2: notebook (células 4–5)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `relatorio_analise_impasses_rag.ipynb (células 4–5)`

### O que fazer neste passo
Chama cada módulo separadamente sobre o Grafo 2 do enunciado: leitura e validação (Etapa 2), busca em profundidade (Etapa 3), saída oficial (Etapa 4) e auditoria do desenho (Etapa 5).

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(notebook): demonstração encadeada das etapas 2 a 5
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Chama cada módulo separadamente sobre o Grafo 2 do enunciado: leitura e validação (Etapa 2), busca em profundidade (Etapa 3), saída oficial (Etapa 4) e auditoria do desenho (Etapa 5).

Co-authored-by: Cinara Oliveira da Silva <215228614+ciinara@users.noreply.github.com>
Co-authored-by: Nicolas Martins Sousa <EMAIL_NICOLAS>
Co-authored-by: Leandro Nascimento Vitório <262035625+Vitorioln@users.noreply.github.com>
Co-authored-by: Raony Olivio Dias Capela <294894058+rahoneeeh@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 5.3: notebook (células 6–11)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `relatorio_analise_impasses_rag.ipynb (células 6–11)`

### O que fazer neste passo
Executa executar_analise_completa_caso para cada caso exigido pelo enunciado, com o rastreamento da lista L e as três imagens de cada um.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(notebook): execução dos casos obrigatórios T1, T2 e T3
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Executa executar_analise_completa_caso para cada caso exigido pelo enunciado, com o rastreamento da lista L e as três imagens de cada um.

Co-authored-by: Nauan Christo de Aquino <278500513+Nauanx1@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 5.4: notebook (células 12–13)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `relatorio_analise_impasses_rag.ipynb (células 12–13)`

### O que fazer neste passo
Percorre CASOS_DE_TESTE_OFICIAIS e executa os casos marcados como opcionais. Quem acrescentar um novo CasoDeTeste na Etapa 6 vê o caso aparecer aqui sem precisar editar o notebook.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(notebook): execução dos casos opcionais T4 a T7 em laço
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Percorre CASOS_DE_TESTE_OFICIAIS e executa os casos marcados como opcionais. Quem acrescentar um novo CasoDeTeste na Etapa 6 vê o caso aparecer aqui sem precisar editar o notebook.

Co-authored-by: Nauan Christo de Aquino <278500513+Nauanx1@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 5.5: notebook (células 14–15)" "$RESP_PAMELLA" "documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `relatorio_analise_impasses_rag.ipynb (células 14–15)`

### O que fazer neste passo
Valida os 7 casos com validar_gabarito_caso, indicando se cada um é obrigatório ou opcional, e lista as 21 figuras geradas em output/figures/.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs(notebook): validação automática do gabarito
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Valida os 7 casos com validar_gabarito_caso, indicando se cada um é obrigatório ou opcional, e lista as 21 figuras geradas em output/figures/.

Co-authored-by: Nauan Christo de Aquino <278500513+Nauanx1@users.noreply.github.com>
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
SUB=$(criar_ou_atualizar "Passo 5.6: output/figures/ (21 PNG)" "$RESP_PAMELLA" "chore,documentation" "Fase 5: Relatorio Tecnico e Figuras" <<'FIM_DO_CORPO'
**Branch:** `fase-5/notebook` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 5**
**Arquivo deste passo:** `output/figures/ (21 PNG)`

### O que fazer neste passo
Acrescenta as três imagens de cada um dos 7 casos (cartão, grafo de alocação e grafo da detecção), geradas pelo notebook e pelo main.py, para que o repositório mostre os resultados sem exigir execução local.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
chore(figuras): adiciona as 21 figuras geradas pela execução
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
Acrescenta as três imagens de cada um dos 7 casos (cartão, grafo de alocação e grafo da detecção), geradas pelo notebook e pelo main.py, para que o repositório mostre os resultados sem exigir execução local.
```

### Como subir este passo
```bash
git switch fase-5/notebook
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-5/notebook
```

Quando **todos** os passos de `fase-5/notebook` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"
echo; echo "== Fase 6 | fase-6/pamella-readme =="
PAI=$(criar_ou_atualizar "Fase 6: pamella-readme (Pamella)" "$RESP_PAMELLA" "documentation" "Fase 6: Documentacao Final e Entrega" <<'FIM_DO_CORPO'
### Objetivo desta etapa
Reescrever o `README.md` para a arquitetura final do projeto. Ele é a porta de entrada de quem abrir o repositório, inclusive o professor.

### Pré-requisitos
- `fase-5/notebook` integrada na `main`: só com tudo pronto dá para documentar os resultados reais.
- Antes de começar: `git switch fase-6/pamella-readme` e depois `git merge origin/main`.

### Arquivos desta etapa
- **Reescrever:** `README.md`

### Antes de começar, confira
- O `README.md` **já existe**, mas descreve a versão antiga do projeto, de arquivo único (`src/detector_impasse_dfs.py`, opção `--rastrear` e 3 casos de teste). Esse texto precisa sair inteiro.
- Copie os resultados da execução real, não de memória.

### O que você vai escrever
- Fundamentação curta: condições de Coffman e convenção visual (processo = círculo, recurso = quadrado, posse `R -> P`, solicitação `P -> R`).
- Tabela da equipe: etapa, integrante, arquivo e responsabilidade técnica.
- Árvore de arquivos comentada.
- Formato de entrada da Opção 1, com um exemplo real de `tests/`.
- Instalação (`venv` e `requirements.txt`) e execução (`python main.py`, `--arquivo`, `--rastreamento`, `--obrigatorios`, e o notebook).
- Tabela de resultados dos 3 casos obrigatórios e dos 4 opcionais, com a saída obtida e o status.
- Instruções para acrescentar um caso novo e a legenda de cores das figuras.

### Pontos de atenção
- Nenhuma menção ao repositório antigo `rag-deadlock-dfs-detector-tests`.
- Os links para os manuais de `docs/` têm de funcionar quando clicados no GitHub.

### Passos — um commit por item
- [ ] **6.1** — `README.md` — commit `docs: reescreve o README para a arquitetura modular final`

O título e a descrição completa de cada commit estão em `docs/PLANO_DE_BRANCHES.md`.

### Técnicas e palavras-chave
Documentação de projeto, Markdown, tabelas, reprodutibilidade.

### Como conferir que funcionou
Abra o `README.md` renderizado no GitHub e siga as instruções de instalação do zero numa pasta nova.

### Para fechar a etapa
`git add` dos arquivos, um commit por passo, `git push` e abra o *Pull Request* de `fase-6/pamella-readme` para a `main`.
FIM_DO_CORPO
)
SUB=$(criar_ou_atualizar "Passo 6.1: README.md" "$RESP_PAMELLA" "documentation" "Fase 6: Documentacao Final e Entrega" <<'FIM_DO_CORPO'
**Branch:** `fase-6/pamella-readme` · **Responsável:** Pamella Roberta Ferreira da Silva · **Fase 6**
**Arquivo deste passo:** `README.md`

### O que fazer neste passo
O README atual descreve a versão antiga, de arquivo único (src/detector_impasse_dfs.py, opção --rastrear e 3 casos de teste). Reescreve o documento para a versão final: divisão em 6 etapas modulares com o responsável por cada uma, estrutura de pastas, instalação via requirements.txt, execução por python main.py e pelo notebook, formato de entrada Opção 1, tabela de resultados dos 3 casos obrigatórios e dos 4 opcionais, instruções para acrescentar um novo caso e a convenção de cores das figuras.

O briefing completo da etapa (pré-requisitos, funções a criar, pontos de atenção e técnicas) está na issue-mãe desta branch.

### Mensagem de commit deste passo
Título (1ª linha):
```
docs: reescreve o README para a arquitetura modular final
```
Descrição (deixe a 2ª linha em branco e cole o resto):
```
O README atual descreve a versão antiga, de arquivo único (src/detector_impasse_dfs.py, opção --rastrear e 3 casos de teste). Reescreve o documento para a versão final: divisão em 6 etapas modulares com o responsável por cada uma, estrutura de pastas, instalação via requirements.txt, execução por python main.py e pelo notebook, formato de entrada Opção 1, tabela de resultados dos 3 casos obrigatórios e dos 4 opcionais, instruções para acrescentar um novo caso e a convenção de cores das figuras.
```

### Como subir este passo
```bash
git switch fase-6/pamella-readme
git merge origin/main        # traz o que já foi integrado
git add <os arquivos deste passo>
git commit                   # cole o título na 1ª linha e a descrição a partir da 3ª
git push origin fase-6/pamella-readme
```

Quando **todos** os passos de `fase-6/pamella-readme` estiverem commitados, abra o *Pull Request* desta branch para a `main` e marque esta caixinha na issue-mãe.
FIM_DO_CORPO
)
vincular_sub "$PAI" "$SUB"

rm -f "$ISSUES_JSON"

# --- 8) Vincular cada branch a sua issue-mae (opcional) ----------------------
echo; echo "Vinculando branches as issues-mae (Development)..."
echo "  (se a branch ja existe, o GitHub pode recusar o vinculo; nesse caso use o painel Development da issue)"
vincular_branch() {   # $1 = titulo da issue-mae | $2 = branch
  local num; num=$(gh issue list -R "$REPO" --state all --limit 200 --json number,title \
    --jq ".[] | select(.title == \"$1\") | .number" 2>/dev/null | head -1)
  [ -n "$num" ] || return 0
  gh issue develop "$num" -R "$REPO" --name "$2" >/dev/null 2>&1 \
    && echo "  [vinculada] $2 -> #$num" || echo "  [ja existia ou indisponivel] $2"
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

# --- 9) Linhas Co-authored-by ------------------------------------------------
echo; echo "Linhas Co-authored-by (para os commits compartilhados):"
for login in "$GH_PAMELLA" "$GH_RAONY" "$GH_NAUAN" "$GH_NICOLAS" "$GH_LEANDRO" "$GH_CINARA"; do
  [ -z "$login" ] && continue
  id=$(gh api "users/$login" --jq .id 2>/dev/null || true)
  nome=$(gh api "users/$login" --jq ".name // .login" 2>/dev/null || echo "$login")
  if [ -n "$id" ]; then echo "  Co-authored-by: $nome <$id+$login@users.noreply.github.com>"
  else echo "  (nao consegui ler o perfil de $login)"; fi
done

echo
echo "Concluido. Confira a aba Issues: cada issue-mae mostra a barra de progresso das suas sub-issues."
echo "Falta so proteger a main: Settings > Branches > Add branch protection rule > main"
echo "  marque \"Require a pull request before merging\" e \"Require approvals: 1\"."

#!/usr/bin/env bash
# =============================================================================
# criar_branches_e_issues.sh
# Cria, no repositorio prfs91/rag-deadlock-dfs-detector:
#   - uma branch por fase/integrante, a partir da main;
#   - uma issue por branch, atribuida ao responsavel, com os passos em checklist.
# Nao altera a main e nao envia codigo: so prepara as areas de trabalho da equipe.
#
# COMO USAR (passo a passo no README do plano):
#   1. gh auth login                  (autenticar como dona do repositorio)
#   2. git clone https://github.com/prfs91/rag-deadlock-dfs-detector.git
#   3. cd rag-deadlock-dfs-detector   (o script precisa rodar aqui, na branch main)
#   4. bash criar_branches_e_issues.sh
# =============================================================================
set -euo pipefail
REPO="prfs91/rag-deadlock-dfs-detector"

# --- 1) Usuarios do GitHub de cada integrante -------------------------------
#     Deixe vazio ("") quem ainda nao informou: a issue e criada sem responsavel.
GH_PAMELLA="prfs91"
GH_RAONY=""
GH_NAUAN=""
GH_NICOLAS=""
GH_LEANDRO=""
GH_CINARA=""

# --- 2) Verificacoes antes de comecar ---------------------------------------
command -v git >/dev/null || { echo "ERRO: git nao encontrado."; exit 1; }
command -v gh  >/dev/null || { echo "ERRO: GitHub CLI (gh) nao encontrado: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: rode primeiro: gh auth login"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "ERRO: rode dentro do clone de $REPO."; exit 1; }
if ! git remote get-url origin | grep -q "rag-deadlock-dfs-detector"; then
  echo "ERRO: este clone nao aponta para $REPO."; exit 1
fi
if [ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then
  echo "ERRO: mude para a branch main antes de rodar: git switch main"; exit 1
fi
git fetch -q origin main
echo "Repositorio: $REPO | branch base: main"

# --- 3) Uma branch por fase/integrante, criada a partir de origin/main -------
criar_branch() {   # $1 = nome da branch
  if git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1; then
    echo "  branch $1 ja existe, mantida"
  else
    git push -q origin "refs/remotes/origin/main:refs/heads/$1"
    echo "  branch $1 criada"
  fi
}
echo "Criando branches..."
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

# --- 4) Uma issue por branch, com os passos em checklist --------------------
# O corpo de cada issue vem por here-document, em Markdown, e e enviado com --body-file.
criar_issue() {   # $1 = titulo | $2 = responsavel (pode ser vazio) | corpo: stdin
  local arquivo_corpo
  arquivo_corpo=$(mktemp)
  cat > "$arquivo_corpo"
  if [ -n "$2" ]; then
    gh issue create -R "$REPO" --title "$1" --assignee "$2" --body-file "$arquivo_corpo" >/dev/null
    echo "  issue criada e atribuida a $2: $1"
  else
    gh issue create -R "$REPO" --title "$1" --body-file "$arquivo_corpo" >/dev/null
    echo "  issue criada SEM responsavel (usuario nao informado): $1"
  fi
  rm -f "$arquivo_corpo"
}
echo "Criando issues..."
criar_issue "Fase 0: pamella-estrutura (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 0 — branch `fase-0/pamella-estrutura` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 0: pamella-manuais (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 0 — branch `fase-0/pamella-manuais` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 1: nauan-casos-teste (Nauan)" "$GH_NAUAN" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 1 — branch `fase-1/nauan-casos-teste` — responsável: Nauan Christo de Aquino

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 1: cinara-leitura (Cinara)" "$GH_CINARA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 1 — branch `fase-1/cinara-leitura` — responsável: Cinara Oliveira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 1: leandro-ciclos (Leandro)" "$GH_LEANDRO" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 1 — branch `fase-1/leandro-ciclos` — responsável: Leandro Nascimento Vitório

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 1: raony-geometria (Raony)" "$GH_RAONY" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 1 — branch `fase-1/raony-geometria` — responsável: Raony Olivio Dias Capela

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 2: nicolas-dfs (Nicolas)" "$GH_NICOLAS" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 2 — branch `fase-2/nicolas-dfs` — responsável: Nicolas Martins Sousa

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 3: pamella-desenho (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 3 — branch `fase-3/pamella-desenho` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 3: nauan-gabarito (Nauan)" "$GH_NAUAN" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 3 — branch `fase-3/nauan-gabarito` — responsável: Nauan Christo de Aquino

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 4: integracao (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 4 — branch `fase-4/integracao` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 5: notebook (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 5 — branch `fase-5/notebook` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE
criar_issue "Fase 6: pamella-readme (Pamella)" "$GH_PAMELLA" <<'FIM_DO_CORPO_DA_ISSUE'
# Fase 6 — branch `fase-6/pamella-readme` — responsável: Pamella Roberta Ferreira da Silva

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
FIM_DO_CORPO_DA_ISSUE

# --- 5) E-mails Co-authored-by de quem tem conta ----------------------------
echo
echo "Linhas Co-authored-by (para os commits compartilhados do plano):"
for login in "$GH_PAMELLA" "$GH_RAONY" "$GH_NAUAN" "$GH_NICOLAS" "$GH_LEANDRO" "$GH_CINARA"; do
  [ -z "$login" ] && continue
  id=$(gh api "users/$login" --jq .id 2>/dev/null || true)
  nome=$(gh api "users/$login" --jq ".name // .login" 2>/dev/null || echo "$login")
  if [ -n "$id" ]; then
    echo "  Co-authored-by: $nome <$id+$login@users.noreply.github.com>"
  else
    echo "  (nao consegui ler o perfil de $login)"
  fi
done

echo
echo "Pronto. Agora proteja a main em Settings > Branches:"
echo "  Add branch protection rule > main > Require a pull request before merging > Require approvals: 1"

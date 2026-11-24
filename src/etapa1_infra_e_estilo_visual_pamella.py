# ------------------------------------------------------------------------------
# [PASSO 0.3 | FASE 0 | branch: fase-0/pamella-estrutura | commit e push: Roberta Ferreira]
# Cabeçalho, imports e resolução portável de DIRETORIO_RAIZ, PASTA_TESTES e PASTA_FIGURAS.
# ------------------------------------------------------------------------------
# ==============================================================================
# INÍCIO DO MÓDULO DE PAMELLA ROBERTA FERREIRA DA SILVA
# ARQUIVO: src/etapa1_infra_e_estilo_visual_pamella.py
# RESPONSABILIDADES TÉCNICAS:
#   1. Arquitetura do repositório GitHub, governança de commits, .gitignore e requirements.txt;
#   2. Resolução portável e multiplataforma de diretórios (visando clonagem imediata);
#   3. Estilização visual dos Grafos de Alocação de Recursos (Processos = Círculos,
#      Recursos = Quadrados, paleta cromática semântica de posse/espera/deadlock);
#   4. Renderização de cartões de telemetria e painéis comparativos lado a lado (200 DPI);
#   5. Orquestração e integração dos módulos de todos os integrantes da equipe.
# ==============================================================================

import os
import math
import textwrap
from typing import Dict, List, Set, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch, Rectangle

def obter_caminhos_portaveis_repositorio() -> Tuple[str, str, str]:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Resolve dinamicamente a raiz do repositório clonado em qualquer Sistema Operacional
    (Windows, Linux ou macOS), garantindo que 'tests/' e 'output/figures/' sejam
    localizados ou criados sem caminhos absolutos fixos (hardcoded).
    """
    dir_atual = os.path.dirname(os.path.abspath(__file__))
    raiz_repo = os.path.abspath(os.path.join(dir_atual, ".."))
    pasta_testes = os.path.join(raiz_repo, "tests")
    pasta_figuras = os.path.join(raiz_repo, "output", "figures")
    os.makedirs(pasta_testes, exist_ok=True)
    os.makedirs(pasta_figuras, exist_ok=True)
    return raiz_repo, pasta_testes, pasta_figuras
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

DIRETORIO_RAIZ, PASTA_TESTES, PASTA_FIGURAS = obter_caminhos_portaveis_repositorio()

# ------------------------------------------------------------------------------
# [PASSO 0.4 | FASE 0 | branch: fase-0/pamella-estrutura | commit e push: Roberta Ferreira]
# Paleta cromática dos grafos (processos, recursos, ciclo e arestas).
# ------------------------------------------------------------------------------
# ==============================================================================
# PALETA CROMÁTICA E ESTILIZAÇÃO GEOMÉTRICA DOS GRAFOS
# ==============================================================================

COR_NO_DEADLOCK = "#e74c3c"       # Vermelho: vértice bloqueado em espera circular (deadlock)
COR_NO_SEGURO = "#2ecc71"         # Verde: vértice inspecionado e livre de impasse
COR_PROCESSO_CIRCULO = "#3498db"  # Azul: Processo representado como Círculo (Holt, 1972)
COR_RECURSO_QUADRADO = "#7ae2ff"  # Ciano: Recurso representado como Quadrado (Holt, 1972)
COR_BORDA_PROCESSO = "#1b4f72"    # Azul marinho: contorno geométrico dos círculos
COR_BORDA_RECURSO = "#117864"     # Verde petróleo: contorno geométrico dos quadrados
COR_ARESTA_NORMAL = "#2c3e50"     # Grafite escuro: arco dirigido no grafo original
COR_ARESTA_CICLO = "#c0392b"      # Vermelho intenso: arco pertencente ao ciclo de impasse
COR_ARESTA_SEGURA = "#7f8c8d"     # Cinza tracejado: arco fora do ciclo após varredura DFS

# ==============================================================================
# RESOLUÇÃO DE EXPORTAÇÃO — altere aqui para mudar TODAS as imagens de uma vez
# ==============================================================================

DPI_FIGURAS = 200                 # resolução (pontos por polegada) do cartão e dos dois grafos

# Medidas dos nós, em unidades do próprio gráfico
RAIO_CIRCULO_PROCESSO = 0.36      # raio do círculo que representa um processo
MEIO_LADO_QUADRADO = 0.33         # metade do lado do quadrado que representa um recurso

# ------------------------------------------------------------------------------
# [PASSO 3.P1 | FASE 3 | branch: fase-3/pamella-desenho | commit e push: Pamella Roberta]
# Recorte da seta na borda do círculo/quadrado e desenho da seta sobre a rota.
# ------------------------------------------------------------------------------

def _dentro_do_no(ponto, centro, eh_processo: bool, folga: float) -> bool:
    """Diz se um ponto cai dentro do círculo (processo) ou do quadrado (recurso)."""
    dx, dy = ponto[0] - centro[0], ponto[1] - centro[1]
    if eh_processo:
        return math.hypot(dx, dy) <= RAIO_CIRCULO_PROCESSO + folga
    return max(abs(dx), abs(dy)) <= MEIO_LADO_QUADRADO + folga

def _recortar_inicio(pontos, centro, eh_processo: bool, folga: float):
    """Corta o pedaço da rota que está dentro do nó de origem, achando a borda por bisseção."""
    for i in range(len(pontos) - 1):
        p, q = pontos[i], pontos[i + 1]
        if _dentro_do_no(q, centro, eh_processo, folga):
            continue
        a, b = 0.0, 1.0
        for _ in range(30):
            m = (a + b) / 2.0
            meio = (p[0] + (q[0] - p[0]) * m, p[1] + (q[1] - p[1]) * m)
            if _dentro_do_no(meio, centro, eh_processo, folga):
                a = m
            else:
                b = m
        borda = (p[0] + (q[0] - p[0]) * b, p[1] + (q[1] - p[1]) * b)
        return [borda] + list(pontos[i + 1:])
    return list(pontos)

def desenhar_aresta_estilizada(
    ax,
    pontos: List[Tuple[float, float]],
    origem_eh_processo: bool,
    destino_eh_processo: bool,
    cor: str,
    largura: float,
    estilo,
    tamanho_seta: float
) -> None:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Desenha a aresta dirigida u -> v sobre a rota calculada pela Etapa 5: a linha é
    recortada nas bordas dos dois nós e a ponta da seta, sempre sólida (mesmo em
    arestas tracejadas), encosta na borda do nó de destino.
    """
    pts = _recortar_inicio(pontos, pontos[0], origem_eh_processo, 0.02)
    pts = _recortar_inicio(pts[::-1], pontos[-1], destino_eh_processo, 0.04)[::-1]

    xs, ys = zip(*pts)
    ax.plot(xs, ys, color=cor, linewidth=largura, linestyle=estilo,
            solid_joinstyle="miter", solid_capstyle="butt", dash_capstyle="butt", zorder=3)

    (x0, y0), (x1, y1) = pts[-2], pts[-1]
    comprimento = math.hypot(x1 - x0, y1 - y0) or 1.0
    recuo = min(0.12, comprimento * 0.5)
    base = (x1 - (x1 - x0) * recuo / comprimento, y1 - (y1 - y0) * recuo / comprimento)
    ax.add_patch(FancyArrowPatch(
        posA=base, posB=(x1, y1),
        arrowstyle=f"-|>,head_length={tamanho_seta * 0.034:.3f},head_width={tamanho_seta * 0.022:.3f}",
        mutation_scale=20, color=cor, linewidth=largura * 0.6, linestyle="solid",
        shrinkA=0, shrinkB=0, zorder=3
    ))
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

    # ------------------------------------------------------------------------------
# [PASSO 3.P2 | FASE 3 | branch: fase-3/pamella-desenho | commit e push: Pamella Roberta]
# Desenho dos nós e preparação da tela comum aos dois grafos.
# ------------------------------------------------------------------------------

def _desenhar_nos(ax, pos, processos, recursos, cores_processos, cores_recursos,
                  cor_borda_processo, cor_borda_recurso, cor_texto) -> None:
    """Desenha processos como círculos e recursos como quadrados, com os nomes centralizados."""
    for i, p in enumerate(processos):
        ax.add_patch(Circle(pos[p], RAIO_CIRCULO_PROCESSO, facecolor=cores_processos[i],
                            edgecolor=cor_borda_processo, linewidth=2.0, zorder=4))
    for i, r in enumerate(recursos):
        x, y = pos[r]
        ax.add_patch(Rectangle((x - MEIO_LADO_QUADRADO, y - MEIO_LADO_QUADRADO),
                               2 * MEIO_LADO_QUADRADO, 2 * MEIO_LADO_QUADRADO,
                               facecolor=cores_recursos[i], edgecolor=cor_borda_recurso,
                               linewidth=2.0, zorder=4))
    for no in list(processos) + list(recursos):
        ax.text(pos[no][0], pos[no][1], no, ha="center", va="center", fontsize=11.5,
                fontweight="bold", color=cor_texto, zorder=5)

def _criar_tela(pos, rotas):
    """Cria a figura de um grafo, com tamanho e enquadramento ajustados ao próprio desenho."""
    xs = [p[0] for p in pos.values()] + [p[0] for pts in rotas.values() for p in pts]
    ys = [p[1] for p in pos.values()] + [p[1] for pts in rotas.values() for p in pts]
    margem = 0.9
    x_min, x_max = min(xs) - margem, max(xs) + margem
    y_min, y_max = min(ys) - margem, max(ys) + margem
    largura_dados, altura_dados = x_max - x_min, y_max - y_min
    escala = min(0.95, 7.2 / largura_dados, 6.0 / altura_dados)   # polegadas por unidade
    fig, ax = plt.subplots(figsize=(max(7.6, largura_dados * escala),
                                    max(3.2, altura_dados * escala) + 1.1))
    ax.set_xlim(x_min, x_max)
    ax.set_ylim(y_min, y_max)
    ax.set_aspect("equal")
    ax.set_axis_off()
    return fig, ax

def _salvar(fig, nome_png: str) -> str:
    """Exporta a figura em DPI_FIGURAS e devolve o caminho do arquivo gravado."""
    caminho = os.path.join(PASTA_FIGURAS, nome_png)
    plt.tight_layout()
    plt.savefig(caminho, bbox_inches="tight", dpi=DPI_FIGURAS, facecolor="white")
    plt.close(fig)
    return caminho

# ------------------------------------------------------------------------------
# [PASSO 3.P3 | FASE 3 | branch: fase-3/pamella-desenho | commit e push: Pamella Roberta]
# salvar_grafo_alocacao: imagem do grafo de alocação de recursos (entrada).
# ------------------------------------------------------------------------------

def salvar_grafo_alocacao(
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    pos: Dict[str, Tuple[float, float]],
    rotas: Dict[Tuple[str, str], List[Tuple[float, float]]],
    nome_png: str
) -> str:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Gera a imagem do Grafo de Alocação de Recursos tal como foi lido do arquivo:
    processos em círculos azuis, recursos em quadrados ciano e todas as setas em
    grafite. As posições e rotas vêm da Etapa 5. Salva o PNG em 'output/figures/'.
    """
    conj_p = set(processos)
    fig, ax = _criar_tela(pos, rotas)
    _desenhar_nos(ax, pos, processos, recursos,
                  [COR_PROCESSO_CIRCULO] * len(processos),
                  [COR_RECURSO_QUADRADO] * len(recursos),
                  COR_BORDA_PROCESSO, COR_BORDA_RECURSO, "#17202a")
    for (u, v) in arestas:
        desenhar_aresta_estilizada(ax, rotas[(u, v)], u in conj_p, v in conj_p,
                                   COR_ARESTA_NORMAL, 2.1, "solid", 21)
    ax.set_title(
        f"Grafo de Alocação de Recursos — {titulo}\n"
        f"● Círculos: Processos ({len(processos)})   |   ■ Quadrados: Recursos ({len(recursos)})",
        fontsize=11.5, fontweight="bold", pad=14
    )
    return _salvar(fig, nome_png)
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

# ------------------------------------------------------------------------------
# [PASSO 3.P4 | FASE 3 | branch: fase-3/pamella-desenho | commit e push: Pamella Roberta]
# salvar_grafo_deteccao_dfs: imagem do resultado da busca em profundidade.
# ------------------------------------------------------------------------------

def salvar_grafo_deteccao_dfs(
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]],
    texto_veredito: str,
    pos: Dict[str, Tuple[float, float]],
    rotas: Dict[Tuple[str, str], List[Tuple[float, float]]],
    nome_png: str
) -> str:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Gera a imagem do resultado da Busca em Profundidade sobre o MESMO desenho do
    grafo de alocação: em vermelho sólido o que pertence ao ciclo de impasse e em
    verde com traço cinza o que a busca percorreu e liberou. Salva em 'output/figures/'.
    """
    conj_p = set(processos)
    nos_ciclo: Set[str] = set()
    arestas_ciclo: Set[Tuple[str, str]] = set()
    for ciclo in ciclos:
        nos_ciclo.update(ciclo)
        for i in range(len(ciclo) - 1):
            arestas_ciclo.add((ciclo[i], ciclo[i + 1]))

    fig, ax = _criar_tela(pos, rotas)
    _desenhar_nos(ax, pos, processos, recursos,
                  [COR_NO_DEADLOCK if p in nos_ciclo else COR_NO_SEGURO for p in processos],
                  [COR_NO_DEADLOCK if r in nos_ciclo else COR_NO_SEGURO for r in recursos],
                  "#17202a", "#17202a", "white")
    for (u, v) in arestas:
        em_ciclo = (u, v) in arestas_ciclo
        desenhar_aresta_estilizada(
            ax, rotas[(u, v)], u in conj_p, v in conj_p,
            COR_ARESTA_CICLO if em_ciclo else COR_ARESTA_SEGURA,
            3.2 if em_ciclo else 1.6,
            "solid" if em_ciclo else (0, (4, 3)),
            24 if em_ciclo else 19
        )
    ax.set_title(
        f"Detecção por Busca em Profundidade (DFS) — {titulo}\n"
        f"{texto_veredito.replace(chr(10), ' | ')}",
        fontsize=11.5, fontweight="bold",
        color=COR_ARESTA_CICLO if ciclos else "#1e8449", pad=14
    )
    return _salvar(fig, nome_png)
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

    # ------------------------------------------------------------------------------
# [PASSO 3.P5 | FASE 3 | branch: fase-3/pamella-desenho | commit e push: Pamella Roberta]
# Explicação dinâmica do resultado e cartão de diagnóstico do caso.
# ------------------------------------------------------------------------------

def descrever_diagnostico(
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]]
) -> List[str]:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Monta, a partir do próprio grafo lido, a explicação do resultado em linguagem
    corrente. Não há texto fixo por caso de teste: qualquer arquivo .txt no formato
    da Opção 1 gera a sua própria descrição.
    """
    conj_p = set(processos)
    if not ciclos:
        bloqueados = {u for u, v in arestas if u in conj_p and any(v == a for a, _ in arestas)}
        return [
            "Nenhum nó se repetiu na lista L: toda busca terminou em beco sem saída e retrocedeu.",
            "Como não há espera circular, a fila de espera sempre chega a um processo que nada pede,",
            "e esse processo libera o que possui, destravando quem vem atrás."
            if bloqueados else
            "Como não há espera circular, nenhum processo fica bloqueado indefinidamente.",
        ]

    linhas: List[str] = []
    presos: Set[str] = set()
    for i, ciclo in enumerate(ciclos, 1):
        nos = ciclo[:-1] if len(ciclo) > 1 and ciclo[0] == ciclo[-1] else list(ciclo)
        p_ciclo = [n for n in nos if n in conj_p]
        r_ciclo = [n for n in nos if n not in conj_p]
        presos.update(p_ciclo)
        rotulo = f"Ciclo {i}: " if len(ciclos) > 1 else ""
        linhas.append(
            f"{rotulo}{len(p_ciclo)} processo(s) ({', '.join(p_ciclo)}) e "
            f"{len(r_ciclo)} recurso(s) ({', '.join(r_ciclo)}) presos em espera circular."
        )
    linhas.append(
        "Cada processo do ciclo mantém um recurso e pede outro que já está tomado, "
        "então nenhum deles avança."
    )
    livres = [p for p in processos if p not in presos]
    if livres:
        linhas.append(
            f"Fora do impasse: {len(livres)} processo(s) ({', '.join(livres)}) seguem livres."
        )
    else:
        linhas.append("Todos os processos declarados estão presos no impasse.")
    linhas.append(
        "Para resolver, basta quebrar o ciclo: encerrar ou preemptar um dos processos presos "
        "libera o recurso que ele mantém."
    )
    return linhas
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

def salvar_cartao_diagnostico(
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]],
    texto_veredito: str,
    nome_png: str
) -> str:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Exporta o cartão-relatório do caso: contagem e nomes dos processos e recursos,
    arcos de posse (R -> P) e de solicitação (P -> R), o veredito da Etapa 4 e a
    explicação devolvida por descrever_diagnostico(). Todo o conteúdo é derivado do
    arquivo lido, então o cartão se ajusta sozinho a qualquer caso de teste.
    """
    conj_p = set(processos)
    posse = [f"{u}->{v}" for u, v in arestas if u not in conj_p]
    solicitacao = [f"{u}->{v}" for u, v in arestas if u in conj_p]

    def dobrar(rotulo: str, itens: List[str]) -> List[str]:
        corpo = ", ".join(itens) if itens else "(nenhum)"
        return textwrap.wrap(f"{rotulo} — {len(itens)}: {corpo}", width=104,
                             subsequent_indent=" " * (len(rotulo) + 3)) or [f"{rotulo} — 0: (nenhum)"]

    linhas = [f"RELATÓRIO DE DETECÇÃO DE IMPASSE (DFS) — CASO: [ {titulo} ]"]
    corpo: List[str] = []
    corpo += dobrar("Processos (círculos)", list(processos))
    corpo += dobrar("Recursos (quadrados)", list(recursos))
    corpo += dobrar("Arcos de posse (recurso -> processo)", posse)
    corpo += dobrar("Arcos de solicitação (processo -> recurso)", solicitacao)
    corpo.append("")
    for i, linha in enumerate(texto_veredito.split("\n")):
        corpo.append(f"Diagnóstico: {linha}" if i == 0 else f"             {linha.strip()}")
    for explicacao in descrever_diagnostico(processos, recursos, arestas, ciclos):
        corpo += textwrap.wrap(explicacao, width=104, initial_indent="  ", subsequent_indent="  ")

    largura_texto = max(len(l) for l in linhas + corpo)
    linhas.append("-" * largura_texto)
    linhas += corpo

    fig, ax = plt.subplots(figsize=(max(9.0, 0.105 * largura_texto),
                                    max(2.4, 0.30 * len(linhas) + 0.8)))
    ax.set_axis_off()
    ax.text(
        0.015, 0.5, "\n".join(linhas), family="monospace", fontsize=9.8,
        verticalalignment="center", linespacing=1.55, fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.65",
                  facecolor="#fdf2e9" if ciclos else "#eafaf1",
                  edgecolor=COR_NO_DEADLOCK if ciclos else COR_NO_SEGURO, lw=2.2)
    )
    return _salvar(fig, nome_png)
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

# ==============================================================================
# FIM DO MÓDULO DE PAMELLA ROBERTA FERREIRA DA SILVA
# ==============================================================================
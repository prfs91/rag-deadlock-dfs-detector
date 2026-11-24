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
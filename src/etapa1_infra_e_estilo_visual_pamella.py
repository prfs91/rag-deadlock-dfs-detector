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
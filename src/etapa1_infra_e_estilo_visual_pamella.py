# ------------------------------------------------------------------------------
# [PASSO 0.3 | FASE 0 | branch: fase-0/pamella-estrutura | commit e push: Pamella Roberta]
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
#   4. Renderização de cartões de telemetria e painéis comparativos lado a lado (300 DPI);
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
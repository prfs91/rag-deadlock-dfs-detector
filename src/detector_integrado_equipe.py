# ------------------------------------------------------------------------------
# [PASSO 4.1 | FASE 4 | branch: fase-4/integracao | commit e push: Pamella Roberta]
# Cabeçalho do integrador e imports dos módulos das 6 etapas.
# ------------------------------------------------------------------------------
# ==============================================================================
# ARQUIVO INTEGRADO: src/detector_integrado_equipe.py
# INTEGRADORA RESPONSÁVEL: Pamella Roberta Ferreira da Silva
# DESCRIÇÃO: Integra os módulos individuais dos 6 integrantes da equipe em um
#            pipeline único invocável pelo CLI (main.py) e pelo Jupyter Notebook
#            de apresentação (relatorio_analise_impasses_rag.ipynb).
# ==============================================================================

import os
import re
import unicodedata
from typing import Any, Dict, List, Tuple

try:
    from IPython.display import Image, display
    POSSUI_IPYTHON = True
except ImportError:
    POSSUI_IPYTHON = False

# Etapa 1: Infraestrutura, Estilização e Renderização (Pamella Roberta Ferreira da Silva)
from src.etapa1_infra_e_estilo_visual_pamella import (
    DIRETORIO_RAIZ,
    PASTA_TESTES,
    salvar_cartao_diagnostico,
    salvar_grafo_alocacao,
    salvar_grafo_deteccao_dfs
)

# Etapa 2: Leitura (Opção 1) e Validação Bipartida (Cinara Oliveira da Silva)
from src.etapa2_leitura_validacao_cinara import carregar_e_validar_grafo

# Etapa 3: Motor de Busca em Profundidade - DFS (Nicolas Martins Sousa)
from src.etapa3_motor_dfs_nicolas import detectar_impasses_dfs

# Etapa 4: Isolamento de Ciclos e Saída Oficial (Leandro Nascimento Vitório)
from src.etapa4_ciclos_e_saida_leandro import formatar_resultado

# Etapa 5: Disposição Ortogonal e Roteamento Anticolisão (Raony Olivio Dias Capela)
from src.etapa5_geometria_anticolisao_raony import (
    calcular_layout_e_rotas,
    contar_colisoes_desenho
)

# Etapa 6: Casos de Teste e Validação de Gabarito (Nauan Christo de Aquino)
from src.etapa6_testes_validacao_nauan import (
    CASOS_DE_TESTE_OFICIAIS,
    validar_gabarito_caso
)
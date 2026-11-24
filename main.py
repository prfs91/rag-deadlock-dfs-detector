# ------------------------------------------------------------------------------
# [PASSO 4.5 | FASE 4 | branch: fase-4/integracao | commit e push: Pamella Roberta]
# Cabeçalho, imports e argumentos de linha de comando (argparse).
# ------------------------------------------------------------------------------
#!/usr/bin/env python3
# ==============================================================================
# ARQUIVO: main.py
# RESPONSÁVEL PELA INTEGRAÇÃO E CLI: Pamella Roberta Ferreira da Silva
# DESCRIÇÃO: Ponto de entrada via linha de comando (CLI) para execução individual
#            de arquivos de grafo (.txt) ou da bateria completa de casos de teste
#            (T1 a T3 obrigatórios e T4 a T7 opcionais).
# EXEMPLOS DE USO:
#   python main.py
#   python main.py --arquivo tests/caso_slide40_multiplos_nos.txt --rastreamento
# ==============================================================================

import os
import sys
import argparse

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.detector_integrado_equipe import (
    executar_bateria_completa_cli,
    carregar_e_validar_grafo,
    detectar_impasses_dfs,
    formatar_resultado,
    gerar_figuras_do_caso
)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Detector de Deadlock com Grafo de Alocação de Recursos por Busca em Profundidade (DFS)."
    )
    parser.add_argument(
        "--arquivo", "-a",
        type=str,
        default=None,
        help="Caminho para um arquivo .txt específico no formato Opção 1 (Lista de Arestas)."
    )
    parser.add_argument(
        "--todos", "-t",
        action="store_true",
        help="Busca todos os ciclos elementares disjuntos presentes no grafo."
    )
    parser.add_argument(
        "--rastreamento", "-r",
        action="store_true",
        help="Exibe o log passo a passo da lista L e marcação de arcos durante a DFS."
    )
    parser.add_argument(
        "--obrigatorios", "-o",
        action="store_true",
        help="Na bateria completa, executa apenas os casos obrigatórios T1, T2 e T3."
    )
    args = parser.parse_args()
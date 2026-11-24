from typing import Dict, List, Tuple

def carregar_e_validar_grafo(
    caminho_arquivo: str
) -> Tuple[List[str], List[str], Dict[str, List[str]], List[Tuple[str, str]]]:
    """
    [INÍCIO DA FUNÇÃO - Autora: Cinara Oliveira da Silva]
    Lê um arquivo de texto (.txt) no formato Opção 1 (Lista de Arestas) e valida:
      1. Disjunção estrita entre os conjuntos de Processos (P) e Recursos (R);
      2. Propriedade de Grafo Dirigido Bipartido (arestas alternam P e R);
      3. Restrição de 1 recurso de cada tipo (cada recurso R possui no máximo 1 arco R -> P).
    Retorna: (lista_processos, lista_recursos, dicionario_adjacencia, lista_arestas).
    """
    processos: List[str] = []
    recursos: List[str] = []
    arestas: List[Tuple[str, str]] = []
    lendo_arestas = False

    with open(caminho_arquivo, "r", encoding="utf-8") as f:
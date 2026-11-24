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





        for num_linha, linha_bruta in enumerate(f, 1):
                    linha = linha_bruta.split("#")[0].strip()
                    if not linha:
                        continue
                    partes = linha.split()
                    cabecalho = partes[0].upper()
        
                    if cabecalho == "PROCESSOS":
                        processos.extend(partes[1:])
                        lendo_arestas = False
                    elif cabecalho == "RECURSOS":
                        recursos.extend(partes[1:])
                        lendo_arestas = False
                    elif cabecalho == "ARESTAS":
                        lendo_arestas = True
                    elif lendo_arestas and len(partes) == 2:
                        arestas.append((partes[0], partes[1]))
                    else:
                        raise ValueError(f"Erro sintático na linha {num_linha}: '{linha}'")


    conj_proc = set(processos)
    conj_rec = set(recursos)
    if conj_proc.intersection(conj_rec):
        raise ValueError(
            "Erro semântico: Há vértices declarados simultaneamente como Processo e Recurso."
        )
    
    recursos_em_posse: Dict[str, str] = {}
    adjacencia: Dict[str, List[str]] = {no: [] for no in processos + recursos}
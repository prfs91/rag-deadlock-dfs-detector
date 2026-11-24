from typing import Dict, List, Set, Tuple, Optional
from src.etapa4_ciclos_e_saida_leandro import isolar_ciclo_elementar, normalizar_ciclo

def detectar_impasses_dfs(
    processos: List[str],
    recursos: List[str],
    adjacencia: Dict[str, List[str]],
    buscar_todos: bool = False
) -> Tuple[List[List[str]], List[str]]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Nicolas Martins Sousa]
    Executa a Busca em Profundidade (DFS) tomando cada vértice N como raiz:
      - Passo 1 e 2: Inicializa L = [] e conjunto de arcos marcados vazio para cada raiz;
      - Passo 3: Ao visitar um nó que já figura em L, detecta ciclo e aciona o isolamento;
      - Passo 4 e 5: Percorre e marca o primeiro arco de saída desmarcado (u -> v);
      - Passo 6: Ao atingir beco sem saída, remove o nó de L (pop) e retrocede ao pai.
    """
    ciclos: List[List[str]] = []
    assinaturas: Set[Tuple[str, ...]] = set()
    log_passos: List[str] = []
    todos_nos = processos + recursos
    ordem_nos = {no: i for i, no in enumerate(todos_nos)}



def percorrer_ramo_dfs_recursivo(
        no_atual: str,
        lista_L: List[str],
        arcos_marcados: Set[Tuple[str, str]]
    ) -> Optional[List[str]]:
        if no_atual in lista_L:
            ciclo_limpo = isolar_ciclo_elementar(lista_L, no_atual, ordem_nos)
            log_passos.append(
                f"  [CICLO DETECTADO!] Nó '{no_atual}' repetido em L={lista_L + [no_atual]} "
                f"-> Ciclo extraído: {' -> '.join(ciclo_limpo)}"
            )
            assinatura = normalizar_ciclo(ciclo_limpo)
            if assinatura not in assinaturas:
                assinaturas.add(assinatura)
                ciclos.append(ciclo_limpo)
            return ciclo_limpo
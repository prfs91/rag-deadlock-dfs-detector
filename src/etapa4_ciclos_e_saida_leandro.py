# ------------------------------------------------------------------------------
# [PASSO 1.L1 | FASE 1 | branch: fase-1/leandro-ciclos | commit e push: Leandro Nascimento]
# Cabeçalho do módulo e isolar_ciclo_elementar.
# ------------------------------------------------------------------------------
# ==============================================================================
# INÍCIO DO MÓDULO DE LEANDRO NASCIMENTO VITÓRIO
# ARQUIVO: src/etapa4_ciclos_e_saida_leandro.py
# RESPONSABILIDADES TÉCNICAS:
#   1. Isolamento matemático do ciclo elementar a partir da lista L da DFS,
#      podando o caminho prefixo que apenas conduziu ao ciclo (ex.: remove 'B'
#      de L = [B, T, E, V, G, U, D, T] no Slide 40);
#   2. Rotação e normalização canônica de ciclos para evitar duplicatas;
#   3. Formatação oficial da string de diagnóstico ("Há deadlock (...)" ou "Sem deadlock").
# ==============================================================================

from typing import Dict, List, Tuple

def isolar_ciclo_elementar(
    lista_L: List[str],
    no_repetido: str,
    ordem_nos: Dict[str, int]
) -> List[str]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Leandro Nascimento Vitório]
    Extrai o ciclo elementar fechado a partir da primeira ocorrência de 'no_repetido'
    na lista ativa L, descartando vértices prefixos fora do laço e ancorando a exibição
    no primeiro processo/vértice segundo a ordem de declaração.
    """
    idx_inicio = lista_L.index(no_repetido)
    nucleo = lista_L[idx_inicio:]
    if len(nucleo) > 1 and nucleo[-1] == no_repetido:
        nucleo = nucleo[:-1]
    ancora = min(nucleo, key=lambda n: ordem_nos.get(n, 9999))
    idx_ancora = nucleo.index(ancora)
    return nucleo[idx_ancora:] + nucleo[:idx_ancora] + [ancora]
    # [FIM DA FUNÇÃO - Autor: Leandro Nascimento Vitório]
# ------------------------------------------------------------------------------
# [PASSO 1.L2 | FASE 1 | branch: fase-1/leandro-ciclos | commit e push: Leandro Nascimento]
# normalizar_ciclo: assinatura canônica para não repetir ciclos.
# ------------------------------------------------------------------------------

def normalizar_ciclo(ciclo: List[str]) -> Tuple[str, ...]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Leandro Nascimento Vitório]
    Gera uma assinatura canônica invariante à rotação para impedir que o mesmo
    ciclo elementar seja contabilizado mais de uma vez em grafos com múltiplos ramos.
    """
    nos = ciclo[:-1]
    menor = min(nos)
    idx = nos.index(menor)
    return tuple(nos[idx:] + nos[:idx])
    # [FIM DA FUNÇÃO - Autor: Leandro Nascimento Vitório]
# ------------------------------------------------------------------------------
# [PASSO 1.L3 | FASE 1 | branch: fase-1/leandro-ciclos | commit e push: Leandro Nascimento]
# formatar_resultado: saída oficial exigida pelo enunciado.
# ------------------------------------------------------------------------------

def formatar_resultado(ciclos: List[List[str]]) -> str:
    """
    [INÍCIO DA FUNÇÃO - Autor: Leandro Nascimento Vitório]
    Formata a mensagem oficial exigida pela especificação do Trabalho 2:
    'Há deadlock (D -> T -> E -> V -> G -> U -> D)' ou 'Sem deadlock'.
    """
    if not ciclos:
        return "Sem deadlock"
    if len(ciclos) == 1:
        return f"Há deadlock ({' -> '.join(ciclos[0])})"
    linhas = [f"Há deadlock ({len(ciclos)} ciclos encontrados):"]
    for i, c in enumerate(ciclos, 1):
        linhas.append(f"  Ciclo {i}: {' -> '.join(c)}")
    return "\n".join(linhas)
    # [FIM DA FUNÇÃO - Autor: Leandro Nascimento Vitório]

# ==============================================================================
# FIM DO MÓDULO DE LEANDRO NASCIMENTO VITÓRIO
# ==============================================================================
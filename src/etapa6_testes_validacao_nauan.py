# ------------------------------------------------------------------------------
# [PASSO 3.N1 | FASE 3 | branch: fase-3/nauan-gabarito | commit e push: Nauan Christo]
# Cabeçalho, estrutura CasoDeTeste e lista CASOS_DE_TESTE_OFICIAIS (T1 a T7).
# ------------------------------------------------------------------------------
# ==============================================================================
# INÍCIO DO MÓDULO DE NAUAN CHRISTO DE AQUINO
# ARQUIVO: src/etapa6_testes_validacao_nauan.py
# RESPONSABILIDADES TÉCNICAS:
#   1. Modelagem dos arquivos de entrada em tests/ no formato Opção 1;
#   2. Especificação dos casos obrigatórios (T1 a T3) e opcionais (T4 a T7),
#      com o gabarito exato esperado de cada um;
#   3. Validação automática do resultado do detector contra esse gabarito.
# ==============================================================================

from typing import Dict, List, NamedTuple

class CasoDeTeste(NamedTuple):
    """Um caso de teste do trabalho: entrada, modo de busca e resultado esperado."""
    sigla: str            # identificador curto usado nos nomes das imagens (T1, T2, ...)
    titulo: str           # descrição do grafo e da situação, usada nos títulos e nos arquivos
    arquivo: str          # nome do .txt dentro de tests/
    buscar_todos: bool    # True procura todos os ciclos; False para no primeiro encontrado
    esperado: str         # saída exata que formatar_resultado() deve produzir
    obrigatorio: bool     # True para os 3 casos exigidos pelo enunciado

CASOS_DE_TESTE_OFICIAIS: List[CasoDeTeste] = [
    # ---------------------- Obrigatórios pelo enunciado ----------------------
    CasoDeTeste(
        sigla="T1",
        titulo="Grafo da Aula com Beco Sem Saída e Ciclo",
        arquivo="caso_slide40_multiplos_nos.txt",
        buscar_todos=False,
        esperado="Há deadlock (D -> T -> E -> V -> G -> U -> D)",
        obrigatorio=True,
    ),
    CasoDeTeste(
        sigla="T2",
        titulo="Grafo 1 do Enunciado com Deadlock",
        arquivo="caso_grafo1_concorrente_seguro.txt",
        buscar_todos=False,
        esperado="Há deadlock (D -> T -> E -> V -> Z -> U -> D)",
        obrigatorio=True,
    ),
    CasoDeTeste(
        sigla="T3",
        titulo="Grafo 2 do Enunciado sem Deadlock",
        arquivo="caso_grafo2_espera_circular.txt",
        buscar_todos=False,
        esperado="Sem deadlock",
        obrigatorio=True,
    ),
    # ------------------------- Opcionais da equipe ---------------------------
    CasoDeTeste(
        sigla="T4",
        titulo="Dois Ciclos Disjuntos com Impasse Duplo",
        arquivo="caso_extra_multiplos_ciclos.txt",
        buscar_todos=True,
        esperado=("Há deadlock (2 ciclos encontrados):\n"
                  "  Ciclo 1: A -> S -> B -> R -> A\n"
                  "  Ciclo 2: C -> U -> D -> T -> C"),
        obrigatorio=False,
    ),
    CasoDeTeste(
        sigla="T5",
        titulo="Ciclo com Processo em Espera Fora do Impasse",
        arquivo="caso_ciclo_com_processo_em_espera.txt",
        buscar_todos=False,
        esperado="Há deadlock (A -> S -> B -> T -> C -> R -> A)",
        obrigatorio=False,
    ),
    CasoDeTeste(
        sigla="T6",
        titulo="Cadeia Longa de Espera sem Deadlock",
        arquivo="caso_cadeia_sem_ciclo.txt",
        buscar_todos=False,
        esperado="Sem deadlock",
        obrigatorio=False,
    ),
    CasoDeTeste(
        sigla="T7",
        titulo="Dois Impasses Simultâneos com Ramo Livre",
        arquivo="caso_dois_impasses_com_ramo_livre.txt",
        buscar_todos=True,
        esperado=("Há deadlock (2 ciclos encontrados):\n"
                  "  Ciclo 1: P1 -> R2 -> P2 -> R1 -> P1\n"
                  "  Ciclo 2: P3 -> R4 -> P4 -> R3 -> P3"),
        obrigatorio=False,
    ),
]

# ------------------------------------------------------------------------------
# [PASSO 3.N2 | FASE 3 | branch: fase-3/nauan-gabarito | commit e push: Nauan Christo]
# validar_gabarito_caso: compara a saída obtida com o gabarito esperado.
# ------------------------------------------------------------------------------

def validar_gabarito_caso(sigla: str, saida_obtida: str, saida_esperada: str) -> Dict[str, str]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Nauan Christo de Aquino]
    Compara a saída produzida pelo detector com o gabarito do caso, ignorando
    apenas espaços nas pontas, e devolve o status de aprovação para o relatório.
    """
    aprovado = saida_obtida.strip() == saida_esperada.strip()
    return {
        "sigla": sigla,
        "status": "APROVADO (PASS)" if aprovado else "FALHOU (FAIL)",
        "saida_obtida": saida_obtida.strip(),
        "saida_esperada": saida_esperada.strip(),
    }
    # [FIM DA FUNÇÃO - Autor: Nauan Christo de Aquino]

# ==============================================================================
# FIM DO MÓDULO DE NAUAN CHRISTO DE AQUINO
# ==============================================================================

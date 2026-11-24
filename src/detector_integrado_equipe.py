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

# ------------------------------------------------------------------------------
# [PASSO 4.2 | FASE 4 | branch: fase-4/integracao | commit e push: Pamella Roberta (coautor: Raony Olivio)]
# Nome descritivo das imagens e geração das três figuras de um caso.
# ------------------------------------------------------------------------------

def montar_nome_figura(sigla: str, titulo: str, tipo: str) -> str:
    """
    [INÍCIO DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]
    Monta o nome do arquivo PNG a partir da sigla do caso, do título (situação e,
    quando houver, identificação do grafo) e do tipo da imagem. Exemplo:
    montar_nome_figura("T1", "Grafo 1 do Enunciado com Deadlock", "cartao")
    -> "T1_grafo_1_do_enunciado_com_deadlock_cartao.png"
    """
    sem_acento = unicodedata.normalize("NFKD", titulo).encode("ascii", "ignore").decode()
    apelido = re.sub(r"[^a-z0-9]+", "_", sem_acento.lower()).strip("_")
    return f"{sigla}_{apelido}_{tipo}.png"
    # [FIM DA FUNÇÃO - Autora: Pamella Roberta Ferreira da Silva]

def gerar_figuras_do_caso(
    sigla: str,
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]],
    veredito: str
) -> Dict[str, str]:
    """
    [INÍCIO DA FUNÇÃO INTEGRADA - Pamella Roberta & Raony Olivio Dias Capela]
    Calcula uma única vez a geometria do grafo (Etapa 5 — Raony), audita o desenho
    e gera as TRÊS imagens separadas do caso (Etapa 1 — Pamella):
      - cartão-relatório do diagnóstico;
      - grafo de alocação de recursos (a entrada, como foi lida);
      - grafo da detecção por busca em profundidade (o resultado).
    Os dois grafos usam exatamente a mesma disposição, para poderem ser comparados.
    Devolve o caminho de cada imagem.
    """
    pos, rotas = calcular_layout_e_rotas(processos, recursos, arestas)
    auditoria = contar_colisoes_desenho(pos, rotas)
    if any(auditoria.values()):
        print(f"[AVISO] Desenho de '{titulo}' com colisões inevitáveis: {auditoria}")

    nome = lambda tipo: montar_nome_figura(sigla, titulo, tipo)
    return {
        "cartao": salvar_cartao_diagnostico(
            f"{sigla} - {titulo}", processos, recursos, arestas, ciclos, veredito,
            nome("cartao")
        ),
        "grafo_alocacao": salvar_grafo_alocacao(
            f"{sigla} - {titulo}", processos, recursos, arestas, pos, rotas,
            nome("grafo_alocacao")
        ),
        "grafo_deteccao_dfs": salvar_grafo_deteccao_dfs(
            f"{sigla} - {titulo}", processos, recursos, arestas, ciclos, veredito, pos, rotas,
            nome("grafo_deteccao_dfs")
        ),
    }
    # [FIM DA FUNÇÃO INTEGRADA - Pamella Roberta & Raony Olivio Dias Capela]

# ------------------------------------------------------------------------------
# [PASSO 4.3 | FASE 4 | branch: fase-4/integracao | commit e push: Pamella Roberta]
# executar_analise_completa_caso: pipeline completo de um caso de teste.
# ------------------------------------------------------------------------------

def executar_analise_completa_caso(
    sigla: str,
    titulo: str,
    nome_arquivo_txt: str,
    buscar_todos: bool = False,
    exibir_rastreamento_dfs: bool = True,
    exibir_no_notebook: bool = True
) -> Dict[str, Any]:
    """
    [INÍCIO DA FUNÇÃO ORQUESTRADORA - Autora: Pamella Roberta Ferreira da Silva]
    Executa o pipeline completo de ponta a ponta para um caso de teste:
      - Etapa 2 (Cinara): leitura e validação do arquivo .txt em tests/;
      - Etapa 3 (Nicolas) e Etapa 4 (Leandro): detecção DFS e formatação do ciclo;
      - Etapa 5 (Raony) e Etapa 1 (Pamella): geometria, estilização e gravação dos
        três PNGs do caso em output/figures/;
      - Exibe o rastreamento, o veredito e as figuras no Jupyter Notebook.
    """
    caminho_txt = os.path.join(PASTA_TESTES, nome_arquivo_txt)
    proc, rec, adj, arestas = carregar_e_validar_grafo(caminho_txt)
    ciclos, logs = detectar_impasses_dfs(proc, rec, adj, buscar_todos=buscar_todos)
    veredito = formatar_resultado(ciclos)

    if exibir_rastreamento_dfs:
        for linha_log in logs:
            print(linha_log)
        print()

    figuras = gerar_figuras_do_caso(sigla, titulo, proc, rec, arestas, ciclos, veredito)

    print(f"Resultado Oficial: {veredito}")
    print("[Imagens salvas em:]")
    for caminho in figuras.values():
        print(f"  - {os.path.relpath(caminho, DIRETORIO_RAIZ)}")

    if exibir_no_notebook and POSSUI_IPYTHON:
        for caminho in figuras.values():
            display(Image(filename=caminho))

    return {
        "sigla": sigla,
        "titulo": titulo,
        "processos": proc,
        "recursos": rec,
        "arestas": arestas,
        "ciclos": ciclos,
        "logs": logs,
        "veredito": veredito,
        "figuras": figuras,
    }
    # [FIM DA FUNÇÃO ORQUESTRADORA - Autora: Pamella Roberta Ferreira da Silva]
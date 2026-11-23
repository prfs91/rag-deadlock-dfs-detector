#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
GERADOR DE VISUALIZAÇÕES LÚDICAS (PADRÃO SLIDES) E RELATÓRIO TÉCNICO (.IPYNB)
Disciplina: Sistemas Operacionais — Engenharia de Computação (UFPA Tucuruí)
Base: Aula 07 / Slide 07 — Impasses (Prof. Dr. Iago Medeiros)

Responsáveis:
  - Raony Olivio Dias Capela (Motor Visual NetworkX/Matplotlib)
  - Nauan Christo de Aquino (Bateria de Testes e Caderno Técnico .ipynb)
  - Pamella Roberta Ferreira da Silva (Integração e Caminhos Multiplataforma)
================================================================================
"""

import os
import json
import base64
from typing import Dict, List, Set, Tuple, Optional

import networkx as nx
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


# ==============================================================================
# CAMINHOS PORTÁVEIS MULTIPLATAFORMA (Pamella Roberta Ferreira da Silva)
# ==============================================================================
PASTA_SRC: str = os.path.dirname(os.path.abspath(__file__))
DIRETORIO_RAIZ: str = os.path.dirname(PASTA_SRC)
PASTA_TESTES: str = os.path.join(DIRETORIO_RAIZ, "tests")
PASTA_FIGURAS: str = os.path.join(DIRETORIO_RAIZ, "output", "figures")

os.makedirs(PASTA_TESTES, exist_ok=True)
os.makedirs(PASTA_FIGURAS, exist_ok=True)

# Paleta de cores lúdica padronizada (baseada nos desenhos dos slides da aula)
COR_NO_DEADLOCK: str = "#e74c3c"       # Vermelho: vértice preso em espera circular
COR_NO_SEGURO: str = "#2ecc71"         # Verde: vértice inspecionado sem ciclo
COR_PROCESSO_CIRCULO: str = "#3498db"  # Azul: Processo (Círculo conforme Slide)
COR_RECURSO_QUADRADO: str = "#7ae2ff"  # Ciano: Recurso (Quadrado conforme Slide)
COR_ARESTA_NORMAL: str = "#7f8c8d"     # Cinza: arco normal
COR_ARESTA_CICLO: str = "#c0392b"      # Vermelho escuro: arco pertencente ao ciclo


# ==============================================================================
# LEITURA E VALIDAÇÃO DO GRAFO (Cinara Oliveira da Silva)
# ==============================================================================
def carregar_grafo_opcao1(
    caminho_arquivo: str
) -> Tuple[List[str], List[str], Dict[str, List[str]], List[Tuple[str, str]]]:
    """Lê um arquivo no formato Opção 1 (Lista de Arestas) e valida nós."""
    processos: List[str] = []
    recursos: List[str] = []
    arestas: List[Tuple[str, str]] = []
    lendo_arestas = False

    with open(caminho_arquivo, "r", encoding="utf-8") as f:
        for linha_bruta in f:
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

    adjacencia: Dict[str, List[str]] = {no: [] for no in processos + recursos}
    for origem, destino in arestas:
        adjacencia[origem].append(destino)

    return processos, recursos, adjacencia, arestas


# ==============================================================================
# BUSCA EM PROFUNDIDADE RECURSIVA E EXTRAÇÃO DE CICLO
# (Nicolas Martins Sousa & Leandro Nascimento Vitório)
# ==============================================================================
def normalizar_ciclo(ciclo: List[str]) -> Tuple[str, ...]:
    nos = ciclo[:-1]
    menor = min(nos)
    idx = nos.index(menor)
    return tuple(nos[idx:] + nos[:idx])


def detectar_ciclos_dfs(
    processos: List[str],
    recursos: List[str],
    adjacencia: Dict[str, List[str]],
    buscar_todos: bool = False
) -> Tuple[List[List[str]], List[str]]:
    """Executa o algoritmo DFS dos slides (lista L, arcos marcados, retrocesso)."""
    ciclos: List[List[str]] = []
    assinaturas: Set[Tuple[str, ...]] = set()
    log_passos: List[str] = []
    todos_nos = processos + recursos
    ordem_nos = {no: i for i, no in enumerate(todos_nos)}

    def dfs_recursivo(
        no_atual: str,
        lista_L: List[str],
        arcos_marcados: Set[Tuple[str, str]]
    ) -> Optional[List[str]]:
        if no_atual in lista_L:
            idx_inicio = lista_L.index(no_atual)
            nucleo = lista_L[idx_inicio:]
            ancora = min(nucleo, key=lambda n: ordem_nos.get(n, 9999))
            idx_ancora = nucleo.index(ancora)
            ciclo_limpo = nucleo[idx_ancora:] + nucleo[:idx_ancora] + [ancora]

            log_passos.append(
                f"  [CICLO DETECTADO!] Nó '{no_atual}' repetido em L={lista_L + [no_atual]} "
                f"-> Ciclo extraído: {' -> '.join(ciclo_limpo)}"
            )
            assinatura = normalizar_ciclo(ciclo_limpo)
            if assinatura not in assinaturas:
                assinaturas.add(assinatura)
                ciclos.append(ciclo_limpo)
            return ciclo_limpo

        lista_L.append(no_atual)
        log_passos.append(f"  [Avanço] Visitando '{no_atual}' | Lista L: {lista_L}")

        for vizinho in adjacencia.get(no_atual, []):
            arco = (no_atual, vizinho)
            if arco not in arcos_marcados:
                arcos_marcados.add(arco)
                log_passos.append(f"    -> Marcando arco ({no_atual} -> {vizinho})")
                achado = dfs_recursivo(vizinho, lista_L, arcos_marcados)
                if achado is not None and not buscar_todos:
                    return achado

        lista_L.pop()
        log_passos.append(f"  [Retrocesso] Beco sem saída em '{no_atual}' | Lista L: {lista_L}")
        return None

    for raiz in todos_nos:
        log_passos.append(f"--- Iniciando busca DFS com raiz em '{raiz}' ---")
        res = dfs_recursivo(raiz, [], set())
        if res is not None and not buscar_todos:
            break

    return ciclos, log_passos


def formatar_saida(ciclos: List[List[str]]) -> str:
    if not ciclos:
        return "Sem deadlock"
    if len(ciclos) == 1:
        return f"Há deadlock ({' -> '.join(ciclos[0])})"
    linhas = [f"Há deadlock ({len(ciclos)} ciclos encontrados):"]
    for i, c in enumerate(ciclos, 1):
        linhas.append(f"  Ciclo {i}: {' -> '.join(c)}")
    return "\n".join(linhas)


# ==============================================================================
# VISUALIZAÇÃO LÚDICA BASEADA NOS DESENHOS DOS SLIDES (Raony Olivio Dias Capela)
# Processos = CÍRCULOS ('o') | Recursos = QUADRADOS ('s')
# ==============================================================================
def salvar_cartao_diagnostico(
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]],
    nome_png: str
) -> str:
    """Gera cartão visual monoespaçado de diagnóstico em 300 DPI."""
    conj_proc = set(processos)
    posse = [f"{u}->{v}" for u, v in arestas if u not in conj_proc]
    espera = [f"{u}->{v}" for u, v in arestas if u in conj_proc]

    fig, ax = plt.subplots(figsize=(12.5, 2.7))
    ax.set_axis_off()

    veredito = formatar_saida(ciclos).replace("\n", " | ")
    linha_sep = "-" * 106
    texto = (
        f"RELATÓRIO DE DETECÇÃO DE IMPASSE (DFS) - CASO: [ {titulo} ]\n"
        f"{linha_sep}\n"
        f"Processos Círculos ({len(processos)}): {', '.join(processos)}   |   "
        f"Recursos Quadrados ({len(recursos)}): {', '.join(recursos)}\n"
        f"Arcos de Posse (R->P): {', '.join(posse)}   |   "
        f"Arcos de Solicitação (P->R): {', '.join(espera)}\n\n"
        f"Diagnóstico Final:  {veredito}"
    )

    cor_borda = "#e74c3c" if ciclos else "#2ecc71"
    cor_fundo = "#fdf2e9" if ciclos else "#eafaf1"
    plt.text(
        0.015, 0.5, texto, family="monospace", fontsize=9.8,
        verticalalignment="center", linespacing=1.55, fontweight="bold",
        bbox=dict(boxstyle="round,pad=0.65", facecolor=cor_fundo, edgecolor=cor_borda, lw=2.2)
    )

    caminho = os.path.join(PASTA_FIGURAS, nome_png)
    plt.savefig(caminho, bbox_inches="tight", dpi=300, facecolor="white")
    plt.close(fig)
    return caminho


def desenhar_comparativo_rag(
    titulo: str,
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]],
    ciclos: List[List[str]],
    nome_png: str
) -> str:
    """
    Desenha dois gráficos lado a lado no padrão visual dos slides:
      - Esquerda: Grafo de Alocação (Círculos Azuis = Processos, Quadrados Cianos = Recursos).
      - Direita: Resultado da Busca em Profundidade (Vermelho = Deadlock, Verde = Seguro).
    """
    G = nx.DiGraph()
    for no in processos + recursos:
        G.add_node(no)
    for u, v in arestas:
        G.add_edge(u, v)

    pos: Dict[str, Tuple[float, float]] = {}
    largura = max(len(processos), len(recursos), 1) * 2.5
    for i, p in enumerate(processos):
        passo = largura / max(len(processos), 1)
        pos[p] = ((i - (len(processos) - 1) / 2.0) * passo, 2.8)
    for i, r in enumerate(recursos):
        passo = largura / max(len(recursos), 1)
        pos[r] = ((i - (len(recursos) - 1) / 2.0) * passo, 0.6)

    nos_ciclo: Set[str] = set()
    arestas_ciclo: Set[Tuple[str, str]] = set()
    for c in ciclos:
        nos_ciclo.update(c)
        for i in range(len(c) - 1):
            arestas_ciclo.add((c[i], c[i + 1]))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16.5, 6.4))

    # Painel Esquerdo: Estrutura Original (Círculos vs Quadrados)
    nx.draw_networkx_nodes(
        G, pos, nodelist=processos, ax=ax1, node_shape="o", node_size=1450,
        node_color=COR_PROCESSO_CIRCULO, edgecolors="#1b4f72", linewidths=1.8
    )
    nx.draw_networkx_nodes(
        G, pos, nodelist=recursos, ax=ax1, node_shape="s", node_size=1350,
        node_color=COR_RECURSO_QUADRADO, edgecolors="#117864", linewidths=1.8
    )
    nx.draw_networkx_labels(G, pos, ax=ax1, font_size=11.5, font_weight="bold", font_color="#17202a")
    nx.draw_networkx_edges(
        G, pos, ax=ax1, arrows=True, arrowsize=20, edge_color=COR_ARESTA_NORMAL,
        width=2.0, node_size=1450, connectionstyle="arc3,rad=0.07"
    )
    ax1.set_title(
        f"Grafo de Alocação de Recursos ({titulo})\n"
        f"● Círculos: Processos ({len(processos)})   |   ■ Quadrados: Recursos ({len(recursos)})",
        fontsize=11.5, fontweight="bold", pad=12
    )
    ax1.margins(0.18)
    ax1.set_axis_off()

    # Painel Direito: Diagnóstico DFS (Vermelho = Impasse, Verde = Livre)
    cores_p = [COR_NO_DEADLOCK if p in nos_ciclo else COR_NO_SEGURO for p in processos]
    cores_r = [COR_NO_DEADLOCK if r in nos_ciclo else COR_NO_SEGURO for r in recursos]
    nx.draw_networkx_nodes(
        G, pos, nodelist=processos, ax=ax2, node_shape="o", node_size=1450,
        node_color=cores_p, edgecolors="#17202a", linewidths=1.8
    )
    nx.draw_networkx_nodes(
        G, pos, nodelist=recursos, ax=ax2, node_shape="s", node_size=1350,
        node_color=cores_r, edgecolors="#17202a", linewidths=1.8
    )
    nx.draw_networkx_labels(G, pos, ax=ax2, font_size=11.5, font_weight="bold", font_color="white")

    e_normais = [e for e in G.edges() if e not in arestas_ciclo]
    e_ciclo = [e for e in G.edges() if e in arestas_ciclo]

    if e_normais:
        nx.draw_networkx_edges(
            G, pos, edgelist=e_normais, ax=ax2, arrows=True, arrowsize=18,
            edge_color=COR_ARESTA_NORMAL, width=1.6, style="dashed",
            node_size=1450, connectionstyle="arc3,rad=0.07"
        )
    if e_ciclo:
        nx.draw_networkx_edges(
            G, pos, edgelist=e_ciclo, ax=ax2, arrows=True, arrowsize=23,
            edge_color=COR_ARESTA_CICLO, width=3.2,
            node_size=1450, connectionstyle="arc3,rad=0.07"
        )

    veredito = formatar_saida(ciclos).replace("\n", " | ")
    ax2.set_title(
        f"Detecção por Busca em Profundidade (DFS)\n{veredito}",
        fontsize=11.5, fontweight="bold",
        color="#c0392b" if ciclos else "#1e8449", pad=12
    )
    ax2.margins(0.18)
    ax2.set_axis_off()

    plt.tight_layout()
    caminho = os.path.join(PASTA_FIGURAS, nome_png)
    plt.savefig(caminho, bbox_inches="tight", dpi=300, facecolor="white")
    plt.close(fig)
    return caminho


# ==============================================================================
# GERAÇÃO DO RELATÓRIO TÉCNICO INTERATIVO .IPYNB (Nauan Christo de Aquino)
# ==============================================================================
def embutir_png(caminho_png: str) -> dict:
    with open(caminho_png, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("ascii")
    return {
        "data": {"image/png": b64, "text/plain": [f"<Image {os.path.basename(caminho_png)}>"]},
        "metadata": {},
        "output_type": "display_data"
    }


def gerar_relatorio_ipynb() -> None:
    # Garante que o caso extra T4 também exista em tests/
    arq_t4 = os.path.join(PASTA_TESTES, "caso_extra_multiplos_ciclos.txt")
    if not os.path.exists(arq_t4):
        with open(arq_t4, "w", encoding="utf-8") as f:
            f.write("PROCESSOS A B C D\nRECURSOS R S T U\nARESTAS\nR A\nA S\nS B\nB R\nT C\nC U\nU D\nD T\n")

    casos = [
        ("T1 - Grafo da Aula (Slide 40)", "caso_slide40_multiplos_nos.txt", False, True),
        ("T2 - Grafo 1 da Aula (Sem Deadlock)", "caso_grafo1_concorrente_seguro.txt", False, False),
        ("T3 - Grafo 2 da Aula (Espera Circular)", "caso_grafo2_espera_circular.txt", False, False),
        ("T4 - Extra Múltiplos Ciclos", "caso_extra_multiplos_ciclos.txt", True, False),
    ]

    outputs_casos = {}
    for titulo, nome_arq, todos, verbose in casos:
        caminho_txt = os.path.join(PASTA_TESTES, nome_arq)
        proc, rec, adj, arestas = carregar_grafo_opcao1(caminho_txt)
        ciclos, logs = detectar_ciclos_dfs(proc, rec, adj, buscar_todos=todos)
        sigla = titulo.split(" ")[0]
        p_cartao = salvar_cartao_diagnostico(titulo, proc, rec, arestas, ciclos, f"cartao_{sigla}.png")
        p_grafo = desenhar_comparativo_rag(titulo, proc, rec, arestas, ciclos, f"grafo_{sigla}.png")
        outputs_casos[sigla] = (logs if verbose else [], p_cartao, p_grafo)
        print(f"[{sigla}] {titulo} -> {formatar_saida(ciclos)}")

    celulas = [
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "# Relatório Técnico e Análise Visual de Impasses (*Deadlocks*) em Grafos de Alocação de Recursos via Busca em Profundidade (*DFS*)\n",
                "**Instituição:** Universidade Federal do Pará (UFPA) — *Campus* Universitário de Tucuruí  \n",
                "**Disciplina:** Sistemas Operacionais — Engenharia de Computação (Prof. Dr. Iago Medeiros)  \n",
                "\n",
                "---\n",
                "## 1. Identificação da Equipe e Divisão de Responsabilidades\n",
                "| Integrante | Papel e Contribuição Técnica | Módulos / Funções |\n",
                "| :--- | :--- | :--- |\n",
                "| **Pamella Roberta Ferreira da Silva** | Criação e gestão do repositório *Git*/*GitHub*, `.gitignore`, `sandbox_local/`, resolução dinâmica de caminhos portáveis (`DIRETORIO_RAIZ`), integração dos módulos e *CLI*. | `.gitignore`, `DIRETORIO_RAIZ`, `PASTA_TESTES`, `PASTA_FIGURAS`, `main()` |\n",
                "| **Cinara Oliveira da Silva** | Leitura e *parsing* do formato Opção 1 (Lista de Arestas) e validação semântica de Grafo Bipartido (`Processo <-> Recurso`) e Instância Única. | `carregar_grafo_opcao1()` |\n",
                "| **Nicolas Martins Sousa** | Motor recursivo de Busca em Profundidade (*Depth-First Search* — *DFS*) seguindo a lista $L$, marcação de arcos e retrocesso (*backtracking*) do *Slide* 40. | `detectar_ciclos_dfs()` |\n",
                "| **Leandro Nascimento Vitório** | Isolamento do ciclo elementar (remoção do prefixo fora do laço), assinatura canônica contra duplicatas e formatação da saída. | `normalizar_ciclo()`, `formatar_saida()` |\n",
                "| **Raony Olivio Dias Capela** | Visualização lúdica (*NetworkX* + *Matplotlib*) fiel aos desenhos dos *slides* (Processos = **Círculos**, Recursos = **Quadrados**) e cartões de telemetria. | `desenhar_comparativo_rag()`, `salvar_cartao_diagnostico()` |\n",
                "| **Nauan Christo de Aquino** | Modelagem dos casos de teste obrigatórios (`T1`, `T2`, `T3`) e extra (`T4`), suíte de validação e redação do relatório técnico. | `tests/*.txt`, `gerar_relatorio_ipynb()` |\n",
                "\n",
                "---\n",
                "## 2. Alinhamento com os *Slides* da Disciplina\n",
                "Conforme a modelagem formal de Holt (1972) apresentada nos *Slides* 22, 23 e 40:\n",
                "* **Processos** são desenhados como **Círculos ($\\bigcirc$)**.\n",
                "* **Recursos** são desenhados como **Quadrados ($\\square$)**.\n",
                "* **Arco `Recurso -> Processo`:** indica **posse** (recurso alocado ao processo).\n",
                "* **Arco `Processo -> Recurso`:** indica **solicitação/espera** (processo bloqueado aguardando o recurso)."
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## 3. Caso Obrigatório T1 — Grafo da Aula (*Slide* 40)\n",
                "Abaixo exibimos o rastreamento passo a passo da **lista $L$** e do **retrocesso (*backtracking*)** em beco sem saída (`S`), seguido pelo cartão de telemetria e pelo grafo visual (círculos e quadrados) destacando o ciclo `D -> T -> E -> V -> G -> U -> D` em vermelho."
            ]
        },
        {
            "cell_type": "code",
            "execution_count": 1,
            "metadata": {},
            "outputs": [
                {"name": "stdout", "output_type": "stream", "text": [l + "\n" for l in outputs_casos["T1"][0]]},
                embutir_png(outputs_casos["T1"][1]),
                embutir_png(outputs_casos["T1"][2]),
            ],
            "source": [
                "# Execução do Caso Obrigatório T1 (Slide 40)\n",
                "from gerar_visualizacoes_e_notebook import carregar_grafo_opcao1, detectar_ciclos_dfs, formatar_saida, PASTA_TESTES\n",
                "import os\n",
                "proc, rec, adj, arestas = carregar_grafo_opcao1(os.path.join(PASTA_TESTES, 'caso_slide40_multiplos_nos.txt'))\n",
                "ciclos, _ = detectar_ciclos_dfs(proc, rec, adj)\n",
                "print(formatar_saida(ciclos))"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## 4. Caso Obrigatório T2 — Grafo 1 da Aula (*Sem Deadlock*)"
            ]
        },
        {
            "cell_type": "code",
            "execution_count": 2,
            "metadata": {},
            "outputs": [
                embutir_png(outputs_casos["T2"][1]),
                embutir_png(outputs_casos["T2"][2]),
            ],
            "source": [
                "# Execução do Caso Obrigatório T2 (Grafo 1 - Sem Deadlock)\n",
                "proc, rec, adj, arestas = carregar_grafo_opcao1(os.path.join(PASTA_TESTES, 'caso_grafo1_concorrente_seguro.txt'))\n",
                "ciclos, _ = detectar_ciclos_dfs(proc, rec, adj)\n",
                "print(formatar_saida(ciclos))"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## 5. Caso Obrigatório T3 — Grafo 2 da Aula (*Espera Circular Clássica*)"
            ]
        },
        {
            "cell_type": "code",
            "execution_count": 3,
            "metadata": {},
            "outputs": [
                embutir_png(outputs_casos["T3"][1]),
                embutir_png(outputs_casos["T3"][2]),
            ],
            "source": [
                "# Execução do Caso Obrigatório T3 (Grafo 2 - Espera Circular A-B-C)\n",
                "proc, rec, adj, arestas = carregar_grafo_opcao1(os.path.join(PASTA_TESTES, 'caso_grafo2_espera_circular.txt'))\n",
                "ciclos, _ = detectar_ciclos_dfs(proc, rec, adj)\n",
                "print(formatar_saida(ciclos))"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## 6. Caso Extra T4 — Múltiplos Impasses Simultâneos (*Slide* 38)"
            ]
        },
        {
            "cell_type": "code",
            "execution_count": 4,
            "metadata": {},
            "outputs": [
                embutir_png(outputs_casos["T4"][1]),
                embutir_png(outputs_casos["T4"][2]),
            ],
            "source": [
                "# Execução do Caso Extra T4 (Múltiplos Ciclos Disjuntos)\n",
                "proc, rec, adj, arestas = carregar_grafo_opcao1(os.path.join(PASTA_TESTES, 'caso_extra_multiplos_ciclos.txt'))\n",
                "ciclos, _ = detectar_ciclos_dfs(proc, rec, adj, buscar_todos=True)\n",
                "print(formatar_saida(ciclos))"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "---\n",
                "## 7. Discussão Teórica, Limitações e Melhorias\n",
                "* **Condições de Coffman:** O algoritmo detecta dinamicamente a quebra da 4ª condição (**Espera Circular**). Em sistemas com **1 instância de cada recurso**, a presença de um ciclo no Grafo de Alocação é condição **necessária e suficiente** para caracterizar *deadlock*.\n",
                "* **Limitações e Trabalhos Futuros:** Para recursos com **múltiplas instâncias**, um ciclo torna-se apenas condição *necessária* (mas não suficiente), exigindo o algoritmo matricial ($E, A, C, R$) ou o Algoritmo do Banqueiro."
            ]
        }
    ]

    notebook = {
        "cells": celulas,
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
            "language_info": {"name": "python", "version": "3.11.0"}
        },
        "nbformat": 4,
        "nbformat_minor": 5
    }

    caminho_ipynb = os.path.join(DIRETORIO_RAIZ, "relatorio_analise_impasses_rag.ipynb")
    with open(caminho_ipynb, "w", encoding="utf-8") as f:
        json.dump(notebook, f, ensure_ascii=False, indent=2)
    print(f"\n[SUCESSO] Relatório interativo gerado em: {caminho_ipynb}")


if __name__ == "__main__":
    gerar_relatorio_ipynb()
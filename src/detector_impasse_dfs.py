#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Módulo: detector_impasse_dfs.py
Descrição: Motor de detecção de impasses (deadlocks) em Grafos de Alocação de
           Recursos (RAG) com uma instância de cada tipo, utilizando o algoritmo
           formal de Busca em Profundidade (DFS) apresentado nos slides da disciplina
           de Sistemas Operacionais (Prof. Dr. Iago Medeiros - UFPA).
"""

import sys
import argparse
from typing import Dict, List, Set, Tuple, Optional


class GrafoAlocacaoRecursos:
    """
    Representa um Grafo de Alocação de Recursos (RAG) bipartido dirigido.
    Convenção dos slides (Tanenbaum / Holt, 1972):
      - Nó de Processo (círculo): solicita recursos.
      - Nó de Recurso (quadrado): é possuído por um processo.
      - Arco Recurso -> Processo: o recurso está alocado ao processo (posse).
      - Arco Processo -> Recurso: o processo está bloqueado aguardando o recurso (requisição).
    """

    def __init__(self) -> None:
        self.processos: List[str] = []
        self.recursos: List[str] = []
        self.ordem_nos: List[str] = []
        self.adjacencia: Dict[str, List[str]] = {}
        self.arestas: List[Tuple[str, str]] = []

    def carregar_arquivo_arestas(self, caminho_arquivo: str) -> None:
        """
        Lê o arquivo de entrada no Formato Opção 1 (Lista de Arestas recomendada):
        PROCESSOS A B C ...
        RECURSOS R S T ...
        ARESTAS
        ORIGEM DESTINO
        """
        modo_leitura_arestas = False

        with open(caminho_arquivo, mode="r", encoding="utf-8") as arquivo:
            for numero_linha, linha_bruta in enumerate(arquivo, start=1):
                linha = linha_bruta.strip()
                if not linha or linha.startswith("#"):
                    continue

                partes = linha.split()
                palavra_chave = partes[0].upper()

                if palavra_chave == "PROCESSOS":
                    self.processos = partes[1:]
                    for proc in self.processos:
                        if proc not in self.adjacencia:
                            self.adjacencia[proc] = []
                elif palavra_chave == "RECURSOS":
                    self.recursos = partes[1:]
                    for rec in self.recursos:
                        if rec not in self.adjacencia:
                            self.adjacencia[rec] = []
                elif palavra_chave == "ARESTAS":
                    modo_leitura_arestas = True
                    # Ordem de inspeção igual à dos slides: primeiro recursos/processos declarados
                    self.ordem_nos = self.recursos + self.processos
                elif modo_leitura_arestas:
                    if len(partes) != 2:
                        raise ValueError(
                            f"Erro de sintaxe na linha {numero_linha}: esperado 'ORIGEM DESTINO', obtido '{linha}'."
                        )
                    origem, destino = partes[0], partes[1]
                    self._validar_aresta_bipartida(origem, destino, numero_linha)
                    self.adjacencia[origem].append(destino)
                    self.arestas.append((origem, destino))
                else:
                    raise ValueError(
                        f"Diretiva desconhecida na linha {numero_linha}: '{linha}'."
                    )

    def _validar_aresta_bipartida(self, origem: str, destino: str, linha: int) -> None:
        """
        Verifica se os nós existem e respeitam a propriedade bipartida (Processo <-> Recurso).
        """
        todos_nos = set(self.processos) | set(self.recursos)
        if origem not in todos_nos:
            raise ValueError(f"Linha {linha}: Nó de origem '{origem}' não foi declarado.")
        if destino not in todos_nos:
            raise ValueError(f"Linha {linha}: Nó de destino '{destino}' não foi declarado.")

        origem_eh_processo = origem in self.processos
        destino_eh_processo = destino in self.processos

        if origem_eh_processo == destino_eh_processo:
            tipo = "Processo" if origem_eh_processo else "Recurso"
            raise ValueError(
                f"Linha {linha}: Violação de grafo bipartido entre '{origem}' e '{destino}' (ambos são do tipo {tipo})."
            )

    def detectar_impasse_dfs(self, exibir_passos: bool = False) -> Tuple[bool, List[str], List[str]]:
        """
        Executa exatamente o algoritmo de detecção de impasses por Busca em Profundidade (DFS)
        descrito nos Slides 38 a 42 da Aula de Impasses (Prof. Dr. Iago Medeiros):
          1. Para cada nó N no grafo, executa DFS com N como nó-raiz:
          2. Inicializa a lista L como vazia e desmarca todos os arcos.
          3. Adiciona o nó atual ao final de L e verifica se o nó aparece duas vezes em L.
             Se aparecer, contém um ciclo (deadlock) e o algoritmo termina.
          4. A partir do nó dado, vê se há algum arco de saída não marcado.
             Se houver, escolhe um arco, marca-o e segue até o novo nó.
          5. Se não houver arcos de saída desmarcados (beco sem saída), recua para o nó anterior
             removendo o nó atual de L. Se for o nó inicial, a subárvore não possui ciclos.
        """
        historico_rastreamento: List[str] = []

        # Ordem de avaliação idêntica à demonstração passo a passo dos slides (R, A, B, C...)
        sequencia_inspecao: List[str] = []
        if "R" in self.recursos:
            sequencia_inspecao.append("R")
        for no in self.processos + self.recursos:
            if no not in sequencia_inspecao:
                sequencia_inspecao.append(no)

        for no_raiz in sequencia_inspecao:
            lista_L: List[str] = []
            arcos_marcados: Set[Tuple[str, str]] = set()
            historico_rastreamento.append(f"[Raiz = {no_raiz}] Iniciando inspeção com L = []")

            encontrou_ciclo, ciclo_extraido = self._passo_recursivo_dfs(
                no_atual=no_raiz,
                lista_L=lista_L,
                arcos_marcados=arcos_marcados,
                historico=historico_rastreamento,
            )

            if encontrou_ciclo:
                if exibir_passos:
                    for linha_log in historico_rastreamento:
                        print(linha_log)
                return True, ciclo_extraido, historico_rastreamento

        if exibir_passos:
            for linha_log in historico_rastreamento:
                print(linha_log)

        return False, [], historico_rastreamento

    def _passo_recursivo_dfs(
        self,
        no_atual: str,
        lista_L: List[str],
        arcos_marcados: Set[Tuple[str, str]],
        historico: List[str],
    ) -> Tuple[bool, List[str]]:
        """
        Passo recursivo de exploração da lista L e marcação de arcos de saída.
        """
        # Passo 3: Insere o nó atual ao final da lista L
        lista_L.append(no_atual)
        historico.append(f"  -> L = {lista_L}")

        # Verifica se o nó atual já apareceu anteriormente na lista L (repetição de nó = ciclo)
        if lista_L.count(no_atual) > 1:
            indice_primeira_ocorrencia = lista_L.index(no_atual)
            ciclo_fechado = lista_L[indice_primeira_ocorrencia:]
            historico.append(
                f"  [!] Repetição do nó '{no_atual}' detectada em L = {lista_L}. Ciclo isolado: {' -> '.join(ciclo_fechado)}"
            )
            return True, ciclo_fechado

        # Passo 4: Inspeciona arcos de saída ainda não marcados a partir do nó atual
        arcos_saida = self.adjacencia.get(no_atual, [])
        for vizinho in arcos_saida:
            arco = (no_atual, vizinho)
            if arco not in arcos_marcados:
                arcos_marcados.add(arco)
                historico.append(f"  Seguindo arco de saída marcado ({no_atual} -> {vizinho})")
                achou, ciclo = self._passo_recursivo_dfs(
                    no_atual=vizinho,
                    lista_L=lista_L,
                    arcos_marcados=arcos_marcados,
                    historico=historico,
                )
                if achou:
                    return True, ciclo

        # Passo 5: Beco sem saída; remove o nó atual de L e retrocede (backtracking)
        historico.append(
            f"  [Beco sem saída em '{no_atual}'] Nenhum arco de saída desmarcado. Recuando..."
        )
        lista_L.pop()
        return False, []


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Detector de Impasses (Deadlock) em Grafos de Alocação de Recursos via DFS."
    )
    parser.add_argument(
        "arquivo_entrada",
        help="Caminho para o arquivo de entrada com a definição dos processos, recursos e arestas.",
    )
    parser.add_argument(
        "--rastrear",
        action="store_true",
        help="Exibe o passo a passo da evolução da lista L conforme os slides da aula.",
    )
    argumentos = parser.parse_args()

    grafo = GrafoAlocacaoRecursos()
    try:
        grafo.carregar_arquivo_arestas(argumentos.arquivo_entrada)
    except Exception as erro:
        print(f"Erro ao processar arquivo de entrada: {erro}", file=sys.stderr)
        sys.exit(1)

    possui_impasse, ciclo, _ = grafo.detectar_impasse_dfs(exibir_passos=argumentos.rastrear)

    if possui_impasse:
        # Padroniza a exibição para começar pelo menor processo ou manter a ordem de descoberta
        cadeia_ciclo = " -> ".join(ciclo)
        print(f"Há deadlock: {cadeia_ciclo}")
    else:
        print("Sem deadlock")


if __name__ == "__main__":
    main()
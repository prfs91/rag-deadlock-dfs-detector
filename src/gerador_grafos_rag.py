#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Módulo: gerador_grafos_rag.py
Descrição: Gera representações visuais vetoriais (SVG) padronizadas dos Grafos de
           Alocação de Recursos (RAG) seguindo a notação gráfica dos slides do
           Prof. Dr. Iago Medeiros (Círculos = Processos, Quadrados = Recursos)
           com codificação cromática para destacar o ciclo de impasse (deadlock).
"""

import os


PALETA_PADRAO = {
    "processo_fundo": "#dbeafe",       # Azul claro para processos normais
    "processo_borda": "#1e40af",       # Azul escuro institucional
    "recurso_fundo": "#fef3c7",        # Âmbar claro para recursos normais
    "recurso_borda": "#b45309",        # Âmbar escuro
    "ciclo_fundo": "#fee2e2",          # Vermelho claro para nós em deadlock
    "ciclo_borda": "#b91c1c",          # Vermelho forte para o ciclo fechado
    "arco_normal": "#475569",          # Cinza ardósia para arcos fora do ciclo
    "arco_ciclo": "#dc2626",           # Vermelho vivo para arcos da espera circular
}


def gerar_svg_slide40(caminho_saida: str) -> None:
    """
    Reproduz exatamente a topologia espacial do Slide 40 da Aula de Impasses,
    adicionando cores padronizadas para processos (círculos), recursos (quadrados)
    e destacando o ciclo D -> T -> E -> V -> G -> U -> D.
    """
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 430" width="100%" height="auto" role="img">
  <title>Grafo de Alocação de Recursos - Slide 40 (Detecção por DFS)</title>
  <defs>
    <marker id="seta-normal" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="{PALETA_PADRAO['arco_normal']}"/>
    </marker>
    <marker id="seta-ciclo" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6.5" markerHeight="6.5" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="{PALETA_PADRAO['arco_ciclo']}"/>
    </marker>
  </defs>

  <rect width="780" height="430" fill="#f8fafc" rx="6" stroke="#cbd5e1" stroke-width="1"/>
  <text x="20" y="28" font-family="Arial, sans-serif" font-size="14" font-weight="bold" fill="#0f172a">
    Caso T1 (Slide 40): Detecção de Impasse por Busca em Profundidade (Lista L)
  </text>

  <!-- Arcos Fora do Ciclo -->
  <line x1="92" y1="75" x2="184" y2="75" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="210" y1="101" x2="210" y2="168" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="96" y1="195" x2="182" y2="195" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="210" y1="354" x2="210" y2="306" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="210" y1="254" x2="210" y2="222" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="354" y1="195" x2="238" y2="195" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>
  <line x1="540" y1="101" x2="540" y2="168" stroke="{PALETA_PADRAO['arco_normal']}" stroke-width="2.2" marker-end="url(#seta-normal)"/>

  <!-- Arcos do Ciclo de Impasse (D -> T -> E -> V -> G -> U -> D) -->
  <line x1="406" y1="195" x2="512" y2="195" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>
  <line x1="566" y1="195" x2="664" y2="195" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>
  <line x1="690" y1="221" x2="690" y2="278" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>
  <path d="M 690 330 L 690 380 L 408 380" fill="none" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>
  <line x1="380" y1="354" x2="380" y2="308" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>
  <line x1="380" y1="254" x2="380" y2="223" stroke="{PALETA_PADRAO['arco_ciclo']}" stroke-width="3" marker-end="url(#seta-ciclo)"/>

  <!-- Nós de Recursos (Quadrados) -->
  <rect x="42" y="50" width="50" height="50" fill="{PALETA_PADRAO['recurso_fundo']}" stroke="{PALETA_PADRAO['recurso_borda']}" stroke-width="2.2"/>
  <text x="67" y="81" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#78350f">R</text>

  <rect x="185" y="170" width="50" height="50" fill="{PALETA_PADRAO['recurso_fundo']}" stroke="{PALETA_PADRAO['recurso_borda']}" stroke-width="2.2"/>
  <text x="210" y="201" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#78350f">S</text>

  <rect x="185" y="355" width="50" height="50" fill="{PALETA_PADRAO['recurso_fundo']}" stroke="{PALETA_PADRAO['recurso_borda']}" stroke-width="2.2"/>
  <text x="210" y="386" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#78350f">W</text>

  <!-- Recursos no Ciclo (T, V, U) -->
  <rect x="515" y="170" width="50" height="50" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="540" y="201" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">T</text>

  <rect x="665" y="280" width="50" height="50" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="690" y="311" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">V</text>

  <rect x="355" y="255" width="50" height="50" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="380" y="286" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">U</text>

  <!-- Nós de Processos Fora do Ciclo (Círculos) -->
  <circle cx="210" cy="75" r="25" fill="{PALETA_PADRAO['processo_fundo']}" stroke="{PALETA_PADRAO['processo_borda']}" stroke-width="2.2"/>
  <text x="210" y="81" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1e3a8a">A</text>

  <circle cx="70" cy="195" r="25" fill="{PALETA_PADRAO['processo_fundo']}" stroke="{PALETA_PADRAO['processo_borda']}" stroke-width="2.2"/>
  <text x="70" y="201" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1e3a8a">C</text>

  <circle cx="210" cy="280" r="25" fill="{PALETA_PADRAO['processo_fundo']}" stroke="{PALETA_PADRAO['processo_borda']}" stroke-width="2.2"/>
  <text x="210" y="286" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1e3a8a">F</text>

  <circle cx="540" cy="75" r="25" fill="{PALETA_PADRAO['processo_fundo']}" stroke="{PALETA_PADRAO['processo_borda']}" stroke-width="2.2"/>
  <text x="540" y="81" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#1e3a8a">B</text>

  <!-- Processos no Ciclo (D, E, G) -->
  <circle cx="380" cy="195" r="25" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="380" y="201" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">D</text>

  <circle cx="690" cy="195" r="25" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="690" y="201" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">E</text>

  <circle cx="380" cy="380" r="25" fill="{PALETA_PADRAO['ciclo_fundo']}" stroke="{PALETA_PADRAO['ciclo_borda']}" stroke-width="2.6"/>
  <text x="380" y="386" font-family="Arial, sans-serif" font-size="16" font-weight="bold" text-anchor="middle" fill="#7f1d1d">G</text>
</svg>"""
    os.makedirs(os.path.dirname(caminho_saida), exist_ok=True)
    with open(caminho_saida, "w", encoding="utf-8") as arq:
        arq.write(svg)


if __name__ == "__main__":
    gerar_svg_slide40("docs/figuras/slide40_rag_colorido.svg")
    print("Diagrama vetorial gerado em 'docs/figuras/slide40_rag_colorido.svg'.")
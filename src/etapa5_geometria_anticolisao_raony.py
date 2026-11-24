import math
import random
from typing import Dict, List, Tuple, Optional

def distancia_ponto_segmento(
    px: float, py: float, x1: float, y1: float, x2: float, y2: float
) -> float:
    """
    [INÍCIO DA FUNÇÃO - Autor: Raony Olivio Dias Capela]
    Calcula a menor distância euclidiana entre o centro de um vértice W(px, py) e o
    segmento de reta dirigido entre U(x1, y1) e V(x2, y2) usando projeção vetorial
    parametrizada limitada ao intervalo t em [0, 1].
    """
    dx, dy = x2 - x1, y2 - y1
    comp2 = dx * dx + dy * dy
    if comp2 == 0.0:
        return math.hypot(px - x1, py - y1)
    t = max(0.0, min(1.0, ((px - x1) * dx + (py - y1) * dy) / comp2))
    proj_x = x1 + t * dx
    proj_y = y1 + t * dy
    return math.hypot(px - proj_x, py - proj_y)



ESPACAMENTO_GRADE = 1.6   # distância (unidades do gráfico) entre células vizinhas
RAIO_EXCLUSAO_NO = 0.42   # raio (em células) proibido para arestas alheias ao nó
PENALIDADE_PROIBIDA = 1000.0
PENALIDADE_CRUZAMENTO = 250.0
PESO_AREA = 0.5
PESO_LADO = 0.6
def _orientacao(a, b, c) -> int:
    v = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    return 0 if abs(v) < 1e-9 else (1 if v > 0 else -1)

def _ponto_no_retangulo(a, b, p) -> bool:
    return (min(a[0], b[0]) - 1e-9 <= p[0] <= max(a[0], b[0]) + 1e-9 and
            min(a[1], b[1]) - 1e-9 <= p[1] <= max(a[1], b[1]) + 1e-9)

def _caixas_se_tocam(s, t) -> bool:
    (a, b), (c, d) = s, t
    return not (max(a[0], b[0]) < min(c[0], d[0]) or max(c[0], d[0]) < min(a[0], b[0]) or
                max(a[1], b[1]) < min(c[1], d[1]) or max(c[1], d[1]) < min(a[1], b[1]))



def _conflito_entre_segmentos(s, t, pontos_compartilhados) -> float:
    """
    [INÍCIO DA FUNÇÃO - Autor: Raony Olivio Dias Capela]
    Classifica o encontro de dois segmentos: 0 (livres ou unidos apenas no nó que
    compartilham), PENALIDADE_CRUZAMENTO (cruzam em X) ou PENALIDADE_PROIBIDA
    (sobrepostos, encostados ou um terminando no meio do outro).
    """
    a, b = s
    c, d = t
    o1, o2 = _orientacao(a, b, c), _orientacao(a, b, d)
    o3, o4 = _orientacao(c, d, a), _orientacao(c, d, b)
    if o1 == o2 == o3 == o4 == 0:
        eixo = 0 if abs(b[0] - a[0]) >= abs(b[1] - a[1]) else 1
        i0, i1 = sorted((a[eixo], b[eixo]))
        j0, j1 = sorted((c[eixo], d[eixo]))
        sobreposicao = min(i1, j1) - max(i0, j0)
        if sobreposicao > 1e-9:
            return PENALIDADE_PROIBIDA
        if sobreposicao > -1e-9:
            toque = a if a in (c, d) else b
            return 0.0 if toque in pontos_compartilhados else PENALIDADE_PROIBIDA
        return 0.0
    if o1 != o2 and o3 != o4:
        if 0 in (o1, o2, o3, o4):
            for p in (a, b):
                if p in (c, d) and p in pontos_compartilhados:
                    return 0.0
            return PENALIDADE_PROIBIDA
        return PENALIDADE_CRUZAMENTO
    for p, (q1, q2), o in ((c, (a, b), o1), (d, (a, b), o2), (a, (c, d), o3), (b, (c, d), o4)):
        if o == 0 and _ponto_no_retangulo(q1, q2, p):
            return 0.0 if p in pontos_compartilhados else PENALIDADE_PROIBIDA
    return 0.0



def _rotas_candidatas(a, b, incluir_desvios: bool):
    """Lista (pontos_da_rota, custo_extra) das rotas ortogonais possíveis de a até b."""
    (x1, y1), (x2, y2) = a, b
    rotas = []
    if not incluir_desvios:
        if x1 == x2 or y1 == y2:
            rotas.append(([a, b], 0.0))
        else:
            rotas.append(([a, (x2, y1), b], 3.0))   # "L": horizontal e depois vertical
            rotas.append(([a, (x1, y2), b], 3.0))   # "L": vertical e depois horizontal
            rotas.append(([a, b], 9.0))             # diagonal (último recurso)
        return rotas
    faixas_h = {y1 - 1, y1 + 1, y2 - 1, y2 + 1, y1 - .5, y1 + .5, y2 - .5, y2 + .5,
                min(y1, y2) - 1.5, max(y1, y2) + 1.5}
    for h in sorted(faixas_h):
        if h not in (y1, y2):
            rotas.append(([a, (x1, h), (x2, h), b], 12.0))
    faixas_v = {x1 - 1, x1 + 1, x2 - 1, x2 + 1, x1 - .5, x1 + .5, x2 - .5, x2 + .5,
                min(x1, x2) - 1.5, max(x1, x2) + 1.5}
    for v in sorted(faixas_v):
        if v not in (x1, x2):
            rotas.append(([a, (v, y1), (v, y2), b], 12.0))
    return rotas

def _direcao_unitaria(p, q):
    dx, dy = q[0] - p[0], q[1] - p[1]
    n = math.hypot(dx, dy)
    return (round(dx / n, 3), round(dy / n, 3))
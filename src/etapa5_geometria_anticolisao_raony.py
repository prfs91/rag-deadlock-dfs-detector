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
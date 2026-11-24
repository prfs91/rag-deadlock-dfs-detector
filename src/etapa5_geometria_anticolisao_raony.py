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
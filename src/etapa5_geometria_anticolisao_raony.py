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



def _avaliar_rota(pontos, extra, u, v, cel, segmentos_fixos, portas_usadas):
    segs = list(zip(pontos[:-1], pontos[1:]))
    custo = extra + sum(math.hypot(q[0] - p[0], q[1] - p[1]) for p, q in segs)
    # (1) a rota não pode passar por cima de nenhum nó (exceto sair/chegar nos seus)
    lim = RAIO_EXCLUSAO_NO
    for i, (p, q) in enumerate(segs):
        x0, x1 = sorted((p[0], q[0]))
        y0, y1 = sorted((p[1], q[1]))
        for w, pw in cel.items():
            if pw[0] < x0 - lim or pw[0] > x1 + lim or pw[1] < y0 - lim or pw[1] > y1 + lim:
                continue
            if (w == u and i == 0) or (w == v and i == len(segs) - 1):
                continue
            if distancia_ponto_segmento(pw[0], pw[1], p[0], p[1], q[0], q[1]) < lim:
                custo += PENALIDADE_PROIBIDA
    # (2)/(3) conflitos com arestas já roteadas
    for (x, y), segs_outra in segmentos_fixos.items():
        comuns = {cel[n] for n in (x, y) if n in (u, v)}
        for s in segs:
            for t in segs_outra:
                if _caixas_se_tocam(s, t):
                    custo += _conflito_entre_segmentos(s, t, comuns)
    # (2) duas setas não podem usar o mesmo lado (porta) de um nó
    d_saida = _direcao_unitaria(pontos[0], pontos[1])
    d_chegada = _direcao_unitaria(pontos[-1], pontos[-2])
    if (u, d_saida) in portas_usadas:
        custo += PENALIDADE_PROIBIDA
    if (v, d_chegada) in portas_usadas:
        custo += PENALIDADE_PROIBIDA
    return custo, segs, d_saida, d_chegada

def rotear_arestas_na_grade(
    cel: Dict[str, Tuple[float, float]],
    arestas: List[Tuple[str, str]]
) -> Tuple[float, Dict[Tuple[str, str], List[Tuple[float, float]]]]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Raony Olivio Dias Capela]
    Roteia todas as arestas (mais curtas primeiro) escolhendo, para cada uma, a rota
    ortogonal de menor custo dado o que já foi desenhado. Retorna (custo, rotas).
    """
    ordem = sorted(arestas, key=lambda e: (abs(cel[e[0]][0] - cel[e[1]][0]) +
                                           abs(cel[e[0]][1] - cel[e[1]][1]), e))
    segmentos_fixos, portas, rotas, total = {}, set(), {}, 0.0
    for (u, v) in ordem:
        a, b = cel[u], cel[v]
        melhor = None
        for desvios in (False, True):
            if desvios and melhor[0] < PENALIDADE_CRUZAMENTO:
                break
            for pts, extra in _rotas_candidatas(a, b, desvios):
                r = _avaliar_rota(pts, extra, u, v, cel, segmentos_fixos, portas)
                if melhor is None or r[0] < melhor[0]:
                    melhor = (r[0], pts, r[1], r[2], r[3])
        custo, pts, segs, d_saida, d_chegada = melhor
        segmentos_fixos[(u, v)] = segs
        portas.add((u, d_saida))
        portas.add((v, d_chegada))
        rotas[(u, v)] = pts
        total += custo
    return total, rotas



def _custo_disposicao(cel, arestas):
    total, rotas = rotear_arestas_na_grade(cel, arestas)
    xs = [p[0] for p in cel.values()]
    ys = [p[1] for p in cel.values()]
    largura, altura = max(xs) - min(xs) + 1, max(ys) - min(ys) + 1
    total += PESO_AREA * largura * altura + PESO_LADO * max(largura, altura) ** 2
    return total, rotas

def _construcao_gulosa(nos, arestas, raiz):
    vizinhos = {n: set() for n in nos}
    for u, v in arestas:
        vizinhos[u].add(v)
        vizinhos[v].add(u)
    cel = {raiz: (0, 0)}
    while len(cel) < len(nos):
        colocados = set(cel)
        candidatos = [n for n in nos if n not in cel and vizinhos[n] & colocados]
        if not candidatos:   # novo componente desconexo: começa à direita
            candidatos = [n for n in nos if n not in cel]
        candidatos.sort(key=lambda n: (-len(vizinhos[n] & colocados), nos.index(n)))
        n = candidatos[0]
        ocupadas = set(cel.values())
        ancoras = [cel[m] for m in vizinhos[n] if m in cel] or \
                  [(max(p[0] for p in ocupadas) + 2, 0)]
        opcoes = {(ax + dx, ay + dy) for (ax, ay) in ancoras
                  for dx in range(-2, 3) for dy in range(-2, 3)} - ocupadas
        sub = [e for e in arestas if (e[0] in cel or e[0] == n) and (e[1] in cel or e[1] == n)]
        melhor = None
        for op in sorted(opcoes):
            cel[n] = op
            c, _ = _custo_disposicao(cel, sub)
            if melhor is None or c < melhor[0]:
                melhor = (c, op)
        cel[n] = melhor[1]
    return cel



def _trocar(cel, no, alvo):
    antigo = cel[no]
    dono = next((m for m, p in cel.items() if p == alvo), None)
    cel[no] = alvo
    if dono:
        cel[dono] = antigo
    return antigo, dono

def _desfazer(cel, no, alvo, antigo, dono):
    cel[no] = antigo
    if dono:
        cel[dono] = alvo

def _recozimento_simulado(cel, arestas, semente=1, iteracoes=None, t_ini=30.0, t_fim=0.05):
    nos = sorted(cel)
    rng = random.Random(semente)
    iteracoes = iteracoes or 200 * len(nos)
    c_atual, _ = _custo_disposicao(cel, arestas)
    melhor = (c_atual, dict(cel))
    for it in range(iteracoes):
        temp = t_ini * (t_fim / t_ini) ** (it / iteracoes)
        no = rng.choice(nos)
        x, y = cel[no]
        alvo = (x + rng.randint(-2, 2), y + rng.randint(-2, 2))
        if alvo == (x, y):
            continue
        antigo, dono = _trocar(cel, no, alvo)
        c_novo, _ = _custo_disposicao(cel, arestas)
        if c_novo <= c_atual or rng.random() < math.exp((c_atual - c_novo) / temp):
            c_atual = c_novo
            if c_novo < melhor[0] - 1e-9:
                melhor = (c_novo, dict(cel))
        else:
            _desfazer(cel, no, alvo, antigo, dono)
    return melhor[1]

def _descida_exaustiva(cel, arestas, max_passadas=6):
    c_atual, _ = _custo_disposicao(cel, arestas)
    for _ in range(max_passadas):
        melhorou = False
        xs = [p[0] for p in cel.values()]
        ys = [p[1] for p in cel.values()]
        alvos = [(x, y) for x in range(min(xs) - 1, max(xs) + 2)
                 for y in range(min(ys) - 1, max(ys) + 2)]
        for no in sorted(cel):
            for alvo in alvos:
                if alvo == cel[no]:
                    continue
                antigo, dono = _trocar(cel, no, alvo)
                c_novo, _ = _custo_disposicao(cel, arestas)
                if c_novo < c_atual - 1e-9:
                    c_atual, melhorou = c_novo, True
                else:
                    _desfazer(cel, no, alvo, antigo, dono)
        if not melhorou:
            break
    return cel



def _componentes_sao_ciclos_disjuntos(nos, arestas) -> Optional[List[List[str]]]:
    """Se o grafo for apenas 2+ ciclos simples disjuntos (Slide 30(c)/38), devolve-os."""
    saida = {n: [] for n in nos}
    entrada = {n: 0 for n in nos}
    for u, v in arestas:
        saida[u].append(v)
        entrada[v] += 1
    if any(len(saida[n]) != 1 or entrada[n] != 1 for n in nos):
        return None
    vistos, ciclos = set(), []
    for n in nos:
        if n in vistos:
            continue
        ciclo, atual = [], n
        while atual not in vistos:
            vistos.add(atual)
            ciclo.append(atual)
            atual = saida[atual][0]
        ciclos.append(ciclo)
    return ciclos if len(ciclos) >= 2 else None

def _arco_circular(centro, raio, ang_ini, ang_fim, passos=40):
    if ang_fim > ang_ini:          # sentido horário: o ângulo sempre diminui
        ang_fim -= 2 * math.pi
    return [(centro[0] + raio * math.cos(ang_ini + (ang_fim - ang_ini) * i / passos),
             centro[1] + raio * math.sin(ang_ini + (ang_fim - ang_ini) * i / passos))
            for i in range(passos + 1)]



def calcular_layout_e_rotas(
    processos: List[str],
    recursos: List[str],
    arestas: List[Tuple[str, str]]
) -> Tuple[Dict[str, Tuple[float, float]], Dict[Tuple[str, str], List[Tuple[float, float]]]]:
    """
    [INÍCIO DA FUNÇÃO - Autor: Raony Olivio Dias Capela]
    Ponto de entrada do motor geométrico. Devolve:
      - pos[no]   = (x, y) do centro de cada processo/recurso;
      - rotas[(u, v)] = lista de pontos (centro de u ... centro de v) por onde a
        seta u -> v deve passar, livre de colisões com nós e outras arestas.
    A seta sempre aponta para v: P -> R = solicitação; R -> P = posse (Aula 07).
    """
    nos = list(processos) + list(recursos)
    ciclos = _componentes_sao_ciclos_disjuntos(nos, arestas)
    if ciclos:
        # Círculo Trigonométrico Autoajustável (um círculo por ciclo, Slide 30(c)/38)
        pos, rotas, centro_x = {}, {}, 0.0
        for ciclo in ciclos:
            k = len(ciclo)
            raio = max(1.45, k * 0.36)
            angulos = {}
            for i, no in enumerate(ciclo):
                ang = (math.pi / 2.0) - (2.0 * math.pi * i / k)
                angulos[no] = ang
                pos[no] = (centro_x + raio * math.cos(ang), raio * math.sin(ang))
            for i, no in enumerate(ciclo):
                prox = ciclo[(i + 1) % k]
                rotas[(no, prox)] = _arco_circular((centro_x, 0.0), raio, angulos[no], angulos[prox])
            centro_x += 2.0 * raio + 2.2
        return pos, rotas

    if not arestas:
        cel = {n: (i, 0) for i, n in enumerate(nos)}
    else:
        grau = {n: sum(n in e for e in arestas) for n in nos}
        raizes = sorted(nos, key=lambda n: (-grau[n], nos.index(n)))[:5]
        melhor = None
        for raiz in raizes:
            cel = _construcao_gulosa(nos, arestas, raiz)
            c, _ = _custo_disposicao(cel, arestas)
            if melhor is None or c < melhor[0]:
                melhor = (c, cel)
        cel = _recozimento_simulado(dict(melhor[1]), arestas)
        cel = _descida_exaustiva(cel, arestas)
    _, rotas_grade = _custo_disposicao(cel, arestas)
    min_x = min(p[0] for p in cel.values())
    min_y = min(p[1] for p in cel.values())
    conv = lambda p: ((p[0] - min_x) * ESPACAMENTO_GRADE, -(p[1] - min_y) * ESPACAMENTO_GRADE)
    pos = {n: conv(p) for n, p in cel.items()}
    rotas = {e: [conv(p) for p in pts] for e, pts in rotas_grade.items()}
    return pos, rotas

# Motor de Detecção de Impasses (*Deadlocks*) via Busca em Profundidade em Grafos de Alocação de Recursos (RAG)

> **Disciplina:** Sistemas Operacionais — Faculdade de Engenharia de Computação (UFPA — *Campus* Universitário de Tucuruí)  
> **Docente:** Prof. Dr. Iago Medeiros (`iagomedeiros@ufpa.br`)  
> **Escopo Técnico:** Modelagem formal de Grafos de Alocação de Recursos (*Resource Allocation Graphs* - RAG) com instância única por classe e detecção automatizada de ciclos de espera circular por Busca em Profundidade (*Depth-First Search* - DFS).

---

## 1. Fundamentação Teórica e Convenção Visual dos Slides

Em Sistemas Operacionais, um conjunto de processos encontra-se em situação de impasse (*deadlock*) quando cada processo do conjunto aguarda por um evento que apenas outro processo pertencente ao mesmo conjunto pode causar. De acordo com Coffman *et al.* (1971), quatro condições precisam ocorrer simultaneamente:
1. **Exclusão mútua** (*Mutual exclusion*);
2. **Posse e espera** (*Hold and wait*);
3. **Não-preempção** (*No preemption*);
4. **Espera circular** (*Circular wait*).

Para sistemas que possuem **apenas uma instância de cada tipo de recurso** (ex.: uma unidade de fita, uma *plotter*, um *scanner*), a modelagem de Holt (1972) apresentada nos slides da disciplina utiliza um grafo dirigido bipartido $G = (V, E)$:
* **Processos ($P$):** Representados graficamente por **círculos**.
* **Recursos ($R$):** Representados graficamente por **quadrados**.
* **Arco de Posse ($R_j \rightarrow P_i$):** Indica que o recurso $R_j$ está atualmente alocado ao processo $P_i$.
* **Arco de Requisição ($P_i \rightarrow R_j$):** Indica que o processo $P_i$ está bloqueado aguardando a liberação do recurso $R_j$.

---

## 2. Formato de Entrada Escolhido (Opção 1 — Lista de Arestas)

A equipe padronizou a **Opção 1 (Lista de Arestas)** por sua clareza estrutural e correspondência direta com os arcos dirigidos dos slides:

```text
PROCESSOS A B C D E F G
RECURSOS R S T U V W
ARESTAS
R A
A S
...
```

---

## 3. Como Executar os Testes Oficialmente Exigidos

O projeto utiliza exclusivamente a biblioteca padrão do Python 3 (`sys`, `argparse`, `typing`), dispensando instalação de dependências externas.

### Execução Padrão dos 3 Casos Obrigatórios:
```bash
# Caso de Teste 1: Grafo completo do Slide 40 (7 processos e 6 recursos)
python3 src/detector_impasse_dfs.py tests/caso_slide40_multiplos_nos.txt

# Caso de Teste 2: Grafo 1 da aula (Alocação sem formação de ciclo)
python3 src/detector_impasse_dfs.py tests/caso_grafo1_concorrente_seguro.txt

# Caso de Teste 3: Grafo 2 da aula (Espera circular entre A, B, C e R, S, T)
python3 src/detector_impasse_dfs.py tests/caso_grafo2_espera_circular.txt
```

### Modo de Rastreamento Didático (Exibição da Lista $L$ passo a passo):
Para visualizar o avanço e o retrocesso (*backtracking*) da lista $L$ idêntico à explicação dos Slides 39 a 42:
```bash
python3 src/detector_impasse_dfs.py tests/caso_slide40_multiplos_nos.txt --rastrear
```

---

## 4. Resultados dos Casos de Teste Obrigatórios

| Caso | Arquivo de Teste | Descrição da Topologia (Slides da Aula) | Saída Esperada | Saída Obtida pelo Detector | Status |
| :---: | :--- | :--- | :--- | :--- | :---: |
| **T1** | `tests/caso_slide40_multiplos_nos.txt` | Grafo do Slide 40 (`A..G`, `R..W`) com beco sem saída em `S` e ciclo fechado envolvendo `D, T, E, V, G, U` | Deadlock no ciclo `D, T, E, V, G, U` | `Há deadlock: T -> E -> V -> G -> U -> D -> T` *(equivalente a `D -> T -> E -> V -> G -> U -> D`)* | **Aprovado** |
| **T2** | `tests/caso_grafo1_concorrente_seguro.txt` | Grafo 1 da aula (`A, B, C` requisitando `R, S, T` sem fechar ciclo de dependência) | Sem deadlock | `Sem deadlock` | **Aprovado** |
| **T3** | `tests/caso_grafo2_espera_circular.txt` | Grafo 2 da aula (`R->A`, `S->B`, `T->C` e requisições cruzadas `A->S`, `B->T`, `C->R`) | Deadlock entre `A, B, C` e `R, S, T` | `Há deadlock: R -> A -> S -> B -> T -> C -> R` | **Aprovado** |
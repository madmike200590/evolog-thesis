graph(
    lst(a, lst(b, lst(c, lst_empty))),
    lst(edge(a, b), lst(edge(b, c), lst(edge(c, a), lst_empty)))).

vertex_element(V, TAIL) :- graph(lst(V, TAIL), _).
vertex_element(V, TAIL) :- vertex_element(_, lst(V, TAIL)).
vertex(V) :- vertex_element(V, _).
edge_element(E, TAIL) :- graph(_, lst(E, TAIL)).
edge_element(E, TAIL) :- edge_element(_, lst(E, TAIL)).
edge(V1, V2) :- edge_element(edge(V1, V2), _).
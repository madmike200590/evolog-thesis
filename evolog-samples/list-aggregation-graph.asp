vertex(a).
vertex(b).
vertex(c).
edge(a,b).
edge(b,c).
edge(c,a).

%% pack vertices into a vertex list
vertex_element(E) :- vertex(E).
% First, establish ordering of elements (which we need to establish the order within the list)
vertex_element_less(N, K) :- vertex_element(N), vertex_element(K), N < K.
vertex_element_not_predecessor(N, K) :- vertex_element_less(N, I), vertex_element_less(I, K).
vertex_element_predecessor(N, K) :- vertex_element_less(N, K), not vertex_element_not_predecessor(N, K).
vertex_element_has_predecessor(N) :- vertex_element_predecessor(_, N).
% Now build the list as a recursively nested function term
vertex_lst_element(IDX, list(N, list_empty)) :- vertex_element(N), not vertex_element_has_predecessor(N), IDX = 0.
vertex_lst_element(IDX, list(N, list(K, TAIL))) :- vertex_element(N), vertex_element_predecessor(K, N), vertex_lst_element(PREV_IDX, list(K, TAIL)), IDX = PREV_IDX + 1.
has_next_vertex_element(IDX) :- vertex_lst_element(IDX, _), NEXT_IDX = IDX + 1, vertex_lst_element(NEXT_IDX, _).
vertex_lst(LIST) :- vertex_lst_element(IDX, LIST), not has_next_vertex_element(IDX).

%% pack edges into an edge list
edge_element(edge(V1, V2)) :- edge(V1, V2).
% First, establish ordering of elements (which we need to establish the order within the list)
edge_element_less(N, K) :- edge_element(N), edge_element(K), N < K.
edge_element_not_predecessor(N, K) :- edge_element_less(N, I), edge_element_less(I, K).
edge_element_predecessor(N, K) :- edge_element_less(N, K), not edge_element_not_predecessor(N, K).
edge_element_has_predecessor(N) :- edge_element_predecessor(_, N).
% Now build the list as a recursively nested function term
edge_lst_element(IDX, list(N, list_empty)) :- edge_element(N), not edge_element_has_predecessor(N), IDX = 0.
edge_lst_element(IDX, list(N, list(K, TAIL))) :- edge_element(N), edge_element_predecessor(K, N), edge_lst_element(PREV_IDX, list(K, TAIL)), IDX = PREV_IDX + 1.
has_next_edge_element(IDX) :- edge_lst_element(IDX, _), NEXT_IDX = IDX + 1, edge_lst_element(NEXT_IDX, _).
edge_lst(LIST) :- edge_lst_element(IDX, LIST), not has_next_edge_element(IDX).
vertex(a).
vertex(b).
vertex(c).
edge(a, b).
edge(b, c).
edge(c, a).
vertex_lst(LIST) :- list_1_result(list_1_no_args, LIST).
edge_lst(LIST) :- list_2_result(list_2_no_args, LIST).
list_1_element_greater(ARGS, N, K) :- list_1_element(ARGS, N), list_1_element(ARGS, K), N > K.
list_1_element_not_successor(ARGS, N, K) :- list_1_element_greater(ARGS, N, I), list_1_element_greater(ARGS, I, K).
list_1_element_successor(ARGS, N, K) :- list_1_element_greater(ARGS, N, K), not list_1_element_not_successor(ARGS, N, K).
list_1_element_has_successor(ARGS, N) :- list_1_element_successor(ARGS, _0, N).
list_1_lst_element(ARGS, IDX, lst(N, lst_empty)) :- list_1_element(ARGS, N), IDX = 0, not list_1_element_has_successor(ARGS, N).
list_1_lst_element(ARGS, IDX, lst(N, lst(K, TAIL))) :- list_1_element(ARGS, N), list_1_element_successor(ARGS, K, N), list_1_lst_element(ARGS, PREV_IDX, lst(K, TAIL)), IDX = PREV_IDX + 1.
list_1_has_next_element(ARGS, IDX) :- list_1_lst_element(ARGS, IDX, _1), NEXT_IDX = IDX + 1, list_1_lst_element(ARGS, NEXT_IDX, _2).
list_1_result(ARGS, LIST) :- list_1_lst_element(ARGS, IDX, LIST), not list_1_has_next_element(ARGS, IDX).
list_1_element(list_1_no_args, V) :- vertex(V).
list_2_element_greater(ARGS, N, K) :- list_2_element(ARGS, N), list_2_element(ARGS, K), N > K.
list_2_element_not_successor(ARGS, N, K) :- list_2_element_greater(ARGS, N, I), list_2_element_greater(ARGS, I, K).
list_2_element_successor(ARGS, N, K) :- list_2_element_greater(ARGS, N, K), not list_2_element_not_successor(ARGS, N, K).
list_2_element_has_successor(ARGS, N) :- list_2_element_successor(ARGS, _3, N).
list_2_lst_element(ARGS, IDX, lst(N, lst_empty)) :- list_2_element(ARGS, N), IDX = 0, not list_2_element_has_successor(ARGS, N).
list_2_lst_element(ARGS, IDX, lst(N, lst(K, TAIL))) :- list_2_element(ARGS, N), list_2_element_successor(ARGS, K, N), list_2_lst_element(ARGS, PREV_IDX, lst(K, TAIL)), IDX = PREV_IDX + 1.
list_2_has_next_element(ARGS, IDX) :- list_2_lst_element(ARGS, IDX, _4), NEXT_IDX = IDX + 1, list_2_lst_element(ARGS, NEXT_IDX, _5).
list_2_result(ARGS, LIST) :- list_2_lst_element(ARGS, IDX, LIST), not list_2_has_next_element(ARGS, IDX).
list_2_element(list_2_no_args, edge(V1, V2)) :- edge(V1, V2).


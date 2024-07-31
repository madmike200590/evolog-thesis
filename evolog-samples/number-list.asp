%% number-list.asp %%
% Collects all even numbers up to a given limit into a list
%%
num(1..MAX) :- max_num(MAX).

even_num(N) :- num(N), N \ 2 = 0.

%% designate even numbers as the elements we want to gather
element_tuple(tuple(N)) :- even_num(N).

%%% Now we collect our nums into a list 
% First, establish ordering of numbers (which we need to establish the order within the list)
element_tuple_less(N, K) :- element_tuple(N), element_tuple(K), N < K.
not_predecessor(N, K) :- element_tuple_less(N, I), element_tuple_less(I, K).
predecessor(N, K) :- element_tuple_less(N, K), not not_predecessor(N, K).
has_predecessor(N) :- predecessor(_, N).

% Now build the list as a recursively nested function term
lst_element(IDX, list(N, list_empty)) :- element_tuple(N), not has_predecessor(N), IDX = 0.
lst_element(IDX, list(N, list(K, TAIL))) :- element_tuple(N), predecessor(K, N), lst_element(PREV_IDX, list(K, TAIL)), IDX = PREV_IDX + 1.
has_next_element(IDX) :- lst_element(IDX, _), NEXT_IDX = IDX + 1, lst_element(NEXT_IDX, _).
lst(LIST) :- lst_element(IDX, LIST), not has_next_element(IDX).

% Tests whether there is more than one atom of predicate "lst/1".
% The expectation is that there is only one, i.e. the fully generated 
% list comprised of all eligible elements is unique
#test unique_list(expect: 1) {
	given {
		max_num(400).
	}
	assertForAll {
		% sanity check, make sure the right even numbers exist.
		exists_even_two :- even_num(2).
		exists_even_four :- even_num(4).
		:- not exists_even_two.
		:- not exists_even_four.
		
		% Only one instance of "lst"
		:- lst(L1), lst(L2), L1 != L2.
		
		%% Verify that lst instance contains exactly the expected elements.
		% First, unwrap all list elements
		element(ELEM, TAIL) :- lst(list(ELEM, TAIL)).
		element(ELEM, TAIL) :- element(_, list(ELEM, TAIL)).
		element_value(VAL) :- element(VAL, _).
		
		% Validate list content
		:- not element_value(tuple(2)).
		:- not element_value(tuple(4)).
		unexpected_element_value :- element_value(tuple(V)) , V != 2, V != 4.
		:- unexpected_element_value.
	}
}
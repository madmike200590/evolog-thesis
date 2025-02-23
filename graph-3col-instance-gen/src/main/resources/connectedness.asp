% make sure graph is undirected
edge(A, B) :- edge(B, A).

reachable(A, B) :- vertex(A), vertex(B), edge(A, B).
reachable(A, C) :- vertex(A), vertex(B), vertex(C), edge(A, B), reachable(B, C).

% graph is not connected if there is a vertex pair with no path between the vertices
unreachable(A, B) :- vertex(A), vertex(B), not reachable(A, B), A != B.
:- vertex(A), vertex(B), A != B, unreachable(A, B).
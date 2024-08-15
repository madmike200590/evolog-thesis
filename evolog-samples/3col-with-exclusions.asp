vertex(a).
vertex(b).
vertex(c).
vertex(d).
edge(a, b).
edge(a, c).
edge(a, d).
edge(b, c).
edge(b, d).
edge(c, d).
edge(X, Y) :- edge(Y, X).

exclude_vertex(d).
exclude_edge(V1, V2) :- edge(V1, V2), exclude_vertex(V1).
exclude_edge(V1, V2) :- exclude_edge(V2, V1).

coloring_vertex(V) :- vertex(V), not exclude_vertex(V).
coloring_edge(V1, V2) :- edge(V1, V2), not exclude_edge(V1, V2).

% Guess colors
red(V) :- coloring_vertex(V), not green(V), not blue(V).
green(V) :- coloring_vertex(V), not red(V), not blue(V).
blue(V) :- coloring_vertex(V), not red(V), not green(V).

% Filter invalid guesses
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), red(V1), red(V2).
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), green(V1), green(V2).
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), blue(V1), blue(V2).
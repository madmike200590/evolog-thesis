coloring_vertex(b).
exclude_vertex(d).
edge(b, d).
edge(a, b).
edge(c, d).
edge(c, b).
coloring_edge(b, c).
coloring_edge(a, c).
coloring_edge(b, a).
edge(a, d).
coloring_edge(c, a).
vertex(c).
vertex(a).
edge(d, b).
exclude_edge(d, b).
exclude_edge(c, d).
exclude_edge(a, d).
coloring_vertex(c).
exclude_edge(b, d).
coloring_vertex(a).
edge(a, c).
edge(b, c).
edge(b, a).
edge(d, c).
coloring_edge(a, b).
coloring_edge(c, b).
vertex(d).
exclude_edge(d, a).
vertex(b).
edge(c, a).
exclude_edge(d, c).
edge(d, a).
red(V) :- coloring_vertex(V), not green(V), not blue(V).
green(V) :- coloring_vertex(V), not red(V), not blue(V).
blue(V) :- coloring_vertex(V), not red(V), not green(V).
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), red(V1), red(V2).
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), green(V1), green(V2).
:- coloring_vertex(V1), coloring_vertex(V2), coloring_edge(V1, V2), blue(V1), blue(V2).


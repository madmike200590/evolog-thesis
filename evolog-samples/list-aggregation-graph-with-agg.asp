vertex(a).
vertex(b).
vertex(c).
edge(a,b).
edge(b,c).
edge(c,a).

%% pack vertices into a vertex list
vertex_lst(LIST) :- LIST = #list{V : vertex(V)}.

%% pack edges into an edge list
edge_lst(LIST) :- LIST = #list{edge(V1, V2) : edge(V1, V2)}.
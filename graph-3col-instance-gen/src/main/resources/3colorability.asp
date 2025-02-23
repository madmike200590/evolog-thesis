% Make sure edges are symmetric
edge(V2, V1) :- edge(V1, V2).

% Guess colors
red(V) :- vertex(V), not green(V), not blue(V).
green(V) :- vertex(V), not red(V), not blue(V).
blue(V) :- vertex(V), not red(V), not green(V).

% Filter invalid guesses
:- vertex(V1), vertex(V2), edge(V1, V2), red(V1), red(V2).
:- vertex(V1), vertex(V2), edge(V1, V2), green(V1), green(V2).
:- vertex(V1), vertex(V2), edge(V1, V2), blue(V1), blue(V2).

col(V, red) :- red(V).
col(V, blue) :- blue(V).
col(V, green) :- green(V).
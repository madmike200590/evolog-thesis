#enumeration_predicate_is ordinal.

color(white).
color(red).
color(magenta).
color(yellow).
color(green).
color(cyan).
color(blue).
color(black).

numbered_color(COL, NUM) :- color(COL), ordinal(colors, COL, NUM).
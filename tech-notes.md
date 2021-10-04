# Evolog Technical Design

## Random thoughts, notes on design

### Evolog vs. Alpha

#### Keep Evolog and "Standard Alpha" code bases separate?
No, we don't want them to diverge massively, both should make use of latest solving features, static analysis, etc.

However, alpha and evolog should be different executables (and library-jars), i.e. the modularized alpha architecture should be extended by an evolog-cli-app and evolog-lib module.

#### How to distinguish between "vanilla ASP solving" and Evolog program execution?
An Evolog program might significantly differ from what Alpha (or ASPCore2) considers a valid program. However, every ASPCore2 program is a valid Evolog program. ~At the very least, we need _different parsers_, one with the ASPCore2 Grammar, the other with the (extended) Evolog grammar.~ Scratch this, we'd have to duplicate  the code from ParseTreeVisitor, we don't wanna do that. Evolog-specific features are handled by a new visitor that extends the current one.

Since Every ASPCore2 program is a valid evolog program, we don't want to distinguish between the two in program implementations. The Alpha backend will be extended to always fully support Evolog execution, but - depending on the parser in use - full Evolog- or only ASPCore2-Syntax is accepted. Note that this might need to be revisited when adding program modules.

Possible ways to distinguish would then be ~a CLI switch for ASPCore2/Evolog mode, or~ separate executables (seems nicer).

### Implementation of Actions

#### Work Packages
- Make Solver-Mode (ASPCore2 vs Evolog) configurable: Alpha interface should cover both, Main probably different
 - Implement configurer component for all objects used by AlphaImpl (also transitively used). Could be spring, but do hand-crafted for now
- Design static checks on Evolog programs (action safety, stratification analysis)
- Implement additional actions
- Proper Test Suite for actions

#### Binding action heads to code

* we don't want to use reflection
* have to get from the string id of the action to a bound method

## Actions

### Syntax

We want rule heads triggering actions to derive user-defined predicates, i.e. one should be able to directly assign an arbitrary predicate name to the result of an "file\_open" action, rather than having to write rules like "`config_file_open(RES) :- @file_open[F](RES), config_path(F).`". This seems to be more convenient and also saves us from the (potentially huge) problem of having all actions of same type use the same predicate name which would mess up dependency analysis (e.g. when code needs to first read one file, then another, and then do something, where read order is important).

Draft syntax example: Read from file "a.txt" (line-wise) and write to file "b.txt"
```
src_file("a.txt").
dst_file("b.txt").

src_stream(RES) : @file_open[SRC, "r"] = RES :- #file_exists[SRC], src_file(SRC).
dst_stream(RES) : @file_open[DST, "w"] = RES :- #file_exists[DST], dst_file(DST).

["Error opening source file " || ERRMSG] :- src_stream(error(ERRMSG)).
["Error opening destination file " || ERRMSG]  :- dst_stream(error(ERRMSG)).

src_line_read(0, RES) : @next_line[SRC] = RES :- src_stream(SRC).
dst_line_written(0, RES) : @write_line[DST, LINE] = RES :- src_line_read(0, string(LINE)), dst_stream(DST).

src_line_read(N + 1, RES) : @next_line[SRC] = RES :- src_stream(SRC), src_line_read(N, string(_)).
dst_line_written(N + 1, RES) : @write_line[DST, LINE] = RES :- src_line_read(N + 1, string(LINE)), dst_stream(DST), dst_line_written(N, ok).

["Error reading source file line " || ERRMSG] :- src_line_read(_, error(ERRMSG)).
["Error writing destination file line " || ERRMSG] :- dst_line_written(_, error(ERRMSG)).

src_file_all_read :- src_line_read(_, eof).
src_closed : @file_close[SRC] = _ :- src_file_all_read, src_file(SRC).

dst_file_all_written :- dst_line_written(LINE_NO, ok), src_line_read(LINE_NO + 1, eof).
dst_closed : @file_close[DST] = _ :- dst_file_all_written, dst_file(DST).

```

### Semantics

Actions are represented as (interpreted) functions, i.e. an action head `p(Y) : @f[X] = Y` can be seen as a short-hand for `p(f(X))`, where `f(X)` denotes the (action-)function `f` that is applied to term `X` and gives the result `Y`.

Function congruence axioms hold for action functions (TODO write out axioms).

#### Axioms

- Actions may only occur in those nodes of a program's component graph, where no incoming path from any entry node (i.e. fact predicate) contains cycles through negation.
- Actions are idempotent (implementation-wise: only get executed once per unique set of ground input terms). NOTE: How does this correlate to a getCurrentTime() external?
- Actions that are not on a common path in the component graph are assumed to be independent, i.e. do not influence each others results.



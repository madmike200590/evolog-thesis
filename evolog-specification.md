# Evolog Language Specification

## Syntax

Every valid ASP-Core2 program is a valid Evolog program. In addition, Evolog programs may contain *action rules* and *module literals*.

### Action Rules

Action Rules are ASP rules that have a body as defined by the ASP-Core2 standard and an *action head*, where an action head is of the following form:
```
<head-atom> : @<action-func>[<action-input>] = <res-var>

where
<head-atom> is an ASP atom of form <pred>(t_1,...,t_n)
<action-func> is the name of an action function, i.e. an identifier starting with a lower-case letter
<action-input> is a list of action input terms
<res-var> is an action result variable (i.e. a normal ASP variable)
```
Action result variables must not occur in the rule body.

### Module Literals

TBD

## Semantics

### Action Rules

#### Desiderata

For every Evolog Program `P` and answer set `A`, the following must be clearly defined:
- D1: Which actions were executed by the program?
- D2: For every individual action `act`, what led to the action being executed, i.e. of which rule body is `act` a consequence?
Combining D1 and D2 it follows that 
- D3: for actions that depend on other actions, it is clearly visible in which sequence they were executed.

Furthermore, 
- D4: all state changes effected on the outside world by execution of `P` are reflected in each answer set (as results of actions)

#### Applicability of action rules

In order to guarantee D1 and D4, for every (ground) action rule `R_a` that fires, it must hold that the corresponding ground instance of `head(R_a)` is part of *every answer set*.
Implementations may further restrict this in order to ensure static verifiability of the condidtion (e.g. by restricting action rules to  the stratified part, i.e. common base program of a program).

#### Expansion of action rules

Semantically, every action rule is equivalent to its *expansion*:
```
file1_open(OP_RES) : @fileInputStream[PATH] = OP_RES :- file1(PATH). %  r1
```
The expansion of `r1` is:
```
action_result(r1, fileInputStream, PATH, OP_RES) :- file1(PATH).
file1_open(OP_RES) :- action_result(r1, fileInputStream, PATH, OP_RES).
```
Consequently, it is ensured that for each ground instance of an action rule `R_a` that fires, there is exactly one `action_result` instance in every answer set. We call this atom a *witness of action `act`*. Requirement D1 is fulfilled through the existence of action witnesses. Furthermore, inspection of a program (or its dependency graph) and all action witnessesin an answer set yields the information demanded in D2.

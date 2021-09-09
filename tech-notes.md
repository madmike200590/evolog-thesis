# Evolog Technical Design

## Random thoughts, notes on design

### Evolog vs. Alpha

#### Keep Evolog and "Standard Alpha" code bases separate?
No, we don't want them to diverge massively, both should make use of latest solving features, static analysis, etc.

#### How to distinguish between "vanilla ASP solving" and Evolog program execution?
An Evolog program might significantly differ from what Alpha (or ASPCore2) considers a valid program. ~At the very least, we need _different parsers_, one with the ASPCore2 Grammar, the other with the (extended) Evolog grammar.~ Scratch this, we'd have to duplicate  the code from ParseTreeVisitor, we don't wanna do that. Evolog-specific features are handed by a new visitor that extends the current one.

Possible ways to distinguish would then be a CLI switch for ASPCore2/Evolog mode, or separate executables (seems nicer).

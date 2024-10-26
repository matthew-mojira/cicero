# Expressions

Cicero is an *expression-oriented* language. Unlike other languages, there are
no *statements* in Cicero. Although they may look the same, they can be thought
of as two different ways:
* statements are commands which are *executed*
* expressions are computations which are *evaluated*

The result of a statement is just the state of the world following execution.
The result of an expression is its *value*.

## Side effects

However, expressions can have *side effects* if it changes the state of the
world. Some expressions are often used for their side effects, rather than
their value. For example, variable assignment expressions evaluate to the new
value for the variable, but you probably write the expression for the
assignment, which is its side effect.

## Arity

Arity is a feature which allows an expression to evaluate to a number of
values. Arity is not a structure of the language or a compound value type.

Currently, expressions can only evaluate to zero or one values. For example,
a block expression evaluates to the value of the last block in the
expression, but the empty block `{ }` evaluates to zero values.

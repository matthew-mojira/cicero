# Cicero

Cicero is a toy dynamically-typed programming language, loosely modeled after
Python for research work on WebAssembly.

At its core, Cicero is an expression-oriented language, with object-oriented
features.

## Language features

> 5
> => 5

> 1 + 2
> => 3

## Built-in types

* `int` (unbounded length)
* `float` (f64)
* `bool`
* `string` (UTF-8)
* `func`
* `tuple` (everything is a tuple!)
* `list`
* `map`
* `type`
* `struct`
* `object`

struct Person {
    field name;
    func create(self, name) {
        
    }
}

new(Person)

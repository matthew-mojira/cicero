We're going to refactor the Object model to make it more similar to class-based
object-oriented programming.

Right now, methods and fields are basically indistinguishable. An object 
internally contains a field called `fields`, which has the fields AND methods
of an object. These are both initialized by the class at the time the object
is created, but this has a few issues.

1. lazy methods - allocating a bound method for every object is quite expensive,
   and we used lazy methods to get around this, but perhaps that's a symptom of
   a more fundamental issue with the object model
2. inheritance - fields and methods are inherited by the lastest definition in
   the class hierarchy, but once a method is overwritten there's no way to 
   access the definition to a superclass, like a `super` keyword.

Ultimately, this means that objects in cicero behave more like a prototype-based
model instead of a class-based one. And we ought to figure out which one it
should be.

# Classes, anew

Finally, we'll have *native fields*, so you'll get to do some absolutely crazy
things (that we desparately need to figure out how to optimize!).

# Methods

`base`: 
* field `class` (yes, you can change the class of an object at runtime!)
* method `display`
* method `fields`
* method `is-true`

`bool`:
* method `display` (override)
* method `not`
* method `and`
* method `or`
* method `is-true` (override)

`char`:
* method `display` (override)
* method `+`
* method `ascii`

`class`:
* method `display` (override)
* field `name`
* field `superclass`



# New operations

Yes, you can change the class of an object and make it a different class. For
most intents and purposes, this will cause some major issue down the line. The
issue is more critical when it is a built-in class that relies on Virgil-level
information. We have tried in this refactoring to expose as many internal
components as fields of the object (which are mutable), but some hold 
information that is structural to the value, like the value of an int.

What to do if the user changes a value of a non-int class to int? We can't
switch it internally. Perhaps this should be an exception, but where, and for
what reason? Or, do we permit this, and simply use a default value for the
type?

## bind

`bind` is almost like a partial application, and in general it could definitely
be. But in this case, `bind` refers to creating *bound methods*. 

`(bind o f)` takes an object `o` and binds it to a function `f`, creating a
bound method. The function `f` requires one parameter (not necessarily named
`self`) and creates a method where only the remaining arguments need to be
supplied. 

Like other object-oriented languages, the `self` or `this` object is the first 
local variable, however, the binding is done separately because in general, we
need to support first-class functions and (first-class) bound methods.

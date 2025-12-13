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

## bind

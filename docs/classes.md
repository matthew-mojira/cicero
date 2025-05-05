# Built-in classes

Built-in classes usually wrap around some internal Virgil value or object. Some
of these can only be represented in Virgil (e.g. int) and some of these can
be represented as Cicero objects. These "primitive fields" are immutable core
information on an object which would significantly change (read: break) the
runtime if they were modified. Thus field accesses are done through getter
methods. For example, you cannot change the code of a function. Its accessor
method `code` is mutable, but this mutates the accessor method, not the 
internal code. Interally, these methods are not used by the runtime, and access
is done directly to the underlying object away from user manipulation. In the
future, this might change so that primitive fields are treated as regular
fields and all operations access these fields so that the user might change it.

## bool

Represents a boolean value.

Methods:
* `(b.display)`: returns a string representation of the object
* `(b.not)`: gets the logical negation of `b`
* `(b1.and b2)`: gets the logical conjunction of `b1` and `b2`. `b2` must be
  another boolean object
* `(b1.or b2)`: gets the logical disjunction of `b1` and `b2`. `b2` must be
  another boolean object

Note that the binary operators *do not* short circuit.

## class

Represents a class.

Methods:
* `(c.display)`: returns a string representation of the object
* `(c.superclass)`: gets the superclass of this class. Throws an exception if
  the class does not have a superclass, if and only if, this is the base class
* `(c.name)`: gets the name of the class as a string

## code

Wrapper for code.

Methods:
* `(co.display)`: returns a string representation of the object

## exn

Represents an exception, which holds a message and a stacktrace.

Methods:
* `(e.display)`: returns a string representation of the object
* `(e.stacktrace)`: returns the stacktrace as a list of strings

## frame

Wrapper for a frame of execution.

Methods:
* `(fr.display)`: returns a string representation of the object

## func

Represents a callable function.

Methods:
* `(f.display)`: returns a string representation of the object
* `(f.name)`: gets the name of the function when it was created
* `(f.params)`: gets the parameters ot the function as a list of strings
* `(f.code)`: gets the code for the body expression

## int

Represents a 64-bit signed integer.

Methods:
* `(i.display)`: returns a string representation of the object
* `(i.succ)`
* `(i.pred)`
* `(i.neg)`
* `(i1.+ i2)`
* `(i1.- i2)`
* `(i1.* i2)`
* `(i1./ i2)`
* `(i1.% i2)`
* `(i1.= i2)`
* `(i1.!= i2)`
* `(i1.< i2)`
* `(i1.<= i2)`
* `(i1.> i2)`
* `(i1.& i2)`: bitwise AND
* `(i1.| i2)`: bitwise OR
* `(i1.^ i2)`: bitwise XOR
* `(i1.<< i2)`: arithmetic shift left
* `(i1.>>> i2)`: logical shift right
* `(i1.>> i2)`: arithmetic shift right

## list

Represents a growable list of objects. The internal structure of the object
(a Virgil Vector of objects) is mutable through its methods.

Methods:
* `(l.display)`: returns a string representation of the object
* `(l.=)`: element-wise equality on another list
* `(l.get i)`: gets the element of the list at index `i` where `i` is a int
  object. Raises exception if index is out of bounds.
* `(l.set i o)`: sets object `o` at index `i` (if in bounds)
* `(l.put o)`: puts object `o` at the end of the list
* `(l.length)`: gets the length of the list
* `(l.reverse)`: reverses the list in place

## map

Represents a map between strings and objects. Except there's no way to create
these.

Methods:
* `(p.display)`: returns a string representation of the object

## method

*extends `func`*

Represents a bound method, i.e. a function and a corresponding object.

Methods:
* `(m.display)`: returns a string representation of the object
* `(m.object)`: gets the object this method is bound to

## base

This is the base class for all objects.

Methods:
* `(o.display)`: returns a string representation for this object.
  User-defined classes should override this method for custom representations.
* `(o.fields)`: returns the list of fields (as strings) which are currently
  bound to the object (note the quirk about lazy binding of methods)
* `(o.getclass)`: gets the underlying class for this object. Note that even
  though this is defined only in the base class, it will return the lowest
  subclass.
* `(o.get-field)`: dynamic field lookup on an object, where the argument must
  be a string of the name of the field to look up
* `(o1.= o2)`: returns if `o2` is exactly the same object (compared through
  internal reference comparison). Note that some classes canonicalize their
  possible values, so that this form of equality is sufficient.
* `(o1.!= o2`): opposite of `o.=`

## poopcrap

Class of the unit value, PoopCrap.

## str

Represents a string.

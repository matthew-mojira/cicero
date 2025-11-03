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

## char

Represents a character

Methods:
* `(ch.display)`: returns a string representation of the object
* `(ch.+ o)`: returns a string that concatenates this char with another string/char
* `(ch.ascii)`: returns the ASCII numerical representation of a character

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
* `(co.disassemble)`: returns a string representation of a disassembly of the
  bytecode. Raises an exception if code hasn't been compiled to bytecode.

## double
Represents an signed double. 64 bit value.

Methods:

* `(d.display)`: returns a string representation of the double by performing round-to-nearest demotion to a float(32-bit)
* `(d.sqrt)`: returns the sqrt of the double value
* `(d.trunc)`: perform truncation and return an `int`
* `(d.sin)`: returns a `double` which is the sine value of angle `d` in radians.
* `(d.cos)`: returns a `double` which is the cosine value of angle `d` in radians.
* `(d.+ o)`
* `(d.- o)`
* `(d.* o)`
* `(d./ o)`
* `(d.= o)`
* `(d.!= o)`
* `(d.< o)`
* `(d.<= o)`
* `(d.> o)`
* `(d.>= o)`
All the above arithmetic operations(`+`, `-`, `*`, `/`) return a `double`. `o` can be either `double` or `int`. Raises exception if `int`(bigInteger) cannot be represented as a `double`.

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

Represents an signed integer.

Methods:
* `(i.display)`: returns a string representation of the object
* `(i.as s)`: converts int to its string representation
* `(i.succ)`
* `(i.pred)`
* `(i.neg)`
* `(i1.+ o)`
* `(i1.- o)`
* `(i1.* o)`
* `(i1./ i2)`
* `(i1.% i2)`
* `(i1.= o)`
* `(i1.!= o)`
* `(i1.< o)`
* `(i1.<= o)`
* `(i1.> o)`
* `(i1.& i2)`: bitwise AND
* `(i1.| i2)`: bitwise OR
* `(i1.^ i2)`: bitwise XOR
* `(i1.<< i2)`: shift left
* `(i1.>> i2)`: shift right
For the comparison operations: we can compare `int` with `int` or `double`
For the arithmetic operations: `int op int` -> `int` and `int op double` -> `double`

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

Represents a map between strings and objects.

Methods:
* `(p.display)`: returns a string representation of the object
* `(p.set s o)`: assigns key `s` to value `o`
* `(p.get s)`: retrieves the value assigned to key `s`, or raises exception if
  not bound
* `(p.delete s)`: delete the value associated with key `s`, or raises exception
  if not bound
* `(p.keys)`: gets list of keys in the map
* `(p.values)`: gets list of values in the map

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

Methods:
* `(u.display)`: returns a string representation for this object.

## str

Represents a string.

Methods:
* `(s.char-at i)`: returns a character object representing the character at
  index i of the string
* `(s.display)`: returns a string representation for this object.
* `(s.length)`: returns the length of the string which is the number of bytes
* `(s.chars)`: returns a list of char objects.
* `(s.substring startIndex endIndex)`: returns a substring in the range {startIndex} to {endIndex}. {endIndex} is exclusive.
* `(s.+ o)`: concatenates this string with another string/char



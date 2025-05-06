# A short note on built-in classes

Built-in classes use Virgil fields to store the underlying data (which may or
may not be a Cicero object). They never use Cicero fields (that is,
Object.fields) to store fields.

Methods are derived either from a Virgil method or from a Cicero method. Virgil
methods are defined in the Virgil class, while Cicero methods are defined in a
separate file (preferably something in the `lib` directory).

Caveats:
 * only the first declaration will be interpreted to mean the definition of
   the method
 * the method is defined as a lambda, where the first parameter is always
   `self`; other parameters may be added at the end and work as expected
   (implementation note: this forces the parser to parse those accesses as
    locals)
 * do not include comments in the definition until after the lambda definition
   is complete (implementation note: newlines are removed from the text file,
   and not comments)

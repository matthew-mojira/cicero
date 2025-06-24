# Bytecode instructions

The tier1 cicero interpreter uses bytecode.

## Bytecode

A `Bytecode` object consists of the following information:
* instructions: array of bytes which can be decoded as cicero bytecode
* locals: a list of strings corresponding to the names of each local (the list
  is ordered so that instructions which manipulate locals can be decoded)
* nonlocals: a list of strings corresponding to the names of variables whose
  values should be captured before executing the instructions (similarly 
  ordered as above)
* string pool: this is a name pool for items which are looked up by name even
  with bytecode (e.g. globals, fields)
* constant pool: a list of objects for constants (literals)
* class pool: these are functions corresponding to declared classes in a
  program. The function `ClassObject -> ClassObject` takes the superclass
  object and returns a finished class object.
* function pool: this is a list of functions (encoded at the AST-level), where
  all that needs to be done to make the function object is to capture the free 
  variables as nonlocals
* source map: this is a map of `pc << 2` to the `FileRange` corresponding to
  the original source for stacktraces and other debugging

## Instructions

Each instruction is 4 bytes: one byte for the opcode and three for the operand.
Unlike cpython's bytecode, there is no extension if longer operands are needed
(so hopefully 24 bits is enough).

| opcode | instruction        | operand                      | stack effect                               | exception                                               |
|--------|--------------------|------------------------------|--------------------------------------------|---------------------------------------------------------|
| 00     | NOP                | no operand                   | no effect                                  | none                                                    |
| 01     | LOAD_CONST         | index into constant pool     | +1 (constant value)                        | none                                                    |
| 02     | LOAD_GLOBAL        | index into string pool       | +1 (global value)                          | global unbound                                          |
| 03     | LOAD_LOCAL         | index into locals (rt)       | +1 (local value)                           | local uninitialized                                     |
| 04     | LOAD_FIELD         | index into string pool       | -1 (object) / +1 (field value)             | missing field                                           |
| 05     | LOAD_NONLOCAL      | index into nonlocals (rt)    | +1 (nonlocal value)                        | none                                                    |
| 06     | STORE_GLOBAL       | index into string pool       | -1 (global value)                          | none                                                    |
| 07     | STORE_LOCAL        | index into locals (rt)       | -1 (local value)                           | none                                                    |
| 08     | STORE_FIELD        | index into string pool       | -2 (field value, object)                   | missing field                                           |
| 09     | CALL               | number of arguments          | -n (arguments) / +1 (return value)         | arity mismatch, callee throws exception                 |
| 0A     | JUMP               | pc offset to target          | no effect                                  | none                                                    |
| 0B     | JUMP_IF_FALSE      | pc offset to target          | -1 (condition)                             | none                                                    |
| 0C     | JUMP_IF_TRUE_PEEK  | pc offset to target          | peek, -1 if top of stack is false          | none                                                    |
| 0D     | JUMP_IF_FALSE_PEEK | pc offset to target          | peek, -1 if top of stack is true           | none                                                    |
| 0E     | RAISE              | no operand                   | -1 (exception value)                       | yes, top of stack is not string                         |
| 0F     | TRY                | pc offset to catch           | no effect                                  | none                                                    |
| 10     | CATCH              | no operand                   | no effect                                  | none                                                    |
| 11     | ASSERT_FUNC        | no operand                   | peek, no effect                            | top of stack is not func                                |
| 12     | CREATE_OBJECT      | no operand                   | -1 (class) / +1 (object)                   | top of stack is not class, initializers throw exception |
| 13     | CREATE_CLASS       | index into class pool        | -1 (superclass object) / +1 (class object) | top of stack is not class                               |
| 14     | CREATE_LIST        | number of elements           | -n (elements)                              | none                                                    |
| 15     | CREATE_FUNC        | index into func pool         | -n (nonlocals)                             | none                                                    |
| 16     | POP                | number of values to pull     | -n (pulled values)                         | none                                                    |
| 17     | DUPE               | stack index of duped value   | peek n, +1 (duped value)                   | none                                                    |
| 18     | SWAP               | stack index of swapped value | peek n, swaps (no net)                     | none                                                    |


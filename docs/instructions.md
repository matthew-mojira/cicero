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

| opcode | instruction        |
|--------|--------------------|
| 00     | NOP                |
| 01     | LOAD_CONST         |
| 02     | LOAD_GLOBAL        |
| 03     | LOAD_LOCAL         |
| 04     | LOAD_FIELD         |
| 05     | LOAD_NONLOCAL      |
| 06     | STORE_GLOBAL       |
| 07     | STORE_LOCAL        |
| 08     | STORE_FIELD        |
| 09     | CALL               |
| 0A     | JUMP               |
| 0B     | JUMP_IF_FALSE      |
| 0C     | JUMP_IF_TRUE_PEEK  |
| 0D     | JUMP_IF_FALSE_PEEK |
| 0E     | RAISE              |
| 0F     | TRY                |
| 10     | CATCH              |
| 11     | ASSERT_FUNC        |
| 12     | CREATE_OBJECT      |
| 13     | CREATE_CLASS       |
| 14     | CREATE_LIST        |
| 15     | CREATE_FUNC        |
| 16     | POP                |
| 17     | DUPE               |
| 18     | SWAP               |

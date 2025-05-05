if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" cicero indenting is similar to lisp
setlocal lisp

let b:undo_indent = "setl cin<"

if exists("b:current_syntax")
    finish
endif

syn keyword ciceroKeyword raise try func lambda set cond while begin get-field set-field get-global set-global class field method init extends new and or
syn keyword ciceroConditional if cond

" adapted from neovim runtime/syntax
syn keyword ciceroTodo contained TODO FIXME XXX NOTE
syn match   ciceroComment ";.*$" contains=ciceroTodo,@Spell

syn region ciceroString           start=+"+ end=+"+ end=+$+ contains=@Spell

syn match ciceroNumber "\<\(\d\(\d\|_\d\)*\)\=\>"

hi def link ciceroKeyword               Keyword
hi def link ciceroInclude               Include
hi def link ciceroLabel                 Label
hi def link ciceroConditional           Conditional
hi def link ciceroRepeat                Repeat
hi def link ciceroStatement             Statement
hi def link ciceroType                  Type
hi def link ciceroNumber                Number
hi def link ciceroComment               Comment
hi def link ciceroOperator              Operator
hi def link ciceroCharacter             Character
hi def link ciceroString                String
hi def link ciceroTodo                  Todo
hi def link ciceroSpecial               Special
hi def link ciceroSpecialError          Error
hi def link ciceroSpecialCharError      Error
hi def link ciceroString                String
hi def link ciceroCharacter             Character
hi def link ciceroSpecialChar           SpecialChar

let b:current_syntax = "cicero"

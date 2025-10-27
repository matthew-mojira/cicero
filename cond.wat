(module
  (func (param i32) (result i32 i32)
    local.get 0
    local.get 0)

  (func (result i32)
    block (result i32)
      block (result i32)
        i32.const 1
	call 0
	br_if 0
	i32.const 2
	br 1
      end
      block (result i32)
        i32.const 1
	call 0
	br_if 0
	i32.const 2
	br 1
      end
      unreachable
    end
  )
)

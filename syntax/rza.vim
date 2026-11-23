if exists("b:current_syntax")
  finish
endif

syn match rzaKeyword "\v<(cav|res|med|view|raise|decay|probe|load|loadb|store|storeb)(\.)@!>"
syn match rzaKeyword "\v<(mov|slt|inc|dec|await|print)(\.)@!>"
syn match rzaKeyword "\v<(jmp|brz|brnz|call|proc|casc|acasc|endc|ret|layout)(\.)@!>"
syn match rzaKeyword "\v<(add|sub|mul|div|mod|and|or|xor|shl|shr|ushr)(\.)@!>"
syn match rzaKeyword "\v<(cadd|csub|cmul|cinc|cdec|crc32c)(\.)@!>"
syn match rzaScalarType "\v(^|[^A-Za-z0-9_.])\zs(u8|i8|u16|i16|u32|i32|i64|u64|f32|f64)>"
syn match rzaKeyword "\v<(mov|load|store|add|sub|mul|inc|dec|cadd|csub|cmul|cinc|cdec|and|or|xor|div|mod|shl|ushr)\.(i8|u8|i16|u16|i32|u32|i64|u64)>"
syn match rzaKeyword "\v<(shr|slt)\.(i8|i16|i32|i64)>"
syn match rzaKeyword "\v<ult\.(u8|u16|u32|u64)>"
syn match rzaKeyword "\v<(mov|load|store|add|sub|mul|div|feq|fne|flt|fle|fgt|fge)\.(f32|f64)>"
syn match rzaKeyword "\v<cvt\.(f32\.(f64|i8|u8|i16|u16|i32|u32|i64|u64)|f64\.(f32|i8|u8|i16|u16|i32|u32|i64|u64)|(i8|u8|i16|u16|i32|u32|i64|u64)\.(f32|f64))>"
syn match rzaKeyword "\v<bitcast\.(f32\.(i32|u32)|f64\.(i64|u64)|(i32|u32)\.f32|(i64|u64)\.f64)>"
syn match rzaLayout "\v<[A-Z][A-Za-z0-9_]*>"
syn keyword rzaConstant field
syn match rzaRegister "\v[%%]r([0-9]|1[0-5])>"
syn match rzaField "\]\.\zs[a-z_][a-z0-9_]*"
syn match rzaLabel "\(proc\s\+\)\@<=[a-z_][a-z0-9_]*"
syn match rzaLabel "^\s*\zs[a-z_][a-z0-9_]*\ze:"
syn match rzaNumber "\v(^|[^A-Za-z0-9_])\zs-?\d+>"
syn match rzaNumber "\v(^|[^A-Za-z0-9_])\zs-?0x[0-9A-Fa-f]+>"
syn region rzaComment start=";" end="$"

hi def link rzaKeyword Keyword
hi def link rzaScalarType Special
hi def link rzaLayout Type
hi def link rzaConstant Constant
hi def link rzaRegister Identifier
hi def link rzaField Special
hi def link rzaLabel Function
hi def link rzaNumber Number
hi def link rzaComment Comment

let b:current_syntax = "rza"

;===============================================================================
; Simple Struct - Complete Working Example
; A minimal struct implementation for learning
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

SimpleStructExample()

class SimpleStruct {
    __New(definition) {
        ; Type sizes
        this.types := Map(
            "Int", 4,
            "UInt", 4,
            "Short", 2,
            "Char", 1,
            "Double", 8,
            "Ptr", A_PtrSize
        )

        ; Parse members
        this.members := Map()
        offset := 0

        for line in StrSplit(definition, "`n") {
            if RegExMatch(Trim(line), '(\w+)\s+(\w+)', &m) {
                type := m[1]
                name := m[2]

                if !this.types.Has(type)
                    throw ValueError("Unknown type: " type)

                this.members[name] := {type: type, offset: offset}
                offset += this.types[type]
            }
        }

        ; Create buffer
        this.buffer := Buffer(offset, 0)

        ; Create properties for each member
        for name, info in this.members {
            this.DefineProp(name, {
                get: ((buf, off, t, this) => NumGet(buf, off, t)).Bind(this.buffer, info.offset, info.type),
                set: ((buf, off, t, this, val) => NumPut(t, val, buf, off)).Bind(this.buffer, info.offset, info.type)
            })
        }
    }

    Size => this.buffer.Size
    Ptr => this.buffer.Ptr

    ToString() {
        s := "Struct Contents:`n"
        for name, info in this.members
            s .= "  " name " (" info.type "): " this.%name% "`n"
        return s
    }
}

SimpleStructExample() {
    ; Define a simple struct
    person := SimpleStruct("
    (
        Int age
        UInt id
        Double salary
    )")

    ; Set values
    person.age := 30
    person.id := 12345
    person.salary := 75000.50

    ; Read values
    result := person.ToString()
    result .= "`nBuffer Info:`n"
    result .= "  Size: " person.Size " bytes`n"
    result .= "  Address: 0x" Format("{:X}", person.Ptr)

    MsgBox(
        "=== Simple Struct Demo ===`n`n"
        result "`n`n"
        "Concepts:`n"
        "• Struct wraps a Buffer`n"
        "• Properties map to buffer locations`n"
        "• Get/Set automatically handle NumGet/NumPut`n"
        "• Struct manages memory layout",
        "Simple Struct"
    )
}

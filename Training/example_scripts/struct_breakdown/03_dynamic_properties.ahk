;===============================================================================
; Dynamic Properties with Bound Parameters
; Demonstrates using Bind() to create closures for property getters/setters
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

DynamicPropertiesExample()

DynamicPropertiesExample() {
    ; Create object with buffer
    obj := {}
    obj.buffer := Buffer(16, 0)

    ; Define property with bound parameters (offset and type)
    ; This is how struct.ahk creates properties dynamically
    offset := 0
    type := "UInt"

    obj.DefineProp("value1", {
        get: ((buf, off, t, this) => NumGet(buf, off, t)).Bind(obj.buffer, offset, type),
        set: ((buf, off, t, this, value) => NumPut(t, value, buf, off)).Bind(obj.buffer, offset, type)
    })

    ; Another property at different offset
    offset2 := 4
    type2 := "Double"

    obj.DefineProp("value2", {
        get: ((buf, off, t, this) => NumGet(buf, off, t)).Bind(obj.buffer, offset2, type2),
        set: ((buf, off, t, this, value) => NumPut(t, value, buf, off)).Bind(obj.buffer, offset2, type2)
    })

    ; Use the properties
    obj.value1 := 100
    obj.value2 := 2.71828

    MsgBox(
        "=== Dynamic Properties Demo ===`n`n"
        "Value1 (UInt at offset 0): " obj.value1 "`n"
        "Value2 (Double at offset 4): " obj.value2 "`n`n"
        "Concepts:`n"
        "• Bind() creates closure with preset parameters`n"
        "• Getters/setters can access bound data`n"
        "• Properties can directly read/write buffer`n"
        "• This pattern allows dynamic property creation",
        "Dynamic Properties"
    )
}

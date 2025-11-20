;===============================================================================
; Property Descriptors - DefineProp() Basics
; Demonstrates how to create dynamic properties using DefineProp
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

PropertyDescriptorExample()

PropertyDescriptorExample() {
    obj := {}

    ; Example 1: Simple property with backing field
    obj.DefineProp("name", {
        get: (this) => this._name ?? "Unknown",
        set: (this, value) => this._name := value
    })

    ; Example 2: Computed property (read-only)
    obj._width := 10
    obj._height := 5
    obj.DefineProp("area", {
        get: (this) => this._width * this._height
    })

    ; Example 3: Validated property
    obj.DefineProp("age", {
        get: (this) => this._age ?? 0,
        set: (this, value) {
            if (value < 0 || value > 150)
                throw ValueError("Age must be between 0-150")
            this._age := value
        }
    })

    ; Example 4: Property with Value (constant)
    obj.DefineProp("version", {Value: "1.0.0"})

    ; Test the properties
    obj.name := "John Doe"
    obj.age := 25

    MsgBox(
        "=== Property Descriptors Demo ===`n`n"
        "Name: " obj.name "`n"
        "Area (10x5): " obj.area "`n"
        "Age: " obj.age "`n"
        "Version: " obj.version "`n`n"
        "Concepts:`n"
        "• DefineProp() creates dynamic properties`n"
        "• get: defines getter function`n"
        "• set: defines setter function`n"
        "• Value: creates read-only constant",
        "Property Descriptors"
    )
}

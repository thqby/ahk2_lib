;===============================================================================
; Nested Structures
; Parse and stringify complex nested JSON
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

NestedStructuresExample()

NestedStructuresExample() {
    ; Create nested structure
    company := Map()
    company["name"] := "Tech Corp"
    company["founded"] := 2010

    ; Nested array of objects
    employees := []

    emp1 := Map()
    emp1["name"] := "John"
    emp1["role"] := "Developer"
    emp1["skills"] := ["JavaScript", "Python", "AHK"]
    employees.Push(emp1)

    emp2 := Map()
    emp2["name"] := "Sarah"
    emp2["role"] := "Designer"
    emp2["skills"] := ["Photoshop", "Figma"]
    employees.Push(emp2)

    company["employees"] := employees

    ; Convert to JSON
    jsonString := JSON.stringify(company)

    result := "=== Nested Structure to JSON ===`n"
    result .= jsonString "`n`n"

    ; Parse it back
    parsed := JSON.parse(jsonString)

    result .= "=== Parsed Back ===`n"
    result .= "Company: " parsed["name"] "`n"
    result .= "Employees:`n"

    for emp in parsed["employees"] {
        result .= "  • " emp["name"] " (" emp["role"] ")`n"
        result .= "    Skills: " JSON.stringify(emp["skills"]) "`n"
    }

    MsgBox(
        result "`n"
        "Concepts:`n"
        "• Objects can contain arrays`n"
        "• Arrays can contain objects`n"
        "• Unlimited nesting depth`n"
        "• Parse → Modify → Stringify workflow`n"
        "• Structure is preserved",
        "Nested Structures"
    )
}

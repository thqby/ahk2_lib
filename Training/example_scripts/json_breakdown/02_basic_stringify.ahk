;===============================================================================
; Basic JSON Stringify
; Convert AHK objects to JSON strings
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

BasicJSONStringifyExample()

BasicJSONStringifyExample() {
    ; Example 1: Object to JSON
    person := Map()
    person["name"] := "Alice"
    person["age"] := 25
    person["active"] := true

    json1 := JSON.stringify(person)
    result := "=== Object to JSON ===`n"
    result .= json1 "`n`n"

    ; Example 2: Array to JSON
    colors := ["red", "green", "blue"]
    json2 := JSON.stringify(colors)
    result .= "=== Array to JSON ===`n"
    result .= json2 "`n`n"

    ; Example 3: Mixed types
    data := Map()
    data["text"] := "Hello"
    data["number"] := 100
    data["float"] := 99.99
    data["items"] := ["a", "b", "c"]

    json3 := JSON.stringify(data)
    result .= "=== Mixed Types ===`n"
    result .= json3 "`n"

    MsgBox(
        result "`n`n"
        "Concepts:`n"
        "• JSON.stringify() converts objects to JSON`n"
        "• Map becomes {} object`n"
        "• Array becomes [] array`n"
        "• Nested structures supported`n"
        "• Result is valid JSON string",
        "Basic JSON Stringify"
    )
}

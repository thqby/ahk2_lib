;===============================================================================
; Basic JSON Parsing
; Parse simple JSON strings into AHK objects
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

BasicJSONParsingExample()

BasicJSONParsingExample() {
    ; Example 1: Parse simple object
    jsonString1 := '{"name": "John", "age": 30, "city": "New York"}'
    obj1 := JSON.parse(jsonString1)

    result := "=== Simple Object ===`n"
    result .= "Name: " obj1["name"] "`n"
    result .= "Age: " obj1["age"] "`n"
    result .= "City: " obj1["city"] "`n`n"

    ; Example 2: Parse simple array
    jsonString2 := '["apple", "banana", "cherry"]'
    arr := JSON.parse(jsonString2)

    result .= "=== Simple Array ===`n"
    for index, fruit in arr
        result .= index ": " fruit "`n"
    result .= "`n"

    ; Example 3: Parse mixed types
    jsonString3 := '{"text": "Hello", "number": 42, "decimal": 3.14}'
    obj2 := JSON.parse(jsonString3)

    result .= "=== Mixed Types ===`n"
    result .= "Text: " obj2["text"] " (Type: " Type(obj2["text"]) ")`n"
    result .= "Number: " obj2["number"] " (Type: " Type(obj2["number"]) ")`n"
    result .= "Decimal: " obj2["decimal"] " (Type: " Type(obj2["decimal"]) ")`n"

    MsgBox(
        result "`n"
        "Concepts:`n"
        "• JSON.parse() converts JSON to AHK objects`n"
        "• {} becomes Map (by default)`n"
        "• [] becomes Array`n"
        "• Types are preserved (String, Integer, Float)`n"
        "• Access via obj['key'] syntax",
        "Basic JSON Parsing"
    )
}

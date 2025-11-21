;===============================================================================
; Error Handling
; Handle malformed JSON and parse errors
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

ErrorHandlingExample()

ErrorHandlingExample() {
    result := ""

    ; Test 1: Missing closing brace
    result .= "=== Test 1: Missing Closing Brace ===`n"
    badJSON1 := '{"name": "John", "age": 30'

    try {
        JSON.parse(badJSON1)
        result .= "Parsed successfully (unexpected!)`n"
    } catch Error as e {
        result .= "Error caught: " e.Message "`n"
    }

    result .= "`n"

    ; Test 2: Invalid character
    result .= "=== Test 2: Invalid Starting Character ===`n"
    badJSON2 := 'not valid json'

    try {
        JSON.parse(badJSON2)
        result .= "Parsed successfully (unexpected!)`n"
    } catch Error as e {
        result .= "Error caught: " e.Message "`n"
    }

    result .= "`n"

    ; Test 3: Missing key
    result .= "=== Test 3: Missing Key ===`n"
    badJSON3 := '{: "value"}'

    try {
        JSON.parse(badJSON3)
        result .= "Parsed successfully (unexpected!)`n"
    } catch Error as e {
        result .= "Error caught: " e.Message "`n"
    }

    result .= "`n"

    ; Test 4: Valid JSON
    result .= "=== Test 4: Valid JSON ===`n"
    goodJSON := '{"name": "John", "age": 30}'

    try {
        obj := JSON.parse(goodJSON)
        result .= "Parsed successfully!`n"
        result .= "Name: " obj["name"] "`n"
    } catch Error as e {
        result .= "Error: " e.Message "`n"
    }

    MsgBox(
        result "`n"
        "Best Practices:`n"
        "• Always wrap JSON.parse() in try/catch`n"
        "• Check JSON validity before parsing`n"
        "• Error messages indicate the problem`n"
        "• Handle parse failures gracefully`n"
        "• Validate data from external sources",
        "Error Handling"
    )
}

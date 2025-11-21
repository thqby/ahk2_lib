;===============================================================================
; Boolean and Null Types
; Handle true, false, and null values
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

BooleanNullExample()

BooleanNullExample() {
    ; JSON with boolean and null values
    jsonString := '{
        "active": true,
        "verified": false,
        "middleName": null,
        "age": 30
    }'

    ; Parse with keepbooltype = false (default)
    obj1 := JSON.parse(jsonString, false)

    result := "=== Default Mode (keepbooltype=false) ===`n"
    result .= "active: " obj1["active"] " (Type: " Type(obj1["active"]) ")`n"
    result .= "verified: " obj1["verified"] " (Type: " Type(obj1["verified"]) ")`n"
    result .= "middleName: '" obj1["middleName"] "' (Type: " Type(obj1["middleName"]) ")`n`n"

    ; Parse with keepbooltype = true
    obj2 := JSON.parse(jsonString, true)

    result .= "=== Keep Bool Type Mode (keepbooltype=true) ===`n"
    result .= "active: " (obj2["active"] == JSON.true ? "JSON.true" : "?") "`n"
    result .= "verified: " (obj2["verified"] == JSON.false ? "JSON.false" : "?") "`n"
    result .= "middleName: " (obj2["middleName"] == JSON.null ? "JSON.null" : "?") "`n`n"

    ; Stringify with boolean values
    data := Map()
    data["isAdmin"] := JSON.true
    data["isGuest"] := JSON.false
    data["nickname"] := JSON.null

    jsonOut := JSON.stringify(data)

    result .= "=== Stringify with JSON types ===`n"
    result .= jsonOut

    MsgBox(
        result "`n`n"
        "Concepts:`n"
        "• true → 1 or JSON.true`n"
        "• false → 0 or JSON.false`n"
        "• null → '' or JSON.null`n"
        "• keepbooltype preserves exact types`n"
        "• Use JSON.true/false/null for output",
        "Boolean & Null"
    )
}

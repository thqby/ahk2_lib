;===============================================================================
; Escape Characters
; Handle special characters and escape sequences
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

EscapeCharactersExample()

EscapeCharactersExample() {
    ; Create strings with special characters
    data := Map()
    data["quote"] := 'He said "Hello"'
    data["backslash"] := "C:\Program Files\MyApp"
    data["tab"] := "Name`tValue"
    data["newline"] := "Line 1`nLine 2"
    data["unicode"] := "© 2024 • Résumé"

    ; Convert to JSON (escapes automatically)
    jsonString := JSON.stringify(data)

    result := "=== Original Data ===`n"
    for key, value in data
        result .= key ": " StrReplace(value, "`n", "↵") "`n"

    result .= "`n=== Escaped JSON ===`n"
    result .= jsonString "`n`n"

    ; Parse back (unescapes automatically)
    parsed := JSON.parse(jsonString)

    result .= "=== Parsed Back ===`n"
    result .= "Quote: " parsed["quote"] "`n"
    result .= "Backslash: " parsed["backslash"] "`n"
    result .= "Tab contains tab: " InStr(parsed["tab"], "`t") "`n"
    result .= "Newline contains newline: " InStr(parsed["newline"], "`n") "`n`n"

    ; Manual JSON with escapes
    manualJSON := '{"test": "Line1\\nLine2\\tTabbed"}'
    manual := JSON.parse(manualJSON)

    result .= "=== Manual Escape Sequences ===`n"
    result .= "Input: " manualJSON "`n"
    result .= "Parsed: " StrReplace(manual["test"], "`n", "↵") "`n"

    MsgBox(
        result "`n"
        "Escape Sequences:`n"
        '• \n → newline`n'
        '• \t → tab`n'
        '• \\ → backslash`n'
        '• \" → quote`n'
        '• \uXXXX → unicode`n'
        "• Automatic escaping/unescaping",
        "Escape Characters"
    )
}

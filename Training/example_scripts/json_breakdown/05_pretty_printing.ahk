;===============================================================================
; Pretty Printing
; Format JSON with indentation for readability
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

PrettyPrintingExample()

PrettyPrintingExample() {
    ; Create complex object
    config := Map()
    config["appName"] := "MyApp"
    config["version"] := "1.0.0"

    database := Map()
    database["host"] := "localhost"
    database["port"] := 5432
    database["credentials"] := Map("user", "admin", "password", "secret")

    config["database"] := database
    config["features"] := ["logging", "caching", "monitoring"]

    ; Compact JSON (default)
    compact := JSON.stringify(config, 0)  ; expandlevel = 0

    result := "=== Compact (expandlevel=0) ===`n"
    result .= compact "`n`n"

    ; Pretty printed (default 2-space indent)
    pretty := JSON.stringify(config)  ; expandlevel = unset (all)

    result .= "=== Pretty Printed (default) ===`n"
    result .= pretty "`n`n"

    ; Custom indentation (4 spaces)
    pretty4 := JSON.stringify(config, unset, "    ")

    result .= "=== 4-Space Indent ===`n"
    result .= pretty4

    MsgBox(
        result "`n`n"
        "Concepts:`n"
        "• expandlevel controls nesting display`n"
        "• expandlevel=0 creates compact JSON`n"
        "• expandlevel=unset expands all levels`n"
        "• space parameter sets indent (default '  ')`n"
        "• Pretty printing aids readability",
        "Pretty Printing"
    )
}

;===============================================================================
; Map vs Object Mode
; Choose between Map or Object for parsed JSON objects
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

MapVsObjectExample()

MapVsObjectExample() {
    jsonString := '{"name": "Test", "value": 42}'

    ; Parse as Map (default, as_map = true)
    asMap := JSON.parse(jsonString, false, true)

    result := "=== Parsed as Map ===`n"
    result .= "Type: " Type(asMap) "`n"
    result .= "Access: asMap['name'] = " asMap["name"] "`n"
    result .= "Has 'name': " asMap.Has("name") "`n"
    result .= "Count: " asMap.Count "`n`n"

    ; Parse as Object (as_map = false)
    asObj := JSON.parse(jsonString, false, false)

    result .= "=== Parsed as Object ===`n"
    result .= "Type: " Type(asObj) "`n"
    result .= "Access: asObj.name = " asObj.name "`n"
    result .= "Has 'name': " asObj.HasOwnProp("name") "`n`n"

    ; Show differences
    result .= "=== Key Differences ===`n"
    result .= "Map:`n"
    result .= "  • Access: obj['key']`n"
    result .= "  • Methods: .Has(), .Count, .Set(), .Get()`n"
    result .= "  • Iterate: for key, value in map`n`n"

    result .= "Object:`n"
    result .= "  • Access: obj.key or obj.%key%`n"
    result .= "  • Methods: .HasOwnProp(), ObjOwnPropCount()`n"
    result .= "  • Iterate: for key, value in obj.OwnProps()`n`n"

    result .= "Recommendation: Use Map (default) for JSON data"

    MsgBox(
        result,
        "Map vs Object"
    )
}

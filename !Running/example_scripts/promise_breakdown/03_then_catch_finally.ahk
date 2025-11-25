;===============================================================================
; Then, Catch, and Finally
; Demonstrates promise chaining and cleanup
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

ThenCatchFinallyExample()

ThenCatchFinallyExample() {
    result := ""

    ; Example 1: Success chain with finally
    result .= "=== Success Path ===`n"

    Promise.resolve(10)
        .then((value) => (result .= "Step 1: " value "`n", value * 2))
        .then((value) => (result .= "Step 2: " value "`n", value + 5))
        .then((value) => (result .= "Step 3: " value "`n", value))
        .finally(() => result .= "Cleanup executed`n")

    Sleep(100)

    ; Example 2: Error path with catch
    result .= "`n=== Error Path ===`n"

    Promise.resolve(10)
        .then((value) => {
            result .= "Before error: " value "`n"
            throw Error("Something went wrong!")
        })
        .then((value) => result .= "This won't run`n")
        .catch((err) => result .= "Caught error: " err.Message "`n")
        .finally(() => result .= "Cleanup still executes`n")

    Sleep(100)

    ; Example 3: Chaining return values
    result .= "`n=== Chaining ===`n"

    Promise.resolve("Hello")
        .then((val) => val " World")
        .then((val) => StrUpper(val))
        .then((val) => result .= "Final: " val "`n")

    Sleep(100)

    MsgBox(
        result "`n`n"
        "Concepts:`n"
        "• then() chains operations`n"
        "• Return value becomes next promise's value`n"
        "• catch() handles errors in chain`n"
        "• finally() runs regardless of outcome`n"
        "• Errors skip to next catch()",
        "Then/Catch/Finally"
    )
}

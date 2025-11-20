;===============================================================================
; Promise.any()
; Returns first fulfilled promise, or rejects if all fail
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PromiseAnyExample()

PromiseAnyExample() {
    result := ""

    ; Example 1: Mixed success/failure - first success wins
    result .= "=== Example 1: First Success ===`n"

    promises1 := [
        Promise.reject("Server 1 failed"),
        Promise((resolve) => SetTimer(() => resolve("Server 2 OK"), -300)),
        Promise((resolve) => SetTimer(() => resolve("Server 3 OK"), -500))
    ]

    Promise.any(promises1).then((value) => {
        result .= "First successful: " value "`n"
        result .= "(Even though Server 1 rejected)`n`n"
    })

    Sleep(600)

    ; Example 2: All failures
    result .= "=== Example 2: All Failed ===`n"

    promises2 := [
        Promise.reject("Error 1"),
        Promise.reject("Error 2"),
        Promise.reject("Error 3")
    ]

    Promise.any(promises2).catch((err) => {
        result .= "All promises rejected!`n"
        result .= "Error message: " err.Message "`n"
        result .= "Errors array available: " (err.HasOwnProp('errors') ? "Yes" : "No") "`n"
    })

    Sleep(100)

    MsgBox(
        result "`n"
        "Concepts:`n"
        "• any() returns first FULFILLED promise`n"
        "• Ignores rejections if any succeeds`n"
        "• Rejects only if ALL promises reject`n"
        "• Useful for trying multiple sources`n"
        "• Good for failover scenarios",
        "Promise.any()"
    )
}

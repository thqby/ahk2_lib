;===============================================================================
; Promise.allSettled()
; Wait for all promises regardless of success or failure
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PromiseAllSettledExample()

PromiseAllSettledExample() {
    result := ""

    ; Create mix of successful and failing promises
    promises := [
        Promise.resolve("Success 1"),
        Promise.reject("Error 1"),
        Promise.resolve("Success 2"),
        Promise.reject("Error 2")
    ]

    ; Wait for all to settle (complete)
    allSettled := Promise.allSettled(promises)

    allSettled.then((results) => {
        result .= "All promises settled!`n`n"

        for i, item in results {
            result .= "[" i "] Status: " item.status "`n"
            result .= "    Result: " item.result "`n`n"
        }

        result .= "Key difference from Promise.all():`n"
        result .= "• all() rejects if ANY promise fails`n"
        result .= "• allSettled() waits for ALL,`n"
        result .= "  regardless of success/failure"

        MsgBox(
            "=== Promise.allSettled() Demo ===`n`n"
            result,
            "Promise.allSettled()"
        )
    })

    Sleep(100)
}

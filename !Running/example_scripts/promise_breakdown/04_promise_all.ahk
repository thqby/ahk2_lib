;===============================================================================
; Promise.all()
; Wait for multiple promises to complete
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PromiseAllExample()

PromiseAllExample() {
    result := ""

    ; Create multiple promises with different delays
    promise1 := Promise((resolve) => SetTimer(() => resolve("Task 1 done"), -500))
    promise2 := Promise((resolve) => SetTimer(() => resolve("Task 2 done"), -300))
    promise3 := Promise((resolve) => SetTimer(() => resolve("Task 3 done"), -700))

    ; Wait for all to complete
    allPromise := Promise.all([promise1, promise2, promise3])

    result .= "Waiting for all promises...`n`n"

    allPromise.then((results) => {
        result .= "All promises completed!`n`n"
        result .= "Results array:`n"
        for i, value in results
            result .= "  [" i "]: " value "`n"

        MsgBox(
            result "`n`n"
            "Concepts:`n"
            "• Promise.all() waits for all promises`n"
            "• Returns array of results in order`n"
            "• If ANY promise rejects, all() rejects`n"
            "• Useful for parallel async operations",
            "Promise.all()"
        )
    })

    ; Keep script alive
    Sleep(1000)
}

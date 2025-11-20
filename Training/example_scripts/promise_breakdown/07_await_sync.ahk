;===============================================================================
; Await - Synchronous Waiting
; Wait for promise to complete synchronously
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

AwaitSyncExample()

AwaitSyncExample() {
    result := ""

    ; Create promise that resolves after delay
    slowPromise := Promise((resolve) => {
        SetTimer(() => resolve("Data loaded!"), -1000)
    })

    result .= "Before await...`n"
    result .= "Promise status: " slowPromise.status "`n`n"

    ; Wait synchronously for promise to complete
    result .= "Calling await()...`n"

    try {
        value := slowPromise.await()  ; Blocks until complete
        result .= "After await!`n"
        result .= "Result: " value "`n`n"
    } catch Error as err {
        result .= "Error: " err.Message "`n`n"
    }

    ; Example with timeout
    neverResolves := Promise((resolve) => {
        ; Never calls resolve
    })

    result .= "Testing timeout...`n"
    try {
        neverResolves.await(500)  ; Wait max 500ms
        result .= "Completed`n"
    } catch TimeoutError {
        result .= "Timed out after 500ms!`n"
    }

    MsgBox(
        "=== Await Demo ===`n`n"
        result "`n"
        "Concepts:`n"
        "• await() blocks until promise completes`n"
        "• Returns result if fulfilled`n"
        "• Throws error if rejected`n"
        "• Optional timeout parameter`n"
        "• Useful for converting async to sync",
        "Await"
    )
}

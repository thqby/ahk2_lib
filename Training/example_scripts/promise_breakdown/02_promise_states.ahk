;===============================================================================
; Promise States
; Demonstrates pending, fulfilled, and rejected states
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PromiseStatesExample()

PromiseStatesExample() {
    ; Create promise that stays pending
    pendingPromise := Promise((resolve, reject) => {
        ; Intentionally do nothing - stays pending
    })

    ; Create fulfilled promise
    fulfilledPromise := Promise.resolve("I am fulfilled!")

    ; Create rejected promise
    rejectedPromise := Promise.reject("I was rejected")

    ; Check states
    result := "Promise States:`n`n"

    result .= "Pending Promise:`n"
    result .= "  Status: " pendingPromise.status "`n"
    result .= "  Has result: " ObjHasOwnProp(pendingPromise, 'result') "`n`n"

    result .= "Fulfilled Promise:`n"
    result .= "  Status: " fulfilledPromise.status "`n"
    result .= "  Result: " fulfilledPromise.result "`n`n"

    result .= "Rejected Promise:`n"
    result .= "  Status: " rejectedPromise.status "`n"
    result .= "  Result: " rejectedPromise.result "`n`n"

    result .= "State Transitions:`n"
    result .= "  pending → fulfilled (via resolve())`n"
    result .= "  pending → rejected (via reject())`n"
    result .= "  Once settled, state cannot change"

    MsgBox(
        "=== Promise States Demo ===`n`n"
        result,
        "Promise States"
    )
}

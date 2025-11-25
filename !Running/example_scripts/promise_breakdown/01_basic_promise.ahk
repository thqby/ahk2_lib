;===============================================================================
; Basic Promise Creation
; Demonstrates creating and using a simple promise
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

BasicPromiseExample()

BasicPromiseExample() {
    result := ""

    ; Example 1: Simple fulfilled promise
    promise1 := Promise((resolve, reject) => resolve("Success!"))

    promise1.then((value) => result .= "Promise 1: " value "`n")

    ; Example 2: Simple rejected promise
    promise2 := Promise((resolve, reject) => reject("Something went wrong"))

    promise2.catch((error) => result .= "Promise 2 Error: " error "`n")

    ; Example 3: Promise with delayed resolution using SetTimer
    promise3 := Promise((resolve, reject) => {
        SetTimer(() => resolve("Delayed result"), -1000)
    })

    ; Wait for promises to complete
    Sleep(1500)

    promise3.then((value) => result .= "Promise 3: " value "`n")

    Sleep(100)

    MsgBox(
        "=== Basic Promise Demo ===`n`n"
        result "`n"
        "Concepts:`n"
        "• Promise(executor) creates new promise`n"
        "• executor gets resolve and reject functions`n"
        "• Call resolve(value) for success`n"
        "• Call reject(reason) for failure`n"
        "• then() handles successful resolution`n"
        "• catch() handles rejection",
        "Basic Promise"
    )
}

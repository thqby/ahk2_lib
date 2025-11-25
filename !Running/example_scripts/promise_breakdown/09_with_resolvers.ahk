;===============================================================================
; Promise.withResolvers()
; Create promise with external resolve/reject control
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

WithResolversExample()

WithResolversExample() {
    result := ""

    ; Create promise with resolvers accessible outside
    deferred := Promise.withResolvers()

    ; Promise is created but pending
    result .= "Promise created: " deferred.promise.status "`n"

    ; Set up what happens when resolved
    deferred.promise.then((value) => {
        result .= "Promise resolved with: " value "`n"

        MsgBox(
            "=== WithResolvers Demo ===`n`n"
            result "`n`n"
            "Concepts:`n"
            "• withResolvers() creates promise + controls`n"
            "• Returns {promise, resolve, reject}`n"
            "• resolve/reject can be called later`n"
            "• Useful for manual promise control`n"
            "• Good for wrapping callbacks",
            "WithResolvers"
        )
    })

    ; Resolve it externally (after 500ms)
    SetTimer(() => deferred.resolve("Resolved from outside!"), -500)

    Sleep(1000)
}

;===============================================================================
; Promise.race()
; Returns first promise to settle (fulfill or reject)
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PromiseRaceExample()

PromiseRaceExample() {
    result := ""

    ; Create promises with different delays
    slow := Promise((resolve) => SetTimer(() => resolve("Slow (1000ms)"), -1000))
    medium := Promise((resolve) => SetTimer(() => resolve("Medium (500ms)"), -500))
    fast := Promise((resolve) => SetTimer(() => resolve("Fast (200ms)"), -200))

    ; Race them - first to complete wins
    race := Promise.race([slow, medium, fast])

    race.then((winner) => {
        result .= "Winner: " winner "`n`n"
        result .= "The fastest promise completed first.`n"
        result .= "Other promises still complete,`n"
        result .= "but their results are ignored."

        MsgBox(
            "=== Promise.race() Demo ===`n`n"
            result "`n`n"
            "Concepts:`n"
            "• race() returns first settled promise`n"
            "• Can be fulfilled or rejected`n"
            "• Useful for timeouts`n"
            "• Other promises continue running",
            "Promise.race()"
        )
    })

    Sleep(1500)
}

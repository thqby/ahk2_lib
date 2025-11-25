;===============================================================================
; Array Manipulation
; Work with JSON arrays - iterate, filter, transform
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

ArrayManipulationExample()

ArrayManipulationExample() {
    ; Parse JSON array of objects
    jsonString := '[
        {"id": 1, "name": "Alice", "score": 85},
        {"id": 2, "name": "Bob", "score": 92},
        {"id": 3, "name": "Charlie", "score": 78},
        {"id": 4, "name": "Diana", "score": 95}
    ]'

    students := JSON.parse(jsonString)

    result := "=== Original Data ===`n"
    result .= "Total students: " students.Length "`n`n"

    ; Iterate and display
    for student in students
        result .= student["name"] ": " student["score"] "`n"

    result .= "`n"

    ; Filter: scores >= 90
    highScorers := []
    for student in students {
        if (student["score"] >= 90)
            highScorers.Push(student)
    }

    result .= "=== High Scorers (>=90) ===`n"
    for student in highScorers
        result .= student["name"] ": " student["score"] "`n"

    result .= "`n"

    ; Transform: add grade property
    for student in students {
        score := student["score"]
        student["grade"] := score >= 90 ? "A" : score >= 80 ? "B" : "C"
    }

    result .= "=== With Grades ===`n"
    result .= JSON.stringify(students)

    MsgBox(
        result "`n`n"
        "Array Operations:`n"
        "• Length property gets count`n"
        "• for...in iterates elements`n"
        "• Push() adds elements`n"
        "• Access via array[index]`n"
        "• Modify elements directly`n"
        "• Filter/map patterns work",
        "Array Manipulation"
    )
}

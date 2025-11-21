; Demo Data Structures
; Examples of Map and Array operations in AutoHotkey v2

#Requires AutoHotkey v2.0

; Array operations example
DemoArrays() {
    ; Create array
    fruits := ["Apple", "Banana", "Cherry"]

    ; Add items
    fruits.Push("Date")
    fruits.Push("Elderberry")

    ; Iterate
    result := "Fruits:`n"
    for index, fruit in fruits {
        result .= index . ": " . fruit . "`n"
    }

    MsgBox(result, "Array Demo")
}

; Map operations example
DemoMaps() {
    ; Create map
    person := Map(
        "name", "John Doe",
        "age", 30,
        "city", "New York"
    )

    ; Add/update entries
    person["occupation"] := "Developer"

    ; Access values
    result := "Person Info:`n"
    for key, value in person {
        result .= key . ": " . value . "`n"
    }

    MsgBox(result, "Map Demo")
}

; Advanced array operations
DemoArrayFiltering() {
    ; Create array of numbers
    numbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    ; Filter even numbers
    evens := []
    for num in numbers {
        if (Mod(num, 2) = 0) {
            evens.Push(num)
        }
    }

    ; Calculate sum
    sum := 0
    for num in evens {
        sum += num
    }

    result := "Even numbers: " . ArrayToString(evens) . "`n"
    result .= "Sum: " . sum

    MsgBox(result, "Array Filtering Demo")
}

; Helper function to convert array to string
ArrayToString(arr) {
    str := ""
    for index, value in arr {
        str .= (index > 1 ? ", " : "") . value
    }
    return str
}

; Run demos
DemoArrays()
DemoMaps()
DemoArrayFiltering()

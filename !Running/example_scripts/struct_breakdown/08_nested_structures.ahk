;===============================================================================
; Nested Structures
; Demonstrates structs containing other structs
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

NestedStructExample()

class Point {
    __New() {
        this.buffer := Buffer(8, 0)  ; 2 Ints = 8 bytes
    }

    x {
        get => NumGet(this.buffer, 0, "Int")
        set => NumPut("Int", value, this.buffer, 0)
    }

    y {
        get => NumGet(this.buffer, 4, "Int")
        set => NumPut("Int", value, this.buffer, 4)
    }

    ToString() => "(" this.x ", " this.y ")"
}

class Rectangle {
    __New() {
        ; Buffer contains two Point structs
        this.buffer := Buffer(16, 0)  ; 2 Points = 16 bytes

        ; Create Point objects that share this buffer
        this._topLeft := Point()
        this._bottomRight := Point()

        ; Override their buffers to point into our buffer
        this._topLeft.buffer := Buffer(8, 0)
        this._topLeft.buffer.Ptr := this.buffer.Ptr

        this._bottomRight.buffer := Buffer(8, 0)
        this._bottomRight.buffer.Ptr := this.buffer.Ptr + 8
    }

    topLeft => this._topLeft
    bottomRight => this._bottomRight

    Width => this.bottomRight.x - this.topLeft.x
    Height => this.bottomRight.y - this.topLeft.y
    Area => this.Width * this.Height

    ToString() {
        return "Rectangle: " this.topLeft.ToString() " to " this.bottomRight.ToString()
             . "`nSize: " this.Width "x" this.Height " (Area: " this.Area ")"
    }
}

NestedStructExample() {
    ; Create rectangle
    rect := Rectangle()

    ; Set values through nested structs
    rect.topLeft.x := 10
    rect.topLeft.y := 20
    rect.bottomRight.x := 100
    rect.bottomRight.y := 80

    MsgBox(
        "=== Nested Structures Demo ===`n`n"
        rect.ToString() "`n`n"
        "Memory Layout:`n"
        "• Rectangle buffer: 16 bytes`n"
        "• TopLeft Point: bytes 0-7`n"
        "• BottomRight Point: bytes 8-15`n`n"
        "Concepts:`n"
        "• Nested structs share parent buffer`n"
        "• Sub-structs use offset pointers`n"
        "• Properties provide clean access`n"
        "• All data stored contiguously",
        "Nested Structures"
    )
}

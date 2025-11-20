;===============================================================================
; Practical API Usage - RECT Structure
; Real-world example using Windows RECT struct
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

PracticalAPIExample()

class RECT {
    __New() {
        this.buffer := Buffer(16, 0)  ; 4 LONGs = 16 bytes
    }

    left {
        get => NumGet(this.buffer, 0, "Int")
        set => NumPut("Int", value, this.buffer, 0)
    }

    top {
        get => NumGet(this.buffer, 4, "Int")
        set => NumPut("Int", value, this.buffer, 4)
    }

    right {
        get => NumGet(this.buffer, 8, "Int")
        set => NumPut("Int", value, this.buffer, 8)
    }

    bottom {
        get => NumGet(this.buffer, 12, "Int")
        set => NumPut("Int", value, this.buffer, 12)
    }

    Width => this.right - this.left
    Height => this.bottom - this.top
    Ptr => this.buffer.Ptr
}

PracticalAPIExample() {
    ; Get window rectangle using Windows API
    hwnd := WinExist("A")  ; Active window
    rect := RECT()

    ; Call GetWindowRect API
    success := DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect.Ptr)

    if success {
        result := "Active Window Position:`n`n"
        result .= "Window Handle: 0x" Format("{:X}", hwnd) "`n`n"
        result .= "Coordinates:`n"
        result .= "  Left: " rect.left "`n"
        result .= "  Top: " rect.top "`n"
        result .= "  Right: " rect.right "`n"
        result .= "  Bottom: " rect.bottom "`n`n"
        result .= "Dimensions:`n"
        result .= "  Width: " rect.Width " pixels`n"
        result .= "  Height: " rect.Height " pixels`n`n"
        result .= "This demonstrates how structs are used`n"
        result .= "to pass data to/from Windows APIs."
    } else {
        result := "Failed to get window rect"
    }

    MsgBox(
        "=== Practical API Usage ===`n`n"
        result "`n`n"
        "Concepts:`n"
        "• RECT is a Windows API struct`n"
        "• Pass struct.Ptr to DllCall()`n"
        "• API fills struct with data`n"
        "• Read struct properties to get results`n"
        "• Computed properties (Width/Height)",
        "Practical API Usage"
    )
}

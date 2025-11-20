;===============================================================================
; 32-bit vs 64-bit Struct Handling
; Demonstrates platform-dependent struct sizes
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

Platform ComparisonExample()

class PlatformAwareStruct {
    __New() {
        ; Calculate sizes based on platform
        this.is64bit := A_PtrSize = 8
        this.ptrSize := A_PtrSize

        ; Define struct with pointers
        ; Layout: Int, Ptr, Int, Ptr
        this.buffer := Buffer(8 + (2 * this.ptrSize), 0)

        this.offsets := {
            value1: 0,                      ; Int (4 bytes)
            pointer1: 4,                    ; Ptr (4 or 8 bytes)
            value2: 4 + this.ptrSize,       ; Int (4 bytes)
            pointer2: 8 + this.ptrSize      ; Ptr (4 or 8 bytes)
        }
    }

    value1 {
        get => NumGet(this.buffer, this.offsets.value1, "Int")
        set => NumPut("Int", value, this.buffer, this.offsets.value1)
    }

    pointer1 {
        get => NumGet(this.buffer, this.offsets.pointer1, "Ptr")
        set => NumPut("Ptr", value, this.buffer, this.offsets.pointer1)
    }

    value2 {
        get => NumGet(this.buffer, this.offsets.value2, "Int")
        set => NumPut("Int", value, this.buffer, this.offsets.value2)
    }

    pointer2 {
        get => NumGet(this.buffer, this.offsets.pointer2, "Ptr")
        set => NumPut("Ptr", value, this.buffer, this.offsets.pointer2)
    }

    ShowLayout() {
        result := "Platform: " (this.is64bit ? "64-bit" : "32-bit") "`n"
        result .= "Pointer Size: " this.ptrSize " bytes`n`n"
        result .= "Struct Layout:`n"
        result .= "  value1 (Int):  offset " this.offsets.value1 " (4 bytes)`n"
        result .= "  pointer1 (Ptr): offset " this.offsets.pointer1 " (" this.ptrSize " bytes)`n"
        result .= "  value2 (Int):  offset " this.offsets.value2 " (4 bytes)`n"
        result .= "  pointer2 (Ptr): offset " this.offsets.pointer2 " (" this.ptrSize " bytes)`n`n"
        result .= "Total Size: " this.buffer.Size " bytes`n`n"

        ; Show what the size would be on opposite platform
        otherSize := 8 + (2 * (this.is64bit ? 4 : 8))
        result .= "On " (this.is64bit ? "32" : "64") "-bit: " otherSize " bytes"

        return result
    }
}

PlatformComparisonExample() {
    s := PlatformAwareStruct()

    ; Set some values
    s.value1 := 100
    s.value2 := 200
    s.pointer1 := 0x12345678
    s.pointer2 := 0x87654321

    result := s.ShowLayout()
    result .= "`n`nStored Values:`n"
    result .= "  value1: " s.value1 "`n"
    result .= "  value2: " s.value2 "`n"
    result .= "  pointer1: 0x" Format("{:X}", s.pointer1) "`n"
    result .= "  pointer2: 0x" Format("{:X}", s.pointer2)

    MsgBox(
        "=== Platform Comparison ===`n`n"
        result "`n`n"
        "Concepts:`n"
        "• A_PtrSize = 4 (32-bit) or 8 (64-bit)`n"
        "• Pointer fields change struct size`n"
        "• Offsets must be calculated dynamically`n"
        "• Same struct has different sizes`n"
        "• Important for cross-platform code",
        "Platform Comparison"
    )
}

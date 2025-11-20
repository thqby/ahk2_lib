;===============================================================================
; Buffer Management Basics
; Demonstrates Buffer allocation and NumPut/NumGet operations
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

BufferManagementExample()

BufferManagementExample() {
    ; Create a buffer (allocates memory)
    bufferSize := 16  ; 16 bytes
    buf := Buffer(bufferSize, 0)  ; Initialize with zeros

    ; Store different data types
    NumPut("UInt", 42, buf, 0)           ; Store unsigned int at offset 0
    NumPut("Double", 3.14159, buf, 4)    ; Store double at offset 4
    NumPut("Short", -1000, buf, 12)      ; Store short at offset 12

    ; Retrieve the values
    value1 := NumGet(buf, 0, "UInt")     ; Read unsigned int
    value2 := NumGet(buf, 4, "Double")   ; Read double
    value3 := NumGet(buf, 12, "Short")   ; Read short

    ; Get buffer information
    bufPtr := buf.Ptr                     ; Get memory address
    bufSize := buf.Size                   ; Get buffer size

    MsgBox(
        "=== Buffer Management Demo ===`n`n"
        "Buffer Size: " bufSize " bytes`n"
        "Buffer Address: 0x" Format("{:X}", bufPtr) "`n`n"
        "Stored Values:`n"
        "• UInt at offset 0: " value1 "`n"
        "• Double at offset 4: " value2 "`n"
        "• Short at offset 12: " value3 "`n`n"
        "Concepts:`n"
        "• Buffer() allocates memory`n"
        "• NumPut() writes to memory`n"
        "• NumGet() reads from memory`n"
        "• .Ptr gets memory address`n"
        "• .Size gets buffer size",
        "Buffer Management"
    )
}

;===============================================================================
; Type Conversion - C Types to AHK Types
; Demonstrates converting Windows API types to AutoHotkey types
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

TypeConversionExample()

TypeConversionExample() {
    ; AHK base types
    ahkTypes := Map(
        "UInt", 4,
        "UInt64", 8,
        "Int", 4,
        "Int64", 8,
        "Short", 2,
        "UShort", 2,
        "Char", 1,
        "UChar", 1,
        "Double", 8,
        "Float", 4,
        "Ptr", A_PtrSize,
        "UPtr", A_PtrSize
    )

    ; Windows API types and their AHK equivalents
    conversions := Map(
        "BYTE", "UChar",
        "WORD", "UShort",
        "DWORD", "UInt",
        "DWORD64", "UInt64",
        "BOOL", "Int",
        "LONG", "Int",
        "LONGLONG", "Int64",
        "HANDLE", "Ptr",
        "HWND", "Ptr",
        "LPWSTR", "Ptr",
        "PVOID", "Ptr",
        "SIZE_T", "UPtr"
    )

    result := "Windows API Type Conversions:`n`n"
    result .= Format("{:-15} {:-10} {}`n", "API Type", "AHK Type", "Size (bytes)")
    result .= "----------------------------------------`n"

    for apiType, ahkType in conversions {
        size := ahkTypes.Has(ahkType) ? ahkTypes[ahkType] : "?"
        result .= Format("{:-15} {:-10} {}`n", apiType, ahkType, size)
    }

    result .= "`n`nPointer Types:`n"
    result .= "• Any type ending with '*' = Ptr`n"
    result .= "• HANDLE types (HWND, HDC, etc.) = Ptr`n"
    result .= "• LP* types (LPWSTR, LPVOID, etc.) = Ptr`n"
    result .= "• Current Ptr size: " A_PtrSize " bytes (" (A_PtrSize = 8 ? "64-bit" : "32-bit") ")"

    MsgBox(
        "=== Type Conversion Demo ===`n`n"
        result "`n`n"
        "Concepts:`n"
        "• Windows types map to AHK types`n"
        "• Pointer types depend on architecture`n"
        "• DWORD = UInt (unsigned 32-bit)`n"
        "• LONG = Int (signed 32-bit)`n"
        "• Pointers = 4 bytes (32-bit) or 8 bytes (64-bit)",
        "Type Conversion"
    )
}

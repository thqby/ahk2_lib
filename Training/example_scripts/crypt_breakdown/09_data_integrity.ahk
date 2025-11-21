;===============================================================================
; Data Integrity Verification
; Use hashing to detect data tampering
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

DataIntegrityExample() {
    ; Simulate important data
    data := "Important financial record: $1000.00"
    buf := Buffer(StrLen(data) * 2)
    StrPut(data, buf, "UTF-16")

    ; Create checksum
    checksum := Crypt_Hash(buf, , "SHA1")

    result := "=== Original Data ===`n"
    result .= data "`n"
    result .= "Checksum: " SubStr(checksum, 1, 20) "...`n`n"

    ; Verify unchanged data
    buf2 := Buffer(StrLen(data) * 2)
    StrPut(data, buf2, "UTF-16")
    checksum2 := Crypt_Hash(buf2, , "SHA1")

    result .= "=== Verification 1 (Unchanged) ===`n"
    result .= "Match: " (checksum = checksum2 ? "✓ Data intact" : "✗ Data corrupted") "`n`n"

    ; Tampered data
    tamperedData := "Important financial record: $2000.00"  ; Changed amount!
    buf3 := Buffer(StrLen(tamperedData) * 2)
    StrPut(tamperedData, buf3, "UTF-16")
    checksum3 := Crypt_Hash(buf3, , "SHA1")

    result .= "=== Verification 2 (Tampered) ===`n"
    result .= "Data: " tamperedData "`n"
    result .= "Match: " (checksum = checksum3 ? "✓ Data intact" : "✗ Data corrupted!") "`n`n"

    result .= "Applications:`n"
    result .= "• Detect file modifications`n"
    result .= "• Verify downloads`n"
    result .= "• Database integrity`n"
    result .= "• Blockchain technology`n"
    result .= "• Digital signatures"

    MsgBox(result, "Data Integrity")
}

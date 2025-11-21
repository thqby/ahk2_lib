;===============================================================================
; Basic MD5 Hashing
; Generate MD5 hash of strings and data
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

BasicMD5Example()

BasicMD5Example() {
    ; Example 1: Hash a simple string
    text1 := "Hello, World!"
    buf1 := Buffer(StrLen(text1) * 2)
    StrPut(text1, buf1, "UTF-16")
    hash1 := MD5(buf1)

    result := "=== Basic String Hashing ===`n"
    result .= "Text: " text1 "`n"
    result .= "MD5: " hash1 "`n`n"

    ; Example 2: Different text = different hash
    text2 := "Hello, world!"  ; lowercase 'w'
    buf2 := Buffer(StrLen(text2) * 2)
    StrPut(text2, buf2, "UTF-16")
    hash2 := MD5(buf2)

    result .= "=== Case Sensitivity ===`n"
    result .= "Text: " text2 "`n"
    result .= "MD5: " hash2 "`n"
    result .= "Same hash? " (hash1 = hash2 ? "Yes" : "No") "`n`n"

    ; Example 3: Same text = same hash (verify)
    text3 := "Hello, World!"
    buf3 := Buffer(StrLen(text3) * 2)
    StrPut(text3, buf3, "UTF-16")
    hash3 := MD5(buf3)

    result .= "=== Verification ===`n"
    result .= "Text: " text3 "`n"
    result .= "MD5: " hash3 "`n"
    result .= "Matches first? " (hash1 = hash3 ? "Yes ✓" : "No") "`n`n"

    ; Example 4: Empty string
    buf4 := Buffer(2)
    StrPut("", buf4, "UTF-16")
    hash4 := MD5(buf4)

    result .= "=== Empty String ===`n"
    result .= "MD5: " hash4

    MsgBox(
        result "`n`n"
        "MD5 Hash Properties:`n"
        "• Fixed 32-character hex output`n"
        "• Same input = same output`n"
        "• One-way (cannot reverse)`n"
        "• Small change = completely different hash`n"
        "• Used for checksums and verification",
        "Basic MD5 Hashing"
    )
}

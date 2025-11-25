;===============================================================================
; AES Key Sizes
; Compare AES-128, AES-192, and AES-256
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

AESKeySizesExample() {
    message := "Test Message"
    password := "MyPassword"
    msgSize := StrLen(message) * 2

    result := "=== AES Key Size Comparison ===`n`n"

    ; Test each key size
    for keySize in [128, 192, 256] {
        buf := Buffer(msgSize + 16, 0)
        StrPut(message, buf, "UTF-16")

        ; Encrypt
        encSize := Crypt_AES(buf, msgSize, password, keySize, true)

        ; Decrypt
        decSize := Crypt_AES(buf, encSize, password, keySize, false)
        decrypted := StrGet(buf, "UTF-16")

        result .= "AES-" keySize ":`n"
        result .= "  Encrypted: " encSize " bytes`n"
        result .= "  Decrypted: " decSize " bytes`n"
        result .= "  Success: " (message = decrypted ? "✓" : "✗") "`n`n"
    }

    result .= "=== Security Levels ===`n"
    result .= "AES-128: Good, fast`n"
    result .= "AES-192: Better, slower`n"
    result .= "AES-256: Best, slowest`n`n"

    result .= "Recommendations:`n"
    result .= "• AES-256 for maximum security`n"
    result .= "• AES-128 for performance`n"
    result .= "• All are currently unbreakable`n"
    result .= "• Use AES-256 when unsure"

    MsgBox(result, "AES Key Sizes")
}

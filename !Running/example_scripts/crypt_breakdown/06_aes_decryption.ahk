;===============================================================================
; AES Decryption
; Encrypt and decrypt data with AES
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

AESDecryptionExample() {
    message := "Secret Message 2024"
    password := "SuperSecureKey!"

    ; Encrypt
    msgSize := StrLen(message) * 2
    buf := Buffer(msgSize + 16, 0)
    StrPut(message, buf, "UTF-16")

    result := "=== Original ===`n"
    result .= message "`n`n"

    encSize := Crypt_AES(buf, msgSize, password, 256, true)

    result .= "=== After Encryption ===`n"
    result .= "Encrypted size: " encSize " bytes`n"
    result .= "(Binary data)`n`n"

    ; Decrypt
    decSize := Crypt_AES(buf, encSize, password, 256, false)

    result .= "=== After Decryption ===`n"
    result .= "Decrypted size: " decSize " bytes`n"
    decrypted := StrGet(buf, "UTF-16")
    result .= "Message: " decrypted "`n`n"

    result .= "Verification: " (message = decrypted ? "✓ Success!" : "✗ Failed") "`n`n"

    ; Show wrong password fails
    buf2 := Buffer(msgSize + 16, 0)
    StrPut(message, buf2, "UTF-16")
    Crypt_AES(buf2, msgSize, password, 256, true)

    result .= "=== Wrong Password Test ===`n"
    Crypt_AES(buf2, encSize, "WrongPassword", 256, false)
    wrong := StrGet(buf2, "UTF-16")
    result .= "Result: " (message = wrong ? "Decrypted (unexpected)" : "Garbage data (expected)") "`n"
    result .= "First chars: " SubStr(wrong, 1, 10) "..."

    MsgBox(result, "AES Encryption/Decryption")
}

;===============================================================================
; AES Encryption
; Encrypt data with AES-256
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

AESEncryptionExample() {
    ; Original message
    message := "This is a secret message!"
    password := "MyEncryptionKey123"

    ; Prepare buffer (needs extra space for encryption)
    msgSize := StrLen(message) * 2
    buf := Buffer(msgSize + 16, 0)
    StrPut(message, buf, "UTF-16")

    result := "=== Original Message ===`n"
    result .= message "`n`n"

    ; Encrypt
    encryptedSize := Crypt_AES(buf, msgSize, password, 256, true)

    result .= "=== Encrypted ===`n"
    result .= "Size: " encryptedSize " bytes`n"
    result .= "First 32 bytes (hex): "
    Loop Min(16, encryptedSize)
        result .= Format("{:02X}", NumGet(buf, A_Index-1, "UChar")) " "
    result .= "...`n"
    result .= "(Binary data, not human-readable)`n`n"

    result .= "=== Encryption Details ===`n"
    result .= "Algorithm: AES-256`n"
    result .= "Key Size: 256 bits`n"
    result .= "Password: (hidden)`n"
    result .= "Block Size: 16 bytes`n`n"

    result .= "Properties:`n"
    result .= "• Symmetric encryption (same key)`n"
    result .= "• Strong security`n"
    result .= "• Fast performance`n"
    result .= "• Industry standard"

    MsgBox(result, "AES Encryption")
}

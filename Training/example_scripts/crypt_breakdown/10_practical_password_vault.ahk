;===============================================================================
; Practical Example - Simple Password Vault
; Encrypt and store passwords securely
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

PasswordVaultExample() {
    ; Master password for the vault
    masterPassword := "MyMasterPassword123"

    ; Create a "database" of passwords
    passwords := Map()
    passwords["email"] := "myemail@example.com:password123"
    passwords["bank"] := "username:securepass456"
    passwords["work"] := "work.user:corporate789"

    result := "=== Password Vault Demo ===`n`n"

    ; Encrypt each password
    encrypted := Map()
    for service, credentials in passwords {
        credSize := StrLen(credentials) * 2
        buf := Buffer(credSize + 16, 0)
        StrPut(credentials, buf, "UTF-16")

        encSize := Crypt_AES(buf, credSize, masterPassword, 256, true)

        ; Store encrypted (in real app, save to file)
        encrypted[service] := {buffer: buf, size: encSize}

        result .= "Encrypted: " service "`n"
    }

    result .= "`n=== Retrieving Password ===`n"

    ; "User" wants to retrieve email password
    requestedService := "email"
    result .= "Service: " requestedService "`n"

    ; Decrypt
    if encrypted.Has(requestedService) {
        entry := encrypted[requestedService]
        decSize := Crypt_AES(entry.buffer, entry.size, masterPassword, 256, false)
        decrypted := StrGet(entry.buffer, "UTF-16")

        result .= "Credentials: " decrypted "`n"
        result .= "Match original: " (passwords[requestedService] = decrypted ? "✓" : "✗") "`n"
    }

    result .= "`n=== Security Features ===`n"
    result .= "• Master password protects all`n"
    result .= "• Each entry encrypted separately`n"
    result .= "• AES-256 encryption`n"
    result .= "• Data unreadable without password`n`n"

    result .= "Real Implementation Would Add:`n"
    result .= "• Save encrypted data to file`n"
    result .= "• GUI for easy access`n"
    result .= "• Password strength checker`n"
    result .= "• Auto-lock after timeout`n"
    result .= "• Backup and sync features"

    MsgBox(result, "Password Vault Example")
}

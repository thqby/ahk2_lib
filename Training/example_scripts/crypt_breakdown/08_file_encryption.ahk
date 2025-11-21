;===============================================================================
; File Encryption
; Encrypt and decrypt entire files
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

FileEncryptionExample() {
    ; Create test file
    originalFile := A_Temp "\test_original.txt"
    encryptedFile := A_Temp "\test_encrypted.bin"
    decryptedFile := A_Temp "\test_decrypted.txt"
    password := "FileEncryptionKey123"

    ; Cleanup old files
    for file in [originalFile, encryptedFile, decryptedFile]
        try FileDelete(file)

    ; Create test content
    content := "This is confidential data.`nLine 2`nLine 3`n"
    FileAppend(content, originalFile, "UTF-8")

    result := "=== Original File ===`n"
    result .= "File: " originalFile "`n"
    result .= "Size: " FileGetSize(originalFile) " bytes`n"
    result .= "Content: " content "`n"

    ; Read file into buffer
    file := FileOpen(originalFile, "r")
    fileSize := file.Length
    buf := Buffer(fileSize + 16, 0)  ; Extra space for encryption
    file.RawRead(buf, fileSize)
    file.Close()

    ; Encrypt
    encSize := Crypt_AES(buf, fileSize, password, 256, true)

    ; Save encrypted
    encFile := FileOpen(encryptedFile, "w")
    encFile.RawWrite(buf, encSize)
    encFile.Close()

    result .= "`n=== Encrypted File ===`n"
    result .= "File: " encryptedFile "`n"
    result .= "Size: " FileGetSize(encryptedFile) " bytes`n"
    result .= "(Binary encrypted data)`n"

    ; Read encrypted file
    encFileRead := FileOpen(encryptedFile, "r")
    encBuf := Buffer(encFileRead.Length)
    encFileRead.RawRead(encBuf, encFileRead.Length)
    encFileRead.Close()

    ; Decrypt
    decSize := Crypt_AES(encBuf, encBuf.Size, password, 256, false)

    ; Save decrypted
    decFile := FileOpen(decryptedFile, "w")
    decFile.RawWrite(encBuf, decSize)
    decFile.Close()

    result .= "`n=== Decrypted File ===`n"
    result .= "File: " decryptedFile "`n"
    result .= "Size: " FileGetSize(decryptedFile) " bytes`n"

    decContent := FileRead(decryptedFile, "UTF-8")
    result .= "Content: " decContent "`n"
    result .= "Match: " (content = decContent ? "✓" : "✗")

    MsgBox(result "`n`nUse Case:`n• Secure file storage`n• Protect sensitive documents`n• Safe backups", "File Encryption")

    ; Cleanup
    for file in [originalFile, encryptedFile, decryptedFile]
        try FileDelete(file)
}

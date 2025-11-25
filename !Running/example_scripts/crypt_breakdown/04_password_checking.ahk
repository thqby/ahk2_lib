;===============================================================================
; Password Verification
; Use hashing to verify passwords without storing them
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

PasswordCheckingExample() {
    ; Simulate storing a password hash (not the password itself)
    correctPassword := "MySecurePassword123"
    buf := Buffer(StrLen(correctPassword) * 2)
    StrPut(correctPassword, buf, "UTF-16")
    storedHash := Crypt_Hash(buf, , "SHA1")

    result := "=== Password Storage (Simulated) ===`n"
    result .= "Stored Hash: " SubStr(storedHash, 1, 20) "...`n"
    result .= "(Full password never stored!)`n`n"

    ; Test 1: Correct password
    attempt1 := "MySecurePassword123"
    buf1 := Buffer(StrLen(attempt1) * 2)
    StrPut(attempt1, buf1, "UTF-16")
    hash1 := Crypt_Hash(buf1, , "SHA1")

    result .= "=== Login Attempt 1 ===`n"
    result .= "Input: " attempt1 "`n"
    result .= "Match: " (hash1 = storedHash ? "✓ Access Granted" : "✗ Access Denied") "`n`n"

    ; Test 2: Wrong password
    attempt2 := "MySecurePassword124"
    buf2 := Buffer(StrLen(attempt2) * 2)
    StrPut(attempt2, buf2, "UTF-16")
    hash2 := Crypt_Hash(buf2, , "SHA1")

    result .= "=== Login Attempt 2 ===`n"
    result .= "Input: " attempt2 "`n"
    result .= "Match: " (hash2 = storedHash ? "✓ Access Granted" : "✗ Access Denied") "`n`n"

    result .= "Security Note:`n"
    result .= "• Store hash, not password`n"
    result .= "• Use salt in production`n"
    result .= "• Use bcrypt/scrypt for passwords`n"
    result .= "• This is simplified example"

    MsgBox(result, "Password Verification")
}

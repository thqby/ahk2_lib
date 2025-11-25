;===============================================================================
; Hash Algorithm Types
; Compare CRC32, MD5, and SHA1 hashing
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

HashTypesExample()

HashTypesExample() {
    text := "The quick brown fox jumps over the lazy dog"
    buf := Buffer(StrLen(text) * 2)
    StrPut(text, buf, "UTF-16")

    ; Hash with different algorithms
    crc32 := Crypt_Hash(buf, , "CRC32")
    md5 := Crypt_Hash(buf, , "MD5")
    sha1 := Crypt_Hash(buf, , "SHA1")

    result := "=== Input Text ===`n"
    result .= text "`n`n"

    result .= "=== Hash Results ===`n`n"

    result .= "CRC32 (32-bit cyclic redundancy check):`n"
    result .= crc32 "`n"
    result .= "Length: " StrLen(crc32) " hex chars`n`n"

    result .= "MD5 (128-bit hash):`n"
    result .= md5 "`n"
    result .= "Length: " StrLen(md5) " hex chars`n`n"

    result .= "SHA1 (160-bit hash):`n"
    result .= sha1 "`n"
    result .= "Length: " StrLen(sha1) " hex chars`n`n"

    result .= "=== Algorithm Comparison ===`n"
    result .= "CRC32: Fast, collision-prone, use for checksums`n"
    result .= "MD5: Medium speed, deprecated for security`n"
    result .= "SHA1: Slower, better security than MD5`n"
    result .= "SHA256+: Use for cryptographic security (not in this lib)"

    MsgBox(result, "Hash Algorithm Types")
}

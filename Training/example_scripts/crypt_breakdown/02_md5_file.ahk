;===============================================================================
; MD5 File Hashing
; Generate MD5 checksum of files
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Crypt.ahk

MD5FileExample()

MD5FileExample() {
    ; Create a temporary test file
    testFile := A_Temp "\ahk_test_md5.txt"
    testContent := "This is a test file for MD5 hashing.`nLine 2`nLine 3"

    ; Write file
    try FileDelete(testFile)
    FileAppend(testContent, testFile, "UTF-8")

    ; Hash the file
    hash1 := MD5_File(testFile)

    result := "=== File MD5 Checksum ===`n"
    result .= "File: " testFile "`n"
    result .= "Size: " FileGetSize(testFile) " bytes`n"
    result .= "MD5: " hash1 "`n`n"

    ; Hash again (should be same)
    hash2 := MD5_File(testFile)
    result .= "Second hash: " hash2 "`n"
    result .= "Matches: " (hash1 = hash2 ? "Yes ✓" : "No") "`n`n"

    ; Modify file slightly
    FileAppend("`n", testFile, "UTF-8")
    hash3 := MD5_File(testFile)

    result .= "=== After Modification ===`n"
    result .= "Added: one newline character`n"
    result .= "New MD5: " hash3 "`n"
    result .= "Changed: " (hash1 != hash3 ? "Yes ✓" : "No") "`n`n"

    ; Hash AutoHotkey executable
    ahkPath := A_AhkPath
    if FileExist(ahkPath) {
        ahkHash := MD5_File(ahkPath)
        result .= "=== AHK Executable ===`n"
        result .= "File: " ahkPath "`n"
        result .= "MD5: " ahkHash
    }

    ; Cleanup
    try FileDelete(testFile)

    MsgBox(
        result "`n`n"
        "File MD5 Use Cases:`n"
        "• Verify file integrity`n"
        "• Detect file changes`n"
        "• Compare file versions`n"
        "• Check download correctness`n"
        "• Duplicate file detection",
        "MD5 File Hashing"
    )
}

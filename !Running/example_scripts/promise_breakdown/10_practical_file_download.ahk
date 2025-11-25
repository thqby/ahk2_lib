;===============================================================================
; Practical Example - Simulated File Download
; Real-world async operation using promises
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../Promise.ahk

PracticalFileDownloadExample()

; Simulated file download function
DownloadFile(url) {
    return Promise((resolve, reject) => {
        ; Simulate download time based on "file size"
        size := StrLen(url) * 10
        delay := size > 100 ? 1000 : 500

        ; Simulate occasional failures
        if (InStr(url, "fail"))
            return SetTimer(() => reject("Download failed: " url), -delay)

        ; Successful download
        SetTimer(() => resolve({url: url, size: size, data: "File content..."}), -delay)
    })
}

PracticalFileDownloadExample() {
    result := ""

    ; Download multiple files in parallel
    files := [
        "https://example.com/image1.jpg",
        "https://example.com/data.json",
        "https://example.com/style.css"
    ]

    result .= "Downloading " files.Length " files...`n`n"

    downloads := []
    for url in files
        downloads.Push(DownloadFile(url))

    ; Wait for all downloads
    Promise.all(downloads)
        .then((results) => {
            result .= "All downloads complete!`n`n"

            totalSize := 0
            for i, file in results {
                result .= files[i] "`n"
                result .= "  Size: " file.size " bytes`n`n"
                totalSize += file.size
            }

            result .= "Total downloaded: " totalSize " bytes"

            MsgBox(
                "=== File Download Demo ===`n`n"
                result "`n`n"
                "Real-world applications:`n"
                "• HTTP requests`n"
                "• File I/O operations`n"
                "• Database queries`n"
                "• Timer-based operations`n"
                "• Any async operation",
                "Practical Example"
            )
        })
        .catch((err) => {
            MsgBox("Download error: " err, "Error", "Icon!")
        })

    Sleep(1500)
}

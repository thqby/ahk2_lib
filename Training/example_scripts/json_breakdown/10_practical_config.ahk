;===============================================================================
; Practical Example - Configuration File
; Read, modify, and save JSON config files
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ../../../JSON.ahk

PracticalConfigExample()

PracticalConfigExample() {
    ; Simulate config file content
    configJSON := '{
        "app": {
            "name": "MyApplication",
            "version": "1.2.0",
            "autoUpdate": true
        },
        "window": {
            "width": 800,
            "height": 600,
            "maximized": false
        },
        "preferences": {
            "theme": "dark",
            "language": "en",
            "notifications": true
        },
        "recentFiles": [
            "C:\\Documents\\file1.txt",
            "C:\\Documents\\file2.txt"
        ]
    }'

    ; Parse configuration
    config := JSON.parse(configJSON)

    result := "=== Current Configuration ===`n"
    result .= "App: " config["app"]["name"] " v" config["app"]["version"] "`n"
    result .= "Window: " config["window"]["width"] "x" config["window"]["height"] "`n"
    result .= "Theme: " config["preferences"]["theme"] "`n"
    result .= "Recent files: " config["recentFiles"].Length "`n`n"

    ; Modify configuration
    config["app"]["version"] := "1.3.0"
    config["window"]["maximized"] := true
    config["preferences"]["theme"] := "light"
    config["recentFiles"].InsertAt(1, "C:\\Documents\\newfile.txt")

    ; Keep only 3 most recent files
    while config["recentFiles"].Length > 3
        config["recentFiles"].Pop()

    result .= "=== Modified Configuration ===`n"
    result .= "App: " config["app"]["name"] " v" config["app"]["version"] "`n"
    result .= "Window: " config["window"]["width"] "x" config["window"]["height"]
              (config["window"]["maximized"] ? " (maximized)" : "") "`n"
    result .= "Theme: " config["preferences"]["theme"] "`n"
    result .= "Recent files: " config["recentFiles"].Length "`n`n"

    ; Convert back to JSON
    newConfigJSON := JSON.stringify(config)

    result .= "=== JSON Output ===`n"
    result .= newConfigJSON "`n`n"

    ; In real application:
    result .= "Real-world usage:`n"
    result .= "• FileRead(configPath) to load`n"
    result .= "• JSON.parse() to convert`n"
    result .= "• Modify settings`n"
    result .= "• JSON.stringify() to convert back`n"
    result .= "• FileAppend(json, configPath, 'UTF-8') to save"

    MsgBox(
        result,
        "Practical Config Example"
    )
}

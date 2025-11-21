;===============================================================================
; JSON.ahk Breakdown Examples - Launcher GUI
; Browse and run all JSON training examples
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

examples := [
    {
        file: "01_basic_parsing.ahk",
        title: "Basic Parsing",
        desc: "Parse simple JSON strings into AHK Maps and Arrays",
        tier: "Beginner",
        concepts: ["parse", "objects", "arrays"]
    },
    {
        file: "02_basic_stringify.ahk",
        title: "Basic Stringify",
        desc: "Convert AHK objects and arrays to JSON strings",
        tier: "Beginner",
        concepts: ["stringify", "conversion", "output"]
    },
    {
        file: "03_nested_structures.ahk",
        title: "Nested Structures",
        desc: "Handle complex nested objects and arrays",
        tier: "Intermediate",
        concepts: ["nesting", "complex", "hierarchy"]
    },
    {
        file: "04_boolean_null.ahk",
        title: "Boolean & Null",
        desc: "Work with true, false, and null values",
        tier: "Intermediate",
        concepts: ["boolean", "null", "types"]
    },
    {
        file: "05_pretty_printing.ahk",
        title: "Pretty Printing",
        desc: "Format JSON with indentation for readability",
        tier: "Beginner",
        concepts: ["formatting", "indentation", "readable"]
    },
    {
        file: "06_map_vs_object.ahk",
        title: "Map vs Object",
        desc: "Choose between Map or Object mode for parsing",
        tier: "Intermediate",
        concepts: ["Map", "Object", "choice"]
    },
    {
        file: "07_escape_characters.ahk",
        title: "Escape Characters",
        desc: "Handle special characters and escape sequences",
        tier: "Intermediate",
        concepts: ["escaping", "special chars", "unicode"]
    },
    {
        file: "08_error_handling.ahk",
        title: "Error Handling",
        desc: "Handle malformed JSON and parse errors",
        tier: "Intermediate",
        concepts: ["errors", "validation", "try-catch"]
    },
    {
        file: "09_array_manipulation.ahk",
        title: "Array Manipulation",
        desc: "Iterate, filter, and transform JSON arrays",
        tier: "Intermediate",
        concepts: ["arrays", "filter", "transform"]
    },
    {
        file: "10_practical_config.ahk",
        title: "Config File Example",
        desc: "Read, modify, and save JSON configuration files",
        tier: "Advanced",
        concepts: ["practical", "config", "real-world"]
    }
]

CreateLauncherGUI()

CreateLauncherGUI() {
    gui := Gui("+Resize", "JSON.ahk Training Examples")
    gui.SetFont("s10", "Segoe UI")
    gui.MarginX := 15
    gui.MarginY := 15

    ; Title
    gui.SetFont("s14 bold")
    gui.Add("Text", "w600", "📦 JSON.ahk Breakdown Examples")
    gui.SetFont("s10 norm")

    ; Description
    gui.Add("Text", "xm y+10 w600",
        "Learn JSON parsing and serialization in AHK v2.`n"
        "Parse JSON data, create JSON strings, and work with complex structures.")

    ; Filter
    gui.Add("Text", "xm y+15", "Filter by Difficulty:")
    tierDDL := gui.Add("DropDownList", "x+10 yp-3 w150", ["All Levels", "Beginner", "Intermediate", "Advanced"])
    tierDDL.Choose(1)
    tierDDL.OnEvent("Change", (*) => UpdateList())

    ; ListView
    gui.Add("Text", "xm y+15", "Examples:")
    lv := gui.Add("ListView", "xm y+5 w600 h350 -Multi", ["#", "Title", "Tier", "Concepts"])
    lv.ModifyCol(1, 40)
    lv.ModifyCol(2, 220)
    lv.ModifyCol(3, 100)
    lv.ModifyCol(4, 210)

    ; Description
    gui.Add("Text", "xm y+10", "Description:")
    descEdit := gui.Add("Edit", "xm y+5 w600 h60 ReadOnly -WantReturn")

    ; Buttons
    runBtn := gui.Add("Button", "xm y+10 w140 h35 Default", "▶ Run Example")
    viewBtn := gui.Add("Button", "x+10 yp w140 h35", "📄 View Code")
    gui.Add("Button", "x+10 yp w140 h35", "ℹ About").OnEvent("Click", (*) => ShowAbout())
    gui.Add("Button", "x+10 yp w140 h35", "❌ Close").OnEvent("Click", (*) => ExitApp())

    ; Events
    lv.OnEvent("ItemSelect", (*) => UpdateDescription())
    lv.OnEvent("DoubleClick", (*) => RunExample())
    runBtn.OnEvent("Click", (*) => RunExample())
    viewBtn.OnEvent("Click", (*) => ViewCode())

    ; Store
    gui.lv := lv
    gui.descEdit := descEdit
    gui.tierDDL := tierDDL

    UpdateList()
    gui.Show("w630 h620")

    UpdateList(*) {
        selectedTier := gui.tierDDL.Text
        gui.lv.Delete()

        num := 1
        for example in examples {
            if (selectedTier = "All Levels" || selectedTier = example.tier) {
                concepts := ""
                for concept in example.concepts
                    concepts .= (A_Index > 1 ? ", " : "") concept

                gui.lv.Add(, num++, example.title, example.tier, concepts)
            }
        }

        if (gui.lv.GetCount() > 0) {
            gui.lv.Modify(1, "Select Focus")
            UpdateDescription()
        }
    }

    UpdateDescription(*) {
        row := gui.lv.GetNext()
        if (!row)
            return

        title := gui.lv.GetText(row, 2)
        for example in examples {
            if (example.title = title) {
                gui.descEdit.Value := example.desc
                break
            }
        }
    }

    RunExample(*) {
        row := gui.lv.GetNext()
        if (!row) {
            MsgBox("Please select an example to run.", "No Selection", "Icon!")
            return
        }

        title := gui.lv.GetText(row, 2)
        for example in examples {
            if (example.title = title) {
                scriptPath := A_ScriptDir "\" example.file
                if FileExist(scriptPath)
                    Run('"' A_AhkPath '" "' scriptPath '"')
                else
                    MsgBox("File not found: " scriptPath, "Error", "Icon!")
                break
            }
        }
    }

    ViewCode(*) {
        row := gui.lv.GetNext()
        if (!row) {
            MsgBox("Please select an example to view.", "No Selection", "Icon!")
            return
        }

        title := gui.lv.GetText(row, 2)
        for example in examples {
            if (example.title = title) {
                scriptPath := A_ScriptDir "\" example.file
                if FileExist(scriptPath)
                    Run('notepad.exe "' scriptPath '"')
                else
                    MsgBox("File not found: " scriptPath, "Error", "Icon!")
                break
            }
        }
    }

    ShowAbout(*) {
        MsgBox(
            "JSON.ahk Training Examples`n`n"
            "Learn JSON parsing and serialization in AutoHotkey v2.`n"
            "Based on the JSON library by thqby & HotKeyIt.`n`n"
            "Total Examples: " examples.Length "`n"
            "Beginner: 3 | Intermediate: 6 | Advanced: 1`n`n"
            "Concepts Covered:`n"
            "• JSON.parse() - string to object`n"
            "• JSON.stringify() - object to string`n"
            "• Nested structures and arrays`n"
            "• Boolean and null handling`n"
            "• Pretty printing and formatting`n"
            "• Map vs Object modes`n"
            "• Escape sequences`n"
            "• Error handling and validation`n"
            "• Practical configuration files",
            "About",
            "Icon64"
        )
    }
}

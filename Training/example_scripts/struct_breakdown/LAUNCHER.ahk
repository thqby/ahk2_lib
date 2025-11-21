;===============================================================================
; Struct Breakdown Examples - Launcher GUI
; Browse and run all struct training examples
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; Example definitions
examples := [
    {
        file: "01_property_descriptors.ahk",
        title: "Property Descriptors",
        desc: "Learn DefineProp() for creating dynamic properties with getters/setters",
        tier: "Beginner",
        concepts: ["DefineProp", "Properties", "Get/Set"]
    },
    {
        file: "02_buffer_management.ahk",
        title: "Buffer Management",
        desc: "Buffer allocation, NumPut/NumGet for reading/writing memory",
        tier: "Beginner",
        concepts: ["Buffer", "NumPut", "NumGet", "Memory"]
    },
    {
        file: "03_dynamic_properties.ahk",
        title: "Dynamic Properties",
        desc: "Using Bind() to create closures for property access",
        tier: "Intermediate",
        concepts: ["Bind", "Closures", "Dynamic"]
    },
    {
        file: "04_string_parsing.ahk",
        title: "String Parsing",
        desc: "RegEx parsing of C struct definitions",
        tier: "Intermediate",
        concepts: ["RegEx", "Parsing", "Strings"]
    },
    {
        file: "05_alignment_offsets.ahk",
        title: "Alignment & Offsets",
        desc: "Memory alignment calculations for struct members",
        tier: "Intermediate",
        concepts: ["Alignment", "Offsets", "Memory Layout"]
    },
    {
        file: "06_type_conversion.ahk",
        title: "Type Conversion",
        desc: "Converting Windows API types to AHK types",
        tier: "Beginner",
        concepts: ["Types", "Conversion", "WinAPI"]
    },
    {
        file: "07_simple_struct_complete.ahk",
        title: "Simple Struct Complete",
        desc: "Complete minimal struct implementation",
        tier: "Intermediate",
        concepts: ["Full Example", "OOP", "Buffer"]
    },
    {
        file: "08_nested_structures.ahk",
        title: "Nested Structures",
        desc: "Structs containing other structs",
        tier: "Advanced",
        concepts: ["Nested", "Composition", "Pointers"]
    },
    {
        file: "09_practical_api_usage.ahk",
        title: "Practical API Usage",
        desc: "Real-world RECT struct with GetWindowRect API",
        tier: "Intermediate",
        concepts: ["DllCall", "WinAPI", "Practical"]
    },
    {
        file: "10_platform_comparison.ahk",
        title: "Platform Comparison",
        desc: "32-bit vs 64-bit struct size handling",
        tier: "Advanced",
        concepts: ["Platform", "Pointers", "Cross-platform"]
    }
]

; Create main GUI
CreateLauncherGUI()

CreateLauncherGUI() {
    gui := Gui("+Resize", "Struct.ahk Training Examples")
    gui.SetFont("s10", "Segoe UI")
    gui.MarginX := 15
    gui.MarginY := 15

    ; Title
    gui.SetFont("s14 bold")
    gui.Add("Text", "w600", "📚 Struct.ahk Breakdown Examples")
    gui.SetFont("s10 norm")

    ; Description
    gui.Add("Text", "xm y+10 w600",
        "Learn how the struct.ahk library works through focused, standalone examples.`n"
        "Each example demonstrates a specific concept used in the full library.")

    ; Filter by tier
    gui.Add("Text", "xm y+15", "Filter by Difficulty:")
    tierDDL := gui.Add("DropDownList", "x+10 yp-3 w150", ["All Levels", "Beginner", "Intermediate", "Advanced"])
    tierDDL.Choose(1)
    tierDDL.OnEvent("Change", (*) => UpdateList())

    ; ListView
    gui.Add("Text", "xm y+15", "Examples:")
    lv := gui.Add("ListView", "xm y+5 w600 h350 -Multi", ["#", "Title", "Tier", "Concepts"])
    lv.ModifyCol(1, 40)   ; #
    lv.ModifyCol(2, 250)  ; Title
    lv.ModifyCol(3, 100)  ; Tier
    lv.ModifyCol(4, 180)  ; Concepts

    ; Description box
    gui.Add("Text", "xm y+10", "Description:")
    descEdit := gui.Add("Edit", "xm y+5 w600 h60 ReadOnly -WantReturn")

    ; Buttons
    runBtn := gui.Add("Button", "xm y+10 w140 h35 Default", "▶ Run Example")
    viewBtn := gui.Add("Button", "x+10 yp w140 h35", "📄 View Code")
    gui.Add("Button", "x+10 yp w140 h35", "ℹ About").OnEvent("Click", (*) => ShowAbout())
    gui.Add("Button", "x+10 yp w140 h35", "❌ Close").OnEvent("Click", (*) => ExitApp())

    ; Event handlers
    lv.OnEvent("ItemSelect", (*) => UpdateDescription())
    lv.OnEvent("DoubleClick", (*) => RunExample())
    runBtn.OnEvent("Click", (*) => RunExample())
    viewBtn.OnEvent("Click", (*) => ViewCode())

    ; Store references
    gui.lv := lv
    gui.descEdit := descEdit
    gui.tierDDL := tierDDL

    ; Populate list
    UpdateList()

    ; Show GUI
    gui.Show("w630 h620")

    ; Functions
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

        ; Find example by title
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

        ; Find and run example
        for example in examples {
            if (example.title = title) {
                scriptPath := A_ScriptDir "\" example.file
                if FileExist(scriptPath) {
                    Run('"' A_AhkPath '" "' scriptPath '"')
                } else {
                    MsgBox("File not found: " scriptPath, "Error", "Icon!")
                }
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

        ; Find and open example
        for example in examples {
            if (example.title = title) {
                scriptPath := A_ScriptDir "\" example.file
                if FileExist(scriptPath) {
                    Run('notepad.exe "' scriptPath '"')
                } else {
                    MsgBox("File not found: " scriptPath, "Error", "Icon!")
                }
                break
            }
        }
    }

    ShowAbout(*) {
        MsgBox(
            "Struct.ahk Training Examples`n`n"
            "These standalone examples break down the struct.ahk library`n"
            "into focused learning modules. Each demonstrates a specific`n"
            "technique used in the full implementation.`n`n"
            "Source: struct.ahk by thqby`n"
            "Training examples created for AHK v2 learning`n`n"
            "Total Examples: " examples.Length "`n"
            "Beginner: 3 | Intermediate: 5 | Advanced: 2",
            "About",
            "Icon64"
        )
    }
}

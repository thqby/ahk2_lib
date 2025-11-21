;===============================================================================
; Promise.ahk Breakdown Examples - Launcher GUI
; Browse and run all Promise training examples
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

examples := [
    {
        file: "01_basic_promise.ahk",
        title: "Basic Promise",
        desc: "Create simple promises with resolve and reject",
        tier: "Beginner",
        concepts: ["Promise", "Resolve", "Reject"]
    },
    {
        file: "02_promise_states.ahk",
        title: "Promise States",
        desc: "Understanding pending, fulfilled, and rejected states",
        tier: "Beginner",
        concepts: ["States", "Status", "Lifecycle"]
    },
    {
        file: "03_then_catch_finally.ahk",
        title: "Then/Catch/Finally",
        desc: "Promise chaining and cleanup with then/catch/finally",
        tier: "Beginner",
        concepts: ["Chaining", "Error Handling", "Finally"]
    },
    {
        file: "04_promise_all.ahk",
        title: "Promise.all()",
        desc: "Wait for multiple promises to complete in parallel",
        tier: "Intermediate",
        concepts: ["Parallel", "Multiple", "All"]
    },
    {
        file: "05_promise_race.ahk",
        title: "Promise.race()",
        desc: "Return first promise to settle (fulfill or reject)",
        tier: "Intermediate",
        concepts: ["Race", "First", "Timeout"]
    },
    {
        file: "06_promise_allsettled.ahk",
        title: "Promise.allSettled()",
        desc: "Wait for all promises regardless of success/failure",
        tier: "Intermediate",
        concepts: ["AllSettled", "Mixed Results"]
    },
    {
        file: "07_await_sync.ahk",
        title: "Await Synchronous",
        desc: "Wait synchronously for promise completion",
        tier: "Intermediate",
        concepts: ["Await", "Sync", "Blocking"]
    },
    {
        file: "08_promise_any.ahk",
        title: "Promise.any()",
        desc: "Return first fulfilled promise, reject if all fail",
        tier: "Intermediate",
        concepts: ["Any", "First Success", "Failover"]
    },
    {
        file: "09_with_resolvers.ahk",
        title: "WithResolvers()",
        desc: "Create promise with external resolve/reject control",
        tier: "Advanced",
        concepts: ["Deferred", "Manual Control"]
    },
    {
        file: "10_practical_file_download.ahk",
        title: "Practical Example",
        desc: "Real-world async file download simulation",
        tier: "Intermediate",
        concepts: ["Practical", "Async", "Real-world"]
    }
]

CreateLauncherGUI()

CreateLauncherGUI() {
    gui := Gui("+Resize", "Promise.ahk Training Examples")
    gui.SetFont("s10", "Segoe UI")
    gui.MarginX := 15
    gui.MarginY := 15

    ; Title
    gui.SetFont("s14 bold")
    gui.Add("Text", "w600", "⚡ Promise.ahk Breakdown Examples")
    gui.SetFont("s10 norm")

    ; Description
    gui.Add("Text", "xm y+10 w600",
        "Learn asynchronous programming in AHK v2 through Promise patterns.`n"
        "Each example demonstrates JavaScript-like async/await concepts.")

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
            "Promise.ahk Training Examples`n`n"
            "Learn async programming with JavaScript-style Promises`n"
            "implemented in AutoHotkey v2.`n`n"
            "Source: Promise.ahk by thqby`n"
            "Training examples for AHK v2 async patterns`n`n"
            "Total Examples: " examples.Length "`n"
            "Beginner: 3 | Intermediate: 6 | Advanced: 1`n`n"
            "Concepts Covered:`n"
            "• Promise creation and states`n"
            "• Chaining and error handling`n"
            "• Parallel operations (all, race, any)`n"
            "• Synchronous waiting (await)`n"
            "• Practical async patterns",
            "About",
            "Icon64"
        )
    }
}

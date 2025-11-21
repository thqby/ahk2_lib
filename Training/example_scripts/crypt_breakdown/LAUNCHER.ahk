;===============================================================================
; Crypt.ahk Breakdown Examples - Launcher GUI
; Browse and run all cryptography training examples
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

examples := [
    {file: "01_md5_basic.ahk", title: "MD5 Basic", desc: "Generate MD5 hash of strings and data", tier: "Beginner", concepts: ["MD5", "Hashing", "Checksum"]},
    {file: "02_md5_file.ahk", title: "MD5 File", desc: "Generate MD5 checksum of files", tier: "Beginner", concepts: ["File Hash", "Verification"]},
    {file: "03_hash_types.ahk", title: "Hash Types", desc: "Compare CRC32, MD5, and SHA1 algorithms", tier: "Intermediate", concepts: ["Algorithms", "Comparison"]},
    {file: "04_password_checking.ahk", title: "Password Verification", desc: "Use hashing to verify passwords securely", tier: "Intermediate", concepts: ["Security", "Passwords"]},
    {file: "05_aes_encryption.ahk", title: "AES Encryption", desc: "Encrypt data with AES-256", tier: "Intermediate", concepts: ["AES", "Encryption"]},
    {file: "06_aes_decryption.ahk", title: "AES Decryption", desc: "Encrypt and decrypt data with AES", tier: "Intermediate", concepts: ["Decryption", "Round-trip"]},
    {file: "07_aes_key_sizes.ahk", title: "AES Key Sizes", desc: "Compare AES-128, AES-192, and AES-256", tier: "Intermediate", concepts: ["Key Sizes", "Security Levels"]},
    {file: "08_file_encryption.ahk", title: "File Encryption", desc: "Encrypt and decrypt entire files", tier: "Advanced", concepts: ["File Security", "Practical"]},
    {file: "09_data_integrity.ahk", title: "Data Integrity", desc: "Use hashing to detect data tampering", tier: "Intermediate", concepts: ["Integrity", "Verification"]},
    {file: "10_practical_password_vault.ahk", title: "Password Vault", desc: "Simple password vault implementation", tier: "Advanced", concepts: ["Practical", "Real-world"]}
]

CreateLauncherGUI()

CreateLauncherGUI() {
    gui := Gui("+Resize", "Crypt.ahk Training Examples")
    gui.SetFont("s10", "Segoe UI")
    gui.MarginX := 15
    gui.MarginY := 15

    gui.SetFont("s14 bold")
    gui.Add("Text", "w600", "🔒 Crypt.ahk Breakdown Examples")
    gui.SetFont("s10 norm")

    gui.Add("Text", "xm y+10 w600", "Learn hashing and encryption in AHK v2.`nMD5, SHA1, CRC32 hashing and AES encryption/decryption.")

    gui.Add("Text", "xm y+15", "Filter by Difficulty:")
    tierDDL := gui.Add("DropDownList", "x+10 yp-3 w150", ["All Levels", "Beginner", "Intermediate", "Advanced"])
    tierDDL.Choose(1)
    tierDDL.OnEvent("Change", (*) => UpdateList())

    gui.Add("Text", "xm y+15", "Examples:")
    lv := gui.Add("ListView", "xm y+5 w600 h350 -Multi", ["#", "Title", "Tier", "Concepts"])
    lv.ModifyCol(1, 40)
    lv.ModifyCol(2, 200)
    lv.ModifyCol(3, 100)
    lv.ModifyCol(4, 230)

    gui.Add("Text", "xm y+10", "Description:")
    descEdit := gui.Add("Edit", "xm y+5 w600 h60 ReadOnly -WantReturn")

    runBtn := gui.Add("Button", "xm y+10 w140 h35 Default", "▶ Run Example")
    viewBtn := gui.Add("Button", "x+10 yp w140 h35", "📄 View Code")
    gui.Add("Button", "x+10 yp w140 h35", "ℹ About").OnEvent("Click", (*) => ShowAbout())
    gui.Add("Button", "x+10 yp w140 h35", "❌ Close").OnEvent("Click", (*) => ExitApp())

    lv.OnEvent("ItemSelect", (*) => UpdateDescription())
    lv.OnEvent("DoubleClick", (*) => RunExample())
    runBtn.OnEvent("Click", (*) => RunExample())
    viewBtn.OnEvent("Click", (*) => ViewCode())

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
            "Crypt.ahk Training Examples`n`n"
            "Learn hashing and encryption in AutoHotkey v2.`n`n"
            "Total Examples: " examples.Length "`n"
            "Beginner: 2 | Intermediate: 6 | Advanced: 2`n`n"
            "Concepts Covered:`n"
            "• MD5 and file hashing`n"
            "• CRC32, SHA1 algorithms`n"
            "• Password verification`n"
            "• AES encryption/decryption`n"
            "• Key sizes (128/192/256-bit)`n"
            "• File encryption`n"
            "• Data integrity checking`n"
            "• Practical password vault",
            "About",
            "Icon64"
        )
    }
}

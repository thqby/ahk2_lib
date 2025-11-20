;===============================================================================
; String Parsing with RegEx
; Demonstrates parsing C struct definitions
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

StringParsingExample()

StringParsingExample() {
    ; C struct definition string
    structDef := "
    (
    typedef struct {
        DWORD id;
        int* pValue;
        char name[32];
        unsigned short flags;
    } MyStruct;
    )"

    ; Parse the struct
    result := ""

    ; Remove comments
    structDef := RegExReplace(structDef, '//.*', '')

    ; Replace 'unsigned' with 'U' prefix
    structDef := RegExReplace(structDef, 'i)\bunsigned\s+', 'U')

    ; Extract struct name
    if RegExMatch(structDef, 'struct\s+(\w+)', &m)
        result .= "Struct Name: " m[1] "`n`n"

    ; Split into lines
    lines := StrSplit(structDef, "`n", "`r `t")

    ; Parse each member
    result .= "Members:`n"
    for line in lines {
        ; Match pattern: type [*] name [array]
        if RegExMatch(line, '^\s*(\w+)\s*(\*+)?\s*(\w+)(\[\d+\])?', &m) {
            memberType := m[1] m[2]  ; Type with pointer
            memberName := m[3]        ; Name
            memberArray := m[4]       ; Array size if any

            result .= "  • " memberName " : " memberType memberArray "`n"
        }
    }

    MsgBox(
        "=== String Parsing Demo ===`n`n"
        result "`n"
        "Concepts:`n"
        "• RegExReplace() modifies strings`n"
        "• RegExMatch() extracts patterns`n"
        "• &m captures match groups`n"
        "• m[1], m[2] etc. access groups`n"
        "• StrSplit() breaks into lines",
        "String Parsing"
    )
}

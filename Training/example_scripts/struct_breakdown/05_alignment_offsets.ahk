;===============================================================================
; Memory Alignment and Offsets
; Demonstrates how struct members are aligned in memory
;===============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

AlignmentOffsetsExample()

AlignmentOffsetsExample() {
    ; Type sizes (in bytes)
    types := Map(
        "Char", 1,
        "Short", 2,
        "Int", 4,
        "Double", 8,
        "Ptr", A_PtrSize
    )

    ; Struct member definitions
    members := [
        {name: "flag", type: "Char"},      ; 1 byte
        {name: "count", type: "Int"},      ; 4 bytes
        {name: "value", type: "Double"},   ; 8 bytes
        {name: "pointer", type: "Ptr"}     ; 4 or 8 bytes
    ]

    ; Calculate aligned offsets
    offset := 0
    maxAlign := 0
    result := "Member Layout (with alignment):`n`n"

    for member in members {
        typeSize := types[member.type]
        maxAlign := Max(maxAlign, typeSize)

        ; Align offset to type boundary
        if Mod(offset, typeSize) != 0
            offset := (Integer(offset / typeSize) + 1) * typeSize

        member.offset := offset
        result .= Format("{:-15} {:-8} offset: {:2} (aligned to {}-byte boundary)`n",
                         member.name, member.type, offset, typeSize)

        offset += typeSize
    }

    ; Align total size to largest member
    totalSize := Mod(offset, maxAlign) ? ((Integer(offset / maxAlign) + 1) * maxAlign) : offset

    result .= "`nTotal Size: " totalSize " bytes`n"
    result .= "Max Alignment: " maxAlign " bytes`n`n"

    ; Show what happens without alignment
    result .= "Without alignment (packed):`n"
    packedSize := 0
    for member in members
        packedSize += types[member.type]
    result .= "Packed Size: " packedSize " bytes`n"
    result .= "Wasted Space: " (totalSize - packedSize) " bytes"

    MsgBox(
        "=== Alignment & Offsets Demo ===`n`n"
        result "`n`n"
        "Concepts:`n"
        "• Data must align to type boundaries`n"
        "• Mod() checks alignment`n"
        "• Integer division rounds offset up`n"
        "• Total size aligns to largest member",
        "Alignment & Offsets"
    )
}

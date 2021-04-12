#Include <JSON>
print(i) {
    global A_DebuggerName
    switch (o := '', Type(i)) {
    case 'Map', 'Array', 'Object':
        o := JSON.stringify(i)
    default:
        try o := String(i)
    }
	(IsSet(&A_DebuggerName) && A_DebuggerName) ? OutputDebug(o) : FileAppend(o, '*')
}
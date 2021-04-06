print(i) {
    switch (o := '', Type(i)) {
    case 'Map', 'Array', 'Object':
        o := Yaml(i)
    default:
        try o := String(i)
    }
	(IsSet(A_DebuggerName) && A_DebuggerName) ? OutputDebug(o) : FileAppend(o, '*')
}
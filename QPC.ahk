QPC() {
	static c := 0, f := (DllCall("QueryPerformanceFrequency", "int64*", &c), c /= 1000)
	return (DllCall("QueryPerformanceCounter", "int64*", &c), c / f)
}
findHeap(block) {
	c := 10, n := 0
	while c > n
		c := DllCall('GetProcessHeaps', 'uint', n, 'ptr', heaps := Buffer(A_PtrSize * (n := c)), 'uint')
	if !c
		throw OSError(A_LastError)
	NumPut('short', 1, PROCESS_HEAP_ENTRY := Buffer(3 * A_PtrSize + 16, 0), A_PtrSize + 6)
	loop c {
		if DllCall('HeapValidate', 'ptr', heap := NumGet(heaps, (A_Index - 1) * A_PtrSize, 'ptr'), 'int', 0, 'ptr', block) {
			NumPut('ptr', 0, PROCESS_HEAP_ENTRY)
			if DllCall('HeapWalk', 'ptr', heap, 'ptr', PROCESS_HEAP_ENTRY) {
				lpFirstBlock := NumGet(PROCESS_HEAP_ENTRY, A_PtrSize + 16, 'ptr')
				lpLastBlock := NumGet(PROCESS_HEAP_ENTRY, 2 * A_PtrSize + 16, 'ptr')
				if lpFirstBlock <= block && block < lpLastBlock
					return heap
			}
		}
	}
	return 0
}
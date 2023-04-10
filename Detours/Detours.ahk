/************************************************************************
 * @description Detours is a software package for monitoring and instrumenting API calls on Windows.
 * @file Detours.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 0.0.1
 ***********************************************************************/

DetourTransactionBegin() => DllCall('detours\DetourTransactionBegin')
DetourTransactionAbort() => DllCall('detours\DetourTransactionAbort')
DetourTransactionCommit() => DllCall('detours\DetourTransactionCommit')
DetourTransactionCommitEx(&ppFailedPointer) => DllCall('detours\DetourTransactionCommit', 'ptr*', &ppFailedPointer := 0)
DetourUpdateThread(hThread) => DllCall('detours\DetourUpdateThread', 'ptr', hThread)
DetourAttach(ppPointer, pDetour) => DllCall('detours\DetourAttach', 'ptr', ppPointer, 'ptr', pDetour)
DetourAttachEx(pPointer, pDetour, &pRealTrampoline := 0, &pRealTarget := 0, &pRealDetour := 0) => DllCall('detours\DetourAttachEx', 'ptr*', pPointer, 'ptr', pDetour, 'ptr*', &pRealTrampoline := 0, 'ptr*', &pRealTarget := 0, 'ptr*', &pRealDetour := 0)
DetourDetach(ppPointer, pDetour) => DllCall('detours\DetourDetach', 'ptr', ppPointer, 'ptr', pDetour)
DetourSetIgnoreTooSmall(fIgnore) => DllCall('detours\DetourSetIgnoreTooSmall', 'int', fIgnore)
DetourSetRetainRegions(fRetain) => DllCall('detours\DetourSetRetainRegions', 'int', fRetain)
DetourSetSystemRegionLowerBound(pSystemRegionLowerBound) => DllCall('detours\DetourSetSystemRegionLowerBound', 'ptr', pSystemRegionLowerBound, 'ptr')
DetourSetSystemRegionUpperBound(pSystemRegionUpperBound) => DllCall('detours\DetourSetSystemRegionUpperBound', 'ptr', pSystemRegionUpperBound, 'ptr')
DetourFindFunction(szModule, szFunction) {
	if !(ptr := DllCall('detours\DetourFindFunction', 'astr', szModule, 'astr', szFunction, 'ptr'))
		return ptr
	buf := Buffer(A_PtrSize), NumPut('ptr', ptr, buf), buf.DefineProp('value', {get: (s) => NumGet(s, 'ptr')})
	return buf
}
DetourCodeFromPointer(pPointer, &pGlobals) => DllCall('detours\DetourCodeFromPointer', 'ptr', pPointer, 'ptr*', &pGlobals := 0, 'ptr')
DetourCopyInstruction(pDst, ppDstPool, pSrc, &pTarget, &lExtra) => DllCall('detours\DetourCopyInstruction', 'ptr', pDst, 'ptr', ppDstPool, 'ptr', pSrc, 'ptr*', &pTarget := 0, 'int*', &lExtra := 0, 'ptr')
DetourSetCodeModule(hModule, fLimitReferencesToModule) => DllCall('detours\DetourSetCodeModule', 'ptr', hModule, 'uint', fLimitReferencesToModule)
DetourAllocateRegionWithinJumpBounds(pbTarget, &cbAllocatedSize) => DllCall('detours\DetourAllocateRegionWithinJumpBounds', 'ptr', pbTarget, 'uint*', &cbAllocatedSize := 0, 'ptr')
DetourGetContainingModule(pvAddr) => DllCall('detours\DetourGetContainingModule', 'ptr', pvAddr, 'ptr')
DetourEnumerateModules(hModuleLast) => DllCall('detours\DetourEnumerateModules', 'ptr', hModuleLast, 'ptr')
DetourGetEntryPoint(hModule) => DllCall('detours\DetourGetEntryPoint', 'ptr', hModule, 'ptr')
DetourGetModuleSize(hModule) => DllCall('detours\DetourGetModuleSize', 'ptr', hModule, 'uint')
DetourEnumerateExports(hModule, pContext, pfExport) => DllCall('detours\DetourEnumerateExports', 'ptr', hModule, 'ptr', pContext, 'ptr', pfExport)
DetourEnumerateImports(hModule, pContext, pfImportFile, pfImportFunc) => DllCall('detours\DetourEnumerateImports', 'ptr', hModule, 'ptr', pContext, 'ptr', pfImportFile, 'ptr', pfImportFunc)
DetourEnumerateImportsEx(hModule, pContext, pfImportFile, pfImportFuncEx) => DllCall('detours\DetourEnumerateImportsEx', 'ptr', hModule, 'ptr', pContext, 'ptr', pfImportFile, 'ptr', pfImportFuncEx)
DetourFindPayload(hModule, rguid, &cbData) => DllCall('detours\DetourFindPayload', 'ptr', hModule, 'ptr', rguid, 'uint*', &cbData := 0, 'ptr')
DetourFindPayloadEx(rguid, &cbData) => DllCall('detours\DetourFindPayloadEx', 'ptr', rguid, 'uint*', &cbData := 0, 'ptr')
DetourGetSizeOfPayloads(hModule) => DllCall('detours\DetourGetSizeOfPayloads', 'ptr', hModule)
DetourFreePayload(pvData) => DllCall('detours\DetourFreePayload', 'ptr', pvData)
DetourBinaryOpen(hFile) => DllCall('detours\DetourBinaryOpen', 'ptr', hFile, 'ptr')
DetourBinaryEnumeratePayloads(pBinary, pGuid, &cbData, nIterator) => DllCall('detours\DetourBinaryEnumeratePayloads', 'ptr', pBinary, 'ptr', pGuid, 'uint*', &cbData, 'uint*', &nIterator, 'ptr')
DetourBinaryFindPayload(pBinary, rguid, &cbData) => DllCall('detours\DetourBinaryFindPayload', 'ptr', pBinary, 'ptr', rguid, 'uint*', &cbData := 0, 'ptr')
DetourBinarySetPayload(pBinary, rguid, pData, cbData) => DllCall('detours\DetourBinarySetPayload', 'ptr', pBinary, 'ptr', rguid, 'ptr', pData, 'uint', cbData, 'ptr')
DetourBinaryDeletePayload(pBinary, rguid) => DllCall('detours\DetourBinaryDeletePayload', 'ptr', pBinary, 'ptr', rguid)
DetourBinaryPurgePayloads(pBinary) => DllCall('detours\DetourBinaryPurgePayloads', 'ptr', pBinary)
DetourBinaryResetImports(pBinary) => DllCall('detours\DetourBinaryResetImports', 'ptr', pBinary)
DetourBinaryEditImports(pBinary, pContext, pfByway, pfFile, pfSymbol, pfCommit) => DllCall('detours\DetourBinaryEditImports', 'ptr', pBinary, 'ptr', pContext, 'ptr', pfByway, 'ptr', pfFile, 'ptr', pfSymbol, 'ptr', pfCommit)
DetourBinaryWrite(pBinary, hFile) => DllCall('detours\DetourBinaryWrite', 'ptr', pBinary, 'ptr', hFile)
DetourBinaryClose(pBinary) => DllCall('detours\DetourBinaryClose', 'ptr', pBinary)
DetourFindRemotePayload(hProcess, rguid, &cbData) => DllCall('detours\DetourFindRemotePayload', 'ptr', hProcess, 'ptr', rguid, 'uint*', &cbData := 0, 'ptr')
DetourCreateProcessWithDll(ApplicationName, CommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, CurrentDirectory, lpStartupInfo, lpProcessInformation, DllName, pfCreateProcess := 0) => DllCall('detours\DetourCreateProcessWithDll', 'str', ApplicationName, 'str', CommandLine, 'ptr', lpProcessAttributes, 'ptr', lpThreadAttributes, 'int', bInheritHandles, 'uint', dwCreationFlags, 'ptr', lpEnvironment, 'str', CurrentDirectory, 'ptr', lpStartupInfo, 'ptr*', &lpProcessInformation := 0, 'str', DllName, 'ptr', pfCreateProcess)
DetourCreateProcessWithDllEx(ApplicationName, CommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, CurrentDirectory, lpStartupInfo, lpProcessInformation, DllName, pfCreateProcess := 0) => DllCall('detours\DetourCreateProcessWithDllEx', 'str', ApplicationName, 'str', CommandLine, 'ptr', lpProcessAttributes, 'ptr', lpThreadAttributes, 'int', bInheritHandles, 'uint', dwCreationFlags, 'ptr', lpEnvironment, 'str', CurrentDirectory, 'ptr', lpStartupInfo, 'ptr*', &lpProcessInformation := 0, 'str', DllName, 'ptr', pfCreateProcess)
DetourCreateProcessWithDlls(ApplicationName, CommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, CurrentDirectory, lpStartupInfo, lpProcessInformation, nDlls, rlpDlls, pfCreateProcess := 0) => DllCall('detours\DetourCreateProcessWithDlls', 'str', ApplicationName, 'str', CommandLine, 'ptr', lpProcessAttributes, 'ptr', lpThreadAttributes, 'int', bInheritHandles, 'uint', dwCreationFlags, 'ptr', lpEnvironment, 'str', CurrentDirectory, 'ptr', lpStartupInfo, 'ptr*', &lpProcessInformation := 0, 'uint', nDlls, 'ptr', rlpDlls, 'ptr', pfCreateProcess)
DetourProcessViaHelper(dwTargetPid, DllName, pfCreateProcess := 0) => DllCall('detours\DetourProcessViaHelper', 'uint', dwTargetPid, 'str', DllName, 'ptr', pfCreateProcess)
DetourProcessViaHelperDlls(dwTargetPid, nDlls, rlpDlls, pfCreateProcess := 0) => DllCall('detours\DetourProcessViaHelperDlls', 'uint', dwTargetPid, 'uint', nDlls, 'ptr', rlpDlls, 'ptr', pfCreateProcess)
DetourUpdateProcessWithDll(hProcess, rlpDlls, nDlls) => DllCall('detours\DetourUpdateProcessWithDll', 'ptr', hProcess, 'ptr', rlpDlls, 'uint', nDlls)
DetourUpdateProcessWithDllEx(hProcess, hImage, bIs32Bit, rlpDlls, nDlls) => DllCall('detours\DetourUpdateProcessWithDllEx', 'ptr', hProcess, 'ptr', hImage, 'int', bIs32Bit, 'ptr', rlpDlls, 'uint', nDlls)
DetourCopyPayloadToProcess(hProcess, rguid, pvData, cbData) => DllCall('detours\DetourCopyPayloadToProcess', 'ptr', hProcess, 'ptr', rguid, 'ptr', pvData, 'uint', cbData)
DetourCopyPayloadToProcessEx(hProcess, rguid, pvData, cbData) => DllCall('detours\DetourCopyPayloadToProcessEx', 'ptr', hProcess, 'ptr', rguid, 'ptr', pvData, 'uint', cbData, 'ptr')
DetourRestoreAfterWith() => DllCall('detours\DetourRestoreAfterWith')
DetourRestoreAfterWithEx(pvData, cbData) => DllCall('detours\DetourRestoreAfterWithEx', 'ptr', pvData, 'uint', cbData)
DetourIsHelperProcess() => DllCall('detours\DetourIsHelperProcess')
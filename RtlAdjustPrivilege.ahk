/**
 * 调整当前进程或线程的相应特权(需要管理员权限启动)
 * @param Privilege 需要调整的权限
 * - Se_CreateToken_Privilege 0x2
 * - Se_AssignPrimaryToken_Privilege 0x3
 * - Se_LockMemory_Privilege 0x4
 * - Se_IncreaseQuota_Privilege 0x5
 * - Se_UnsolicitedInput_Privilege 0x0
 * - Se_MachineAccount_Privilege 0x6
 * - Se_Tcb_Privilege 0x7
 * - Se_Security_Privilege 0x8
 * - Se_TakeOwnership_Privilege 0x9
 * - Se_LoadDriver_Privilege 0xa
 * - Se_SystemProfile_Privilege 0xb
 * - Se_Systemtime_Privilege 0xc
 * - Se_ProfileSingleProcess_Privilege 0xd
 * - Se_IncreaseBasePriority_Privilege 0xe
 * - Se_CreatePagefile_Privilege 0xf
 * - Se_CreatePermanent_Privilege 0x10
 * - Se_Backup_Privilege 0x11
 * - Se_Restore_Privilege 0x12
 * - Se_Shutdown_Privilege 0x13
 * - Se_Debug_Privilege 0x14
 * - Se_Audit_Privilege 0x15
 * - Se_SystemEnvironment_Privilege 0x16
 * - Se_ChangeNotify_Privilege 0x17
 * - Se_RemoteShutdown_Privilege 0x18
 * - Se_Undock_Privilege 0x19
 * - Se_SyncAgent_Privilege 0x1a
 * - Se_EnableDelegation_Privilege 0x1b
 * - Se_ManageVolume_Privilege 0x1c
 * - Se_Impersonate_Privilege 0x1d
 * - Se_CreateGlobal_Privilege 0x1e
 * - Se_TrustedCredManAccess_Privilege 0x1f
 * - Se_Relabel_Privilege 0x20
 * - Se_IncreaseWorkingSet_Privilege 0x21
 * - Se_TimeZone_Privilege 0x22
 * - Se_CreateSymbolicLink_Privilege 0x23
 * @param Enable 打开或关闭相应权限
 * @param CurrentThread 如果为True 则仅提升当前线程权限，否则提升整个进程的权限
 * @param Enabled 返回先前是否启用或禁用特权
 * @returns 0: 成功; 非0: 失败 详情见https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55
 */
RtlAdjustPrivilege(Privilege, Enable, CurrentThread := false, &Enabled := 0) => DllCall('ntdll\RtlAdjustPrivilege', 'uint', Privilege, 'int', Enable, 'int', CurrentThread, 'int*', &Enabled := 0, 'uint')
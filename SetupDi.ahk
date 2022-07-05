/************************************************************************
 * @description 设备管理相关WinApi函数，SetDeviceState禁用/启用指定设备实例路径的设备
 * @file SetupDi.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 1.0.2
 ***********************************************************************/

#DllLoad setupapi.dll

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @MemberIndex: UINT, A zero-based index of the device information element to retrieve.
 * @DeviceInfoData: Ptr or Buffer Object, A pointer to an SP_DEVINFO_DATA structure
 * DeviceInfoData:=Buffer(A_PtrSize=8?32:28, 0), NumPut("UInt", SP_DEVINFO_DATA.Size, SP_DEVINFO_DATA, 0)
 * @return value: UInt, TRUE if it is successful. Otherwise, it returns FALSE
 */
SetupDiEnumDeviceInfo(DeviceInfoSet, MemberIndex, DeviceInfoData) => DllCall("setupapi\SetupDiEnumDeviceInfo", "Ptr", DeviceInfoSet, "UInt", MemberIndex, "Ptr", DeviceInfoData, "Int")

/*
 * @ClassGuid: Buffer Object, ClassGuid:=Buffer(16), DllCall("ole32\CLSIDFromString", "WStr", GuidStr, "Ptr", ClassGuid)
 * @Enumerator: String, Flags |= 0x14 when Enumerator is Device Instance ID
 * @Flags: UInt, DIGCF_DEFAULT = 0x1; DIGCF_PRESENT = 0x2; DIGCF_ALLCLASSES = 0x4; DIGCF_PROFILE = 0x8; DIGCF_DEVICEINTERFACE = 0x10
 * @hwndParent: Ptr, A handle to the top-level window to be used for a user interface that is associated with installing a device instance in the device information set.
 * @return value: a handle to a device information set if it is successful. Otherwise, it returns INVALID_HANDLE_VALUE = ((HANDLE)(LONG_PTR)-1)
 */
SetupDiGetClassDevs(ClassGuid := 0, Enumerator := 0, hwndParent := 0, Flags := 0x4) => DllCall("setupapi\SetupDiGetClassDevs", "Ptr", ClassGuid, "Ptr", IsInteger(Enumerator) ? Integer(Enumerator) : StrPtr(Enumerator), "Ptr", hwndParent, "UInt", Flags, "Ptr")

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @DeviceInfoData: Ptr or Buffer Object, A pointer to the SP_DEVINFO_DATA structure
 * @PropertyKey: Ptr or Buffer Object, A pointer to a DEVPROPKEY structure
 * @return value: String or throw a Error
 */
SetupDiGetDeviceProperty(DeviceInfoSet, DeviceInfoData, PropertyKey) {
	if (!DllCall("setupapi\SetupDiGetDevicePropertyW", "Ptr", DeviceInfoSet, "Ptr", DeviceInfoData, "Ptr", PropertyKey, "UInt*", &PropertyType := 0, "Ptr", 0, "UInt", 0, "UInt*", &RequiredSize := 0, "UInt", 0) && A_LastError == 0x7A) {
		DllCall("setupapi\SetupDiGetDevicePropertyW", "Ptr", DeviceInfoSet, "Ptr", DeviceInfoData, "Ptr", PropertyKey, "UInt*", &PropertyType := 0, "Ptr", PropertyBuffer := Buffer(RequiredSize), "UInt", RequiredSize, "Ptr", 0, "UInt", 0)
		switch PropertyType
		{
			case 0x07, 0x11:	; DEVPROP_TYPE_UINT32, DEVPROP_TYPE_BOOLEAN
				return NumGet(PropertyBuffer, "UInt")
			case 0x09:	; DEVPROP_TYPE_UINT64
				return NumGet(PropertyBuffer, "Int64")
			case 0x10:	; DEVPROP_TYPE_FILETIME
			case 0x0d:	; DEVPROP_TYPE_GUID
				return (VarSetStrCapacity(&Property, 80), DllCall("ole32\StringFromGUID2", "Ptr", PropertyBuffer, "Str", Property, "Int", 80), Property)
			case 0x13:	; DEVPROP_TYPE_SECURITY_DESCRIPTOR
			case 0x14:	; DEVPROP_TYPE_SECURITY_DESCRIPTOR_STRING
			case 0x18:	; DEVPROP_TYPE_NTSTATUS
			case 18:	; DEVPROP_TYPE_STRING
				return StrGet(PropertyBuffer, "UTF-16")
			case 0x2012:	; DEVPROP_TYPE_STRING_LIST
				ads := PropertyBuffer.Ptr, Property := ""
				while ("" != subpro := StrGet(ads + 0, "UTF-16"))
					Property .= "`n" subpro, ads += (StrLen(subpro) + 1) * 2
				return LTrim(Property, "`n")
			default:
				return
		}
	}
}

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @DeviceInfoData: Ptr or Buffer Object, A pointer to the SP_DEVINFO_DATA structure
 * @return value: String or throw a Error
 */
SetupDiGetDeviceInstanceId(DeviceInfoSet, DeviceInfoData) => DllCall("setupapi\SetupDiGetDeviceInstanceIdW", "Ptr", DeviceInfoSet, "Ptr", DeviceInfoData, "Ptr", DeviceInstanceId := Buffer(200), "UInt", 200, "UInt", 0) ? StrGet(DeviceInstanceId, "UTF-16") : ""

/*
 * @include file: devpkey.h
 * @PropertyKey: String, eg. Device_DeviceDesc, Device_HardwareIds
 * @return value: Buffer Object, A DEVPROPKEY structure
 */
DEVPROPKEY(PropertyKey) {
	static DEVPKEY := Map(
		"{b725f130-47ef-101a-a5f1-02608c9eebac}", [["NAME", 10]],
		"{a45c254e-df1c-4efd-8020-67d146a850e0}", [["Device_DeviceDesc", 2], ["Device_HardwareIds", 3], ["Device_CompatibleIds", 4], ["Device_Service", 6], ["Device_Class", 9], ["Device_ClassGuid", 10], ["Device_Driver", 11], ["Device_ConfigFlags", 12], ["Device_Manufacturer", 13], ["Device_FriendlyName", 14], ["Device_LocationInfo", 15], ["Device_PDOName", 16], ["Device_Capabilities", 17], ["Device_UINumber", 18], ["Device_UpperFilters", 19], ["Device_LowerFilters", 20], ["Device_BusTypeGuid", 21], ["Device_LegacyBusType", 22], ["Device_BusNumber", 23], ["Device_EnumeratorName", 24], ["Device_Security", 25], ["Device_SecuritySDS", 26], ["Device_DevType", 27], ["Device_Exclusive", 28], ["Device_Characteristics", 29], ["Device_Address", 30], ["Device_UINumberDescFormat", 31], ["Device_PowerData", 32], ["Device_RemovalPolicy", 33], ["Device_RemovalPolicyDefault", 34], ["Device_RemovalPolicyOverride", 35], ["Device_InstallState", 36], ["Device_LocationPaths", 37], ["Device_BaseContainerId", 38]],
		"{78c34fc8-104a-4aca-9ea4-524d52996e57}", [["Device_InstanceId", 256]],
		"{4340a6c5-93fa-4706-972c-7b648008a5a7}", [["Device_DevNodeStatus", 2], ["Device_ProblemCode", 3], ["Device_EjectionRelations", 4], ["Device_RemovalRelations", 5], ["Device_PowerRelations", 6], ["Device_BusRelations", 7], ["Device_Parent", 8], ["Device_Children", 9], ["Device_Siblings", 10], ["Device_TransportRelations", 11], ["Device_ProblemStatus", 12]],
		"{80497100-8c73-48b9-aad9-ce387e19c56e}", [["Device_Reported", 2], ["Device_Legacy", 3]],
		"{8c7ed206-3f8a-4827-b3ab-ae9e1faefc6c}", [["Device_ContainerId", 2], ["Device_InLocalMachineContainer", 4]],
		"{78c34fc8-104a-4aca-9ea4-524d52996e57}", [["Device_Model", 39]],
		"{80d81ea6-7473-4b0c-8216-efc11a2c4c8b}", [["Device_ModelId", 2], ["Device_FriendlyNameAttributes", 3], ["Device_ManufacturerAttributes", 4], ["Device_PresenceNotForDevice", 5], ["Device_SignalStrength", 6], ["Device_IsAssociateableByUserAction", 7], ["Device_ShowInUninstallUI", 8]],
		"{540b947e-8b40-45bc-a8a2-6a0b894cbda2}", [["Device_Numa_Proximity_Domain", 1], ["Device_DHP_Rebalance_Policy", 2], ["Device_Numa_Node", 3], ["Device_BusReportedDeviceDesc", 4], ["Device_IsPresent", 5], ["Device_HasProblem", 6], ["Device_ConfigurationId", 7], ["Device_ReportedDeviceIdsHash", 8], ["Device_PhysicalDeviceLocation", 9], ["Device_BiosDeviceName", 10], ["Device_DriverProblemDesc", 11], ["Device_DebuggerSafe", 12], ["Device_PostInstallInProgress", 13], ["Device_Stack", 14], ["Device_ExtendedConfigurationIds", 15], ["Device_IsRebootRequired", 16], ["Device_FirmwareDate", 17], ["Device_FirmwareVersion", 18], ["Device_FirmwareRevision", 19], ["Device_DependencyProviders", 20], ["Device_DependencyDependents", 21], ["Device_SoftRestartSupported", 22], ["Device_ExtendedAddress", 23]],
		"{83da6326-97a6-4088-9453-a1923f573b29}", [["Device_SessionId", 6], ["Device_InstallDate", 100], ["Device_FirstInstallDate", 101], ["Device_LastArrivalDate", 102], ["Device_LastRemovalDate", 103]],
		"{afd97640-86a3-4210-b67c-289c41aabe55}", [["Device_SafeRemovalRequired", 2], ["Device_SafeRemovalRequiredOverride", 3]],
		"{cf73bb51-3abf-44a2-85e0-9a3dc7a12132}", [["DrvPkg_Model", 2], ["DrvPkg_VendorWebSite", 3], ["DrvPkg_DetailedDescription", 4], ["DrvPkg_DocumentationLink", 5], ["DrvPkg_Icon", 6], ["DrvPkg_BrandingIcon", 7]],
		"{4321918b-f69e-470d-a5de-4d88c75ad24b}", [["DeviceClass_UpperFilters", 19], ["DeviceClass_LowerFilters", 20], ["DeviceClass_Security", 25], ["DeviceClass_SecuritySDS", 26], ["DeviceClass_DevType", 27], ["DeviceClass_Exclusive", 28], ["DeviceClass_Characteristics", 29]],
		"{d14d3ef3-66cf-4ba2-9d38-0ddb37ab4701}", [["DeviceClass_DHPRebalanceOptOut", 2]],
		"{713d1703-a2e2-49f5-9214-56472ef3da5c}", [["DeviceClass_ClassCoInstallers", 2]],
		"{026e516e-b814-414b-83cd-856d6fef4822}", [["DeviceInterface_FriendlyName", 2], ["DeviceInterface_Enabled", 3], ["DeviceInterface_ClassGuid", 4], ["DeviceInterface_ReferenceString", 5], ["DeviceInterface_Restricted", 6], ["DeviceInterface_UnrestrictedAppCapabilities", 8], ["DeviceInterface_SchematicName", 9]],
		"{14c83a99-0b3f-44b7-be4c-a178d3990564}", [["DeviceInterfaceClass_DefaultInterface", 2], ["DeviceInterfaceClass_Name", 3]],
		"{78c34fc8-104a-4aca-9ea4-524d52996e57}", [["Devicecontainer_Address", 51], ["Devicecontainer_DiscoveryMethod", 52], ["Devicecontainer_IsEncrypted", 53], ["Devicecontainer_IsAuthenticated", 54], ["Devicecontainer_IsConnected", 55], ["Devicecontainer_IsPaired", 56], ["Devicecontainer_Icon", 57], ["Devicecontainer_Version", 65], ["Devicecontainer_Last_Seen", 66], ["Devicecontainer_Last_Connected", 67], ["Devicecontainer_IsShowInDisconnectedState", 68], ["Devicecontainer_IsLocalMachine", 70], ["Devicecontainer_MetadataPath", 71], ["Devicecontainer_IsMetadataSearchInProgress", 72], ["Devicecontainer_MetadataChecksum", 73], ["Devicecontainer_IsNotInterestingForDisplay", 74], ["Devicecontainer_LaunchDeviceStageOnDeviceConnect", 76], ["Devicecontainer_LaunchDeviceStageFromExplorer", 77], ["Devicecontainer_BaselineExperienceId", 78], ["Devicecontainer_IsDeviceUniquelyIdentifiable", 79], ["Devicecontainer_AssociationArray", 80], ["Devicecontainer_DeviceDescription1", 81], ["Devicecontainer_DeviceDescription2", 82], ["Devicecontainer_HasProblem", 83], ["Devicecontainer_IsSharedDevice", 84], ["Devicecontainer_IsNetworkDevice", 85], ["Devicecontainer_IsDefaultDevice", 86], ["Devicecontainer_MetadataCabinet", 87], ["Devicecontainer_RequiresPairingElevation", 88], ["Devicecontainer_ExperienceId", 89], ["Devicecontainer_Category", 90], ["Devicecontainer_Category_Desc_Singular", 91], ["Devicecontainer_Category_Desc_Plural", 92], ["Devicecontainer_Category_Icon", 93], ["Devicecontainer_CategoryGroup_Desc", 94], ["Devicecontainer_CategoryGroup_Icon", 95], ["Devicecontainer_PrimaryCategory", 97], ["Devicecontainer_UnpairUninstall", 98], ["Devicecontainer_RequiresUninstallElevation", 99], ["Devicecontainer_DeviceFunctionSubRank", 100], ["Devicecontainer_AlwaysShowDeviceAsConnected", 101], ["Devicecontainer_ConfigFlags", 105], ["Devicecontainer_PrivilegedPackageFamilyNames", 106], ["Devicecontainer_CustomPrivilegedPackageFamilyNames", 107], ["Devicecontainer_IsRebootRequired", 108]],
		"{656a3bb3-ecc0-43fd-8477-4ae0404a96cd}", [["DeviceContainer_FriendlyName", 12288], ["DeviceContainer_Manufacturer", 8192], ["DeviceContainer_ModelName", 8194], ["DeviceContainer_ModelNumber", 8195]],
		"{83da6326-97a6-4088-9453-a1923f573b29}", [["Devicecontainer_InstallInProgress", 9]],
		"{13673f42-a3d6-49f6-b4da-ae46e0c5237c}", [["DevQuery_ObjectType", 2]]
	)
	PropertyKey := StrReplace(PropertyKey, "DEVPKEY_")
	for guid, arr in DEVPKEY
		for sarr in arr
			if InStr(sarr[1], PropertyKey)
				return (DllCall("ole32\CLSIDFromString", "Str", guid, "Ptr", PropertyKey := Buffer(20)), NumPut("UInt", sarr[2], PropertyKey, 16), PropertyKey)
	throw Error("invalid DEVPKEY")
}

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @DeviceInfoData: Ptr or Buffer Object, A pointer to the SP_DEVINFO_DATA structure
 * @ClassInstallParams: Ptr or Buffer Object, A pointer to a SP_CLASSINSTALL_HEADER structure
 * @return value: UInt, TRUE if it is successful. Otherwise, it returns FALSE
 */
SetupDiSetClassInstallParams(DeviceInfoSet, DeviceInfoData, ClassInstallParams) => DllCall("setupapi\SetupDiSetClassInstallParamsW", "Ptr", DeviceInfoSet, "Ptr", DeviceInfoData, "Ptr", ClassInstallParams, "UInt", 20, "Int")

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @DeviceInfoData: Ptr or Buffer Object, A pointer to the SP_DEVINFO_DATA structure
 * @return value: UInt, TRUE if it is successful. Otherwise, it returns FALSE
 */
SetupDiChangeState(DeviceInfoSet, DeviceInfoData) => DllCall("setupapi\SetupDiChangeState", "Ptr", DeviceInfoSet, "Ptr", DeviceInfoData, "Int")

/*
 * @DeviceInfoSet: Ptr, A handle to a device information set
 * @return value: UInt, TRUE if it is successful. Otherwise, it returns FALSE
 */
SetupDiDestroyDeviceInfoList(DeviceInfoSet) => DllCall("setupapi\SetupDiDestroyDeviceInfoList", "Ptr", DeviceInfoSet, "Int")

SetupDiEnumDeviceInterfaces(DeviceInfoSet, DeviceInfoData, InterfaceClassGuid, MemberIndex, DeviceInterfaceData) => DllCall("setupapi\SetupDiEnumDeviceInterfaces", "Ptr", DeviceInfoSet, "ptr", DeviceInfoData, "Ptr", InterfaceClassGuid, "UInt", MemberIndex, "Ptr", DeviceInterfaceData, "Int")

SetupDiGetDeviceInterfaceDetail(DeviceInfoSet, DeviceInterfaceData, DeviceInfoData := 0) {
	DeviceInterfaceDetailData := Buffer(1024, 0), NumPut("UInt", A_PtrSize = 8 ? 8 : 6, DeviceInterfaceDetailData)
	if !DllCall("setupapi\SetupDiGetDeviceInterfaceDetail", "Ptr", DeviceInfoSet, "Ptr", DeviceInterfaceData, "Ptr", DeviceInterfaceDetailData, "UInt", 1024, "Ptr", 0, "Ptr", DeviceInfoData)
		throw OSError(A_LastError)
	return DeviceInterfaceDetailData
}

/*
 * @DeviceInstanceID: String, A Device Instance ID, eg. HID\DELL0824&COL02\5&3AE7DB47&0&0001
 * @Enable: BOOL
 * @return value: Int, TRUE if it is successful. Otherwise, it returns FALSE
 */
SetDeviceState(DeviceInstanceID, Enable := true) {
	hDevInfo := SetupDiGetClassDevs(0, DeviceInstanceID, 0, 0x14)
	if (hDevInfo = -1)
		return false
	DeviceInfoData := Buffer(A_PtrSize = 8 ? 32 : 28, 0), NumPut("UInt", DeviceInfoData.Size, DeviceInfoData, 0)
	PropChangeParams := Buffer(20, 0)
	NumPut("UInt", 8,	; PropChangeParams.ClassInstallHeader.cbSize = sizeof(SP_CLASSINSTALL_HEADER)
		"UInt", 0x12,	; PropChangeParams.ClassInstallHeader.InstallFunction = DIF_PROPERTYCHANGE
		"UInt", (Enable ? 1 : 2),	; PropChangeParams.StateChange = Enable ? DICS_ENABLE : DICS_DISABLE
		"UInt", 1,	; PropChangeParams.Scope = DICS_FLAG_GLOBAL
		PropChangeParams, 0)
	ret := SetupDiEnumDeviceInfo(hDevInfo, 0, DeviceInfoData)
		&& SetupDiSetClassInstallParams(hDevInfo, DeviceInfoData, PropChangeParams)
		&& SetupDiChangeState(hDevInfo, DeviceInfoData)
	SetupDiDestroyDeviceInfoList(hDevInfo)
	if !(ret || A_IsAdmin)
		throw Error("this script requires administrator privileges!")
	return ret
}

; @return value: Int, Touchpad Device Instance ID
GetTouchpadDeviceInstanceID() {
	DllCall("ole32\CLSIDFromString", "Str", "{745a17a0-74d3-11d0-b6fe-00a0c90f57da}", "Ptr", HIDGUID := Buffer(16))
	hDevInfo := SetupDiGetClassDevs(HIDGUID, 0, 0, 2), InstanceId := ""
	if (hDevInfo = -1)
		throw Error("GetClassDevs Fail")
	DeviceInfoData := Buffer(A_PtrSize = 8 ? 32 : 28, 0), NumPut("UInt", DeviceInfoData.Size, DeviceInfoData, 0)
	Device_DeviceDesc := DEVPROPKEY("Device_DeviceDesc")
	touchpad := A_Language = "0804" ? "触摸板" : "touch pad"
	while SetupDiEnumDeviceInfo(hDevInfo, A_Index - 1, DeviceInfoData) {
		if InStr(SetupDiGetDeviceProperty(hDevInfo, DeviceInfoData, Device_DeviceDesc), touchpad)
			return (InstanceId := SetupDiGetDeviceInstanceId(hDevInfo, DeviceInfoData), SetupDiDestroyDeviceInfoList(hDevInfo), InstanceId)
	}
	SetupDiDestroyDeviceInfoList(hDevInfo)
}

; if (!A_IsAdmin)
; 	Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'), ExitApp()
; TouchpadDeviceInstanceID:=GetTouchpadDeviceInstanceID()
; DeviceInfoData:=Buffer(A_PtrSize=8?32:28, 0), NumPut("UInt", DeviceInfoData.Size, DeviceInfoData, 0)
; hDevInfo:=SetupDiGetClassDevs(0, TouchpadDeviceInstanceID, 0, 0x14), SetupDiEnumDeviceInfo(hDevInfo, 0, DeviceInfoData)
; MsgBox SetupDiGetDeviceProperty(hDevInfo, DeviceInfoData, Device_DeviceDesc:=DEVPROPKEY("Device_DeviceDesc"))
; MsgBox SetupDiGetDeviceProperty(hDevInfo, DeviceInfoData, Device_HardwareIds:=DEVPROPKEY("Device_HardwareIds"))
; SetDeviceState(TouchpadDeviceInstanceID, false)
; Sleep(4000)
; SetDeviceState(TouchpadDeviceInstanceID, true)
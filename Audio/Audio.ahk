/************************************************************************
 * @file: Audio.ahk
 * @description: Core Audio APIs, Windows 多媒体设备API
 * @author thqby
 * @date 2022/02/09
 * @version 1.0.12
 ***********************************************************************/
; https://docs.microsoft.com/en-us/windows/win32/api/unknwn/nn-unknwn-iunknown
class IAudioBase {
	static IID := "{00000000-0000-0000-C000-000000000046}"
	Ptr := 0
	__New(ptr) {
		if IsObject(ptr)
			this.Ptr := ComObjValue(ptr), this.AddRef()
		else this.Ptr := ptr
	}
	__Delete() => this.Release()
	AddRef() => ObjAddRef(this.Ptr)
	Release() => (this.Ptr ? ObjRelease(this.Ptr) : 0)
	QueryInterface(riid) => (HasBase(riid, IAudioBase) ? riid(ComObjQuery(this, riid.IID)) : ComObjQuery(this, riid))

	static STR(ptr) {
		static _ := DllCall("LoadLibrary", "str", "ole32.dll")
		if ptr {
			s := StrGet(ptr), DllCall("ole32\CoTaskMemFree", "ptr", ptr)
			return s
		}
	}
}

;; audioclient.h header

; https://docs.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-ichannelaudiovolume
class IChannelAudioVolume extends IAudioBase {
	static IID := "{1C158861-B533-4B30-B1CF-E853E51C59B8}"
	GetChannelCount() => (ComCall(3, this, "UInt*", &dwCount := 0), dwCount)
	SetChannelVolume(dwIndex, fLevel, EventContext := 0) => ComCall(4, this, "UInt", dwIndex, "Float", fLevel, "Ptr", EventContext)
	GetChannelVolume(dwIndex) => (ComCall(5, this, "UInt", dwIndex, "Float*", &fLevel := 0), fLevel)
	SetAllVolumes(dwCount, pfVolumes, EventContext := 0) => ComCall(4, this, "UInt", dwCount, "Ptr", pfVolumes, "Ptr", EventContext)
	GetAllVolumes(dwCount) => (ComCall(5, this, "UInt", dwCount, "Ptr*", &pfVolumes := 0), pfVolumes)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-isimpleaudiovolume
class ISimpleAudioVolume extends IAudioBase {
	static IID := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
	SetMasterVolume(fLevel, EventContext := 0) => ComCall(3, this, "Float", fLevel, "Ptr", EventContext)
	GetMasterVolume() => (ComCall(4, this, "Float*", &fLevel := 0), fLevel)
	SetMute(bMute, EventContext := 0) => ComCall(5, this, "Int", bMute, "Ptr", EventContext)
	GetMute() => (ComCall(6, this, "Int*", &bMute := 0), bMute)
}

;; mmdeviceapi.h header

; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-iactivateaudiointerfaceasyncoperation
class IActivateAudioInterfaceAsyncOperation extends IAudioBase {
	static IID := "{72A22D78-CDE4-431D-B8CC-843A71199B6D}"
	GetActivateResult(&activateResult, &activatedInterface) => ComCall(3, this, "Int*", &activateResult := 0, "Ptr*", &activatedInterface := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-iactivateaudiointerfacecompletionhandler
class IActivateAudioInterfaceCompletionHandler extends IAudioBase {
	static IID := "{41D949AB-9862-444A-80F6-C261334DA5EB}"
	ActivateCompleted(activateOperation) => ComCall(3, this, "Ptr", activateOperation)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevice
class IMMDevice extends IAudioBase {
	static IID := "{D666063F-1587-4E43-81F1-B948E807363F}"
	Activate(iidorclass, dwClsCtx := 23, pActivationParams := 0) {
		DllCall("ole32\CLSIDFromString", "Str", HasBase(iidorclass, IAudioBase) ? iidorclass.IID : iidorclass, "Ptr", pCLSID := Buffer(16))
		ComCall(3, this, "Ptr", pCLSID, "UInt", dwClsCtx, "Ptr", pActivationParams, "Ptr*", &pInterface := 0)
		return HasBase(iidorclass, IAudioBase) ? iidorclass(pInterface) : ComValue(0xd, pInterface)
	}
	OpenPropertyStore(stgmAccess) => (ComCall(4, this, "UInt", stgmAccess, "Ptr*", &pProperties := 0), pProperties)
	GetId() => (ComCall(5, this, "Ptr*", &strId := 0), IAudioBase.STR(strId))
	GetState() => (ComCall(6, this, "UInt*", &dwState := 0), dwState)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevicecollection
class IMMDeviceCollection extends IAudioBase {
	static IID := "{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}"
	GetCount() => (ComCall(3, this, "UInt*", &cDevices := 0), cDevices)
	Item(nDevice) => (ComCall(4, this, "UInt", nDevice, "Ptr*", &pDevice := 0), IMMDevice(pDevice))
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator
class IMMDeviceEnumerator extends IAudioBase {
	static IID := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
	__New() => (this.Ptr := ComObjValue(ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")), this.AddRef())

	/*
	 * EDataFlow: eRender 0, eCapture 1, eAll 2, EDataFlow_enum_count 3
	 * ERole: eConsole 0, eMultimedia 1, eCommunications 2, ERole_enum_count 3
	 * StateMask: DEVICE_STATE_ACTIVE 1, DEVICE_STATE_DISABLED 2, DEVICE_STATE_NOTPRESENT 4, DEVICE_STATE_UNPLUGGED 8, DEVICE_STATEMASK_ALL 0xf
	 * EndpointFormFactor: RemoteNetworkDevice 0, Speakers 1, LineLevel 2, Headphones 3, Microphone 4, Headset 5, Handset 6, UnknownDigitalPassthrough 7, SPDIF 8, DigitalAudioDisplayDevice 9, UnknownFormFactor 10, EndpointFormFactor_enum_count 11
	 */
	EnumAudioEndpoints(dataFlow := 0, dwStateMask := 1) => (ComCall(3, this, "Int", dataFlow, "UInt", dwStateMask, "Ptr*", &pDevices := 0), IMMDeviceCollection(pDevices))
	GetDefaultAudioEndpoint(dataFlow := 0, role := 0) => (ComCall(4, this, "Int", dataFlow, "UInt", role, "Ptr*", &pEndpoint := 0), IMMDevice(pEndpoint))
	GetDevice(pwstrId) => (ComCall(5, this, "Str", pwstrId, "Ptr*", &pEndpoint := 0), IMMDevice(pEndpoint))
	RegisterEndpointNotificationCallback(pClient) => ComCall(6, this, "Ptr", pClient)
	UnregisterEndpointNotificationCallback(pClient) => ComCall(7, this, "Ptr", pClient)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immendpoint
class IMMEndpoint extends IAudioBase {
	static IID := "{1BE09788-6894-4089-8586-9A2A6C265AC5}"
	GetDataFlow() => (ComCall(3, this, "UInt*", &DataFlow := 0), DataFlow)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immnotificationclient
/*
class IMMNotificationClient extends IAudioBase {
	static IID := "{7991EEC9-7E89-4D85-8390-6C703CEC60C0}"
	OnDeviceStateChanged(pwstrDeviceId, dwNewState) => ComCall(3, this, "Str", pwstrDeviceId, "UInt", dwNewState)
	OnDeviceAdded(pwstrDeviceId) => ComCall(4, this, "Str", pwstrDeviceId)
	OnDeviceRemoved(pwstrDeviceId) => ComCall(5, this, "Str", pwstrDeviceId)
	OnDefaultDeviceChanged(flow, role, pwstrDefaultDeviceId) => ComCall(6, this, "UInt", flow, "UInt", role, "Str", pwstrDefaultDeviceId)
	OnPropertyValueChanged(pwstrDeviceId, key) => ComCall(6, this, "Str", pwstrDeviceId, "Ptr", key)
}
 */

;; audiopolicy.h header

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol
class IAudioSessionControl extends IAudioBase {
	static IID := "{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}"
	; AudioSessionState: AudioSessionStateInactive 0, AudioSessionStateActive 1, AudioSessionStateExpired 2
	GetState() => (ComCall(3, this, "UInt*", &RetVal := 0), RetVal)
	GetDisplayName() => (ComCall(4, this, "Ptr*", &RetVal := 0), IAudioBase.STR(RetVal))
	SetDisplayName(Value, EventContext := 0) => ComCall(5, this, "Str", Value, "Ptr", EventContext)
	GetIconPath() => (ComCall(6, this, "Ptr*", &RetVal := ""), IAudioBase.STR(RetVal))
	SetIconPath(Value, EventContext := 0) => ComCall(7, this, "Str", Value, "Ptr", EventContext)
	GetGroupingParam() {
		ComCall(8, this, "Ptr", pRetVal := Buffer(16))
		return pRetVal
	}
	SetGroupingParam(Override, EventContext := 0) => ComCall(9, this, "Ptr", Override, "Ptr", EventContext)
	RegisterAudioSessionNotification(NewNotifications) => ComCall(10, this, "Ptr", NewNotifications)
	UnregisterAudioSessionNotification(NewNotifications) => ComCall(11, this, "Ptr", NewNotifications)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol2
class IAudioSessionControl2 extends IAudioSessionControl {
	static IID := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
	GetSessionIdentifier() => (ComCall(12, this, "Ptr*", &RetVal := 0), IAudioBase.STR(RetVal))
	GetSessionInstanceIdentifier() => (ComCall(13, this, "Ptr*", &RetVal := 0), IAudioBase.STR(RetVal))
	GetProcessId() => (ComCall(14, this, "UInt*", &RetVal := 0), RetVal)
	IsSystemSoundsSession() => ComCall(15, this)
	SetDuckingPreference(optOut) => ComCall(16, this, "Int", optOut)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionenumerator
class IAudioSessionEnumerator extends IAudioBase {
	static IID := "{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}"
	GetCount() => (ComCall(3, this, "Int*", &SessionCount := 0), SessionCount)
	GetSession(SessionCount) => (ComCall(4, this, "Int", SessionCount, "Ptr*", &Session := 0), IAudioSessionControl(Session))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionevents
/*
class IAudioSessionEvents extends IAudioBase {
	static IID := "{24918ACC-64B3-37C1-8CA9-74A66E9957A8}"
	OnDisplayNameChanged(NewDisplayName, EventContext) => ComCall(3, this, "Str", NewDisplayName, "Ptr", EventContext)
	OnIconPathChanged(NewIconPath, EventContext) => ComCall(4, this, "Str", NewIconPath, "Ptr", EventContext)
	OnSimpleVolumeChanged(NewVolume, NewMute, EventContext) => ComCall(5, this, "Float", NewVolume, "Int", NewMute, "Ptr", EventContext)
	OnChannelVolumeChanged(ChannelCount, NewChannelVolumeArray, ChangedChannel, EventContext) => ComCall(6, this, "UInt", ChannelCount, "Ptr", NewChannelVolumeArray, "UInt", ChangedChannel, "Ptr", EventContext)
	OnGroupingParamChanged(NewGroupingParam, EventContext) => ComCall(7, this, "Ptr", NewGroupingParam, "Ptr", EventContext)
	OnStateChanged(NewState) => ComCall(8, this, "UInt", NewState)
	OnSessionDisconnected(DisconnectReason) => ComCall(9, this, "UInt", DisconnectReason)
}
 */

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager
class IAudioSessionManager extends IAudioBase {
	static IID := "{BFA971F1-4D5E-40BB-935E-967039BFBEE4}"
	GetAudioSessionControl(AudioSessionGuid, StreamFlags) => (ComCall(3, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &SessionControl := 0), IAudioSessionControl(SessionControl))
	GetSimpleAudioVolume(AudioSessionGuid, StreamFlags) => (ComCall(4, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &AudioVolume := 0), ISimpleAudioVolume(AudioVolume))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager2
class IAudioSessionManager2 extends IAudioSessionManager {
	static IID := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
	GetSessionEnumerator() => (ComCall(5, this, "Ptr*", &SessionEnum := 0), IAudioSessionEnumerator(SessionEnum))
	RegisterSessionNotification(SessionNotification) => ComCall(6, this, "Ptr", SessionNotification)
	UnregisterSessionNotification(SessionNotification) => ComCall(7, this, "Ptr", SessionNotification)
	RegisterDuckNotification(sessionID, duckNotification) => ComCall(8, this, "Str", sessionID, "Ptr", duckNotification)
	UnregisterDuckNotification(duckNotification) => ComCall(9, this, "Ptr", duckNotification)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionnotification
/*
class IAudioSessionNotification extends IAudioBase {
	static IID := "{641DD20B-4D41-49CC-ABA3-174B9477BB08}"
	OnSessionCreated(&NewSession := 0) => (ComCall(3, this, "Ptr*", &NewSession := 0), IAudioSessionControl(NewSession, this))
}
 */

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiovolumeducknotification
/*
class IAudioVolumeDuckNotification extends IAudioBase {
	static IID := "{C3B284D4-6D39-4359-B3CF-B56DDB3BB39C}"
	OnVolumeDuckNotification(sessionID, countCommunicationSessions) => ComCall(3, this, "Str", sessionID, "UInt", countCommunicationSessions)
	OnVolumeUnduckNotification(sessionID) => ComCall(4, this, "Str", sessionID)
}
 */

;; endpointvolume.h header

; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolume
class IAudioEndpointVolume extends IAudioBase {
	static IID := "{5CDF2C82-841E-4546-9722-0CF74078229A}"
	RegisterControlChangeNotify(pNotify) => ComCall(3, this, "Ptr", pNotify)
	UnregisterControlChangeNotify(pNotify) => ComCall(4, this, "Ptr", pNotify)
	GetChannelCount() => (ComCall(5, this, "UInt*", &pnChannelCount := 0), pnChannelCount)
	SetMasterVolumeLevel(fLevelDB, pguidEventContext := 0) => ComCall(6, this, "Float", fLevelDB, "Ptr", pguidEventContext)
	SetMasterVolumeLevelScalar(fLevelDB, pguidEventContext := 0) => ComCall(7, this, "Float", fLevelDB, "Ptr", pguidEventContext)
	GetMasterVolumeLevel() => (ComCall(8, this, "Float*", &fLevelDB := 0), fLevelDB)
	GetMasterVolumeLevelScalar() => (ComCall(9, this, "Float*", &fLevel := 0), fLevel)
	SetChannelVolumeLevel(nChannel, fLevelDB, pguidEventContext := 0) => ComCall(10, this, "UInt", nChannel, "Float", fLevelDB, "Ptr", pguidEventContext)
	SetChannelVolumeLevelScalar(nChannel, pfLevel, pguidEventContext := 0) => ComCall(11, this, "UInt", nChannel, "Float", pfLevel, "Ptr", pguidEventContext)
	GetChannelVolumeLevel(nChannel) => (ComCall(12, this, "UInt", nChannel, "Float*", &fLevel := 0), fLevel)
	GetChannelVolumeLevelScalar(nChannel) => (ComCall(13, this, "UInt", nChannel, "Float*", &fLevel := 0), fLevel)
	SetMute(bMute, pguidEventContext := 0) => ComCall(14, this, "Int", bMute, "Ptr", pguidEventContext)
	GetMute() => (ComCall(15, this, "Int*", &bMute := 0), bMute)
	GetVolumeStepInfo(&nStep, &nStepCount) => ComCall(16, this, "UInt*", &nStep := 0, "UInt*", &nStepCount := 0)
	VolumeStepUp(pguidEventContext := 0) => ComCall(17, this, "Ptr", pguidEventContext)
	VolumeStepDown(pguidEventContext := 0) => ComCall(18, this, "Ptr", pguidEventContext)
	QueryHardwareSupport() => (ComCall(19, this, "UInt*", &dwHardwareSupportMask := 0), dwHardwareSupportMask)
	GetVolumeRange(&flVolumeMindB := 0, &flVolumeMaxdB := 0, &flVolumeIncrementdB := 0) => ComCall(20, this, "Float*", &flVolumeMindB := 0, "Float*", &flVolumeMaxdB := 0, "Float*", &flVolumeIncrementdB := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolumeex
class IAudioEndpointVolumeEx extends IAudioEndpointVolume {
	static IID := "{66E11784-F695-4F28-A505-A7080081A78F}"
	GetVolumeRangeChannel(iChannel, &flVolumeMindB := 0, &flVolumeMaxdB := 0, &flVolumeIncrementdB := 0) => ComCall(21, this, "UInt", iChannel, "Float*", &flVolumeMindB := 0, "Float*", &flVolumeMaxdB := 0, "Float*", &flVolumeIncrementdB := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudiometerinformation
class IAudioMeterInformation extends IAudioBase {
	static IID := "{C02216F6-8C67-4B5B-9D00-D008E73E0064}"
	GetPeakValue() => (ComCall(3, this, "Float*", &fPeak := 0), fPeak)
	GetMeteringChannelCount() => (ComCall(4, this, "UInt*", &nChannelCount := 0), nChannelCount)
	GetChannelsPeakValues(u32ChannelCount) => (ComCall(5, this, "UInt", u32ChannelCount, "Float*", &afPeakValues := 0), afPeakValues)
	QueryHardwareSupport() => (ComCall(6, this, "UInt*", &dwHardwareSupportMask := 0), dwHardwareSupportMask)
}

;; propsys.h header

; https://docs.microsoft.com/en-us/windows/win32/api/propsys/nn-propsys-ipropertystore
class IPropertyStore extends IAudioBase {
	static IID := "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}"
	GetCount() => (ComCall(3, this, "UInt*", &cProps := 0), cProps)
	GetAt(iProp) => (ComCall(4, this, "UInt", iProp, "Ptr", pkey := Buffer(20)), pkey)
	GetValue(key) => (ComCall(5, this, "Ptr", key, "Ptr", pv := Buffer(A_PtrSize = 8 ? 24 : 16)), pv)
	SetValue(key, propvar) => ComCall(6, this, "Ptr", key, "Ptr", propvar)
	Commit() => ComCall(7, this)
}

SimpleAudioVolumeFromPid(pid) {
	se := IMMDeviceEnumerator().GetDefaultAudioEndpoint().Activate(IAudioSessionManager2).GetSessionEnumerator()
	loop se.GetCount() {
		sc := se.GetSession(A_Index - 1).QueryInterface(IAudioSessionControl2)
		if (sc.GetProcessId() = pid)
			return sc.QueryInterface(ISimpleAudioVolume)
	}
}

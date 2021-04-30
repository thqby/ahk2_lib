/************************************************************************
 * @file: Audio.ahk
 * @description: Core Audio APIs, Windows 多媒体设备API
 * @author thqby
 * @date 2021/04/25
 * @version 1.0.3
 ***********************************************************************/
; https://docs.microsoft.com/en-us/windows/win32/api/unknwn/nn-unknwn-iunknown
class IUnknown {
    static IID := "{00000000-0000-0000-C000-000000000046}", IIDs := {IUnknown: "{00000000-0000-0000-C000-000000000046}"}
    static __IID {
        set => IUnknown.IIDs.%this.Prototype.__Class% := value
    }
    Ptr := 0, ComObj := 0, parent := 0
    __New(ptr, par := 0) => (this.Ptr := Type(ptr) = "ComObj" ? ptr.Ptr : (ObjAddRef(ptr), ptr), this.parent := par)
    __Delete() => ObjRelease(this.Ptr)
    AddRef() => ObjAddRef(this.Ptr)
    Release() => ObjRelease(this.Ptr)
    QueryInterface(riid, ComObj := unset) {
        if (!IsSet(ComObj))
            ComObj := ComObjQuery(this.Ptr, riid)
        for Interface, iid in IUnknown.IIDs.OwnProps()
            if (riid = iid)
                return %Interface%(ComObj, this)
        return Type(ComObj) = "ComObj" ? ComObj.Ptr : ComObj
    }
}
CLSIDFromString(sCLSID) {
    DllCall("ole32\CLSIDFromString", "Str", sCLSID, "Ptr", pCLSID := Buffer(16))
    return pCLSID
}
StringFromCLSID(pCLSID) {
    DllCall("ole32\StringFromCLSID", "Ptr", pCLSID, "Str*", &CLSID := "")
    return CLSID
}
FAILED(hr) {
    if (hr)
        throw Exception(hr)
}

;; audioclient.h header
; https://docs.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-ichannelaudiovolume
class IChannelAudioVolume extends IUnknown {
    static IID := this.__IID := "{1C158861-B533-4B30-B1CF-E853E51C59B8}"
    GetChannelCount(&dwCount) => ComCall(3, this, "UInt*", &dwCount := 0)
    SetChannelVolume(dwIndex, fLevel, EventContext := 0) => ComCall(4, this, "UInt", dwIndex, "Float", fLevel, "Ptr", EventContext)
    GetChannelVolume(dwIndex, &fLevel) => ComCall(5, this, "UInt", dwIndex, "Float*", &fLevel := 0)
    SetAllVolumes(dwCount, pfVolumes, EventContext := 0) => ComCall(4, this, "UInt", dwCount, "Ptr", pfVolumes, "Ptr", EventContext)
    GetAllVolumes(dwCount, &pfVolumes) => ComCall(5, this, "UInt", dwCount, "Ptr*", &pfVolumes := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-isimpleaudiovolume
class ISimpleAudioVolume extends IUnknown {
    static IID := this.__IID := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
    SetMasterVolume(fLevel, EventContext := 0) => ComCall(3, this, "Float", fLevel, "Ptr", EventContext)
    GetMasterVolume(&fLevel) => ComCall(4, this, "Float*", &fLevel := 0)
    SetMute(bMute, EventContext := 0) => ComCall(5, this, "Int", bMute, "Ptr", EventContext)
    GetMute(&bMute) => ComCall(6, this, "Int*", &bMute := 0)
}

;; mmdeviceapi.h header
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-iactivateaudiointerfaceasyncoperation
class IActivateAudioInterfaceAsyncOperation extends IUnknown {
    static IID := this.__IID := "{72A22D78-CDE4-431D-B8CC-843A71199B6D}"
    GetActivateResult(&activateResult, &activatedInterface) => ComCall(3, this, "Int*", &activateResult := 0, "Ptr*", &activatedInterface := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-iactivateaudiointerfacecompletionhandler
class IActivateAudioInterfaceCompletionHandler extends IUnknown {
    static IID := this.__IID := "{41D949AB-9862-444A-80F6-C261334DA5EB}"
    ActivateCompleted(activateOperation) => ComCall(3, this, "Ptr", activateOperation)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevice
class IMMDevice extends IUnknown {
    static IID := this.__IID := "{D666063F-1587-4E43-81F1-B948E807363F}"
    Activate(iid, dwClsCtx := 23, pActivationParams := 0, &pInterface := 0) => (FAILED(ComCall(3, this, "Ptr",
        Type(iid) = "String" ? CLSIDFromString(iid) : iid, "UInt", dwClsCtx, "Ptr", pActivationParams, "Ptr*",
        pInterface := 0)), this.QueryInterface(Type(iid) = "String" ? iid : StringFromCLSID(iid), pInterface))
    OpenPropertyStore(stgmAccess, &pProperties) => ComCall(4, this, "UInt", stgmAccess, "Ptr*", &pProperties := 0)
    GetId(&strId) => ComCall(5, this, "Str*", &strId := "")
    GetState(&dwState) => ComCall(6, this, "UInt*", &dwState := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevicecollection
class IMMDeviceCollection extends IUnknown {
    static IID := this.__IID := "{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}"
    GetCount(&cDevices) => ComCall(3, this, "UInt*", &cDevices := 0)
    Item(nDevice, &pDevice := 0) => (ComCall(4, this, "UInt", nDevice, "Ptr*", &pDevice := 0), IMMDevice(pDevice, this))
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator
class IMMDeviceEnumerator extends IUnknown {
    static IID := this.__IID := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
    __New() => (this.ComObj := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}"), this.Ptr := this.ComObj.Ptr)

    /*
     * EDataFlow: eRender 0, eCapture 1, eAll 2, EDataFlow_enum_count 3
     * ERole: eConsole 0, eMultimedia 1, eCommunications 2, ERole_enum_count 3
     * EndpointFormFactor: RemoteNetworkDevice 0, Speakers 1, LineLevel 2, Headphones 3, Microphone 4, Headset 5, Handset 6, UnknownDigitalPassthrough 7, SPDIF 8, DigitalAudioDisplayDevice 9, UnknownFormFactor 10, EndpointFormFactor_enum_count 11
     */
    EnumAudioEndpoints(dataFlow, dwStateMask, &pDevices := 0) => (FAILED(ComCall(3, this, "Int", dataFlow, "UInt", dwStateMask, "Ptr*", &pDevices := 0)), IMMDeviceCollection(pDevices, this))
    GetDefaultAudioEndpoint(dataFlow := 0, role := 0, &pEndpoint := 0) => (FAILED(ComCall(4, this, "Int", dataFlow, "UInt", role, "Ptr*", &pEndpoint := 0)), IMMDevice(pEndpoint, this))
    GetDevice(pwstrId, &pEndpoint := 0) => (FAILED(ComCall(5, this, "Str", pwstrId, "Ptr*", &pEndpoint := 0)), IMMDevice(pEndpoint, this))
    RegisterEndpointNotificationCallback(pClient) => ComCall(6, this, "Ptr", pClient)
    UnregisterEndpointNotificationCallback(pClient) => ComCall(7, this, "Ptr", pClient)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immendpoint
class IMMEndpoint extends IUnknown {
    static IID := this.__IID := "{1BE09788-6894-4089-8586-9A2A6C265AC5}"
    GetDataFlow(&DataFlow) => ComCall(3, this, "UInt*", &DataFlow := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immnotificationclient
class IMMNotificationClient extends IUnknown {
    static IID := this.__IID := "{7991EEC9-7E89-4D85-8390-6C703CEC60C0}"
    OnDeviceStateChanged(pwstrDeviceId, dwNewState) => ComCall(3, this, "Str", pwstrDeviceId, "UInt", dwNewState)
    OnDeviceAdded(pwstrDeviceId) => ComCall(4, this, "Str", pwstrDeviceId)
    OnDeviceRemoved(pwstrDeviceId) => ComCall(5, this, "Str", pwstrDeviceId)
    OnDefaultDeviceChanged(flow, role, pwstrDefaultDeviceId) => ComCall(6, this, "UInt", flow, "UInt", role, "Str", pwstrDefaultDeviceId)
    OnPropertyValueChanged(pwstrDeviceId, key) => ComCall(6, this, "Str", pwstrDeviceId, "Ptr", key)
}

;; audiopolicy.h header
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol
class IAudioSessionControl extends IUnknown {
    static IID := this.__IID := "{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}"
    ; AudioSessionState: AudioSessionStateInactive 0, AudioSessionStateActive 1, AudioSessionStateExpired 2
    GetState(&RetVal) => ComCall(3, this, "UInt*", &RetVal := 0)
    GetDisplayName(&RetVal) => ComCall(4, this, "Str*", &RetVal := "")
    SetDisplayName(Value, EventContext := 0) => ComCall(5, this, "Str", Value, "Ptr", EventContext)
    GetIconPath(&RetVal) => ComCall(6, this, "Str*", &RetVal := "")
    SetIconPath(Value, EventContext := 0) => ComCall(7, this, "Str", Value, "Ptr", EventContext)
    GetGroupingParam(&pRetVal) => ComCall(8, this, "Ptr*", &pRetVal := 0)
    SetGroupingParam(Override, EventContext := 0) => ComCall(9, this, "Ptr", Override, "Ptr", EventContext)
    RegisterAudioSessionNotification(NewNotifications) => ComCall(10, this, "Ptr", NewNotifications)
    UnregisterAudioSessionNotification(NewNotifications) => ComCall(11, this, "Ptr", NewNotifications)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol2
class IAudioSessionControl2 extends IAudioSessionControl {
    static IID := this.__IID := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
    GetSessionIdentifier(&RetVal) => ComCall(12, this, "Str*", &RetVal := "")
    GetSessionInstanceIdentifier(&RetVal) => ComCall(13, this, "Str*", &RetVal := "")
    GetProcessId(&RetVal) => ComCall(14, this, "UInt*", &RetVal := 0)
    IsSystemSoundsSession() => ComCall(15, this)
    SetDuckingPreference(optOut) => ComCall(16, this, "Int", optOut)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionenumerator
class IAudioSessionEnumerator extends IUnknown {
    static IID := this.__IID := "{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}"
    GetCount(&SessionCount) => ComCall(3, this, "Int*", &SessionCount := 0)
    GetSession(SessionCount, &Session := 0) => (FAILED(ComCall(4, this, "Int", SessionCount, "Ptr*", &Session := 0)), IAudioSessionControl(Session, this))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionevents
class IAudioSessionEvents extends IUnknown {
    static IID := this.__IID := "{24918ACC-64B3-37C1-8CA9-74A66E9957A8}"
    OnDisplayNameChanged(NewDisplayName, EventContext) => ComCall(3, this, "Str", NewDisplayName, "Ptr", EventContext)
    OnIconPathChanged(NewIconPath, EventContext) => ComCall(4, this, "Str", NewIconPath, "Ptr", EventContext)
    OnSimpleVolumeChanged(NewVolume, NewMute, EventContext) => ComCall(5, this, "Float", NewVolume, "Int", NewMute, "Ptr", EventContext)
    OnChannelVolumeChanged(ChannelCount, NewChannelVolumeArray, ChangedChannel, EventContext) => ComCall(6, this, "UInt", ChannelCount, "Ptr", NewChannelVolumeArray, "UInt", ChangedChannel, "Ptr", EventContext)
    OnGroupingParamChanged(NewGroupingParam, EventContext) => ComCall(7, this, "Ptr", NewGroupingParam, "Ptr", EventContext)
    OnStateChanged(NewState) => ComCall(8, this, "UInt", NewState)
    OnSessionDisconnected(DisconnectReason) => ComCall(9, this, "UInt", DisconnectReason)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager
class IAudioSessionManager extends IUnknown {
    static IID := this.__IID := "{BFA971F1-4D5E-40BB-935E-967039BFBEE4}"
    GetAudioSessionControl(AudioSessionGuid, StreamFlags, &SessionControl := 0) => (FAILED(ComCall(3, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &SessionControl := 0)), IAudioSessionControl(SessionControl, this))
    GetSimpleAudioVolume(AudioSessionGuid, StreamFlags, &AudioVolume := 0) => (FAILED(ComCall(4, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &AudioVolume := 0)), ISimpleAudioVolume(AudioVolume, this))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager2
class IAudioSessionManager2 extends IAudioSessionManager {
    static IID := this.__IID := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
    GetSessionEnumerator(&SessionEnum := 0) => (FAILED(ComCall(5, this, "Ptr*", &SessionEnum := 0)), IAudioSessionEnumerator(SessionEnum, this))
    RegisterSessionNotification(SessionNotification) => ComCall(6, this, "Ptr", SessionNotification)
    UnregisterSessionNotification(SessionNotification) => ComCall(7, this, "Ptr", SessionNotification)
    RegisterDuckNotification(sessionID, duckNotification) => ComCall(8, this, "Str", sessionID, "Ptr", duckNotification)
    UnregisterDuckNotification(duckNotification) => ComCall(9, this, "Ptr", duckNotification)
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionnotification
class IAudioSessionNotification extends IUnknown {
    static IID := this.__IID := "{641DD20B-4D41-49CC-ABA3-174B9477BB08}"
    OnSessionCreated(&NewSession := 0) => (FAILED(ComCall(3, this, "Ptr*", &NewSession := 0)), IAudioSessionControl(NewSession, this))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiovolumeducknotification
class IAudioVolumeDuckNotification extends IUnknown {
    static IID := this.__IID := "{C3B284D4-6D39-4359-B3CF-B56DDB3BB39C}"
    OnVolumeDuckNotification(sessionID, countCommunicationSessions) => ComCall(3, this, "Str", sessionID, "UInt", countCommunicationSessions)
    OnVolumeUnduckNotification(sessionID) => ComCall(4, this, "Str", sessionID)
}

;; endpointvolume.h header
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolume
class IAudioEndpointVolume extends IUnknown {
    static IID := this.__IID := "{5CDF2C82-841E-4546-9722-0CF74078229A}"
    RegisterControlChangeNotify(pNotify) => ComCall(3, this, "Ptr", pNotify)
    UnregisterControlChangeNotify(pNotify) => ComCall(4, this, "Ptr", pNotify)
    GetChannelCount(pnChannelCount) => ComCall(5, this, "UInt*", &pnChannelCount)
    SetMasterVolumeLevel(fLevelDB, pguidEventContext := 0) => ComCall(6, this, "Float", fLevelDB, "Ptr", pguidEventContext)
    SetMasterVolumeLevelScalar(fLevelDB, pguidEventContext := 0) => ComCall(7, this, "Float", fLevelDB, "Ptr", pguidEventContext)
    GetMasterVolumeLevel(&fLevelDB) => ComCall(8, this, "Float*", &fLevelDB := 0)
    GetMasterVolumeLevelScalar(&fLevel) => ComCall(9, this, "Float*", &fLevel := 0)
    SetChannelVolumeLevel(nChannel, fLevelDB, pguidEventContext := 0) => ComCall(10, this, "UInt", nChannel, "Float", fLevelDB, "Ptr", pguidEventContext)
    SetChannelVolumeLevelScalar(nChannel, pfLevel, pguidEventContext := 0) => ComCall(11, this, "UInt", nChannel, "Float", pfLevel, "Ptr", pguidEventContext)
    GetChannelVolumeLevel(nChannel, &fLevel) => ComCall(12, this, "UInt", nChannel, "Float*", &fLevel := 0)
    GetChannelVolumeLevelScalar(nChannel, &fLevel) => ComCall(13, this, "UInt", nChannel, "Float*", &fLevel := 0)
    SetMute(bMute, pguidEventContext := 0) => ComCall(14, this, "Int", bMute, "Ptr", pguidEventContext)
    GetMute(&bMute) => ComCall(15, this, "Int*", &bMute := 0)
    GetVolumeStepInfo(&nStep, &nStepCount) => ComCall(16, this, "UInt*", &nStep := 0, "UInt*", &nStepCount := 0)
    VolumeStepUp(pguidEventContext := 0) => ComCall(17, this, "Ptr", pguidEventContext)
    VolumeStepDown(pguidEventContext := 0) => ComCall(18, this, "Ptr", pguidEventContext)
    QueryHardwareSupport(&dwHardwareSupportMask) => ComCall(19, this, "UInt*", &dwHardwareSupportMask := 0)
    GetVolumeRange(&flVolumeMindB, &flVolumeMaxdB, &flVolumeIncrementdB) => ComCall(20, this, "Float*", &flVolumeMindB := 0, "Float*", &flVolumeMaxdB := 0, "Float*", &flVolumeIncrementdB := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolumeex
class IAudioEndpointVolumeEx extends IAudioEndpointVolume {
    static IID := this.__IID := "{66E11784-F695-4F28-A505-A7080081A78F}"
    GetVolumeRangeChannel(iChannel, &flVolumeMindB, &flVolumeMaxdB, &flVolumeIncrementdB) => ComCall(21, this, "UInt", iChannel, "Float*", &flVolumeMindB := 0, "Float*", &flVolumeMaxdB := 0, "Float*", &flVolumeIncrementdB := 0)
}
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudiometerinformation
class IAudioMeterInformation extends IUnknown {
    static IID := this.__IID := "{C02216F6-8C67-4B5B-9D00-D008E73E0064}"
    GetPeakValue(&fPeak) => ComCall(3, this, "Float*", &fPeak := 0)
    GetMeteringChannelCount(&nChannelCount) => ComCall(4, this, "UInt*", &nChannelCount := 0)
    GetChannelsPeakValues(u32ChannelCount, &afPeakValues) => ComCall(5, this, "UInt", u32ChannelCount, "Float*", &afPeakValues := 0)
    QueryHardwareSupport(&dwHardwareSupportMask) => ComCall(6, this, "UInt*", &dwHardwareSupportMask := 0)
}

;; propsys.h header
; https://docs.microsoft.com/en-us/windows/win32/api/propsys/nn-propsys-ipropertystore
class IPropertyStore extends IUnknown {
    static IID := this.__IID := "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}"
    GetCount(&cProps) => ComCall(3, this, "UInt*", &cProps := 0)
    GetAt(iProp, &pkey := 0) => (ComCall(4, this, "UInt", iProp, "Ptr", pkey := Buffer(20)), pkey)
    GetValue(key, &pv := 0) => (ComCall(5, this, "Ptr", key, "Ptr", pv := Buffer(A_PtrSize = 8 ? 24 : 16)), pv)
    SetValue(key, propvar) => ComCall(6, this, "Ptr", key, "Ptr", propvar)
    Commit() => ComCall(7, this)
}
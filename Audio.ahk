/************************************************************************
 * @description: Core Audio APIs, Windows 多媒体设备API
 * @author thqby
 * @date 2024/09/14
 * @version 1.1.1
 ***********************************************************************/
#DllLoad ole32.dll
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

	_events {
		set {
			this.DefineProp("_events", { value: Value }).DefineProp("__Delete", { value: __del })
			__del(this) {
				for k, v in this._events.DefineProp("Delete", { call: (*) => 0 })
					v(this, k)
				this.Release()
			}
		}
	}

	static STR(ptr) {
		if ptr {
			s := StrGet(ptr), DllCall("ole32\CoTaskMemFree", "ptr", ptr)
			return s
		}
	}
}

class _interface_impl extends Buffer {
	; Lazy initialization
	static vtable {
		set {
			this.Prototype.DefineProp("_vtable", { get: this => make_vtable(this, Value) })
			make_vtable(this, methods) {
				proto := this.Base
				vtable := Buffer(A_PtrSize * methods.Length)
				vtable.__Delete := __del, p := vtable.Ptr
				for m in methods {
					if m is Func
						fn := CallbackCreate(m, , m.MaxParams)
					else
						fn := CallbackCreate(invoke.Bind(m), , set_writable(proto, m[1]).MaxParams)
					p := NumPut("ptr", fn, p)
				}
				proto.DefineProp("_vtable", { value: vtable })
				return vtable
				__del(this) {
					p := this.Ptr
					loop this.Size // A_PtrSize
						CallbackFree(NumGet(p, "ptr")), p += A_PtrSize
				}
			}
			invoke(def, this, args*) {
				iter := def.__Enum(), iter(, &m)
				for k, v in iter
					if IsSet(v)
						args[k] := v(args[--k])
				ObjFromPtrAddRef(NumGet(this, A_PtrSize, "ptr")).%m%(args*)
			}
			set_writable(proto, k) {
				desc := proto.GetOwnPropDesc(k)
				desc.set := (this, v) => this.DefineProp(k, { Call: v })
				proto.DefineProp(k, desc)
				return desc.Call
			}
		}
	}
	__New() {
		this.Size := 2 * A_PtrSize
		NumPut("ptr", this._vtable.Ptr, "ptr", ObjPtr(this), this)
	}
}

;; audioclient.h header

; https://docs.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-ichannelaudiovolume
class IChannelAudioVolume extends IAudioBase {
	static IID := "{1C158861-B533-4B30-B1CF-E853E51C59B8}"
	GetChannelCount() => (ComCall(3, this, "UInt*", &dwCount := 0), dwCount)
	SetChannelVolume(dwIndex, fLevel, EventContext := 0) => ComCall(4, this, "UInt", dwIndex, "Float", fLevel, "Ptr", EventContext)
	GetChannelVolume(dwIndex) => (ComCall(5, this, "UInt", dwIndex, "Float*", &fLevel := 0), fLevel)
	/** @param {Array<Float>} fVolumes */
	SetAllVolumes(fVolumes, EventContext := 0) {
		dwCount := fVolumes.Length, pfVolumes := Buffer(dwCount << 2)
		for v in fVolumes
			NumPut("float", v, pfVolumes, (A_Index - 1) << 2)
		ComCall(6, this, "UInt", dwCount, "Ptr", pfVolumes, "Ptr", EventContext)
	}
	GetAllVolumes(dwCount := this.GetChannelCount()) {
		ComCall(7, this, "UInt", dwCount, "Ptr", pfVolumes := Buffer(dwCount << 2, 0))
		volumes := []
		loop dwCount
			volumes.Push(NumGet(pfVolumes, (A_Index - 1) << 2, "float"))
		return volumes
	}
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
	GetActivateResult(&activateResult, &activatedInterface) => ComCall(3, this, "Int*", &activateResult := 0, "Ptr*", activatedInterface := ComValue(0xd, 0))
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-iactivateaudiointerfacecompletionhandler
class IActivateAudioInterfaceCompletionHandler extends _interface_impl {
	static IID := "{41D949AB-9862-444A-80F6-C261334DA5EB}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["ActivateCompleted", IActivateAudioInterfaceAsyncOperation]
	]
	/** @event */
	ActivateCompleted(activateOperation) => 0
}

; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevice
class IMMDevice extends IAudioBase {
	static IID := "{D666063F-1587-4E43-81F1-B948E807363F}"
	Activate(iidorclass, dwClsCtx := 23, pActivationParams := 0) {
		DllCall("ole32\CLSIDFromString", "Str", HasBase(iidorclass, IAudioBase) ? iidorclass.IID : iidorclass, "Ptr", pCLSID := Buffer(16))
		ComCall(3, this, "Ptr", pCLSID, "UInt", dwClsCtx, "Ptr", pActivationParams, "Ptr*", &pInterface := 0)
		return HasBase(iidorclass, IAudioBase) ? iidorclass(pInterface) : ComValue(0xd, pInterface)
	}
	OpenPropertyStore(stgmAccess) => (ComCall(4, this, "UInt", stgmAccess, "Ptr*", &pProperties := 0), IPropertyStore(pProperties))
	GetId() => (ComCall(5, this, "Ptr*", &strId := 0), IAudioBase.STR(strId))
	GetState() => (ComCall(6, this, "UInt*", &dwState := 0), dwState)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevicecollection
class IMMDeviceCollection extends IAudioBase {
	static IID := "{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}"
	GetCount() => (ComCall(3, this, "UInt*", &cDevices := 0), cDevices)
	Item(nDevice) => (ComCall(4, this, "UInt", nDevice, "Ptr*", &pDevice := 0), IMMDevice(pDevice))
	__Enum(n) {
		if n == 1
			return (n := this.GetCount(), i := 0, (&v) => i < n ? (v := this.Item(i++), true) : false)
		return (n := this.GetCount(), i := 0, (&k, &v, *) => i < n ? (v := this.Item(k := i++), true) : false)
	}
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator
class IMMDeviceEnumerator extends IAudioBase {
	static IID := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
	_events := Map()
	__New() {
		obj := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", IMMDeviceEnumerator.IID)
		this.Ptr := ComObjValue(obj), this.AddRef()
	}

	/**
	 * EDataFlow: eRender 0, eCapture 1, eAll 2, EDataFlow_enum_count 3
	 * ERole: eConsole 0, eMultimedia 1, eCommunications 2, ERole_enum_count 3
	 * StateMask: DEVICE_STATE_ACTIVE 1, DEVICE_STATE_DISABLED 2, DEVICE_STATE_NOTPRESENT 4, DEVICE_STATE_UNPLUGGED 8, DEVICE_STATEMASK_ALL 0xf
	 * EndpointFormFactor: RemoteNetworkDevice 0, Speakers 1, LineLevel 2, Headphones 3, Microphone 4, Headset 5, Handset 6, UnknownDigitalPassthrough 7, SPDIF 8, DigitalAudioDisplayDevice 9, UnknownFormFactor 10, EndpointFormFactor_enum_count 11
	 */
	EnumAudioEndpoints(dataFlow := 0, dwStateMask := 1) => (ComCall(3, this, "Int", dataFlow, "UInt", dwStateMask, "Ptr*", &pDevices := 0), IMMDeviceCollection(pDevices))
	GetDefaultAudioEndpoint(dataFlow := 0, role := 0) => (ComCall(4, this, "Int", dataFlow, "UInt", role, "Ptr*", &pEndpoint := 0), IMMDevice(pEndpoint))
	GetDevice(pwstrId) => (ComCall(5, this, "Str", pwstrId, "Ptr*", &pEndpoint := 0), IMMDevice(pEndpoint))
	/** @param {IMMNotificationClient} Client */
	RegisterEndpointNotificationCallback(Client) {
		ComCall(6, this, "Ptr", Client)
		this._events[Client] := this.UnregisterEndpointNotificationCallback
	}
	/** @param {IMMNotificationClient} Client */
	UnregisterEndpointNotificationCallback(Client) {
		ComCall(7, this, "Ptr", Client)
		this._events.Delete(Client)
	}
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immendpoint
class IMMEndpoint extends IAudioBase {
	static IID := "{1BE09788-6894-4089-8586-9A2A6C265AC5}"
	GetDataFlow() => (ComCall(3, this, "UInt*", &DataFlow := 0), DataFlow)
}
; https://docs.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immnotificationclient
class IMMNotificationClient extends _interface_impl {
	static IID := "{7991EEC9-7E89-4D85-8390-6C703CEC60C0}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["OnDeviceStateChanged", StrGet],
		["OnDeviceAdded", StrGet],
		["OnDeviceRemoved", StrGet],
		["OnDefaultDeviceChanged", , , StrGet],
		["OnPropertyValueChanged", StrGet],
	]

	/** @event */
	OnDeviceStateChanged(pwstrDeviceId, dwNewState) => 0
	/** @event */
	OnDeviceAdded(pwstrDeviceId) => 0
	/** @event */
	OnDeviceRemoved(pwstrDeviceId) => 0
	/** @event */
	OnDefaultDeviceChanged(flow, role, pwstrDefaultDeviceId) => 0
	/** @event */
	OnPropertyValueChanged(pwstrDeviceId, key) => 0
}

;; audiopolicy.h header

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol
class IAudioSessionControl extends IAudioBase {
	static IID := "{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}"
	_events := Map()
	; AudioSessionState: AudioSessionStateInactive 0, AudioSessionStateActive 1, AudioSessionStateExpired 2
	GetState() => (ComCall(3, this, "UInt*", &RetVal := 0), RetVal)
	GetDisplayName() => (ComCall(4, this, "Ptr*", &RetVal := 0), IAudioBase.STR(RetVal))
	SetDisplayName(Value, EventContext := 0) => ComCall(5, this, "Str", Value, "Ptr", EventContext)
	GetIconPath() => (ComCall(6, this, "Ptr*", &RetVal := 0), IAudioBase.STR(RetVal))
	SetIconPath(Value, EventContext := 0) => ComCall(7, this, "Str", Value, "Ptr", EventContext)
	GetGroupingParam() {
		ComCall(8, this, "Ptr", pRetVal := Buffer(16))
		return pRetVal
	}
	SetGroupingParam(Override, EventContext := 0) => ComCall(9, this, "Ptr", Override, "Ptr", EventContext)
	/** @param {IAudioSessionEvents} NewNotifications */
	RegisterAudioSessionNotification(NewNotifications) {
		ComCall(10, this, "Ptr", NewNotifications)
		this._events[NewNotifications] := this.UnregisterAudioSessionNotification
	}
	/** @param {IAudioSessionEvents} NewNotifications */
	UnregisterAudioSessionNotification(NewNotifications) {
		ComCall(11, this, "Ptr", NewNotifications)
		this._events.Delete(NewNotifications)
	}
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
	__Enum(n) {
		if n == 1
			return (n := this.GetCount(), i := 0, (&v) => i < n ? (v := this.GetSession(i++), true) : false)
		return (n := this.GetCount(), i := 0, (&k, &v, *) => i < n ? (v := this.GetSession(k := i++), true) : false)
	}
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionevents
class IAudioSessionEvents extends _interface_impl {
	static IID := "{24918ACC-64B3-37C1-8CA9-74A66E9957A8}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["OnDisplayNameChanged", StrGet],
		["OnIconPathChanged", StrGet],
		["OnSimpleVolumeChanged",],
		["OnChannelVolumeChanged",],
		["OnGroupingParamChanged",],
		["OnStateChanged",],
		["OnSessionDisconnected",],
	]
	/** @event */
	OnDisplayNameChanged(NewDisplayName, EventContext) => 0
	/** @event */
	OnIconPathChanged(NewIconPath, EventContext) => 0
	/** @event */
	OnSimpleVolumeChanged(NewVolume, NewMute, EventContext) => 0
	/** @event */
	OnChannelVolumeChanged(ChannelCount, NewChannelVolumeArray, ChangedChannel, EventContext) => 0
	/** @event */
	OnGroupingParamChanged(NewGroupingParam, EventContext) => 0
	/** @event */
	OnStateChanged(NewState) => 0
	/** @event */
	OnSessionDisconnected(DisconnectReason) => 0
}

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager
class IAudioSessionManager extends IAudioBase {
	static IID := "{BFA971F1-4D5E-40BB-935E-967039BFBEE4}"
	GetAudioSessionControl(AudioSessionGuid, StreamFlags) => (ComCall(3, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &SessionControl := 0), IAudioSessionControl(SessionControl))
	GetSimpleAudioVolume(AudioSessionGuid, StreamFlags) => (ComCall(4, this, "Ptr", AudioSessionGuid, "UInt", StreamFlags, "Ptr*", &AudioVolume := 0), ISimpleAudioVolume(AudioVolume))
}
; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager2
class IAudioSessionManager2 extends IAudioSessionManager {
	static IID := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
	_events := Map()
	GetSessionEnumerator() => (ComCall(5, this, "Ptr*", &SessionEnum := 0), IAudioSessionEnumerator(SessionEnum))
	/** @param {IAudioSessionNotification} SessionNotification */
	RegisterSessionNotification(SessionNotification) {
		ComCall(6, this, "Ptr", SessionNotification)
		this._events[SessionNotification] := this.UnregisterSessionNotification
	}
	/** @param {IAudioSessionNotification} SessionNotification */
	UnregisterSessionNotification(SessionNotification) {
		ComCall(7, this, "Ptr", SessionNotification)
		this._events.Delete(SessionNotification)
	}
	/** @param {IAudioVolumeDuckNotification} duckNotification */
	RegisterDuckNotification(sessionID, duckNotification) {
		ComCall(8, this, "Str", sessionID, "Ptr", duckNotification)
		this._events[duckNotification] := this.UnregisterDuckNotification
	}
	/** @param {IAudioVolumeDuckNotification} duckNotification */
	UnregisterDuckNotification(duckNotification) {
		ComCall(9, this, "Ptr", duckNotification)
		this._events.Delete(duckNotification)
	}
}

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionnotification
class IAudioSessionNotification extends _interface_impl {
	static IID := "{641DD20B-4D41-49CC-ABA3-174B9477BB08}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["OnSessionCreated", IAudioSessionControl],
	]
	/** @event */
	OnSessionCreated(NewSession) => 0
}

; https://docs.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiovolumeducknotification
class IAudioVolumeDuckNotification extends _interface_impl {
	static IID := "{C3B284D4-6D39-4359-B3CF-B56DDB3BB39C}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["OnVolumeDuckNotification", StrGet],
		["OnVolumeUnduckNotification", StrGet],
	]
	/** @event */
	OnVolumeDuckNotification(sessionID, countCommunicationSessions) => 0
	/** @event */
	OnVolumeUnduckNotification(sessionID) => 0
}

;; endpointvolume.h header

; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolume
class IAudioEndpointVolume extends IAudioBase {
	static IID := "{5CDF2C82-841E-4546-9722-0CF74078229A}"
	_events := Map()
	/** @param {IAudioEndpointVolumeCallback} Notify */
	RegisterControlChangeNotify(Notify) {
		ComCall(3, this, "Ptr", Notify)
		this._events[Notify] := this.UnregisterControlChangeNotify
	}
	/** @param {IAudioEndpointVolumeCallback} Notify */
	UnregisterControlChangeNotify(Notify) {
		ComCall(4, this, "Ptr", Notify)
		this._events.Delete(Notify)
	}
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

class IAudioEndpointVolumeCallback extends _interface_impl {
	static IID := "{657804FA-D6AD-4496-8A60-352752AF4F89}"
	static vtable := [
		(this, iid, pobj) => !NumPut("ptr", this, pobj),
		(this) => 1,
		(this) => 1,
		["OnNotify", this.AUDIO_VOLUME_NOTIFICATION_DATA]
	]
	/** @event */
	OnNotify(Notify) => 0

	class AUDIO_VOLUME_NOTIFICATION_DATA {
		__New(ptr) {
			DllCall("ole32\StringFromGUID2", "ptr", ptr, "ptr", buf := Buffer(78), "int", 39)
			this.guidEventContext := StrGet(buf)
			this.bMuted := NumGet(ptr += 16, "int")
			this.fMasterVolume := NumGet(ptr += 4, "float")
			this.afChannelVolumes := volumes := []
			loop this.nChannels := NumGet(ptr += 4, "uint")
				volumes.Push(NumGet(ptr += 4, "float"))
		}
	}
}
; https://docs.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudiometerinformation
class IAudioMeterInformation extends IAudioBase {
	static IID := "{C02216F6-8C67-4B5B-9D00-D008E73E0064}"
	GetPeakValue() => (ComCall(3, this, "Float*", &fPeak := 0), fPeak)
	GetMeteringChannelCount() => (ComCall(4, this, "UInt*", &nChannelCount := 0), nChannelCount)
	GetChannelsPeakValues(u32ChannelCount := this.GetMeteringChannelCount()) {
		peakValues := []
		ComCall(5, this, "UInt", u32ChannelCount, "Ptr", afPeakValues := Buffer(u32ChannelCount * 4))
		loop u32ChannelCount
			peakValues.Push(NumGet(afPeakValues, (A_Index - 1) * 4, 'Float'))
		return peakValues
	}
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

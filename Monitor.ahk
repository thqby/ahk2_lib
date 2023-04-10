; =================================================================================================== ;
; AutoHotkey V2 a122 Wrapper for Monitor Configuration WinAPI Functions
;
; Original Author ....: jNizM
; Released ...........: 2015-05-26
; Modified ...........: 2020-08-17
; Adapted By .........: tigerlily, CloakerSmoker
; Version ............: 2.3.1
; Github .............: https://github.com/tigerlily-dev/Monitor-Configuration-Class
; Forum ..............: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=79220
; License/Copyright ..: The Unlicense (https://unlicense.org)
;
; [Change Log], [Pending], and [Remarks] sections can be found @ bottom of script
;
; =================================================================================================== ;

#DllLoad dxva2.dll
class Monitor {

  ; ===== PUBLIC METHODS ============================================================================== ;

  ; ===== GET METHODS ===== ;

  static GetInfo() => this.EnumDisplayMonitors()

  static GetBrightness(Display := "") => this.GetSetting("GetMonitorBrightness", Display)

  static GetContrast(Display := "") => this.GetSetting("GetMonitorContrast", Display)

  static GetGammaRamp(Display := "") => this.GammaSetting("GetDeviceGammaRamp", , , , Display)

  static GetRedDrive(Display := "") => this.GetSetting("GetMonitorRedDrive", Display)

  static GetGreenDrive(Display := "") => this.GetSetting("GetMonitorGreenDrive", Display)

  static GetBlueDrive(Display := "") => this.GetSetting("GetMonitorBlueDrive", Display)

  static GetRedGain(Display := "") => this.GetSetting("GetMonitorRedGain", Display)

  static GetGreenGain(Display := "") => this.GetSetting("GetMonitorGreenGain", Display)

  static GetBlueGain(Display := "") => this.GetSetting("GetMonitorBlueGain", Display)

  static GetDisplayAreaWidth(Display := "") => this.GetSetting("GetMonitorDisplayAreaWidth", Display)

  static GetDisplayAreaHeight(Display := "") => this.GetSetting("GetMonitorDisplayAreaHeight", Display)

  static GetDisplayAreaPositionHorizontal(Display := "") => this.GetSetting("GetMonitorDisplayAreaPositionHorizontal", Display)

  static GetDisplayAreaPositionVertical(Display := "") => this.GetSetting("GetMonitorDisplayAreaPositionVertical", Display)

  static GetVCPFeatureAndReply(VCPCode, Display := "") => this.GetSetting("GetVCPFeatureAndVCPFeatureReply", Display, VCPCode)

  static GetSharpness(Display := "") => this.GetSetting("GetVCPFeatureAndVCPFeatureReply", Display, 0x87)["CurrentValue"]

  static CapabilitiesRequestAndCapabilitiesReply(Display := "") => this.GetSetting("MonitorCapabilitiesRequestAndCapabilitiesReply", Display)

  static GetCapabilitiesStringLength(Display := "") => this.GetSetting("GetMonitorCapabilitiesStringLength", Display)

  static GetCapabilities(Display := "") {

      static MC_CAPS := Map(
          0x00000000, "MC_CAPS_NONE:`nThe monitor does not support any monitor settings.",
          0x00000001, "MC_CAPS_MONITOR_TECHNOLOGY_TYPE:`nThe monitor supports the GetMonitorTechnologyType function.",
          0x00000002, "MC_CAPS_BRIGHTNESS:`nThe monitor supports the GetMonitorBrightness and SetMonitorBrightness functions.",
          0x00000004, "MC_CAPS_CONTRAST:`nThe monitor supports the GetMonitorContrast and SetMonitorContrast functions.",
          0x00000008, "MC_CAPS_COLOR_TEMPERATURE:`nThe monitor supports the GetMonitorColorTemperature and SetMonitorColorTemperature functions.",
          0x00000010, "MC_CAPS_RED_GREEN_BLUE_GAIN:`nThe monitor supports the GetMonitorRedGreenOrBlueGain and SetMonitorRedGreenOrBlueGain functions.",
          0x00000020, "MC_CAPS_RED_GREEN_BLUE_DRIVE:`nThe monitor supports the GetMonitorRedGreenOrBlueDrive and SetMonitorRedGreenOrBlueDrive functions.",
          0x00000040, "MC_CAPS_DEGAUSS:`nThe monitor supports the DegaussMonitor function.",
          0x00000080, "MC_CAPS_DISPLAY_AREA_POSITION:`nThe monitor supports the GetMonitorDisplayAreaPosition and SetMonitorDisplayAreaPosition functions.",
          0x00000100, "MC_CAPS_DISPLAY_AREA_SIZE:`nThe monitor supports the GetMonitorDisplayAreaSize and SetMonitorDisplayAreaSize functions.",
          0x00000200, "MC_CAPS_RESTORE_FACTORY_DEFAULTS:`nThe monitor supports the RestoreMonitorFactoryDefaults function.",
          0x00000400, "MC_CAPS_RESTORE_FACTORY_COLOR_DEFAULTS:`nThe monitor supports the RestoreMonitorFactoryColorDefaults function.",
          0x00001000, "MC_RESTORE_FACTORY_DEFAULTS_ENABLES_MONITOR_SETTINGS:`nIf this flag is present, calling the RestoreMonitorFactoryDefaults function enables all of the monitor settings used by the high-level monitor configuration functions. For more information, see the Remarks section in RestoreMonitorFactoryDefaults. (https://docs.microsoft.com/en-us/windows/win32/api/highlevelmonitorconfigurationapi/nf-highlevelmonitorconfigurationapi-restoremonitorfactorydefaults)")

      if (CapabilitiesFlags := this.GetSetting("GetMonitorCapabilities", Display)["MonitorCapabilities"]) {
        SupportedCapabilities := []
        for FlagValue, FlagDescription in MC_CAPS
          if (CapabilitiesFlags & FlagValue)
            SupportedCapabilities.Push(FlagDescription)
        return SupportedCapabilities
      }
      throw MC_CAPS[CapabilitiesFlags]
    }

  static GetSupportedColorTemperatures(Display := "") {

      static MC_SUPPORTED_COLOR_TEMPERATURE := Map(
          0x00000000, "No color temperatures are supported.",
          0x00000001, "The monitor supports 4,000 kelvins (K) color temperature.",
          0x00000002, "The monitor supports 5,000 K color temperature.",
          0x00000004, "The monitor supports 6,500 K color temperature.",
          0x00000008, "The monitor supports 7,500 K color temperature.",
          0x00000010, "The monitor supports 8,200 K color temperature.",
          0x00000020, "The monitor supports 9,300 K color temperature.",
          0x00000040, "The monitor supports 10,000 K color temperature.",
          0x00000080, "The monitor supports 11,500 K color temperature.")

      if (ColorTemperatureFlags := this.GetSetting("GetMonitorCapabilities", Display)["SupportedColorTemperatures"]) {
        SupportedColorTemperatures := []
        for FlagValue, FlagDescription in MC_SUPPORTED_COLOR_TEMPERATURE
          if (ColorTemperatureFlags & FlagValue)
            SupportedColorTemperatures.Push(FlagDescription)
        return SupportedColorTemperatures
      }
      throw MC_SUPPORTED_COLOR_TEMPERATURE[ColorTemperatureFlags]
    }

  static GetColorTemperature(Display := "") {

      static MC_COLOR_TEMPERATURE := Map(
          0x00000000, "Unknown temperature.",
          0x00000001, "4,000 kelvins (K).",
          0x00000002, "5,000 kelvins (K).",
          0x00000004, "6,500 kelvins (K).",
          0x00000008, "7,500 kelvins (K).",
          0x00000010, "8,200 kelvins (K).",
          0x00000020, "9,300 kelvins (K).",
          0x00000040, "10,000 kelvins (K).",
          0x00000080, "11,500 kelvins (K).")

      return MC_COLOR_TEMPERATURE[this.GetSetting("GetMonitorColorTemperature", Display)]
    }

  static GetTechnologyType(Display := "") {

      static DISPLAY_TECHNOLOGY_TYPE := Map(
          0x00000000, "Shadow-mask cathode ray tube (CRT)",
          0x00000001, "Aperture-grill CRT",
          0x00000002, "Thin-film transistor (TFT) display",
          0x00000004, "Liquid crystal on silicon (LCOS) display",
          0x00000008, "Plasma display",
          0x00000010, "Organic light emitting diode (LED) display",
          0x00000020, "Electroluminescent display",
          0x00000040, "Microelectromechanical display",
          0x00000080, "Field emission device (FED) display")

      return DISPLAY_TECHNOLOGY_TYPE[this.GetSetting("GetMonitorTechnologyType", Display)]
    }

  static GetPowerMode(Display := "") {

      static PowerModes := Map(
          0x01, "On",
          0x02, "Standby",
          0x03, "Suspend",
          0x04, "Off",
          0x05, "PowerOff")

      return PowerModes[this.GetSetting("GetVCPFeatureAndVCPFeatureReply", Display, 0xD6)["CurrentValue"]]
    }

  ; ===== SET METHODS ===== ;

  static SetBrightness(Brightness, Display := "") => this.SetSetting("SetMonitorBrightness", Brightness, Display)

  static SetContrast(Contrast, Display := "") => this.SetSetting("SetMonitorContrast", Contrast, Display)

  static SetGammaRamp(Red := 100, Green := 100, Blue := 100, Display := "") => this.GammaSetting("SetDeviceGammaRamp", Red, Green, Blue, Display)

  static SetRedDrive(RedDrive, Display := "") => this.SetSetting("SetMonitorRedDrive", RedDrive, Display)

  static SetGreenDrive(GreenDrive, Display := "") => this.SetSetting("SetMonitorGreenDrive", GreenDrive, Display)

  static SetBlueDrive(BlueDrive, Display := "") => this.SetSetting("SetMonitorBlueDrive", BlueDrive, Display)

  static SetRedGain(RedGain, Display := "") => this.SetSetting("SetMonitorRedGain", RedGain, Display)

  static SetGreenGain(GreenGain, Display := "") => this.SetSetting("SetMonitorGreenGain", GreenGain, Display)

  static SetBlueGain(BlueGain, Display := "") => this.SetSetting("SetMonitorBlueGain", BlueGain, Display)

  static SetDisplayAreaWidth(DisplayAreaWidth, Display := "") => this.SetSetting("SetMonitorDisplayAreaWidth", DisplayAreaWidth, Display)

  static SetDisplayAreaHeight(DisplayAreaHeight, Display := "") => this.SetSetting("SetMonitorDisplayAreaHeight", DisplayAreaHeight, Display)

  static SetDisplayAreaPositionHorizontal(DisplayAreaPositionHorizontal, Display := "") => this.SetSetting("SetMonitorDisplayAreaPositionHorizontal", DisplayAreaPositionHorizontal, Display)

  static SetDisplayAreaPositionVertical(DisplayAreaPositionVertical, Display := "") => this.SetSetting("SetMonitorDisplayAreaPositionVertical", DisplayAreaPositionVertical, Display)

  static SetVCPFeature(VCPCode, NewValue, Display := "") => this.SetSetting("SetMonitorVCPFeature", VCPCode, Display, NewValue)

  static SetSharpness(Sharpness, Display := "") => this.SetSetting("SetMonitorVCPFeature", 0x87, Display, Sharpness)

  static SetColorTemperature(ColorTemperature, Display := "") {

      static MC_COLOR_TEMPERATURE := Map(
          0x00000000, "Unknown temperature.",
          0x00000001, "4,000 kelvins (K).",
          0x00000002, "5,000 kelvins (K).",
          0x00000004, "6,500 kelvins (K).",
          0x00000008, "7,500 kelvins (K).",
          0x00000010, "8,200 kelvins (K).",
          0x00000020, "9,300 kelvins (K).",
          0x00000040, "10,000 kelvins (K).",
          0x00000080, "11,500 kelvins (K).")

      return MC_COLOR_TEMPERATURE[this.SetSetting("SetMonitorColorTemperature", ColorTemperature, Display)]
    }

  static SetPowerMode(PowerMode, Display := "") {

      static PowerModes := Map(
          "On", 0x01,
          "Standby", 0x02,
          "Suspend", 0x03,
          "Off", 0x04,
          "PowerOff", 0x05)

      if (PowerModes.Has(PowerMode))
        if (this.SetSetting("SetMonitorVCPFeature", 0xD6, Display, PowerModes[PowerMode]))
          return PowerMode
      throw Error("An invalid [PowerMode] parameter was passed to the SetPowerMode() Method.")
    }

  ; ===== VOID METHODS ===== ;

  static Degauss(Display := "") => this.VoidSetting("DegaussMonitor", Display)

  static RestoreFactoryDefaults(Display := "") => this.VoidSetting("RestoreMonitorFactoryDefaults", Display)

  static RestoreFactoryColorDefaults(Display := "") => this.VoidSetting("RestoreMonitorFactoryColorDefaults", Display)

  static SaveCurrentSettings(Display := "") => this.VoidSetting("SaveCurrentMonitorSettings", Display)

  ; ===== PRIVATE METHODS ============================================================================= ;

  ; ===== CORE MONITOR METHODS ===== ;

  static EnumDisplayMonitors(hMonitor := "") {

      static EnumProc := CallbackCreate(MonitorEnumProc, , 4)
      static DisplayMonitors := []

      if (!DisplayMonitors.Length)
        if !(DllCall("user32\EnumDisplayMonitors", "ptr", 0, "ptr", 0, "ptr", EnumProc, "ptr", ObjPtr(DisplayMonitors), "uint"))
          return false
      return DisplayMonitors

      MonitorEnumProc(hMonitor, hDC, pRECT, ObjectAddr) {

        DisplayMonitors := ObjFromPtrAddRef(ObjectAddr)
        MonitorData := Monitor.GetMonitorInfo(hMonitor)
        DisplayMonitors.Push(MonitorData)
        return true
      }
    }

  static GetMonitorInfo(hMonitor) {	; (MONITORINFO = 40 byte struct) + (MONITORINFOEX = 64 bytes)

      NumPut("uint", 104, MONITORINFOEX := Buffer(104))
      if (DllCall("user32\GetMonitorInfo", "ptr", hMonitor, "ptr", MONITORINFOEX)) {
        MONITORINFO := Map()
        MONITORINFO["Handle"] := hMonitor
        MONITORINFO["Name"] := Name := StrGet(MONITORINFOEX.Ptr + 40, 32)
        MONITORINFO["Number"] := RegExReplace(Name, ".*(\d+)$", "$1")
        MONITORINFO["Left"] := NumGet(MONITORINFOEX, 4, "int")
        MONITORINFO["Top"] := NumGet(MONITORINFOEX, 8, "int")
        MONITORINFO["Right"] := NumGet(MONITORINFOEX, 12, "int")
        MONITORINFO["Bottom"] := NumGet(MONITORINFOEX, 16, "int")
        MONITORINFO["WALeft"] := NumGet(MONITORINFOEX, 20, "int")
        MONITORINFO["WATop"] := NumGet(MONITORINFOEX, 24, "int")
        MONITORINFO["WARight"] := NumGet(MONITORINFOEX, 28, "int")
        MONITORINFO["WABottom"] := NumGet(MONITORINFOEX, 32, "int")
        MONITORINFO["Primary"] := NumGet(MONITORINFOEX, 36, "uint")
        return MONITORINFO
      }
      throw OSError()
    }

  static GetMonitorHandle(Display := "", hMonitor := 0, hWindow := 0) {

      MonitorInfo := this.EnumDisplayMonitors()
      if (Display != "") {
        for Info in MonitorInfo {
          if (InStr(Info["Name"], Display)) {
            hMonitor := Info["Handle"]
            break
          }
        }
      }

      if (!hMonitor)	;	MONITOR_DEFAULTTONEAREST = 0x00000002
        hMonitor := DllCall("user32\MonitorFromWindow", "ptr", hWindow, "uint", 0x00000002)
      return hMonitor
    }

  static GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor, NumberOfPhysicalMonitors := 0) {

      if (DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "ptr", hMonitor, "uint*", &NumberOfPhysicalMonitors))
        return NumberOfPhysicalMonitors
      return false
    }

  static GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitorArraySize, &PHYSICAL_MONITOR) {

      PHYSICAL_MONITOR := Buffer((A_PtrSize + 256) * PhysicalMonitorArraySize, 0)
      if (DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "ptr", hMonitor, "uint", PhysicalMonitorArraySize, "ptr", PHYSICAL_MONITOR))
        return NumGet(PHYSICAL_MONITOR, "ptr")
      return false
    }

  static DestroyPhysicalMonitors(PhysicalMonitorArraySize, PHYSICAL_MONITOR) {

      if (DllCall("dxva2\DestroyPhysicalMonitors", "uint", PhysicalMonitorArraySize, "ptr", PHYSICAL_MONITOR))
        return true
      return false
    }

  static CreateDC(DisplayName) {

      if (hDC := DllCall("gdi32\CreateDC", "str", DisplayName, "ptr", 0, "ptr", 0, "ptr", 0, "ptr"))
        return hDC
      return false
    }

  static DeleteDC(hDC) {

      if (DllCall("gdi32\DeleteDC", "ptr", hDC))
        return true
      return false
    }

  ; ===== HELPER METHODS ===== ;

  static GetSetting(GetMethodName, Display := "", params*) {

      if (hMonitor := this.GetMonitorHandle(Display)) {
        PHYSICAL_MONITOR := ""
        PhysicalMonitors := this.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor)
        hPhysicalMonitor := this.GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR)
        Setting := this.%GetMethodName%(hPhysicalMonitor, params*)
        this.DestroyPhysicalMonitors(PhysicalMonitors, PHYSICAL_MONITOR)
        return Setting
      }
      throw OSError()
    }

  static SetSetting(SetMethodName, Setting, Display := "", params*) {

      if (hMonitor := this.GetMonitorHandle(Display)) {
        PHYSICAL_MONITOR := ""
        PhysicalMonitors := this.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor)
        hPhysicalMonitor := this.GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR)

        if (SetMethodName = "SetMonitorVCPFeature" || SetMethodName = "SetMonitorColorTemperature") {
          Setting := this.%SetMethodName%(hPhysicalMonitor, Setting, params*)
          this.DestroyPhysicalMonitors(PhysicalMonitors, PHYSICAL_MONITOR)
          return Setting
        } else {
          GetMethodName := RegExReplace(SetMethodName, "S(.*)", "G$1")
          GetSetting := this.%GetMethodName%(hPhysicalMonitor)
          Setting := (Setting < GetSetting["Minimum"]) ? GetSetting["Minimum"]
            : (Setting > GetSetting["Maximum"]) ? GetSetting["Maximum"]
              : (Setting)
          this.%SetMethodName%(hPhysicalMonitor, Setting)
          this.DestroyPhysicalMonitors(PhysicalMonitors, PHYSICAL_MONITOR)
          return Setting
        }

      }
      throw OSError()
    }

  static VoidSetting(VoidMethodName, Display := "") {

      if (hMonitor := this.GetMonitorHandle(Display)) {
        PHYSICAL_MONITOR := ""
        PhysicalMonitors := this.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor)
        hPhysicalMonitor := this.GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR)
        bool := this.%VoidMethodName%(hPhysicalMonitor)
        this.DestroyPhysicalMonitors(PhysicalMonitors, PHYSICAL_MONITOR)
        return bool
      }
      throw OSError()
    }

  static GammaSetting(GammaMethodName, Red := "", Green := "", Blue := "", Display := "", DisplayName := "") {

      if (Display = "" && MonitorInfo := this.EnumDisplayMonitors()) {
        for Info in MonitorInfo {
          if (Info["Primary"]) {
            PrimaryMonitor := A_Index
            break
          }
        }
      }

      if (DisplayName := MonitorInfo[Display ? Display : PrimaryMonitor]["Name"]) {
        if (hDC := this.CreateDC(DisplayName)) {
          if (GammaMethodName = "SetDeviceGammaRamp") {
            for Color in ["Red", "Green", "Blue"] {
              %Color% := (%Color% < 0) ? 0
                  : (%Color% > 100) ? 100
                    : (%Color%)
                %Color% := Round((2.56 * %Color%) - 128, 1)	; convert to decimal
            }
            this.SetDeviceGammaRamp(hDC, Red, Green, Blue)
            this.DeleteDC(hDC)

            for Color in ["Red", "Green", "Blue"]
              %Color% := Round((%Color% +128) / 2.56, 1)	; convert back to percentage

            return Map("Red", Red, "Green", Green, "Blue", Blue)
          } else {	; if (GammaMethodName = "GetDeviceGammaRamp")
            GammaRamp := this.GetDeviceGammaRamp(hDC)
            for Color, GammaLevel in GammaRamp
              GammaRamp[Color] := Round((GammaLevel + 128) / 2.56, 1)	; convert to percentage
            this.DeleteDC(hDC)
            return GammaRamp
          }

        }
        this.DeleteDC(hDC)
        throw OSError()
      }

    }

  ; ===== GET METHODS ===== ;

  static GetMonitorBrightness(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {

      if (DllCall("dxva2\GetMonitorBrightness", "ptr", hMonitor, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorContrast(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {

      if (DllCall("dxva2\GetMonitorContrast", "ptr", hMonitor, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetDeviceGammaRamp(hMonitor) {

      if (DllCall("gdi32\GetDeviceGammaRamp", "ptr", hMonitor, "ptr", GAMMA_RAMP := Buffer(1536)))
        return Map(
          "Red", NumGet(GAMMA_RAMP, 2, "ushort") - 128,
          "Green", NumGet(GAMMA_RAMP, 512 + 2, "ushort") - 128,
          "Blue", NumGet(GAMMA_RAMP, 1024 + 2, "ushort") - 128)
      throw OSError()
    }

  static GetMonitorRedDrive(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_RED_DRIVE = 0x00000000

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000000, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorGreenDrive(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_GREEN_DRIVE = 0x00000001

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000001, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorBlueDrive(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_BLUE_DRIVE = 0x00000002

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000002, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      MsgBox "Failed"
      throw OSError()
    }

  static GetMonitorRedGain(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_RED_GAIN = 0x00000000

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000000, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorGreenGain(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_GREEN_GAIN = 0x00000001

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000001, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorBlueGain(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_BLUE_GAIN = 0x00000002

      if (DllCall("dxva2\GetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000002, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorDisplayAreaWidth(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_WIDTH = 0x00000000

      if (DllCall("dxva2\GetMonitorDisplayAreaSize", "ptr", hMonitor, "ptr", 0x00000000, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorDisplayAreaHeight(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_HEIGHT = 0x00000001

      if (DllCall("dxva2\GetMonitorDisplayAreaSize", "ptr", hMonitor, "ptr", 0x00000001, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorDisplayAreaPositionHorizontal(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_HORIZONTAL_POSITION = 0x00000000

      if (DllCall("dxva2\GetMonitorDisplayAreaPosition", "ptr", hMonitor, "ptr", 0x00000000, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetMonitorDisplayAreaPositionVertical(hMonitor, Minimum := 0, Current := 0, Maximum := 0) {	;	MC_VERTICAL_POSITION = 0x00000001

      if (DllCall("dxva2\GetMonitorDisplayAreaPosition", "ptr", hMonitor, "ptr", 0x00000001, "uint*", &Minimum, "uint*", &Current, "uint*", &Maximum))
        return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
      throw OSError()
    }

  static GetVCPFeatureAndVCPFeatureReply(hMonitor, VCPCode, vct := 0, CurrentValue := 0, MaximumValue := 0) {

      static VCP_CODE_TYPE := Map(
          0x00000000, "MC_MOMENTARY — Momentary VCP code. Sending a command of this type causes the monitor to initiate a self-timed operation and then revert to its original state. Examples include display tests and degaussing.",
          0x00000001, "MC_SET_PARAMETER — Set Parameter VCP code. Sending a command of this type changes some aspect of the monitor's operation.")

      if (DllCall("dxva2\GetVCPFeatureAndVCPFeatureReply", "ptr", hMonitor, "ptr", VCPCode, "uint*", &vct, "uint*", &CurrentValue, "uint*", &MaximumValue))
        return Map("VCPCode", Format("0x{:X}", VCPCode),
          "VCPCodeType", VCP_CODE_TYPE[vct],
          "Current", CurrentValue,
          "Maximum", (MaximumValue ? MaximumValue : "Undefined due to non-continuous (NC) VCP Code."))
      throw OSError()
    }

  static GetMonitorCapabilitiesStringLength(hMonitor, CapabilitiesStrLen := 0) {

      if (DllCall("dxva2\GetCapabilitiesStringLength", "ptr", hMonitor, "uint*", &CapabilitiesStrLen))
        return CapabilitiesStrLen
      throw OSError()
    }

  static MonitorCapabilitiesRequestAndCapabilitiesReply(hMonitor, ASCIICapabilitiesString := "", CapabilitiesStrLen := 0) {

      CapabilitiesStrLen := this.GetMonitorCapabilitiesStringLength(hMonitor)
      ASCIICapabilitiesString := Buffer(CapabilitiesStrLen)
      if (DllCall("dxva2\GetCapabilitiesStringLength", "ptr", hMonitor, "ptr", ASCIICapabilitiesString.Ptr, "uint", CapabilitiesStrLen))
        return ASCIICapabilitiesString
      throw OSError()
    }

  static GetMonitorCapabilities(hMonitor, MonitorCapabilities := 0, SupportedColorTemperatures := 0) {

      if (DllCall("dxva2\GetMonitorCapabilities", "ptr", hMonitor, "uint*", &MonitorCapabilities, "uint*", &SupportedColorTemperatures))
        return Map("MonitorCapabilities", MonitorCapabilities,
          "SupportedColorTemperatures", SupportedColorTemperatures)
      throw OSError()
    }

  static GetMonitorColorTemperature(hMonitor, CurrentColorTemperature := 0) {

      if (DllCall("dxva2\GetMonitorColorTemperature", "ptr", hMonitor, "uint*", &CurrentColorTemperature))
        return CurrentColorTemperature
      throw OSError()
    }

  static GetMonitorTechnologyType(hMonitor, DisplayTechnologyType := 0) {

      if (DllCall("dxva2\GetMonitorTechnologyType", "ptr", hMonitor, "uint*", &DisplayTechnologyType))
        return DisplayTechnologyType
      throw OSError()
    }

  ; ===== SET METHODS ===== ;

  static SetMonitorBrightness(hMonitor, Brightness) {

      if (DllCall("dxva2\SetMonitorBrightness", "ptr", hMonitor, "uint", Brightness))
        return Brightness
      throw OSError()
    }

  static SetMonitorContrast(hMonitor, Contrast) {

      if (DllCall("dxva2\SetMonitorContrast", "ptr", hMonitor, "uint", Contrast))
        return Contrast
      throw OSError()
    }

  static SetDeviceGammaRamp(hMonitor, red, green, blue) {

      GAMMA_RAMP := Buffer(1536)
      while ((i := A_Index - 1) < 256) {
        NumPut("ushort", (r := (red + 128) * i) > 65535 ? 65535 : r, GAMMA_RAMP, 2 * i)
        NumPut("ushort", (g := (green + 128) * i) > 65535 ? 65535 : g, GAMMA_RAMP, 512 + 2 * i)
        NumPut("ushort", (b := (blue + 128) * i) > 65535 ? 65535 : b, GAMMA_RAMP, 1024 + 2 * i)
      }
      if (DllCall("gdi32\SetDeviceGammaRamp", "ptr", hMonitor, "ptr", GAMMA_RAMP))
        return true
      throw OSError()
    }

  static SetMonitorRedDrive(hMonitor, RedDrive) {	;	MC_RED_DRIVE = 0x00000000

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000000, "uint", RedDrive))
        return true
      throw OSError()
    }

  static SetMonitorGreenDrive(hMonitor, GreenDrive) {	;	MC_GREEN_DRIVE = 0x00000001

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000001, "uint", GreenDrive))
        return true
      throw OSError()
    }

  static SetMonitorBlueDrive(hMonitor, BlueDrive) {	;	MC_BLUE_DRIVE = 0x00000002

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueDrive", "ptr", hMonitor, "ptr", 0x00000002, "uint", BlueDrive))
        return true
      throw OSError()
    }

  static SetMonitorRedGain(hMonitor, RedGain) {	;	MC_RED_GAIN = 0x00000000

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000000, "uint", RedGain))
        return true
      throw OSError()
    }

  static SetMonitorGreenGain(hMonitor, GreenGain) {	;	MC_GREEN_GAIN = 0x00000001

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000001, "uint", GreenGain))
        return true
      throw OSError()
    }

  static SetMonitorBlueGain(hMonitor, BlueGain) {	;	MC_BLUE_GAIN = 0x00000002

      if (DllCall("dxva2\SetMonitorRedGreenOrBlueGain", "ptr", hMonitor, "ptr", 0x00000002, "uint", BlueGain))
        return true
      throw OSError()
    }

  static SetMonitorDisplayAreaWidth(hMonitor, DisplayAreaWidth) {	;	MC_WIDTH = 0x00000000

      if (DllCall("dxva2\SetMonitorDisplayAreaSize", "ptr", hMonitor, "ptr", 0x00000000, "uint", DisplayAreaWidth))
        return true
      throw OSError()
    }

  static SetMonitorDisplayAreaHeight(hMonitor, DisplayAreaHeight) {	;	MC_HEIGHT = 0x00000001

      if (DllCall("dxva2\SetMonitorDisplayAreaSize", "ptr", hMonitor, "ptr", 0x00000001, "uint", DisplayAreaHeight))
        return true
      throw OSError()
    }

  static SetMonitorDisplayAreaPositionHorizontal(hMonitor, NewHorizontalPosition) {	;	MC_HORIZONTAL_POSITION = 0x00000000

      if (DllCall("dxva2\SetMonitorDisplayAreaPosition", "ptr", hMonitor, "ptr", 0x00000000, "uint", NewHorizontalPosition))
        return true
      throw OSError()
    }

  static SetMonitorDisplayAreaPositionVertical(hMonitor, NewVerticalPosition) {	;	MC_VERTICAL_POSITION = 0x00000001

      if (DllCall("dxva2\SetMonitorDisplayAreaPosition", "ptr", hMonitor, "ptr", 0x00000001, "uint", NewVerticalPosition))
        return true
      throw OSError()
    }

  static SetMonitorVCPFeature(hMonitor, VCPCode, NewValue) {

      if (DllCall("dxva2\SetVCPFeature", "ptr", hMonitor, "ptr", VCPCode, "uint", NewValue))
        return Map("VCPCode", Format("0x{:X}", VCPCode), "NewValue", NewValue)
      throw OSError()
    }

  static SetMonitorColorTemperature(hMonitor, CurrentColorTemperature) {

      if (DllCall("dxva2\SetMonitorColorTemperature", "ptr", hMonitor, "uint", CurrentColorTemperature))
        return CurrentColorTemperature
      throw OSError()
    }

  ; ===== VOID METHODS ===== ;

  static DegaussMonitor(hMonitor) {

      if (DllCall("dxva2\DegaussMonitor", "ptr", hMonitor))
        return true
      throw OSError()
    }

  static RestoreMonitorFactoryDefaults(hMonitor) {

      if (DllCall("dxva2\RestoreMonitorFactoryDefaults", "ptr", hMonitor))
        return true
      throw OSError()
    }

  static RestoreMonitorFactoryColorDefaults(hMonitor) {

      if (DllCall("dxva2\RestoreMonitorFactoryColorDefaults", "ptr", hMonitor))
        return true
      throw OSError()
    }

  static SaveCurrentMonitorSettings(hMonitor) {

    if (DllCall("dxva2\RestoreMonitorFactoryDefaults", "ptr", hMonitor))
      return true
    throw OSError()
  }
}
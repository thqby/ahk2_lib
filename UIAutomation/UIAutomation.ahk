/************************************************************************
 * @description UI Automation class wrapper, based on https://github.com/neptercn/UIAutomation/blob/master/UIA2.ahk
 * @file UIAutomation.ahk
 * @author thqby, neptercn(v1 version)
 * @date 2021/10/21
 * @version 1.0.12
 ***********************************************************************/

#Include <BSTR>
#Include <ComVar>

; NativeArray is C style array, zero-based index, it has `__Item` and `__Enum` property
class NativeArray {
	__New(ptr, count, type := "ptr") {
		static _ := DllCall("LoadLibrary", "str", "ole32.dll")
		static bits := { UInt: 4, UInt64: 8, Int: 4, Int64: 8, Short: 2, UShort: 2, Char: 1, UChar: 1, Double: 8, Float: 4, Ptr: A_PtrSize, UPtr: A_PtrSize }
		this.size := (this.count := count) * (bit := bits.%type%), this.ptr := ptr || DllCall("ole32\CoTaskMemAlloc", "uint", this.size, "ptr")
		this.DefineProp("__Item", { get: (s, i) => NumGet(s, i * bit, type) })
		this.DefineProp("__Enum", { call: (s, i) => (i = 1 ?
				(i := 0, (&v) => i < count ? (v := NumGet(s, i * bit, type), ++i) : false) :
					(i := 0, (&k, &v) => (i < count ? (k := i, v := NumGet(s, i * bit, type), ++i) : false))
			) })
	}
	__Delete() => DllCall("ole32\CoTaskMemFree", "ptr", this)
}

class IUIABase {
	__New(ptr) {
		if !(this.ptr := ptr)
			throw ValueError('Invalid IUnknown interface pointer', -2, this.__Class)
	}
	__Delete() => this.Release()
	__Item => (ObjAddRef(this.ptr), ComValue(0xd, this.ptr))
	AddRef() => ObjAddRef(this.ptr)
	Release() => this.ptr ? ObjRelease(this.ptr) : 0
}

class UIA {
	static ptr := ComObjValue(this.__ := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"))
	static ControlType := { Button: 50000, Calendar: 50001, CheckBox: 50002, ComboBox: 50003, Edit: 50004, Hyperlink: 50005, Image: 50006, ListItem: 50007, List: 50008, Menu: 50009, MenuBar: 50010, MenuItem: 50011, ProgressBar: 50012, RadioButton: 50013, ScrollBar: 50014, Slider: 50015, Spinner: 50016, StatusBar: 50017, Tab: 50018, TabItem: 50019, Text: 50020, ToolBar: 50021, ToolTip: 50022, Tree: 50023, TreeItem: 50024, Custom: 50025, Group: 50026, Thumb: 50027, DataGrid: 50028, DataItem: 50029, Document: 50030, SplitButton: 50031, Window: 50032, Pane: 50033, Header: 50034, HeaderItem: 50035, Table: 50036, TitleBar: 50037, Separator: 50038, SemanticZoom: 50039, AppBar: 50040 }
	static ControlPattern := { Invoke: 10000, Selection: 10001, Value: 10002, RangeValue: 10003, Scroll: 10004, ExpandCollapse: 10005, Grid: 10006, GridItem: 10007, MultipleView: 10008, Window: 10009, SelectionItem: 10010, Dock: 10011, Table: 10012, TableItem: 10013, Text: 10014, Toggle: 10015, Transform: 10016, ScrollItem: 10017, LegacyIAccessible: 10018, ItemContainer: 10019, VirtualizedItem: 10020, SynchronizedInput: 10021, ObjectModel: 10022, Annotation: 10023, Styles: 10025, Spreadsheet: 10026, SpreadsheetItem: 10027, TextChild: 10029, Drag: 10030, DropTarget: 10031, TextEdit: 10032, CustomNavigation: 10033,
		10000: "Invoke", 10001: "Selection", 10002: "Value", 10003: "RangeValue", 10004: "Scroll", 10005: "ExpandCollapse", 10006: "Grid", 10007: "GridItem", 10008: "MultipleView", 10009: "Window", 10010: "SelectionItem", 10011: "Dock", 10012: "Table", 10013: "TableItem", 10014: "Text", 10015: "Toggle", 10016: "Transform", 10017: "ScrollItem", 10018: "LegacyIAccessible", 10019: "ItemContainer", 10020: "VirtualizedItem", 10021: "SynchronizedInput", 10022: "ObjectModel", 10023: "Annotation", 10025: "Styles", 10026: "Spreadsheet", 10027: "SpreadsheetItem", 10029: "TextChild", 10030: "Drag", 10031: "DropTarget", 10032: "TextEdit", 10033: "CustomNavigation" }
	static Event := { ToolTipOpened: 20000, ToolTipClosed: 20001, StructureChanged: 20002, MenuOpened: 20003, AutomationPropertyChanged: 20004, AutomationFocusChanged: 20005, AsyncContentLoaded: 20006, MenuClosed: 20007, LayoutInvalidated: 20008, Invoke_Invoked: 20009, SelectionItem_ElementAddedToSelection: 20010, SelectionItem_ElementRemovedFromSelection: 20011, SelectionItem_ElementSelected: 20012, Selection_Invalidated: 20013, Text_TextSelectionChanged: 20014, Text_TextChanged: 20015, Window_WindowOpened: 20016, Window_WindowClosed: 20017, MenuModeStart: 20018, MenuModeEnd: 20019, InputReachedTarget: 20020, InputReachedOtherElement: 20021, InputDiscarded: 20022, SystemAlert: 20023, LiveRegionChanged: 20024, HostedFragmentRootsInvalidated: 20025, Drag_DragStart: 20026, Drag_DragCancel: 20027, Drag_DragComplete: 20028, DropTarget_DragEnter: 20029, DropTarget_DragLeave: 20030, DropTarget_Dropped: 20031, TextEdit_TextChanged: 20032, TextEdit_ConversionTargetChanged: 20033, Changes: 20034, Notification: 20035, ActiveTextPositionChanged: 20036 }
	static Property := {
		RuntimeId: 30000,	; VT_I4 | VT_ARRAY (VT_EMPTY)
		BoundingRectangle: 30001,	; VT_R8 | VT_ARRAY ([0,0,0,0])
		ProcessId: 30002,	; VT_I4 (0)
		ControlType: 30003,	; VT_I4 (UIA_CustomControlTypeId)
		LocalizedControlType: 30004,	; VT_BSTR (empty string) The string should contain only lowercase characters. Correct: "button", Incorrect: "Button"
		Name: 30005,	; VT_BSTR (empty string)
		AcceleratorKey: 30006,	; VT_BSTR (empty string)
		AccessKey: 30007,	; VT_BSTR (empty string)
		HasKeyboardFocus: 30008,	; VT_BOOL (FALSE)
		IsKeyboardFocusable: 30009,	; VT_BOOL (FALSE)
		IsEnabled: 30010,	; VT_BOOL (FALSE)
		AutomationId: 30011,	; VT_BSTR (empty string)
		ClassName: 30012,	; VT_BSTR (empty string)
		HelpText: 30013,	; VT_BSTR (empty string)
		ClickablePoint: 30014,	; VT_R8 | VT_ARRAY (VT_EMPTY)
		Culture: 30015,	; VT_I4 (0)
		IsControlElement: 30016,	; VT_BOOL (TRUE)
		IsContentElement: 30017,	; VT_BOOL (TRUE)
		LabeledBy: 30018,	; VT_UNKNOWN (NULL)
		IsPassword: 30019,	; VT_BOOL (FALSE)
		NativeWindowHandle: 30020,	; VT_I4 (0)
		ItemType: 30021,	; VT_BSTR (empty string)
		IsOffscreen: 30022,	; VT_BOOL (FALSE)
		Orientation: 30023,	; VT_I4 (0 (OrientationType_None))
		FrameworkId: 30024,	; VT_BSTR (empty string)
		IsRequiredForForm: 30025,	; VT_BOOL (FALSE)
		ItemStatus: 30026,	; VT_BSTR (empty string)
		IsDockPatternAvailable: 30027,	; VT_BOOL
		IsExpandCollapsePatternAvailable: 30028,	; VT_BOOL
		IsGridItemPatternAvailable: 30029,	; VT_BOOL
		IsGridPatternAvailable: 30030,	; VT_BOOL
		IsInvokePatternAvailable: 30031,	; VT_BOOL
		IsMultipleViewPatternAvailable: 30032,	; VT_BOOL
		IsRangeValuePatternAvailable: 30033,	; VT_BOOL
		IsScrollPatternAvailable: 30034,	; VT_BOOL
		IsScrollItemPatternAvailable: 30035,	; VT_BOOL
		IsSelectionItemPatternAvailable: 30036,	; VT_BOOL
		IsSelectionPatternAvailable: 30037,	; VT_BOOL
		IsTablePatternAvailable: 30038,	; VT_BOOL
		IsTableItemPatternAvailable: 30039,	; VT_BOOL
		IsTextPatternAvailable: 30040,	; VT_BOOL
		IsTogglePatternAvailable: 30041,	; VT_BOOL
		IsTransformPatternAvailable: 30042,	; VT_BOOL
		IsValuePatternAvailable: 30043,	; VT_BOOL
		IsWindowPatternAvailable: 30044,	; VT_BOOL
		ValueValue: 30045,	; VT_BSTR (empty string)
		ValueIsReadOnly: 30046,	; VT_BOOL (TRUE)
		RangeValueValue: 30047,	; VT_R8 (0)
		RangeValueIsReadOnly: 30048,	; VT_BOOL (TRUE)
		RangeValueMinimum: 30049,	; VT_R8 (0)
		RangeValueMaximum: 30050,	; VT_R8 (0)
		RangeValueLargeChange: 30051,	; VT_R8 (0)
		RangeValueSmallChange: 30052,	; VT_R8 (0)
		ScrollHorizontalScrollPercent: 30053,	; VT_R8 (0)
		ScrollHorizontalViewSize: 30054,	; VT_R8 (100)
		ScrollVerticalScrollPercent: 30055,	; VT_R8 (0)
		ScrollVerticalViewSize: 30056,	; VT_R8 (100)
		ScrollHorizontallyScrollable: 30057,	; VT_BOOL (FALSE)
		ScrollVerticallyScrollable: 30058,	; VT_BOOL (FALSE)
		SelectionSelection: 30059,	; VT_UNKNOWN | VT_ARRAY (empty array)
		SelectionCanSelectMultiple: 30060,	; VT_BOOL (FALSE)
		SelectionIsSelectionRequired: 30061,	; VT_BOOL (FALSE)
		GridRowCount: 30062,	; VT_I4 (0)
		GridColumnCount: 30063,	; VT_I4 (0)
		GridItemRow: 30064,	; VT_I4 (0)
		GridItemColumn: 30065,	; VT_I4 (0)
		GridItemRowSpan: 30066,	; VT_I4 (1)
		GridItemColumnSpan: 30067,	; VT_I4 (1)
		GridItemContainingGrid: 30068,	; VT_UNKNOWN (NULL)
		DockDockPosition: 30069,	; VT_I4 (DockPosition_None)
		ExpandCollapseExpandCollapseState: 30070,	; VT_I4 (ExpandCollapseState_LeafNode)
		MultipleViewCurrentView: 30071,	; VT_I4 (0)
		MultipleViewSupportedViews: 30072,	; VT_I4 | VT_ARRAY (empty array)
		WindowCanMaximize: 30073,	; VT_BOOL (FALSE)
		WindowCanMinimize: 30074,	; VT_BOOL (FALSE)
		WindowWindowVisualState: 30075,	; VT_I4 (WindowVisualState_Normal)
		WindowWindowInteractionState: 30076,	; VT_I4 (WindowInteractionState_Running)
		WindowIsModal: 30077,	; VT_BOOL (FALSE)
		WindowIsTopmost: 30078,	; VT_BOOL (FALSE)
		SelectionItemIsSelected: 30079,	; VT_BOOL (FALSE)
		SelectionItemSelectionContainer: 30080,	; VT_UNKNOWN (NULL)
		TableRowHeaders: 30081,	; VT_UNKNOWN | VT_ARRAY (empty array)
		TableColumnHeaders: 30082,	; VT_UNKNOWN | VT_ARRAY (empty array)
		TableRowOrColumnMajor: 30083,	; VT_I4 (RowOrColumnMajor_Indeterminate)
		TableItemRowHeaderItems: 30084,	; VT_UNKNOWN | VT_ARRAY (empty array)
		TableItemColumnHeaderItems: 30085,	; VT_UNKNOWN | VT_ARRAY (empty array)
		ToggleToggleState: 30086,	; VT_I4 (ToggleState_Indeterminate)
		TransformCanMove: 30087,	; VT_BOOL (FALSE)
		TransformCanResize: 30088,	; VT_BOOL (FALSE)
		TransformCanRotate: 30089,	; VT_BOOL (FALSE)
		IsLegacyIAccessiblePatternAvailable: 30090,	; VT_BOOL
		LegacyIAccessibleChildId: 30091,	; VT_I4 (0)
		LegacyIAccessibleName: 30092,	; VT_BSTR (empty string)
		LegacyIAccessibleValue: 30093,	; VT_BSTR (empty string)
		LegacyIAccessibleDescription: 30094,	; VT_BSTR (empty string)
		LegacyIAccessibleRole: 30095,	; VT_I4 (0)
		LegacyIAccessibleState: 30096,	; VT_I4 (0)
		LegacyIAccessibleHelp: 30097,	; VT_BSTR (empty string)
		LegacyIAccessibleKeyboardShortcut: 30098,	; VT_BSTR (empty string)
		LegacyIAccessibleSelection: 30099,	; VT_UNKNOWN | VT_ARRAY (empty array)
		LegacyIAccessibleDefaultAction: 30100,	; VT_BSTR (empty string)
		AriaRole: 30101,	; VT_BSTR (empty string)
		AriaProperties: 30102,	; VT_BSTR (empty string)
		IsDataValidForForm: 30103,	; VT_BOOL (FALSE)
		ControllerFor: 30104,	; VT_UNKNOWN | VT_ARRAY (empty array)
		DescribedBy: 30105,	; VT_UNKNOWN | VT_ARRAY (empty array)
		FlowsTo: 30106,	; VT_UNKNOWN | VT_ARRAY (empty array)
		ProviderDescription: 30107,	; VT_BSTR (empty string)
		IsItemContainerPatternAvailable: 30108,	; VT_BOOL
		IsVirtualizedItemPatternAvailable: 30109,	; VT_BOOL
		IsSynchronizedInputPatternAvailable: 30110,	; VT_BOOL
		OptimizeForVisualContent: 30111,	; VT_BOOL (FALSE)
		IsObjectModelPatternAvailable: 30112,	; VT_BOOL
		AnnotationAnnotationTypeId: 30113,	; VT_I4 (0)
		AnnotationAnnotationTypeName: 30114,	; VT_BSTR (empty string)
		AnnotationAuthor: 30115,	; VT_BSTR (empty string)
		AnnotationDateTime: 30116,	; VT_BSTR (empty string)
		AnnotationTarget: 30117,	; VT_UNKNOWN (NULL)
		IsAnnotationPatternAvailable: 30118,	; VT_BOOL
		IsTextPattern2Available: 30119,	; VT_BOOL
		StylesStyleId: 30120,	; VT_I4 (0)
		StylesStyleName: 30121,	; VT_BSTR (empty string)
		StylesFillColor: 30122,	; VT_I4 (0)
		StylesFillPatternStyle: 30123,	; VT_BSTR (empty string)
		StylesShape: 30124,	; VT_BSTR (empty string)
		StylesFillPatternColor: 30125,	; VT_I4 (0)
		StylesExtendedProperties: 30126,	; VT_BSTR (empty string)
		IsStylesPatternAvailable: 30127,	; VT_BOOL
		IsSpreadsheetPatternAvailable: 30128,	; VT_BOOL
		SpreadsheetItemFormula: 30129,	; VT_BSTR (empty string)
		SpreadsheetItemAnnotationObjects: 30130,	; VT_UNKNOWN | VT_ARRAY (empty array)
		SpreadsheetItemAnnotationTypes: 30131,	; VT_I4 | VT_ARRAY (empty array)
		IsSpreadsheetItemPatternAvailable: 30132,	; VT_BOOL
		Transform2CanZoom: 30133,	; VT_BOOL (FALSE)
		IsTransformPattern2Available: 30134,	; VT_BOOL
		LiveSetting: 30135,	; VT_I4 (0)
		IsTextChildPatternAvailable: 30136,	; VT_BOOL
		IsDragPatternAvailable: 30137,	; VT_BOOL
		DragIsGrabbed: 30138,	; VT_BOOL (FALSE)
		DragDropEffect: 30139,	; VT_BSTR (empty string)
		DragDropEffects: 30140,	; VT_BSTR | VT_ARRAY (empty array)
		IsDropTargetPatternAvailable: 30141,	; VT_BOOL
		DropTargetDropTargetEffect: 30142,	; VT_BSTR (empty string)
		DropTargetDropTargetEffects: 30143,	; VT_BSTR | VT_ARRAY (empty array)
		DragGrabbedItems: 30144,	; VT_UNKNOWN | VT_ARRAY (empty array)
		Transform2ZoomLevel: 30145,	; VT_R8 (1)
		Transform2ZoomMinimum: 30146,	; VT_R8 (1)
		Transform2ZoomMaximum: 30147,	; VT_R8 (1)
		FlowsFrom: 30148,	; VT_UNKNOWN | VT_ARRAY (empty array)
		IsTextEditPatternAvailable: 30149,	; VT_BOOL
		IsPeripheral: 30150,	; VT_BOOL (FALSE)
		IsCustomNavigationPatternAvailable: 30151,	; VT_BOOL
		PositionInSet: 30152,	; VT_I4 (0)
		SizeOfSet: 30153,	; VT_I4 (0)
		Level: 30154,	; VT_I4 (0)
		AnnotationTypes: 30155,	; VT_I4 | VT_ARRAY (empty array)
		AnnotationObjects: 30156,	; VT_I4 | VT_ARRAY (empty array)
		LandmarkType: 30157,	; VT_I4 (0)
		LocalizedLandmarkType: 30158,	; VT_BSTR (empty string)
		FullDescription: 30159,	; VT_BSTR (empty string)
		FillColor: 30160,	; VT_I4 (0)
		OutlineColor: 30161,	; VT_I4 | VT_ARRAY (0)
		FillType: 30162,	; VT_I4 (0)
		VisualEffects: 30163,	; VT_I4 (0) VisualEffects_Shadow: 0x1 VisualEffects_Reflection: 0x2 VisualEffects_Glow: 0x4 VisualEffects_SoftEdges: 0x8 VisualEffects_Bevel: 0x10
		OutlineThickness: 30164,	; VT_R8 | VT_ARRAY (VT_EMPTY)
		CenterPoint: 30165,	; VT_R8 | VT_ARRAY (VT_EMPTY)
		Rotation: 30166,	; VT_R8 (0)
		Size: 30167,	; VT_R8 | VT_ARRAY (VT_EMPTY)
		HeadingLevel: 30173,	; VT_I4 (HeadingLevel_None)
		IsDialog: 30174	; VT_BOOL (FALSE)
	}
	static PropertyConditionFlags := {
		None: 0,
		IgnoreCase: 1,
		MatchSubstring: 2
	}
	static TextAttribute := {
		AnimationStyle: 40000,	; VT_I4 (AnimationStyle_None)
		BackgroundColor: 40001,	; VT_I4 (0)
		BulletStyle: 40002,	; VT_I4 (BulletStyle_None)
		CapStyle: 40003,	; VT_I4 (CapStyle_None)
		Culture: 40004,	; VT_I4 (locale of the application UI)
		FontName: 40005,	; VT_BSTR (empty string)
		FontSize: 40006,	; VT_R8 (0)
		FontWeight: 40007,	; VT_I4 (0)
		ForegroundColor: 40008,	; VT_I4 (0)
		HorizontalTextAlignment: 40009,	; VT_I4 (HorizontalTextAlignment_Left)
		IndentationFirstLine: 40010,	; VT_R8 (0)
		IndentationLeading: 40011,	; VT_R8 (0)
		IndentationTrailing: 40012,	; VT_R8 (0)
		IsHidden: 40013,	; VT_BOOL (FALSE)
		IsItalic: 40014,	; VT_BOOL (FALSE)
		IsReadOnly: 40015,	; VT_BOOL (FALSE)
		IsSubscript: 40016,	; VT_BOOL (FALSE)
		IsSuperscript: 40017,	; VT_BOOL (FALSE)
		MarginBottom: 40018,	; VT_R8 (0)
		MarginLeading: 40019,	; VT_R8 (0)
		MarginTop: 40020,	; VT_R8
		MarginTrailing: 40021,	; VT_R8 (0)
		OutlineStyles: 40022,	; VT_I4 (OutlineStyles_None)
		OverlineColor: 40023,	; VT_I4 (0)
		OverlineStyle: 40024,	; VT_I4 (TextDecorationLineStyle_None)
		StrikethroughColor: 40025,	; VT_I4 (0)
		StrikethroughStyle: 40026,	; VT_I4 (TextDecorationLineStyle_None)
		Tabs: 40027,	; VT_ARRAY	VT_R8 (empty array)
		TextFlowDirections: 40028,	; VT_I4 (FlowDirections_Default)
		UnderlineColor: 40029,	; VT_I4 (0)
		UnderlineStyle: 40030,	; VT_I4 (TextDecorationLineStyle_None)
		AnnotationTypes: 40031,	; VT_ARRAY	VT_I4 (empty array)
		AnnotationObjects: 40032,	; VT_UNKNOWN (empty array)
		StyleName: 40033,	; VT_BSTR (empty string)
		StyleId: 40034,	; VT_I4 (0)
		Link: 40035,	; VT_UNKNOWN (NULL)
		IsActive: 40036,	; VT_BOOL (FALSE)
		SelectionActiveEnd: 40037,	; VT_I4 (ActiveEnd_None)
		CaretPosition: 40038,	; VT_I4 (CaretPosition_Unknown)
		CaretBidiMode: 40039,	; VT_I4 (CaretBidiMode_LTR)
		LineSpacing: 40040,	; VT_BSTR ("LineSpacingAttributeDefault")
		BeforeParagraphSpacing: 40041,	; VT_R8 (0)
		AfterParagraphSpacing: 40042,	; VT_R8 (0)
	}
	static TreeScope := {
		None: 0,
		Element: 1,
		Children: 2,
		Descendants: 4,
		Subtree: 7,
		Parent: 8,
		Ancestors: 16
	}

	/**
	 * Create Property Condition from AHK Object
	 * @param obj Object or Map or Array contains multiple Property Conditions. default operator (Object, Map): `and`, default operator (Array): `or`, default flags: 0
	 * #### example
	 * `[{ControlType: 50000, Name: "edit"}, {ControlType: 50004, Name: "edit", flags: 3}]` is same as `{0:{ControlType: 50000, Name: "edit"}, 1:{ControlType: 50004, Name: "edit", flags: 3}, operator: "or"}`
	 * 
	 * {0: {ControlType: 50004, Name: "edit"}, operator: "not"}
	 * @returns IUIAutomationCondition
	 */
	static PropertyCondition(obj) {
		return conditionbuilder(obj)
		conditionbuilder(obj) {
			switch Type(obj) {
				case "Object":
					operator := obj.DeleteProp("operator") || "and"
					flags := obj.DeleteProp("flags") || 0
					count := ObjOwnPropCount(obj), obj := obj.OwnProps()
				case "Array":
					operator := "or", flags := 0, count := obj.Length
				case "Map":
					operator := obj.Delete("operator") || "and"
					flags := obj.Delete("flags") || 0
					count := obj.Count
				default:
					throw TypeError("Invalid parameter type", -3)
			}
			arr := ComObjArray(0xd, count), i := 0
			for k, v in obj {
				if (IsNumber(k))
					k := Integer(k)
				else
					k := UIA.Property.%k%
				if (k >= 30000) {
					switch k {
						case 30003:
							if !(v is Integer)
								try v := UIA.ControlType.%v%
					}
					t := flags ? UIA.CreatePropertyConditionEx(k, v, flags) : UIA.CreatePropertyCondition(k, v)
					arr[i++] := t[]
				} else
					t := conditionbuilder(v), arr[i++] := t[]
			}
			if (count = 1) {
				if (operator = "not")
					return UIA.CreateNotCondition(t)
				return t
			} else {
				switch operator, false {
					case "and":
						return UIA.CreateAndConditionFromArray(arr)
					case "or":
						return UIA.CreateOrConditionFromArray(arr)
					default:
						return UIA.CreateFalseCondition()
				}
			}
		}
	}

	; Compares two UI Automation elements to determine whether they represent the same underlying UI element.
	static CompareElements(el1, el2) => (ComCall(3, this, "ptr", el1, "ptr", el2, "int*", &areSame := 0), areSame)

	; Compares two integer arrays containing run-time identifiers (IDs) to determine whether their content is the same and they belong to the same UI element.
	static CompareRuntimeIds(runtimeId1, runtimeId2) => (ComCall(4, this, "ptr", runtimeId1, "ptr", runtimeId2, "int*", &areSame := 0), areSame)

	; Retrieves the UI Automation element that represents the desktop.
	static GetRootElement() => (ComCall(5, this, "ptr*", &root := 0), IUIAutomationElement(root))

	; Retrieves a UI Automation element for the specified window.
	static ElementFromHandle(hwnd) => (ComCall(6, this, "ptr", hwnd, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves the UI Automation element at the specified point on the desktop.
	static ElementFromPoint(pt) => (ComCall(7, this, "int64", pt, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves the UI Automation element that has the input focus.
	static GetFocusedElement() => (ComCall(8, this, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	static GetRootElementBuildCache(cacheRequest) => (ComCall(9, this, "ptr", cacheRequest, "ptr*", &root := 0), IUIAutomationElement(root))

	; Retrieves a UI Automation element for the specified window, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	static ElementFromHandleBuildCache(hwnd, cacheRequest) => (ComCall(10, this, "ptr", hwnd, "ptr", cacheRequest, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves the UI Automation element at the specified point on the desktop, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	static ElementFromPointBuildCache(pt, cacheRequest) => (ComCall(11, this, "int64", pt, "ptr", cacheRequest, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves the UI Automation element that has the input focus, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	static GetFocusedElementBuildCache(cacheRequest) => (ComCall(12, this, "ptr", cacheRequest, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves a tree walker object that can be used to traverse the Microsoft UI Automation tree.
	static CreateTreeWalker(pCondition) => (ComCall(13, this, "ptr", pCondition, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))

	; Retrieves an IUIAutomationTreeWalker interface used to discover control elements.
	static ControlViewWalker() => (ComCall(14, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))

	; Retrieves an IUIAutomationTreeWalker interface used to discover content elements.
	static ContentViewWalker() => (ComCall(15, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))

	; Retrieves a tree walker object used to traverse an unfiltered view of the UI Automation tree.
	static RawViewWalker() => (ComCall(16, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))

	; Retrieves a predefined IUIAutomationCondition interface that selects all UI elements in an unfiltered view.
	static RawViewCondition() => (ComCall(17, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))

	; Retrieves a predefined IUIAutomationCondition interface that selects control elements.
	static ControlViewCondition() => (ComCall(18, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))

	; Retrieves a predefined IUIAutomationCondition interface that selects content elements.
	static ContentViewCondition() => (ComCall(19, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))

	; Creates a cache request.
	; After obtaining the IUIAutomationCacheRequest interface, use its methods to specify properties and control patterns to be cached when a UI Automation element is obtained.
	static CreateCacheRequest() => (ComCall(20, this, "ptr*", &cacheRequest := 0), IUIAutomationCacheRequest(cacheRequest))

	; Retrieves a predefined condition that selects all elements.
	static CreateTrueCondition() => (ComCall(21, this, "ptr*", &newCondition := 0), IUIAutomationBoolCondition(newCondition))

	; Creates a condition that is always false.
	; This method exists only for symmetry with IUIAutomation,,CreateTrueCondition. A false condition will never enable a match with UI Automation elements, and it cannot usefully be combined with any other condition.
	static CreateFalseCondition() => (ComCall(22, this, "ptr*", &newCondition := 0), IUIAutomationBoolCondition(newCondition))

	; Creates a condition that selects elements that have a property with the specified value.
	static CreatePropertyCondition(propertyId, value) {
		if A_PtrSize = 4
			v := ComVar(value, , true), ComCall(23, this, "int", propertyId, "int64", NumGet(v, 'int64'), "int64", NumGet(v, 8, "int64"), "ptr*", &newCondition := 0)
		else
			ComCall(23, this, "int", propertyId, "ptr", ComVar(value, , true), "ptr*", &newCondition := 0)
		return IUIAutomationPropertyCondition(newCondition)
	}

	; Creates a condition that selects elements that have a property with the specified value, using optional flags.
	static CreatePropertyConditionEx(propertyId, value, flags) {
		if A_PtrSize = 4
			v := ComVar(value, , true), ComCall(24, this, "int", propertyId, "int64", NumGet(v, 'int64'), "int64", NumGet(v, 8, "int64"), "int", flags, "ptr*", &newCondition := 0)
		else
			ComCall(24, this, "int", propertyId, "ptr", ComVar(value, , true), "int", flags, "ptr*", &newCondition := 0)
		return IUIAutomationPropertyCondition(newCondition)
	}

	; The Create**Condition** method calls AddRef on each pointers. This means you can call Release on those pointers after the call to Create**Condition** returns without invalidating the pointer returned from Create**Condition**. When you call Release on the pointer returned from Create**Condition**, UI Automation calls Release on those pointers.

	; Creates a condition that selects elements that match both of two conditions.
	static CreateAndCondition(condition1, condition2) => (ComCall(25, this, "ptr", condition1, "ptr", condition2, "ptr*", &newCondition := 0), IUIAutomationAndCondition(newCondition))

	; Creates a condition that selects elements based on multiple conditions, all of which must be true.
	static CreateAndConditionFromArray(conditions) => (ComCall(26, this, "ptr", conditions, "ptr*", &newCondition := 0), IUIAutomationAndCondition(newCondition))

	; Creates a condition that selects elements based on multiple conditions, all of which must be true.
	static CreateAndConditionFromNativeArray(conditions, conditionCount) => (ComCall(27, this, "ptr", conditions, "int", conditionCount, "ptr*", &newCondition := 0), IUIAutomationAndCondition(newCondition))

	; Creates a combination of two conditions where a match exists if either of the conditions is true.
	static CreateOrCondition(condition1, condition2) => (ComCall(28, this, "ptr", condition1, "ptr", condition2, "ptr*", &newCondition := 0), IUIAutomationOrCondition(newCondition))

	; Creates a combination of two or more conditions where a match exists if any of the conditions is true.
	static CreateOrConditionFromArray(conditions) => (ComCall(29, this, "ptr", conditions, "ptr*", &newCondition := 0), IUIAutomationOrCondition(newCondition))

	; Creates a combination of two or more conditions where a match exists if any one of the conditions is true.
	static CreateOrConditionFromNativeArray(conditions, conditionCount) => (ComCall(30, this, "ptr", conditions, "ptr", conditionCount, "ptr*", &newCondition := 0), IUIAutomationOrCondition(newCondition))

	; Creates a condition that is the negative of a specified condition.
	static CreateNotCondition(condition) => (ComCall(31, this, "ptr", condition, "ptr*", &newCondition := 0), IUIAutomationNotCondition(newCondition))

	; Note,  Before implementing an event handler, you should be familiar with the threading issues described in Understanding Threading Issues. http,//msdn.microsoft.com/en-us/library/ee671692(v=vs.85).aspx
	; A UI Automation client should not use multiple threads to add or remove event handlers. Unexpected behavior can result if one event handler is being added or removed while another is being added or removed in the same client process.
	; It is possible for an event to be delivered to an event handler after the handler has been unsubscribed, if the event is received simultaneously with the request to unsubscribe the event. The best practice is to follow the Component Object Model (COM) standard and avoid destroying the event handler object until its reference count has reached zero. Destroying an event handler immediately after unsubscribing for events may result in an access violation if an event is delivered late.

	; Registers a method that handles Microsoft UI Automation events.
	static AddAutomationEventHandler(eventId, element, scope, cacheRequest, handler) => ComCall(32, this, "int", eventId, "ptr", element, "int", scope, "ptr", cacheRequest ? cacheRequest : 0, "ptr", handler)

	; Removes the specified UI Automation event handler.
	static RemoveAutomationEventHandler(eventId, element, handler) => ComCall(33, this, "int", eventId, "ptr", element, "ptr", handler)

	; Registers a method that handles property-changed events.
	; The UI item specified by element might not support the properties specified by the propertyArray parameter.
	; This method serves the same purpose as IUIAutomation,,AddPropertyChangedEventHandler, but takes a normal array of property identifiers instead of a SAFEARRAY.
	static AddPropertyChangedEventHandlerNativeArray(element, scope, cacheRequest, handler, propertyArray, propertyCount) => ComCall(34, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler, "ptr", propertyArray, "int", propertyCount)

	; Registers a method that handles property-changed events.
	; The UI item specified by element might not support the properties specified by the propertyArray parameter.
	static AddPropertyChangedEventHandler(element, scope, cacheRequest, handler, propertyArray) => ComCall(35, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler, "ptr", propertyArray)

	; Removes a property-changed event handler.
	static RemovePropertyChangedEventHandler(element, handler) => ComCall(36, this, "ptr", element, "ptr", handler)

	; Registers a method that handles structure-changed events.
	static AddStructureChangedEventHandler(element, scope, cacheRequest, handler) => ComCall(37, this, "ptr", element, "int", scope, "ptr", cacheRequest ? cacheRequest : 0, "ptr", handler)

	; Removes a structure-changed event handler.
	static RemoveStructureChangedEventHandler(element, handler) => ComCall(38, this, "ptr", element, "ptr", handler)

	; Registers a method that handles focus-changed events.
	; Focus-changed events are system-wide; you cannot set a narrower scope.
	static AddFocusChangedEventHandler(cacheRequest, handler) => ComCall(39, this, "ptr", cacheRequest ? cacheRequest : 0, "ptr", handler)

	; Removes a focus-changed event handler.
	static RemoveFocusChangedEventHandler(handler) => ComCall(40, this, "ptr", handler)

	; Removes all registered Microsoft UI Automation event handlers.
	static RemoveAllEventHandlers() => ComCall(41, this)

	; Converts an array of integers to a SAFEARRAY.
	static IntNativeArrayToSafeArray(array, arrayCount) => (ComCall(42, this, "ptr", array, "int", arrayCount, "ptr*", &safeArray := 0), ComValue(0x2003, safeArray))

	; Converts a SAFEARRAY of integers to an array.
	static IntSafeArrayToNativeArray(intArray) => (ComCall(43, this, "ptr", intArray, "ptr*", &array := 0, "int*", &arrayCount := 0), NativeArray(array, arrayCount, "int"))

	; Creates a VARIANT that contains the coordinates of a rectangle.
	; The returned VARIANT has a data type of VT_ARRAY | VT_R8.
	static RectToVariant(rc) => (ComCall(44, this, "ptr", rc, "ptr", var := ComVar()), var)

	; Converts a VARIANT containing rectangle coordinates to a RECT.
	static VariantToRect(var) {
		if A_PtrSize = 4
			ComCall(45, this, "int64", NumGet(var, "int64"), "int64", NumGet(var, 8, "int64"), "ptr", rc := NativeArray(0, 4, "Int"))
		else
			ComCall(45, this, "ptr", var, "ptr", rc := NativeArray(0, 4, "Int"))
		return rc
	}

	; Converts a SAFEARRAY containing rectangle coordinates to an array of type RECT.
	static SafeArrayToRectNativeArray(rects) => (ComCall(46, this, "ptr", rects, "ptr*", &rectArray := 0, "int*", &rectArrayCount := 0), NativeArray(rectArray, rectArrayCount, "int"))

	; Creates a instance of a proxy factory object.
	; Use the IUIAutomationProxyFactoryMapping interface to enter the proxy factory into the table of available proxies.
	static CreateProxyFactoryEntry(factory) => (ComCall(47, this, "ptr", factory, "ptr*", &factoryEntry := 0), IUIAutomationProxyFactoryEntry(factoryEntry))

	; Retrieves an object that represents the mapping of Window classnames and associated data to individual proxy factories. This property is read-only.
	static ProxyFactoryMapping() => (ComCall(48, this, "ptr*", &factoryMapping := 0), IUIAutomationProxyFactoryMapping(factoryMapping))

	; The programmatic name is intended for debugging and diagnostic purposes only. The string is not localized.
	; This property should not be used in string comparisons. To determine whether two properties are the same, compare the property identifiers directly.

	; Retrieves the registered programmatic name of a property.
	static GetPropertyProgrammaticName(property) => (ComCall(49, this, "int", property, "ptr*", &name := 0), BSTR(name))

	; Retrieves the registered programmatic name of a control pattern.
	static GetPatternProgrammaticName(pattern) => (ComCall(50, this, "int", pattern, "ptr*", &name := 0), BSTR(name))

	; This method is intended only for use by Microsoft UI Automation tools that need to scan for properties. It is not intended to be used by UI Automation clients.
	; There is no guarantee that the element will support any particular control pattern when asked for it later.

	; Retrieves the control patterns that might be supported on a UI Automation element.
	static PollForPotentialSupportedPatterns(pElement, &patternIds, &patternNames) {
		ComCall(51, this, "ptr", pElement, "ptr*", &patternIds := 0, "ptr*", &patternNames := 0)
		patternIds := ComValue(0x2003, patternIds), patternNames := ComValue(0x2008, patternNames)
	}

	; Retrieves the properties that might be supported on a UI Automation element.
	static PollForPotentialSupportedProperties(pElement, &propertyIds, &propertyNames) {
		ComCall(52, this, "ptr", pElement, "ptr*", &propertyIds := 0, "ptr*", &propertyNames := 0)
		propertyIds := ComValue(0x2003, propertyIds), propertyNames := ComValue(0x2008, propertyNames)
	}

	; Checks a provided VARIANT to see if it contains the Not Supported identifier.
	; After retrieving a property for a UI Automation element, call this method to determine whether the element supports the retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetCurrentPropertyValue.
	static CheckNotSupported(value) {
		if A_PtrSize = 4
			value := ComVar(value, , true), ComCall(53, this, "int64", NumGet(value, "int64"), "int64", NumGet(value, 8, "int64"), "int*", &isNotSupported := 0)
		else
			ComCall(53, this, "ptr", ComVar(value, , true), "int*", &isNotSupported := 0)
		return isNotSupported
	}

	; Retrieves a static token object representing a property or text attribute that is not supported. This property is read-only.
	; This object can be used for comparison with the results from IUIAutomationElement,,GetCurrentPropertyValue or IUIAutomationTextRange,,GetAttributeValue.
	static ReservedNotSupportedValue() => (ComCall(54, this, "ptr*", &notSupportedValue := 0), ComValue(0xd, notSupportedValue))

	; Retrieves a static token object representing a text attribute that is a mixed attribute. This property is read-only.
	; The object retrieved by IUIAutomation,,ReservedMixedAttributeValue can be used for comparison with the results from IUIAutomationTextRange,,GetAttributeValue to determine if a text range contains more than one value for a particular text attribute.
	static ReservedMixedAttributeValue() => (ComCall(55, this, "ptr*", &mixedAttributeValue := 0), ComValue(0xd, mixedAttributeValue))

	; This method enables UI Automation clients to get IUIAutomationElement interfaces for accessible objects implemented by a Microsoft Active Accessiblity server.
	; This method may fail if the server implements UI Automation provider interfaces alongside Microsoft Active Accessibility support.
	; The method returns E_INVALIDARG if the underlying implementation of the Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.

	; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server.
	static ElementFromIAccessible(accessible, childId) => (ComCall(56, this, "ptr", accessible, "int", childId, "ptr*", &element := 0), IUIAutomationElement(element))

	; Retrieves a UI Automation element for the specified accessible object from a Microsoft Active Accessibility server, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	static ElementFromIAccessibleBuildCache(accessible, childId, cacheRequest) => (ComCall(57, this, "ptr", accessible, "int", childId, "ptr", cacheRequest, "ptr*", &element := 0), IUIAutomationElement(element))
}

class IUIAutomationAndCondition extends IUIAutomationCondition {
	ChildCount => (ComCall(3, this, "int*", &childCount := 0), childCount)
	GetChildrenAsNativeArray() => (ComCall(4, this, "ptr*", &childArray := 0, "int*", &childArrayCount := 0), NativeArray(childArray, childArrayCount))
	GetChildren() => (ComCall(5, this, "ptr*", &childArray := 0), ComValue(0x200d, childArray))
}

class IUIAutomationAnnotationPattern extends IUIABase {
	CurrentAnnotationTypeId => (ComCall(3, this, "int*", &retVal := 0), retVal)
	CurrentAnnotationTypeName => (ComCall(4, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentAuthor => (ComCall(5, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentDateTime => (ComCall(6, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentTarget => (ComCall(7, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
	CachedAnnotationTypeId => (ComCall(8, this, "int*", &retVal := 0), retVal)
	CachedAnnotationTypeName => (ComCall(9, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedAuthor => (ComCall(10, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedDateTime => (ComCall(11, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedTarget => (ComCall(11, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
}

class IUIAutomationBoolCondition extends IUIAutomationCondition {
	Value => (ComCall(3, this, "int*", &boolVal := 0), boolVal)
}

class IUIAutomationCacheRequest extends IUIABase {
	; Adds a property to the cache request.
	AddProperty(propertyId) => ComCall(3, this, "int", propertyId)

	; Adds a control pattern to the cache request. Adding a control pattern that is already in the cache request has no effect.
	AddPattern(patternId) => ComCall(4, this, "int", patternId)

	; Creates a copy of the cache request.
	Clone() => (ComCall(5, this, "ptr*", &clonedRequest := 0), IUIAutomationCacheRequest(clonedRequest))

	TreeScope {
		get => (ComCall(6, this, "int*", &scope := 0), scope)
		set => ComCall(7, this, "int", Value)
	}

	TreeFilter {
		get => (ComCall(8, this, "ptr*", &filter := 0), IUIAutomationCondition(filter))
		set => ComCall(9, this, "ptr", Value)
	}

	AutomationElementMode {
		get => (ComCall(10, this, "int*", &mode := 0), mode)
		set => ComCall(11, this, "int", Value)
	}
}

class IUIAutomationCondition extends IUIABase {
}

class IUIAutomationCustomNavigationPattern extends IUIABase {
	Navigate(direction) => (ComCall(3, this, "int", direction, "ptr*", &pRetVal := 0), IUIAutomationElement(pRetVal))
}

class IUIAutomationDockPattern extends IUIABase {
	; Sets the dock position of this element.
	SetDockPosition(dockPos) => ComCall(3, this, "int", dockPos)

	; Retrieves the `dock position` of this element within its docking container.
	CurrentDockPosition => (ComCall(4, this, "int*", &retVal := 0), retVal)

	; Retrieves the `cached dock` position of this element within its docking container.
	CachedDockPosition => (ComCall(5, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationDragPattern extends IUIABase {
	CurrentIsGrabbed => (ComCall(3, this, "int*", &retVal := 0), retVal)
	CachedIsGrabbed => (ComCall(4, this, "int*", &retVal := 0), retVal)
	CurrentDropEffect => (ComCall(5, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedDropEffect => (ComCall(6, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentDropEffects => (ComCall(7, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
	CachedDropEffects => (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
	GetCurrentGrabbedItems() => (ComCall(9, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
	GetCachedGrabbedItems() => (ComCall(10, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
}

class IUIAutomationDropTargetPattern extends IUIABase {
	CurrentDropTargetEffect => (ComCall(3, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedDropTargetEffect => (ComCall(4, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentDropTargetEffects => (ComCall(5, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
	CachedDropTargetEffects => (ComCall(6, this, "ptr*", &retVal := 0), ComValue(0x2008, retVal))
}

class IUIAutomationElement extends IUIABase {
	/**
	 * Find or wait target control element.
	 * @param ControlType target control type, such as 'button' or UIA.ControlType.Button
	 * @param propertys The property object or 'Name' property.
	 * @param propertyId The property identifier. `Name`(default)
	 * @param waittime Waiting time for control element to appear.
	 */
	FindControl(ControlID, propertys := unset, waittime := 0) {
		index := 1
		if !IsNumber(ControlID) {
			if RegExMatch(ControlID, "i)^([a-z]+)(\d+)$", &m)
				index := Integer(m[2]), ControlID := m[1]
			try ControlID := UIA.ControlType.%ControlID%
			catch
				throw ValueError("ControlType invalid")
		}
		if (!IsSet(propertys))
			propertys := {}
		switch Type(propertys) {
			case "String":
				propertys := { Name: propertys }
			case "Array":
				propertys := { 0: propertys }
			case "Object":
			default:
				throw ValueError("invalid param")
		}
		propertys.ControlType := ControlID
		cond := UIA.PropertyCondition(propertys)
		endtime := A_TickCount + waittime
		loop {
			try {
				if (index = 1)
					return this.FindFirst(cond)
				else {
					eles := this.FindAll(cond)
					if (index <= eles.Length)
						return eles.GetElement(index)
					throw TargetError("Target element not found.")
				}
			} catch TargetError {
				if (A_TickCount > endtime)
					return
			}
		}
	}

	GetAllCurrentPropertyValue() {
		infos := {}
		for k, v in UIA.Property.OwnProps() {
			v := this.GetCurrentPropertyValue(v)
			if (v is ComObjArray) {
				arr := []
				for t in v
					arr.Push(t)
				v := arr
			}
			infos.%k% := v
		}
		return infos
	}

	GetControlID() {
		cond := UIA.CreatePropertyCondition(UIA.Property.ControlType, controltype := this.GetCurrentPropertyValue(UIA.Property.ControlType))
		runtimeid := IUIA_RuntimeIdToString(this.GetRuntimeId())
		runtimeid := RegExReplace(runtimeid, "^(\w+\.\w+)\..*$", "$1")
		rootele := UIA.GetRootElement().FindFirst(UIA.CreatePropertyCondition(UIA.Property.RuntimeId, IUIA_RuntimeIdFromString(runtimeid)))
		eles := rootele.FindAll(cond)
		for i in UIA.ControlType
			if (UIA.ControlType.%i% == controltype) {
				controltype := i
				break
			}
		loop eles.Length {
			if (UIA.CompareElements(this, eles.GetElement(A_Index - 1)))
				return controltype A_Index
		}
	}

	; Sets the keyboard focus to this UI Automation element.
	SetFocus() => ComCall(3, this)

	; Retrieves the unique identifier assigned to the UI element.
	; The identifier is only guaranteed to be unique to the UI of the desktop on which it was generated. Identifiers can be reused over time.
	; The format of run-time identifiers might change in the future. The returned identifier should be treated as an opaque value and used only for comparison; for example, to determine whether a Microsoft UI Automation element is in the cache.
	GetRuntimeId() => (ComCall(4, this, "ptr*", &runtimeId := 0), ComValue(0x2003, runtimeId))

	; The scope of the search is relative to the element on which the method is called. Elements are returned in the order in which they are encountered in the tree.
	; This function cannot search for ancestor elements in the Microsoft UI Automation tree; that is, TreeScope_Ancestors is not a valid value for the scope parameter.
	; When searching for top-level windows on the desktop, be sure to specify TreeScope_Children in the scope parameter, not TreeScope_Descendants. A search through the entire subtree of the desktop could iterate through thousands of items and lead to a stack overflow.
	; If your client application might try to find elements in its own user interface, you must make all UI Automation calls on a separate thread.

	; Retrieves the first child or descendant element that matches the specified condition.
	FindFirst(condition, scope := 4) {
		if (ComCall(5, this, "int", scope, "ptr", condition, "ptr*", &found := 0), found)
			return IUIAutomationElement(found)
		throw TargetError("Target element not found.")
	}

	; Returns all UI Automation elements that satisfy the specified condition.
	FindAll(condition, scope := 4) {
		if (ComCall(6, this, "int", scope, "ptr", condition, "ptr*", &found := 0), found)
			return IUIAutomationElementArray(found)
		throw TargetError("Target elements not found.")
	}

	; Retrieves the first child or descendant element that matches the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	FindFirstBuildCache(condition, cacheRequest, scope := 4) {
		if (ComCall(7, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &found := 0), found)
			return IUIAutomationElement(found)
		throw TargetError("Target element not found.")
	}

	; Returns all UI Automation elements that satisfy the specified condition, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	FindAllBuildCache(condition, cacheRequest, scope := 4) {
		if (ComCall(8, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &found := 0), found)
			return IUIAutomationElementArray(found)
		throw TargetError("Target elements not found.")
	}

	; Retrieves a  UI Automation element with an updated cache.
	; The original UI Automation element is unchanged. The  IUIAutomationElement interface refers to the same element and has the same runtime identifier.
	BuildUpdatedCache(cacheRequest) => (ComCall(9, this, "ptr", cacheRequest, "ptr*", &updatedElement := 0), IUIAutomationElement(updatedElement))

	; Microsoft UI Automation properties of the double type support Not a Number (NaN) values. When retrieving a property of the double type, a client can use the _isnan function to determine whether the property is a NaN value.

	; Retrieves the current value of a property for this UI Automation element.
	GetCurrentPropertyValue(propertyId) => (ComCall(10, this, "int", propertyId, "ptr", val := ComVar()), val[])

	; Retrieves a property value for this UI Automation element, optionally ignoring any default value.
	; Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling IUIAutomationElement,,GetCurrentPropertyValue.
	; If the Microsoft UI Automation provider for the element itself supports the property, the value of the property is returned. Otherwise, if ignoreDefaultValue is FALSE, a default value specified by UI Automation is returned.
	; This method returns a failure code if the requested property was not previously cached.
	GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue) => (ComCall(11, this, "int", propertyId, "int", ignoreDefaultValue, "ptr", val := ComVar()), val[])

	; Retrieves a property value from the cache for this UI Automation element.
	GetCachedPropertyValue(propertyId) => (ComCall(12, this, "int", propertyId, "ptr", val := ComVar()), val[])

	; Retrieves a property value from the cache for this UI Automation element, optionally ignoring any default value.
	GetCachedPropertyValueEx(propertyId, ignoreDefaultValue, retVal) => (ComCall(13, this, "int", propertyId, "int", ignoreDefaultValue, "ptr", val := ComVar()), val[])

	; Retrieves the control pattern interface of the specified pattern on this UI Automation element.
	GetCurrentPatternAs(patternId, riid) {	; not completed
		try {
			if IsNumber(patternId)
				name := UIA.ControlPattern.%patternId%
			else
				patternId := UIA.ControlPattern.%(name := patternId)%
			ComCall(14, this, "int", patternId, "ptr", riid, "ptr*", &patternObject := 0)
			return IUIAutomation%name%Pattern(patternObject)
		}
	}

	; Retrieves the control pattern interface of the specified pattern from the cache of this UI Automation element.
	GetCachedPatternAs(patternId, riid) {	; not completed
		try {
			if IsNumber(patternId)
				name := UIA.ControlPattern.%patternId%
			else
				patternId := UIA.ControlPattern.%(name := patternId)%
			ComCall(15, this, "int", patternId, "ptr", riid, "ptr*", &patternObject := 0)
			return IUIAutomation%name%Pattern(patternObject)
		}
	}

	; Retrieves the IUnknown interface of the specified control pattern on this UI Automation element.
	; This method gets the specified control pattern based on its availability at the time of the call.
	; For some forms of UI, this method will incur cross-process performance overhead. Applications can reduce overhead by caching control patterns and then retrieving them by using IUIAutomationElement,,GetCachedPattern.
	GetCurrentPattern(patternId) {
		try {
			if IsNumber(patternId)
				name := UIA.ControlPattern.%patternId%
			else
				patternId := UIA.ControlPattern.%(name := patternId)%
			ComCall(16, this, "int", patternId, "ptr*", &patternObject := 0)
			return IUIAutomation%name%Pattern(patternObject)
		}
	}

	; Retrieves from the cache the IUnknown interface of the specified control pattern of this UI Automation element.
	GetCachedPattern(patternId) {
		try {
			if IsNumber(patternId)
				name := UIA.ControlPattern.%patternId%
			else
				patternId := UIA.ControlPattern.%(name := patternId)%
			ComCall(17, this, "int", patternId, "ptr*", &patternObject := 0)
			return IUIAutomation%name%Pattern(patternObject)
		}
	}

	; Retrieves from the cache the parent of this UI Automation element.
	GetCachedParent() => (ComCall(18, this, "ptr*", &parent := 0), IUIAutomationElement(parent))

	; Retrieves the cached child elements of this UI Automation element.
	; The view of the returned collection is determined by the TreeFilter property of the IUIAutomationCacheRequest that was active when this element was obtained.
	; Children are cached only if the scope of the cache request included TreeScope_Subtree, TreeScope_Children, or TreeScope_Descendants.
	; If the cache request specified that children were to be cached at this level, but there are no children, the value of this property is 0. However, if no request was made to cache children at this level, an attempt to retrieve the property returns an error.
	GetCachedChildren() => (ComCall(19, this, "ptr*", &children := 0), IUIAutomationElementArray(children))

	; Retrieves the identifier of the process that hosts the element.
	CurrentProcessId => (ComCall(20, this, "int*", &retVal := 0), retVal)

	; Retrieves the control type of the element.
	; Control types describe a known interaction model for UI Automation elements without relying on a localized control type or combination of complex logic rules. This property cannot change at run time unless the control supports the IUIAutomationMultipleViewPattern interface. An example is the Win32 ListView control, which can change from a data grid to a list, depending on the current view.
	CurrentControlType => (ComCall(21, this, "int*", &retVal := 0), retVal)

	; Retrieves a localized description of the control type of the element.
	CurrentLocalizedControlType => (ComCall(22, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the name of the element.
	CurrentName => (ComCall(23, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the accelerator key for the element.
	CurrentAcceleratorKey => (ComCall(24, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the access key character for the element.
	; An access key is a character in the text of a menu, menu item, or label of a control such as a button that activates the attached menu function. For example, the letter "O" is often used to invoke the Open file common dialog box from a File menu. Microsoft UI Automation elements that have the access key property set always implement the Invoke control pattern.
	CurrentAccessKey => (ComCall(25, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Indicates whether the element has keyboard focus.
	CurrentHasKeyboardFocus => (ComCall(26, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element can accept keyboard focus.
	CurrentIsKeyboardFocusable => (ComCall(27, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element is enabled.
	CurrentIsEnabled => (ComCall(28, this, "int*", &retVal := 0), retVal)

	; Retrieves the Microsoft UI Automation identifier of the element.
	; The identifier is unique among sibling elements in a container, and is the same in all instances of the application.
	CurrentAutomationId => (ComCall(29, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the class name of the element.
	; The value of this property is implementation-defined. The property is useful in testing environments.
	CurrentClassName => (ComCall(30, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the help text for the element. This information is typically obtained from tooltips.
	; Caution  Do not retrieve the CachedHelpText property from a control that is based on the SysListview32 class. Doing so could cause the system to become unstable and data to be lost. A client application can discover whether a control is based on SysListview32 by retrieving the CachedClassName or CurrentClassName property from the control.
	CurrentHelpText => (ComCall(31, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the culture identifier for the element.
	CurrentCulture => (ComCall(32, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element is a control element.
	CurrentIsControlElement => (ComCall(33, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element is a content element.
	; A content element contains data that is presented to the user. Examples of content elements are the items in a list box or a button in a dialog box. Non-content elements, also called peripheral elements, are typically used to manipulate the content in a composite control; for example, the button on a drop-down control.
	CurrentIsContentElement => (ComCall(34, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element contains a disguised password.
	; This property enables applications such as screen-readers to determine whether the text content of a control should be read aloud.
	CurrentIsPassword => (ComCall(35, this, "int*", &retVal := 0), retVal)

	; Retrieves the window handle of the element.
	CurrentNativeWindowHandle => (ComCall(36, this, "ptr*", &retVal := 0), retVal)

	; Retrieves a description of the type of UI item represented by the element.
	; This property is used to obtain information about items in a list, tree view, or data grid. For example, an item in a file directory view might be a "Document File" or a "Folder".
	CurrentItemType => (ComCall(37, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Indicates whether the element is off-screen.
	CurrentIsOffscreen => (ComCall(38, this, "int*", &retVal := 0), retVal)

	; Retrieves a value that indicates the orientation of the element.
	; This property is supported by controls such as scroll bars and sliders that can have either a vertical or a horizontal orientation.
	CurrentOrientation => (ComCall(39, this, "int*", &retVal := 0), retVal)

	; Retrieves the name of the underlying UI framework. The name of the UI framework, such as "Win32", "WinForm", or "DirectUI".
	CurrentFrameworkId => (ComCall(40, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Indicates whether the element is required to be filled out on a form.
	CurrentIsRequiredForForm => (ComCall(41, this, "int*", &retVal := 0), retVal)

	; Retrieves the description of the status of an item in an element.
	; This property enables a client to ascertain whether an element is conveying status about an item. For example, an item associated with a contact in a messaging application might be "Busy" or "Connected".
	CurrentItemStatus => (ComCall(42, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the coordinates of the rectangle that completely encloses the element, in screen coordinates.
	CurrentBoundingRectangle => (ComCall(43, this, "ptr", retVal := NativeArray(0, 4, "int")), { left: retVal[0], top: retVal[1], right: retVal[2], bottom: retVal[3] })

	; This property maps to the Accessible Rich Internet Applications (ARIA) property.

	; Retrieves the element that contains the text label for this element.
	; This property could be used to retrieve, for example, the static text label for a combo box.
	CurrentLabeledBy => (ComCall(44, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))

	; Retrieves the Accessible Rich Internet Applications (ARIA) role of the element.
	CurrentAriaRole => (ComCall(45, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the ARIA properties of the element.
	CurrentAriaProperties => (ComCall(46, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Indicates whether the element contains valid data for a form.
	CurrentIsDataValidForForm => (ComCall(47, this, "int*", &retVal := 0), retVal)

	; Retrieves an array of elements for which this element serves as the controller.
	CurrentControllerFor => (ComCall(48, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves an array of elements that describe this element.
	CurrentDescribedBy => (ComCall(49, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves an array of elements that indicates the reading order after the current element.
	CurrentFlowsTo => (ComCall(50, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a description of the provider for this element.
	CurrentProviderDescription => (ComCall(51, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached ID of the process that hosts the element.
	CachedProcessId => (ComCall(52, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates the control type of the element.
	CachedControlType => (ComCall(53, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached localized description of the control type of the element.
	CachedLocalizedControlType => (ComCall(54, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached name of the element.
	CachedName => (ComCall(55, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached accelerator key for the element.
	CachedAcceleratorKey => (ComCall(56, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached access key character for the element.
	CachedAccessKey => (ComCall(57, this, "ptr*", &retVal := 0), BSTR(retVal))

	; A cached value that indicates whether the element has keyboard focus.
	CachedHasKeyboardFocus => (ComCall(58, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can accept keyboard focus.
	CachedIsKeyboardFocusable => (ComCall(59, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element is enabled.
	CachedIsEnabled => (ComCall(60, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached UI Automation identifier of the element.
	CachedAutomationId => (ComCall(61, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached class name of the element.
	CachedClassName => (ComCall(62, this, "ptr*", &retVal := 0), BSTR(retVal))

	;
	CachedHelpText => (ComCall(63, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached help text for the element.
	CachedCulture => (ComCall(64, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element is a control element.
	CachedIsControlElement => (ComCall(65, this, "int*", &retVal := 0), retVal)

	; A cached value that indicates whether the element is a content element.
	CachedIsContentElement => (ComCall(66, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element contains a disguised password.
	CachedIsPassword => (ComCall(67, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached window handle of the element.
	CachedNativeWindowHandle => (ComCall(68, this, "ptr*", &retVal := 0), retVal)

	; Retrieves a cached string that describes the type of item represented by the element.
	CachedItemType => (ComCall(69, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves a cached value that indicates whether the element is off-screen.
	CachedIsOffscreen => (ComCall(70, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates the orientation of the element.
	CachedOrientation => (ComCall(71, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached name of the underlying UI framework associated with the element.
	CachedFrameworkId => (ComCall(72, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves a cached value that indicates whether the element is required to be filled out on a form.
	CachedIsRequiredForForm => (ComCall(73, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached description of the status of an item within an element.
	CachedItemStatus => (ComCall(74, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached coordinates of the rectangle that completely encloses the element.
	CachedBoundingRectangle => (ComCall(75, this, "ptr", retVal := NativeArray(0, 4, "int")), { left: retVal[0], top: retVal[1], right: retVal[2], bottom: retVal[3] })

	; Retrieves the cached element that contains the text label for this element.
	CachedLabeledBy => (ComCall(76, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))

	; Retrieves the cached ARIA role of the element.
	CachedAriaRole => (ComCall(77, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves the cached ARIA properties of the element.
	CachedAriaProperties => (ComCall(78, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves a cached value that indicates whether the element contains valid data for the form.
	CachedIsDataValidForForm => (ComCall(79, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached array of UI Automation elements for which this element serves as the controller.
	CachedControllerFor => (ComCall(80, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a cached array of elements that describe this element.
	CachedDescribedBy => (ComCall(81, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a cached array of elements that indicate the reading order after the current element.
	CachedFlowsTo => (ComCall(82, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a cached description of the provider for this element.
	CachedProviderDescription => (ComCall(83, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves a point on the element that can be clicked.
	; A client application can use this method to simulate clicking the left or right mouse button. For example, to simulate clicking the right mouse button to display the context menu for a control,
	; • Call the GetClickablePoint method to find a clickable point on the control.
	; • Call the SendInput function to send a right-mouse-down, right-mouse-up sequence.
	GetClickablePoint() {
		if (ComCall(84, this, "int64*", &clickable := 0, "int*", &gotClickable := 0), gotClickable)
			return { x: clickable & 0xffff, y: clickable >> 32 }
		throw TargetError('The element has no clickable point')
	}

	;; IUIAutomationElement2
	CurrentOptimizeForVisualContent => (ComCall(85, this, "int*", &retVal := 0), retVal)
	CachedOptimizeForVisualContent => (ComCall(86, this, "int*", &retVal := 0), retVal)
	CurrentLiveSetting => (ComCall(87, this, "int*", &retVal := 0), retVal)
	CachedLiveSetting => (ComCall(88, this, "int*", &retVal := 0), retVal)
	CurrentFlowsFrom => (ComCall(89, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
	CachedFlowsFrom => (ComCall(90, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	;; IUIAutomationElement3
	ShowContextMenu() => ComCall(91, this)
	CurrentIsPeripheral => (ComCall(92, this, "int*", &retVal := 0), retVal)
	CachedIsPeripheral => (ComCall(93, this, "int*", &retVal := 0), retVal)

	;; IUIAutomationElement4
	CurrentPositionInSet => (ComCall(94, this, "int*", &retVal := 0), retVal)
	CurrentSizeOfSet => (ComCall(95, this, "int*", &retVal := 0), retVal)
	CurrentLevel => (ComCall(96, this, "int*", &retVal := 0), retVal)
	CurrentAnnotationTypes => (ComCall(97, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
	CurrentAnnotationObjects => (ComCall(98, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
	CachedPositionInSet => (ComCall(99, this, "int*", &retVal := 0), retVal)
	CachedSizeOfSet => (ComCall(100, this, "int*", &retVal := 0), retVal)
	CachedLevel => (ComCall(101, this, "int*", &retVal := 0), retVal)
	CachedAnnotationTypes => (ComCall(102, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
	CachedAnnotationObjects => (ComCall(103, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	;; IUIAutomationElement5
	CurrentLandmarkType => (ComCall(104, this, "int*", &retVal := 0), retVal)
	CurrentLocalizedLandmarkType => (ComCall(105, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedLandmarkType => (ComCall(106, this, "int*", &retVal := 0), retVal)
	CachedLocalizedLandmarkType => (ComCall(107, this, "ptr*", &retVal := 0), BSTR(retVal))

	;; IUIAutomationElement6
	CurrentFullDescription => (ComCall(108, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedFullDescription => (ComCall(109, this, "ptr*", &retVal := 0), BSTR(retVal))

	;; IUIAutomationElement7
	; IUIAutomationCondition, TreeTraversalOptions, IUIAutomationElement, TreeScope
	FindFirstWithOptions(condition, traversalOptions, root, scope := 4) {
		if (ComCall(110, this, "int", scope, "ptr", condition, "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
			return IUIAutomationElement(found)
		throw TargetError("Target element not found.")
	}
	FindAllWithOptions(condition, traversalOptions, root, scope := 4) {
		if (ComCall(111, this, "int", scope, "ptr", condition, "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
			return IUIAutomationElementArray(found)
		throw TargetError("Target elements not found.")
	}

	; TreeScope, IUIAutomationCondition, IUIAutomationCacheRequest, TreeTraversalOptions, IUIAutomationElement
	FindFirstWithOptionsBuildCache(condition, cacheRequest, traversalOptions, root, scope := 4) {
		if (ComCall(112, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
			return IUIAutomationElement(found)
		throw TargetError("Target element not found.")
	}
	FindAllWithOptionsBuildCache(condition, cacheRequest, traversalOptions, root, scope := 4) {
		if (ComCall(113, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", traversalOptions, "ptr", root, "ptr*", &found := 0), found)
			return IUIAutomationElementArray(found)
		throw TargetError("Target elements not found.")
	}
	GetCurrentMetadataValue(targetId, metadataId) => (ComCall(114, this, "int", targetId, "int", metadataId, "ptr", returnVal := ComVar()), returnVal[])

	;; IUIAutomationElement8
	CurrentHeadingLevel => (ComCall(115, this, "int*", &retVal := 0), retVal)
	CachedHeadingLevel => (ComCall(116, this, "int*", &retVal := 0), retVal)

	;; IUIAutomationElement9
	CurrentIsDialog => (ComCall(117, this, "int*", &retVal := 0), retVal)
	CachedIsDialog => (ComCall(118, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationElementArray extends IUIABase {
	; Retrieves the number of elements in the collection.
	Length => (ComCall(3, this, "int*", &length := 0), length)

	; Retrieves a Microsoft UI Automation element from the collection.
	GetElement(index) => (ComCall(4, this, "int", index, "ptr*", &element := 0), IUIAutomationElement(element))
}

class IUIAutomationExpandCollapsePattern extends IUIABase {
	; This is a blocking method that returns after the element has been collapsed.
	; There are cases when a element that is marked as a leaf node might not know whether it has children until either the IUIAutomationExpandCollapsePattern,,Collapse or the IUIAutomationExpandCollapsePattern,,Expand method is called. This behavior is possible with a tree view control that does delayed loading of its child items. For example, Microsoft Windows Explorer might display the expand icon for a node even though there are currently no child items; when the icon is clicked, the control polls for child items, finds none, and removes the expand icon. In these cases clients should listen for a property-changed event on the IUIAutomationExpandCollapsePattern,,CurrentExpandCollapseState property.

	; Displays all child nodes, controls, or content of the element.
	Expand() => ComCall(3, this)

	; Hides all child nodes, controls, or content of the element.
	Collapse() => ComCall(4, this)

	; Retrieves a value that indicates the state, expanded or collapsed, of the element.
	CurrentExpandCollapseState => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates the state, expanded or collapsed, of the element.
	CachedExpandCollapseState => (ComCall(6, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationGridItemPattern extends IUIABase {
	; Retrieves the element that contains the grid item.
	CurrentContainingGrid => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))

	; Retrieves the zero-based index of the row that contains the grid item.
	CurrentRow => (ComCall(4, this, "int*", &retVal := 0), retVal)

	; Retrieves the zero-based index of the column that contains the item.
	CurrentColumn => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves the number of rows spanned by the grid item.
	CurrentRowSpan => (ComCall(6, this, "int*", &retVal := 0), retVal)

	; Retrieves the number of columns spanned by the grid item.
	CurrentColumnSpan => (ComCall(7, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached element that contains the grid item.
	CachedContainingGrid => (ComCall(8, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))

	; Retrieves the cached zero-based index of the row that contains the item.
	CachedRow => (ComCall(9, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached zero-based index of the column that contains the grid item.
	CachedColumn => (ComCall(10, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached number of rows spanned by a grid item.
	CachedRowSpan => (ComCall(11, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached number of columns spanned by the grid item.
	CachedColumnSpan => (ComCall(12, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationGridPattern extends IUIABase {
	; Retrieves a UI Automation element representing an item in the grid.
	GetItem(row, column) => (ComCall(3, this, "int", row, "int", column, "ptr*", &element := 0), IUIAutomationGridItemPattern(element))

	; Hidden rows and columns, depending on the provider implementation, may be loaded in the Microsoft UI Automation tree and will therefore be reflected in the row count and column count properties. If the hidden rows and columns have not yet been loaded they are not counted.

	; Retrieves the number of rows in the grid.
	CurrentRowCount => (ComCall(4, this, "int*", &retVal := 0), retVal)

	; The number of columns in the grid.
	CurrentColumnCount => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached number of rows in the grid.
	CachedRowCount => (ComCall(6, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached number of columns in the grid.
	CachedColumnCount => (ComCall(7, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationInvokePattern extends IUIABase {
	; Invokes the action of a control, such as a button click.
	; Calls to this method should return immediately without blocking. However, this behavior depends on the implementation.
	Invoke() => ComCall(3, this)
}

class IUIAutomationItemContainerPattern extends IUIABase {
	; IUIAutomationItemContainerPattern

	; Retrieves an element within a containing element, based on a specified property value.
	; The provider may return an actual IUIAutomationElement interface or a placeholder if the matching element is virtualized.
	; This method returns E_INVALIDARG if the property requested is not one that the container supports searching over. It is expected that most containers will support Name property, and if appropriate for the container, AutomationId and IsSelected.
	; This method can be slow, because it may need to traverse multiple objects to find a matching one. When used in a loop to return multiple items, no specific order is defined so long as each item is returned only once (that is, the loop should terminate). This method is also item-centric, not UI-centric, so items with multiple UI representations need to be hit only once.
	; When the propertyId parameter is specified as 0 (zero), the provider is expected to return the next item after pStartAfter. If pStartAfter is specified as NULL with a propertyId of 0, the provider should return the first item in the container. When propertyId is specified as 0, the value parameter should be VT_EMPTY.
	FindItemByProperty(pStartAfter, propertyId, value) {
		if A_PtrSize = 4
			value := ComVar(value, , true), ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "int64", NumGet(value, "int64"), "int64", NumGet(value, 8, "int64"), "ptr*", &pFound := 0)
		else
			ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "ptr", ComVar(value, , true), "ptr*", &pFound := 0)
		if (pFound)
			return IUIAutomationElement(pFound)
		throw TargetError("Target elements not found.")
	}
}

class IUIAutomationLegacyIAccessiblePattern extends IUIABase {

	; IUIAutomationLegacyIAccessiblePattern

	; Performs a Microsoft Active Accessibility selection.
	Select(flagsSelect) => ComCall(3, this, "int", flagsSelect)

	; Performs the Microsoft Active Accessibility default action for the element.
	DoDefaultAction() => ComCall(4, this)

	; Sets the Microsoft Active Accessibility value property for the element. This method is supported only for some elements (usually edit controls).
	SetValue(szValue) => ComCall(5, this, "wstr", szValue)

	; Retrieves the Microsoft Active Accessibility child identifier for the element. If the element is not a child element, CHILDID_SELF (0) is returned.
	CurrentChildId => (ComCall(6, this, "int*", &pRetVal := 0), pRetVal)

	; Retrieves the Microsoft Active Accessibility name property of the element. The name of an element can be used to find the element in the element tree when the automation ID property is not supported on the element.
	CurrentName => (ComCall(7, this, "ptr*", &pszName := 0), BSTR(pszName))

	; Retrieves the Microsoft Active Accessibility value property.
	CurrentValue => (ComCall(8, this, "ptr*", &pszValue := 0), BSTR(pszValue))

	; Retrieves the Microsoft Active Accessibility description of the element.
	CurrentDescription => (ComCall(9, this, "ptr*", &pszDescription := 0), BSTR(pszDescription))

	; Retrieves the Microsoft Active Accessibility role identifier of the element.
	CurrentRole => (ComCall(10, this, "uint*", &pdwRole := 0), pdwRole)

	; Retrieves the Microsoft Active Accessibility state identifier for the element.
	CurrentState => (ComCall(11, this, "uint*", &pdwState := 0), pdwState)

	; Retrieves the Microsoft Active Accessibility help string for the element.
	CurrentHelp => (ComCall(12, this, "ptr*", &pszHelp := 0), BSTR(pszHelp))

	; Retrieves the Microsoft Active Accessibility keyboard shortcut property for the element.
	CurrentKeyboardShortcut => (ComCall(13, this, "ptr*", &pszKeyboardShortcut := 0), BSTR(pszKeyboardShortcut))

	; Retrieves the Microsoft Active Accessibility property that identifies the selected children of this element.
	GetCurrentSelection() => (ComCall(14, this, "ptr*", &pvarSelectedChildren := 0), IUIAutomationElementArray(pvarSelectedChildren))

	; Retrieves the Microsoft Active Accessibility default action for the element.
	CurrentDefaultAction => (ComCall(15, this, "ptr*", &pszDefaultAction := 0), BSTR(pszDefaultAction))

	; Retrieves the cached Microsoft Active Accessibility child identifier for the element.
	CachedChildId => (ComCall(16, this, "int*", &pRetVal := 0), pRetVal)

	; Retrieves the cached Microsoft Active Accessibility name property of the element.
	CachedName => (ComCall(17, this, "ptr*", &pszName := 0), BSTR(pszName))

	; Retrieves the cached Microsoft Active Accessibility value property.
	CachedValue => (ComCall(18, this, "ptr*", &pszValue := 0), BSTR(pszValue))

	; Retrieves the cached Microsoft Active Accessibility description of the element.
	CachedDescription => (ComCall(19, this, "ptr*", &pszDescription := 0), BSTR(pszDescription))

	; Retrieves the cached Microsoft Active Accessibility role of the element.
	CachedRole => (ComCall(20, this, "uint*", &pdwRole := 0), pdwRole)

	; Retrieves the cached Microsoft Active Accessibility state identifier for the element.
	CachedState => (ComCall(21, this, "uint*", &pdwState := 0), pdwState)

	; Retrieves the cached Microsoft Active Accessibility help string for the element.
	CachedHelp => (ComCall(22, this, "ptr*", &pszHelp := 0), BSTR(pszHelp))

	; Retrieves the cached Microsoft Active Accessibility keyboard shortcut property for the element.
	CachedKeyboardShortcut => (ComCall(23, this, "ptr*", &pszKeyboardShortcut := 0), BSTR(pszKeyboardShortcut))

	; Retrieves the cached Microsoft Active Accessibility property that identifies the selected children of this element.
	GetCachedSelection() => (ComCall(24, this, "ptr*", &pvarSelectedChildren := 0), IUIAutomationElementArray(pvarSelectedChildren))

	; Retrieves the Microsoft Active Accessibility default action for the element.
	CachedDefaultAction => (ComCall(25, this, "ptr*", &pszDefaultAction := 0), BSTR(pszDefaultAction))

	; Retrieves an IAccessible object that corresponds to the Microsoft UI Automation element.
	; This method returns NULL if the underlying implementation of the UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
	GetIAccessible() => (ComCall(26, this, "ptr*", &ppAccessible := 0), ComValue(0xd, ppAccessible))
}

class IUIAutomationMultipleViewPattern extends IUIABase {
	; Retrieves the name of a control-specific view.
	GetViewName(view) => (ComCall(3, this, "int", view, "ptr*", &name := 0), BSTR(name))

	; Sets the view of the control.
	SetCurrentView(view) => ComCall(4, this, "int", view)

	; Retrieves the control-specific identifier of the current view of the control.
	CurrentCurrentView => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves a collection of control-specific view identifiers.
	GetCurrentSupportedViews() => (ComCall(6, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))

	; Retrieves the cached control-specific identifier of the current view of the control.
	CachedCurrentView => (ComCall(7, this, "int*", &retVal := 0), retVal)

	; Retrieves a collection of control-specific view identifiers from the cache.
	GetCachedSupportedViews() => (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
}

class IUIAutomationNotCondition extends IUIAutomationCondition {
	GetChild() => (ComCall(3, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))
}

class IUIAutomationObjectModelPattern extends IUIABase {
	GetUnderlyingObjectModel() => (ComCall(3, this, "ptr*", &retVal := 0), ComValue(0xd, retVal))
}

class IUIAutomationOrCondition extends IUIAutomationAndCondition {
}

class IUIAutomationPropertyCondition extends IUIAutomationCondition {
	PropertyId => (ComCall(3, this, "int*", &propertyId := 0), propertyId)
	PropertyValue => (ComCall(4, this, "ptr", propertyValue := ComVar()), propertyValue[])
	PropertyConditionFlags => (ComCall(5, this, "int*", &flags := 0), flags)
}

class IUIAutomationProxyFactory extends IUIABase {
	CreateProvider(hwnd, idObject, idChild) => (ComCall(3, this, "ptr", hwnd, "int", idObject, "int", idChild, "ptr*", &provider := 0), ComValue(0xd, provider))
	ProxyFactoryId => (ComCall(4, this, "ptr*", &factoryId := 0), BSTR(factoryId))
}

class IUIAutomationProxyFactoryEntry extends IUIABase {
	ProxyFactory() => (ComCall(3, this, "ptr*", &factory := 0), IUIAutomationProxyFactory(factory))
	ClassName {
		get => (ComCall(4, this, "ptr*", &classname := 0), BSTR(classname))
		set => (ComCall(9, this, "wstr", Value))
	}
	ImageName {
		get => (ComCall(5, this, "ptr*", &imageName := 0), BSTR(imageName))
		set => (ComCall(10, this, "wstr", Value))
	}
	AllowSubstringMatch {
		get => (ComCall(6, this, "int*", &allowSubstringMatch := 0), allowSubstringMatch)
		set => (ComCall(11, this, "int", Value))
	}
	CanCheckBaseClass {
		get => (ComCall(7, this, "int*", &canCheckBaseClass := 0), canCheckBaseClass)
		set => (ComCall(12, this, "int", Value))
	}
	NeedsAdviseEvents {
		get => (ComCall(8, this, "int*", &adviseEvents := 0), adviseEvents)
		set => (ComCall(13, this, "int", Value))
	}
	SetWinEventsForAutomationEvent(eventId, propertyId, winEvents) => ComCall(14, this, "int", eventId, "Int", propertyId, "ptr", winEvents)
	GetWinEventsForAutomationEvent(eventId, propertyId) => (ComCall(15, this, "int", eventId, "Int", propertyId, "ptr*", &winEvents := 0), ComValue(0x200d, winEvents))
}

class IUIAutomationProxyFactoryMapping extends IUIABase {
	Count => (ComCall(3, this, "uint*", &count := 0), count)
	GetTable() => (ComCall(4, this, "ptr*", &table := 0), ComValue(0x200d, table))
	GetEntry(index) => (ComCall(5, this, "int", index, "ptr*", &entry := 0), IUIAutomationProxyFactoryEntry(entry))
	SetTable(factoryList) => ComCall(6, this, "ptr", factoryList)
	InsertEntries(before, factoryList) => ComCall(7, this, "uint", before, "ptr", factoryList)
	InsertEntry(before, factory) => ComCall(8, this, "uint", before, "ptr", factory)
	RemoveEntry(index) => ComCall(9, this, "uint", index)
	ClearTable() => ComCall(10, this)
	RestoreDefaultTable() => ComCall(11, this)
}

class IUIAutomationRangeValuePattern extends IUIABase {
	; Sets the value of the control.
	SetValue(val) => ComCall(3, this, "double", val)

	; Retrieves the value of the control.
	CurrentValue => (ComCall(4, this, "double*", &retVal := 0), retVal)

	; Indicates whether the value of the element can be changed.
	CurrentIsReadOnly => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves the maximum value of the control.
	CurrentMaximum => (ComCall(6, this, "double*", &retVal := 0), retVal)

	; Retrieves the minimum value of the control.
	CurrentMinimum => (ComCall(7, this, "double*", &retVal := 0), retVal)

	; The LargeChange and SmallChange property can support a Not a Number (NaN) value. When retrieving this property, a client can use the _isnan function to determine whether the property is a NaN value.

	; Retrieves the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
	CurrentLargeChange => (ComCall(8, this, "double*", &retVal := 0), retVal)

	; Retrieves the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
	CurrentSmallChange => (ComCall(9, this, "double*", &retVal := 0), retVal)

	; Retrieves the cached value of the control.
	CachedValue => (ComCall(10, this, "double*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the value of the element can be changed.
	CachedIsReadOnly => (ComCall(11, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached maximum value of the control.
	CachedMaximum => (ComCall(12, this, "double*", &retVal := 0), retVal)

	; Retrieves the cached minimum value of the control.
	CachedMinimum => (ComCall(13, this, "double*", &retVal := 0), retVal)

	; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a large change is made, such as when the PAGE DOWN key is pressed.
	CachedLargeChange => (ComCall(14, this, "double*", &retVal := 0), retVal)

	; Retrieves, from the cache, the value that is added to or subtracted from the value of the control when a small change is made, such as when an arrow key is pressed.
	CachedSmallChange => (ComCall(15, this, "double*", &retVal := 0), retVal)
}

class IUIAutomationScrollItemPattern extends IUIABase {
	; Scrolls the content area of a container object to display the UI Automation element within the visible region (viewport) of the container.
	; This method does not provide the ability to specify the position of the element within the viewport.
	ScrollIntoView() => ComCall(3, this)
}

class IUIAutomationScrollPattern extends IUIABase {
	; Scrolls the visible region of the content area horizontally and vertically.
	Scroll(horizontalAmount, verticalAmount) => ComCall(3, this, "int", horizontalAmount, "int", verticalAmount)

	; Sets the horizontal and vertical scroll positions as a percentage of the total content area within the UI Automation element.
	; This method is useful only when the content area of the control is larger than the visible region.
	SetScrollPercent(horizontalPercent, verticalPercent) => ComCall(4, this, "double", horizontalPercent, "double", verticalPercent)

	; Retrieves the horizontal scroll position.
	CurrentHorizontalScrollPercent => (ComCall(5, this, "double*", &retVal := 0), retVal)

	; Retrieves the vertical scroll position.
	CurrentVerticalScrollPercent => (ComCall(6, this, "double*", &retVal := 0), retVal)

	; Retrieves the horizontal size of the viewable region of a scrollable element.
	CurrentHorizontalViewSize => (ComCall(7, this, "double*", &retVal := 0), retVal)

	; Retrieves the vertical size of the viewable region of a scrollable element.
	CurrentVerticalViewSize => (ComCall(8, this, "double*", &retVal := 0), retVal)

	; Indicates whether the element can scroll horizontally.
	; This property can be dynamic. For example, the content area of the element might not be larger than the current viewable area, meaning that the property is FALSE. However, resizing the element or adding child items can increase the bounds of the content area beyond the viewable area, making the property TRUE.
	CurrentHorizontallyScrollable => (ComCall(9, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element can scroll vertically.
	CurrentVerticallyScrollable => (ComCall(10, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached horizontal scroll position.
	CachedHorizontalScrollPercent => (ComCall(11, this, "double*", &retVal := 0), retVal)

	; Retrieves the cached vertical scroll position.
	CachedVerticalScrollPercent => (ComCall(12, this, "double*", &retVal := 0), retVal)

	; Retrieves the cached horizontal size of the viewable region of a scrollable element.
	CachedHorizontalViewSize => (ComCall(13, this, "double*", &retVal := 0), retVal)

	; Retrieves the cached vertical size of the viewable region of a scrollable element.
	CachedVerticalViewSize => (ComCall(14, this, "double*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can scroll horizontally.
	CachedHorizontallyScrollable => (ComCall(15, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can scroll vertically.
	CachedVerticallyScrollable => (ComCall(16, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationSelectionItemPattern extends IUIABase {
	; Clears any selected items and then selects the current element.
	Select() => ComCall(3, this)

	; Adds the current element to the collection of selected items.
	AddToSelection() => ComCall(4, this)

	; Removes this element from the selection.
	; An error code is returned if this element is the only one in the selection and the selection container requires at least one element to be selected.
	RemoveFromSelection() => ComCall(5, this)

	; Indicates whether this item is selected.
	CurrentIsSelected => (ComCall(6, this, "int*", &retVal := 0), retVal)

	; Retrieves the element that supports IUIAutomationSelectionPattern and acts as the container for this item.
	CurrentSelectionContainer => (ComCall(7, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))

	; A cached value that indicates whether this item is selected.
	CachedIsSelected => (ComCall(8, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached element that supports IUIAutomationSelectionPattern and acts as the container for this item.
	CachedSelectionContainer => (ComCall(9, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
}

class IUIAutomationSelectionPattern extends IUIABase {
	; Retrieves the selected elements in the container.
	GetCurrentSelection() => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Indicates whether more than one item in the container can be selected at one time.
	CurrentCanSelectMultiple => (ComCall(4, this, "int*", &retVal := 0), retVal)

	; Indicates whether at least one item must be selected at all times.
	CurrentIsSelectionRequired => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached selected elements in the container.
	GetCachedSelection() => (ComCall(6, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a cached value that indicates whether more than one item in the container can be selected at one time.
	CachedCanSelectMultiple => (ComCall(7, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether at least one item must be selected at all times.
	CachedIsSelectionRequired => (ComCall(8, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationSpreadsheetPattern extends IUIABase {
	GetItemByName(name) => (ComCall(3, this, "wstr", name, "ptr*", &element := 0), IUIAutomationElement(element))
}

class IUIAutomationSpreadsheetItemPattern extends IUIABase {
	CurrentFormula => (ComCall(3, this, "ptr*", &retVal := 0), BSTR(retVal))
	GetCurrentAnnotationObjects() => (ComCall(4, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
	GetCurrentAnnotationTypes() => (ComCall(5, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
	CachedFormul => (ComCall(6, this, "ptr*", &retVal := 0), BSTR(retVal))
	GetCachedAnnotationObjects() => (ComCall(7, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
	GetCachedAnnotationTypes() => (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
}

class IUIAutomationStylesPattern extends IUIABase {
	CurrentStyleId => (ComCall(3, this, "int*", &retVal := 0), retVal)
	CurrentStyleName => (ComCall(4, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentFillColor => (ComCall(5, this, "int*", &retVal := 0), retVal)
	CurrentFillPatternStyle => (ComCall(6, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentShape => (ComCall(7, this, "ptr*", &retVal := 0), BSTR(retVal))
	CurrentFillPatternColor => (ComCall(8, this, "int*", &retVal := 0), retVal)
	CurrentExtendedProperties => (ComCall(9, this, "ptr*", &retVal := 0), BSTR(retVal))
	GetCurrentExtendedPropertiesAsArray() {
		ComCall(10, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0), arr := []
		for p in NativeArray(propertyArray, propertyCount)
			arr.Push({ PropertyName: BSTR(NumGet(p, "ptr")), PropertyValue: BSTR(NumGet(p, A_PtrSize, "ptr")) })
		return arr
	}
	CachedStyleId => (ComCall(11, this, "int*", &retVal := 0), retVal)
	CachedStyleName => (ComCall(12, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedFillColor => (ComCall(13, this, "int*", &retVal := 0), retVal)
	CachedFillPatternStyle => (ComCall(14, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedShape => (ComCall(15, this, "ptr*", &retVal := 0), BSTR(retVal))
	CachedFillPatternColor => (ComCall(16, this, "int*", &retVal := 0), retVal)
	CachedExtendedProperties => (ComCall(17, this, "ptr*", &retVal := 0), BSTR(retVal))
	GetCachedExtendedPropertiesAsArray() {
		ComCall(18, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0), arr := []
		for p in NativeArray(propertyArray, propertyCount)
			arr.Push({ PropertyName: BSTR(NumGet(p, "ptr")), PropertyValue: BSTR(NumGet(p, A_PtrSize, "ptr")) })
		return arr
	}
}

class IUIAutomationSynchronizedInputPattern extends IUIABase {
	; Causes the Microsoft UI Automation provider to start listening for mouse or keyboard input.
	; When matching input is found, the provider checks whether the target element matches the current element. If they match, the provider raises the UIA_InputReachedTargetEventId event; otherwise it raises the UIA_InputReachedOtherElementEventId or UIA_InputDiscardedEventId event.
	; After receiving input of the specified type, the provider stops checking for input and continues as normal.
	; If the provider is already listening for input, this method returns E_INVALIDOPERATION.
	StartListening(inputType) => ComCall(3, this, "int", inputType)

	; Causes the Microsoft UI Automation provider to stop listening for mouse or keyboard input.
	Cancel() => ComCall(4, this)
}

class IUIAutomationTableItemPattern extends IUIABase {
	; Retrieves the row headers associated with a table item or cell.
	GetCurrentRowHeaderItems() => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves the column headers associated with a table item or cell.
	GetCurrentColumnHeaderItems() => (ComCall(4, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves the cached row headers associated with a table item or cell.
	GetCachedRowHeaderItems() => (ComCall(5, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves the cached column headers associated with a table item or cell.
	GetCachedColumnHeaderItems() => (ComCall(6, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
}

class IUIAutomationTablePattern extends IUIABase {
	; Retrieves a collection of UI Automation elements representing all the row headers in a table.
	GetCurrentRowHeaders() => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a collection of UI Automation elements representing all the column headers in a table.
	GetCurrentColumnHeaders() => (ComCall(4, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves the primary direction of traversal for the table.
	CurrentRowOrColumnMajor => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached collection of UI Automation elements representing all the row headers in a table.
	GetCachedRowHeaders() => (ComCall(6, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves a cached collection of UI Automation elements representing all the column headers in a table.
	GetCachedColumnHeaders() => (ComCall(7, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))

	; Retrieves the cached primary direction of traversal for the table.
	CachedRowOrColumnMajor => (ComCall(8, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationTextChildPattern extends IUIABase {
	TextContainer => (ComCall(3, this, "ptr*", &container := 0), IUIAutomationElement(container))
	TextRange => (ComCall(4, this, "ptr*", &range := 0), IUIAutomationTextRange(range))
}

class IUIAutomationTextEditPattern extends IUIABase {
	GetActiveComposition() => (ComCall(3, this, "ptr*", &range := 0), IUIAutomationTextRange(range))
	GetConversionTarget() => (ComCall(4, this, "ptr*", &range := 0), IUIAutomationTextRange(range))
}

class IUIAutomationTextPattern extends IUIABase {
	; Retrieves the degenerate (empty) text range nearest to the specified screen coordinates.
	/*
	 * A text range that wraps a child object is returned if the screen coordinates are within the coordinates of an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
	 * Because hidden text is not ignored, this method retrieves a degenerate range from the visible text closest to the specified coordinates.
	 * The implementation of RangeFromPoint in Windows Internet Explorer 9 does not return the expected result. Instead, clients should,
	 * 1. Call the GetVisibleRanges method to retrieve an array of visible text ranges.Call the GetVisibleRanges method to retrieve an array of visible text ranges.
	 * 2. Call the GetVisibleRanges method to retrieve an array of visible text ranges.For each text range in the array, call IUIAutomationTextRange,,GetBoundingRectangles to retrieve the bounding rectangles.
	 * 3. Call the GetVisibleRanges method to retrieve an array of visible text ranges.Check the bounding rectangles to find the text range that occupies the particular screen coordinates.
	 */
	RangeFromPoint(pt) => (ComCall(3, this, "int64", pt, "ptr*", &range := 0), IUIAutomationTextRange(range))

	; Retrieves a text range enclosing a child element such as an image, hyperlink, Microsoft Excel spreadsheet, or other embedded object.
	; If there is no text in the range that encloses the child element, a degenerate (empty) range is returned.
	; The child parameter is either a child of the element associated with a IUIAutomationTextPattern or from the array of children of a IUIAutomationTextRange.
	RangeFromChild(child) => (ComCall(4, this, "ptr", child, "ptr*", &range := 0), IUIAutomationTextRange(range))

	; Retrieves a collection of text ranges that represents the currently selected text in a text-based control.
	; If the control supports the selection of multiple, non-contiguous spans of text, the ranges collection receives one text range for each selected span.
	; If the control contains only a single span of selected text, the ranges collection receives a single text range.
	; If the control contains a text insertion point but no text is selected, the ranges collection receives a degenerate (empty) text range at the position of the text insertion point.
	; If the control does not contain a text insertion point or does not support text selection, ranges is set to NULL.
	; Use the IUIAutomationTextPattern,,SupportedTextSelection property to test whether a control supports text selection.
	GetSelection() => (ComCall(5, this, "ptr*", &ranges := 0), IUIAutomationTextRangeArray(ranges))

	; Retrieves an array of disjoint text ranges from a text-based control where each text range represents a contiguous span of visible text.
	; If the visible text consists of one contiguous span of text, the ranges array will contain a single text range that represents all of the visible text.
	; If the visible text consists of multiple, disjoint spans of text, the ranges array will contain one text range for each visible span, beginning with the first visible span, and ending with the last visible span. Disjoint spans of visible text can occur when the content of a text-based control is partially obscured by an overlapping window or other object, or when a text-based control with multiple pages or columns has content that is partially scrolled out of view.
	; IUIAutomationTextPattern,,GetVisibleRanges retrieves a degenerate (empty) text range if no text is visible, if all text is scrolled out of view, or if the text-based control contains no text.
	GetVisibleRanges() => (ComCall(6, this, "ptr*", &ranges := 0), IUIAutomationTextRangeArray(ranges))

	; Retrieves a text range that encloses the main text of a document.
	; Some auxiliary text such as headers, footnotes, or annotations might not be included.
	DocumentRange() => (ComCall(7, this, "ptr*", &range := 0), IUIAutomationTextRange(range))

	; Retrieves a value that specifies the type of text selection that is supported by the control.
	SupportedTextSelection => (ComCall(8, this, "int*", &supportedTextSelection := 0), supportedTextSelection)
}

class IUIAutomationTextRange extends IUIABase {
	; Retrieves a IUIAutomationTextRange identical to the original and inheriting all properties of the original.
	; The range can be manipulated independently of the original.
	Clone() => (ComCall(3, this, "ptr*", &clonedRange := 0), IUIAutomationTextRange(clonedRange))

	; Retrieves a value that specifies whether this text range has the same endpoints as another text range.
	; This method compares the endpoints of the two text ranges, not the text in the ranges. The ranges are identical if they share the same endpoints. If two text ranges have different endpoints, they are not identical even if the text in both ranges is exactly the same.
	Compare(range) => (ComCall(4, this, "ptr", range, "int*", &areSame := 0), areSame)

	; Retrieves a value that specifies whether the start or end endpoint of this text range is the same as the start or end endpoint of another text range.
	CompareEndpoints(srcEndPoint, range, targetEndPoint) => (ComCall(5, this, "int", srcEndPoint, "ptr", range, "int", targetEndPoint, "int*", &compValue := 0), compValue)

	; Normalizes the text range by the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit.
	; Client applications such as screen readers use this method to retrieve the full word, sentence, or paragraph that exists at the insertion point or caret position.
	; Despite its name, the ExpandToEnclosingUnit method does not necessarily expand a text range. Instead, it "normalizes" a text range by moving the endpoints so that the range encompasses the specified text unit. The range is expanded if it is smaller than the specified unit, or shortened if it is longer than the specified unit. If the range is already an exact quantity of the specified units, it remains unchanged. The following diagram shows how ExpandToEnclosingUnit normalizes a text range by moving the endpoints of the range.
	; ExpandToEnclosingUnit defaults to the next largest text unit supported if the specified text unit is not supported by the control. The order, from smallest unit to largest, is as follows, Character Format Word Line Paragraph Page Document
	; ExpandToEnclosingUnit respects both visible and hidden text.
	ExpandToEnclosingUnit(textUnit) => ComCall(6, this, "int", textUnit)

	; Retrieves a text range subset that has the specified text attribute value.
	; The FindAttribute method retrieves matching text regardless of whether the text is hidden or visible. Use UIA_IsHiddenAttributeId to check text visibility.
	FindAttribute(attr, val, backward) {
		if A_PtrSize = 4
			val := ComVar(val, , true), ComCall(7, this, "int", attr, "int64", NumGet(val, "int64"), "int64", NumGet(val, 8, "int64"), "int", backward, "ptr*", &found := 0)
		else
			ComCall(7, this, "int", attr, "ptr", ComVar(val, , true), "int", backward, "ptr*", &found := 0)
		if (found)
			return IUIAutomationTextRange(found)
		throw TargetError("Target textrange not found.")
	}

	; Retrieves a text range subset that contains the specified text. There is no differentiation between hidden and visible text.
	FindText(text, backward, ignoreCase) {
		if (ComCall(8, this, "wstr", text, "int", backward, "int", ignoreCase, "ptr*", &found := 0), found)
			return IUIAutomationTextRange(found)
		throw TargetError("Target textrange not found.")
	}

	; Retrieves the value of the specified text attribute across the entire text range.
	; The type of value retrieved by this method depends on the attr parameter. For example, calling GetAttributeValue with the attr parameter set to UIA_FontNameAttributeId returns a string that represents the font name of the text range, while calling GetAttributeValue with attr set to UIA_IsItalicAttributeId would return a boolean.
	; If the attribute specified by attr is not supported, the value parameter receives a value that is equivalent to the IUIAutomation,,ReservedNotSupportedValue property.
	; A text range can include more than one value for a particular attribute. For example, if a text range includes more than one font, the FontName attribute will have multiple values. An attribute with more than one value is called a mixed attribute. You can determine if a particular attribute is a mixed attribute by comparing the value retrieved from GetAttributeValue with the UIAutomation,,ReservedMixedAttributeValue property.
	; The GetAttributeValue method retrieves the attribute value regardless of whether the text is hidden or visible. Use UIA_ IsHiddenAttributeId to check text visibility.
	GetAttributeValue(attr) => (ComCall(9, this, "int", attr, "ptr", val := ComVar()), val[])

	; Retrieves a collection of bounding rectangles for each fully or partially visible line of text in a text range.
	GetBoundingRectangles() => (ComCall(10, this, "ptr*", &boundingRects := 0), ComValue(0x2005, boundingRects))

	; Returns the innermost UI Automation element that encloses the text range.
	GetEnclosingElement() => (ComCall(11, this, "ptr*", &enclosingElement := 0), IUIAutomationElement(enclosingElement))

	; Returns the plain text of the text range.
	GetText(maxLength := -1) => (ComCall(12, this, "int", maxLength, "ptr*", &text := 0), BSTR(text))

	; Moves the text range forward or backward by the specified number of text units .
	/*
	 * IUIAutomationTextRange,,Move moves the text range to span a different part of the text; it does not alter the text in any way.
	 * For a non-degenerate (non-empty) text range, IUIAutomationTextRange,,Move normalizes and moves the range by performing the following steps.
	 * The text range is collapsed to a degenerate (empty) range at the starting endpoint.
	 * If necessary, the resulting text range is moved backward in the document to the beginning of the requested text unit boundary.
	 * The text range is moved forward or backward in the document by the requested number of text unit boundaries.
	 * The text range is expanded from the degenerate state by moving the ending endpoint forward by one requested text unit boundary.
	 * If any of the preceding steps fail, the text range is left unchanged. If the text range cannot be moved as far as the requested number of text units, but can be moved by a smaller number of text units, the text range is moved by the smaller number of text units and moved is set to the number of text units moved.
	 * For a degenerate text range, IUIAutomationTextRange,,Move simply moves the text insertion point by the specified number of text units.
	 * When moving a text range, IUIAutomationTextRange,,Move ignores the boundaries of any embedded objects in the text.
	 * IUIAutomationTextRange,,Move respects both hidden and visible text.
	 * If a text-based control does not support the text unit specified by the unit parameter, IUIAutomationTextRange,,Move substitutes the next larger supported text unit. The size of the text units, from smallest unit to largest, is as follows.
	 * Character
	 * Format
	 * Word
	 * Line
	 * Paragraph
	 * Page
	 * Document
	 */
	Move(unit, count) => (ComCall(13, this, "int", unit, "int", count, "int*", &moved := 0), moved)

	; Moves one endpoint of the text range the specified number of text units within the document range.
	MoveEndpointByUnit(endpoint, unit, count) {	; TextPatternRangeEndpoint , TextUnit
		ComCall(14, this, "int", endpoint, "int", unit, "int", count, "int*", &moved := 0)	; TextPatternRangeEndpoint,TextUnit
		return moved
	}

	; Moves one endpoint of the current text range to the specified endpoint of a second text range.
	; If the endpoint being moved crosses the other endpoint of the same text range, that other endpoint is moved also, resulting in a degenerate (empty) range and ensuring the correct ordering of the endpoints (that is, the start is always less than or equal to the end).
	MoveEndpointByRange(srcEndPoint, range, targetEndPoint) {	; TextPatternRangeEndpoint , IUIAutomationTextRange , TextPatternRangeEndpoint
		ComCall(15, this, "int", srcEndPoint, "ptr", range, "int", targetEndPoint)
	}

	; Selects the span of text that corresponds to this text range, and removes any previous selection.
	; If the Select method is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
	Select() => ComCall(16, this)

	; Adds the text range to the collection of selected text ranges in a control that supports multiple, disjoint spans of selected text.
	; The text insertion point moves to the newly selected text. If AddToSelection is called on a text range object that represents a degenerate (empty) text range, the text insertion point moves to the starting endpoint of the text range.
	AddToSelection() => ComCall(17, this)

	; Removes the text range from an existing collection of selected text in a text container that supports multiple, disjoint selections.
	; The text insertion point moves to the area of the removed highlight. Providing a degenerate text range also moves the insertion point.
	RemoveFromSelection() => ComCall(18, this)

	; Causes the text control to scroll until the text range is visible in the viewport.
	; The method respects both hidden and visible text. If the text range is hidden, the text control will scroll only if the hidden text has an anchor in the viewport.
	; A Microsoft UI Automation client can check text visibility by calling IUIAutomationTextRange,,GetAttributeValue with the attr parameter set to UIA_IsHiddenAttributeId.
	ScrollIntoView(alignToTop) => ComCall(19, this, "int", alignToTop)

	; Retrieves a collection of all embedded objects that fall within the text range.
	GetChildren() => (ComCall(20, this, "ptr*", &children := 0), IUIAutomationElementArray(children))
}

class IUIAutomationTextRangeArray extends IUIABase {
	; Retrieves the number of text ranges in the collection.
	Length => (ComCall(3, this, "int*", &length := 0), length)

	; Retrieves a text range from the collection.
	GetElement(index) => (ComCall(4, this, "int", index, "ptr*", &element := 0), IUIAutomationTextRange(element))
}

class IUIAutomationTogglePattern extends IUIABase {
	; Cycles through the toggle states of the control.
	; A control cycles through its states in this order, ToggleState_On, ToggleState_Off and, if supported, ToggleState_Indeterminate.
	Toggle() => ComCall(3, this)

	; Retrieves the state of the control.
	CurrentToggleState => (ComCall(4, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached state of the control.
	CachedToggleState => (ComCall(5, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationTransformPattern extends IUIABase {
	; An element cannot be moved, resized or rotated such that its resulting screen location would be completely outside the coordinates of its container and inaccessible to the keyboard or mouse. For example, when a top-level window is moved completely off-screen or a child object is moved outside the boundaries of the container's viewport, the object is placed as close to the requested screen coordinates as possible with the top or left coordinates overridden to be within the container boundaries.

	; Moves the UI Automation element.
	Move(x, y) => ComCall(3, this, "double", x, "double", y)

	; Resizes the UI Automation element.
	; When called on a control that supports split panes, this method can have the side effect of resizing other contiguous panes.
	Resize(width, height) => ComCall(4, this, "double", width, "double", height)

	; Rotates the UI Automation element.
	Rotate(degrees) => ComCall(5, this, "double", degrees)

	; Indicates whether the element can be moved.
	CurrentCanMove => (ComCall(6, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element can be resized.
	CurrentCanResize => (ComCall(7, this, "int*", &retVal := 0), retVal)

	; Indicates whether the element can be rotated.
	CurrentCanRotate => (ComCall(8, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can be moved.
	CachedCanMove => (ComCall(9, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can be resized.
	CachedCanResize => (ComCall(10, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the element can be rotated.
	CachedCanRotate => (ComCall(11, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationTreeWalker extends IUIABase {
	; The structure of the Microsoft UI Automation tree changes as the visible UI elements on the desktop change.
	; An element can have additional child elements that do not match the current view condition and thus are not returned when navigating the element tree.

	; Retrieves the parent element of the specified UI Automation element.
	GetParentElement(element) => (ComCall(3, this, "ptr", element, "ptr*", &parent := 0), IUIAutomationElement(parent))

	; Retrieves the first child element of the specified UI Automation element.
	GetFirstChildElement(element) => (ComCall(4, this, "ptr", element, "ptr*", &first := 0), IUIAutomationElement(first))

	; Retrieves the last child element of the specified UI Automation element.
	GetLastChildElement(element) => (ComCall(5, this, "ptr", element, "ptr*", &last := 0), IUIAutomationElement(last))

	; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetNextSiblingElement(element) => (ComCall(6, this, "ptr", element, "ptr*", &next := 0), IUIAutomationElement(next))

	; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetPreviousSiblingElement(element) => (ComCall(7, this, "ptr", element, "ptr*", &previous := 0), IUIAutomationElement(previous))

	; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view.
	; The element is normalized by navigating up the ancestor chain in the tree until an element that satisfies the view condition (specified by a previous call to IUIAutomationTreeWalker,,Condition) is reached. If the root element is reached, the root element is returned, even if it does not satisfy the view condition.
	; This method is useful for applications that obtain references to UI Automation elements by hit-testing. The application might want to work only with specific types of elements, and can use IUIAutomationTreeWalker,,Normalize to make sure that no matter what element is initially retrieved (for example, when a scroll bar gets the input focus), only the element of interest (such as a content element) is ultimately retrieved.
	NormalizeElement(element) => (ComCall(8, this, "ptr", element, "ptr*", &normalized := 0), IUIAutomationElement(normalized))

	; Retrieves the parent element of the specified UI Automation element, and caches properties and control patterns.
	GetParentElementBuildCache(element, cacheRequest) => (ComCall(9, this, "ptr", element, "ptr", cacheRequest, "ptr*", &parent := 0), IUIAutomationElement(parent))

	; Retrieves the first child element of the specified UI Automation element, and caches properties and control patterns.
	GetFirstChildElementBuildCache(element, cacheRequest) => (ComCall(10, this, "ptr", element, "ptr", cacheRequest, "ptr*", &first := 0), IUIAutomationElement(first))

	; Retrieves the last child element of the specified UI Automation element, and caches properties and control patterns.
	GetLastChildElementBuildCache(element, cacheRequest) => (ComCall(11, this, "ptr", element, "ptr", cacheRequest, "ptr*", &last := 0), IUIAutomationElement(last))

	; Retrieves the next sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetNextSiblingElementBuildCache(element, cacheRequest) => (ComCall(12, this, "ptr", element, "ptr", cacheRequest, "ptr*", &next := 0), IUIAutomationElement(next))

	; Retrieves the previous sibling element of the specified UI Automation element, and caches properties and control patterns.
	GetPreviousSiblingElementBuildCache(element, cacheRequest) => (ComCall(13, this, "ptr", element, "ptr", cacheRequest, "ptr*", &previous := 0), IUIAutomationElement(previous))

	; Retrieves the ancestor element nearest to the specified Microsoft UI Automation element in the tree view, prefetches the requested properties and control patterns, and stores the prefetched items in the cache.
	NormalizeElementBuildCache(element, cacheRequest) => (ComCall(14, this, "ptr", element, "ptr", cacheRequest, "ptr*", &normalized := 0), IUIAutomationElement(normalized))

	; Retrieves the condition that defines the view of the UI Automation tree. This property is read-only.
	; The condition that defines the view. This is the interface that was passed to CreateTreeWalker.
	Condition() => (ComCall(15, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))
}

class IUIAutomationValuePattern extends IUIABase {
	; Sets the value of the element.
	; The CurrentIsEnabled property must be TRUE, and the IUIAutomationValuePattern,,CurrentIsReadOnly property must be FALSE.
	SetValue(val) => ComCall(3, this, "wstr", val)

	; Retrieves the value of the element.
	; Single-line edit controls support programmatic access to their contents through IUIAutomationValuePattern. However, multiline edit controls do not support this control pattern, and their contents must be retrieved by using IUIAutomationTextPattern.
	; This property does not support the retrieval of formatting information or substring values. IUIAutomationTextPattern must be used in these scenarios as well.
	CurrentValue => (ComCall(4, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Indicates whether the value of the element is read-only.
	CurrentIsReadOnly => (ComCall(5, this, "int*", &retVal := 0), retVal)

	; Retrieves the cached value of the element.
	CachedValue => (ComCall(6, this, "ptr*", &retVal := 0), BSTR(retVal))

	; Retrieves a cached value that indicates whether the value of the element is read-only.
	; This property must be TRUE for IUIAutomationValuePattern,,SetValue to succeed.
	CachedIsReadOnly => (ComCall(7, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationVirtualizedItemPattern extends IUIABase {
	; Creates a full UI Automation element for a virtualized item.
	; A virtualized item is represented by a placeholder automation element in the UI Automation tree. The Realize method causes the provider to make full information available for the item so that a full UI Automation element can be created for the item.
	Realize() => ComCall(3, this)
}

class IUIAutomationWindowPattern extends IUIABase {
	; Closes the window.
	; When called on a split pane control, this method closes the pane and removes the associated split. This method may also close all other panes, depending on implementation.
	Close() => ComCall(3, this)

	; Causes the calling code to block for the specified time or until the associated process enters an idle state, whichever completes first.
	WaitForInputIdle(milliseconds) => (ComCall(4, this, "int", milliseconds, "int*", &success := 0), success)

	; Minimizes, maximizes, or restores the window.
	SetWindowVisualState(state) => ComCall(5, this, "int", state)

	; Indicates whether the window can be maximized.
	CurrentCanMaximize => (ComCall(6, this, "int*", &retVal := 0), retVal)

	; Indicates whether the window can be minimized.
	CurrentCanMinimize => (ComCall(7, this, "int*", &retVal := 0), retVal)

	; Indicates whether the window is modal.
	CurrentIsModal => (ComCall(8, this, "int*", &retVal := 0), retVal)

	; Indicates whether the window is the topmost element in the z-order.
	CurrentIsTopmost => (ComCall(9, this, "int*", &retVal := 0), retVal)

	; Retrieves the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
	CurrentWindowVisualState => (ComCall(10, this, "int*", &retVal := 0), retVal)

	; Retrieves the current state of the window for the purposes of user interaction.
	CurrentWindowInteractionState => (ComCall(11, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the window can be maximized.
	CachedCanMaximize => (ComCall(12, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the window can be minimized.
	CachedCanMinimize => (ComCall(13, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the window is modal.
	CachedIsModal => (ComCall(14, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates whether the window is the topmost element in the z-order.
	CachedIsTopmost => (ComCall(15, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates the visual state of the window; that is, whether it is in the normal, maximized, or minimized state.
	CachedWindowVisualState => (ComCall(16, this, "int*", &retVal := 0), retVal)

	; Retrieves a cached value that indicates the current state of the window for the purposes of user interaction.
	CachedWindowInteractionState => (ComCall(17, this, "int*", &retVal := 0), retVal)
}

/*	event handle sample
 * HandleAutomationEvent(pself,sender,eventId) ; IUIAutomationElement , EVENTID
 * HandleFocusChangedEvent(pself,sender) ; IUIAutomationElement
 * HandlePropertyChangedEvent(pself,sender,propertyId,newValue) ; IUIAutomationElement, PROPERTYID, VARIANT
 * HandleStructureChangedEvent(pself,sender,changeType,runtimeId) ; IUIAutomationElement, StructureChangeType, SAFEARRAY
 */
IUIA_EventHandler(funcobj) {
	if !HasMethod(funcobj, "Call")
		throw TypeError("it is not a func", -2)
	buf := Buffer(A_PtrSize * 5)
	cb1 := CallbackCreate(EventHandler, "F", 3)
	cb2 := CallbackCreate(EventHandler, "F", 1)
	cb3 := CallbackCreate(funcobj, "F")
	NumPut("ptr", buf.Ptr + A_PtrSize, "ptr", cb1, "ptr", cb2, "ptr", cb2, "ptr", cb3, buf)
	buf.DefineProp("__Delete", { call: (*) => (CallbackFree(cb1), CallbackFree(cb2), CallbackFree(cb3)) })
	return buf

	EventHandler(self, param1 := 0, param2 := 0) {
		static str := "                                        "
		if (param1) {
			DllCall('ole32\StringFromGUID2', "ptr", param1, "wstr", str, "int", 80)
			switch str, false {
				case "{00000000-0000-0000-C000-000000000046}", "{146c3c17-f12e-4e22-8c27-f894b9b79c69}", "{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}", "{e81d1b4e-11c5-42f8-9754-e7036c79f054}", "{c270f6b5-5c69-4290-9745-7a7f97169468}":
					return NumPut("ptr", self, param2) * 0
				default:
					return 0x80004002
			}
		}
	}
}

IUIA_RuntimeIdToString(runtimeId) {
	str := ""
	for v in runtimeId
		str .= "." Format("{:X}", v)
	return LTrim(str, ".")
}

IUIA_RuntimeIdFromString(str) {
	t := StrSplit(str, ".")
	arr := ComObjArray(3, t.Length)
	for v in t
		arr[A_Index - 1] := Integer("0x" v)
	return arr
}
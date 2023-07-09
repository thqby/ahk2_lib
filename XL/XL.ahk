/************************************************************************
 * @file: XL.ahk
 * @description: High performance library for reading and writing Excel(xls,xlsx) files.
 * @author thqby
 * @date 2023/07/09
 * @version 1.1.3 (libxl 4.2.0)
 * @documentation https://www.libxl.com/documentation.html
 * @enum var
 * Color {BLACK = 8, WHITE, RED, BRIGHTGREEN, BLUE, YELLOW, PINK, TURQUOISE, DARKRED, GREEN, DARKBLUE, DARKYELLOW, VIOLET, TEAL, GRAY25, GRAY50, PERIWINKLE_CF, PLUM_CF, IVORY_CF, LIGHTTURQUOISE_CF, DARKPURPLE_CF, CORAL_CF, OCEANBLUE_CF, ICEBLUE_CF, DARKBLUE_CL, PINK_CL, YELLOW_CL, TURQUOISE_CL, VIOLET_CL, DARKRED_CL, TEAL_CL, BLUE_CL, SKYBLUE, LIGHTTURQUOISE, LIGHTGREEN, LIGHTYELLOW, PALEBLUE, ROSE, LAVENDER, TAN, LIGHTBLUE, AQUA, LIME, GOLD, LIGHTORANGE, ORANGE, BLUEGRAY, GRAY40, DARKTEAL, SEAGREEN, DARKGREEN, OLIVEGREEN, BROWN, PLUM, INDIGO, GRAY80, DEFAULT_FOREGROUND = 0x40, DEFAULT_BACKGROUND = 0x41, TOOLTIP = 0x51, NONE = 0x7F, AUTO = 0x7FFF}
 * NumFormat {GENERAL = 0, NUMBER = 1, NUMBER_D2 = 2, NUMBER_SEP = 3, NUMBER_SEP_D2 = 4, CURRENCY_NEGBRA = 5, CURRENCY_NEGBRARED = 6, CURRENCY_D2_NEGBRA = 7, CURRENCY_D2_NEGBRARED = 8, PERCENT = 9, PERCENT_D2 = 10, SCIENTIFIC_D2 = 11, FRACTION_ONEDIG = 12, FRACTION_TWODIG = 13, DATE = 14, CUSTOM_D_MON_YY = 15, CUSTOM_D_MON = 16, CUSTOM_MON_YY = 17, CUSTOM_HMM_AM = 18, CUSTOM_HMMSS_AM = 19, CUSTOM_HMM = 20, CUSTOM_HMMSS = 21, CUSTOM_MDYYYY_HMM = 22, NUMBER_SEP_NEGBRA=37 = 23, NUMBER_SEP_NEGBRARED = 24, NUMBER_D2_SEP_NEGBRA = 25, NUMBER_D2_SEP_NEGBRARED = 26, ACCOUNT = 27, ACCOUNTCUR = 28, ACCOUNT_D2 = 29, ACCOUNT_D2_CUR = 30, CUSTOM_MMSS = 31, CUSTOM_H0MMSS = 32, CUSTOM_MMSS0 = 33, CUSTOM_000P0E_PLUS0 = 34, TEXT = 35}
 * AlignH {GENERAL = 0, LEFT = 1, CENTER = 2, RIGHT = 3, FILL = 4, JUSTIFY = 5, MERGE = 6, DISTRIBUTED = 7}
 * AlignV {TOP = 0, CENTER = 1, BOTTOM = 2, JUSTIFY = 2, DISTRIBUTED = 3}
 * BorderStyle {NONE, THIN, MEDIUM, DASHED, DOTTED, THICK, DOUBLE, HAIR, MEDIUMDASHED, DASHDOT, MEDIUMDASHDOT, DASHDOTDOT, MEDIUMDASHDOTDOT, SLANTDASHDOT}
 * BorderDiagonal {NONE = 0, DOWN = 1, UP = 2, BOTH = 3}
 * FillPattern {NONE, SOLID, GRAY50, GRAY75, GRAY25, HORSTRIPE, VERSTRIPE, REVDIAGSTRIPE, DIAGSTRIPE, DIAGCROSSHATCH, THICKDIAGCROSSHATCH, THINHORSTRIPE, THINVERSTRIPE, THINREVDIAGSTRIPE, THINDIAGSTRIPE, THINHORCROSSHATCH, THINDIAGCROSSHATCH, GRAY12P5, GRAY6P25}
 * Script {NORMAL = 0, SUPER = 1, SUB = 2}
 * Underline {NONE = 0, SINGLE, DOUBLE, SINGLEACC = 0x21, DOUBLEACC = 0x22}
 * Paper {DEFAULT, LETTER, LETTERSMALL, TABLOID, LEDGER, LEGAL, STATEMENT, EXECUTIVE, A3, A4, A4SMALL, A5, B4, B5, FOLIO, QUATRO, 10x14, 10x17, NOTE, ENVELOPE_9, ENVELOPE_10, ENVELOPE_11, ENVELOPE_12, ENVELOPE_14, C_SIZE, D_SIZE, E_SIZE, ENVELOPE_DL, ENVELOPE_C5, ENVELOPE_C3, ENVELOPE_C4, ENVELOPE_C6, ENVELOPE_C65, ENVELOPE_B4, ENVELOPE_B5, ENVELOPE_B6, ENVELOPE, ENVELOPE_MONARCH, US_ENVELOPE, FANFOLD, GERMAN_STD_FANFOLD, GERMAN_LEGAL_FANFOLD, B4_ISO, JAPANESE_POSTCARD, 9x11, 10x11, 15x11, ENVELOPE_INVITE, US_LETTER_EXTRA = 50, US_LEGAL_EXTRA, US_TABLOID_EXTRA, A4_EXTRA, LETTER_TRANSVERSE, A4_TRANSVERSE, LETTER_EXTRA_TRANSVERSE, SUPERA, SUPERB, US_LETTER_PLUS, A4_PLUS, A5_TRANSVERSE, B5_TRANSVERSE, A3_EXTRA, A5_EXTRA, B5_EXTRA, A2, A3_TRANSVERSE, A3_EXTRA_TRANSVERSE, JAPANESE_DOUBLE_POSTCARD, A6, JAPANESE_ENVELOPE_KAKU2, JAPANESE_ENVELOPE_KAKU3, JAPANESE_ENVELOPE_CHOU3, JAPANESE_ENVELOPE_CHOU4, LETTER_ROTATED, A3_ROTATED, A4_ROTATED, A5_ROTATED, B4_ROTATED, B5_ROTATED, JAPANESE_POSTCARD_ROTATED, DOUBLE_JAPANESE_POSTCARD_ROTATED, A6_ROTATED, JAPANESE_ENVELOPE_KAKU2_ROTATED, JAPANESE_ENVELOPE_KAKU3_ROTATED, JAPANESE_ENVELOPE_CHOU3_ROTATED, JAPANESE_ENVELOPE_CHOU4_ROTATED, B6, B6_ROTATED, 12x11, JAPANESE_ENVELOPE_YOU4, JAPANESE_ENVELOPE_YOU4_ROTATED, PRC16K, PRC32K, PRC32K_BIG, PRC_ENVELOPE1, PRC_ENVELOPE2, PRC_ENVELOPE3, PRC_ENVELOPE4, PRC_ENVELOPE5, PRC_ENVELOPE6, PRC_ENVELOPE7, PRC_ENVELOPE8, PRC_ENVELOPE9, PRC_ENVELOPE10, PRC16K_ROTATED, PRC32K_ROTATED, PRC32KBIG_ROTATED, PRC_ENVELOPE1_ROTATED, PRC_ENVELOPE2_ROTATED, PRC_ENVELOPE3_ROTATED, PRC_ENVELOPE4_ROTATED, PRC_ENVELOPE5_ROTATED, PRC_ENVELOPE6_ROTATED, PRC_ENVELOPE7_ROTATED, PRC_ENVELOPE8_ROTATED, PRC_ENVELOPE9_ROTATED, PRC_ENVELOPE10_ROTATED}
 * SheetType {SHEET, CHART, UNKNOWN}
 * CellType {EMPTY, NUMBER, STRING, BOOLEAN, BLANK, ERROR, STRICTDATE}
 * ErrorType {NULL = 0x0, DIV_0 = 0x7, VALUE = 0x0F, REF = 0x17, NAME = 0x1D, NUM = 0x24, NA = 0x2A, NOERROR = 0xFF}
 * PictureType {PNG, JPEG, GIF, WMF, DIB, EMF, PICT, TIFF, ERROR = 0xFF}
 * SheetState {VISIBLE, HIDDEN, VERYHIDDEN}
 * Scope {UNDEFINED = -2, WORKBOOK = -1}
 * Position {MOVE_AND_SIZE, ONLY_MOVE, ABSOLUTE}
 * Operator {EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL, LESS_THAN, LESS_THAN_OR_EQUAL, NOT_EQUAL}
 * Filter {VALUE, TOP10, CUSTOM, DYNAMIC, COLOR, ICON, EXT, NOT_SET}
 * IgnoredError {NO_ERROR = 0, EVAL_ERROR = 1, EMPTY_CELLREF = 2, NUMBER_STORED_AS_TEXT = 4, INCONSIST_RANGE = 8, INCONSIST_FMLA = 16, TWODIG_TEXTYEAR = 32, UNLOCK_FMLA = 64, DATA_VALIDATION = 128}
 * EnhancedProtection {DEFAULT = -1, ALL = 0, OBJECTS = 1, SCENARIOS = 2, FORMAT_CELLS = 4, FORMAT_COLUMNS = 8, FORMAT_ROWS = 16, INSERT_COLUMNS = 32, INSERT_ROWS = 64, INSERT_HYPERLINKS = 128, DELETE_COLUMNS = 256, DELETE_ROWS = 512, SEL_LOCKED_CELLS = 1024, SORT = 2048, AUTOFILTER = 4096, PIVOTTABLES = 8192, SEL_UNLOCKED_CELLS = 16384}
 * DataValidationType {TYPE_NONE, TYPE_WHOLE, TYPE_DECIMAL, TYPE_LIST, TYPE_DATE, TYPE_TIME, TYPE_TEXTLENGTH, TYPE_CUSTOM}
 * DataValidationOperator {OP_BETWEEN, OP_NOTBETWEEN, OP_EQUAL, OP_NOTEQUAL, OP_LESSTHAN, OP_LESSTHANOREQUAL, OP_GREATERTHAN, OP_GREATERTHANOREQUAL}
 * DataValidationErrorStyle {ERRSTYLE_STOP, ERRSTYLE_WARNING, ERRSTYLE_INFORMATION}
 * CalcModeType {MANUAL, AUTO, AUTONOTABLE}
 * CheckedType {CHECKEDTYPE_UNCHECKED, CHECKEDTYPE_CHECKED, CHECKEDTYPE_MIXED}
 * ObjectType {OBJECT_UNKNOWN, OBJECT_BUTTON, OBJECT_CHECKBOX, OBJECT_DROP, OBJECT_GBOX, OBJECT_LABEL, OBJECT_LIST, OBJECT_RADIO, OBJECT_SCROLL, OBJECT_SPIN, OBJECT_EDITBOX, OBJECT_DIALOG}
 * CFormatType {CFORMAT_BEGINWITH, CFORMAT_CONTAINSBLANKS, CFORMAT_CONTAINSERRORS, CFORMAT_CONTAINSTEXT, CFORMAT_DUPLICATEVALUES, CFORMAT_ENDSWITH, CFORMAT_EXPRESSION, CFORMAT_NOTCONTAINSBLANKS, CFORMAT_NOTCONTAINSERRORS, CFORMAT_NOTCONTAINSTEXT, CFORMAT_UNIQUEVALUES}
 * CFormatOperator {CFOPERATOR_LESSTHAN, CFOPERATOR_LESSTHANOREQUAL, CFOPERATOR_EQUAL, CFOPERATOR_NOTEQUAL, CFOPERATOR_GREATERTHANOREQUAL, CFOPERATOR_GREATERTHAN, CFOPERATOR_BETWEEN, CFOPERATOR_NOTBETWEEN, CFOPERATOR_CONTAINSTEXT, CFOPERATOR_NOTCONTAINS, CFOPERATOR_BEGINSWITH, CFOPERATOR_ENDSWITH}
 * CFormatTimePeriod {CFTP_LAST7DAYS, CFTP_LASTMONTH, CFTP_LASTWEEK, CFTP_NEXTMONTH, CFTP_NEXTWEEK, CFTP_THISMONTH, CFTP_THISWEEK, CFTP_TODAY, CFTP_TOMORROW, CFTP_YESTERDAY}
 * CFVOType {CFVO_MIN, CFVO_MAX, CFVO_FORMULA, CFVO_NUMBER, CFVO_PERCENT, CFVO_PERCENTILE}
 * CellStyle {CELLSTYLE_NORMAL, CELLSTYLE_BAD, CELLSTYLE_GOOD, CELLSTYLE_NEUTRAL, CELLSTYLE_CALC, CELLSTYLE_CHECKCELL, CELLSTYLE_EXPLANATORY, CELLSTYLE_INPUT, CELLSTYLE_OUTPUT, CELLSTYLE_HYPERLINK, CELLSTYLE_LINKEDCELL, CELLSTYLE_NOTE, CELLSTYLE_WARNING, CELLSTYLE_TITLE, CELLSTYLE_HEADING1, CELLSTYLE_HEADING2, CELLSTYLE_HEADING3, CELLSTYLE_HEADING4, CELLSTYLE_TOTAL, CELLSTYLE_20ACCENT1, CELLSTYLE_40ACCENT1, CELLSTYLE_60ACCENT1, CELLSTYLE_ACCENT1, CELLSTYLE_20ACCENT2, CELLSTYLE_40ACCENT2, CELLSTYLE_60ACCENT2, CELLSTYLE_ACCENT2, CELLSTYLE_20ACCENT3, CELLSTYLE_40ACCENT3, CELLSTYLE_60ACCENT3, CELLSTYLE_ACCENT3, CELLSTYLE_20ACCENT4, CELLSTYLE_40ACCENT4, CELLSTYLE_60ACCENT4, CELLSTYLE_ACCENT4, CELLSTYLE_20ACCENT5, CELLSTYLE_40ACCENT5, CELLSTYLE_60ACCENT5, CELLSTYLE_ACCENT5, CELLSTYLE_20ACCENT6, CELLSTYLE_40ACCENT6, CELLSTYLE_60ACCENT6, CELLSTYLE_ACCENT6, CELLSTYLE_COMMA, CELLSTYLE_COMMA0, CELLSTYLE_CURRENCY, CELLSTYLE_CURRENCY0, CELLSTYLE_PERCENT}
 ***********************************************************************/

class XL {
	static _ := DllCall('LoadLibrary', 'str', A_LineFile '\..\' (A_PtrSize * 8) 'bit\libxl.dll', 'ptr')
	static Load(path, as_xlsx?) {
		if !FileExist(path)
			throw Error('Excel file does not exist.')
		if IsSet(as_xlsx)
			ext := as_xlsx ? 'xlsx' : 'xls'
		else SplitPath(path, , , &ext)
		handle := ext = 'xlsx' ? DllCall('libxl\xlCreateXMLBook', 'cdecl ptr') : DllCall('libxl\xlCreateBook', 'cdecl ptr')
		book := XL.IBook(handle)
		book.setKey('libxl', 'windows-28232b0208c4ee0369ba6e68abv6v5i3')
		if (book.load(path))
			return book
		throw Error('Failed to load')
	}
	static New(ext := 'xlsx') {
		book := XL.IBook(ext = 'xlsx' ? DllCall('libxl\xlCreateXMLBook', 'cdecl ptr') : DllCall('libxl\xlCreateBook', 'cdecl ptr'))
		book.setKey('libxl', 'windows-28232b0208c4ee0369ba6e68abv6v5i3')
		return book
	}
	class IBase {
		ptr := 0, parent := 0
		__New(handle, parent := 0) => (this.parent := parent, this.ptr := handle)
	}
	class IAutoFilter extends XL.IBase {
		getRef(&rowFirst, &rowLast, &colFirst, &colLast) => DllCall('libxl\xlAutoFilterGetRef', 'ptr', this, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		setRef(rowFirst, rowLast, colFirst, colLast) => DllCall('libxl\xlAutoFilterSetRef', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		column(colId) => XL.IFilterColumn(DllCall('libxl\xlAutoFilterColumn', 'ptr', this, 'int', colId, 'cdecl ptr'))
		columnSize() => DllCall('libxl\xlAutoFilterColumnSize', 'ptr', this, 'cdecl')
		columnByIndex(index) => XL.IFilterColumn(DllCall('libxl\xlAutoFilterColumnByIndex', 'ptr', this, 'int', index, 'cdecl ptr'))
		getSortRange(&rowFirst, &rowLast, &colFirst, &colLast) => DllCall('libxl\xlAutoFilterGetSortRange', 'ptr', this, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		getSort(&columnIndex, &descending) => DllCall('libxl\xlAutoFilterGetSort', 'ptr', this, 'int*', &columnIndex := 0, 'int*', &descending := 0, 'cdecl')
		setSort(columnIndex, descending := false) => DllCall('libxl\xlAutoFilterSetSort', 'ptr', this, 'int', columnIndex, 'int', descending, 'cdecl')
		addSort(columnIndex, descending := false) => DllCall('libxl\xlAutoFilterAddSort', 'ptr', this, 'int', columnIndex, 'int', descending, 'cdecl')
	}
	class IBook extends XL.IBase {
		path := ''
		active => this.getSheet(this.activeSheet())
		__Item[it] {
			get {
				count := this.sheetCount()
				if IsNumber(it) {
					if (it < 0 && it >= count)
						throw Error('Invalid index')
					return this.getSheet(it)
				}
				Loop count
					if (this.getSheetName(A_Index - 1) = it)
						return this.getSheet(A_Index - 1)
				throw Error('table ' it ' does not exist')
			}
		}
		activeSheet() => DllCall('libxl\xlBookActiveSheet', 'ptr', this, 'cdecl')
		addConditionalFormat(customNumFormat) => XL.IConditionalFormat(DllCall('libxl\xlBookAddConditionalFormat', 'ptr', this, 'cdecl ptr'))
		addCustomNumFormat(customNumFormat) => DllCall('libxl\xlBookAddCustomNumFormat', 'ptr', this, 'str', customNumFormat, 'cdecl')
		addFont(initFont := 0) => XL.IFont(DllCall('libxl\xlRichStringAddFont', 'ptr', this, 'ptr', initFont, 'cdecl ptr'))
		addFormat(initFormat := 0) => XL.IFormat(DllCall('libxl\xlBookAddFormat', 'ptr', this, 'ptr', initFormat, 'cdecl ptr'))
		addFormatFromStyle(style) => XL.IFormat(DllCall('libxl\xlBookAddFormatFromStyle', 'ptr', this, 'int', style, 'cdecl ptr'))
		addPicture(filename) => DllCall('libxl\xlBookAddPicture', 'ptr', this, 'str', filename, 'cdecl')
		addPicture2(data, size) => DllCall('libxl\xlBookAddPicture2', 'ptr', this, 'ptr', data, 'uint', size, 'cdecl')
		addPictureAsLink(filename, insert := false) => DllCall('libxl\xlBookAddPictureAsLink', 'ptr', this, 'str', filename, 'int', insert, 'cdecl')
		addRichString() => XL.IRichString(DllCall('libxl\xlBookAddRichString', 'ptr', this, 'cdecl ptr'))
		addSheet(name, initSheet := 0) => XL.ISheet(DllCall('libxl\xlBookAddSheet', 'ptr', this, 'str', name, 'ptr', initSheet, 'cdecl ptr'), this)
		biffVersion() => DllCall('libxl\xlBookBiffVersion', 'ptr', this, 'cdecl')
		calcMode() => DllCall('libxl\xlBookCalcMode', 'ptr', this, 'cdecl')
		colorPack(red, green, blue) => DllCall('libxl\xlBookColorPack', 'ptr', this, 'int', red, 'int', green, 'int', blue, 'cdecl')
		colorUnpack(color, &red, &green, &blue) => DllCall('libxl\xlBookColorUnpack', 'ptr', this, 'int', color, 'int*', &red := 0, 'int*', &green := 0, 'int*', &blue := 0, 'cdecl')
		customNumFormat(fmt) => DllCall('libxl\xlBookCustomNumFormat', 'ptr', this, 'int', fmt, 'cdecl str')
		datePack(year, month, day, hour := 0, min := 0, sec := 0, msec := 0) => DllCall('libxl\xlBookDatePack', 'ptr', this, 'int', year, 'int', month, 'int', day, 'int', hour, 'int', min, 'int', sec, 'int', msec, 'cdecl double')
		dateUnpack(value, &year, &month, &day, &hour := 0, &min := 0, &sec := 0, &msec := 0) => DllCall('libxl\xlBookDateUnpack', 'ptr', this, 'double', value, 'int*', &year := 0, 'int*', &month := 0, 'int*', &day := 0, 'int*', &hour := 0, 'int*', &min := 0, 'int*', &sec := 0, 'int*', &msec := 0, 'cdecl')
		defaultFont(&fontSize) => DllCall('libxl\xlBookDefaultFont', 'ptr', this, 'int*', &fontSize := 0, 'cdecl str')
		delSheet(index) => DllCall('libxl\xlBookDelSheet', 'ptr', this, 'int', index, 'cdecl')
		errorMessage() => DllCall('libxl\xlBookErrorMessage', 'ptr', this, 'cdecl astr')
		font(index) => XL.IFont(DllCall('libxl\xlBookFont', 'ptr', this, 'int', index, 'cdecl ptr'))
		fontSize() => DllCall('libxl\xlBookFontSize', 'ptr', this, 'cdecl')
		format(index) => XL.IFormat(DllCall('libxl\xlBookFormat', 'ptr', this, 'int', index, 'cdecl ptr'))
		formatSize() => DllCall('libxl\xlBookFormatSize', 'ptr', this, 'cdecl')
		getPicture(index, &data, &size) => DllCall('libxl\xlBookGetPicture', 'ptr', this, 'int', index, 'ptr*', &data := 0, 'uint*', &size := 0, 'cdecl')
		getSheet(index) => XL.ISheet(DllCall('libxl\xlBookGetSheet', 'ptr', this, 'int', index, 'cdecl ptr'), this)
		getSheetName(index) => DllCall('libxl\xlBookGetSheetName', 'ptr', this, 'int', index, 'cdecl str')
		insertSheet(index, name, initSheet := 0) => XL.ISheet(DllCall('libxl\xlBookInsertSheet', 'ptr', this, 'int', index, 'str', name, 'ptr', initSheet, 'cdecl ptr'), this)
		isDate1904() => DllCall('libxl\xlBookIsDate1904', 'ptr', this, 'cdecl')
		isTemplate() => DllCall('libxl\xlBookIsTemplate', 'ptr', this, 'cdecl')
		isWriteProtected() => DllCall('libxl\xlBookIsWriteProtected', 'ptr', this, 'cdecl')
		load(filename, tempFile := '') => (this.path := filename, tempFile ? DllCall('libxl\xlBookLoadUsingTempFile', 'ptr', this, 'str', filename, 'str', tempFile, 'cdecl') : DllCall('libxl\xlBookLoad', 'ptr', this, 'str', filename, 'cdecl'))
		loadInfo(filename) => DllCall('libxl\xlBookLoadInfo', 'ptr', this, 'str', filename, 'cdecl')
		loadPartially(filename, sheetIndex, firstRow, lastRow, tempFile := '') => (tempFile ? DllCall('libxl\xlBookLoadPartiallyUsingTempFile', 'ptr', this, 'str', filename, 'int', sheetIndex, 'int', firstRow, 'int', lastRow, 'str', tempFile, 'cdecl') : DllCall('libxl\xlBookLoadPartially', 'ptr', this, 'str', filename, 'int', sheetIndex, 'int', firstRow, 'int', lastRow, 'cdecl'))
		loadRaw(data, size, sheetIndex := -1, firstRow := -1, lastRow := -1) => (sheetIndex = -1 ? DllCall('libxl\xlBookLoadRaw', 'ptr', this, 'ptr', data, 'uint', size, 'cdecl') : DllCall('libxl\xlBookLoadRawPartially', 'ptr', this, 'astr', data, 'uint', size, 'int', sheetIndex, 'int', firstRow, 'int', lastRow, 'cdecl'))
		loadSheet(filename, sheetIndex, tempFile := '') => (this.load(filename, tempFile), this.setActiveSheet(sheetIndex))
		loadWithoutEmptyCells(filename) => DllCall('libxl\xlBookLoadWithoutEmptyCells', 'ptr', this, 'str', filename, 'cdecl')
		moveSheet(srcIndex, dstIndex) => DllCall('libxl\xlBookMoveSheet', 'ptr', this, 'int', srcIndex, 'int', dstIndex, 'cdecl')
		pictureSize() => DllCall('libxl\xlSheetPictureSize', 'ptr', this, 'cdecl')
		refR1C1() => DllCall('libxl\xlBookRefR1C1', 'ptr', this, 'cdecl')
		release() => (this.ptr ? (DllCall('libxl\xlBookRelease', 'ptr', this, 'cdecl'), this.ptr := 0) : 0)
		rgbMode() => DllCall('libxl\xlBookRgbMode', 'ptr', this, 'cdecl')
		save(filename := '', useTempFile := false) {
			filename := filename || this.path
			if !(useTempFile ? DllCall('libxl\xlBookSaveUsingTempFile', 'ptr', this, 'str', filename, 'int', useTempFile, 'cdecl') : DllCall('libxl\xlBookSave', 'ptr', this, 'str', filename, 'cdecl'))
				throw Error(this.errorMessage())
		}
		saveRaw(&data, &size) => DllCall('libxl\xlBookSaveRaw', 'ptr', this, 'ptr*', &data := 0, 'uint*', &size := 0, 'cdecl')
		setActiveSheet(index) => DllCall('libxl\xlBookSetActiveSheet', 'ptr', this, 'int', index, 'cdecl')
		setCalcMode(CalcMode) => DllCall('libxl\xlBookSetCalcMode', 'ptr', this, 'int', calcMode, 'cdecl')
		setDate1904(date1904 := true) => DllCall('libxl\xlBookSetDate1904', 'ptr', this, 'int', date1904, 'cdecl')
		setDefaultFont(fontName, fontSize) => DllCall('libxl\xlBookSetDefaultFont', 'ptr', this, 'str', fontName, 'int', fontSize, 'cdecl')
		setKey(name, key) => DllCall('libxl\xlBookSetKey', 'ptr', this, 'str', name, 'str', key, 'cdecl')
		setLocale(locale) => DllCall('libxl\xlBookSetLocale', 'ptr', this, 'astr', locale, 'cdecl')
		setRefR1C1(refR1C1 := true) => DllCall('libxl\xlBookSetRefR1C1', 'ptr', this, 'int', refR1C1, 'cdecl')
		setRgbMode(rgbMode := true) => DllCall('libxl\xlBookSetRgbMode', 'ptr', this, 'int', rgbMode, 'cdecl')
		setTemplate(tmpl := true) => DllCall('libxl\xlBookSetTemplate', 'ptr', this, 'int', tmpl, 'cdecl')
		sheetCount() => DllCall('libxl\xlBookSheetCount', 'ptr', this, 'cdecl')
		sheetType(index) => DllCall('libxl\xlBookSheetType', 'ptr', this, 'int', index, 'cdecl')
		version() => DllCall('libxl\xlBookVersion', 'ptr', this, 'cdecl')
		__Delete() => this.release()
	}
	class IConditionalFormat extends XL.IBase {
		font() => XL.IFont(DllCall('libxl\xlConditionalFormatFont', 'ptr', this, 'cdecl ptr'))
		numFormat() => DllCall('libxl\xlConditionalFormatNumFormat', 'ptr', this, 'cdecl')
		setNumFormat(numFormat) => DllCall('libxl\xlConditionalFormatSetNumFormat', 'ptr', this, 'int', numFormat, 'cdecl')
		customNumFormat() => DllCall('libxl\xlConditionalFormatCustomNumFormat', 'ptr', this, 'cdecl str')
		setCustomNumFormat(customNumFormat) => DllCall('libxl\xlConditionalFormatSetCustomNumFormat', 'ptr', this, 'str', customNumFormat, 'cdecl')
		setBorder(style := 1) => DllCall('libxl\xlConditionalFormatSetBorder', 'ptr', this, 'int', style, 'cdecl')
		setBorderColor(color) => DllCall('libxl\xlConditionalFormatSetBorderColor', 'ptr', this, 'int', color, 'cdecl')
		borderLeft() => DllCall('libxl\xlConditionalFormatBorderLeft', 'ptr', this, 'cdecl')
		setBorderLeft(style := 1) => DllCall('libxl\xlConditionalFormatSetBorderLeft', 'ptr', this, 'int', style, 'cdecl')
		borderRight() => DllCall('libxl\xlConditionalFormatBorderRight', 'ptr', this, 'cdecl')
		setBorderRight(style := 1) => DllCall('libxl\xlConditionalFormatSetBorderRight', 'ptr', this, 'int', style, 'cdecl')
		borderTop() => DllCall('libxl\xlConditionalFormatBorderTop', 'ptr', this, 'cdecl')
		setBorderTop(style := 1) => DllCall('libxl\xlConditionalFormatSetBorderTop', 'ptr', this, 'int', style, 'cdecl')
		borderBottom() => DllCall('libxl\xlConditionalFormatBorderBottom', 'ptr', this, 'cdecl')
		setBorderBottom(style := 1) => DllCall('libxl\xlConditionalFormatSetBorderBottom', 'ptr', this, 'int', style, 'cdecl')
		borderLeftColor() => DllCall('libxl\xlConditionalFormatBorderLeftColor', 'ptr', this, 'cdecl')
		setBorderLeftColor(color) => DllCall('libxl\xlConditionalFormatSetBorderLeftColor', 'ptr', this, 'int', color, 'cdecl')
		borderRightColor() => DllCall('libxl\xlConditionalFormatBorderRightColor', 'ptr', this, 'cdecl')
		setBorderRightColor(color) => DllCall('libxl\xlConditionalFormatSetBorderRightColor', 'ptr', this, 'int', color, 'cdecl')
		borderTopColor() => DllCall('libxl\xlConditionalFormatBorderTopColor', 'ptr', this, 'cdecl')
		setBorderTopColor(color) => DllCall('libxl\xlConditionalFormatSetBorderTopColor', 'ptr', this, 'int', color, 'cdecl')
		borderBottomColor() => DllCall('libxl\xlConditionalFormatBorderBottomColor', 'ptr', this, 'cdecl')
		setBorderBottomColor(color) => DllCall('libxl\xlConditionalFormatSetBorderBottomColor', 'ptr', this, 'int', color, 'cdecl')
		fillPattern() => DllCall('libxl\xlConditionalFormatFillPattern', 'ptr', this, 'cdecl')
		setFillPattern(pattern) => DllCall('libxl\xlConditionalFormatSetFillPattern', 'ptr', this, 'int', pattern, 'cdecl')
		patternForegroundColor() => DllCall('libxl\xlConditionalFormatPatternForegroundColor', 'ptr', this, 'cdecl')
		setPatternForegroundColor(color) => DllCall('libxl\xlConditionalFormatSetPatternForegroundColor', 'ptr', this, 'int', color, 'cdecl')
		patternBackgroundColor() => DllCall('libxl\xlConditionalFormatPatternBackgroundColor', 'ptr', this, 'cdecl')
		setPatternBackgroundColor(color) => DllCall('libxl\xlConditionalFormatSetPatternBackgroundColor', 'ptr', this, 'int', color, 'cdecl')
	}
	class IConditionalFormatting extends XL.IBase {
		addRange(rowFirst, rowLast, colFirst, colLast) => DllCall('libxl\xlConditionalFormattingAddRange', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		addRule(type, cFormat, value?, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAddRule', 'ptr', this, 'int', type, 'ptr', cFormat, IsSet(value) ? 'str' : 'ptr', value ?? 0, 'char', stopIfTrue, 'cdecl')
		addTopRule(cFormat, value, bottom := false, percent := false, stopIfTrue := 0) => DllCall('libxl\xlConditionalFormattingAddTopRule', 'ptr', this, 'ptr', cFormat, 'int', value, 'char', bottom, 'char', percent, 'char', stopIfTrue, 'cdecl')
		addOpNumRule(op, cFormat, value1, value2 := 0, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAddOpNumRule', 'ptr', this, 'int', op, 'ptr', cFormat, 'double', value1, 'double', value2, 'char', stopIfTrue, 'cdecl')
		addOpStrRule(op, cFormat, value1, value2?, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAddOpStrRule', 'ptr', this, 'int', op, 'ptr', cFormat, 'str', value1, IsSet(value2) ? 'str' : 'ptr', value2 ?? 0, 'char', stopIfTrue, 'cdecl')
		addAboveAverageRule(cFormat, aboveAverage := true, equalAverage := false, stdDev := 0, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAddAboveAverageRule', 'ptr', this, 'ptr', cFormat, 'char', aboveAverage, 'char', equalAverage, 'int', stdDev, 'char', stopIfTrue, 'cdecl')
		addTimePeriodRule(cFormat, timePeriod, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAddTimePeriodRule', 'ptr', this, 'ptr', cFormat, 'int', timePeriod, 'char', stopIfTrue, 'cdecl')
		add2ColorScaleRule(minColor, maxColor, minType := 0, minValue := 0, maxType := 1, maxValue := 0, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAdd2ColorScaleRule', 'ptr', this, 'int', minColor, 'int', maxColor, 'int', minType, 'double', minValue, 'int', maxType, 'double', maxValue, 'char', stopIfTrue, 'cdecl')
		add2ColorScaleFormulaRule(minColor, maxColor, minType := 2, minValue?, maxType := 2, maxValue?, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAdd2ColorScaleFormulaRule', 'ptr', this, 'int', minColor, 'int', maxColor, 'int', minType, IsSet(minValue) ? 'str' : 'ptr', minValue ?? 0, 'int', maxType, IsSet(maxValue) ? 'str' : 'ptr', maxValue ?? 0, 'char', stopIfTrue, 'cdecl')
		add3ColorScaleRule(minColor, midColor, maxColor, minType := 0, minValue := 0, midType := 5, midValue := 50, maxType := 1, maxValue := 0, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAdd3ColorScaleRule', 'ptr', this, 'int', minColor, 'int', midColor, 'int', maxColor, 'int', minType, 'double', minValue, 'int', midType, 'double', midValue, 'int', maxType, 'double', maxValue, 'char', stopIfTrue, 'cdecl')
		add3ColorScaleFormulaRule(minColor, midColor, maxColor, minType := 2, minValue?, midType := 2, midValue?, maxType := 2, maxValue?, stopIfTrue := false) => DllCall('libxl\xlConditionalFormattingAdd3ColorScaleFormulaRule', 'ptr', this, 'int', minColor, 'int', midColor, 'int', maxColor, 'int', minType, IsSet(minValue) ? 'str' : 'ptr', minValue ?? 0, 'int', midType, IsSet(midValue) ? 'str' : 'ptr', midValue ?? 0, 'int', maxType, IsSet(maxValue) ? 'str' : 'ptr', maxValue ?? 0, 'char', stopIfTrue, 'cdecl')
	}
	class IFilterColumn extends XL.IBase {
		index() => DllCall('libxl\xlFilterColumnIndex', 'ptr', this, 'cdecl')
		filterType() => DllCall('libxl\xlFilterColumnFilterType', 'ptr', this, 'cdecl')
		filterSize() => DllCall('libxl\xlFilterColumnFilterSize', 'ptr', this, 'cdecl')
		filter(index) => DllCall('libxl\xlFilterColumnFilter', 'ptr', this, 'int', index, 'cdecl str')
		addFilter(value) => DllCall('libxl\xlFilterColumnAddFilter', 'ptr', this, 'str', value, 'cdecl')
		getTop10(&value, &top, &percent) => DllCall('libxl\xlFilterColumnGetTop10', 'ptr', this, 'double*', &value := 0, 'int*', &top := 0, 'int*', &percent := 0, 'cdecl')
		setTop10(value, top := true, percent := false) => DllCall('libxl\xlFilterColumnSetTop10', 'ptr', this, 'double', value, 'int', top, 'int', percent, 'cdecl')
		getCustomFilter(&op1, &v1, &op2, &v2, &andOp) => DllCall('libxl\xlFilterColumnGetCustomFilter', 'ptr', this, 'int*', &op1 := 0, 'str*', &v1 := '', 'int*', &op2 := 0, 'str*', &v2 := '', 'int*', &andOp := 0, 'cdecl')
		setCustomFilter(op1, v1, op2 := 0, v2 := '', andOp := false) => DllCall('libxl\xlFilterColumnSetCustomFilterEx', 'ptr', this, 'int', op1, 'str', v1, 'int', op2, 'str', v2, 'int', andOp, 'cdecl')
		clear() => DllCall('libxl\xlFilterColumnClear', 'ptr', this, 'cdecl')
	}
	class IFormControl extends XL.IBase {
		objectType() => DllCall('libxl\xlFormControlObjectType', 'ptr', this, 'cdecl')
		checked() => DllCall('libxl\xlFormControlChecked', 'ptr', this, 'cdecl')
		setChecked(checked) => DllCall('libxl\xlFormControlSetChecked', 'ptr', this, 'int', checked, 'cdecl')
		fmlaGroup() => DllCall('libxl\xlFormControlFmlaGroup', 'ptr', this, 'cdecl str')
		setFmlaGroup(group) => DllCall('libxl\xlFormControlSetFmlaGroup', 'ptr', this, 'str', group, 'cdecl')
		fmlaLink() => DllCall('libxl\xlFormControlFmlaLink', 'ptr', this, 'cdecl str')
		setFmlaLink(link) => DllCall('libxl\xlFormControlSetFmlaLink', 'ptr', this, 'str', link, 'cdecl')
		fmlaRange() => DllCall('libxl\xlFormControlFmlaRange', 'ptr', this, 'cdecl str')
		setFmlaRange(range) => DllCall('libxl\xlFormControlSetFmlaRange', 'ptr', this, 'str', range, 'cdecl')
		fmlaTxbx() => DllCall('libxl\xlFormControlFmlaTxbx', 'ptr', this, 'cdecl str')
		setFmlaTxbx(txbx) => DllCall('libxl\xlFormControlSetFmlaTxbx', 'ptr', this, 'str', txbx, 'cdecl')
		name() => DllCall('libxl\xlFormControlName', 'ptr', this, 'cdecl str')
		linkedCell() => DllCall('libxl\xlFormControlLinkedCell', 'ptr', this, 'cdecl str')
		listFillRange() => DllCall('libxl\xlFormControlListFillRange', 'ptr', this, 'cdecl str')
		macro() => DllCall('libxl\xlFormControlMacro', 'ptr', this, 'cdecl str')
		altText() => DllCall('libxl\xlFormControlAltText', 'ptr', this, 'cdecl str')
		locked() => DllCall('libxl\xlFormControlLocked', 'ptr', this, 'cdecl')
		defaultSize() => DllCall('libxl\xlFormControlDefaultSize', 'ptr', this, 'cdecl')
		print() => DllCall('libxl\xlFormControlPrint', 'ptr', this, 'cdecl')
		disabled() => DllCall('libxl\xlFormControlDisabled', 'ptr', this, 'cdecl')
		item(index) => DllCall('libxl\xlFormControlItem', 'ptr', this, 'int', index, 'cdecl str')
		itemSize() => DllCall('libxl\xlFormControlItemSize', 'ptr', this, 'cdecl')
		addItem(value) => DllCall('libxl\xlFormControlAddItem', 'ptr', this, 'str', value, 'cdecl')
		insertItem(index, value) => DllCall('libxl\xlFormControlInsertItem', 'ptr', this, 'int', index, 'str', value, 'cdecl')
		clearItems() => DllCall('libxl\xlFormControlClearItems', 'ptr', this, 'cdecl')
		dropLines() => DllCall('libxl\xlFormControlDropLines', 'ptr', this, 'cdecl')
		setDropLines(lines) => DllCall('libxl\xlFormControlSetDropLines', 'ptr', this, 'int', lines, 'cdecl')
		dx() => DllCall('libxl\xlFormControlDx', 'ptr', this, 'cdecl')
		setDx(dx) => DllCall('libxl\xlFormControlSetDx', 'ptr', this, 'int', dx, 'cdecl')
		firstButton() => DllCall('libxl\xlFormControlFirstButton', 'ptr', this, 'cdecl')
		setFirstButton(firstButton) => DllCall('libxl\xlFormControlSetFirstButton', 'ptr', this, 'int', firstButton, 'cdecl')
		horiz() => DllCall('libxl\xlFormControlHoriz', 'ptr', this, 'cdecl')
		setHoriz(horiz) => DllCall('libxl\xlFormControlSetHoriz', 'ptr', this, 'int', horiz, 'cdecl')
		inc() => DllCall('libxl\xlFormControlInc', 'ptr', this, 'cdecl')
		setInc(inc) => DllCall('libxl\xlFormControlSetInc', 'ptr', this, 'int', inc, 'cdecl')
		getMax() => DllCall('libxl\xlFormControlGetMax', 'ptr', this, 'cdecl')
		setMax(max) => DllCall('libxl\xlFormControlSetMax', 'ptr', this, 'int', max, 'cdecl')
		getMin() => DllCall('libxl\xlFormControlGetMin', 'ptr', this, 'cdecl')
		setMin(min) => DllCall('libxl\xlFormControlSetMin', 'ptr', this, 'int', min, 'cdecl')
		multiSel() => DllCall('libxl\xlFormControlMultiSel', 'ptr', this, 'cdecl str')
		setMultiSel(value) => DllCall('libxl\xlFormControlSetMultiSel', 'ptr', this, 'str', value, 'cdecl')
		sel() => DllCall('libxl\xlFormControlSel', 'ptr', this, 'cdecl')
		setSel(sel) => DllCall('libxl\xlFormControlSetSel', 'ptr', this, 'int', sel, 'cdecl')
		fromAnchor(&col, &colOff, &row, &rowOff) => DllCall('libxl\xlFormControlFromAnchor', 'ptr', this, 'int*', &col := 0, 'int*', &colOff := 0, 'int*', &row := 0, 'int*', &rowOff := 0, 'cdecl')
		toAnchor(&col, &colOff, &row, &rowOff) => DllCall('libxl\xlFormControlToAnchor', 'ptr', this, 'int*', &col := 0, 'int*', &colOff := 0, 'int*', &row := 0, 'int*', &rowOff := 0, 'cdecl')
	}
	class IFont extends XL.IBase {
		size() => DllCall('libxl\xlFontSize', 'ptr', this, 'cdecl')
		setSize(size) => DllCall('libxl\xlFontSetSize', 'ptr', this, 'int', size, 'cdecl')
		italic() => DllCall('libxl\xlFontItalic', 'ptr', this, 'cdecl')
		setItalic(italic := true) => DllCall('libxl\xlFontSetItalic', 'ptr', this, 'int', italic, 'cdecl')
		strikeOut() => DllCall('libxl\xlFontStrikeOut', 'ptr', this, 'cdecl')
		setStrikeOut(strikeOut := true) => DllCall('libxl\xlFontSetStrikeOut', 'ptr', this, 'int', strikeOut, 'cdecl')
		color() => DllCall('libxl\xlFontColor', 'ptr', this, 'cdecl')
		setColor(Color) => DllCall('libxl\xlFontSetColor', 'ptr', this, 'int', color, 'cdecl')
		bold() => DllCall('libxl\xlFontBold', 'ptr', this, 'cdecl')
		setBold(bold) => DllCall('libxl\xlFontSetBold', 'ptr', this, 'int', bold, 'cdecl')
		script() => DllCall('libxl\xlFontScript', 'ptr', this, 'cdecl')
		setScript(Script) => DllCall('libxl\xlFontSetScript', 'ptr', this, 'int', script, 'cdecl')
		underline() => DllCall('libxl\xlFontUnderline', 'ptr', this, 'cdecl')
		setUnderline(Underline) => DllCall('libxl\xlFontSetUnderline', 'ptr', this, 'int', underline, 'cdecl')
		name() => DllCall('libxl\xlFontName', 'ptr', this, 'cdecl str')
		setName(name) => DllCall('libxl\xlFontSetName', 'ptr', this, 'str', name, 'cdecl')
	}
	class IFormat extends XL.IBase {
		font() => XL.IFont(DllCall('libxl\xlFormatFont', 'ptr', this, 'cdecl ptr'))
		setFont(font) => DllCall('libxl\xlFormatSetFont', 'ptr', this, 'ptr', font, 'cdecl')
		numFormat() => DllCall('libxl\xlFormatNumFormat', 'ptr', this, 'cdecl')
		setNumFormat(numFormat) => DllCall('libxl\xlFormatSetNumFormat', 'ptr', this, 'int', numFormat, 'cdecl')
		alignH() => DllCall('libxl\xlFormatAlignH', 'ptr', this, 'cdecl')
		setAlignH(Align) => DllCall('libxl\xlFormatSetAlignH', 'ptr', this, 'int', align, 'cdecl')
		alignV() => DllCall('libxl\xlFormatAlignV', 'ptr', this, 'cdecl')
		setAlignV(Align) => DllCall('libxl\xlFormatSetAlignV', 'ptr', this, 'int', align, 'cdecl')
		wrap() => DllCall('libxl\xlFormatWrap', 'ptr', this, 'cdecl')
		setWrap(wrap := true) => DllCall('libxl\xlFormatSetWrap', 'ptr', this, 'int', wrap, 'cdecl')
		rotation() => DllCall('libxl\xlFormatRotation', 'ptr', this, 'cdecl')
		setRotation(rotation) => DllCall('libxl\xlFormatSetRotation', 'ptr', this, 'int', rotation, 'cdecl')
		indent() => DllCall('libxl\xlFormatIndent', 'ptr', this, 'cdecl')
		setIndent(indent) => DllCall('libxl\xlFormatSetIndent', 'ptr', this, 'int', indent, 'cdecl')
		shrinkToFit() => DllCall('libxl\xlFormatShrinkToFit', 'ptr', this, 'cdecl')
		setShrinkToFit(shrinkToFit := true) => DllCall('libxl\xlFormatSetShrinkToFit', 'ptr', this, 'int', shrinkToFit, 'cdecl')
		setBorder(Style := 1) => DllCall('libxl\xlFormatSetBorder', 'ptr', this, 'int', style, 'cdecl')
		setBorderColor(Color) => DllCall('libxl\xlFormatSetBorderColor', 'ptr', this, 'int', color, 'cdecl')
		borderLeft() => DllCall('libxl\xlFormatBorderLeft', 'ptr', this, 'cdecl')
		setBorderLeft(Style := 1) => DllCall('libxl\xlFormatSetBorderLeft', 'ptr', this, 'int', style, 'cdecl')
		borderRight() => DllCall('libxl\xlFormatBorderRight', 'ptr', this, 'cdecl')
		setBorderRight(style := 1) => DllCall('libxl\xlFormatSetBorderRight', 'ptr', this, 'int', style, 'cdecl')
		borderTop() => DllCall('libxl\xlFormatBorderTop', 'ptr', this, 'cdecl')
		setBorderTop(style := 1) => DllCall('libxl\xlFormatSetBorderTop', 'ptr', this, 'int', style, 'cdecl')
		borderBottom() => DllCall('libxl\xlFormatBorderBottom', 'ptr', this, 'cdecl')
		setBorderBottom(style := 1) => DllCall('libxl\xlFormatSetBorderBottom', 'ptr', this, 'int', style, 'cdecl')
		borderLeftColor() => DllCall('libxl\xlFormatBorderLeftColor', 'ptr', this, 'cdecl')
		setBorderLeftColor(color) => DllCall('libxl\xlFormatSetBorderLeftColor', 'ptr', this, 'int', color, 'cdecl')
		borderRightColor() => DllCall('libxl\xlFormatBorderRightColor', 'ptr', this, 'cdecl')
		setBorderRightColor(color) => DllCall('libxl\xlFormatSetBorderRightColor', 'ptr', this, 'int', color, 'cdecl')
		borderTopColor() => DllCall('libxl\xlFormatBorderTopColor', 'ptr', this, 'cdecl')
		setBorderTopColor(color) => DllCall('libxl\xlFormatSetBorderTopColor', 'ptr', this, 'int', color, 'cdecl')
		borderBottomColor() => DllCall('libxl\xlFormatBorderBottomColor', 'ptr', this, 'cdecl')
		setBorderBottomColor(color) => DllCall('libxl\xlFormatSetBorderBottomColor', 'ptr', this, 'int', color, 'cdecl')
		borderDiagonal() => DllCall('libxl\xlFormatBorderDiagonal', 'ptr', this, 'cdecl')
		setBorderDiagonal(Border) => DllCall('libxl\xlFormatSetBorderDiagonal', 'ptr', this, 'int', border, 'cdecl')
		borderDiagonalStyle() => DllCall('libxl\xlFormatBorderDiagonalStyle', 'ptr', this, 'cdecl')
		setBorderDiagonalStyle(style) => DllCall('libxl\xlFormatSetBorderDiagonalStyle', 'ptr', this, 'int', style, 'cdecl')
		borderDiagonalColor() => DllCall('libxl\xlFormatBorderDiagonalColor', 'ptr', this, 'cdecl')
		setBorderDiagonalColor(color) => DllCall('libxl\xlFormatSetBorderDiagonalColor', 'ptr', this, 'int', color, 'cdecl')
		fillPattern() => DllCall('libxl\xlFormatFillPattern', 'ptr', this, 'cdecl')
		setFillPattern(Pattern) => DllCall('libxl\xlFormatSetFillPattern', 'ptr', this, 'int', pattern, 'cdecl')
		patternForegroundColor() => DllCall('libxl\xlFormatPatternForegroundColor', 'ptr', this, 'cdecl')
		setPatternForegroundColor(color) => DllCall('libxl\xlFormatSetPatternForegroundColor', 'ptr', this, 'int', color, 'cdecl')
		patternBackgroundColor() => DllCall('libxl\xlFormatPatternBackgroundColor', 'ptr', this, 'cdecl')
		setPatternBackgroundColor(color) => DllCall('libxl\xlFormatSetPatternBackgroundColor', 'ptr', this, 'int', color, 'cdecl')
		locked() => DllCall('libxl\xlFormatLocked', 'ptr', this, 'cdecl')
		setLocked(locked := true) => DllCall('libxl\xlFormatSetLocked', 'ptr', this, 'int', locked, 'cdecl')
		hidden() => DllCall('libxl\xlFormatHidden', 'ptr', this, 'cdecl')
		setHidden(hidden := true) => DllCall('libxl\xlFormatSetHidden', 'ptr', this, 'int', hidden, 'cdecl')
	}
	class IRichString extends XL.IBase {
		addFont(initFont := 0) => XL.IFont(DllCall('libxl\xlRichStringAddFont', 'ptr', this, 'ptr', initFont, 'cdecl ptr'))
		addText(text, font := 0) => DllCall('libxl\xlRichStringAddText', 'ptr', this, 'str', text, 'ptr', font, 'cdecl')
		getText(index, &font := 0) => DllCall('libxl\xlRichStringGetText', 'ptr', this, 'int', index, 'ptr*', &font := 0, 'cdecl str')
		textSize() => DllCall('libxl\xlRichStringTextSize', 'ptr', this, 'cdecl')
	}
	class ISheet extends XL.IBase {
		cellType(row, col) => DllCall('libxl\xlSheetCellType', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		isFormula(row, col) => DllCall('libxl\xlSheetIsFormula', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		cellFormat(row, col) => XL.IFormat(DllCall('libxl\xlSheetCellFormat', 'ptr', this, 'int', row, 'int', col, 'cdecl ptr'))
		setCellFormat(row, col, format) => DllCall('libxl\xlSheetSetCellFormat', 'ptr', this, 'int', row, 'int', col, 'ptr', format, 'cdecl')
		readStr(row, col, &format := 0) {
			ret := DllCall('libxl\xlSheetReadStr', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl str')
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeStr(row, col, value, format := 0) => DllCall('libxl\xlSheetWriteStr', 'ptr', this, 'int', row, 'int', col, 'str', value, 'ptr', format, 'cdecl')
		readRichStr(row, col, &format := 0) {
			ret := XL.IRichString(DllCall('libxl\xlSheetReadRichStr', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl ptr'))
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeRichStr(row, col, richString, format := 0) => DllCall('libxl\xlSheetWriteRichStr', 'ptr', this, 'int', row, 'int', col, 'ptr', richString, 'ptr', format, 'cdecl')
		readNum(row, col, &format := 0) {
			ret := DllCall('libxl\xlSheetReadNum', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl double')
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeNum(row, col, value, format := 0) => DllCall('libxl\xlSheetWriteNum', 'ptr', this, 'int', row, 'int', col, 'double', value, 'ptr', format, 'cdecl')
		readBool(row, col, &format := 0) {
			ret := DllCall('libxl\xlSheetReadBool', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl')
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeBool(row, col, value, format := 0) => DllCall('libxl\xlSheetWriteBool', 'ptr', this, 'int', row, 'int', col, 'int', value, 'ptr', format, 'cdecl')
		readBlank(row, col, &format := 0) {
			ret := DllCall('libxl\xlSheetReadBlank', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl')
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeBlank(row, col, format) => DllCall('libxl\xlSheetWriteBlank', 'ptr', this, 'int', row, 'int', col, 'ptr', format, 'cdecl')
		readFormula(row, col, &format := unset) {
			ret := DllCall('libxl\xlSheetReadFormula', 'ptr', this, 'int', row, 'int', col, 'ptr*', &format := 0, 'cdecl str')
			if (!format)
				throw Error(this.parent.errorMessage())
			return (format := XL.IFormat(format), ret)
		}
		writeFormula(row, col, expr, format := 0) => DllCall('libxl\xlSheetWriteFormula', 'ptr', this, 'int', row, 'int', col, 'str', expr, 'ptr', format, 'cdecl')
		writeFormulaNum(row, col, expr, value, format := 0) => DllCall('libxl\xlSheetWriteFormulaNum', 'ptr', this, 'int', row, 'int', col, 'str', expr, 'double', value, 'ptr', format, 'cdecl')
		writeFormulaStr(row, col, expr, value, format := 0) => DllCall('libxl\xlSheetWriteFormulaStr', 'ptr', this, 'int', row, 'int', col, 'str', expr, 'str', value, 'ptr', format, 'cdecl')
		writeFormulaBool(row, col, expr, value, format := 0) => DllCall('libxl\xlSheetWriteFormulaBool', 'ptr', this, 'int', row, 'int', col, 'str', expr, 'int', value, 'ptr', format, 'cdecl')
		readComment(row, col) => DllCall('libxl\xlSheetReadComment', 'ptr', this, 'int', row, 'int', col, 'cdecl str')
		writeComment(row, col, value, author := 0, width := 129, height := 75) => DllCall('libxl\xlSheetWriteComment', 'ptr', this, 'int', row, 'int', col, 'str', value, 'str', author, 'int', width, 'int', height, 'cdecl')
		removeComment(row, col) => DllCall('libxl\xlSheetRemoveComment', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		isDate(row, col) => DllCall('libxl\xlSheetIsDate', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		isRichStr(row, col) => DllCall('libxl\xlSheetIsRichStr', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		readError(row, col) => DllCall('libxl\xlSheetReadError', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		writeError(row, col, ErrorType, format := 0) => DllCall('libxl\xlSheetWriteError', 'ptr', this, 'int', row, 'int', col, 'int', ErrorType, 'ptr', format, 'cdecl')
		colWidth(col) => DllCall('libxl\xlSheetColWidth', 'ptr', this, 'int', col, 'cdecl double')
		rowHeight(row) => DllCall('libxl\xlSheetRowHeight', 'ptr', this, 'int', row, 'cdecl double')
		colWidthPx(col) => DllCall('libxl\xlSheetColWidthPx', 'ptr', this, 'int', col, 'cdecl')
		rowHeightPx(row) => DllCall('libxl\xlSheetRowHeightPx', 'ptr', this, 'int', row, 'cdecl')
		setCol(colFirst, colLast, width, format := 0, hidden := false) => DllCall('libxl\xlSheetSetCol', 'ptr', this, 'int', colFirst, 'int', colLast, 'double', width, 'ptr', format, 'int', hidden, 'cdecl')
		setColPx(colFirst, colLast, widthPx, format := 0, hidden := false) => DllCall('libxl\xlSheetSetColPx', 'ptr', this, 'int', colFirst, 'int', colLast, 'int', widthPx, 'ptr', format, 'int', hidden, 'cdecl')
		setRow(row, height, format := 0, hidden := false) => DllCall('libxl\xlSheetSetRow', 'ptr', this, 'int', row, 'double', height, 'ptr', format, 'int', hidden, 'cdecl')
		setRowPx(row, heightPx, format := 0, hidden := false) => DllCall('libxl\xlSheetSetRowPx', 'ptr', this, 'int', row, 'int', heightPx, 'ptr', format, 'int', hidden, 'cdecl')
		rowHidden(row) => DllCall('libxl\xlSheetRowHidden', 'ptr', this, 'int', row, 'cdecl')
		setRowHidden(row, hidden) => DllCall('libxl\xlSheetSetRowHidden', 'ptr', this, 'int', row, 'int', hidden, 'cdecl')
		colHidden(col) => DllCall('libxl\xlSheetColHidden', 'ptr', this, 'int', col, 'cdecl')
		setColHidden(col, hidden) => DllCall('libxl\xlSheetSetColHidden', 'ptr', this, 'int', col, 'int', hidden, 'cdecl')
		defaultRowHeight() => DllCall('libxl\xlSheetDefaultRowHeight', 'ptr', this, 'cdecl double')
		setDefaultRowHeight(height) => DllCall('libxl\xlSheetSetDefaultRowHeight', 'ptr', this, 'double', height, 'cdecl double')
		getMerge(row, col, &rowFirst := 0, &rowLast := 0, &colFirst := 0, &colLast := 0) => DllCall('libxl\xlSheetGetMerge', 'ptr', this, 'int', row, 'int', col, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		setMerge(rowFirst, rowLast, colFirst, colLast) => DllCall('libxl\xlSheetSetMerge', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		delMerge(row, col) => DllCall('libxl\xlSheetDelMerge', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		mergeSize() => DllCall('libxl\xlSheetMergeSize', 'ptr', this, 'cdecl')
		merge(index, &rowFirst, &rowLast, &colFirst, &colLast) => DllCall('libxl\xlSheetMerge', 'ptr', this, 'int', index, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		delMergeByIndex(index) => DllCall('libxl\xlSheetDelMergeByIndex', 'ptr', this, 'int', index, 'cdecl')
		pictureSize() => DllCall('libxl\xlSheetPictureSize', 'ptr', this, 'cdecl')
		getPicture(index, &rowTop := 0, &colLeft := 0, &rowBottom := 0, &colRight := 0, &width := 0, &height := 0, &offset_x := 0, &offset_y := 0) => DllCall('libxl\xlSheetGetPicture', 'ptr', this, 'int', index, 'int*', &rowTop := 0, 'int*', &colLeft := 0, 'int*', &rowBottom := 0, 'int*', &colRight := 0, 'int*', &width := 0, 'int*', &height := 0, 'int*', &offset_x := 0, 'int*', &offset_y := 0, 'cdecl')
		removePictureByIndex(index) => DllCall('libxl\xlSheetRemovePictureByIndex', 'ptr', this, 'int', index, 'cdecl')
		setPicture(row, col, pictureId, scale := 1.0, offset_x := 0, offset_y := 0, pos := 0) => DllCall('libxl\xlSheetSetPicture', 'ptr', this, 'int', row, 'int', col, 'int', pictureId, 'double', scale, 'int', offset_x, 'int', offset_y, 'int', pos, 'cdecl')
		setPicture2(row, col, pictureId, width := -1, height := -1, offset_x := 0, offset_y := 0, pos := 0) => DllCall('libxl\xlSheetSetPicture2', 'ptr', this, 'int', row, 'int', col, 'int', pictureId, 'int', width, 'int', height, 'int', offset_x, 'int', offset_y, 'int', pos, 'cdecl')
		removePicture(row, col) => DllCall('libxl\xlSheetRemovePicture', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		getHorPageBreak(index) => DllCall('libxl\xlSheetGetHorPageBreak', 'ptr', this, 'int', index, 'cdecl')
		getHorPageBreakSize() => DllCall('libxl\xlSheetGetHorPageBreakSize', 'ptr', this, 'cdecl')
		getVerPageBreak(index) => DllCall('libxl\xlSheetGetVerPageBreak', 'ptr', this, 'int', index, 'cdecl')
		getVerPageBreakSize() => DllCall('libxl\xlSheetGetVerPageBreakSize', 'ptr', this, 'cdecl')
		setHorPageBreak(row, pageBreak := true) => DllCall('libxl\xlSheetSetHorPageBreak', 'ptr', this, 'int', row, 'int', pageBreak, 'cdecl')
		setVerPageBreak(col, pageBreak := true) => DllCall('libxl\xlSheetSetVerPageBreak', 'ptr', this, 'int', col, 'int', pageBreak, 'cdecl')
		split(row, col) => DllCall('libxl\xlSheetSplit', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		splitInfo(&row, &col) => DllCall('libxl\xlSheetSplitInfo', 'ptr', this, 'int*', &row := 0, 'int*', &col := 0, 'cdecl')
		groupRows(rowFirst, rowLast, collapsed := true) => DllCall('libxl\xlSheetGroupRows', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', collapsed, 'cdecl')
		groupCols(colFirst, colLast, collapsed := true) => DllCall('libxl\xlSheetGroupCols', 'ptr', this, 'int', colFirst, 'int', colLast, 'int', collapsed, 'cdecl')
		groupSummaryBelow() => DllCall('libxl\xlSheetGroupSummaryBelow', 'ptr', this, 'cdecl')
		setGroupSummaryBelow(below) => DllCall('libxl\xlSheetSetGroupSummaryBelow', 'ptr', this, 'int', below, 'cdecl')
		groupSummaryRight() => DllCall('libxl\xlSheetGroupSummaryRight', 'ptr', this, 'cdecl')
		setGroupSummaryRight(right) => DllCall('libxl\xlSheetSetGroupSummaryRight', 'ptr', this, 'int', right, 'cdecl')
		clear(rowFirst := 0, rowLast := 1048575, colFirst := 0, colLast := 16383) => DllCall('libxl\xlSheetClear', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		insertCol(colFirst, colLast, updateNamedRanges := true) => DllCall('libxl\xlSheetInsertCol', 'ptr', this, 'int', colFirst, 'int', colLast, 'cdecl')
		insertRow(rowFirst, rowLast, updateNamedRanges := true) => DllCall('libxl\xlSheetInsertRow', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'cdecl')
		removeCol(colFirst, colLast, updateNamedRanges := true) => DllCall('libxl\xlSheetRemoveCol', 'ptr', this, 'int', colFirst, 'int', colLast, 'cdecl')
		removeRow(rowFirst, rowLast, updateNamedRanges := true) => DllCall('libxl\xlSheetRemoveRow', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'cdecl')
		insertColAndKeepRanges(colFirst, colLast) => DllCall('libxl\xlSheetInsertColAndKeepRanges', 'ptr', this, 'int', colFirst, 'int', colLast, 'cdecl')
		insertRowAndKeepRanges(rowFirst, rowLast) => DllCall('libxl\xlSheetInsertRowAndKeepRanges', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'cdecl')
		removeColAndKeepRanges(colFirst, colLast) => DllCall('libxl\xlSheetRemoveColAndKeepRanges', 'ptr', this, 'int', colFirst, 'int', colLast, 'cdecl')
		removeRowAndKeepRanges(rowFirst, rowLast) => DllCall('libxl\xlSheetRemoveRowAndKeepRanges', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'cdecl')
		copyCell(rowSrc, colSrc, rowDst, colDst) => DllCall('libxl\xlSheetCopyCell', 'ptr', this, 'int', rowSrc, 'int', colSrc, 'int', rowDst, 'int', colDst, 'cdecl')
		firstRow() => DllCall('libxl\xlSheetFirstRow', 'ptr', this, 'cdecl')
		lastRow() => DllCall('libxl\xlSheetLastRow', 'ptr', this, 'cdecl')
		firstCol() => DllCall('libxl\xlSheetFirstCol', 'ptr', this, 'cdecl')
		lastCol() => DllCall('libxl\xlSheetLastCol', 'ptr', this, 'cdecl')
		firstFilledRow() => DllCall('libxl\xlSheetFirstFilledRow', 'ptr', this, 'cdecl')
		lastFilledRow() => DllCall('libxl\xlSheetLastFilledRow', 'ptr', this, 'cdecl')
		firstFilledCol() => DllCall('libxl\xlSheetFirstFilledCol', 'ptr', this, 'cdecl')
		lastFilledCol() => DllCall('libxl\xlSheetLastFilledCol', 'ptr', this, 'cdecl')
		displayGridlines() => DllCall('libxl\xlSheetDisplayGridlines', 'ptr', this, 'cdecl')
		setDisplayGridlines(show := true) => DllCall('libxl\xlSheetSetDisplayGridlines', 'ptr', this, 'int', show, 'cdecl')
		printGridlines() => DllCall('libxl\xlSheetPrintGridlines', 'ptr', this, 'cdecl')
		setPrintGridlines(print := true) => DllCall('libxl\xlSheetSetPrintGridlines', 'ptr', this, 'int', print, 'cdecl')
		zoom() => DllCall('libxl\xlSheetZoom', 'ptr', this, 'cdecl')
		setZoom(zoom) => DllCall('libxl\xlSheetSetZoom', 'ptr', this, 'int', zoom, 'cdecl')
		printZoom() => DllCall('libxl\xlSheetPrintZoom', 'ptr', this, 'cdecl')
		setPrintZoom(zoom) => DllCall('libxl\xlSheetSetPrintZoom', 'ptr', this, 'int', zoom, 'cdecl')
		getPrintFit(&wPages, &hPages) => DllCall('libxl\xlSheetGetPrintFit', 'ptr', this, 'int*', &wPages := 0, 'int*', &hPages := 0, 'cdecl')
		setPrintFit(wPages := 1, hPages := 1) => DllCall('libxl\xlSheetSetPrintFit', 'ptr', this, 'int', wPages, 'int', hPages, 'cdecl')
		landscape() => DllCall('libxl\xlSheetLandscape', 'ptr', this, 'cdecl')
		setLandscape(landscape := true) => DllCall('libxl\xlSheetSetLandscape', 'ptr', this, 'int', landscape, 'cdecl')
		paper() => DllCall('libxl\xlSheetPaper', 'ptr', this, 'cdecl')
		setPaper(Paper := 0) => DllCall('libxl\xlSheetSetPaper', 'ptr', this, 'int', paper, 'cdecl')
		header() => DllCall('libxl\xlSheetHeader', 'ptr', this, 'cdecl str')
		setHeader(header, margin := 0.5) => DllCall('libxl\xlSheetSetHeader', 'ptr', this, 'str', header, 'double', margin, 'cdecl')
		headerMargin() => DllCall('libxl\xlSheetHeaderMargin', 'ptr', this, 'cdecl double')
		footer() => DllCall('libxl\xlSheetFooter', 'ptr', this, 'cdecl str')
		setFooter(footer, margin := 0.5) => DllCall('libxl\xlSheetSetFooter', 'ptr', this, 'str', footer, 'double', margin, 'cdecl')
		footerMargin() => DllCall('libxl\xlSheetFooterMargin', 'ptr', this, 'cdecl double')
		hCenter() => DllCall('libxl\xlSheetHCenter', 'ptr', this, 'cdecl')
		setHCenter(hCenter := true) => DllCall('libxl\xlSheetSetHCenter', 'ptr', this, 'int', hCenter, 'cdecl')
		vCenter() => DllCall('libxl\xlSheetVCenter', 'ptr', this, 'cdecl')
		setVCenter(vCenter := true) => DllCall('libxl\xlSheetSetVCenter', 'ptr', this, 'int', vCenter, 'cdecl')
		marginLeft() => DllCall('libxl\xlSheetMarginLeft', 'ptr', this, 'cdecl double')
		setMarginLeft(margin) => DllCall('libxl\xlSheetSetMarginLeft', 'ptr', this, 'double', margin, 'cdecl')
		marginRight() => DllCall('libxl\xlSheetMarginRight', 'ptr', this, 'cdecl double')
		setMarginRight(margin) => DllCall('libxl\xlSheetSetMarginRight', 'ptr', this, 'double', margin, 'cdecl')
		marginTop() => DllCall('libxl\xlSheetMarginTop', 'ptr', this, 'cdecl double')
		setMarginTop(margin) => DllCall('libxl\xlSheetSetMarginTop', 'ptr', this, 'double', margin, 'cdecl')
		marginBottom() => DllCall('libxl\xlSheetMarginBottom', 'ptr', this, 'cdecl double')
		setMarginBottom(margin) => DllCall('libxl\xlSheetSetMarginBottom', 'ptr', this, 'double', margin, 'cdecl')
		printRowCol() => DllCall('libxl\xlSheetPrintRowCol', 'ptr', this, 'cdecl')
		setPrintRowCol(print := true) => DllCall('libxl\xlSheetSetPrintRowCol', 'ptr', this, 'int', print, 'cdecl')
		printRepeatRows(&rowFirst, &rowLast) => DllCall('libxl\xlSheetPrintRepeatRows', 'ptr', this, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'cdecl')
		setPrintRepeatRows(rowFirst, rowLast) => DllCall('libxl\xlSheetSetPrintRepeatRows', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'cdecl')
		printRepeatCols(&colFirst, &colLast) => DllCall('libxl\xlSheetPrintRepeatCols', 'ptr', this, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		setPrintRepeatCols(colFirst, colLast) => DllCall('libxl\xlSheetSetPrintRepeatCols', 'ptr', this, 'int', colFirst, 'int', colLast, 'cdecl')
		printArea(&rowFirst, &rowLast, &colFirst, &colLast) => DllCall('libxl\xlSheetPrintArea', 'ptr', this, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl')
		setPrintArea(rowFirst, rowLast, colFirst, colLast) => DllCall('libxl\xlSheetSetPrintArea', 'ptr', this, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		clearPrintRepeats() => DllCall('libxl\xlSheetClearPrintRepeats', 'ptr', this, 'cdecl')
		clearPrintArea() => DllCall('libxl\xlSheetClearPrintArea', 'ptr', this, 'cdecl')
		getNamedRange(name, &rowFirst, &rowLast, &colFirst, &colLast, scopeId := -2, &hidden := 0) => DllCall('libxl\xlSheetGetNamedRange', 'ptr', this, 'str', name, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'int', scopeId, 'int*', &hidden := 0, 'cdecl')
		setNamedRange(name, rowFirst, rowLast, colFirst, colLast, scopeId := -2, hidden := false) => DllCall('libxl\xlSheetSetNamedRange', 'ptr', this, 'str', name, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'int', scopeId, 'cdecl')
		delNamedRange(name, scopeId := -2) => DllCall('libxl\xlSheetDelNamedRange', 'ptr', this, 'str', name, 'int', scopeId, 'cdecl')
		namedRangeSize() => DllCall('libxl\xlSheetNamedRangeSize', 'ptr', this, 'cdecl')
		namedRange(index, &rowFirst, &rowLast, &colFirst, &colLast, &scopeId := 0, &hidden := 0) => DllCall('libxl\xlSheetNamedRange', 'ptr', this, 'int', index, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'int*', &scopeId := 0, 'int*', &hidden := 0, 'cdecl str')
		getTable(name, &rowFirst, &rowLast, &colFirst, &colLast, &headerRowCount, &totalsRowCount) => DllCall('libxl\xlSheetGetTable', 'ptr', this, 'str', name, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'int*', &headerRowCount := 0, 'int*', &totalsRowCount := 0, 'cdecl str')
		tableSize() => DllCall('libxl\xlSheetTableSize', 'ptr', this, 'cdecl')
		table(index, &rowFirst, &rowLast, &colFirst, &colLast, &headerRowCount, &totalsRowCount) => DllCall('libxl\xlSheetTable', 'ptr', this, 'int', index, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'int*', &headerRowCount := 0, 'int*', &totalsRowCount := 0, 'cdecl str')
		hyperlinkSize() => DllCall('libxl\xlSheetHyperlinkSize', 'ptr', this, 'cdecl')
		hyperlink(index, &rowFirst, &rowLast, &colFirst, &colLast) => DllCall('libxl\xlSheetHyperlink', 'ptr', this, 'int', index, 'int*', &rowFirst := 0, 'int*', &rowLast := 0, 'int*', &colFirst := 0, 'int*', &colLast := 0, 'cdecl str')
		delHyperlink(index) => DllCall('libxl\xlSheetDelHyperlink', 'ptr', this, 'int', index, 'cdecl')
		addHyperlink(hyperlink, rowFirst, rowLast, colFirst, colLast) => DllCall('libxl\xlSheetAddHyperlink', 'ptr', this, 'str', hyperlink, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'cdecl')
		hyperlinkIndex(row, col) => DllCall('libxl\xlSheetHyperlinkIndex', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		isAutoFilter() => DllCall('libxl\xlSheetIsAutoFilter', 'ptr', this, 'cdecl')
		autoFilter() => XL.IAutoFilter(DllCall('libxl\xlSheetAutoFilter', 'ptr', this, 'cdecl ptr'))
		applyFilter() => DllCall('libxl\xlSheetApplyFilter', 'ptr', this, 'cdecl')
		removeFilter() => DllCall('libxl\xlSheetRemoveFilter', 'ptr', this, 'cdecl')
		name() => DllCall('libxl\xlSheetName', 'ptr', this, 'cdecl str')
		setName(name) => DllCall('libxl\xlSheetSetName', 'ptr', this, 'str', name, 'cdecl')
		protect() => DllCall('libxl\xlSheetProtect', 'ptr', this, 'cdecl')
		setProtect(protect := true, password := 0, enhancedProtection := -1) => DllCall('libxl\xlSheetSetProtectEx', 'ptr', this, 'int', protect, 'ptr', Type(password) = 'String' ? StrPtr(password) : password, 'int', enhancedProtection, 'cdecl')
		hidden() => DllCall('libxl\xlSheetHidden', 'ptr', this, 'cdecl')
		setHidden(SheetState := 1) => DllCall('libxl\xlSheetSetHidden', 'ptr', this, 'int', SheetState, 'cdecl')
		getTopLeftView(&row, &col) => DllCall('libxl\xlSheetGetTopLeftView', 'ptr', this, 'int*', &row := 0, 'int*', &col := 0, 'cdecl')
		setTopLeftView(row, col) => DllCall('libxl\xlSheetSetTopLeftView', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		rightToLeft() => DllCall('libxl\xlSheetRightToLeft', 'ptr', this, 'cdecl')
		setRightToLeft(rightToLeft := true) => DllCall('libxl\xlSheetSetRightToLeft', 'ptr', this, 'int', rightToLeft, 'cdecl')
		setAutoFitArea(rowFirst := 0, colFirst := 0, rowLast := -1, colLast := -1) => DllCall('libxl\xlSheetSetAutoFitArea', 'ptr', this, 'int', rowFirst, 'int', colFirst, 'int', rowLast, 'int', colLast, 'cdecl')
		addrToRowCol(addr, &row, &col, &rowRelative := 0, &colRelative := 0) => DllCall('libxl\xlSheetAddrToRowCol', 'ptr', this, 'str', StrUpper(addr), 'int*', &row := 0, 'int*', &col := 0, 'int*', &rowRelative := 0, 'int*', &colRelative := 0, 'cdecl')
		rowColToAddr(row, col, rowRelative := true, colRelative := true) => DllCall('libxl\xlSheetRowColToAddr', 'ptr', this, 'int', row, 'int', col, 'int', rowRelative, 'int', colRelative, 'cdecl str')
		tabColor(Color) => DllCall('libxl\xlSheetTabColor', 'ptr', this, 'cdecl')
		setTabColor(Color) => DllCall('libxl\xlSheetSetTabColor', 'ptr', this, 'int', Color, 'cdecl')
		getTabRGBColor(&red, &green, &blue) => DllCall('libxl\xlSheetGetTabRgbColor', 'ptr', this, 'int*', &red := 0, 'int*', &green := 0, 'int*', &blue := 0, 'cdecl')
		setTabRGBColor(red, green, blue) => DllCall('libxl\xlSheetSetTabRgbColor', 'ptr', this, 'int', red, 'int', green, 'int', blue, 'cdecl')
		addIgnoredError(rowFirst, colFirst, rowLast, colLast, IgnoredError) => DllCall('libxl\xlSheetAddIgnoredError', 'ptr', this, 'int', rowFirst, 'int', colFirst, 'int', rowLast, 'int', colLast, 'int', IgnoredError, 'cdecl')
		addDataValidation(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2) => DllCall('libxl\xlSheetAddDataValidation', 'ptr', this, 'int', type, 'int', op, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'str', value1, 'str', value2, 'cdecl')
		addDataValidationEx(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2, allowBlank := true, hideDropDown := false, showInputMessage := true, showErrorMessage := true, promptTitle := 0, prompt := 0, errorTitle := 0, error := 0, errorStyle := 0) => DllCall('libxl\xlSheetAddDataValidationEx', 'ptr', this, 'int', type, 'int', op, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'str', value1, 'str', value2, 'int', allowBlank, 'int', hideDropDown, 'int', showInputMessage, 'int', showErrorMessage, 'str', promptTitle, 'str', prompt, 'str', errorTitle, 'str', error, 'int', errorStyle, 'cdecl')
		addDataValidationDouble(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2) => DllCall('libxl\xlSheetAddDataValidationDouble', 'ptr', this, 'int', type, 'int', op, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'double', value1, 'double', value2, 'cdecl')
		addDataValidationDoubleEx(type, op, rowFirst, rowLast, colFirst, colLast, value1, value2, allowBlank := true, hideDropDown := false, showInputMessage := true, showErrorMessage := true, promptTitle := 0, prompt := 0, errorTitle := 0, error := 0, errorStyle := 0) => DllCall('libxl\xlSheetAddDataValidationDoubleEx', 'ptr', this, 'int', type, 'int', op, 'int', rowFirst, 'int', rowLast, 'int', colFirst, 'int', colLast, 'double', value1, 'double', value2, 'int', allowBlank, 'int', hideDropDown, 'int', showInputMessage, 'int', showErrorMessage, 'str', promptTitle, 'str', prompt, 'str', errorTitle, 'str', error, 'int', errorStyle, 'cdecl')
		removeDataValidations() => DllCall('libxl\xlSheetRemoveDataValidations', 'ptr', this, 'cdecl')
		formControlSize() => DllCall('libxl\xlSheetFormControlSize', 'ptr', this, 'cdecl')
		formControl(index) => XL.IFormControl(DllCall('libxl\xlSheetFormControl', 'ptr', this, 'int', index, 'cdecl ptr'))
		addConditionalFormatting() => XL.IConditionalFormatting(DllCall('libxl\xlSheetAddConditionalFormatting', 'ptr', this, 'cdecl ptr'))
		getActiveCell(&row, &col) => DllCall('libxl\xlSheetGetActiveCell', 'ptr', this, 'int*', &row := 0, 'int*', &col := 0, 'cdecl')
		setActiveCell(row, col) => DllCall('libxl\xlSheetSetActiveCell', 'ptr', this, 'int', row, 'int', col, 'cdecl')
		selectionRange() => DllCall('libxl\xlSheetSelectionRange', 'ptr', this, 'cdecl str')
		addSelectionRange(sqref) => DllCall('libxl\xlSheetAddSelectionRange', 'ptr', this, 'str', sqref, 'cdecl')
		removeSelection() => DllCall('libxl\xlSheetRemoveSelection', 'ptr', this, 'cdecl')
		__Delete() => (this.parent := '')
		__Item[row, col := ''] {
			get => (IsNumber(row) ? '' : this.addrToRowCol(row, &row, &col), XL.ISheet.ICell(row, col, this))
			set {
				if (ret := format := 0, bool := formula := '', !IsNumber(row))
					this.addrToRowCol(row, &row, &col)
				rechecktype:
				switch Type(value) {
				case 'Object':
					val := value, value := ''
					for k in val.OwnProps()
						switch StrLower(k) {
						case 'format':
							format := val.format
						case 'bool':
							value := val.bool, bool := true
						case 'exp', 'expr', 'formula':
							formula := val.%k%
						case 'int', 'integer':
							value := Integer(val.%k%)
						case 'num', 'float', 'number', 'double':
							value := Float(val.%k%)
						default:
							value := val.%k%
						}
					if (formula != '') {
						if (bool)
							ret := this.writeFormulaBool(row, col, formula, !!value, format)
						else if (value = '')
							ret := this.writeFormula(row, col, formula, format)
						else if ('String' = Type(value))
							ret := this.writeFormulaStr(row, col, formula, value, format)
						else ret := this.writeFormulaNum(row, col, formula, value, format)
					} else if (bool)
						ret := this.writeBool(row, col, !!value, format)
					else goto rechecktype
				case 'String':
					ret := this.writeStr(row, col, value, format)
				case 'Integer', 'Float':
					ret := this.writeNum(row, col, value, format)
				case 'XL.IRichString':
					ret := this.writeRichStr(row, col, value, format)
				default:
					throw Error('Wrong parameter type')
				}
				if (!ret && (msg := this.parent.errorMessage()) != 'ok')
					throw Error(msg)
			}
		}
		class ICell {
			__New(row, col, parent) {
				this.row := row, this.col := col, this.parent := parent
			}
			content {
				get {
					format := 0, ret := {value: '', type: '', format: 0}
					switch this.parent.cellType(row := this.row, col := this.col) {
					case 0:	; EMPTY
						ret.type := 'EMPTY'
						return ret
					case 1:	; NUMBER, DATE
						if (this.parent.isDate(row, col)) {
							year := month := day := hour := min := sec := msec := 0
							value := this.parent.readNum(row, col, &format)
							this.parent.parent.dateUnpack(value, &year, &month, &day, &hour, &min, &sec, &msec)
							ret := {year: year, month: month, day: day, hour: hour, min: min, sec: sec, msec: msec}
							ret.type := 'DATE', ret.value := value
						} else if (this.parent.isFormula(row, col)) {
							ret.formula := this.parent.readFormula(row, col, &format), ret.type := 'FORMULA'
							try ret.value := this.parent.readNum(row, col)
						} else ret.type := 'NUMBER', ret.value := this.parent.readNum(row, col, &format)
						ret.format := format
					case 2:	; STRING, FORMULA, RICHSTRING
						if (this.parent.isRichStr(row, col))
							ret.richstr := this.parent.readRichStr(row, col, &format), ret.type := 'RICHSTRING', ret.value := this.parent.readStr(row, col)
						else if (this.parent.isFormula(row, col)) {
							ret.formula := this.parent.readFormula(row, col, &format), ret.type := 'FORMULA'
							try ret.value := this.parent.readStr(row, col)
						} else ret.type := 'STRING', ret.value := this.parent.readStr(row, col, &format)
						ret.format := format
					case 3:	; BOOLEAN
						ret.value := this.parent.readBool(row, col, &format), ret.format := format, ret.type := 'BOOLEAN'
					case 4:	; BLANK
						this.parent.readBlank(row, col, &format), ret.format := format, ret.type := 'BLANK'
					default: ;ERROR
						ret.type := 'ERROR'
						switch ret.errcode := this.parent.readError(row, col) {
						case 0:
							ret.value := '#NULL!'
						case 0x7:
							ret.value := '#DIV/0!'
						case 0xF:
							ret.value := '#VALUE!'
						case 0x17:
							ret.value := '#REF!'
						case 0x1D:
							ret.value := '#NAME?'
						case 0x24:
							ret.value := '#NUM!'
						case 0x2A:
							ret.value := '#N/A'
						default:
							ret.value := 'no error'
						}
					}
					return ret
				}
			}
			value {
				get => this.content.value
				set => (this.parent[this.row, this.col] := {value: value, format: this.format})
			}
			format {
				get => this.parent.cellFormat(this.row, this.col)
				set => this.parent.setCellFormat(this.row, this.col, value)
			}
			comment {
				get => this.parent.readComment(this.row, this.col)
				set {
					if (value = '')
						return this.parent.removeComment(this.row, this.col)
					author := height := width := ''
					for k in ['author', 'width', 'height', 'value']
						%k% := value.HasOwnProp(k) ? value.%k% : ''
					return this.parent.writeComment(this.row, this.col, value, author, height || 129, width || 75)
				}
			}
			width {
				get => this.parent.colWidth(this.col)
				set => this.parent.setCol(this.col, this.col, value, this.format, this.parent.colHidden(this.col))
			}
			height {
				get => this.parent.rowHeight(this.row)
				set => this.parent.setRow(this.row, this.row, value, this.format, this.parent.rowHidden(this.row))
			}
			hidden => this.parent.rowHidden(this.row) || this.parent.colHidden(this.col)
			copy(rowDst, colDst) => this.parent.copyCell(this.row, this.col, rowDst, colDst)
		}
	}
}
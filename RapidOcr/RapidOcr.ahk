/************************************************************************
 * @description [RapidOcrOnnx](https://github.com/RapidAI/RapidOcrOnnx)基于PaddleOCR和OnnxRuntime, 采用静态库编译, 无其他依赖
 * @author thqby, RapidAI
 * @date 2023/01/12
 * @version 1.0.0
 ***********************************************************************/

class RapidOcr {
	ptr := 0
	/**
	 * @param {Map|Object} config 设置det,rec,cls模型所在路径, keys.txt路径, 线程数. 值格式:
	 * `{ det: det模型路径, rec: rec模型路径, keys: keys.txt路径, cls?: cls模型路径, numThread?: 线程数 }`
	 * 或`{ modelpath: 模型所在文件夹路径, numThread?: 线程数量 }`
	 * @param dllpath RapidOcrOnnx.dll所在路径
	 */
	__New(config?, dllpath?) {
		static init := 0
		if (!init) {
			init := DllCall('LoadLibrary', 'str', dllpath ?? A_LineFile '\..\RapidOcrOnnx.dll', 'ptr')
			if (!init)
				throw OSError()
		}
		if !IsSet(config)
			config := { modelpath: A_LineFile '\..\models' }, !FileExist(config.modelpath) && (config.modelpath := unset)
		det_model := cls_model := rec_model := keys_dict := '', numThread := 8
		for k, v in (config is Map ? config : config.OwnProps()) {
			switch k, false {
				case 'det', 'cls', 'rec': %k%_model := v
				case 'keys', 'dict': keys_dict := v
				case 'det_model', 'cls_model', 'rec_model', 'keys_dict', 'numThread': %k% := v
				case 'modelpath':
					if !(v ~= '[/\\]$')
						v .= '\'
					if !keys_dict {
						loop files v '*.txt'
							if A_LoopFileName ~= 'i)_(keys|dict)[_.]' {
								keys_dict := A_LoopFileFullPath
								break
							}
					}
					loop files v '*.onnx' {
						if RegExMatch(A_LoopFileName, 'i)_(det|cls|rec)[_.]', &m) && !%m[1]%_model
							%m[1]%_model := A_LoopFileFullPath
					} until det_model && cls_model && rec_model
			}
		}
		for k in ['keys_dict', 'det_model', 'cls_model', 'rec_model']
			if !%k% {
				if k != 'cls_model'
					throw ValueError('未指定值错误: ' k)
			} else if !FileExist(%k%)
				throw TargetError('"' k '"文件不存在')
		this.ptr := DllCall('RapidOcrOnnx\OcrInit', 'str', det_model, 'str', cls_model, 'str', rec_model, 'str', keys_dict, 'int', numThread, 'ptr')
	}
	__Delete() => this.ptr && DllCall('RapidOcrOnnx\OcrDestroy', 'ptr', this)

	static __cbobj := { ptr: CallbackCreate((userdata, ptext, presult) => %ObjFromPtrAddRef(userdata)% := StrGet(ptext, 'utf-8')), __Delete: this => CallbackFree(this) }

	; ocr识别opencv4.7.0 Mat对象
	ocr_from_mat(mat, param := 0) => DllCall('RapidOcrOnnx\OcrDetectMat', 'ptr', this, 'ptr', mat, 'ptr', param, 'ptr', RapidOcr.__cbobj, 'ptr', ObjPtr(&res)) ? res : ''

	; ocr识别本地文件
	ocr_from_file(picpath, param := 0) => DllCall('RapidOcrOnnx\OcrDetectFile', 'ptr', this, 'astr', picpath, 'ptr', param, 'ptr', RapidOcr.__cbobj, 'ptr', ObjPtr(&res)) ? res : ''

	; ocr识别图像二进制数据
	ocr_from_binary(data, size, param := 0) => DllCall('RapidOcrOnnx\OcrDetectBinary', 'ptr', this, 'ptr', data, 'uptr', size, 'ptr', param, 'ptr', RapidOcr.__cbobj, 'ptr', ObjPtr(&res)) ? res : ''

	; ocr识别结构体`struct BITMAP_DATA { void *bits; uint pitch; int width, height, bytespixel;};`
	ocr_from_bitmapdata(data, param := 0) => DllCall('RapidOcrOnnx\OcrDetectBitmapData', 'ptr', this, 'ptr', data, 'ptr', param, 'ptr', RapidOcr.__cbobj, 'ptr', ObjPtr(&res)) ? res : ''

	class OcrParam extends Buffer {
		__New(param?) {
			super.__New(42, 0)
			p := NumPut('int', 50, 'int', 1024, 'float', 0.6, 'float', 0.3, 'float', 2.0, this)
			if !IsSet(param)
				return NumPut('int', 1, 'int', 1, p)
			for k, v in (param is Map ? param : param.OwnProps())
				if this.Base.HasOwnProp(k)
					this.%k% := v
		}
		; 图像预处理，在图片外周添加白边，用于提升识别率，文字框没有正确框住所有文字时，增加此值
		padding {
			get => NumGet(this, 0, 'int')
			set => NumPut('int', value, this, 0)
		}
		; 按图片最长边的长度，此值为0代表不缩放，例：1024，如果图片长边大于1024则把图像整体缩小到1024再进行图像分割计算，
		; 如果图片长边小于1024则不缩放，如果图片长边小于32，则缩放到32
		maxSideLen {
			get => NumGet(this, 4, 'int')
			set => NumPut('int', value, this, 4)
		}
		; 文字框置信度门限，文字框没有正确框住所有文字时，减小此值
		boxScoreThresh {
			get => NumGet(this, 8, 'float')
			set => NumPut('float', value, this, 8)
		}
		boxThresh {
			get => NumGet(this, 12, 'float')
			set => NumPut('float', value, this, 12)
		}
		; 单个文字框大小倍率，越大时单个文字框越大。此项与图片的大小相关，越大的图片此值应该越大
		unClipRatio {
			get => NumGet(this, 16, 'float')
			set => NumPut('float', value, this, 16)
		}
		; 启用(1)/禁用(0) 文字方向检测，只有图片倒置的情况下(旋转90~270度的图片)，才需要启用文字方向检测
		doAngle {
			get => NumGet(this, 20, 'int')
			set => NumPut('int', value, this, 20)
		}
		; 启用(1)/禁用(0) 角度投票(整张图片以最大可能文字方向来识别)，当禁用文字方向检测时，此项也不起作用
		mostAngle {
			get => NumGet(this, 24, 'int')
			set => NumPut('int', value, this, 24)
		}
		; 输出标记框后的图像路径
		outputPath {
			get => StrGet(NumGet(this, 24 + A_PtrSize, 'ptr') || StrPtr(''), 'cp0')
			set => (StrPut(Value, this.__outputbuf := Buffer(StrPut(Value, 'cp0')), 'cp0'), NumPut('ptr', this.__outputbuf.Ptr, this, 24 + A_PtrSize))
		}
	}
}

; if A_LineFile == A_ScriptFullPath {
; 	param := RapidOcr.OcrParam()
; 	param.doAngle := false
; 	; param.maxSideLen := 300
; 	ocr := RapidOcr({ modelpath: A_ScriptDir '\models' })
; 	t := A_TickCount
; 	MsgBox ocr.ocr_from_file('1.jpg', param) '`n' (A_TickCount - t)
; }
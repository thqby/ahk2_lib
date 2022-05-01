/************************************************************************
 * @description PaddleOCR v2.1
 * @author thqby
 * @date 2022/05/02
 * @version 1.0.0
 ***********************************************************************/

class ppocr {
	ptr := 0
	__New(config := '', dllpath := '') {
		static init := 0
		if (!init) {
			if (!dllpath)
				DllCall('SetDllDirectory', 'str', A_LineFile '\..')
			init := DllCall('LoadLibrary', 'str', dllpath || 'ppocr.dll', 'ptr')
			if (!init)
				throw Error('load ppocr fail')
		}
		if (!this.ptr := DllCall('ppocr\ocr_create', 'astr', config || Format('
			(
				enable_mkldnn 1
				det_model_dir  "{1:}/inference/ch_PP-OCRv2_det_infer/" # 检测模型inference model地址
				
				# cls config
				use_angle_cls 0 # 是否使用方向分类器，0表示不使用，1表示使用
				cls_model_dir  "{1:}/inference/ch_ppocr_mobile_v2.0_cls_infer/" # 方向分类器inference model地址
				cls_thresh  0.9 # 方向分类器的得分阈值
				
				# rec config
				rec_model_dir  "{1:}/inference/ch_PP-OCRv2_rec_infer/" # 识别模型inference model地址
				char_list_file "{1:}/ppocr_keys_v1.txt"
			)', RegExReplace(A_LineFile, '[/\\][^/\\]*$')), 'ptr'))
			throw Error('load config fail`n' config)
	}
	__Delete() => DllCall('ppocr\ocr_destroy', 'ptr', this)

	/**
	 * ocr识别opencv Mat对象
	 * @param mat opencv Mat
	 * @param userdata 用户数据指针, 无callback时, 传递`Array`或`VarRef`对象
	 * @param callback 回调函数, void (callback)(const wchar_t* words, cv::Point[4] location, float score, void* userdata)
	 */
	ocr_from_mat(mat, userdata, callback := 0) => DllCall('ppocr\ocr_from_mat', 'ptr', this, 'ptr', mat, 'ptr', callback, 'ptr', userdata is Integer ? userdata : ObjPtr(userdata))

	; ocr识别本地文件
	ocr_from_file(picpath, userdata, callback := 0) => DllCall('ppocr\ocr_from_file', 'ptr', this, 'astr', picpath, 'ptr', callback, 'ptr', userdata is Integer ? userdata : ObjPtr(userdata))

	; ocr识别图像二进制数据
	ocr_from_binary(data, size, userdata, callback := 0) => DllCall('ppocr\ocr_from_binary', 'ptr', this, 'ptr', data, 'uint', size, 'ptr', callback, 'ptr', userdata is Integer ? userdata : ObjPtr(userdata))
}
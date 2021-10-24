class ppocr {
	__New(config := '', dllpath := '') {
		static init := 0
		if (!init) {
			if (!dllpath)
				DllCall('SetDllDirectory', 'str', A_LineFile '\..')
			init := DllCall('LoadLibrary', 'str', dllpath || 'ppocr.dll', 'ptr')
			if (!init)
				throw Error('load ppocr fail')
		}
		if (!DllCall('ppocr\load_config', 'astr', config || Format('
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
			)', RegExReplace(A_LineFile, '[/\\][^/\\]*$'))))
			throw Error('load config fail`n' config)
	}
	__Delete() => DllCall('ppocr\destroy')

	; ocr本地文件，allinfo 为 TRUE 时，返回JSON格式，包含识别结果、置信度、位置信息
	ocr_from_file(picpath, allinfo := false) => DllCall('ppocr\ocr_from_file', 'astr', picpath, 'int', allinfo, 'wstr')
	ocr_from_binary(data, size, allinfo := false) => DllCall('ppocr\ocr_from_binary', 'ptr', data, 'uint', size, 'int', allinfo, 'wstr')
}
/************************************************************************
 * @description Yolo, High performance detector. compiled by https://github.com/DefTruth/lite.ai.toolkit/blob/main/lite/ort/cv
 * @author thqby, DefTruth
 * @date 2022/6/5
 * @version 1.1.0
 * @dependencies cpu: onnxRuntime 1.11.0, opencv 4.5.5; gpu: cuda 11.4, cudnn 8.2.26; tensorrt: tensorrt 
 * - [Microsoft.ML.OnnxRuntime.Gpu 1.11.0](https://globalcdn.nuget.org/packages/microsoft.ml.onnxruntime.gpu.1.11.0.nupkg)
 * - [opencv 455](https://nchc.dl.sourceforge.net/project/opencvlibrary/4.5.5/opencv-4.5.5-vc14_vc15.exe)
 * - [cuda 11.4](https://developer.download.nvidia.cn/compute/cuda/11.4.2/local_installers/cuda_11.4.2_471.41_win10.exe)
 * - [cudnn 8.2.2.26](https://developer.nvidia.com/rdp/cudnn-archive)
 * - [tensorrt](https://developer.nvidia.com/nvidia-tensorrt-8x-download)
 ***********************************************************************/
class Yolo {
	static hModule := 0
	static init(dll_path := '') {
		if (!this.hModule && !(this.hModule := DllCall('LoadLibraryEx', 'str', (dll_path || A_LineFile '\..') '\yolo', 'ptr', 0, 'uint', 8, 'ptr')))
			throw Error('load Yolo fail', -1)
	}

	/**
	 * create a Yolo instance
	 * @param tp 4(yolov4) 5(yolov5) x(yolox)
	 * @param onnx_path onnx Model path
	 * @param fp16 Whether to turn on semi-precision reasoning when tensorrt reasoning
	 * @param num_threads Number of threads in cpu reasoning
	 * @param inferencemode 0 is cpu reasoning, 1 is cuda reasoning, 2 is tensorrt reasoning
	 * @param device_id Gpu numbering in cuda and tensorrt reasoning
	 */
	__New(tp, onnx_path, labels := '', num_threads := 4, inferencemode := 0, device_id := 0, fp16 := 1) {
		if !Yolo.hModule
			Yolo.init()
		if (!this.ptr := DllCall('yolo\yolo_create', 'char', Ord(tp), 'astr', onnx_path, 'astr', labels, 'uint', num_threads, 'int', device_id, 'int', fp16, 'int', inferencemode, 'cdecl ptr'))
			throw Error('create Yolo fail')
	}

	/**
	 * run Yolo reasoning, and receive result array.
	 * @param data binary or file or bmp info
	 * - `Picture binary data` of a picture when size_flag = binary size
	 * - `Picture file path` when size_flag = 0
	 * - `wincapture.BitmapBuffer` when size = -1
	 * - `cv::Mat*` when size = -2
	 * @param size_flag Picture binary size or flag, See the above
	 * @param score_threshold score threshold
	 * @param iou_threshold Intersection over Union threshold
	 * @param topk max detect boxes size
	 * @param nms_type non maximum suppression type, HARD = 0, BLEND = 1, OFFSET = 2
	 * @param output_path draw detect boxes and output picture file when output_path is path.
	 * Draw the raw data of the picture when output_path = 1 and data is `wincapture.BitmapBuffer`.
	 */
	detect(data, size_flag := 0, score_threshold := 0.25, iou_threshold := 0.45, topk := 100, nms_type := 2, preview := '', output_path := '') {
		static params := Buffer(32), obj := {boxs: [], preview: 0}, callback := CallbackCreate(receive)
		NumPut('float', score_threshold, 'float', iou_threshold, 'uint', topk, 'uint', nms_type, 'ptr', preview ? StrPtr(preview) : 0, 'ptr', output_path ? StrPtr(output_path) : 0, params)
		if !size_flag && data is String
			if FileExist(data)
				data := StrPtr(t := data)
			else
				throw Error('Invalid picture path')
		if (rt := DllCall('yolo\yolo_detect', 'ptr', this, 'ptr', data, 'int', size_flag, 'ptr', params, 'ptr', callback, 'cdecl int')) < 0
			throw Error('Invalid picture')
		res := obj.boxs, obj.boxs := []
		return res

		receive(data, len) {
			static empty := '', p := StrPtr(empty)
			boxs := obj.boxs
			loop len
				boxs.Push({
					x1: NumGet(data, 'float'),
					y1: NumGet(data, 4, 'float'),
					x2: NumGet(data, 8, 'float'),
					y2: NumGet(data, 12, 'float'),
					score: NumGet(data, 16, 'float'),
					label_text: StrGet(NumGet(data, 24, 'ptr') || p, 'cp0'),
					label: NumGet(data, 32, 'uint'),
					flag: NumGet(data, 36, 'char')
				}), data += 40
		}
	}
	__Delete() {
		if this.HasOwnProp('ptr')
			DllCall('yolo\yolo_destroy', 'ptr', this)
	}
}
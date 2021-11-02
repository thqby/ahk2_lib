/************************************************************************
 * @description YoloX, High performance detector. compiled by https://github.com/DefTruth/lite.ai.toolkit/blob/main/lite/ort/cv/yolox.cpp
 * @author thqby, DefTruth
 * @date 2021/11/02
 * @version 1.0.9
 * @dependencies cpu: onnxRuntime 1.9.0, opencv 4.5.2; gpu: cuda 11.4, cudnn 8.2.26; tensorrt: tensorrt 
 * - [Microsoft.ML.OnnxRuntime.Gpu 1.9.0](https://globalcdn.nuget.org/packages/microsoft.ml.onnxruntime.gpu.1.9.0.nupkg)
 * - [opencv 452](https://nchc.dl.sourceforge.net/project/opencvlibrary/4.5.2/opencv-4.5.2-vc14_vc15.exe)
 * - [cuda 11.4](https://developer.download.nvidia.cn/compute/cuda/11.4.2/local_installers/cuda_11.4.2_471.41_win10.exe)
 * - [cudnn 8.2.2.26](https://developer.nvidia.com/rdp/cudnn-archive)
 * - [tensorrt ?](https://developer.nvidia.com/nvidia-tensorrt-8x-download)	Haven't test
 ***********************************************************************/
class YoloX {
	static hModule := 0
	static init(dll_path := '') {
		if (!this.hModule && !(this.hModule := DllCall('LoadLibraryEx', 'str', (dll_path || A_LineFile '\..') '\YoloX', 'ptr', 0, 'uint', 8, 'ptr')))
			throw Error('load YoloX fail', -1)
	}

	/**
	 * create a YoloX instance
	 * @param onnx_path onnx Model path
	 * @param fp16 Whether to turn on semi-precision reasoning when tensorrt reasoning
	 * @param num_threads Number of threads in cpu reasoning
	 * @param inferencemode 0 is cpu reasoning, 1 is cuda reasoning, 2 is tensorrt reasoning
	 * @param device_id Gpu numbering in cuda and tensorrt reasoning
	 */
	__New(onnx_path, fp16 := 1, num_threads := 4, inferencemode := 0, device_id := 0) {
		if !YoloX.hModule
			YoloX.init()
		if (!this.ptr := DllCall('YoloX\create', 'wstr', onnx_path, 'int', fp16, 'uint', num_threads, 'int', inferencemode, 'int', device_id, 'ptr'))
			throw Error('create YoloX fail')
	}

	; load mark labels, One label per line, utf-16 string, such as `a\nb\nc\nd`
	load_labels(str) {
		return DllCall('Yolox\load_labels', 'ptr', this, 'wstr', str, 'int64')
	}

	/**
	 * run YoloX reasoning, and receive result array.
	 * @param data binary or file or bmp info
	 * - `Picture binary data` of a picture when size_flag = binary size
	 * - `Picture file path` when size_flag = 0
	 * - `YoloX.ImageData` when size = -1
	 * - `HBITMAP` when size_flag = -2
	 * - `Gdip Bitmap` when size_flag = -3
	 * - `IStream*` when size_flag = -4
	 * @param size_flag Picture binary size or flag, See the above
	 * @param score_threshold score threshold
	 * @param iou_threshold Intersection over Union threshold
	 * @param topk max detect boxes size
	 * @param nms_type non maximum suppression type, HARD = 0, BLEND = 1, OFFSET = 2
	 * @param output_path draw detect boxes and output picture file
	 */
	detect(data, size_flag := 0, score_threshold := 0.25, iou_threshold := 0.45, topk := 100, nms_type := 2, output_path := '') {
		static params := Buffer(24), boxs := [], callback := CallbackCreate(receive)
		NumPut('float', score_threshold, 'float', iou_threshold, 'uint', topk, 'uint', nms_type, 'ptr', output_path ? StrPtr(output_path) : 0, params)
		if data is YoloX.ImageData
			size_flag := -1
		else if !size_flag && data is String
			if FileExist(data)
				data := StrPtr(t := data)
			else
				throw Error('Invalid picture path')
		if DllCall('YoloX\detect', 'ptr', this, 'ptr', data, 'int', size_flag, 'ptr', params, 'ptr', callback, 'int') < 0
			throw Error('Invalid picture')
		res := boxs, boxs := []
		return res

		receive(data, len) {
			static empty := '', p := StrPtr(empty)
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
			DllCall('YoloX\release', 'ptr', this)
	}

	class ImageData extends Buffer {
		/**
		 * create `ImageData` struct.
		 * @param imageData bitmap pixel data, maybe from `Gdiplus::Bitmap::LockBits`, etc.
		 * @param width image width in pixels.
		 * @param height image height in pixels.
		 * @param widthStep size of aligned image row in bytes.
		 * @param nChannels RGBA 4, RGB 3, 2, GRAY 1
		 */
		__New(imageData, width, height, widthStep, nChannels := 4) {
			super.__New(24)
			NumPut('ptr', imageData, 'int', nChannels, 'int', width, 'int', height, 'int', widthStep, this)
		}
	}
}
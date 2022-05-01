## ppocr
百度飞桨OCR dll封装，[源码链接](https://github.com/PaddlePaddle/PaddleOCR)

ppocr导出函数
```cpp
// 释放加载的模型
void ocr_destroy(void* ocr);

// 读取配置字符串，根据配置文件加载模型，配置文件ansi编码
void* ocr_create(const char* config);

// ocr opencv Mat对象
void ocr_from_mat(void* ocr, cv::Mat* mat, void (callback)(const wchar_t*, cv::Point[4], float, void*), void* userdata = nullptr);

// ocr识别本地文件
void ocr_from_file(void* ocr, const char* path, void (callback)(const wchar_t*, cv::Point[4], float, void*), void* userdata = nullptr);

// ocr识别图像二进制数据
void ocr_from_binary(void* ocr, const char* data, UINT size, void (callback)(const wchar_t*, cv::Point[4], float, void*), void* userdata = nullptr);
```

```autohotkey2
pp := ppocr(), pic := '1.png'
pp.ocr_from_file(pic, &text)
pp.ocr_from_file(pic, arr := [])
arr2 := [], arr2.words := ''
pp.ocr_from_file(pic, arr2)
pcb := CallbackCreate(callback)
pp.ocr_from_file(pic, ObjPtr(arr3 := []), pcb)

callback(pstr, plocation, score, userdata) {
	arr := ObjFromPtrAddRef(userdata)
	t := [], p := plocation
	loop 4
		t.Push([NumGet(p, 'int'), NumGet(p, 4, 'int')]), p += 8
	arr.Push([StrGet(pstr), t, score])
}
```

更多参数如下：

- 通用参数

|参数名称|类型|默认参数|意义|
| --- | --- | --- | --- |
|cpu_math_library_num_threads|int|10|CPU预测时的线程数，在机器核数充足的情况下，该值越大，预测速度越快|
|use_mkldnn|bool|true|是否使用mkldnn库|

- 检测模型相关

|参数名称|类型|默认参数|意义|
| --- | --- | --- | --- |
|det_model_dir|string|-|检测模型inference model地址|
|max_side_len|int|960|输入图像长宽大于960时，等比例缩放图像，使得图像最长边为960|
|det_db_thresh|float|0.3|用于过滤DB预测的二值化图像，设置为0.-0.3对结果影响不明显|
|det_db_box_thresh|float|0.5|DB后处理过滤box的阈值，如果检测存在漏框情况，可酌情减小|
|det_db_unclip_ratio|float|1.6|表示文本框的紧致程度，越小则文本框更靠近文本|
|use_polygon_score|bool|false|是否使用多边形框计算bbox score，false表示使用矩形框计算。矩形框计算速度更快，多边形框对弯曲文本区域计算更准确。|
|visualize|bool|true|是否对结果进行可视化，为1时，会在当前文件夹下保存文件名为`ocr_vis.png`的预测结果。|

- 方向分类器相关

|参数名称|类型|默认参数|意义|
| --- | --- | --- | --- |
|use_angle_cls|bool|false|是否使用方向分类器|
|cls_model_dir|string|-|方向分类器inference model地址|
|cls_thresh|float|0.9|方向分类器的得分阈值|

- 识别模型相关

|参数名称|类型|默认参数|意义|
| --- | --- | --- | --- |
|rec_model_dir|string|-|识别模型inference model地址|
|char_list_file|string|../../ppocr/utils/ppocr_keys_v1.txt|字典文件|

**注意**
- 需要以下dll文件: 
    [paddle预测库](https://paddle-inference-lib.bj.bcebos.com/2.2.1/cxx_c/Windows/CPU/x86-64_vs2017_avx_mkl/paddle_inference.zip)
    [opencv_world455](https://sourceforge.net/projects/opencvlibrary/files/4.5.5/opencv-4.5.5-vc14_vc15.exe/download)
- 需要识别模型:
    [OCR模型列表](https://gitee.com/paddlepaddle/PaddleOCR/blob/release/2.1/doc/doc_ch/models_list.md)

    推荐模型 [检测模型](https://paddleocr.bj.bcebos.com/PP-OCRv2/chinese/ch_PP-OCRv2_det_infer.tar) [识别模型](https://paddleocr.bj.bcebos.com/PP-OCRv2/chinese/ch_PP-OCRv2_rec_infer.tar) [字典](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.1/ppocr/utils/ppocr_keys_v1.txt)
## YOLOX
YOLOX is an anchor-free version of YOLO, with a simpler design but better performance! It aims to bridge the gap between research and industrial communities.

[repository](https://github.com/Megvii-BaseDetection/YOLOX)
[yolox c++ source](https://github.com/DefTruth/lite.ai.toolkit/blob/main/lite/ort/cv/yolox.cpp)

#### example
```
#Include <YoloX\yolox>

; YoloX.init(A_ScriptDir)
DllCall('LoadLibrary', 'str', A_ScriptDir '\onnxruntime')
yy := YoloX('yolox.onnx')
yy.load_labels('1`n2`n3`n4`n5')

arr := yy.detect('Picture.png')
; FileAppend JSON.stringify(l2, 2), '*', 'utf-8'
```
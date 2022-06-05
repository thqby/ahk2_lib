## YOLOX
YOLOX is an anchor-free version of YOLO, with a simpler design but better performance! It aims to bridge the gap between research and industrial communities.

[repository](https://github.com/Megvii-BaseDetection/YOLOX)
[yolo c++ source](https://github.com/DefTruth/lite.ai.toolkit/blob/main/lite/ort/cv)

#### example
```
#Include <Yolo\yolo>
#Include <wincapture\wincapture>

dx := wincapture.DXGI()
DllCall('LoadLibrary', 'str', A_ScriptDir '\onnxruntime')
Yolo.init(A_ScriptDir)
; yy := Yolo('5', 'yolov5.onnx')
yy := Yolo('x', 'yolox.onnx', '1`n2`n3`n4`n5')

tu := BitmapBuffer.loadPicture('car.jpg')
; tu := DXGI.captureAndSave()
r := yy.detect(tu.info,-1,,,,, 'dst')

; ; bin
; bin := FileRead('Picture.png', 'raw')
; r := yy.detect(bin,bin.Size)
; r := yy.detect('Picture.png',0,,,,,,  'out.png')

```
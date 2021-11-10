## YOLOX
YOLOX is an anchor-free version of YOLO, with a simpler design but better performance! It aims to bridge the gap between research and industrial communities.

[repository](https://github.com/Megvii-BaseDetection/YOLOX)
[yolox c++ source](https://github.com/DefTruth/lite.ai.toolkit/blob/main/lite/ort/cv/yolox.cpp)

#### example
```
#Include <YoloX\yolox>

; YoloX.init(A_ScriptDir)
DllCall('LoadLibrary', 'str', A_ScriptDir '\onnxruntime')
YoloX.init(A_ScriptDir)
yy := YoloX('yolox.onnx')
yy.load_labels('1`n2`n3`n4`n5')

; #DllLoad gdiplus.dll
; #Include <CGdip>
; CGdip.Startup()
; pbitmap := CGdip.Bitmap.FromFile('Picture.png')

; ; gdip bitmap
; arr := yy.detect(pbitmap,-3,,,,, 'out (1).png')

; CGdip.GetImageDimensions(pbitmap, &w, &h)
; pbitmap.LockBits(0, 0, w, h, &stride, &scan0, &bmpdata)

; ; imagedata
; arr := yy.detect(YoloX.ImageData(scan0, w, h, stride, 4),-1,,,,, 'out (2).png')

; pbitmap.UnlockBits(bmpdata)

; stream := pbitmap.Save('.jpg', 100)
; arr := yy.detect(stream, -4,,,,, 'out (3).png')

; pbitmap := 0, CGdip.Shutdown()

; ; hbitmap
; hbm := LoadPicture('Picture.png')
; arr := yy.detect(hbm,-2,,,,, 'out (2).png')

; ; bin
; bin := FileRead('Picture.png', 'raw')
; arr := yy.detect(bin,bin.Size,,,,, 'out (3).png')

yy.preview := (mat) => YoloX.showImage('pic', mat)

; file
arr := yy.detect('Picture.png',,,,,, 1)
MsgBox

; output array
FileAppend JSON.stringify(arr, 2), '*', 'utf-8'

```
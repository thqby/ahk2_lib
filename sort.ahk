class Sort
{
	__New(compare:=""){
		if (!Array.Prototype.HasOwnMethod("swap"))
			Array.Prototype.DefineMethod("swap", (self, i, j)=>(t:=self[i], self[i]:=self[j], self[j]:=t))
		if Type(compare)="Func"
			this.DefineMethod("compare", compare)
	}

	bubbleSort(arr){
		this._bubbleSort(arr, 1, arr.Length)
	}

	insertSort(arr){
		this._insertSort(arr, 1, arr.Length)
	}

	QSort(arr){
		_sort(arr, 1, arr.Length)

		_sort(arr, l, h){
			if (n:=h-l+1, n<=20)
				return this._insertSort(arr, l, h)
			else if (n<=40)
				arr.swap(median3(arr, l, l+(n>>1), h), l)
			else
				eps:=n>>3, mid:=l+n>>1, arr.swap(median3(arr, median3(arr, l, l+eps, l+eps+eps),
					median3(arr, mid-eps, mid, mid+eps), median3(arr, h-eps-eps, h-eps, h)), l)
			p:=i:=l, q:=j:=h+1, v:=arr[l]
			while (true){
				while (this.compare(arr[++i], v)>0&&i<h)
					continue
				while (this.compare(v, arr[--j])>0&&j>l)
					continue
				if (i=j&&this.compare(arr[i], v)=0)
					arr.swap(++p, i)
				if (i>=j)
					break
				arr.swap(i, j)
				if (this.compare(arr[i], v)=0)
					arr.swap(++p, i)
				if (this.compare(arr[j], v)=0)
					arr.swap(--q, j)
			}

			i:=j+1, k:=l
			while (k<=p)
				arr.swap(k, j--), k++
			k:=h
			while (k>=q)
				arr.swap(k, i++), k--
			_sort(arr, l, j), _sort(arr, i, h)
		}

		median3(arr, i, j, k){
			return this.compare(arr[i], arr[j])>0 ? (this.compare(arr[j], arr[k])>0 ? j : this.compare(arr[i], arr[k])>0 ? k : i)
				: (this.compare(arr[k], arr[j])>0 ? j : this.compare(arr[k], arr[i])>0 ? k : i)
		}
	}

	_bubbleSort(arr, l, h){
		i:=l
		while (i<h){
			j:=i+1
			while (j>l)
				(this.compare(arr[j], arr[j-1])>0)?(arr.swap(j, j-1),j--):j--
			i++
		}
	}

	_insertSort(arr, l, h){
		i:=l+1
		while (i<=h){
			t:=arr[i], ll:=l, hh:=i-1
			while (ll<=hh)
				m:=(ll+hh)>>1, (this.compare(t, arr[m])>0)?(hh:=m-1):(ll:=m+1)
			j:=i-1
			while (j>=hh+1)
				arr[j+1]:=arr[j], j--
			arr[j+1]:=t, i++
		}
	}

	compare(v, w){
		return v<w ? 1 : v==w ? 0 : -1
	}
}

ArrSort(oArray, compare:="asc"){
	static _fun_:=A_PtrSize=8?"M8CF0nQdZmYPH4QAAAAAAESNSAFEi8BBi8FGiQyBRDvKcu3D":"i1QkCDPAhdJ0E1aLdCQIkI1IAYkMhovBO8Jy9F7D",pF,___:=(DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"Ptr",0,"uint*",_sz_:=0,"Ptr",0,"Ptr",0),pF:=DllCall("GlobalAlloc","uint",0,"Ptr",_sz_,"Ptr"),DllCall("VirtualProtect","Ptr",pF,"Ptr",_sz_,"uint",0x40,"uint*",_op_:=0),DllCall("crypt32\CryptStringToBinary","str",_fun_,"uint",0,"uint",1,"Ptr",pF,"uint*",_sz_,"Ptr",0,"Ptr",0))
	switch Type(compare)
	{
	case "Func", "BoundFunc":
		pFunc:=CallbackCreate(compare, "C")
	case "String":
		pFunc:=compare="desc"
			?CallbackCreate((p1, p2)=>(v1:=oArray[NumGet(p1+0, "UInt")],v2:=oArray[NumGet(p2+0, "UInt")],v1<v2?1:v1>v2?-1:0), "C", 2)
			:CallbackCreate((p1, p2)=>(v1:=oArray[NumGet(p1+0, "UInt")],v2:=oArray[NumGet(p2+0, "UInt")],v1>v2?1:v1<v2?-1:0), "C", 2)
	default:
		pFunc:=CallbackCreate((p1, p2)=>(v1:=oArray[NumGet(p1+0, "UInt")],v2:=oArray[NumGet(p2+0, "UInt")],v1<v2?1:v1>v2?-1:0), "C", 2)
	}
	vCount := oArray.Length, vData:=Buffer(4*vCount), DllCall(pF, "Ptr", vData, "UInt", vCount, "Cdecl")
	; Loop vCount
	; 	NumPut("UInt", A_Index, vData, offset), offset+=4
	DllCall("msvcrt\qsort", "Ptr", vData, "UInt", vCount, "UInt", 4, "Ptr", pFunc, "Cdecl")
	oArray2 := [], oArray2.Capacity:=vCount, offset:=0
	Loop vCount
		oArray2.Push(oArray[NumGet(vData, offset, "UInt")]), offset+=4
	CallbackFree(pFunc)
	return oArray2
}

; ; examples
; arr:=[], list:=""
; Loop 50
; 	arr.Push(Random(1, 100000)), list.=arr[-1] " "
; MsgBox "数组初始化`n" list
; list:=""
; ; 升序
; ; Sort.New().QSort(arr)	; 快排
; ; Sort.New().insertSort(arr)	; 插入排序
; ; Sort.New().bubbleSort(arr)  ; 冒泡
; Array.Prototype.DefineMethod("sort", (a)=>Sort.New().QSort(a))	; 定义Array对象 sort方法
; arr.sort()
; Loop arr.Length
; 	list.=arr[A_Index] " "
; MsgBox "快排 升序`n" list
; list:=""
; ; 降序
; Sort.New((self,v,w)=>(v>w ? 1 : v==w ? 0 : -1)).QSort(arr)	; 快排
; Loop arr.Length
; 	list.=arr[A_Index] " "
; MsgBox "快排 降序`n" list
; list:=""
; ; 随机
; Sort.New((self,v,w)=>Random(-1,1)).QSort(arr)	; 快排
; Loop arr.Length
; 	list.=arr[A_Index] " "
; MsgBox "快排 随机`n" list
; list:=""

; ; msvcrt qsort	c运行时 快排
; arr:=ArrSort(arr)	; 升序
; Loop arr.Length
; 	list.=arr[A_Index] " "
; MsgBox "c运行时 快排 升序`n" list
; list:=""

; arr:=ArrSort(arr, "desc")	; 降序
; Loop arr.Length
; 	list.=arr[A_Index] " "
; MsgBox "c运行时 快排 降序`n" list
; list:=""

; ; 对象排序
; objarr:=[]
; Loop 50
; 	objarr.Push({k:"a" A_Index, v:t:=Random(1, 1000)}), list.="{k:'a" A_Index "',v:" t "} "
; MsgBox "对象数组初始化`n" list
; list:=""
; Sort.New((self,v,w)=>(v.v>w.v ? 1 : v.v==w.v ? 0 : -1)).QSort(objarr)	; 快排
; Loop objarr.Length
; 	list.="{k:'" objarr[A_Index].k "',v:" objarr[A_Index].v "} "
; MsgBox "对象 快排 降序`n" list
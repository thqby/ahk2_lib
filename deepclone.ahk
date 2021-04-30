deepclone(obj) {
	objs := Map(), objs.Default := ''
	return clone(obj)

	clone(obj) {
		switch Type(obj) {
			case 'Array', 'Map':
				o := obj.Clone()
				for k, v in o
					if IsObject(v)
						o[k] := objs[p := ObjPtr(v)] || (objs[p] := clone(v))
				return o
			case 'Object':
				o := obj.Clone()
				for k, v in o.OwnProps()
					if IsObject(v)
						o.%k% := objs[p := ObjPtr(v)] || (objs[p] := clone(v))
				return o
			default:
				return obj
		}
	}
}
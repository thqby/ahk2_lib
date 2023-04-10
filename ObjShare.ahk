ObjShare(ObjorLresult) {
	static IDispatch := Buffer(16), init := NumPut("int64", 0x20400, "int64", 0x46000000000000c0, IDispatch)
	if IsObject(ObjorLresult)
		return LresultFromObject(IDispatch.Ptr, 0, ObjPtr(ObjorLresult))
	else if ObjectFromLresult(ObjorLresult, IDispatch.Ptr, 0, getvar(com := 0))
		throw  Error("LResult Object could not be created", -1)
	return ComValue(9, com, 1)
}
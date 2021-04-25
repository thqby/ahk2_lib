/************************************************************************
 * @file: RegEx.ah2
 * @description: 正则函数扩展，RegExReplaceEx、RegExMatchAll
 * @author thqby
 * @date 2021/04/25
 * @version 1.0.10
 ***********************************************************************/

/**
 * @description 正则替换加强版，支持匹配项计算
 * @param Haystack: string 需要替换的字符串
 * @param NeedleRegEx: string 正则表达式
 * @param CallBack: funcobj 回调函数，参数为RegExMatchInfo对象，返回值计算后的字符串
 * @param Limit: integer 允许替换的最大次数
 * @param StartingPosition: integer
 * @returns string 返回 Haystack 被替换之后的值
 */
RegExReplaceEx(Haystack, NeedleRegEx, CallBack, Limit := -1, StartingPosition := 1) {
	i := j := StartingPosition, val := SubStr(Haystack, 1, i - 1), k := 0
	while (j := RegExMatch(Haystack, NeedleRegEx, &m, i)) {
		val .= SubStr(Haystack, i, j - i) CallBack(m), i := j + m.Len
		if (Limit != -1 && (++k >= Limit))
			break
	}
	return val SubStr(Haystack, i)
}

/**
 * @description 正则全局模式，返回所有匹配项
 * @param Haystack: string 需要替换的字符串
 * @param NeedleRegEx: string 正则表达式
 * @param StartingPosition: integer
 * @returns array | 0 返回所有匹配项数组，无匹配项时返回0
 */
RegExMatchAll(Haystack, NeedleRegEx, StartingPosition:=1){
	Matchs := [], index := StartingPosition
	while (index := RegExMatch(Haystack, NeedleRegEx, &m, index))
		Matchs.Push(m[0]), index += m.Len(0)
	return Matchs.Length ? Matchs : 0
}
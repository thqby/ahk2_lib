## NLTCalc

[NTL](https://libntl.org/doc/tour-intro.html) is a high-performance, portable C++ library providing data structures and algorithms for manipulating signed, arbitrary length integers, and for vectors, matrices, and polynomials over the integers and over finite fields.

This is the NTL wrapper for evaluating integer and floating-point expressions.

#### example
```autohotkey
MsgBox(
	'0.1+0.7*0.3/0.5+0.3=' NTLCalc('0.1+0.7*0.3/0.5+0.3') '(NTL)   ' (0.1 + 0.7 * 0.3 / 0.5 + 0.3) '(ahk)`n'
	'99999999999999999999999911111111111111111111111*11111111111111111111111=' NTLCalc('99999999999999999999999911111111111111111111111*11111111111111111111111')
)
/*
 * 0.1+0.7*0.3/0.5+0.3=0.82(NTL)   0.82000000000000006(ahk)
 * 99999999999999999999999911111111111111111111111*11111111111111111111111=1111111111111111111111099012345679012345679012354320987654320987654321
 */
```
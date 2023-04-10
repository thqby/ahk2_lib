## XL

[LibXL](https://www.libxl.com/documentation.html) is high performance library for reading and writing Excel(xls,xlsx) files.

#### Example
```AutoHotkey
#Include <XL\XL>

book := XL.New('xlsx'), sheet := book.addSheet('test')
book.setCalcMode(0), rs := book.addRichString()
ft1 := rs.addFont(), ft1.setColor(10), ft1.setSize(24)
ft2 := rs.addFont(), ft2.setSize(24)
ft3 := rs.addFont(), ft3.setColor(12), ft3.setSize(24)
ft4 := rs.addFont(), ft4.setColor(17), ft4.setSize(24)
ft5 := rs.addFont(), ft5.setScript(1), ft5.setSize(24)
rs.addText('E', ft1), rs.addText('=', ft2), rs.addText('m', ft3)
rs.addText('c', ft4), rs.addText('2', ft5)
sheet['D6'] := rs
sheet['a1'] := {bool: false}
sheet[4, 9] := 543.3, sheet['k2'] := 'jview'
sheet['b2'] := {expr: '3*4+2'}
sheet['b4'] := {expr: '9*4', value: 36}
ft := book.addFormat(), ft.setNumFormat(14)
sheet.addrToRowCol(row := 'c8', &row, &col := 0)
sheet['c8'] := {value: book.datePack(2010, 3, 11, 10, 25, 55), format: ft}
; sheet[row, col] := {value: book.datePack(2010, 3, 11, 10, 25, 55), format: ft}
sheet[row, col].width := 50
; sheet.setCol(col, col, 50)
book.save('test.xlsx')
msgbox 'K2 Cell value：' sheet['k2'].value
msgbox 'B2 Cell formula：' sheet['b2'].content.formula
book := ''
```
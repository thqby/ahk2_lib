RasDialDlg(lpszPhonebook, lpszEntry, lpszPhoneNumber, lpInfo) => DllCall('Rasdlg\RasDialDlg', 'str', lpszPhonebook, 'str', lpszEntry, 'str', lpszPhoneNumber, 'ptr', lpInfo, 'int')
RasEntryDlg(lpszPhonebook, lpszEntry, lpInfo) => DllCall('Rasdlg\RasEntryDlg', 'str', lpszPhonebook, 'str', lpszEntry, 'ptr', lpInfo, 'int')
RasPhonebookDlg(lpszPhonebook, lpszEntry, lpInfo) => DllCall('Rasdlg\RasPhonebookDlg', 'str', lpszPhonebook, 'str', lpszEntry, 'ptr', lpInfo, 'int')

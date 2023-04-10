RasSecurityDialogGetInfo(hPort, pBuffer) => DllCall('Rasman\RasSecurityDialogGetInfo', 'ptr', hPort, 'ptr', pBuffer, 'uint')
RasSecurityDialogReceive(hPort, pBuffer, pBufferLength, Timeout, hEvent) => DllCall('Rasman\RasSecurityDialogReceive', 'ptr', hPort, 'ptr', pBuffer, 'ptr', pBufferLength, 'uint', Timeout, 'ptr', hEvent, 'uint')
RasSecurityDialogSend(hPort, pBuffer, BufferLength) => DllCall('Rasman\RasSecurityDialogSend', 'ptr', hPort, 'ptr', pBuffer, 'ushort', BufferLength, 'uint')

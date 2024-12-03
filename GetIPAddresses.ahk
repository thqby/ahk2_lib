GetIPAddresses() {
    #DllLoad ws2_32.dll
    if err := DllCall('ws2_32\WSAStartup', 'ushort', 0x0202, 'ptr', WSAData := Buffer(394 + A_PtrSize, 0))
        throw OSError(err)
    paddrinfo := 0, ips := []
    try {
        if err := DllCall('ws2_32\gethostname', 'ptr', buf := Buffer(2048, 0), 'uint', 256) ||
            DllCall('ws2_32\GetAddrInfoW', 'str', StrGet(buf, 'cp0'), 'ptr', 0, 'ptr', Buffer(48, 0), 'ptr*', &paddrinfo)
            throw OSError(err)
        p := paddrinfo
        loop {
            paddr := NumGet(p, 16 + 2 * A_PtrSize, 'ptr')
            switch t := NumGet(p, 4, 'int') {
                case 2, 23:
                    DllCall('ws2_32\WSAAddressToStringW', 'ptr', paddr, 'uint', NumGet(p, 16, 'uptr'), 'ptr', 0, 'ptr', buf, 'uint*', 2048)
                    ips.Push(StrGet(buf))
            }
            p := NumGet(p, 16 + 3 * A_PtrSize, 'ptr')
        } until !p
        return ips
    } finally
        (paddrinfo) && DllCall('ws2_32\FreeAddrInfoW', 'ptr', paddrinfo), DllCall('ws2_32\WSACleanup')
}

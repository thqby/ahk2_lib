#Include <Socket>

MAC := "A1:B2:C3:D4:E5:F6"

Len := MakeMagicPacket(&MP, MAC)
UDP := SocketUDP()
UDP.Connect(["255.255.255.255", "7"])
; The following line has seemingly no effect
; UDP.SetBroadcast(True)
UDP.Send(StrPtr(MP), Len)
ExitApp

MakeMagicPacket(&MagicPacket, MAC)
{
	MAC := RegExReplace(MAC, "[^0-9A-Fa-f]")
	if (StrLen(MAC) != 12)
		throw Error("Invalid MAC address")
	VarSetStrCapacity(&MagicPacket, 6*17, 0xFF)
	Loop 6*16
	{
		x := "0x" SubStr(MAC, Mod(A_Index*2, 12)-1, 2)
		NumPut("UChar", x, MagicPacket, 5+A_Index)
	}
	return 6*17
}

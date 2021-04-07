#Include <Socket>

global DC_SERV := True
global DC_CLI := False

Server := SocketTCP()
Server.OnAccept := OnAccept
Server.Bind(["0.0.0.0", 8000])
Server.Listen()

Loop
{
	x := SocketTCP()
	x.Connect(["127.0.0.1", 8000])
	x.SendText(A_Index)
	Sleep 300
	if (DC_CLI)
		x.Disconnect()
}
return

OnAccept(Server)
{
	Sock := Server.Accept()
	ToolTip Sock.RecvText()
	if (DC_SERV)
		Sock.Disconnect()
}

# coding: utf-8
module LocalPc
  module NetworkAccess
    module AutoItSendPacketConst
      TCPClientPath = "bin/TcpClient.exe"
      NewClientPath = "bin/newClient.exe"
      GetWindowThreadProcessId = Win32API.new('user32','GetWindowThreadProcessId', 'LP', 'L')
      AutoItX3 = WIN32OLE.new("AutoItX3.Control")
    end
  end
end

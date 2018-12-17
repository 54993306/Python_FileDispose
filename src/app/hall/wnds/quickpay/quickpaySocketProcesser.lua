

quickpaySocketProcesser = class("quickpaySocketProcesser", SocketProcesser)

function quickpaySocketProcesser:MainInfoTransmit(cmd,packetInfo)
    Log.i("quickpaySocketProcesser:RepMailContent..1", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

quickpaySocketProcesser.s_severCmdEventFuncMap = {
}
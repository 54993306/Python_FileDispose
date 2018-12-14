SocketProcesser = class("SocketProcesser");

function SocketProcesser:ctor(delegate)
	self.m_delegate = delegate;
    self:initMember()
end

function SocketProcesser:initMember()
end

--连接成功
function SocketProcesser:onNetWorkConnected()
    if self.m_delegate and self.m_delegate.onNetWorkConnected then
        self.m_delegate:onNetWorkConnected();
    end
end 

--重连成功
function SocketProcesser:onNetWorkReconnected()
    if self.m_delegate and self.m_delegate.onNetWorkReconnected then
        self.m_delegate:onNetWorkReconnected();
    end
end 

--正在重连
function SocketProcesser:onNetWorkReconnect()
    if self.m_delegate and self.m_delegate.onNetWorkReconnect then
        self.m_delegate:onNetWorkReconnect();
    end
end 

function SocketProcesser:onNetWorkClosed(event)
    if self.m_delegate and self.m_delegate.onNetWorkClosed then
        self.m_delegate:onNetWorkClosed(event)
    end
end 

function SocketProcesser:onNetWorkClose()
    if self.m_delegate and self.m_delegate.onNetWorkClose then
        self.m_delegate:onNetWorkClose();
    end
end 

function SocketProcesser:onNetWorkConnectFail()
    if self.m_delegate and self.m_delegate.onNetWorkConnectFail then
        self.m_delegate:onNetWorkConnectFail();
    end
end

function SocketProcesser:onNetWorkConnectException()
    if self.m_delegate and self.m_delegate.onNetWorkConnectException then
        self.m_delegate:onNetWorkConnectException();
    end
end  

--连接弱
function SocketProcesser:onNetWorkConnectWeak()
    if self.m_delegate and self.m_delegate.onNetWorkConnectWeak then
        self.m_delegate:onNetWorkConnectWeak();
    end
end 

function SocketProcesser:onNetWorkConnectHealthly()
    if self.m_delegate and self.m_delegate.onNetWorkConnectHealthly then
        self.m_delegate:onNetWorkConnectHealthly();
    end
end

function SocketProcesser:onReceivePacket(cmd, packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then
        local done = self.s_severCmdEventFuncMap[cmd](self, cmd, packetInfo);
        return done or true;
    end
    return false;
end

function SocketProcesser:onSyncData(cmd, code, packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then
        local done = self.s_severCmdEventFuncMap[cmd](self, code, packetInfo);
        return done or true;
    end
    return false;
end

function SocketProcesser:directForward(cmd, packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo)
end

SocketProcesser.s_severCmdEventFuncMap = {
	
};
local testDelay_10021 = false -- 是否延迟处理10021(用于复现问题)
local testResolve_10021 = true -- 是否解决10021延迟问题
local ReloginDelayTime = 10 -- 登录无返回后重新发送登录请求

require("app.hall.network.PacketBuffer");
require("app.hall.network.socketProcesser");
require("app.hall.network.commonSocketProcesser");
require("app.hall.network.socketCmd");
local GlobalDataProcesser = require("app.hall.socket.GlobalDataProcesser")

package.loaded["app.framework.cc.net.SocketTCP"] = nil
package.loaded["app.framework.cc.net.init"] = nil
cc.net  = require("app.framework.cc.net.init")

SocketManager = class("SocketManager")
local MAX_OBSERVER = 10

SocketManager.getInstance = function()
    if not SocketManager.s_instance then 
        SocketManager.s_instance = SocketManager.new();
    end
    return SocketManager.s_instance;
end

SocketManager.releaseInstance = function()
    if SocketManager.s_instance then
        SocketManager.s_instance:dtor();
    end
    SocketManager.s_instance = nil;
end

function SocketManager:ctor()
    self.buf = PacketBuffer.new();
    self.cacheMsgs = {};
    self.pauseDispatchMsg = false
    --
    self.m_socketProcessers = {};
    self.m_status = NETWORK_EXCEPTION;
    --心跳间隔
    self.m_heartBeat_time = 6;
    --网络弱时间
    self.m_network_weak_time = 1.8;
    --网络异常时间
    self.m_network_exception_time = 14;
    --重连最大次数
    self.m_maxReconnect_time = 3;
    --连接尝试次数
    if IS_IOS then
        self.m_maxTry_time = 3;
    else
        self.m_maxTry_time = 1;
    end
    self.m_try_time = 0;

    -- 断线后重连时间
    self.m_retryConnect_time = 9

    self:resetAttemptedServers()

    self._authMutex = false  --登录成功
    self.delayTest = testDelay_10021
    self.EventList = {};     --mzd add 存放监听事件
    self.hostIP = {}
end

function SocketManager:dtor()
    if self._socket then
        self._socket:close();
        self._socket = nil;
    end

    if self.m_forceReturnToLoginHandler then
        scheduler.unscheduleGlobal(self.m_forceReturnToLoginHandler)
        self.m_forceReturnToLoginHandler = nil
    end
end

-- 函数功能：  添加消息观察者  -- mzd add
-- 返回值：   retHandler = {msgId = number, obj = obj, func = function }
-- msgId:     消息编号
-- obj：      观察者对象
-- func：     观察者观察后的响应函数
function SocketManager:AddObserver(msgId, obj, func)
    local retHandler = {}
    if type(func) ~= "function" then
        Log.d("添加消息"..msgId.."的监听失败：请输入正确的监听函数！")
        return retHandler
    end

    if obj then
        if type(obj) ~= "table" then
            Log.d("添加消息"..msgId.."的监听失败：请输入正确的观察者对象！")
        end
    end

    if not self.EventList[msgId] then
        self.EventList[msgId] = {}
    else
        -- 检查是否重复添加
        local isContained = false
        for i, v in ipairs(self.EventList[msgId]) do
            if v.obj == obj and v.func == func then
                isContained = true
                break
            end
        end
        if isContained then
            Log.d("添加消息"..msgId.."的监听失败：重复添加！")
            return retHandler
        end
    end

    -- 同一个消息的观察者数量
    local numObserver = #self.EventList[msgId]
    if numObserver >= MAX_OBSERVER then
        Log.d("添加消息"..msgId.."的监听失败：超出最大监听数量！")
        return retHandler
    end
    numObserver = numObserver + 1
    local newObserver = {}
    newObserver.obj = obj
    newObserver.func = func
    self.EventList[msgId][numObserver] = newObserver

    retHandler.msgId = msgId
    retHandler.obj = obj
    retHandler.func = func
    return retHandler
end

-- 函数功能： 移除消息观察者
-- 返回值：   true:移除成功，false：移除失败
-- argA:     消息编号 or table = {msgId = number, obj = obj, func = function }
-- argB:     观察者对象
-- argC:     观察者观察后的响应函数
function SocketManager:RemoveObserver(argA, argB, argC)
    local msgId = argA
    local obj = argB
    local func = argC
    if type(argA) == "table" then
        msgId = argA.msgId
        obj = argA.obj
        func = argA.func
    end

    if not self.EventList[msgId] then
        return true
    end

    for i, v in ipairs(self.EventList[msgId]) do
        if v.obj == obj and v.func == func then
            table.remove(self.EventList[msgId], i)
            break
        end
    end
    return true
end

function SocketManager:getSocketTime()
    if self._socket then
        return self._socket:getTime();
    else
        return os.time();
    end
end

--获取网络连接状态
function SocketManager:getNetWorkStatus()
    return self.m_status;
end

function SocketManager:addSocketProcesser(socketProcesser)
    if not self:checkExist(self.m_socketProcessers, socketProcesser) then
        table.insert(self.m_socketProcessers, 1, socketProcesser);
    end
end

function SocketManager:setUserDataProcesser(socketProcesser)
    self.m_userDataProcessers = socketProcesser;
end

function SocketManager:removeSocketProcesser(socketProcesser)
    local index = self:getIndex(self.m_socketProcessers, socketProcesser);
    if index ~= -1 then
        table.remove(self.m_socketProcessers, index);
    end
end

function SocketManager:onConnected(event)
    Log.d("------SocketManager:onConnected ", "连通");
    self.m_status = NETWORK_NORMAL;
    self.m_try_time = 0;

    if self.m_forceReturnToLoginHandler then
        scheduler.unscheduleGlobal(self.m_forceReturnToLoginHandler)
        self.m_forceReturnToLoginHandler = nil
    end

    if self.m_isReconnent then

        ---TODO 判断是否是扑克监听
        local eventApi = HallAPI.EventAPI
        if eventApi:hasEvent(eventApi.NetWorkReconnected) then
            eventApi:dispatchEvent(eventApi.NetWorkReconnected)
        else
            if self.m_socketProcessers[1] then
                kLoginInfo:requestLogin();
                self.m_socketProcessers[1]:onNetWorkReconnected(event);
            end
        end
        self.m_isReconnent = false;
        self.m_reconnectTime = 0;
    else
        if self.m_socketProcessers[1] then
            self.m_socketProcessers[1]:onNetWorkConnected(event);
        end
    end

    kLoginInfo:setServerMaintainStatus(-1)
    self:startHeartBeat();
    if not self.m_msg_hander then
        self.m_msg_hander = scheduler.scheduleUpdateGlobal(function()
             self:onReceivePacket();
            end);
    end
end

function SocketManager:startHeartBeat()
    self:stopHeartBeat();
    local function hearBeat()
        --发送心跳消息
        self:send(CODE_TYPE_SYS, CODE_HEARTBEAT);
        --
        self.checkNetWorkWeakThread = scheduler.performWithDelayGlobal(function ()
            self:onConnectWeak();
        end, self.m_network_weak_time);
    end
    hearBeat()
    self.heatBeatThread = scheduler.scheduleGlobal(hearBeat, self.m_heartBeat_time);
end

function SocketManager:stopHeartBeat()
    if self.heatBeatThread then
        scheduler.unscheduleGlobal(self.heatBeatThread);
        self.heatBeatThread = nil;
    end
    self:stopCheckNetWorkThread();
end

function SocketManager:stopCheckNetWorkThread()
    if self.checkNetWorkThread then
        scheduler.unscheduleGlobal(self.checkNetWorkThread);
        self.checkNetWorkThread = nil;
    end

    if self.checkNetWorkWeakThread then
        scheduler.unscheduleGlobal(self.checkNetWorkWeakThread);
        self.checkNetWorkWeakThread = nil;
    end
end

function SocketManager:onClosed(event)
    Log.d("SocketManager:onClosed self.m_manual_close", self.m_manual_close);

    -- 延迟0.1秒, 避免在被人挤号时, 自动尝试重连网络
    scheduler.performWithDelayGlobal(
        function()
            if self.m_manual_close then --如果是强制退出则不理会断网
                return;
            end
            local is_maintain = kLoginInfo:isServerMaintain()
            Log.d("is_maintain", is_maintain)
            if is_maintain then
                self:onClosedNotify(event)
                self:stopHeartBeat()
                self:resetAttemptedServers()
            elseif not self.m_isReconnent then -- 若不是服务器处于维护状态, 则走网络异常流程处理, 尝试重连
                self:onConnectException()
            end
        end, 0.1)
end

function SocketManager:onClosedNotify(event)
    -- dump(event, "SocketManager:onClosedNotify")
    ---TODO 判断是否是扑克监听
    local eventApi = HallAPI.EventAPI
    if eventApi:hasEvent(eventApi.NetWorkClosed) then
        eventApi:dispatchEvent(eventApi.NetWorkClosed, event)
        self.m_status = NETWORK_EXCEPTION;
    else
        if #self.m_socketProcessers > 0 then
            self.m_status = NETWORK_EXCEPTION;
            self.m_socketProcessers[1]:onNetWorkClosed(event);
        end
    end
    self:startForceReturnToLoginCountDown()
end

-- 强制退回登陆界面
function SocketManager:startForceReturnToLoginCountDown()
    if not self.m_forceReturnToLoginHandler then
        self.m_forceReturnToLoginHandler = scheduler.performWithDelayGlobal(function()
                self:onClosedNotify({_forceReturnToLogin = false})
                self.m_forceReturnToLoginHandler = nil
            end, 120)
    end
end

function SocketManager:onClose(event)
    -- Log.i(debug.traceback("------SocketManager:onClose---------"))
    if self.m_manual_close then --如果是强制退出则不理会断网
        return;
    end
    --self:stopHeartBeat();
end

function SocketManager:onConnectFail(event)
    Log.d("SocketManager:onConnectFail self.m_isReconnent", self.m_isReconnent);
    Log.d("SocketManager:onConnectFail self.m_reconnectTime", self.m_reconnectTime);
    if self.m_isReconnent then -- 重连时失败处理
        if self.m_reconnectTime < self.m_maxReconnect_time then
            self:reconnetSocket();
        elseif not self:switchServerAndConnect() then
            if self.m_needRetryConnect then -- 如果需要继续尝试重连, 则0.5秒后再次发起重连请求
                self:onConnectException()
                -- scheduler.performWithDelayGlobal(function() self:onConnectException() end, 2)
            else
                -- 断开连接并通知玩家
                self.m_manual_close = false;
                self.m_isReconnent = false;
                self.m_reconnectTime = 0;
                self:stopHeartBeat()
                self:resetAttemptedServers()
                self:onClosedNotify(event)
            end
        end
        return;
    end

    -- 正常登录时失败处理
    if not self:switchServerAndConnect() then
        self:stopHeartBeat();
        self:resetAttemptedServers()
        if self.m_try_time >= self.m_maxTry_time then
            self:closeSocket();
            
            ---TODO 判断是否是扑克监听
            local eventApi = HallAPI.EventAPI
            if eventApi:hasEvent(eventApi.NetWorkConnectFail) then
                eventApi:dispatchEvent(eventApi.NetWorkConnectFail)
                self.m_status = NETWORK_EXCEPTION;
            else
                if #self.m_socketProcessers > 0 then
                    self.m_status = NETWORK_EXCEPTION;
                    self.m_socketProcessers[1]:onNetWorkConnectFail(event);
                end
            end
        else
            self:closeSocket();
            self:openSocket();
        end
    end
end

-- 函数功能: 是否能切换服务器并连接
-- 返回值: bool
function SocketManager:switchServerAndConnect()
    if #self.m_unAttemptedSLBServers > 0 then
        self:attemptRandomConnect(self.m_unAttemptedSLBServers)
        return true
    elseif #self.m_unAttemptedGFServers > 0 then
        self:attemptRandomConnect(self.m_unAttemptedGFServers)
        return true
    end
    return false
end

-- 函数功能: 尝试连接servers中的服务器
-- servers: 服务器列表
function SocketManager:attemptRandomConnect(servers)
    local index = math.random(#servers)
    SERVER_IP = servers[index].IP
    SERVIER_PORT = servers[index].PORT
    if self._socket then
        self:closeSocket();
    end
    self:openSocket();
end

function SocketManager:onConnectException(event)
    Log.d("SocketManager:onConnectException", "socekt 连接异常");
    self:closeSocket();
    
    if not self.m_retryConnectHandler then -- 确保只有一个进程在设置重连状态
        self.m_needRetryConnect = true
        self.m_retryConnectHandler = scheduler.performWithDelayGlobal(function()
            self.m_needRetryConnect = false
            self.m_retryConnectHandler = nil
            end, self.m_retryConnect_time)
    end

    ---TODO 判断是否是扑克监听
    local eventApi = HallAPI.EventAPI
    if eventApi:hasEvent(eventApi.NetWorkConnectException) then
        eventApi:dispatchEvent(eventApi.NetWorkConnectException)
        self.m_status = NETWORK_EXCEPTION;
    else
        if #self.m_socketProcessers > 0 then
            self.m_status = NETWORK_EXCEPTION;
            self.m_socketProcessers[1]:onNetWorkConnectException(event);
        end
    end
    self:stopHeartBeat();
    self:resetAttemptedServers()
    self:reconnetSocket();
end

function SocketManager:onConnectWeak(event)
    Log.d("SocketManager:onConnectWeak", "socekt 连接弱");

    ---TODO 判断是否是扑克监听
    local eventApi = HallAPI.EventAPI
    if eventApi:hasEvent(eventApi.NetWorkConnectWeak) then
        eventApi:dispatchEvent(eventApi.NetWorkConnectWeak)
    else
        if #self.m_socketProcessers > 0 then
            self.m_socketProcessers[1]:onNetWorkConnectWeak(event);
        end
    end

    if self.checkNetWorkThread == nil then
        self.checkNetWorkThread = scheduler.performWithDelayGlobal(function ()
            Log.d("checkNetWorkThreadcheckNetWorkThreadcheckNetWorkThread")
            self:onConnectException();
        end, self.m_network_exception_time);
    end
end

function SocketManager:onReceive(event)
    self:stopCheckNetWorkThread();    
    local eventApi = HallAPI.EventAPI
    if eventApi:hasEvent(eventApi.NetWorkConnectHealthly) then
        eventApi:dispatchEvent(eventApi.NetWorkConnectHealthly)
    else
        if #self.m_socketProcessers > 0 then
            self.m_socketProcessers[1]:onNetWorkConnectHealthly(event);
        end
    end
    --
    local msgs = self.buf:parseMessage(event.data); 
    for i = 1, #msgs do
        if self.delayTest and msgs[i].subcode == HallSocketCmd.CODE_REC_LOGIN then
            Log.d("delayTest")
            self.delayTest = false
            scheduler.performWithDelayGlobal(function()
                table.insert(self.cacheMsgs, 1, msgs[i])
                end, 2)
        else
            --Modify Start diyal.yin 20180319
            --登录后消息总线消息乱序，将10021消息插入到队列最前端
            
            if testResolve_10021 and not self._authMutex and msgs[i].subcode == HallSocketCmd.CODE_REC_LOGIN then
                table.insert(self.cacheMsgs, 1, msgs[i]);
            else
                table.insert(self.cacheMsgs, msgs[i]);
            end

            --Modify End diyal.yin 20180319
            if msgs[i].subcode == HallSocketCmd.CODE_PLAYER_ROOM_STATE then
                local packetInfo = json.decode(msgs[i].content)
                kLoginInfo:setHasResumeRoom(packetInfo.gaT)
            end

            if msgs[i].subcode == 0 and msgs[i].code == 0 then
                Log.d("msgs[i].subcode == 0 and msgs[i].code == 0")
                kLoginInfo:setServerMaintainStatus(msgs[i].subcode)
            end
        end
    end
end

function SocketManager:reStartReceivePacket()
    if self.resumeMsg then
        self:onReceivePacket(self.resumeMsg);
        self.resumeMsg = nil;
    end
    if not self.m_msg_hander then
        self.m_msg_hander = scheduler.scheduleUpdateGlobal(function()
             self:onReceivePacket();
            end);
    end
end

-- 在不影响消息乱序功能判断的前提下，账号注册部分需要透传的消息
function SocketManager:permeateMsg(msg)
    if msg.subcode == HallSocketCmd.CODE_REC_VERIFY 
    or msg.subcode == HallSocketCmd.CODE_REC_CODEVERIFY 
    or msg.subcode == HallSocketCmd.CODE_REC_GETPASSWORD
    or msg.subcode == HallSocketCmd.CODE_REC_BINDWECHAT
    then return true end
    return false
end

-- 对消息乱序的处理
function SocketManager:disorderMsgJudge(msg)
    if msg.subcode == CODE_HEARTBEAT then return false end   -- 心跳消息不处理
    if testResolve_10021 and not self._authMutex then
        if self:permeateMsg(msg) then return false end          -- 对需要透传的数据处理
        if msg.subcode == HallSocketCmd.CODE_REC_LOGIN then
            self._authMutex = true
        else
            return true
        end
    end
    return false
end

function SocketManager:onReceivePacket(msg)
    if self.pauseDispatchMsg then return end

    --Modify Start diyal.yin 20180319
    --登录后消息总线消息乱序，如果没有收到10021则不去透传消息
    if msg and msg.subcode == HallSocketCmd.CODE_REC_LOGIN then
        self._authMutex = true
    end
    --Modify End diyal.yin 20180319

    if not msg then
        if #self.cacheMsgs == 0 then
            return;
        end
        msg = self.cacheMsgs[1]
        if self:disorderMsgJudge(msg) then return end
        table.remove(self.cacheMsgs, 1);
    end
    local info = {}
    if msg.subcode ~= CODE_HEARTBEAT then
        info = json.decode(msg.content);
    else
        return
    end

    local packetInfo = nil;
    if msg.code == CODE_TYPE_INSERT or msg.code == CODE_TYPE_UPDATE or msg.code == CODE_TYPE_DELETE then
        self.m_userDataProcessers:onSyncData(msg.subcode, msg.code, info);
        local tempInfo = {};
        tempInfo.code = msg.code;
        tempInfo.content = info;
        packetInfo = tempInfo
    else
        packetInfo = info;
    end
    require("app.clientdebuginfo");
    clientdebug(msg);

    GlobalDataProcesser.onSyncData(msg.subcode, msg.code, packetInfo)
    for k, v in ipairs(self.m_socketProcessers) do
        if v:onReceivePacket(msg.subcode, packetInfo) then
            break;
        end
    end

    if not self.EventList[msg.subcode] then
        if not flagDeal then
            Log.i("消息msgId = "..msg.subcode.."没有被监听！")
        end
    else
        -- 遍历消息监听列表
        len = #self.EventList[msg.subcode]
        v = nil
        for i = len, 1, -1 do
            v = self.EventList[msg.subcode][i]
            if v.obj then
                v.func(v.obj, msg.subcode, packetInfo)
            else
                v.func(msg.subcode, packetInfo)
            end
        end
    end
end

--[[
-- @brief  回放模拟数据返回函数
-- @param  void
-- @return void
--]]
function SocketManager:onRecordReceivePacket(recordMsgs)
    if #recordMsgs == 0 then
        return;
    end
    local msg = table.remove(recordMsgs, 1);
    local info = json.decode(msg.content);
    local packetInfo = nil;
    if msg.code == CODE_TYPE_INSERT or msg.code == CODE_TYPE_UPDATE or msg.code == CODE_TYPE_DELETE then
        self.m_userDataProcessers:onSyncData(msg.subcode, msg.code, info);
        local tempInfo = {};
        tempInfo.code = msg.code;
        tempInfo.content = info;
        packetInfo = tempInfo
    else
        packetInfo = info;
    end
    for k, v in ipairs(self.m_socketProcessers) do
        if v:onReceivePacket(msg.subcode, packetInfo) then
            break;
        end
    end

    -- 回放中增加斗地主的分发
    if not self.EventList[msg.subcode] then
        if not flagDeal then
            Log.i("消息msgId = "..msg.subcode.."没有被监听！")
        end
    else
        -- 遍历消息监听列表
        len = #self.EventList[msg.subcode]
        v = nil
        for i = len, 1, -1 do
            v = self.EventList[msg.subcode][i]
            if v.obj then
                v.func(v.obj, msg.subcode, packetInfo)
            else
                v.func(msg.subcode, packetInfo)
            end
        end
    end

end

function SocketManager:send(code, subcode, msgContent)
    --if not self._socket then
    if not self._socket or not self._socket.isConnected then
        debug.traceback( "SocketManager:send() 网络尚未连接...." )
        return false
    end 
    if subcode == HallSocketCmd.CODE_SEND_LOGIN then
        self.delayTest = testDelay_10021
        self._authMutex = false
        scheduler.performWithDelayGlobal(function()
                if not UIManager.getInstance():getWnd(HallLogin) then
                    self:relogin(code, subcode, msgContent) -- 尝试重新发送登录
                end
            end, ReloginDelayTime)
    end
    local data = (msgContent ~= nil) and json.encode(msgContent) or nil;
    if code > 0 then
        Log.i("------send msg code", code .. " subcode:" .. subcode);
        Log.i("------send msg data", data);
        Log.s("------send msg code: " .. tostring(code) .. "\n------send msg subcode: " .. tostring(subcode) .. "\n------send msg data: " .. tostring(data))
    end
    local buf = PacketBuffer.createMessage(code, subcode, data);
    self._socket:send(buf:getPack());
    return true
end

-- 尝试重新发送登录
-- 当服务器重启后, 玩家迅速登录 (大约<1秒), 可以建立socket, 但服务器服务未完全启用, 此时登录消息发送后无返回, 需要重新发送登录请求
function SocketManager:relogin(code, subcode, msgContent)
    if self._authMutex then return end -- 如已经登录成功, 则不做处理
    if self.m_status ~= NETWORK_NORMAL then return end -- 如果网络不是已经连接, 则不做处理
    if self.m_isReconnent then return end -- 如正在进行重连操作, 则不做处理
    self.m_isReconnent = true
    self:send(code, subcode, msgContent)
end

--打开连接
function SocketManager:openSocket()
    Log.i("self.m_status.........",self.m_status)
    if self.m_ddzCloseSocket or self.m_status == NETWORK_NORMAL then 
        return 
    end 
    self.m_manual_close = false;
    self.m_try_time = self.m_try_time + 1;
    if not self._socket then
        local host = SERVER_IP;
        local port = SERVIER_PORT;
        Log.d("------SocketManager:openSocket host", host);
        Log.d("------SocketManager:openSocket port", port);
        self._socket = cc.net.SocketTCP.new(host, port, false);
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected));
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed));
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose));
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFail));
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onReceive));
        local updateInterval = cc.Director:getInstance():getAnimationInterval()
        self._socket:setConnFailTime(2 * 0.05 / updateInterval) -- 设置为2秒超时
        -- self._socket:connect();
        self:getIP(SERVER_IP)
        for i, v in ipairs(self.m_unAttemptedSLBServers) do
            if SERVER_IP == v.IP then
                table.remove(self.m_unAttemptedSLBServers, i)
                return
            end
        end
        for i, v in ipairs(self.m_unAttemptedGFServers) do
            if SERVER_IP == v.IP then
                table.remove(self.m_unAttemptedGFServers, i)
                return
            end
        end
    else
        -- self._socket:connect();
        self:getIP(SERVER_IP)
    end
end

function SocketManager:getIP(host)
    self.hostIP[host] = nil
    Log.i("SocketManager:getIP.......",self.m_status)
    if self.m_status ~= NETWORK_NORMAL then
        if type(luckyGDNSPaser) == "function" then
            luckyGDNSPaser(host)
        else
            self._socket:connect()
        end
    end
end

function SocketManager:getIPCallback(host, ip)
    Log.i("SocketManager:getIPCallback(host, ip)", host, ip)
    if type(ip) ~= "string" then return end
    local addrinfo = {}
    if string.find(ip, ":") then -- ipv6
        table.insert(addrinfo, {family = "inet6", addr = ip})
    end
    if string.find(ip, ".") then -- ipv4
        table.insert(addrinfo, {family = "inet", addr = ip})
    end
    Log.i("addrinfo", addrinfo)
    -- if not next(addrinfo) then return end

    self.hostIP[host] = addrinfo
    if host == SERVER_IP then
        self._socket:connectWithIP(nil, nil, nil, addrinfo)
    end
end

--关闭连接
function SocketManager:closeSocket()
    self.m_try_time = 0;
    self:stopHeartBeat()
    self.m_manual_close = true;
    self.cacheMsgs = {};
    self.pauseDispatchMsg = false
    if self._socket then
        self._socket:close();
        self._socket = nil;
    end
    self.m_status = NETWORK_EXCEPTION
end

function SocketManager:reconnetSocket()
    local host = SERVER_IP;
    local port = SERVIER_PORT;
    Log.d("SocketManager:reconnetSocket", "------host =" .. host);
    Log.d("SocketManager:reconnetSocket", "------port =" .. port);
    if self._socket then
        self:closeSocket();
    end
    self.m_isReconnent = true;
    self.m_reconnectTime = (self.m_reconnectTime or 0) + 1;
    self:openSocket();
end

function SocketManager:getIndex(vtable, value)
    for k, v in pairs(vtable or {}) do 
        if v == value then
            return k;
        end
    end

    return -1;
end

function SocketManager:checkExist(vtable, value)
    return self:getIndex(vtable, value) ~= -1;
end

-- 函数功能: 清空尝试过的服务器列表
-- 返回值: 无
function SocketManager:resetAttemptedServers()
    G_Config = G_Config or {}
    G_Config.SLB_Servers = G_Config.SLB_Servers or {}
    G_Config.GF_Servers = G_Config.GF_Servers or {}
    self.m_unAttemptedSLBServers = clone(G_Config.SLB_Servers)
    self.m_unAttemptedGFServers = clone(G_Config.GF_Servers)
end

-- 函数功能: 斗地主调用关闭网络
-- 返回值: 无
function SocketManager:addDDZCloseSocket(boolean)
    self.m_ddzCloseSocket = boolean
end

-------------------------------------------------------------------------
-- Desc:   扑克牌框架网络代理
-- Last:
-- Author:   diyal.yin
-- Content:  因为底层代码原因，这里网络部分消息分发通过代理全部处理
-- 劫持注册的模块消息，抽离数据，只给到逻辑层。达到数据UI逻辑解耦合
-- 2017-11-04  新建
-- 2017-11-07  修改 区分队列消息和普通直传消息
-------------------------------------------------------------------------
local ProxyDelegate = class("ProxyDelegate")

local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")

local SList = require("package_src.games.paodekuai.pdkcommon.control.SList");

local _scheduler = cc.Director:getInstance():getScheduler()

local Facade = require("package_src.games.paodekuai.pdkcommon.control.Facade");

-- 构造函数
-- @param bindQueueMsgTab: 队列管理消息
-- @param bindOtherMsgTab: 其它消息，不存队列，即刻透传
function ProxyDelegate:ctor(bindQueueMsgTab, bindOtherMsgTab)
    Log.i("ProxyDelegate:ctor()")

    -- 队列消息的开关，默认关闭
    self.m_queueSwitch = false

    -- 缓存消息的委托方法列表
    self.m_handlerOfQueue = {}

    -- 即时消息的委托方法列表
    self.m_handlesOfimmediate = {}

    --网络事件集合
    self.m_handlerOfNetWork = {}

    --注册缓存消息的监听
    self:bindMsgQueueEvent(bindQueueMsgTab)

    -- 注册即时消息的监听
    self:bindMsgCommEvent(bindOtherMsgTab)

    -- 注册网络状态监听
    self:bindNetWorkStatus()

    --注册缓存消息开关控制事件
    self._EventSwitchHandler = HallAPI.EventAPI:addEvent(POKERCONST_EVENT_NETDISPATCH,
        handler(self, self.setLockState))

    -- 解读缓存消息的委托方法
    self.m_handlerOfQueueRead = self:stateLoop()
end

-- 析构函数
function ProxyDelegate:dtor()
    Log.i("ProxyDelegate:dtor")
    local RemoveListener = function (handlerTable)
        for _,v in pairs(handlerTable) do
            Log.i("ProxyDelegate:dtor  v == ", v)
    
            HallAPI.EventAPI:removeNetEvent(v)
        end
    end
    --批量移除网络监听
    RemoveListener(self.m_handlerOfQueue)
    RemoveListener(self.m_handlesOfimmediate)
    for i,v in ipairs(self.m_handlerOfNetWork) do
        HallAPI.EventAPI:removeEvent(v)
    end

    --取消注册消息
    -- Facade:getInstance():removeEventListener(self._EventSwitchHandler)
    HallAPI.EventAPI:removeEvent(self._EventSwitchHandler)

    -- 关闭循环调度
    _scheduler:unscheduleScriptEntry(self.m_handlerOfQueueRead)
end

--绑定监听队列消息
--@param bindMsgTabs 绑定消息列表
function ProxyDelegate:bindMsgQueueEvent(bindMsgTabs)
    if not bindMsgTabs then
        return
    end

    self.SList = SList.new()

    for _, v in pairs(bindMsgTabs) do
        -- Log.i("add to listener : ", v)
        local handler = HallAPI.EventAPI:addNetEvent(v, handler(self, self.msgRecvHandler))
        table.insert(self.m_handlerOfQueue, handler)
    end
end

--绑定监听普通消息
--@param bindMsgTabs 绑定消息列表
function ProxyDelegate:bindMsgCommEvent(bindMsgTabs)
    if not bindMsgTabs then
        return
    end

    for _, v in pairs(bindMsgTabs) do
        -- Log.i("add to listener : ", v)
        local handler = HallAPI.EventAPI:addNetEvent(v, handler(self, self.msgCommRecvHandler))
        table.insert(self.m_handlesOfimmediate, handler)
    end
end

--注册网络状态监听
function ProxyDelegate:bindNetWorkStatus()

    local function addEvent(id)
        local nhandle =  HallAPI.EventAPI:addEvent(id, function (...)
            self:ListenToNetEvent(id, ...)
        end)
        table.insert(self.m_handlerOfNetWork, nhandle)
    end

    addEvent(HallAPI.EventAPI.NetWorkClosed)
    addEvent(HallAPI.EventAPI.NetWorkConnectFail)
    addEvent(HallAPI.EventAPI.NetWorkConnectWeak)
    addEvent(HallAPI.EventAPI.NetWorkConnectException)
    addEvent(HallAPI.EventAPI.NetWorkReconnected)
    addEvent(HallAPI.EventAPI.NetWorkConnectHealthly)
end


--处理网络事件监听
function ProxyDelegate:ListenToNetEvent(id, ...)
    Log.i("ProxyDelegate:ListenToEvent id", id)


    if id == HallAPI.EventAPI.NetWorkClosed then
        self:onNetWorkClosed(...)

    elseif id == HallAPI.EventAPI.NetWorkConnectFail then
        self:NetWorkConnectFail(...)

    elseif id == HallAPI.EventAPI.NetWorkConnectWeak then
        self:NetWorkConnectWeak(...)

    elseif id == HallAPI.EventAPI.NetWorkConnectException then
        self:NetWorkConnectException(...)

    elseif id == HallAPI.EventAPI.NetWorkReconnected then
        self:NetWorkReconnected(...)

    elseif id == HallAPI.EventAPI.NetWorkConnectHealthly then
        self:onNetWorkConnectHealthly(...)
    end
end

--网络关闭
function ProxyDelegate:onNetWorkClosed( ...)
    Log.i("ProxyDelegate:onNetWorkClosed ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_CLOSE , ...)
end

--网络连接失败
function ProxyDelegate:NetWorkConnectFail( ...)
    Log.i("ProxyDelegate:NetWorkConnectFail ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONFAIL , ...)
end

--网络弱
function ProxyDelegate:NetWorkConnectWeak( ...)
    Log.i("ProxyDelegate:NetWorkConnectWeak ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONWEAK , ...)
end

--网络异常
function ProxyDelegate:NetWorkConnectException( ...)
    Log.i("ProxyDelegate:NetWorkConnectException ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONEXCEPTION , ...)
end

--网络重连
function ProxyDelegate:NetWorkReconnected( ...)
    Log.i("ProxyDelegate:NetWorkReconnected ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_RECONNECTED , ...)
end

--网络正常隐藏转圈
function ProxyDelegate:onNetWorkConnectHealthly( ...)
    Log.i("ProxyDelegate:onNetWorkConnectHealthly ")
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_NETWORK_CONNECTHEALTHLY , ...)
end

--处理队列消息监听处理
--@param cmd 指令
--@param packetInfo 包体
function ProxyDelegate:msgRecvHandler(cmd, packetInfo)
    Log.i("ProxyDelegate:msgRecvHandler cmd", cmd)
    -- Log.i("ProxyDelegate:msgRecvHandler", packetInfo)
    local st = {}
    st.cmd = cmd
    st.packetInfo = packetInfo

    self:pushBack(st)
end

--处理普通消息监听处理
--@param cmd 指令
--@param packetInfo 包体
function ProxyDelegate:msgCommRecvHandler(cmd, packetInfo)
    Log.i("ProxyDelegate:msgCommRecvHandler cmd", cmd)
    
    -- Log.i("ProxyDelegate:msgCommRecvHandler ", st)
    local st = {}
    st.cmd = cmd
    st.packetInfo = packetInfo
    self:ReadServerStructInfor(st)
end

--插入消息队列
--@param cmd 指令
--@param packetInfo 包体
--@interface 可以被子类覆盖
function ProxyDelegate:pushBack(event_struct)
    self.SList:pushBack(event_struct)
end

--缺省格式化
--@param cmd 指令
--@param packetInfo 包体
function ProxyDelegate:formatDefault(cmd, packetInfo)
    local event_struct = {}
    event_struct.cmd = cmd
    event_struct.packetInfo = packetInfo
    return event_struct
end

--状态循环调度
function ProxyDelegate:stateLoop()

    local function scheduleUpdate_(dt)
        --Log.i("ProxyDelegate:stateLoop ", self.m_queueSwitch)
        if self.m_queueSwitch then
           self:dispatchMsg()
        else
           -- Log.i("ProxyDelegate:stateLoop() false")
        end
    end
    local handler = _scheduler:scheduleScriptFunc(scheduleUpdate_, 0.0, false)
    return handler
end

--设置逻辑循环阀值
-- @param event {_eventnname, _userdata}  事件名，附带数据
function ProxyDelegate:setLockState(data)
    assert(type(data) == "boolean", "ProxyDelegate:setLockState- invalid value type, must boolean")
    self.m_queueSwitch = data
end

--透传消息
function ProxyDelegate:dispatchMsg()
    if self.SList:getSize() > 0 then

        local topCell = self.SList:popFront()
        self.m_queueSwitch = false
        -- dump(topCell)
        self:ReadServerStructInfor(topCell)

        -- self.SList:popFront()
    end
end

-- 消息解析
-- @param infor:消息内容
function ProxyDelegate:ReadServerStructInfor(infor)
    printError("这个消息必须重载")
end


return ProxyDelegate
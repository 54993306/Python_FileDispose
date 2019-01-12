--ViewAPI
local EventAPI = class("EventAPI")
local GEvent=import(".GEvent")

-- 网络关闭
EventAPI.NetWorkClosed            = "NetWorkClosed"
-- 网络连通失败
EventAPI.NetWorkConnectFail       = "NetWorkConnectFail"
-- 网络连通异常
EventAPI.NetWorkConnectWeak       = "NetWorkConnectWeak"
-- 网络正在重连
EventAPI.NetWorkConnectException  = "NetWorkConnectException"
-- 网络重连成功
EventAPI.NetWorkReconnected       = "NetWorkReconnected"
-- 网络连接状态隐藏转圈
EventAPI.NetWorkConnectHealthly = "NetWorkConnectHealthly"

function EventAPI:ctor()
    self.oEvent=GEvent.new()
end
--[[
@desc:注册网络消息接口
@param nCmd{number} 网络消息Id
@param onCallBack{Function} 回调函数 函数格式：onCallBack(nCmd,data)
@return nHandle{number}
--]]
function EventAPI:addNetEvent(nCmd, onCallBack)
    return SocketManager.getInstance():AddObserver(nCmd, nil, onCallBack)
end

--[[
@desc:取消网络消息接口
@param nHandle{number}
--]]
function EventAPI:removeNetEvent(nHandle)
    return SocketManager.getInstance():RemoveObserver(nHandle)
end

--[[
@desc:注册全局事件
@param sEvent{string} 事件名字
@param onCallBack{Function} 回调函数 函数格式，onCallBack(...)
@return nHandle{number}
--]]
function EventAPI:addEvent(sEvent, onCallBack)
    return self.oEvent:addEventListener(sEvent,onCallBack)
end

--[[
@desc:取消全局事件
@param nHandle{number}
--]]
function EventAPI:removeEvent(nHandle)
   self.oEvent:removeEventListener(nHandle)
end


--[[
@desc:判断事件是否监听
@param nHandle{number}
--]]
function EventAPI:hasEvent(nHandle)
   return self.oEvent:hasEventListener(nHandle)
end
--[[
@desc:发送全局事件
@param sEvent{string} 事件
@param data{table} 不定参数，自由发挥
--]]
function EventAPI:dispatchEvent(sEvent, ...)
    -- body
    self.oEvent:dispatchEvent(sEvent, ...)
end

return EventAPI
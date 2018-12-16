-------------------------------------------------------------------------
-- Desc:   扑克牌框架包装调度
-- Last: 
-- Author:   diyal.yin
-- Content:  模块消息到逻辑类的调度
-- 2017-11-04  新建
-------------------------------------------------------------------------
local Facade = class("Facade")

Facade.instance = nil

function Facade:getInstance()
    if not Facade.instance then
        Facade.instance = Facade.new()
    end
    return Facade.instance
end

function Facade:release()
    if Facade.instance then
    	Facade:finalizer()
    	Facade.instance = nil
    end
end

function Facade:ctor()
	-- body
	self:init()
end

function Facade:init()
	self._eventDispatcher = cc.EventDispatcher:new()
	assert(self._eventDispatcher)
	self._eventDispatcher:retain()
	self:setEventDispatcherEnabled(true)
end

function Facade:getEventDispatcher()
	assert(self._eventDispatcher)
	return self._eventDispatcher;
end

function Facade:setEventDispatcherEnabled(enabled)
	assert(type(enabled) == "boolean")
	self:getEventDispatcher():setEnabled(enabled)
end

-- 添加自定义的事件监听器
-- @param eventName - 事件名
-- @param eventCallback - 事件回调
function Facade:addCustomEventListener(eventName, eventCallback)
	assert(type(eventName) == "string" and type(eventCallback) == "function")
	if string.len(eventName) == 0 then
		Log.i("<Facade | registerEvent -- eventName is empty.")

		return
	end

	local listener = cc.EventListenerCustom:create(eventName, eventCallback)
	self:getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

	return listener
end

-- 移除事件监听器
-- @param eventListener
function Facade:removeEventListener(eventListener)
	-- body
	if not iskindof(eventListener, "cc.EventListener") then
		Log.i("<Facade | addEventListener - argument(eventListener) is not kind of cc.EventListener")

		return
	end

	self:getEventDispatcher():removeEventListener(eventListener)
end

-- 派发自定义事件
function Facade:dispatchCustomEvent(eventName, ...)
	-- body
	assert(type(eventName) == "string")
	local event = cc.EventCustom:new(eventName)
	event._userdata = {...}
	event._eventName = eventName

   	self:getEventDispatcher():dispatchEvent(event)
end

-- 伪构造函数
function Facade:finalizer()
	self._eventDispatcher:release()
end

return Facade
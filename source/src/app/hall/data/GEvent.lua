
local GEvent = class("GEvent")

local EVENT_DEBUG = 0
--封装在内部的ID
local nListenerHandleIndex=0

function GEvent:ctor()
    self:__init();
end

function GEvent:__init()
    self.listeners = {}
    self.isDebug=false
    if EVENT_DEBUG>0 then
        self.checkEventData={};
    end
end


function GEvent:addEventListener(eventName, listener, tag)
    if not (type(eventName) == "string" and eventName ~= "") then
       eventName=tostring(eventName);
    end
    if self.listeners[eventName] == nil then
        self.listeners[eventName] = {}
    end

    nListenerHandleIndex = nListenerHandleIndex + 1
    local handle = nListenerHandleIndex
    tag = tag or ""
    if EVENT_DEBUG>0 then
        self.checkEventData[handle]=eventName;
    end
    self.listeners[eventName][handle] = {listener, tag}

    return  handle
end


--为了个别模块需要利用错误码来处理逻辑，所以增加一个不定参数
--commit by VindyLeong
function GEvent:dispatchEvent(eventName, ...)
    Log.i("*******************************************dispatchEvent1")
    if not (type(eventName) == "string" and eventName ~= "") then
       eventName=tostring(eventName);
    end

    local listeners=self.listeners[eventName]

    if listeners == nil then
        return
    end

    for handle, listener in pairs(listeners) do
        if listener and  listener[1] then
            listener[1](...)
        else
            Log.i("listener is nil eventName:",eventName);
            listeners[handle]=nil;
        end
    end

end


--发送事件
--为了个别模块需要利用错误码来处理逻辑，所以增加一个不定参数
--commit by VindyLeong
function GEvent:dispathEventWith(eventName, ...)
    self:dispatchEvent(eventName, ...)
end

function GEvent:removeEventFast(eventName,handleToRemove)
    if not (type(eventName) == "string" and eventName ~= "") then
       eventName=tostring(eventName);
    end
    local tb = self.listeners[eventName]
    if tb then
        tb[handleToRemove] = nil
    end
end

function GEvent:removeEventListener(handleToRemove)
    local isFound=false
    for eventName, listenersForGEvent in pairs(self.listeners) do
        for handle, _ in pairs(listenersForGEvent) do
            if handle == handleToRemove then
                if EVENT_DEBUG > 1 then
                    printInfo("[GEvent] removeEventListener() - remove listener [%s] for GEvent %s", handle, eventName)
                end
                if EVENT_DEBUG > 0 then
                    local checkName=self.checkEventData[handle];
                    if checkName and checkName~=eventName then
                        assert(false);
                    end
                end
                --self.listeners[eventName][handle] = nil
                listenersForGEvent[handle] = nil
                -- if self.isDebug then
                --     print("handle has been remove:"..handle);
                -- end
                isFound=true
                break
            end
        end
        if isFound then
            break
        end
    end

end

function GEvent:removeEventListenersByTag(tagToRemove)
    for eventName, listenersForGEvent in pairs(self.listeners) do
        for handle, listener in pairs(listenersForGEvent) do
            -- listener[1] = listener
            -- listener[2] = tag
            if listener[2] == tagToRemove then
                listenersForGEvent[handle] = nil
                -- if EVENT_DEBUG > 1 then
                --     printInfo("%s [GEvent] removeEventListener() - remove listener [%s] for GEvent %s", tostring(self.target_), handle, eventName)
                -- end
            end
        end
    end

end

function GEvent:removeEventListenersByName(eventName)
    if EVENT_DEBUG > 1 then
        printInfo("%s [GEvent] removeAllEventListenersForGEvent() - remove all listeners for GEvent %s", tostring(self.target_), eventName)
    end
end

function GEvent:removeAllEventListeners()
    self.listeners = {}
    if EVENT_DEBUG > 1 then
        printInfo("%s [GEvent] removeAllEventListeners() - remove all listeners", tostring(self.target_))
    end
end

function GEvent:hasEventListener(eventName)
    if not (type(eventName) == "string" and eventName ~= "") then
       eventName=tostring(eventName);
    end
    local t = self.listeners[eventName]

    if not t then return false end
    for _, __ in pairs(t) do
        return true
    end
    return false
end

function GEvent:DumpAllEventListeners()
    print("---- GEvent:dumpAllEventListeners() ----")
    for name, listeners in pairs(self.listeners) do
        printf("-- GEvent: %s", name)
        for handle, listener in pairs(listeners) do
            printf("--     listener: %s, handle: %s", tostring(listener[1]), tostring(handle))
        end
    end
end

return GEvent

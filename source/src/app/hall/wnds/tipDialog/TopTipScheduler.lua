
local LocalEvent = require("app.hall.common.LocalEvent")

local TopTipScheduler = class("TopTipScheduler")

local EventType = {
    Notify = 1,
    CantEnterRoom = 2,
}

local _instance = nil

function TopTipScheduler:getInstance()
    if not _instance then
        _instance = TopTipScheduler.new()
    end
    return _instance
end

function TopTipScheduler:releaseInstance()
    _instance = nil
end

function TopTipScheduler:ctor(serverData)
    self.m_handles = {}
end

function TopTipScheduler:resetAllHandles(pauseTopTip)
    self:stopAllHandles()
    if pauseTopTip then return end -- 暂停提示
    local serverData = kServerInfo:getServerNotifyData()
    -- dump(serverData)
    if not serverData or serverData.gameStatus == "online" or not serverData.gameUpgradeTime then return end

    local updateTime = tonumber(serverData.gameUpgradeTime)
    if not updateTime then return end -- 获取不到时间

    local nowTime = kServerInfo:getServerTime() / 1000
    local formatUpgradeTime = os.date("*t", updateTime)
    print(string.format("服务器维护时间: %d月%d日%d时%02d分", formatUpgradeTime.month, formatUpgradeTime.day, formatUpgradeTime.hour, formatUpgradeTime.min))
    local formatNowTime = os.date("*t", nowTime)
    print(string.format("客户端当前时间: %d月%d日%d时%02d分", formatNowTime.month, formatNowTime.day, formatNowTime.hour, formatNowTime.min))

    local remainTime = updateTime - nowTime -- 剩余多久维护
    if remainTime < 0 then return end -- 维护时间已过
    self:startHandleTopTip(serverData, remainTime)
    self:startHandleCantEnterRoomTime(serverData, remainTime)
end

function TopTipScheduler:startHandleTopTip(serverData, remainTime)
    local timeToNextNotice = remainTime -- 截止下一次通知的时间, 若已过一条通知的时间, 且距离下一条通知的时间超过60秒, 则补发一次通知
    local passedNotice = false
    if type(serverData.gameMessage.messageRule) ~= "table" then return end -- 倒计时配置有问题
    for i, v in ipairs(serverData.gameMessage.messageRule) do
        local countdown = tonumber(v) * 60
        local delayTime = remainTime - countdown
        if delayTime > 0 then
            local eventData = {}
            eventData.content = serverData.gameMessage.updateMessage
            eventData.countdown = tonumber(v)
            table.insert(self.m_handles, self:createHandle(delayTime, eventData, EventType.Notify))
        end
        if countdown > remainTime then -- 已过通知的时间
            passedNotice = true
        else
            timeToNextNotice = delayTime < timeToNextNotice and delayTime or timeToNextNotice
        end
    end
    Log.i("timeToNextNotice", timeToNextNotice)
    if passedNotice and timeToNextNotice > 0 then -- 立即推送一条消息
        local eventData = {}
        eventData.content = serverData.gameMessage.updateMessage
        eventData.countdown = math.floor(remainTime / 60)
        table.insert(self.m_handles, self:createHandle(0, eventData, EventType.Notify))
    end
end

function TopTipScheduler:startHandleCantEnterRoomTime(serverData, remainTime)
    -- 禁止创建或加入房间
    local cantEnterRoomTime = tonumber(serverData.gameCloseRoomTime)
    Log.i("cantEnterRoomTime", cantEnterRoomTime)
    if not cantEnterRoomTime then cantEnterRoomTime = 15 end -- 默认提前15分钟禁止进入
    if cantEnterRoomTime and cantEnterRoomTime > 0 then
        local delayTime = remainTime - cantEnterRoomTime * 60
        local eventData = clone(serverData.gameNotify)
        eventData.cantEnter = true
        table.insert(self.m_handles, self:createHandle(delayTime, eventData, EventType.CantEnterRoom))
    end
end

function TopTipScheduler:stopAllHandles()
    table.walk(
        self.m_handles,
        function(handle)
            scheduler.unscheduleGlobal(handle)
        end)
    self.m_handles = {}
    -- 重置
    kServerInfo:setCantEnterRoom({cantEnter = false})
end

function TopTipScheduler:createHandle(delayTime, eventData, eventType)
    local handle = scheduler.performWithDelayGlobal(function()
            if eventType == EventType.Notify then
                kServerInfo:showServerNotice(eventData)
            elseif eventType == EventType.CantEnterRoom then
                kServerInfo:setCantEnterRoom(eventData)
            end
        end, 
        delayTime)
    return handle
end

function TopTipScheduler:jiaoyanData()
end

return TopTipScheduler
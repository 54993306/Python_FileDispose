--礼包UI数据
--achive1 任务当前进度1
--achive2 任务当前进度1
--achive3 任务当前进度1
UserData_giftInfo = class("UserData_giftInfo", UserData_base);

UserData_giftInfo.getInstance = function()
    if not UserData_giftInfo.s_instance then
        UserData_giftInfo.s_instance = UserData_giftInfo.new();
    end

    return UserData_giftInfo.s_instance;
end

UserData_giftInfo.releaseInstance = function()
    if UserData_giftInfo.s_instance then
        UserData_giftInfo.s_instance:dtor();
    end
    UserData_giftInfo.s_instance = nil;
end

function UserData_giftInfo:ctor()
    self.super.ctor(self);
    self.m_onLineTime=0;
end

function UserData_giftInfo:dtor()
    if(self.m_timerProxy~=nil) then
        self.m_timerProxy:finalizer()
        self.m_timerProxy:removeTimer("onLine_duration_timer")
        self.m_timerProxy=nil
    end
end

function UserData_giftInfo:checkHasCanGetGift()
    for k, v in pairs(self.m_userData) do
        if v.status == 1 then
            return true;
        end
    end
end

function UserData_giftInfo:getNewerGiftId()
    return self.m_newGiftId;
end

function UserData_giftInfo:getLoginGiftId()
    return self.m_loginGiftId;
end

function UserData_giftInfo:getLoginGiftInfo()
    return self.m_loginGiftInfo;
end

function UserData_giftInfo:checkIsNewer()
    for k, v in pairs(self.m_userData) do
        local baseInfo =kHallGiftInfo:getGiftBaseInfo(v.questId);
        if baseInfo and v.status == 1 and baseInfo.quT == 14 then
            self.m_newGiftId = v.questId;
            return true;
        end
    end
end

function UserData_giftInfo:checkLoginGift()
    for k, v in pairs(self.m_userData) do
        local baseInfo =kHallGiftInfo:getGiftBaseInfo(v.questId);
        if baseInfo and v.status == 1 and baseInfo.quT == 16 then
            self.m_loginGiftId = v.keyID;
            self.m_loginGiftInfo = baseInfo;
            return true;
        end
    end
end

function UserData_giftInfo:getShareGift()
    for k, v in pairs(self.m_userData) do
        local baseInfo =kHallGiftInfo:getGiftBaseInfo(v.questId);
        if baseInfo and baseInfo.quT == 15 then
            self.m_shareGiftId = v.keyID;
            return baseInfo;
        end
    end
end

function UserData_giftInfo:getShareGiftKeyId()
    return self.m_shareGiftId;
end

function UserData_giftInfo:getOnLineTime()
    return self.m_onLineTime
end

-- 根据任务id获取任务数据
function UserData_giftInfo:getTaskByID(id)
    for _,data in pairs(self.m_userData) do
        if data.questId == id then
            return data
        end
    end
    return {}
end

-- 在线时长任务
function UserData_giftInfo:checkOnLineDuration()
    for k, v in pairs(self.m_userData) do
        local baseInfo =kHallGiftInfo:getGiftBaseInfo(v.questId);
        if(baseInfo.quT == GiftTaskTypeEnum.onLine_duration_type) then
        
            --如果当前用户更换账号再进行游戏，要把之前账号的任务定时器关闭重新计时
            if(self.m_currentUserID~=nil and self.m_currentUserID~=kUserInfo:getUserId()) then
                Log.i("当前用户更换账号再进行游戏,任务定时器关闭重新计时")
                if(self.m_timerProxy~=nil) then         
                    self.m_timerProxy:finalizer()
                    self.m_timerProxy:removeTimer("onLine_duration_timer")
                    self.m_timerProxy=nil
                end
                self.m_currentUserID = kUserInfo:getUserId()
            else
                self.m_currentUserID = kUserInfo:getUserId()
            end
        
        
            --时间任务只能有一个能运行,必要条件是前置任务要完成
            local isFinish=false
            if(baseInfo.prQI>0) then
                local isret = kHallGiftInfo:isFinishTask(baseInfo.prQI);
                isFinish =isret
            else
                isFinish =true           
            end

            if(isFinish and v.status==0 and self.m_timerProxy==nil) then --
            
                self.m_onLineTime = v.achive1 -- 在线时长
                Log.i("在线时长任务,当前在线时间：",self.m_onLineTime)
                local function updateTimeVar()
                    if(self.m_onLineTime<baseInfo.co*60) then
                        self.m_onLineTime = self.m_onLineTime+1
                    else
                        --告诉服务器任务完成
                        self.m_timerProxy:finalizer()
                        self.m_timerProxy:removeTimer("onLine_duration_timer")
                        self.m_timerProxy=nil
                        
                        local tmpData={};
                        tmpData.quI=v.questId
                        HallGiftSocketProcesser.sendTaskFinish(tmpData)
                    end
                end
                
                if not IsPortrait then -- TODO
                    if(self.m_timerProxy==nil) then
                        self.m_timerProxy = require "app.common.TimerProxy".new()
                        self.m_timerProxy:addTimer("onLine_duration_timer", updateTimeVar, 1,-1)
                    end
                end
            end
        end
    end
end
kGiftData_logicInfo = UserData_giftInfo.getInstance();

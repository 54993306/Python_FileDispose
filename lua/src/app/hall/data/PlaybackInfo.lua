--玩家数据

PlaybackInfo = class("PlaybackInfo");

PlaybackInfo.getInstance = function()
    if not PlaybackInfo.s_instance then
        PlaybackInfo.s_instance = PlaybackInfo.new();
    end

    return PlaybackInfo.s_instance;
end

PlaybackInfo.releaseInstance = function()
    if PlaybackInfo.s_instance then
        PlaybackInfo.s_instance:dtor();
    end
    PlaybackInfo.s_instance = nil;
end

function PlaybackInfo:ctor()
    self.m_playbackInfo     = {}
    self.m_startGameInfo    = {}
    self.currentGamesNum    = 0     -- 当前局数
    self.speedDelay         = 10 
    self.actions            = {}    -- 操作
    self.returnVideo        = false -- 
    self.m_startddzGameInfo = {}
    self.ddzGetStartCount = 0
end

function PlaybackInfo:dtor()

end

function PlaybackInfo:setPlaybackData(data)
    self.m_playbackInfo = data
end

function PlaybackInfo:getPlaybackData()
    return self.m_playbackInfo or {}
end

function PlaybackInfo:setStartGameData(data)
    self.m_startGameInfo = data
end

function PlaybackInfo:getStartGameData()
    return self.m_startGameInfo
end

function PlaybackInfo:setddzStartGameData(data)
    self.m_startddzGameInfo = data
end

function PlaybackInfo:getddzStartGameData()
    return self.m_startddzGameInfo
end
--[[
-- @brief  通过用户id获取玩家内容函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:getStartGameContentByid(userid)
    if next(self.m_startddzGameInfo) then
        self:setStartGameData(clone(self.m_startddzGameInfo[1]))
        self.ddzGetStartCount = self.ddzGetStartCount + 1
        if self.ddzGetStartCount == 3 then
            table.remove(self.m_startddzGameInfo,1)
            self.ddzGetStartCount = 0
        end
    else
        self.ddzGetStartCount = 0
    end
    for k, v in pairs(self.m_startGameInfo) do
        if v.content.recUserId == userid then
            return v.content
        end
    end
end

function PlaybackInfo:getStartGameDataByUserid()
    
end

--[[
-- @brief  设置局数函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:setCurrentGamesNum(num)
   self.currentGamesNum = num
end
--[[
-- @brief  获取局数函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:getCurrentGamesNum()
    return self.currentGamesNum
end

--[[
-- @brief  设置返回地方函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:setVideoReturn(from)
   self.returnVideo = from
end
--[[
-- @brief  获取返回地方函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:getVideoReturn()
    return self.returnVideo
end

--[[
-- @brief  设置快进延时时间函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:setSpeedDelayTime(time)
   self.speedDelay = time
end
--[[
-- @brief  获取快进延时时间函数
-- @param  void
-- @return void
--]]
function PlaybackInfo:getSpeedDelayTime()
    return self.speedDelay
end

kPlaybackInfo = PlaybackInfo.getInstance();
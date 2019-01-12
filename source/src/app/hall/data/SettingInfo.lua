--设置信息

SettingInfo = class("SettingInfo");

SettingInfo.getInstance = function()
    if not SettingInfo.s_instance then
        SettingInfo.s_instance = SettingInfo.new();
    end

    return SettingInfo.s_instance;
end

SettingInfo.releaseInstance = function()
    if SettingInfo.s_instance then
        SettingInfo.s_instance:dtor();
    end
    SettingInfo.s_instance = nil;
end

SettingInfo.cleanup = function()
    SettingInfo.releaseInstance();
    kSettingInfo = SettingInfo.getInstance();
end

SettingInfo.ctor = function(self)
    self.m_gameSoundStatus = {};
    self.m_gameDsSoundStatus = {};
    self.m_SettingInfo = {};
end

SettingInfo.dtor = function(self)
    self.m_SettingInfo = {};
end

--大厅音乐
SettingInfo.getMusicStatus = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("music_status", true);
end

SettingInfo.setMusicStatus = function(self, musicStatus)
    cc.UserDefault:getInstance():setBoolForKey("music_status", musicStatus);
end

--大厅声音
SettingInfo.getSoundStatus = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("sound_status", true);
end

SettingInfo.setSoundStatus = function(self, soundStatus)
    cc.UserDefault:getInstance():setBoolForKey("sound_status", soundStatus);
end

--游戏音乐
SettingInfo.getGameMusicStatus = function(self, gamePath)
    return cc.UserDefault:getInstance():getBoolForKey((gamePath or "") .. "music_status", true);
end

SettingInfo.setGameMusicStatus = function(self, gamePath, soundStatus)
    cc.UserDefault:getInstance():setBoolForKey((gamePath or "") .. "music_status", soundStatus);
end

--音效
SettingInfo.getGameSoundStatus = function(self, gamePath)
    gamePath = gamePath or _gameAudioEffectPath;
    if not self.m_gameSoundStatus[gamePath] then
        self.m_gameSoundStatus[gamePath] = cc.UserDefault:getInstance():getBoolForKey(gamePath .. "sound_status", true)
    end
    return self.m_gameSoundStatus[gamePath];
end

SettingInfo.setGameSoundStatus = function(self, gamePath, soundStatus)
    gamePath = gamePath or _gameAudioEffectPath;
    self.m_gameSoundStatus[gamePath] = soundStatus;
    cc.UserDefault:getInstance():setBoolForKey(gamePath .. "sound_status", soundStatus);
end

--方言
SettingInfo.getGameDialectStatus = function(self)
    if IsPortrait then -- TODO
        if G_DEFAULT_DIALECT == nil then
            G_DEFAULT_DIALECT = false
        end
        return cc.UserDefault:getInstance():getBoolForKey("dialect_status", G_DEFAULT_DIALECT);
    else
        return cc.UserDefault:getInstance():getBoolForKey("dialect_status", false);
    end
end

SettingInfo.setGameDialectStatus = function(self, soundStatus)
    cc.UserDefault:getInstance():setBoolForKey("dialect_status", soundStatus);
end

-----------zcq 2016-09-23新增----------------------
-- 获取玩家语音
SettingInfo.getGameVoiceStatus = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("voice_status", false)
end

-- 设置玩家语音
SettingInfo.setGameVoiceStatus = function(self, voiceStatus)
    cc.UserDefault:getInstance():setBoolForKey("voice_status", voiceStatus);
end

--获取设置的玩家语音
SettingInfo.getPlayerVoiceStatus = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("playerVoice_status",false)
end
SettingInfo.setPlayerVoiceStatus = function(self,playerVoice)
    cc.UserDefault:getInstance():setBoolForKey("playerVoice_status",playerVoice)
end
-- 获取音效大小
SettingInfo.getGameSoundValue = function(self)
    return cc.UserDefault:getInstance():getFloatForKey("sound_value", 50)
end

-- 设置音效大小
SettingInfo.setGameSoundValue = function(self, soundValue)
    cc.UserDefault:getInstance():setFloatForKey("sound_value", soundValue);
end

-- 获取音乐大小
SettingInfo.getGameMusicValue = function(self)
    return cc.UserDefault:getInstance():getFloatForKey("music_value", 50)
end

-- 设置音乐大小
SettingInfo.setGameMusicValue = function(self, musicValue)
    cc.UserDefault:getInstance():setFloatForKey("music_value", musicValue)
end

if IsPortrait then -- TODO
-- 获取推荐游戏id
SettingInfo.getRecommendID = function(self)
    return cc.UserDefault:getInstance():getFloatForKey("RecommendID", 0)
end

-- 设置推荐游戏id
SettingInfo.setRecommendID = function(self, id)
    if SettingInfo.getInstance():getRecommendID() == id then return end
    local tab = kFriendRoomInfo:getAreaAndCommon()   -- 如果玩法在通用玩法或选择的地区玩法中，则不记录
    for _,v in pairs(tab) do
        if id == v then
            return 
        end
    end
    cc.UserDefault:getInstance():setFloatForKey("RecommendID", id)
    cc.UserDefault:getInstance():flush()
end
end

-- 获取选择地区的游戏id
SettingInfo.getSelectAreaGameID = function(self)
    return cc.UserDefault:getInstance():getFloatForKey("SelectAreaGameID", 0)
end

-- 设置选择地区的游戏id
SettingInfo.setSelectAreaGameID = function(self, musicValue)
    if SettingInfo.getInstance():getSelectAreaGameID() == musicValue then return end
    cc.UserDefault:getInstance():setFloatForKey("SelectAreaGameID", musicValue)
    cc.UserDefault:getInstance():flush()
    if IsPortrait then -- TODO
        SettingInfo.getInstance():setRecommendID(musicValue)
    end
end

-- 获取选择地区的地区id
SettingInfo.getSelectAreaPlaceID = function(self)
    return cc.UserDefault:getInstance():getIntegerForKey("IntSelectAreaPlaceID", 0)
end

-- 设置选择地区的地区id
SettingInfo.setSelectAreaPlaceID = function(self, PlaceID)
    if SettingInfo.getInstance():getSelectAreaPlaceID() == PlaceID then return end
    cc.UserDefault:getInstance():setIntegerForKey("IntSelectAreaPlaceID", PlaceID)
    cc.UserDefault:getInstance():flush()
    if IsPortrait then -- TODO
        kFriendRoomInfo:initAreaAndCommon(PlaceID)
    end
end

--设置亲友圈引导是否弹出
SettingInfo.setClubGuidance = function(self,boolean)
    cc.UserDefault:getInstance():setBoolForKey("guidance",boolean)
    cc.UserDefault:getInstance():flush()
end
--获取亲友圈引导是否弹出
SettingInfo.getClubGuidance = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("guidance",false)
end

--设置斗地主引导状态
SettingInfo.setDDZGuidanceStatus = function(self, guidance_status)
    cc.UserDefault:getInstance():setIntegerForKey("pdk_guidance_status", guidance_status)
    cc.UserDefault:getInstance():flush()
end
--获取斗地主引导状态
SettingInfo.getDDZGuidanceStatus = function(self)
    return cc.UserDefault:getInstance():getIntegerForKey("pdk_guidance_status", 0)
end

------------------------------------------------
--单点
SettingInfo.getGameSingleStatus = function(self, gamePath)
    return cc.UserDefault:getInstance():getBoolForKey(gamePath .. "single_status", false);
end

SettingInfo.setGameSingleStatus = function(self, gamePath, soundStatus)
    gamePath = gamePath or _gameAudioEffectPath;
    cc.UserDefault:getInstance():setBoolForKey((gamePath or "") .. "single_status", soundStatus);
    cc.UserDefault:getInstance():flush()
end

--获取玩家震动
SettingInfo.getGameVibrationStatus = function(self)
    return cc.UserDefault:getInstance():getBoolForKey("vibration_status",true);
end
--设置玩家震动
SettingInfo.setGameVibrationStatus = function(self,vibration)
    cc.UserDefault:getInstance():setBoolForKey("vibration_status",vibration);
    cc.UserDefault:getInstance():flush()
end

--配音
SettingInfo.getGameDubStatus = function(self, gamePath)
    gamePath = gamePath or _gameAudioEffectPath;
    return cc.UserDefault:getInstance():getBoolForKey((gamePath or "") .. "Dub_status", true);
end

SettingInfo.setGameDubStatus = function(self, gamePath, soundStatus)
    gamePath = gamePath or _gameAudioEffectPath;
    cc.UserDefault:getInstance():setBoolForKey(gamePath .. "Dub_status", soundStatus);
    cc.UserDefault:getInstance():flush()
end

--大圣特殊配音
SettingInfo.getGameDsDubStatus = function(self, gamePath)
    gamePath = gamePath or _gameAudioEffectPath;
    local dv = true;
    if kUserInfo:getUserSex() == 1 then
        dv = false;
    end
    if not self.m_gameDsSoundStatus[gamePath] then
        self.m_gameDsSoundStatus[gamePath] = cc.UserDefault:getInstance():getBoolForKey(gamePath or "" .. "DsDub_status", dv)
    end
    return self.m_gameDsSoundStatus[gamePath];
end

SettingInfo.setGameDsDubStatus = function(self, gamePath, soundStatus)
    gamePath = gamePath or _gameAudioEffectPath;
    self.m_gameDsSoundStatus[gamePath] = soundStatus;
    cc.UserDefault:getInstance():setBoolForKey(gamePath or "" .. "DsDub_status", soundStatus);
end

kSettingInfo = SettingInfo.getInstance();

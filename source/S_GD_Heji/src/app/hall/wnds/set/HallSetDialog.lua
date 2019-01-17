-------------------------------------------------------------
--  @file   HallSetDialog.lua
--  @brief  设置对话框
--  @author Linxiancheng
--  @DateTime:2016-09-21 15:11:13
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

HallSetDialog = class("HallSetDialog", UIWndBase)
local UmengClickEvent = require("app.common.UmengClickEvent")

-- HallSetDialog = class("HallSetDialog", function ()
--     local layer = display.newLayer()
--     layer:setTouchEnabled(true)
--     layer:setTouchSwallowEnabled(true)
--     return layer
-- end)

-- 按钮开关
local kBtnType = {
    ON  = 0, -- 开
    OFF = 1, -- 关
}

-- 按钮开关
local filename = ""-- 文件名
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function HallSetDialog:ctor(openId)
    if IsPortrait then -- TODO
        self.super.ctor(self, "hall/set_dialog_hall.csb", openId);
    else
        self.super.ctor(self, "hall/set_dialog_game.csb", openId);
    end
    self.baseShowType = UIWndBase.BaseShowType.RTOL
    self.openId = openId or 1
    self.m_isMusic = false
end

--[[
-- @brief  创建声音相关函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.m_content_Panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"content_Panel")
    self.exitBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "out_Button");
    self.exitBtn:addTouchEventListener(handler(self, self.onClickButton));
    if self.openId == 2 then
       self.exitBtn:setVisible(false)
    end

    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "close_btn");
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));
    if IsPortrait then -- TODO
        self.yesBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_yes");
        self.yesBtn:addTouchEventListener(handler(self, self.onClickButton));
    end

    local audio_Panel = ccui.Helper:seekWidgetByName(self.m_content_Panel,"audio_Panel")
   -- 声音相关
    self:createSoundPanel(audio_Panel)
    self:setMusicPanel(audio_Panel)

    self:onSelectPanel()

    --游戏帮助
    self.m_helpGame = ccui.Helper:seekWidgetByName(self.m_pWidget,"help_Image")
    self.m_helpGame:addTouchEventListener(handler(self,self.onClickButton))

    self.ver  = ccui.Helper:seekWidgetByName(self.m_pWidget, "Ver")
    if IsPortrait then -- TODO
        self.ver:getLayoutParameter():setMargin({ left = 456, top = 623})
        self.ver:setString(tostring("Ver:"..VERSION))
    else
        self.ver:setString(tostring("Ver"..VERSION))
    end
end
--[[
-- @brief  创建声音相关函数
-- @param  void
-- @return void
--]]
function HallSetDialog:createSoundPanel(audio_Panel)
    local sound_Panel = ccui.Helper:seekWidgetByName(audio_Panel,"sound_Panel")
    self.soundSlider  = ccui.Helper:seekWidgetByName(sound_Panel, "slider")
    self.soundSlider:setPercent(SettingInfo.getInstance():getGameSoundValue())

    local sound_on_off = ccui.Helper:seekWidgetByName(audio_Panel,"sound_on_off")
    sound_on_off:setSelected(SettingInfo.getInstance():getSoundStatus())
    sound_on_off:addTouchEventListener(function(obj, event)
        
        if event == ccui.TouchEventType.ended then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameCloseEffect)
            SoundManager.playEffect("btn");
            if not sound_on_off:isSelected() then
                audio.resumeAllSounds()
                SettingInfo.getInstance():setSoundStatus(true)
                self.soundSlider:setPercent(50)
                SettingInfo.getInstance():setGameSoundValue(50)
                -- 设置音效音量
                audio.setSoundsVolume(50 / 80)
                local img= "hall/huanpi2/set/btn_a_on.png"
                self.soundSlider:loadSlidBallTextures(img,img,img) 

            else
                audio.stopAllSounds()
                SettingInfo.getInstance():setSoundStatus(false)
                self.soundSlider:setPercent(5)
                SettingInfo.getInstance():setGameSoundValue(0)
                -- 设置音效最小
                audio.setSoundsVolume(0)
            end
        end
    end)
    local function soundVolume()
        if self.soundSlider:getPercent() <= 5 then
            self.soundSlider:setPercent(5)
        elseif self.soundSlider:getPercent() >= 95 then
            self.soundSlider:setPercent(95)
        end
        SettingInfo.getInstance():setGameSoundValue(self.soundSlider:getPercent())
        -- 设置音效
        audio.setSoundsVolume(self.soundSlider:getPercent() / 80)
    end
    soundVolume()

    if self.soundSlider:getPercent() <= 5 then
        local img= "hall/huanpi2/set/btn_vol_unable.png"
        self.soundSlider:loadSlidBallTextures(img,img,img)       
    end

    self.soundSlider:addEventListener(function(mWidget, sliderType)
        if mWidget:getPercent() <= 5  then

            SettingInfo.getInstance():setSoundStatus(false)
            mWidget:setPercent(5)
            sound_on_off:setSelected(false)

            local img= "hall/huanpi2/set/btn_vol_unable.png"
            mWidget:loadSlidBallTextures(img,img,img)
        elseif mWidget:getPercent() > 5  then

            SettingInfo.getInstance():setSoundStatus(true)
            sound_on_off:setSelected(true)
            local img= "hall/huanpi2/set/btn_a_on.png"
            mWidget:loadSlidBallTextures(img,img,img)

            if mWidget:getPercent() >= 95 then
                mWidget:setPercent(95)
            end     
        end
        soundVolume()
    end)
end
function HallSetDialog:setMusicPanel(audio_Panel)
    --背景音乐设置  music_on_off
    local music_Panel = ccui.Helper:seekWidgetByName(audio_Panel,"music_Panel")
    self.musicSlider  = ccui.Helper:seekWidgetByName(music_Panel, "slider")
    self.musicSlider:setPercent(SettingInfo.getInstance():getGameMusicValue())
    local music_on_off = ccui.Helper:seekWidgetByName(music_Panel,"music_on_off")
    music_on_off:setSelected( self.musicSlider:getPercent() > 5 )
    music_on_off:addTouchEventListener(handler(self,function(panel,pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameCloseMusic)

            if not music_on_off:isSelected() then

                if self.openId == 2 then
                    audio.playMusic(_gameBgMusicPath, true)
                end
                SettingInfo.getInstance():setMusicStatus(true)
                SettingInfo.getInstance():setGameVoiceStatus(false)
                self.musicSlider:setPercent(50)
                SettingInfo.getInstance():setGameMusicValue(50)
                -- 设置音乐音量
                audio.setMusicVolume(50 / 80)
                self.m_isMusic = true
                local img= "hall/huanpi2/set/btn_a_on.png"
                self.musicSlider:loadSlidBallTextures(img,img,img) 
                
                return
            else
                audio.stopMusic()
                SettingInfo.getInstance():setMusicStatus(false)
                SettingInfo.getInstance():setGameVoiceStatus(true)
                self.musicSlider:setPercent(5)
                SettingInfo.getInstance():setGameMusicValue(0)
                -- 设置音乐最小
                audio.setMusicVolume(0)
                self.m_isMusic = false
                return
            end
        end
    end))
    local function musicVolume()
        if self.musicSlider:getPercent() <= 5 then
            self.musicSlider:setPercent(5)
        elseif self.musicSlider:getPercent() >= 95 then
            self.musicSlider:setPercent(95)
        end
        SettingInfo.getInstance():setGameMusicValue(self.musicSlider:getPercent())
        -- 设置音乐
        audio.setMusicVolume(self.musicSlider:getPercent() / 80)
    end
    musicVolume()

    if self.musicSlider:getPercent() <= 5 then
        local img= "hall/huanpi2/set/btn_vol_unable.png"
        self.musicSlider:loadSlidBallTextures(img,img,img)       
    end

    self.musicSlider:addEventListener(handler(self, function(panel,mWidget, sliderType)
        -- Log.i("audio.isMusicPlaying()...",self.m_isMusic)
        if mWidget:getPercent() <= 5  then
            SettingInfo.getInstance():setMusicStatus(false)
            SettingInfo.getInstance():setGameVoiceStatus(true)
            audio.pauseMusic()
            mWidget:setPercent(5)
            self.m_isMusic = false
            music_on_off:setSelected(false)

            local img= "hall/huanpi2/set/btn_vol_unable.png"
            mWidget:loadSlidBallTextures(img,img,img)

        else
            music_on_off:setSelected(true)
            SettingInfo.getInstance():setMusicStatus(true)
            SettingInfo.getInstance():setGameVoiceStatus(false)
            if self.openId == 2 and not self.m_isMusic then
                audio.playMusic(_gameBgMusicPath, true)
                self.m_isMusic = true
            end
            if mWidget:getPercent() >= 95 then
                mWidget:setPercent(95)
            end

            local img= "hall/huanpi2/set/btn_a_on.png"
            mWidget:loadSlidBallTextures(img,img,img)
        end
        musicVolume()
    end))
end
--选择层的设置
function HallSetDialog:onSelectPanel()
    --玩家语音
    local select_Panel = ccui.Helper:seekWidgetByName(self.m_content_Panel,"select_Panel")
    local voice_Panel = ccui.Helper:seekWidgetByName(select_Panel,"voice_Panel")
    local voic_CheckBox = ccui.Helper:seekWidgetByName(voice_Panel,"select_CheckBox")
    if IsPortrait then -- TODO
        local voice = SettingInfo.getInstance():getPlayerVoiceStatus()
        voic_CheckBox:setSelected(voice)
        voic_CheckBox:addTouchEventListener(function(obj, event)
            if event == ccui.TouchEventType.ended then
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameBanVoice)
                SettingInfo.getInstance():setPlayerVoiceStatus(not voic_CheckBox:isSelected())
            end
        end)
    else
        voic_CheckBox:setSelected(not SettingInfo.getInstance():getPlayerVoiceStatus())
        voic_CheckBox:addTouchEventListener(function(obj, event)
            if event == ccui.TouchEventType.ended then
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameBanVoice)
                SettingInfo.getInstance():setPlayerVoiceStatus(voic_CheckBox:isSelected())
            end
        end)
    end
    --普通话
    local mandarin_Panel = ccui.Helper:seekWidgetByName(select_Panel,"mandarin_Panel")
    local mandarin_CheckBox = ccui.Helper:seekWidgetByName(mandarin_Panel,"select_CheckBox")
    mandarin_CheckBox:setSelected(not SettingInfo.getInstance():getGameDialectStatus())
    --方言
    local dialect_Panel = ccui.Helper:seekWidgetByName(select_Panel,"dialect_Panel")
	if(_isShowDialect~=nil and _isShowDialect==false) then --不同游戏是否要显示方言
	   dialect_Panel:setVisible(false)
	   mandarin_Panel:setVisible(false)
       self.m_content_Panel:setPosition(cc.pAdd(cc.p(self.m_content_Panel:getPosition()),cc.p(0,50)))
       --设置一下其他控件的位置布局
	end

    local dialect_checkBox = ccui.Helper:seekWidgetByName(dialect_Panel,"select_CheckBox")
    dialect_checkBox:setSelected(SettingInfo.getInstance():getGameDialectStatus())

    mandarin_CheckBox:addTouchEventListener(function(obj,event)
        if event == ccui.TouchEventType.ended then
            SettingInfo.getInstance():setGameDialectStatus(mandarin_CheckBox:isSelected())
            dialect_checkBox:setSelected(mandarin_CheckBox:isSelected())
            if not mandarin_CheckBox:isSelected() then
                mandarin_CheckBox:setTouchEnabled(false)
                dialect_checkBox:setTouchEnabled(true)
            end
        end
    end)
    dialect_checkBox:addTouchEventListener(function(obj,event)
     if event == ccui.TouchEventType.ended then
            SettingInfo.getInstance():setGameDialectStatus(not dialect_checkBox:isSelected())
            mandarin_CheckBox:setSelected(dialect_checkBox:isSelected())
            if not dialect_checkBox:isSelected() then
                mandarin_CheckBox:setTouchEnabled(true)
                dialect_checkBox:setTouchEnabled(false)
            end
        end
    end)

    --震动
    local vibration_Panel = ccui.Helper:seekWidgetByName(select_Panel,"vibration_Panel")
    local vibration_checkBox = ccui.Helper:seekWidgetByName(vibration_Panel,"select_CheckBox")
    vibration_checkBox:setSelected(SettingInfo.getInstance():getGameVibrationStatus())
    vibration_checkBox:addTouchEventListener(function(obj,event)
        if event == ccui.TouchEventType.ended then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameVibrate)
            SettingInfo.getInstance():setGameVibrationStatus(not vibration_checkBox:isSelected())
        end
    end)
end

--[[
-- @brief  按钮回调函数
-- @param  void
-- @return void
--]]
function HallSetDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
         if pWidget == self.exitBtn then

             if self.openId == 1 then
                 -- 退出到登录
                 SocketManager.getInstance():closeSocket();
                 kLoginInfo:clearAccountInfo();
                 cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
                 cc.UserDefault:getInstance():setStringForKey("wx_name", "");
                 local info = {};
                 info.isExit = true;
                 UIManager.getInstance():replaceWnd(HallLogin, info);
             end
         elseif pWidget == self.closeBtn then
            UIManager:getInstance():popWnd(HallSetDialog)
        elseif IsPortrait and pWidget == self.yesBtn then -- TODO
            UIManager:getInstance():popWnd(HallSetDialog)
        elseif pWidget == self.m_helpGame then
            UIManager:getInstance():pushWnd(RuleDialog);
        end
    end
end

function HallSetDialog:keyBack()
    UIManager:getInstance():popWnd(HallSetDialog)
end
return HallSetDialog


local PokerRoomRuleView = require("package_src.games.pokercommon.widget.PokerRoomRuleView")
--local PokerSettingInfo = require("package_src.games.pokercommon.data.PokerSettingInfo")
local PokerRoomSettingView = class("PokerRoomSettingView",PokerUIWndBase)

local settingViewPath ="package_src.games.pokercommon.widget.PokerRoomSettingView"

function PokerRoomSettingView:ctor(data)
    self.super.ctor(self,"package_res/games/pokercommon/porker_setting_view.csb", data)
end

function PokerRoomSettingView:onInit()
    local root = ccui.Helper:seekWidgetByName(self.m_pWidget,"root")
    root:addTouchEventListener(handler(self,self.onClickButton))
    self.version = ccui.Helper:seekWidgetByName(self.m_pWidget,"version")
    if IsPortrait then
    	self.version:setString("VER".._gameVersion)
    else
    	self.version:setString("VER"..VERSION)
    	self.version:setFontSize(self.version:getFontSize()-4)
    end	
    local sound_panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"sound_panel")
    local music_panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"music_panel")
    self:initSoundPanel(sound_panel)
    self:initMusicPanel(music_panel)
end

function PokerRoomSettingView:onShow()
    
end

function PokerRoomSettingView:initSoundPanel(parent)
    self.sound_slider = ccui.Helper:seekWidgetByName(parent,"slider_sound")
    self.sound_slider:setPercent(HallAPI.SoundAPI:getSoundVolume())

    self.check_sound_btn = ccui.Helper:seekWidgetByName(parent,"check_sound_btn")
    self.soundNormal = ccui.Helper:seekWidgetByName(self.check_sound_btn,"normal")
    self.soundSelect = ccui.Helper:seekWidgetByName(self.check_sound_btn,"select")
    self.check_sound_btn:setTouchEnabled(true)
    self.soundIsSelect = self.sound_slider:getPercent() > 0 and true or  false

    if self.soundIsSelect then
        self.soundNormal:setVisible(true)
        self.soundSelect:setVisible(false)
    else
        self.soundNormal:setVisible(false)
        self.soundSelect:setVisible(true)
    end

    self.check_sound_btn:addTouchEventListener(handler(self,self.soundListeneter))

    local function soundVolume()
        if self.sound_slider:getPercent() <= 0 then
            self.sound_slider:setPercent(0)
        elseif self.sound_slider:getPercent() >= 100 then
            self.sound_slider:setPercent(100)
        end
        HallAPI.SoundAPI:setSoundVolume(self.sound_slider:getPercent())
    end
    soundVolume()

    self.sound_slider:addEventListener(function(mWidget, sliderType)
        if mWidget:getPercent() <= 0  then
            self.soundNormal:setVisible(false)
            self.soundSelect:setVisible(true)
            HallAPI.SoundAPI:setSoundMute(true)
            mWidget:setPercent(0)
        elseif mWidget:getPercent() > 0  then
            self.soundNormal:setVisible(true)
            self.soundSelect:setVisible(false)
            if mWidget:getPercent() >= 100 then
                mWidget:setPercent(100)
            end
            HallAPI.SoundAPI:setSoundMute(false)
        end
        soundVolume()
    end)
end

function PokerRoomSettingView:initMusicPanel(parent)
    self.music_slider = ccui.Helper:seekWidgetByName(parent,"slider_music")
    self.music_slider:setPercent(HallAPI.SoundAPI:getMusicVolume())
    self.check_music_btn = ccui.Helper:seekWidgetByName(parent,"check_music_btn")
    self.musicNormal = ccui.Helper:seekWidgetByName(self.check_music_btn,"normal")
    self.musicSelect = ccui.Helper:seekWidgetByName(self.check_music_btn,"select")
    self.check_music_btn:setTouchEnabled(true)
    self.musicIsSelect = self.music_slider:getPercent() > 0 and true or  false
    if self.musicIsSelect then
        self.musicNormal:setVisible(true)
        self.musicSelect:setVisible(false)
    else
        self.musicNormal:setVisible(false)
        self.musicSelect:setVisible(true)
    end

    self.check_music_btn:addTouchEventListener(handler(self,self.musicListeneter))
    
    local function musicVolume()
        if self.music_slider:getPercent() <= 0 then
            self.music_slider:setPercent(0)
        elseif self.music_slider:getPercent() >= 100 then
            self.music_slider:setPercent(100)
        end

        HallAPI.SoundAPI:setMusicVolume(self.music_slider:getPercent())
    end
    musicVolume()

    self.music_slider:addEventListener(function(mWidget, sliderType)
        if mWidget:getPercent() <= 0  then
            self.musicIsSelect = false
            mWidget:setPercent(0)
            HallAPI.SoundAPI:pauseMusic()
            HallAPI.SoundAPI:setMusicMute(true)
            HallAPI.SoundAPI:setGameVoiceStatus(true)
            self.musicNormal:setVisible(false)
            self.musicSelect:setVisible(true)
        elseif mWidget:getPercent() > 0  then
            self.musicIsSelect = true
            HallAPI.SoundAPI:setMusicMute(false)
            HallAPI.SoundAPI:setGameVoiceStatus(false)

            HallAPI.SoundAPI:resumeMusic()
            self.musicNormal:setVisible(true)
            self.musicSelect:setVisible(false)
            if mWidget:getPercent() >= 100 then
                mWidget:setPercent(100)
            end
        end
        musicVolume()
    end)
end

function PokerRoomSettingView:musicListeneter(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        HallAPI.SoundAPI:playSound("btn")
        self.musicIsSelect = not self.musicIsSelect
        if self.musicIsSelect then
            self.musicNormal:setVisible(true)
            self.musicSelect:setVisible(false)
            self.music_slider:setPercent(100)
            HallAPI.SoundAPI:setMusicMute(false)
            HallAPI.SoundAPI:setMusicVolume(80)
            audio.setMusicVolume(80 /100)

            HallAPI.SoundAPI:resumeMusic()
            HallAPI.SoundAPI:setGameVoiceStatus(false)
            
            self.m_isMusic = true
        else
            self.musicNormal:setVisible(false)
            self.musicSelect:setVisible(true)
            self.music_slider:setPercent(0)
            audio.setMusicVolume(0)

            HallAPI.SoundAPI:setGameVoiceStatus(true)
            HallAPI.SoundAPI:pauseMusic()
            HallAPI.SoundAPI:setMusicMute(true)
            HallAPI.SoundAPI:setMusicVolume(0)
            self.m_isMusic = false
        end
    end
    
end

function PokerRoomSettingView:soundListeneter(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        HallAPI.SoundAPI:playSound("btn")
        self.soundIsSelect = not self.soundIsSelect
        if EventType == ccui.TouchEventType.ended then
            HallAPI.SoundAPI:playSound("btn")
            if self.soundIsSelect then
                self.soundNormal:setVisible(true)
                self.soundSelect:setVisible(false)
                HallAPI.SoundAPI:setSoundMute(false)
                HallAPI.SoundAPI:setSoundVolume(80)
                audio.setSoundsVolume(80 /100)

                self.sound_slider:setPercent(100)
                return
            else
                self.soundNormal:setVisible(false)
                self.soundSelect:setVisible(true)
                HallAPI.SoundAPI:setSoundMute(true)
                HallAPI.SoundAPI:stopAllSounds()
                self.sound_slider:setPercent(0)
                HallAPI.SoundAPI:setSoundVolume(0)
                audio.setSoundsVolume(0)

                return
            end
        end
    end
end

function PokerRoomSettingView:setBtnState(btn,isSelected)
    local normal = ccui.Helper:seekWidgetByName(btn,"normal")
    local select = ccui.Helper:seekWidgetByName(btn,"select")
    if isSelected then
        normal:setVisible(true)
        select:setVisible(false)
    else
        normal:setVisible(false)
        select:setVisible(true)
    end
end

function PokerRoomSettingView:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerRoomSettingView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        self:keyBack();
    end
end
return PokerRoomSettingView
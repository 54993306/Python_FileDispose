--
-- Author: Machine
-- Date: 2017-11-30
-- 桌面點擊更多時的 退出和設置界面
--
-- 速配开始倒计时

if not IsPortrait then
	require("package_src.games.pokercommon.widget.PokerUIWndBase")
	require("package_src.games.pokercommon.widget.PokerUIManager")
	require("package_src.games.pokercommon.sound.PokerSoundPlayer")
	require("package_src.games.pokercommon.widget.PokerTouchCaptureView")
	local csvConfig = require("package_src.games.ddz.data.config_GameData")
	PokerSoundPlayer:setEffectCfg(csvConfig.musicList["effectpath"]["path"], csvConfig.musicList, csvConfig.musicList["bgpath"]["path"])

end

local DDZRoomView = require("package_src.games.ddz.mediator.widget.DDZRoomView")
local DDZMoreLayer = class("DDZMoreLayer", DDZRoomView);
local DDZGameEvent = require("package_src.games.ddz.data.DDZGameEvent")
local PokerRoomDialogView = require("package_src.games.pokercommon.widget.PokerRoomDialogView")
local PokerRoomSettingView = require("package_src.games.pokercommon.widget.PokerRoomSettingView")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local PokerRoomRuleView = require("package_src.games.pokercommon.widget.PokerRoomRuleView")
local UmengClickEvent = require("app.common.UmengClickEvent")


function DDZMoreLayer:initView()
	Log.i("DDZMoreLayer:initView()")
	if self.m_pWidget then
		Log.i("is excist")
	end
    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_setting");
    self.btn_setting:addTouchEventListener(handler(self, self.onClicked));

    self.btn_exit = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_exit");
    self.btn_exit:addTouchEventListener(handler(self, self.onClicked));

    self.btn_rule = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_rule");
    self.btn_rule:addTouchEventListener(handler(self, self.onClicked));

    self.m_pWidget:addTouchEventListener(handler(self, self.onClicked));
    self.m_pWidget:setEnabled(true)

end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function DDZMoreLayer:onClicked(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
    	-- kPokerSoundPlayer:playEffect("btn");
    	if pWidget == self.btn_setting then
    		Log.i("btn_setting ")
            PokerUIManager:getInstance():pushWnd(PokerRoomSettingView)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.DDZGameSetting)
    	elseif pWidget == self.btn_exit then
    		Log.i("btn_exit ")
            if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_JIESAN)
            else
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)
            end 
        elseif pWidget == self.btn_rule then
            Log.i("btn_rule ")
            local info = {}
            info.gamepath = "ddz"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView, info);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.DDZGameRuleButton)
    	end

    	self:onBack()
	end
end

------------------------------------------------
-- @desc 显示此界面
------------------------------------------------
function DDZMoreLayer:showshow()
	self.m_pWidget:setVisible(true)
end

------------------------------------------------
-- @desc 隐藏此界面
------------------------------------------------
function DDZMoreLayer:hidehide()
	self.m_pWidget:setVisible(false)
end

------------------------------------------------
-- @desc 去掉此界面
------------------------------------------------
function DDZMoreLayer:onBack()
	HallAPI.EventAPI:dispatchEvent(DDZGameEvent.HIDEMORELAYER)
	if not IsPortrait then
		self:hidehide()
	end
end

return DDZMoreLayer
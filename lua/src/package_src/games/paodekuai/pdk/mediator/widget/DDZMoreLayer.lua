--
-- Author: Machine
-- Date: 2017-11-30
-- 桌面點擊更多時的 退出和設置界面
--
-- 速配开始倒计时

local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZMoreLayer = class("DDZMoreLayer", DDZRoomView);
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local PokerRoomSettingView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomSettingView")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local PokerRoomRuleView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomRuleView")
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
    	kPokerSoundPlayer:playEffect("btn");
    	if pWidget == self.btn_setting then
    		Log.i("btn_setting ")
            PokerUIManager:getInstance():pushWnd(PokerRoomSettingView)
            NativeCallUmengEvent(UmengClickEvent.PDKGameSetting)
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
            info.gamepath = "paodekuai.pdk"
            PokerUIManager.getInstance():pushWnd(PokerRoomRuleView, info);
            NativeCallUmengEvent(UmengClickEvent.PDKGameRuleButton)
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
end

return DDZMoreLayer
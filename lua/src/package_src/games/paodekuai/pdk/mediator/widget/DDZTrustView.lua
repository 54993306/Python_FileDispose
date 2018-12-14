--
-- Author: Machine
-- Date: 2017-12-27
-- 斗地主托管界面
--
local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZTrustView = class("DDZTrustView", DDZRoomView)
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")


-----------------------------------------------
-- @desc 初始化ui
-----------------------------------------------
function DDZTrustView:initView()
	self.btn_canceltrust = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_canceltrust")
	self.btn_canceltrust:addTouchEventListener(handler(self, self.onClickButton));
	if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
		self:hide()
	end
end

-----------------------------------------------
-- @desc 处理点击事件
-- @pram pWidget:点击的控件, EventType:点击的类型
-----------------------------------------------
function DDZTrustView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
		if pWidget == self.btn_canceltrust then
			HallAPI.EventAPI:dispatchEvent( DDZGameEvent.REQTUOGUAN, DDZConst.TUOGUAN_STATE_0)
        end
    end
end


return DDZTrustView
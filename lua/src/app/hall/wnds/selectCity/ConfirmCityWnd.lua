--
-- Author: Nong Jinxia
-- Date: 2017-04-07 12:10:21
--
--选择地区二次确认界面

require("app.DebugHelper")
ConfirmCityWnd = class("ConfirmCityWnd", UIWndBase)

local function drawUnderline(node)
	local drawNode = cc.DrawNode:create()
	local color = node:getTextColor()
	local size = node:getContentSize()

	drawNode:drawLine(cc.p(0, 0), cc.p(size.width, 0), cc.c4f(0x27/0xff, 0x50/0xff, 0, 1))
	drawNode:setPosition(cc.p(0, 0))
	drawNode:setAnchorPoint(cc.p(0, 0))
	node:addChild(drawNode)
end

function ConfirmCityWnd:ctor(data, zorder, delegate)
	if IsPortrait then -- TODO
		zorder = 66
	end
	self.super.ctor(self, "hall/select_city_confirm_wnd.csb", data, zorder, delegate)
end

function ConfirmCityWnd:onInit()
	self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root")
	local cityName = ccui.Helper:seekWidgetByName(self.m_pWidget, "city_name")
	cityName:setString(self.m_data.city_name)

	local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg")
	local bgSize = bg:getContentSize()

	local x, y = cityName:getPosition()
	cityName:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.5))

	local tip = cityName:clone()
	tip:setFontSize(24)
	tip:setString("您选择的地区")
	tip:setPosition(cc.p(cityName:getPositionX(), cityName:getPositionY() + 80))
	-- cityName:getParent():addChild(tip)

	-- drawUnderline(cityName)

	local yesBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "yes")
	local noBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "no")
	local cancelBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_back")
	local noX, noY = noBtn:getPosition()
	noBtn:setPosition(cc.p(noX + 20, noY))
	yesBtn:addTouchEventListener(handler(self, self.onOK))
	noBtn:addTouchEventListener(handler(self, self.onCancel))
	cancelBtn:addTouchEventListener(handler(self, self.onCancel))
	if not IsPortrait then -- TODO
		local yesBtnPos,noBtnPos = noBtn:getLayoutParameter():getMargin(), yesBtn:getLayoutParameter():getMargin()
		yesBtn:getLayoutParameter():setMargin(yesBtnPos)
		noBtn:getLayoutParameter():setMargin(noBtnPos)
	end
end


function ConfirmCityWnd:onOK(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
		self:onKeyBack()
		if IsPortrait then -- TODO
			UIManager:getInstance():popWnd(SelectProvinceCityWnd);
		else
			UIManager:getInstance():popToWnd(HallMain);
		end
		HallSocketProcesser.sendSelectCity(self.m_data.reqData)
        SettingInfo.getInstance():setSelectAreaPlaceID(self.m_data.reqData.ciI)
        --Log.i("========================选择城市确认id",self.m_data.reqData.ciI)
		--SettingInfo.getInstance():setSelectAreaGameID(self.m_data.city_id)
		--kFriendRoomInfo:initRoomInfo();
	end
end

function ConfirmCityWnd:onCancel(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
		self:onKeyBack()
	end
end
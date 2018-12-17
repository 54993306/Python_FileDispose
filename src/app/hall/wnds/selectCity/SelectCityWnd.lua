--
-- Author: Nong Jinxia
-- Date: 2017-04-06 12:13:02
--

-- 选择地区界面

require("app.DebugHelper")

SelectCityWnd = class("SelectCityWnd", UIWndBase);

local widget_name = {
	-- "btn_close",
	"btn_back",
	"btn_yes",
}

function SelectCityWnd:ctor(data)
	self.super.ctor(self, "hall/select_city.csb", data)
	self.city_id = 0
end

function SelectCityWnd:onInit()
	self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root")
	for k,v in pairs(widget_name) do
		self[v] = ccui.Helper:seekWidgetByName(self.root, v)
	end
	
	self.root:addTouchEventListener(handler(self, self.onClick))
	self:btnCallBack()
end

function SelectCityWnd:btnCallBack(  )
	self.btn_back:addTouchEventListener(handler(self,self.onClickButton))
	self.btn_yes:addTouchEventListener(handler(self,self.onClickButton))
	self.btn_yes:setBright(false)
    self.btn_yes:setTouchEnabled(false)
end

function SelectCityWnd:onClickButton(pWidget, EventType)
	if EventType == ccui.TouchEventType.ended then
		SoundManager.playEffect("btn");
        if pWidget == self.btn_back then
            SocketManager.getInstance():closeSocket();
            kLoginInfo:clearAccountInfo();
            cc.UserDefault:getInstance():setStringForKey("refresh_token", "");
            cc.UserDefault:getInstance():setStringForKey("wx_name", "");
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
		elseif pWidget == self.btn_yes then
			if not self.city_name then
				Toast.getInstance():show("请选择所在地区")
			else
				UIManager:getInstance():pushWnd(ConfirmCityWnd, {city_name = self.city_name, reqData = {gaI = self.city_id} })
			end
		end
	end
end

function SelectCityWnd:onClick(pWidget, EventType)

end

function SelectCityWnd:onSelectButton(btn, EventType)

	if EventType == ccui.TouchEventType.ended then
		for k,v in pairs(self.city_btn) do
			if k == btn:getTag() then
				v.select:setBright(true)
			else
				v.select:setBright(false)
			end
			self.btn_yes:setBright(true)
            self.btn_yes:setTouchEnabled(true)
		end
		self.city_id = btn.gaID
		self.city_name = btn.text:getString()	
	end

end

function SelectCityWnd:onShow()
	local cityInfos = {}
	if _gameHideSelectCitys then
		for i,v in ipairs(self.m_data.ciL) do
			if not _gameHideSelectCitys[v.ciN] then
				cityInfos[#cityInfos + 1] = v
			end
		end
		if #cityInfos == 0 then
			cityInfos = self.m_data.ciL
		end
	else
		cityInfos = self.m_data.ciL
	end

	local len = math.ceil(#cityInfos / 4)

	local list = ccui.Helper:seekWidgetByName(self.m_pWidget, "city_list")
	list:setVisible(true)

	local kitem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/city_item.csb")
	local total = 0
	self.city_btn = {}
	for i = 1, len do
		local item = list:getItem(i)
		if item == nil then
			item = kitem:clone()
			for k = 1, 4, 1 do
				total = total + 1
				local btn = ccui.Helper:seekWidgetByName(item, "btn_" .. k)
				local text = ccui.Helper:seekWidgetByName(btn, "city_name")
				local btn_select = ccui.Helper:seekWidgetByName(btn, "btn_select")
				btn_select:setBright(false)

				btn.text = text 
				btn.select = btn_select				
				self.city_btn[#self.city_btn + 1] = btn
				if total <= #cityInfos then
					local cityInfo = cityInfos[total]
					text:setString(cityInfo.ciN)
					btn:setTag(total)
					btn.gaID = cityInfo.gaID
				else
					btn:setVisible(false)
				end
				
				btn:addTouchEventListener(handler(self, self.onSelectButton))
			end
			list:pushBackCustomItem(item)
		end
	end
end

function SelectCityWnd:onKeyBack()
end
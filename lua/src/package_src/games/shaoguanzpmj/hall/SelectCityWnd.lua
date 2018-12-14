--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CommonSelectCityWnd = require("app.hall.wnds.selectCity.SelectCityWnd")

SelectCityWnd = class("SelectCityWnd",CommonSelectCityWnd)

function SelectCityWnd:ctor(data)
    self.super.ctor(self.super,data)
end

function SelectCityWnd:onShow()
    local cityInfos = {{["ciN"] = "韶关",["gaID"] = 10102}}

	local len = math.ceil(#cityInfos / 3)

	local list = ccui.Helper:seekWidgetByName(self.m_pWidget, "city_list")
	list:setVisible(true)

	local kitem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/city_item.csb")
	local total = 0
	for i = 1, len do
		local item = list:getItem(i)
		if item == nil then
			item = kitem:clone()
			for k = 1, 3, 1 do
				total = total + 1
				local btn = ccui.Helper:seekWidgetByName(item, "btn" .. k)
				if total <= #cityInfos then
					local cityInfo = cityInfos[total]
					local text = ccui.Helper:seekWidgetByName(btn, "city_name")
					text:setString(cityInfo.ciN)
					btn:setTag(cityInfo.gaID)
				else
					btn:setVisible(false)
				end
				
				btn:addTouchEventListener(handler(self, self.onSelectButton))
			end
			list:pushBackCustomItem(item)
		end
	end
end

return SelectCityWnd
--endregion

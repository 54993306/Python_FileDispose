--
-- Author: Nong Jinxia
-- Date: 2017-04-06 12:13:02
--

-- 选择地区界面

require("app.DebugHelper")

local SelectProvinceCityWnd = class("SelectProvinceCityWnd", UIWndBase);

local widget_name = {
    "btn_back",
    "btn_county_back",
    "title",
    "select_desc",

    "panel_citys",
    "city_list",
    "btn_yes_city",
    "img_cityPrecent",

    "panel_county",
    "county_list",
    "btn_yes_county",
    "img_countyPrecent",
}

function SelectProvinceCityWnd:ctor(data)
    if IsPortrait then -- TODO
        self.super.ctor(self, "hall/select_province_city.csb", self:formatData(data),66)
    else
        self.super.ctor(self, "hall/select_province_city.csb", self:formatData(data))
    end
    self.city_id = 0
end

--[[
formatted = {
    provinceName = "广东省", 
    cityList = {
        {
            cityId = 1000, cityName = "韶关市",
            countyList = {
                { countyId = 11000, countyName = "韶关市区", gameList = { 200000,200001 } },
            }
        },
    }
}
]]
function SelectProvinceCityWnd:formatData(data)
    --[[local formatted = {
        provinceName = "广东省", 
        cityList = {
            {
                cityId = 1000, cityName = "韶关市",
                countyList = {
                    { countyId = 11000, countyName = "韶关市区", gameList = { 200000,200001 } },
                }
            },
            {
                cityId = 1100, cityName = "江门市",
                countyList = {
                    { countyId = 11100, countyName = "江门市区", gameList = { 200002,200003 } },
                    { countyId = 11101, countyName = "开平市", gameList = { 200004 } },
                }
            },
            {
                cityId = 1200, cityName = "茂名市",
                countyList = {
                    { countyId = 11200, countyName = "茂名市区", gameList = { 200005 } },
                    { countyId = 11201, countyName = "高州市", gameList = { 200006,200007 } },
                }
            },
            {
                cityId = 1300, cityName = "肇庆市",
                countyList = {
                    { countyId = 11300, countyName = "肇庆市区", gameList = { 200008 } },
                    { countyId = 11301, countyName = "怀集县", gameList = { 200009 } },
                }
            },
            {
                cityId = 1400, cityName = "云浮市",
                countyList = {
                    { countyId = 11400, countyName = "云浮市区", gameList = { 200010,200011,200012 } },
                }
            },
            {
                cityId = 1500, cityName = "河源市",
                countyList = {
                    { countyId = 11500, countyName = "河源市区", gameList = { 200013 } },
                }
            },
            {
                cityId = 1600, cityName = "梅州市",
                countyList = {
                    { countyId = 11600, countyName = "梅州市区", gameList = { 200014 } },
                }
            },
            {
                cityId = 1700, cityName = "惠州市",
                countyList = {
                    { countyId = 11700, countyName = "惠州市区", gameList = { 200015 } },
                }
            },
            {
                cityId = 1800, cityName = "汕头市",
                countyList = {
                    { countyId = 11800, countyName = "汕头市区", gameList = { 200016 } },
                }
            },
            {
                cityId = 1900, cityName = "湛江市",
                countyList = {
                    { countyId = 11900, countyName = "湛江市区", gameList = { 200017 } },
                    { countyId = 11901, countyName = "廉江市", gameList = { 200018 } },
                }
            },
            {
                cityId = 2000, cityName = "汕尾市",
                countyList = {
                    { countyId = 12000, countyName = "汕尾市区", gameList = { 200019 } },
                }
            },
            {
                cityId = 2100, cityName = "潮州市",
                countyList = {
                    { countyId = 12100, countyName = "潮州市区", gameList = { 200020 } },
                }
            },
            {
                cityId = 2200, cityName = "中山市",
                countyList = {
                    { countyId = 12200, countyName = "中山市区", gameList = { 200021 } },
                }
            },
            {
                cityId = 2300, cityName = "珠海市",
                countyList = {
                    { countyId = 12300, countyName = "珠海市区", gameList = { 200022 } },
                }
            },
            {
                cityId = 2400, cityName = "清远市",
                countyList = {
                    { countyId = 12400, countyName = "清远市区", gameList = { 200023,200024,200025 } },
                }
            },
            {
                cityId = 2500, cityName = "阳江市",
                countyList = {
                    { countyId = 12500, countyName = "阳江市区", gameList = { 200026,200027 } },
                }
            },
            {
                cityId = 2600, cityName = "揭阳市",
                countyList = {
                    { countyId = 12600, countyName = "揭阳市区", gameList = { 200028 } },
                }
            },
        }
    }--]]-- test data

    local formatted = { provinceID = data.pr.plID, provinceName = data.pr.plN, cityList = {} }
    for i,v in ipairs(data.ciL) do
        if v.plL and #v.plL > 0 then
            formatted.cityList[#formatted.cityList+1] = { cityId = v.plID0, cityName = v.plN1, countyList = {} }
            for j,w in ipairs(v.plL) do
                local tidx = #formatted.cityList[#formatted.cityList].countyList + 1
                formatted.cityList[#formatted.cityList].countyList[tidx] = { countyId = w.plID, countyName = w.plN}
            end
        end
    end--]]--
    return formatted
end

function SelectProvinceCityWnd:onInit()
    if IsPortrait then -- TODO
        local UITool = require("app.common.UITool")
        UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
    end
    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root")
    for k,v in pairs(widget_name) do
        self[v] = ccui.Helper:seekWidgetByName(self.root, v)
    end
    
    self.root:addTouchEventListener(handler(self, self.onClick))

    self:initWidgetConfig()
    self:btnCallBack()
end

function SelectProvinceCityWnd:onShow()
    self:backToCitysUI()
    self:initCitysInfo()
end

function SelectProvinceCityWnd:initWidgetConfig()
    self.panel_citys:setVisible(true)
    self.panel_county:setVisible(false)
    self.modelItemCount = 1
    local kitem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/city_item.csb")
    self.city_list:setItemModel(kitem:clone())
    self.county_list:setItemModel(kitem:clone())

    while ccui.Helper:seekWidgetByName(kitem, "btn_" .. (self.modelItemCount+1)) ~= nil do
        self.modelItemCount = self.modelItemCount + 1
    end

    self.city_list:removeAllItems()
    self.county_list:removeAllItems()

    if not IsPortrait then -- TODO
        self.img_cityPrecent:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
                local innerHeight = self.city_list:getInnerContainerSize().height
                local contentHeight = self.city_list:getContentSize().height
                if innerHeight <= contentHeight then
                    self.img_cityPrecent:setVisible(false)
                else
                    self.img_cityPrecent:setVisible(true)

                    local rid = -1 * self.city_list:getInnerContainer():getPositionY() / (innerHeight - contentHeight)
                    rid = math.min(1, math.max(rid, 0))
                    self.img_cityPrecent:setPositionY(rid * self.img_cityPrecent:getParent():getContentSize().height)
                end
            end )
        self.img_cityPrecent:scheduleUpdate()    

        self.img_countyPrecent:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
                local innerHeight = self.county_list:getInnerContainerSize().height
                local contentHeight = self.county_list:getContentSize().height
                if innerHeight <= contentHeight then
                    self.img_countyPrecent:setVisible(false)
                else
                    self.img_countyPrecent:setVisible(true)

                    local rid = -1 * self.county_list:getInnerContainer():getPositionY() / (innerHeight - contentHeight)
                    rid = math.min(1, math.max(rid, 0))
                    self.img_countyPrecent:setPositionY(rid * self.img_countyPrecent:getParent():getContentSize().height)
                end
            end )
        self.img_countyPrecent:scheduleUpdate()
    end
end

function SelectProvinceCityWnd:btnCallBack()
    self.btn_back:addTouchEventListener(handler(self,self.onClickButton))
    if IsPortrait then -- TODO
        self.btn_county_back:addTouchEventListener(handler(self,self.onClickButton))
    else
        if self.btn_county_back then self.btn_county_back:addTouchEventListener(handler(self,self.onClickButton)) end
    end

    self.btn_yes_city:addTouchEventListener(handler(self,self.onClickButton))
    self.btn_yes_city:setBright(false)
    self.btn_yes_city:setTouchEnabled(false)

    self.btn_yes_county:addTouchEventListener(handler(self,self.onClickButton))
    self.btn_yes_county:setBright(false)
    self.btn_yes_county:setTouchEnabled(false)
end

function SelectProvinceCityWnd:initCitysInfo()
    self.select_desc:setString("中国>"..self.m_data.provinceName..">")
    local cityInfos = self.m_data.cityList
    local len = math.ceil(#cityInfos / self.modelItemCount)

    local list = self.city_list
    list:removeAllItems()

    self.btn_yes_city:setBright(false)
    self.btn_yes_city:setTouchEnabled(false)

    self.lastCity = nil
    local firstCityBtn = nil
    local total = 0
    for i = 0, len-1 do
        local item = list:getItem(i)
        if item == nil then
            list:pushBackDefaultItem()
            item = list:getItem(#list:getItems() - 1)
            for k = 1, self.modelItemCount, 1 do
                total = total + 1
                local btn = ccui.Helper:seekWidgetByName(item, "btn_" .. k)
                local text = ccui.Helper:seekWidgetByName(btn, "city_name")
                local btn_select = ccui.Helper:seekWidgetByName(btn, "btn_select")
                btn_select:setBright(false)

                btn.text = text 
                btn.select = btn_select                
                if total <= #cityInfos then
                    local cityInfo = cityInfos[total]
                    text:setString(ToolKit.subUtfStrByCn(cityInfo.cityName, 0, 8, ".."))
                    btn:setTag(total)
                    btn.cityInfo = cityInfo
                else
                    btn:setVisible(false)
                end

                if total == 1 then
                    firstCityBtn = btn
                end
                
                btn:addTouchEventListener(handler(self, self.onSelectCityButton))
            end
        end
    end

    if #cityInfos == 1 then
        self:doSelectCity(firstCityBtn)
        self:switchToCity(self.lastCity.cityInfo)
    end
end

function SelectProvinceCityWnd:switchToCity(cityInfo)
    local countyInfos = cityInfo.countyList

    if #countyInfos == 1 then
        self:doSelectCounty(cityInfo, countyInfos[1], true)
        return
    end


    local len = math.ceil(#countyInfos / self.modelItemCount)

    local list = self.county_list
    list:removeAllItems()

    local total = 0
    self.lastCounty = nil
    self.btn_yes_county:setBright(false)
    self.btn_yes_county:setTouchEnabled(false)
    for i = 0, len-1 do
        local item = list:getItem(i)
        if item == nil then
            list:pushBackDefaultItem()
            item = list:getItem(#list:getItems() - 1)
            for k = 1, self.modelItemCount, 1 do
                total = total + 1
                local btn = ccui.Helper:seekWidgetByName(item, "btn_" .. k)
                local text = ccui.Helper:seekWidgetByName(btn, "city_name")
                local btn_select = ccui.Helper:seekWidgetByName(btn, "btn_select")
                btn_select:setBright(false)

                btn.text = text 
                btn.select = btn_select                
                if total <= #countyInfos then
                    local countyInfo = countyInfos[total]
                    text:setString(ToolKit.subUtfStrByCn(countyInfo.countyName, 0, 8, ".."))
                    btn:setTag(total)
                    btn.countyInfo = countyInfo
                else
                    btn:setVisible(false)
                end
                
                btn:addTouchEventListener(handler(self, self.onSelectCountyButton))
            end
        end
    end

    self.panel_citys:setVisible(false)
    self.panel_county:setVisible(true)
    self.btn_back:setVisible(true)
    if not IsPortrait then -- TODO
        if self.btn_county_back then self.btn_county_back:setVisible(true) end
    end
    self.select_desc:setString("中国>"..self.m_data.provinceName..">"..cityInfo.cityName)
end

function SelectProvinceCityWnd:backToCitysUI()
    self.panel_citys:setVisible(true)
    self.panel_county:setVisible(false)
    self.btn_back:setVisible(false)
    if IsPortrait then -- TODO
        self.btn_county_back:setVisible(false)
    else
        if self.btn_county_back then self.btn_county_back:setVisible(false) end
    end
    self.select_desc:setString("中国>"..self.m_data.provinceName..">")
end

function SelectProvinceCityWnd:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_yes_city then
            if not tolua.isnull(self.lastCity) then
                self:switchToCity(self.lastCity.cityInfo)
            else
                Toast.getInstance():show("请选择所在地区")
            end
        elseif pWidget == self.btn_yes_county then            
            if not tolua.isnull(self.lastCounty) and not tolua.isnull(self.lastCity) then
                self:doSelectCounty(self.lastCity.cityInfo, self.lastCounty.countyInfo)
            else                
                Toast.getInstance():show("请选择所在地区")
            end
        elseif pWidget == self.btn_back or pWidget == self.btn_county_back then
            self:backToCitysUI()
        end
    end
end

function SelectProvinceCityWnd:doSelectCounty(cityInfo, countyInfo, hideCountyName)
    local placeName = cityInfo.cityName
    if not hideCountyName then
       placeName = placeName .. "·" ..countyInfo.countyName
    end
    local selectPlaceId = countyInfo.countyId
    UIManager:getInstance():pushWnd(ConfirmCityWnd, {city_name = placeName, reqData = {ciI = selectPlaceId} })
end

function SelectProvinceCityWnd:onClick(pWidget, EventType)

end

function SelectProvinceCityWnd:doSelectCity(btn)
    if not tolua.isnull(self.lastCity) then
        self.lastCity.select:setBright(false)
        if IsPortrait then -- TODO
            self.lastCity.text:setColor(cc.c3b(0, 0, 0))
        else
            self.lastCity.text:setColor(cc.c3b(255, 255, 255))
        end
    end
    self.lastCity = btn
    self.lastCity.select:setBright(true)
    if IsPortrait then -- TODO
        self.lastCity.text:setColor(cc.c3b(255, 255, 255))
    else
        self.lastCity.text:setColor(cc.c3b(38, 204, 38))
    end

    self.btn_yes_city:setBright(true)
    self.btn_yes_city:setTouchEnabled(true)
end

function SelectProvinceCityWnd:onSelectCityButton(btn, EventType)
    if EventType == ccui.TouchEventType.ended then
        self:doSelectCity(btn)
    end
end

function SelectProvinceCityWnd:onSelectCountyButton(btn, EventType)
    if EventType == ccui.TouchEventType.ended then
        if not tolua.isnull(self.lastCounty) then
            self.lastCounty.select:setBright(false)
            if IsPortrait then -- TODO
                self.lastCounty.text:setColor(cc.c3b(0, 0, 0))
            else
                self.lastCounty.text:setColor(cc.c3b(255, 255, 255))
            end
        end
        self.lastCounty = btn
        self.lastCounty.select:setBright(true)
        
        if IsPortrait then -- TODO
            self.lastCounty.text:setColor(cc.c3b(255, 255, 255))
        else
            self.lastCounty.text:setColor(cc.c3b(38, 204, 38))
        end

        self.btn_yes_county:setBright(true)
        self.btn_yes_county:setTouchEnabled(true)
    end
end


function SelectProvinceCityWnd:onKeyBack()
end

return SelectProvinceCityWnd
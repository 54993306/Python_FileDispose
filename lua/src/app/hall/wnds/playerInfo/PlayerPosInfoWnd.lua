--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
PlayerPosInfoWnd = class("PlayerPosInfoWnd",UIWndBase)
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")

function PlayerPosInfoWnd:ctor(data)
    if IsPortrait then -- TODO
        if display.width > display.height then
            self.super.ctor(self, "hall/player_position_info.csb", data);
        else
            self.super.ctor(self, "hall/player_position_info_portrait.csb", data);
        end
    else
        self.super.ctor(self, "hall/player_position_info.csb", data);
        for i=1,#data.site do
            if data.site[i] == nil or data.site[i] == "" then
                table.remove(data.site,i)
            end
        end
    end

    local originSiteTable = data.site
    data.site = {}
    for k,v in pairs(originSiteTable) do
        table.insert(data.site, v)
    end

    Log.i("PlayerPosInfoWnd:ctor....",data)
    self.m_data = data
    self.m_wndType = data.type;
end
function PlayerPosInfoWnd:onInit()
    self.baseShowType = UIWndBase.BaseShowType.RTOL

    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    for i = 1, 4 do
        local panel_position = self:getWidget(panel_content, "Panel_position_"..i)
        panel_position:setVisible(false)
    end
    self:setPlayerTitle()
    self:setPostionContent()
    
    self.button_close = self:getWidget(self.m_pWidget,"Button_close")
    self.button_close:addTouchEventListener(handler(self,self.onClickButton))
end
function PlayerPosInfoWnd:onClickButton(pWidget,EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.button_close then
            UIManager:getInstance():popWnd(PlayerPosInfoWnd);
        end
    end
end
function PlayerPosInfoWnd:setPlayerTitle()
    Log.i("PlayerPosInfoWnd:setPlayerTitle....")
    local panel_title = self:getWidget(self.m_pWidget,"panel_title");
    local image_head_bg = self:getWidget(panel_title,"Image_head_bg");
    image_head_bg:loadTexture(self.m_data.playerHeadImage);
    --[[local cirHead = CircleClippingNode.new(self.m_data.playerHeadImage, true, image_head_bg:getContentSize().width)
    cirHead:setPosition(image_head_bg:getContentSize().width/2, image_head_bg:getContentSize().height/2)
    image_head_bg:addChild(cirHead)]]
    local label_name = self:getWidget(panel_title,"Label_name");
    local nameStr = ToolKit.subUtfStrByCn(self.m_data.playerName,0,20,"")
    if IsPortrait then -- TODO
        nameStr = ToolKit.subUtfStrByCn(self.m_data.playerName,0,8,"...")
    end
    -- label_name:setString(nameStr);
    Util.updateNickName(label_name, nameStr)
    local label_player_ip = self:getWidget(panel_title,"Label_player_ip");
    label_player_ip:setString(self.m_data.playerIP);
    local label_player_id = self:getWidget(panel_title,"Label_player_id");
    if label_player_id and self.m_data.playerID then label_player_id:setString(self.m_data.playerID); end

    if IsPortrait then -- TODO
        if self.m_wndType ==1 then
            local margin = label_player_id:getLayoutParameter():getMargin()
            margin.left = margin.left + -10
            label_player_id:getLayoutParameter():setMargin(margin)

            local margin = label_player_ip:getLayoutParameter():getMargin()
            margin.left = margin.left + 20
            label_player_ip:getLayoutParameter():setMargin(margin)

            local label_id = self:getWidget(panel_title,"Label_ip_name");
            local margin = label_id:getLayoutParameter():getMargin()
            margin.left = margin.left + 30
            label_id:getLayoutParameter():setMargin(margin)
        end
    end
end
function PlayerPosInfoWnd:setPostionContent()
    local panel_content = self:getWidget(self.m_pWidget,"Panel_content");
    for i, v in ipairs(self.m_data.site) do
        local panel_position = self:getWidget(panel_content, "Panel_position_"..i)
        panel_position:setVisible(true)
        local label_name = self:getWidget(panel_position,"Label_name");
        local label_juli = self:getWidget(panel_position,"Label_juli");
        if v ~= nil then
            local nameStr = ToolKit.subUtfStrByCn(v.name,0,5,"")
            -- label_name:setString(nameStr);
            Util.updateNickName(label_name, nameStr, 30)
            local lo = tonumber(v.lo)
            if v.lo ~=nil and v.lo ~= 0 and lo ~= nil then
                local juli = HallAPI.DataAPI:getDistance(self.m_data.lo, self.m_data.la, v.lo, v.la);
                label_juli:setString(juli);
            else
                label_juli:setString("无法获取位置");
            end
        else
            panel_position:setVisible(false)
        end
    end
end

function PlayerPosInfoWnd:getlen(str)
    local byteSize = 0
    for i = 1 , #str do
        local byteCount = 0
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            byteCount = 1.3
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
        byteSize = byteSize + byteCount
    end
    return byteSize
end
function PlayerPosInfoWnd:getDistance(LonA, LatA, LonB, LatB)
    -- 东西经，南北纬处理，只在国内可以不处理(假设都是北半球，南半球只有澳洲具有应用意义)
    local EARTH_RADIUS = 6378137;--赤道半径(单位m)  
    local radLat1 = math.angle2radian(LonA);
    local radLat2 = math.angle2radian(LonB);
    local a = radLat1 - radLat2;
    local b = math.angle2radian(LatA) - math.angle2radian(LatB);

    local s = 2*math.asin(math.sqrt(math.pow(math.sin(a/2),2)+math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)))
    s = s * EARTH_RADIUS;
    s = math.round(s * 10000) / 10000;
    return s;
end


--endregion

require("app.DebugHelper")
local CommonCheckBoxPanel = require("package_src.games.maomingmj.hall.CommonCheckBoxPanel")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local GameRoomInfoUI_maomingmj = class("GameRoomInfoUI_maomingmj", GameRoomInfoUIBase)


--玩法的配置
local wanfaSetting = {
    [1] = {name = "zhuangmaima",        newline = true,     isLink = true},
    [2] = {name = "shuihushuifanma",    isSelect = true},
    [3] = {name = "zhigangbao",         isSelect = true,    multi = true,   newline = true},
    [4] = {name = "huangjinbufanma",    isSelect = true,    multi = true},
    [5] = {name = "shisanyaobufanma",   isSelect = true,    multi = true,   newline = true},
    [6] = {name = "genzhuang",          multi = true},
    [8] = {name = "1f2f",               isSelect = true},
    [9] = {name = "5f10f",               newline = true,     isLink = true},
    [10] = {name = "10f20f",             isLink = true},
    [12] = {name = "4ma",               isSelect = true},
--    [13] = {name = "8ma",               newline = true,     isLink = true},
}

function GameRoomInfoUI_maomingmj:ctor(...)
	self.super.ctor(self,...)
	
end
function GameRoomInfoUI_maomingmj:playerNumChange(playerNum)
    if self.m_wanfaPanel then
        self:updateRenShu(playerNum)
    end
end

function GameRoomInfoUI_maomingmj:updateRenShu(playerNum)
    local renshu = playerNum
    local zhuangmaima = self.m_wanfaPanel:getCheckBoxPanel("zhuangmaima")
    local genzhuang = self.m_wanfaPanel:getCheckBoxPanel("genzhuang") 
    
    if renshu == 3 or renshu == 2 then
        local checkBox_z = ccui.Helper:seekWidgetByName(zhuangmaima,"CheckBox")
        if checkBox_z:isSelected() then
            local shuihushuifanma = self.m_wanfaPanel:getCheckBoxPanel("shuihushuifanma")
            checkBox = ccui.Helper:seekWidgetByName(shuihushuifanma,"CheckBox")
            checkBox:setSelected(true)
            local label_name_1 = ccui.Helper:seekWidgetByName(shuihushuifanma,"Label_name")
		    label_name_1:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end

        self.m_wanfaPanel:setPanelGrey(zhuangmaima,false)
        checkBox_z:setSelected(false)
        checkBox_z:setTouchEnabled(false)
        genzhuang:setVisible(false)
        checkBox = ccui.Helper:seekWidgetByName(genzhuang,"CheckBox")
        checkBox:setSelected(false)
        local label_name = ccui.Helper:seekWidgetByName(genzhuang,"Label_name")
		label_name:setColor(G_ROOM_INFO_FORMAT.normalColor)
    else
        self.m_wanfaPanel:setPanelGrey(zhuangmaima,true)
        local checkBox_z = ccui.Helper:seekWidgetByName(zhuangmaima,"CheckBox")
        genzhuang:setVisible(true)
    end

    local zhigangbao = self.m_wanfaPanel:getCheckBoxPanel("zhigangbao")
    if renshu == 2 then
        self.m_wanfaPanel:setPanelGrey(zhigangbao,false)
    else
        self.m_wanfaPanel:setPanelGrey(zhigangbao,true,true)
    end

end

function GameRoomInfoUI_maomingmj:initWanFa()
	self:initDiFen()

	local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local wanfa =Util.analyzeString_2(baseInfo.wanfa)
    Log.i("--wangzhi--wanfa--",wanfa)
    local data = {}
    data.title = "玩法:"
    data.content = {}
--    data.isDrawLine = true
    for i,v in pairs(wanfa) do
        local m_data = {}
        m_data.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data[item] = content
                    end
                end
                break
            end
        end
        table.insert(data.content,m_data)
    end

    self.m_wanfaPanel = CommonCheckBoxPanel.new(data)
    table.insert(self.m_itemChildren,self.m_wanfaPanel)
    self.m_wanfaPanel:addTo(self.m_viewWanfaBaseHrl)
    self.m_wanfaPanel:updateSelectBox(function(data,panel) self:updateWanFa(data,panel) end)

    self:initMaiMa()
end
local isSelectBuFanMa = false
--更新选项，当点击不翻马时要屏蔽一些按钮
function GameRoomInfoUI_maomingmj:updateWanFa(data,panel)
    
    local bufanma = self.m_wanfaPanel:getCheckBoxPanel("bufanma")
    local checkBox = ccui.Helper:seekWidgetByName(bufanma,"CheckBox")
    local label = ccui.Helper:seekWidgetByName(bufanma,"Label_name")
    local panels = self.m_maimaPanel:getAllPanel()

    local huangjinbufanma = self.m_wanfaPanel:getCheckBoxPanel("huangjinbufanma")
    local shisanyaobufanma = self.m_wanfaPanel:getCheckBoxPanel("shisanyaobufanma")
    if checkBox:isSelected() then
        for i,v in pairs(panels) do
            for j,k in pairs(v) do
                self.m_maimaPanel:setPanelGrey(k,false)
            end
        end
        self.m_wanfaPanel:setPanelGrey(huangjinbufanma,false)
        self.m_wanfaPanel:setPanelGrey(shisanyaobufanma,false)
        isSelectBuFanMa = true
    else
        
        local isSelect = false
        if isSelectBuFanMa then
            self.m_wanfaPanel:setPanelGrey(huangjinbufanma,true)
            self.m_wanfaPanel:setPanelGrey(shisanyaobufanma,true)
            isSelectBuFanMa = false
            for i,v in pairs(panels) do
                for j,k in pairs(v) do
                    local checkBox = ccui.Helper:seekWidgetByName(k,"CheckBox")
                    if checkBox:isSelected() then
                        isSelect = true
                        break
                    end
                end
            end
            for i,v in pairs(panels) do
                for j,k in pairs(v) do
                    if not isSelect and j == 1 then
                        self.m_maimaPanel:setPanelGrey(k,true,true)
                    else
                        self.m_maimaPanel:setPanelGrey(k,true)
                    end
                
                end
            end
        end
    end
    if data.chick ~= "zhuangmaima" then
        local zhuangmaima = self.m_wanfaPanel:getCheckBoxPanel("zhuangmaima")
        local grey = zhuangmaima.grey or false
        self.m_wanfaPanel:setPanelGrey(zhuangmaima,not grey)
    end
    if data.chick ~= "zhigangbao" then
        local zhigangbao = self.m_wanfaPanel:getCheckBoxPanel("zhigangbao")
        local grey = zhigangbao.grey or false
        self.m_wanfaPanel:setPanelGrey(zhigangbao,not grey)
    end
end
function GameRoomInfoUI_maomingmj:stringToTable(str)  
   local ret = loadstring("return "..str)()  
   return ret  
end 
function GameRoomInfoUI_maomingmj:initDiFen()
    local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local jiadi =Util.analyzeString_2(baseInfo.jiadi)
    local data = {}
    data.title = "底分:"
    data.content = {}
    for i,v in pairs(jiadi) do
        local m_data = {}
        m_data.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v).ch
        m_data.chick = v 
        for j,k in pairs(wanfaSetting) do
            if v == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data[item] = content
                    end
                end
                break
            end
        end
        table.insert(data.content,m_data)
    end

    self.m_difenPanel = CommonCheckBoxPanel.new(data)
    table.insert(self.m_itemChildren,self.m_difenPanel)
    self.m_difenPanel:addTo(self.m_viewWanfaBaseHrl)
end
function GameRoomInfoUI_maomingmj:initMaiMa()

    local maiPosY = self.m_wanfaPanel:getPositionY()
    local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local maima = Util.analyzeString_2(baseInfo.fanma)
    local data = {}
    data.title = "买马:"
    data.content = {}
    for i,v in pairs(maima) do
        local m_data = {}
        m_data.name = MjGameConfigManager[self.m_gameID].kGetPlayingInfoByTitle(v.."ma").ch
        m_data.chick = v 
        local name = v.."ma"
        for j,k in pairs(wanfaSetting) do
            if name == k.name then
                for item,content in pairs(k) do
                    if item ~= "name" then
                        m_data[item] = content
                    end
                end
                break
            end
        end
        table.insert(data.content,m_data)
    end

    self.m_maimaPanel = CommonCheckBoxPanel.new(data)
    table.insert(self.m_itemChildren,self.m_maimaPanel)
    self.m_maimaPanel:addTo(self.m_viewWanfaBaseHrl)
end


--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_maomingmj:wanFaFactory()
	local wanfa = self.m_wanfaPanel:getPanelData()
    
	self.m_setData.wa = wanfa
	self.m_setData.gaI = kFriendRoomInfo:getGameID();
	
    self:jiaDIFactory()
    self:fanmaFactory()
end
function GameRoomInfoUI_maomingmj:jiaDIFactory()
    self.m_setData.ji = tonumber(self:setFenZhiConversion(self.m_difenPanel:getPanelData())[1].id)
    local fenzhi = {
        [1] = "1f2f",
        [2] = "2f4f",
        [5] = "5f10f",
        [10] = "10f20f",
    }
    local fen = fenzhi[tonumber(self.m_setData.ji)]
    if fen then
        self.m_setData.wa = self.m_setData.wa .. "|" ..fen
    end
end
function GameRoomInfoUI_maomingmj:setFenZhiConversion(strText)
   local retV={};
   if(strText==nil or strText=="")then return retV end
   
   local retTable = Util.split(strText,"f");
   for k,v in pairs(retTable) do
     local retTable2 = Util.split(v,":");
	 local tmpData={};
	 tmpData.id = retTable2[1];
	 tmpData.num = retTable2[2];
     table.insert(retV,tmpData)
   end
   return retV
end
function GameRoomInfoUI_maomingmj:fanmaFactory()
    self.m_setData.fa = self.m_maimaPanel:getPanelData()
    if self.m_setData.fa == nil or self.m_setData.fa == "" then
        self.m_setData.fa = 0
    else
        self.m_setData.wa = self.m_setData.wa .. "|" .. self.m_setData.fa .. "ma"
    end
end
return  GameRoomInfoUI_maomingmj
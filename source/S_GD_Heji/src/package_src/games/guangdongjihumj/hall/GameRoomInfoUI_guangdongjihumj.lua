require("app.DebugHelper")
local CommonCheckBoxPanel = require("package_src.games.guangdongjihumj.hall.CommonCheckBoxPanel")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local GameRoomInfoUI_guangdongjihumj = class("GameRoomInfoUI_guangdongjihumj", GameRoomInfoUIBase)

function GameRoomInfoUI_guangdongjihumj:ctor(...)
	self.super.ctor(self,...)
	
end
local wanfaSetting = {
    [1] = {name = "keqiangganghu",          multi = true,       isSelect = true},
    [2] = {name = "qianggangbaosanjia",     multi = true,       isSelect = true},
    [3] = {name = "budaifeng",              multi = true,       isSelect = true,        newline = true},
    [4] = {name = "genzhuang",              multi = true,       isSelect = true},
    [5] = {name = "jiejiegao",              multi = true,       isSelect = true,        newline = true},
    [6] = {name = "guipai",                 title = true,       newline = true},
    [7] = {name = "wugui",                  isSelect = true},
    [8] = {name = "shuanggui",              itemSelect = true,  multi = true},
    [9] = {name = "maima",                  title = true,       newline = true},
    [10] = {name = "erma",                  isSelect = true},
    [11] = {name = "liuma",                 newline = true,     isLink = true},
    [12] = {name = "ershima",               newline = true,     isLink = true},
}

function GameRoomInfoUI_guangdongjihumj:playerNumChange(playerNum)
    if self.m_wanfaPanel then
        self:updateRenShu(playerNum)
    end
end
function GameRoomInfoUI_guangdongjihumj:updateRenShu(playerNum)
    local fanma = self.m_wanfaPanel:getCheckBoxPanel("fangui")
    local shuanggui = self.m_wanfaPanel:getCheckBoxPanel("shuanggui")
    local genzhuang = self.m_wanfaPanel:getCheckBoxPanel("genzhuang")
    local wugui = self.m_wanfaPanel:getCheckBoxPanel("wugui")
    if playerNum and playerNum < 4 then
        self.m_wanfaPanel:setPanelGrey(genzhuang,false)
    else
        self.m_wanfaPanel:setPanelGrey(genzhuang,true)
    end 
end
function GameRoomInfoUI_guangdongjihumj:initWanFa()
	
	local baseInfo = kFriendRoomInfo:getRoomBaseInfo()
    local wanfa = Util.analyzeString_2(baseInfo.wanfa)
--    local wanfaPosY = self.m_jushuPanel:getPositionY()
    local wanfaTable = {}
    for i,v in pairs(wanfa) do
        if v == "wugui" then
            table.insert(wanfaTable,"guipai")
        elseif v == "wuma"  then
            table.insert(wanfaTable,"maima")
        end
        table.insert(wanfaTable,v)
    end
    wanfa = wanfaTable
    local data = {}
    data.title = "玩法:"
    data.content = {} 
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
    self:updateWanFa(data)
end
--更新选项，当点击不翻马时要屏蔽一些按钮
function GameRoomInfoUI_guangdongjihumj:updateWanFa(data)
    --翻鬼和双鬼的动作
    local fanma = self.m_wanfaPanel:getCheckBoxPanel("fangui")
    local checkBox = ccui.Helper:seekWidgetByName(fanma,"CheckBox")
    local shuanggui = self.m_wanfaPanel:getCheckBoxPanel("shuanggui")
    fanma:setPositionX(G_ROOM_INFO_FORMAT.lineWidth/3 + self.m_wanfaPanel.m_startCBPanelX - self.m_wanfaPanel.m_TitleFontSize)
    shuanggui:setPositionX(fanma:getPositionX()+self.m_wanfaPanel.m_itemPanelWidth)
    if not checkBox:isSelected() then
        self.m_wanfaPanel:setPanelGrey(shuanggui,false)
    else
        self.m_wanfaPanel:setPanelGrey(shuanggui,true)
    end
    if data.chick ~= "fangui" and data.chick ~= "shuanggui" then
        if checkBox:isSelected() then
            local checkBox = ccui.Helper:seekWidgetByName(shuanggui,"CheckBox")
            local label = ccui.Helper:seekWidgetByName(shuanggui,"Label_name")
            if checkBox:isSelected() then
                label:setColor(G_ROOM_INFO_FORMAT.selectColor)
            end
        end
    end
    --抢杠胡和抢杠全包的操作
    if data.chick == "keqiangganghu" then
        local keqiangganghu = self.m_wanfaPanel:getCheckBoxPanel("keqiangganghu")
        local checkBox = ccui.Helper:seekWidgetByName(keqiangganghu,"CheckBox")
        checkBox:setSwallowTouches(false)

        local qianggangbaosanjia = self.m_wanfaPanel:getCheckBoxPanel("qianggangbaosanjia")
        if checkBox:isSelected() then
            self.m_wanfaPanel:setPanelGrey(qianggangbaosanjia,false)
        else
            self.m_wanfaPanel:setPanelGrey(qianggangbaosanjia,true)
        end
    end
    if data.chick == "budaifeng" then
        local keqiangganghu = self.m_wanfaPanel:getCheckBoxPanel("keqiangganghu")
        local checkBox = ccui.Helper:seekWidgetByName(keqiangganghu,"CheckBox")
        checkBox:setSwallowTouches(false)
        local qianggangbaosanjia = self.m_wanfaPanel:getCheckBoxPanel("qianggangbaosanjia")
        if not checkBox:isSelected() then
            self.m_wanfaPanel:setPanelGrey(qianggangbaosanjia,false)
        end
    end

    --无马和节节高的操作
    local wuma = self.m_wanfaPanel:getCheckBoxPanel("wuma")
    local checkBox = ccui.Helper:seekWidgetByName(wuma,"CheckBox")
    checkBox:setSwallowTouches(false)

    local jiejiegao = self.m_wanfaPanel:getCheckBoxPanel("jiejiegao")
    if checkBox:isSelected() then
        self.m_wanfaPanel:setPanelGrey(jiejiegao,false)
    else
        self.m_wanfaPanel:setPanelGrey(jiejiegao,true)
    end
    local checkBox = ccui.Helper:seekWidgetByName(jiejiegao,"CheckBox")
    checkBox:setSwallowTouches(false)

    local label = ccui.Helper:seekWidgetByName(jiejiegao,"Label_name")
    if data.chick == "jiejiegao" then
        self:updateRenShu()
        if not checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    else
        if checkBox:isSelected() then
            label:setColor(G_ROOM_INFO_FORMAT.selectColor)
        end
    end

    local genzhuang = self.m_wanfaPanel:getCheckBoxPanel("genzhuang") 
    local checkBox = ccui.Helper:seekWidgetByName(genzhuang,"CheckBox")
    checkBox:setSwallowTouches(false)

    if data.chick ~= "genzhuang" then
        if checkBox:isSelected()  then
            self.m_wanfaPanel:setPanelGrey(genzhuang,true,true)
        end
    end
end
function GameRoomInfoUI_guangdongjihumj:stringToTable(str)  
   local ret = loadstring("return "..str)()  
   return ret  
end 


--[[
-- @brief  玩法组装工厂函数
-- @param  void
-- @return void
--]]
function GameRoomInfoUI_guangdongjihumj:wanFaFactory()
	local wanfa = self.m_wanfaPanel:getPanelData()
    local wf = ""
    for i,v in pairs(Util.analyzeString_2(wanfa)) do
        for j,k in pairs(Util.analyzeString_3(v)) do
            wf = wf == "" and k or wf.."|"..k
        end
    end
    Log.i("wanfa......",wanfa)
	self.m_setData.wa = wf
	self.m_setData.gaI = kFriendRoomInfo:getGameID();
	
end

function GameRoomInfoUI_guangdongjihumj:initRoomInfo()

    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
        end
    end

    local wanfa = self.m_itemChildren
    for i,v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            local panelData =self._friendRoomDataManager:getData(string.format( "wanfa%s",tostring(i)))
            v:updateRoomPanel(panelData)
        end
    end
end

function GameRoomInfoUI_guangdongjihumj:saveRoomInfo()

    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,tostring(i))
        end
    end

    local wanfa = self.m_itemChildren
    for i, v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            local panelData = v:getSavePanelAllData()
            self._friendRoomDataManager:saveData(string.format( "wanfa%s",tostring(i)),panelData)
        end
    end
end

return  GameRoomInfoUI_guangdongjihumj
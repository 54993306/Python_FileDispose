
require("app.DebugHelper")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")

local GameRoomInfoUI_zhaoqingmj = class("GameRoomInfoUI_zhaoqingmj", GameRoomInfoUIBase )


--初始化玩法列表
function GameRoomInfoUI_zhaoqingmj:initWanFa()
     
     --local SelectRadioPanel = require("package_src.games.zhaoqingmj.hall.SelectRadioPanel")

    self.gamePalyingName= {}---------------------新建玩法列表

    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法

     local dataSelectRadio1 =
    {
        title = "底数:", radios = {self.gamePalyingName[12].ch, self.gamePalyingName[13].ch}, hiddenLine = true
    }
    local groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
        self.m_wanfa[1] = self.gamePalyingName[index + 11].title
    end)
    self:addScrollItem(groupSelectRadio1)

    
    local dataSelectRadio2 =
    {
        title = "鬼牌:", radios = {self.gamePalyingName[1].ch, self.gamePalyingName[2].ch}, hiddenLine = true
    }
    local dataSelectRadio2 = SelectRadioPanel.new(dataSelectRadio2, function(index)
        self.m_wanfa[2] = self.gamePalyingName[index].title
    end)
    self:addScrollItem(dataSelectRadio2)

    local dataSelectRadio3 =
    {
        title = "买马:", 
        radios = {self.gamePalyingName[3].ch, 
            self.gamePalyingName[4].ch, 
            self.gamePalyingName[5].ch,
            self.gamePalyingName[6].ch,
            self.gamePalyingName[7].ch,
            }, 
        hiddenLine = true
    }
    local dataSelectRadio3 = SelectRadioPanel.new(dataSelectRadio3, function(index)
        self.m_wanfa[3] = self.gamePalyingName[index + 2].title
    end)
    dataSelectRadio3:setSelectedIndex(3)
    self:addScrollItem(dataSelectRadio3)

    local dataSelectRadio4 =
    {
        title = "定马:", 
        radios = {self.gamePalyingName[8].ch, self.gamePalyingName[9].ch}, 
        hiddenLine = true
    }
    local dataSelectRadio4 = SelectRadioPanel.new(dataSelectRadio4, function(index)
        self.m_wanfa[4] = self.gamePalyingName[index + 7].title
    end)
    dataSelectRadio4:setSelectedIndex(2)
    self:addScrollItem(dataSelectRadio4)

    local dataSelectRadio5 =
    {
        title = "玩法:", 
        radios = {self.gamePalyingName[10].ch, self.gamePalyingName[11].ch}, 
        hiddenLine = true
    }
    local dataSelectRadio5 = SelectRadioPanel.new(dataSelectRadio5, function(index)
        self.m_wanfa[5] = self.gamePalyingName[index + 9].title
    end)
    dataSelectRadio5:setSelectedIndex(2)
    self:addScrollItem(dataSelectRadio5)
end


function GameRoomInfoUI_zhaoqingmj:initRoomInfo()
    
    local baseItemChildren = self.m_baseItemChildren
    local itemChildren = {}
    for i,v in pairs(baseItemChildren) do
        itemChildren[tostring(i)] = v
    end
    baseItemChildren = itemChildren
    for i,v in pairs(baseItemChildren) do
        if v.m_data and v.m_data.title and v.m_data.title == "局数:" then
            table.remove( baseItemChildren,tostring(i))
            baseItemChildren[tostring(i)] = v
            break;
        end
    end
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:updateRoomPanel(v,tostring(i))
        end
    end
	
	local itemChildren = self.m_itemChildren
    for i, v in pairs(itemChildren) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:updateRoomPanel(v,string.format( "wanfa%d",i) )
            else
                self._friendRoomDataManager:updateRoomCheckPanel(v,string.format( "wanfa%d",i))
            end
        end
    end
end

function GameRoomInfoUI_zhaoqingmj:saveRoomInfo()
    local wanfa = self.m_itemChildren
    for i, v in pairs(wanfa) do
        if v and type(v) == "userdata" then
            if v.m_radioBtns then
                self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,string.format( "wanfa%d",i))
            else
                self._friendRoomDataManager:setCheckPanelAllData(v,string.format( "wanfa%d",i))
            end
        end
    end
    local baseItemChildren = self.m_baseItemChildren
    for i,v in pairs(baseItemChildren) do
        if v and type(v) == "userdata" and v.m_radioBtns then
            self._friendRoomDataManager:savePanelAllData(v.m_radioBtns,tostring(i))
        end
    end
end


return GameRoomInfoUI_zhaoqingmj
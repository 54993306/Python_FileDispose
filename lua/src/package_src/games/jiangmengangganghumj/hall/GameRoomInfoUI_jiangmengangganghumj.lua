
require("app.DebugHelper")

local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")

local GameRoomInfoUI_jiangmengangganghumj = class("GameRoomInfoUI_jiangmengangganghumj", GameRoomInfoUIBase )



function GameRoomInfoUI_jiangmengangganghumj:initScore()
    local dataScore =
    {
        title = "底分:",
        options =
        {
            {text = self.gamePalyingName[1].ch, isSelected = true},
            {text = self.gamePalyingName[2].ch},
            {text = self.gamePalyingName[3].ch},
            {text = self.gamePalyingName[4].ch},
        },
        lineVisible = true
    }
    self.m_wanfa[1] = self.gamePalyingName[1].title

    self.m_items1 = DropDownBoxPanel.new(dataScore, function(index)
        self.m_wanfa[1] = self.gamePalyingName[index ].title
    end)
    --self.m_items1:setMaxRow(4)
    --self.m_items1:setTag(self.m_itemType.ITEM_SCORE)
    self:addScrollItem(self.m_items1)
    self.m_items1:setLocalZOrder(999)
   
end
--初始化玩法列表
function GameRoomInfoUI_jiangmengangganghumj:initWanFa()
     
     --local SelectRadioPanel = require("package_src.games.jiangmengangganghumj.hall.SelectRadioPanel")

     self.gamePalyingName= {}---------------------新建玩法列表

    self.gamePalyingName = MjGameConfigManager[self.m_gameID]._gamePalyingName------获取玩法

    self:initScore()---下拉框

     local dataSelectRadio1 =
    {
        title = "玩法:", radios = {self.gamePalyingName[5].ch, self.gamePalyingName[6].ch}, hiddenLine = true
    }
    local groupSelectRadio1 = SelectRadioPanel.new(dataSelectRadio1, function(index)
        self.m_wanfa[2] = self.gamePalyingName[index+4].title
    end)
    self:addScrollItem(groupSelectRadio1)

    --  单选（第2排）
    local dataSelectRadio2 =
    {
        title = "", radios = {self.gamePalyingName[7].ch, self.gamePalyingName[8].ch}, hiddenLine = true
    }
    local groupSelectRadio2 = SelectRadioPanel.new(dataSelectRadio2, function(index)
        self.m_wanfa[3] = self.gamePalyingName[index + 6].title
    end)
    self:addScrollItem(groupSelectRadio2)


 local dataSelectRadio3 =
    {
        title = "买马", radios = {self.gamePalyingName[9].ch, self.gamePalyingName[10].ch, self.gamePalyingName[11].ch}, hiddenLine = true
    }
    local groupSelectRadio3 = SelectRadioPanel.new(dataSelectRadio3, function(index)
        self.m_wanfa[4] = self.gamePalyingName[index +8 ].title
    end)
    groupSelectRadio3:setSelectedIndex(2)
    self:addScrollItem(groupSelectRadio3)
end


function GameRoomInfoUI_jiangmengangganghumj:initRoomInfo()
    
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

function GameRoomInfoUI_jiangmengangganghumj:saveRoomInfo()
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


return GameRoomInfoUI_jiangmengangganghumj
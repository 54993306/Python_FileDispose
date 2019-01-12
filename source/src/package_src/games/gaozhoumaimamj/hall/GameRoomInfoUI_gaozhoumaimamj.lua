--
-- Author: RuiHao Lin
-- Date: 2017-05-08 10:17:58
--

require("app.DebugHelper")

local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local DropDownBoxPanel = require("app.games.common.custom.DropDownBox.DropDownBoxPanel")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUI_gaozhoumaimamj = class("GameRoomInfoUI_gaozhoumaimamj", GameRoomInfoUIBase)

function GameRoomInfoUI_gaozhoumaimamj:onInit()
    self:changPlayerNumber({4})
    self:initData()
end

--  初始化数据
function GameRoomInfoUI_gaozhoumaimamj:initData()
    --  玩法规则
    self.m_GameRule = MjGameConfigManager[self.m_gameID]._gamePalyingName
    --  子项列表
    self.m_items = {}
    --  子项类别
    self.m_itemType =
    {
        ITEM_WANFA_1 = 1,    --  玩法1——黄庄是否换庄
        ITEM_MAIMA = 2,     --   买马
        ITEM_SCORE = 3,     --   底分
    }
end

-- 初始化买马列表
function GameRoomInfoUI_gaozhoumaimamj:initMaiMa()
    local lMaiMaNumList = { }
    local itemFormat = { }
    local lMaiMaList = Util.analyzeString_2(self.m_roomBaseInfo.fanma)
    --local lMaiMaList = Util.analyzeStringEx(ret.roundFreeSum, ",", "|")(self.m_RoomInFo.fanma)
    local lTextList =
    {
        [4] = self.m_GameRule[3],
        [6] = self.m_GameRule[4],
        [8] = self.m_GameRule[5],
        [12] = self.m_GameRule[6],
    }

    for i, v in pairs(lMaiMaList) do
        local num = tonumber(v)
        local lSelected = false
        if num == 8 then
            lSelected = true
        end
        local item = { text = lTextList[num].ch, isSelected = lSelected }
        table.insert(itemFormat, item)
        table.insert(lMaiMaNumList, num)
    end

    local dataMaiMa =
    {
        title = "买马:",
        options = itemFormat,
        Config =
        {
            LineVisible = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_MAIMA] = RadioButtonGroup.new(dataMaiMa, function(index)
        self.m_setData.fa = lMaiMaNumList[index]
        self.m_wanfa[self.m_itemType.ITEM_MAIMA] = lTextList[lMaiMaNumList[index]].title
    end )
    self.m_items[self.m_itemType.ITEM_MAIMA]:setTag(self.m_itemType.ITEM_MAIMA)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_MAIMA])
    self.m_items[self.m_itemType.ITEM_MAIMA]:setLocalZOrder(99)
end

--  初始化底分
function GameRoomInfoUI_gaozhoumaimamj:initScore()
    local lSerScoreList = Util.analyzeString_2(self.m_roomBaseInfo.jiadi)
    local lScoreList = {}
    local lItemList = {}
    local lTextList =
    {
        [1] = self.m_GameRule[7],
        [2] = self.m_GameRule[8],
        [5] = self.m_GameRule[9],
        [10] = self.m_GameRule[10],
    }

    for i, v in pairs(lSerScoreList) do
        local lScore = tonumber(v)
        local lSelected = false
        if lScore == 1 then
            lSelected = true
        end
        local lItem = {text = lTextList[lScore].ch, isSelected = lSelected}
        table.insert(lScoreList, lScore)
        table.insert(lItemList, lItem)
    end
    local dataScore =
    {
        title = "底分:",
        options = lItemList,
        Config =
        {
            LineVisible = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_SCORE] = DropDownBoxPanel.new(dataScore, function(index)
        self.m_setData.ji = lScoreList[index]
        self.m_wanfa[self.m_itemType.ITEM_SCORE] = lTextList[lScoreList[index]].title
    end)
    self.m_items[self.m_itemType.ITEM_SCORE]:setTag(self.m_itemType.ITEM_SCORE)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_SCORE])
    self.m_items[self.m_itemType.ITEM_SCORE]:setLocalZOrder(999)
end

-- 初始化玩法列表
function GameRoomInfoUI_gaozhoumaimamj:initWanFa()
    self:initMaiMa()
    self:initScore()

    --  黄庄是否换庄
    local dataWanFa1 =
    {
        title = "玩法:",
        options =
        {
            { text = self.m_GameRule[1].ch, isSelected = true },
            { text = self.m_GameRule[2].ch }
        },
        Config =
        {
            LineVisible = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_1] = RadioButtonGroup.new(dataWanFa1, function(index)
        self.m_wanfa[self.m_itemType.ITEM_WANFA_1] = self.m_GameRule[index].title
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_1]:setTag(self.m_itemType.ITEM_WANFA_1)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_1])
end

return GameRoomInfoUI_gaozhoumaimamj
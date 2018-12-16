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

local GameRoomInfoUI_jiangmenguipaimj = class("GameRoomInfoUI_jiangmenguipaimj", GameRoomInfoUIBase)

--  override
function GameRoomInfoUI_jiangmenguipaimj:ctor(viewSize, roomBaseInfo, friendRoomMode, gameID, viewLayoutCallBack, ...)
    self.super.ctor(self, viewSize, roomBaseInfo, friendRoomMode, gameID, viewLayoutCallBack, ...)

    self:doDefualtEvent()
end

function GameRoomInfoUI_jiangmenguipaimj:onInit()
    self:initData()
end

--  初始化数据
function GameRoomInfoUI_jiangmenguipaimj:initData()
    --  玩法规则
    self.m_GameRule = MjGameConfigManager[self.m_gameID]._gamePalyingName
    --  子项列表
    self.m_items = {}

    --  子项类别
    self.m_itemType =
    {
        ITEM_WANFA_1 = 1,    --  玩法1——有无鬼牌
        ITEM_WANFA_2 = 2,    --  玩法2——通常翻马数
        ITEM_WANFA_3 = 3,    --  玩法3——1马时翻马数
        ITEM_WANFA_4 = 4,    --  玩法4——中发白算马
        ITEM_WANFA_5 = 5,    --  玩法5——是否4鬼牌胡牌
        ITEM_MAIMA = 6,     --   买马
        ITEM_SCORE = 7,     --   底分
        ITEM_12_LUODI = 8,  --  玩法--十二张落地包三家
    }
end

-- 初始化买马列表
function GameRoomInfoUI_jiangmenguipaimj:initMaiMa()
    local number = { 1, 4, 6, 8, 10 }
    local itemFormat = { }
    for i, v in pairs(number) do
        local buf = string.format(v .. "马")
        local kSelected = false
        if v == 10 then
            kSelected = true
        end
        local item = { text = buf, isSelected = kSelected }
        table.insert(itemFormat, item)
    end

    local dataMaiMa =
    {
        title = "买马：",
        options = itemFormat,
        Config =
        {
            LineVisible = false,
            ResponseEvent = false,
            boxBtnCallBack = function()
                if self.m_items[self.m_itemType.ITEM_SCORE] and self.m_items[self.m_itemType.ITEM_SCORE].m_OptionPanelList[1].m_BoxListView:isVisible() then
                    self.m_items[self.m_itemType.ITEM_SCORE]:dealResponseEvent(true)
                end
            end,
        }
    }
    self.m_items[self.m_itemType.ITEM_MAIMA] = DropDownBoxPanel.new(dataMaiMa, function(index)
        self.m_wanfa[self.m_itemType.ITEM_MAIMA] = self.m_GameRule[index + 10].title
        if number[index] == 1 then
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_2], false)
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_3], true)
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_4], true)
            self.m_wanfa[self.m_itemType.ITEM_WANFA_2] = nil

            --  无鬼牌情况下，显示分割线
            -- local isWuGuiPai = self.m_items[self.m_itemType.ITEM_WANFA_1].m_CurrButton:getTag() == 1
            -- if isWuGuiPai then
                -- self.m_items[self.m_itemType.ITEM_WANFA_2]:setLineVisible(false)
                -- self.m_items[self.m_itemType.ITEM_WANFA_4]:setLineVisible(true)
            -- end
        else
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_2], true)
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_3], false)
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_4], false)
            self.m_wanfa[self.m_itemType.ITEM_WANFA_3] = nil
            self.m_wanfa[self.m_itemType.ITEM_WANFA_4] = nil

            --  无鬼牌情况下，显示分割线
            -- local isWuGuiPai = self.m_items[self.m_itemType.ITEM_WANFA_1].m_CurrButton:getTag() == 1
            -- if isWuGuiPai then
            --     self.m_items[self.m_itemType.ITEM_WANFA_2]:setLineVisible(true)
            --     self.m_items[self.m_itemType.ITEM_WANFA_4]:setLineVisible(false)
            -- end
        end
        self:dealVisibleEvent(self.m_items[self.m_itemType.ITEM_WANFA_2])
        self:dealVisibleEvent(self.m_items[self.m_itemType.ITEM_WANFA_3])
        self:dealVisibleEvent(self.m_items[self.m_itemType.ITEM_WANFA_4])
        self:dealVisibleEvent(self.m_items[self.m_itemType.ITEM_WANFA_1])
        self:viewLayout()
    end )
    self.m_items[self.m_itemType.ITEM_MAIMA]:setTag(self.m_itemType.ITEM_MAIMA)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_MAIMA])
    self.m_items[self.m_itemType.ITEM_MAIMA]:setLocalZOrder(99)
end

--  初始化底分
function GameRoomInfoUI_jiangmenguipaimj:initScore()
    local dataScore =
    {
        title = "底分：",
        options =
        {
            {text = self.m_GameRule[16].ch, isSelected = true},
            {text = self.m_GameRule[17].ch},
            {text = self.m_GameRule[18].ch},
            {text = self.m_GameRule[19].ch},
        },
        Config =
        {
            LineVisible = false,
            ResponseEvent = false,
            boxBtnCallBack = function()
                if self.m_items[self.m_itemType.ITEM_MAIMA] and self.m_items[self.m_itemType.ITEM_MAIMA].m_OptionPanelList[1].m_BoxListView:isVisible() then
                    self.m_items[self.m_itemType.ITEM_MAIMA]:dealResponseEvent(true)
                end
            end,
        }
    }
    self.m_items[self.m_itemType.ITEM_SCORE] = DropDownBoxPanel.new(dataScore, function(index)
        self.m_wanfa[self.m_itemType.ITEM_SCORE] = self.m_GameRule[index + 15].title
    end)
    self.m_items[self.m_itemType.ITEM_SCORE]:setTag(self.m_itemType.ITEM_SCORE)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_SCORE])
    self.m_items[self.m_itemType.ITEM_SCORE]:setLocalZOrder(999)
end

-- 初始化玩法列表
function GameRoomInfoUI_jiangmenguipaimj:initWanFa()
    self:initMaiMa()
    self:initScore()

    --  选择有无鬼牌
    local dataWanFa1 =
    {
        title = "玩法：",
        options =
        {
            { text = self.m_GameRule[1].ch, isSelected = true },
            { text = self.m_GameRule[2].ch }
        },
        Config =
        {
            ResponseEvent = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_1] = RadioButtonGroup.new(dataWanFa1, function(index)
        self.m_wanfa[self.m_itemType.ITEM_WANFA_1] = self.m_GameRule[index].title
        if index == 1 then
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_5], false)
            self.m_wanfa[self.m_itemType.ITEM_WANFA_5] = nil
            -- self.m_items[self.m_itemType.ITEM_WANFA_2]:setLineVisible(true)
            -- self.m_items[self.m_itemType.ITEM_WANFA_4]:setLineVisible(true)

            self.m_items[self.m_itemType.ITEM_WANFA_2]:setSelectedIndex(false, 1)
            self.m_items[self.m_itemType.ITEM_WANFA_2]:setSelectedIndex(false, 2)
            self.m_items[self.m_itemType.ITEM_WANFA_2]:setSelectedIndex(true, 3)
            self.m_items[self.m_itemType.ITEM_WANFA_2]:setBtnEnabled(false, 1)
            self.m_items[self.m_itemType.ITEM_WANFA_2]:setBtnEnabled(false, 2)

            self.m_wanfa[self.m_itemType.ITEM_WANFA_2] = self.m_GameRule[5].title

        else
            self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_5], true)
            -- self.m_items[self.m_itemType.ITEM_WANFA_2]:setLineVisible(false)
            -- self.m_items[self.m_itemType.ITEM_WANFA_4]:setLineVisible(false)

            self.m_items[self.m_itemType.ITEM_WANFA_2]:setBtnEnabled(true, 1)
            self.m_items[self.m_itemType.ITEM_WANFA_2]:setBtnEnabled(true, 2)
        end
        self:dealVisibleEvent(self.m_items[self.m_itemType.ITEM_WANFA_5])
        self:viewLayout()
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_1]:setTag(self.m_itemType.ITEM_WANFA_1)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_1])

    --  选择翻马数
    local dataWanFa2 =
    {
        options =
        {
            { text = self.m_GameRule[3].ch},
            { text = self.m_GameRule[4].ch },
            { text = self.m_GameRule[5].ch, isSelected = true }
        },
        Config =
        {
            ResponseEvent = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_2] = RadioButtonGroup.new(dataWanFa2, function(index)
        self.m_wanfa[self.m_itemType.ITEM_WANFA_2] = self.m_GameRule[index + 2].title
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_2]:setTag(self.m_itemType.ITEM_WANFA_2)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_2])

    --  选择翻马数（1马玩法）
    local dataWanFa3 =
    {
        options =
        {
            { text = self.m_GameRule[6].ch, isSelected = true },
            { text = self.m_GameRule[7].ch }
        },
        Config =
        {
            ResponseEvent = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_3] = RadioButtonGroup.new(dataWanFa3, function(index)
        self.m_wanfa[self.m_itemType.ITEM_WANFA_3] = self.m_GameRule[index + 5].title
    end )

    self.m_items[self.m_itemType.ITEM_WANFA_3]:setTag(self.m_itemType.ITEM_WANFA_3)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_3])
    --self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_3], false)

    --  中发白算马
    local dataWanFa4 =
    {
        options =
        {
            { text = self.m_GameRule[8].ch, isSelected = true },
            { text = self.m_GameRule[9].ch }
        },
        Config =
        {
            LineVisible = false,
            ResponseEvent = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_4] = RadioButtonGroup.new(dataWanFa4, function(index)
        self.m_wanfa[self.m_itemType.ITEM_WANFA_4] = self.m_GameRule[index + 7].title
    end )

    self.m_items[self.m_itemType.ITEM_WANFA_4]:setTag(self.m_itemType.ITEM_WANFA_4)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_4])
    self:setItemVisible(self.m_items[self.m_itemType.ITEM_WANFA_4], false)
    self.m_wanfa[self.m_itemType.ITEM_WANFA_4] = nil

    -- 2018年1月9日21:53:48  这个版本先不上
    -- 选择十二张落地选项
    local dataWanFa6 =
    {
        options =
        {
            { text = self.m_GameRule[20].ch, isSelected = true },
            { text = self.m_GameRule[21].ch }
        },
        Config =
        {
            ResponseEvent = false,MaxCol = 1
        }
    }
    self.m_items[self.m_itemType.ITEM_12_LUODI] = RadioButtonGroup.new(dataWanFa6, function(tag)
        local index = tag + 19
        self.m_wanfa[self.m_itemType.ITEM_12_LUODI] = self.m_GameRule[index].title
    end )

    self.m_items[self.m_itemType.ITEM_12_LUODI]:setTag(self.m_itemType.ITEM_12_LUODI)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_12_LUODI])

    --  四鬼算胡牌
    local dataWanFa5 =
    {
        options =
        {
            { text = self.m_GameRule[10].ch, isSelected = true }
        },
        Config =
        {
            LineVisible = false,
            ResponseEvent = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_5] = CheckBoxPanel.new(dataWanFa5, function(tag, isSelected)
        local index = tag + 9
        if isSelected then
            self.m_wanfa[self.m_itemType.ITEM_WANFA_5] = self.m_GameRule[index].title
        else
            self.m_wanfa[self.m_itemType.ITEM_WANFA_5] = nil
        end
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_5]:setTag(self.m_itemType.ITEM_WANFA_5)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_5])
end

--  处理子项可见性事件响应
function GameRoomInfoUI_jiangmenguipaimj:dealVisibleEvent(obj)
    if obj:isVisible() then
        local cn = obj.__cname
        if cn == "RadioButtonGroup" then
            obj:dealResponseEvent()
        elseif cn == "CheckBoxPanel" then
            obj:dealResponseEvent()
        elseif cn == "DropDownBoxPanel" then
            obj:dealResponseEvent()
        end
    end
end

--  执行默认事件响应
function GameRoomInfoUI_jiangmenguipaimj:doDefualtEvent()
    for i, v in pairs(self.m_items) do
        self:dealVisibleEvent(v)
    end
end

return GameRoomInfoUI_jiangmenguipaimj
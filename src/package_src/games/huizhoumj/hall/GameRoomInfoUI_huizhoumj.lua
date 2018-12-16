--
-- Author: Machine
-- Date: 2018-01-03 10:17:58
--

require("app.DebugHelper")

local RadioButtonGroup = require("app.games.common.custom.RadioButtonGroup")
local CheckBoxPanel = require("app.games.common.custom.CheckBoxPanel")
local DropItem = require("app.games.common.custom.DropItem")

local GameRoomInfoUIBase = require("app.games.common.custom.GameRoomInfoUIBase")
local MjGameConfigManager = require("app.games.common.MjGameConfigManager")

local GameRoomInfoUI_mengzituidaohumj = class("GameRoomInfoUI_mengzituidaohumj", GameRoomInfoUIBase)

local dropDownZorder     = 10   -- 下拉框z
local dropDownItemZorder = 5    -- 下拉框里面的内容z
local offsetNum1         = 10   -- 回调中的买马偏移数目
local offsetNum2         = 15   -- 回调中的玩法偏移数目

--  override
function GameRoomInfoUI_mengzituidaohumj:onInit()
    self:initData()
end

--  override
function GameRoomInfoUI_mengzituidaohumj:initUI()
    self.super.initUI(self)
end

--  初始化数据
function GameRoomInfoUI_mengzituidaohumj:initData()
    --  子项列表
    self.m_items = {}
    --  玩法规则
    self.m_GameRule = MjGameConfigManager[self.m_gameID]._gamePalyingName

    --  子项类别
    self.m_itemType =
    {
        ITEM_RENSHU = 1,    --  人数
        ITEM_JUSHU = 2,     --  局数
        ITEM_PAYTYPE = 3,   --  房费支付
        ITEM_WANFA_1 = 4,   --  玩法1——底分 
        ITEM_WANFA_2 = 5,   --  玩法2——买马
        ITEM_WANFA_3 = 6,   --  玩法3——玩法
    }
end

function GameRoomInfoUI_mengzituidaohumj:playerNumChange(playerNum)
    if playerNum == 2 or playerNum == 3 then
        if not tolua.isnull(self.m_items[self.m_itemType.ITEM_WANFA_3]) then
            self.m_items[self.m_itemType.ITEM_WANFA_3]:setBtnEnabled(1, false)
            self.m_items[self.m_itemType.ITEM_WANFA_3]:setSelectedIndex(false, 1)
            self.m_wanfa[self.m_GameRule[16].ch] = nil

            dump(self.m_wanfa)

        end
    elseif playerNum == 4 then
        if not tolua.isnull(self.m_items[self.m_itemType.ITEM_WANFA_3]) then
            self.m_items[self.m_itemType.ITEM_WANFA_3]:setBtnEnabled(1, true)
            self.m_wanfa[self.m_GameRule[16].ch] = self.m_GameRule[3].title
        end
    end

end

--  override
-- 初始化玩法列表
function GameRoomInfoUI_mengzituidaohumj:initWanFa()

------------------------------------底分---------------------------------------------------
    local layout = ccui.Layout:create()
    local layoutSize = cc.size(G_ROOM_INFO_FORMAT.lineWidth,G_ROOM_INFO_FORMAT.lineHeight)
    layout:setContentSize(layoutSize)

    local  dropData1 = {
        title="底数：",
        -- offX = 130,
        -- offY = -7,
        -- width = dropWidth,
        radios = {
            self.m_GameRule[1].ch,
            self.m_GameRule[2].ch,
            self.m_GameRule[3].ch,
            self.m_GameRule[4].ch,
            self.m_GameRule[5].ch,
            self.m_GameRule[6].ch,
            self.m_GameRule[7].ch,
            self.m_GameRule[8].ch,
            self.m_GameRule[9].ch,
            self.m_GameRule[10].ch,
        },  -- 未选中情况下的文字
        index           = 1, -- 默认序号
        callback        = function(index)
            self.m_wanfa[self.m_itemType.ITEM_WANFA_1] = self.m_GameRule[index].title
        end, -- 选中选项时的回调
        clickback = function()
            -- todo
        end, --点击按钮回调
        zorder = dropDownItemZorder,
        -- width=200, --调整条目的宽
        line = false,
    }
    local dropItem1 = DropItem.new(dropData1)
    dropItem1:setPosition(0, layoutSize.height - dropItem1:getContentSize().height)
    layout:addChild(dropItem1, dropDownZorder)
    self:addScrollItem(layout)


------------------------------------翻鸡  上下鸡---------------------------------------------------
    local dataWanFa2 =
    {
        title = "买马：",
        options =
        {
            { text = self.m_GameRule[offsetNum1+1].ch, isSelected = true},
            { text = self.m_GameRule[offsetNum1+2].ch},
            { text = self.m_GameRule[offsetNum1+3].ch},
            { text = self.m_GameRule[offsetNum1+4].ch},
            { text = self.m_GameRule[offsetNum1+5].ch},
        },
        Config =
        {
            LineVisible = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_2] = RadioButtonGroup.new(dataWanFa2, function(tag)
        local index = tag + offsetNum1
        self.m_wanfa[self.m_itemType.ITEM_WANFA_2] = self.m_GameRule[index].title
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_2]:setTag(self.m_itemType.ITEM_WANFA_2)
    -- self.m_items[self.m_itemType.ITEM_WANFA_2]:setLocalZOrder(99)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_2])


------------------------------------玩法---------------------------------------------------
    local layoutMix = ccui.Layout:create()
    layoutMix:setContentSize(layoutSize)
    local dataWanFa3 =
    {
        title = "玩法：",
        options =
        {
           { text = self.m_GameRule[offsetNum2+1].ch},
           { text = self.m_GameRule[offsetNum2+2].ch},
           { text = self.m_GameRule[offsetNum2+3].ch},
        },
        Config =
        {
            LineVisible = false,
        }
    }
    self.m_items[self.m_itemType.ITEM_WANFA_3] = CheckBoxPanel.new(dataWanFa3, function(tag, isSelected) 
        local index = tag + offsetNum2
        if isSelected then
            self.m_wanfa[self.m_GameRule[index].ch] = self.m_GameRule[index].title
            if tag == 1 and self.m_items[self.m_itemType.ITEM_WANFA_3] then
                self.m_items[self.m_itemType.ITEM_WANFA_3]:setSelectedIndex(true, 3)
                self.m_wanfa[self.m_GameRule[index + 2].ch] = self.m_GameRule[index + 2].title
            end
        else
            self.m_wanfa[self.m_GameRule[index].ch] = nil
            if tag == 1 and self.m_items[self.m_itemType.ITEM_WANFA_3] then
                self.m_items[self.m_itemType.ITEM_WANFA_3]:setSelectedIndex(false, 3)
                self.m_wanfa[self.m_GameRule[index + 2].ch] = nil
            end
        end
    end )
    self.m_items[self.m_itemType.ITEM_WANFA_3]:setTag(self.m_itemType.ITEM_WANFA_3)
    self:addScrollItem(self.m_items[self.m_itemType.ITEM_WANFA_3])

end

return GameRoomInfoUI_mengzituidaohumj
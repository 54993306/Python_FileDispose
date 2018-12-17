--
-- Author: RuiHao Lin
-- Date: 2017-07-18 15:08:18
--
--  @CardPanel  卡牌板块；默认排版方式为居中对齐

local Card = require("app.games.common.custom.TurnCard.Card")
local MjTool = require("app.games.common.custom.MjTool")

local CardPanel = class("CardPanel", function ()
    local ret = cc.Node:create()
    return ret
end)

--  排列方式枚举
CardPanel.EnumLayoutStyle =
{
    Align_Center = 1,   --  居中对齐排列
    Align_Left = 2,     --  左对齐排列
}

--[[
    @biref  卡牌面板；
    @lData  卡牌数据  
    {
        {CardID = 31, Lottery = 0}, --  CardID：卡牌ID， Lottery：1 --高亮；0 --灰暗
        {CardID = 32, Lottery = 0},
        {CardID = 33, Lottery = 1},
    }
    @lConfig   卡牌面板的配置；
    {
        LayoutStyle = CardPanel.EnumLayoutStyle.Align_Center,   --  排列方式，默认为Align_Center
        ShowAniHighLight = true,                                --  是否播放高亮动画，默认为true
        ColGap = 30,                                            --  列间距，默认为30
        RowGap = 30,                                            --  行间距，默认为30
        MaxCol = 8,                                             --  最大列数，默认为8
    }
--]]
function CardPanel:ctor(lData, lConfig)
    self.m_Data = lData or { }
    self.m_Options = lConfig or {}

    self:init()
end

function CardPanel:init()
	self:initData()
	self:initUI()
end

function CardPanel:initData()
    self:initConfig()

    --  翻牌动画时间
    self.m_AniTime = 0
    --  卡牌列表
    self.m_ListCard = {}
    --  中马列表
    self.m_ListLottery = {}
    --  实际列数
    self.m_ActualCol = 0
    --  实际行数
    self.m_ActualRow = 0
end

--  初始化配置列表
function CardPanel:initConfig()
    --  是否需要高亮动画
    self.m_Options.ShowAniHighLight = self.m_Options.ShowAniHighLigh or true
    --  排列方式
    self.m_Options.LayoutStyle = self.m_Options.LayoutStyle or CardPanel.EnumLayoutStyle.Align_Center
    --  最大列数
    self.m_Options.MaxCol = self.m_Options.MaxCol or 8
    --  列间距  
    self.m_Options.ColGap = self.m_Options.ColGap or 30
    --  行间距   
    self.m_Options.RowGap = self.m_Options.RowGap or 30
end

function CardPanel:initUI()
    self:initCard()
    self:composing()
end

--  初始化卡牌
function CardPanel:initCard()
    for i, v in pairs(self.m_Data) do
        local lCardID = v.CardID
        local lLottery = v.Lottery
        local lCard = Card.new(lCardID)
        self:addChild(lCard)
        table.insert(self.m_ListCard, lCard)
        if lLottery == 1 then
            table.insert(self.m_ListLottery, lCard)
        end
    end
end

--  根据当前排列方式排版
function CardPanel:composing()
    if self.m_Options.LayoutStyle == CardPanel.EnumLayoutStyle.Align_Center then
        self:layoutForAlignCenter()
    elseif self.m_Options.LayoutStyle == CardPanel.EnumLayoutStyle.Align_Left then
        self:layoutForAlignLeft()
    end
end

--[[
    @biref  更变卡牌数据并重新绘制排版；
    @data   卡牌数据
--]]
function CardPanel:changeData(data)
    self:clean()
    self.m_Data = data
    self:initCard()
    self:composing()
end

--  设置是否显示高亮动画
function CardPanel:setShowAniHighLight(isLight)
    self.m_Options.ShowAniHighLight = isLight
end

--[[
    @biref  设置排列方式；
            设置后需要手动调用composing方法重新排版
    @lLayoutStyle 排列方式枚举值，参考 “CardPanel.EnumLayoutStyle”变量
--]]
function CardPanel:setLayoutStyle(lLayoutStyle)
    self.m_Options.LayoutStyle = lLayoutStyle
end

--[[
    @biref  设置最大列数；
            设置后需要手动调用composing方法重新排版
    @maxCol 最大列数值
--]]
function CardPanel:setMaxCol(maxCol)
    self.m_Options.MaxCol = maxCol
end

--[[
    @biref  设置列和行的间距；
            设置后需要手动调用composing方法重新排版
    @colGap 列间距
    @rowGap 行间距
--]]
function CardPanel:setColAndRowGap(colGap, rowGap)
    self:setColGap(colGap)
    self:setRowGap(rowGap)
end

--[[
    @biref  设置列间距；
            设置后需要手动调用composing方法重新排版
    @colGap 列间距，小于0时取0值
--]]
function CardPanel:setColGap(colGap)
    if colGap < 0 then
        colGap = 0
    end
    self.m_Options.ColGap = colGap
end

--[[
    @biref  设置行间距；
            设置后需要手动调用composing方法重新排版
    @rowGap 行间距，小于0时取0值
--]]
function CardPanel:setRowGap(rowGap)
    if rowGap < 0 then
        rowGap = 0
    end
    self.m_Options.RowGap = rowGap
end

--  清除卡牌
function CardPanel:clean()
    self:removeAllChildren()
    self.m_ListCard = {}
    self.m_ListLottery = {}
    self.m_Data = {}
end

--  居中对齐排列
function CardPanel:layoutForAlignCenter()
    local data =
    {
        ObjList = self.m_ListCard,
        MaxCol = self.m_Options.MaxCol,
        ColGap = self.m_Options.ColGap,
        RowGap = self.m_Options.RowGap,
    }
    local lComposeData = MjTool:alignCenter(data)
          
    self.m_ActualCol = lComposeData.ActualCol
    self.m_ActualRow = lComposeData.ActualRow
    self:setContentSize(lComposeData.ComposeSize)
end

--  左对齐排列
function CardPanel:layoutForAlignLeft()
    local data =
    {
        ObjList = self.m_ListCard,
        MaxCol = self.m_Options.MaxCol,
        ColGap = self.m_Options.ColGap,
        RowGap = self.m_Options.RowGap,
    }
    local lComposeData = MjTool:alignLeft(data)
          
    self.m_ActualCol = lComposeData.ActualCol
    self.m_ActualRow = lComposeData.ActualRow
    self:setContentSize(lComposeData.ComposeSize)
end

--  执行翻牌动画，逐个翻牌
function CardPanel:doAniTurnCardOneByOne()
    self.m_AniCardIndex = 0    --  重置卡牌索引
    local lGapTime = 0.1    --  翻牌间隔时间
    local scheduler = cc.Director:getInstance():getScheduler()
    self.m_SchedulerID = scheduler:scheduleScriptFunc(handler(self, self.dealAniTurnCard), lGapTime, false)

    if not self.m_Options.ShowAniHighLight then
        --  不需要高亮动画
        self.m_AniTime = lGapTime * #self.m_ListCard
        return
    end

    local lLightTime = 0    --  高亮动画时间
    if #self.m_ListLottery > 0 then
        lLightTime = 1
    end
    self.m_AniTime = lGapTime * #self.m_ListCard + lLightTime
    self:performWithDelay( function()
        for i, v in pairs(self.m_ListLottery) do
            v:doAniHighLight()
        end
    end , self.m_AniTime)
end

--  处理逐个翻牌动画逻辑
function CardPanel:dealAniTurnCard()
    self.m_AniCardIndex = self.m_AniCardIndex + 1
    self.m_ListCard[self.m_AniCardIndex]:doAniTurnCard()

    if self.m_AniCardIndex >= #self.m_ListCard then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_SchedulerID)
    end
end

--  执行翻牌动画，全部牌同时翻转
function CardPanel:doAniTurnCardAll()
    for i, v in pairs(self.m_ListCard) do
        v:doAniTurnCard()
    end

    local lLightTime = 1    --  高亮动画时间
    self:performWithDelay( function()
        for i, v in pairs(self.m_ListLottery) do
            v:doAniHighLight()
        end
    end , lLightTime)

    self.m_AniTime = 0.5 + lLightTime
end

return CardPanel
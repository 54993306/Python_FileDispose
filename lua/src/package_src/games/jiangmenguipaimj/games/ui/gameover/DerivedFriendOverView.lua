--
-- Author: RuiHao Lin
-- Date: 2017-05-10 11:03:32
--

require("app.DebugHelper")

local Mj = require "app.games.common.mahjong.Mj"
local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")
local lFriendOverView = require("app.games.common.ui.gameover.FriendOverView")
local DerivedFriendOverView = class("DerivedFriendOverView", lFriendOverView)

--  中马图标
local lImgIconZhongMa = "games/common/game/icon_zhongma.png"
--  全马图标
local lImgIconQuanMa = "games/common/game/icon_quanma.png"

--  override
function DerivedFriendOverView:ctor(data)
    self.super.ctor(self.super, data)
end

--  override
function DerivedFriendOverView:onInit()
    self.super.onInit(self)
    self:showGuiPaiTitle()
    self:showTurnCardType()
    self:showAniTurnCard()
    self:dealTurnCard()
end

--  处理翻牌显示（花牌处）
function DerivedFriendOverView:dealTurnCard()
    local lGameOverData = self.gameSystem:getGameOverDatas()
    local lFlowerCard = { }
    local lTurnCard = { }

    for i, v in pairs(self.m_PlayerCardList) do
        if #v.FlowerCards > 0 then
            lFlowerCard[i] = v.FlowerCards
        else
            lFlowerCard[i] = {}
        end
    end

    for i, v in pairs(lGameOverData.score) do
        if #v.TurnCardList > 0 then
            lTurnCard = v.TurnCardList
        end
    end
    dump(lTurnCard, "DerivedFriendOverView:dealTurnCard ======== lTurnCard")

    for i = 1, #lFlowerCard do
        for _, v in pairs(lFlowerCard[i]) do
            local lFlowerCardID = v:getValue()
            local lIsLottery = false
            for j, k in pairs(lTurnCard) do
                local lTurnCardID = k.faI
                local lLottery = k.isM
                if lFlowerCardID == lTurnCardID and lLottery == 1 then
                    lIsLottery = true
                    break
                end
            end
            if not lIsLottery then
                v:setMjState(enMjState.MJ_STATE_CANT_TOUCH)
            end
        end
    end
end

--  显示鬼牌标题
function DerivedFriendOverView:showGuiPaiTitle()
    local lGuiPaiTip = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_tip")
    lGuiPaiTip:setString("鬼牌：")
end

--  override
-- 添加赖子角标
function DerivedFriendOverView:addLaiziIcon(majiang)
    local laiziPng = cc.Sprite:create(GC_TurnLaiziPath_2)
    laiziPng:setScale(0.5)
    laiziPng:setPosition(cc.p(-4, -6))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
end

--  显示翻牌类型
function DerivedFriendOverView:showTurnCardType()
    local lGameOverData = self.gameSystem:getGameOverDatas()
    for i, v in pairs(self.playerPanels) do
        if #lGameOverData.score[i].flowerCards > 0 then

            local lLine = ccui.Helper:seekWidgetByName(v, "line")
            lLine:setVisible(false)

            local lRightCardPanel = ccui.Helper:seekWidgetByName(v, "right_card_panel")
            lRightCardPanel:setPositionX(lRightCardPanel:getPositionX() + 20)

            local lTurnCardTitle = { }
            local lTurnCardType = lGameOverData.score[i].TurnCardType
            if lTurnCardType == 0 then
                lTurnCardTitle = cc.Sprite:create(lImgIconZhongMa)
            elseif lTurnCardType == 1 then
                lTurnCardTitle = cc.Sprite:create(lImgIconZhongMa)
            elseif lTurnCardType == 2 then
                lTurnCardTitle = cc.Sprite:create(lImgIconQuanMa)
            end
            lRightCardPanel:addChild(lTurnCardTitle)
            lTurnCardTitle:setAnchorPoint(cc.p(1, 0.5))
            lTurnCardTitle:setPosition(cc.p(lTurnCardTitle:getContentSize().width / 2 - 20, lRightCardPanel:getContentSize().height / 2))
        end
    end
end

--  展现翻牌动画
function DerivedFriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)
    local lGameOverData = self.gameSystem:getGameOverDatas()
    local lTurnCardList = { }
    for i, v in ipairs(lGameOverData.score) do
        local lCardList = v.TurnCardList
        if #lCardList > 0 then
            for j, k in ipairs(lCardList) do
                local item = { CardID = k.faI, Lottery = k.isM }
                table.insert(lTurnCardList, item)
            end
            break
        end
    end

    --  没有翻牌数据则直接跳过翻牌动画
    if #lTurnCardList <= 0 then
        self:setOverViewVisible(true)
        return
    end

    --  添加翻牌动画

    local scene = cc.Director:getInstance():getRunningScene()
    local lLayerTurnCard = LayerTurnCard.new(lTurnCardList)
    scene:addChild(lLayerTurnCard, 999)
    lLayerTurnCard:doAniTurnCardOneByOne()
    local lDelayTime = 0
    if #lLayerTurnCard.m_CardPanel.m_ListLottery > 0 then
        lDelayTime = 2
    else
        lDelayTime = 1
    end
    local lTime = lLayerTurnCard.m_AniTime + lDelayTime
    scene:performWithDelay( function()
        lLayerTurnCard:closed()
        self:setOverViewVisible(true)
    end , lTime)
end

--  设置结算界面的可见性
function DerivedFriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end

--  override
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function DerivedFriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setVisible(true)
    local buf = ""
    local name = scoreitems.policyName or {}

    if #name > 0 then
        for i = 1, #name do
            local format = name[i] .. "   "
            buf = buf .. format
        end
    end

    lab_fan:setString(buf)
end

return DerivedFriendOverView

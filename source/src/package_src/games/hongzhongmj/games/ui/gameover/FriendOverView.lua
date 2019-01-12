local Mj     = require("app.games.common.mahjong.Mj")
local kLaiziPang = "games/common/game/friendRoom/mjOver/laizi.png"

local kResPath = "package_res/games/hongzhongmj/game/"
-- --加载公共模块
require("app.games.common.ui.gameover.FriendOverView")

------------------------
-- 设置玩家详情 (只显示pon)
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function FriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setString("")
    -- 只显示赢的玩家
    if scoreitems.result == enResult.WIN then
        lab_fan:setVisible(true)
    else
        lab_fan:setVisible(false)
    end
    -- 显示胡牌提示
    local detail = ""
    local pon = scoreitems.policyName or {}
    if #pon > 0 then
        local textUnit = " "
        local policyName = ""
        for i=1, #pon do
            policyName = pon[i]..textUnit
            detail = detail..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end
    -- 显示杠牌数量
    if scoreitems.gang > 0 then
        local gangStr = string.format("杠牌(%d花)", scoreitems.gang)
        detail = detail .. " " .. gangStr
    end
    -- 显示花牌数量
    if #scoreitems.flowerCards > 0 then
        local huaStr = string.format("花牌(%d花)", #scoreitems.flowerCards)
        detail = detail .. " " .. huaStr
    end
    lab_fan:setString(detail)
end

-------------------------------
-- 显示赖子 (变为显示翻马)
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function FriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    laiziName:setString("")
    -- self:showFanMa(laiziPanel, laiziName)
end

------------------------
-- 设置规则 (调整规则位置)
-- @param lab_rule  待设置的规则label
-- @param wanfa     玩法字符串: palyingInfo.wa
function FriendOverView:setRule(lab_rule, wanfa)
    local originWidth = lab_rule:getContentSize().width
    local originMargin = lab_rule:getLayoutParameter():getMargin()
    Log.i("getMargin()", originMargin)
    local itemList= Util.analyzeString_2(wanfa)
    Log.i("itemList.....",itemList)
    local ruleStr = ""
    if (#itemList > 0 ) then
        for i, v in pairs(itemList) do
            local content = kFriendRoomInfo:getPlayingInfoByTitle(v)
            if ruleStr == "" then
                ruleStr = content.ch
            else
                ruleStr = string.format("%s %s", ruleStr, content.ch)
            end
        end
    end

    lab_rule:setString(ruleStr)
    originMargin.left = originMargin.left + originWidth - lab_rule:getContentSize().width
    Log.i("getMargin()", originMargin)
    
    lab_rule:getLayoutParameter():setMargin(originMargin)
end

--------------------------
-- 添加赖子角标 (调整位置)
function FriendOverView:addLaiziIcon(majiang)
    local laiziPng = cc.Sprite:create(kLaiziPang)
    laiziPng:setPosition(cc.p(-2, -7))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
end

function FriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == enGameOverType.ZI_MO then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture(kResPath .. "qiangganghuicon.png", ccui.TextureResType.localType)
        else
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        end
        img_hu:setVisible(true)
        -- 只有赢家显示翻马
        local hua_mj = ccui.Helper:seekWidgetByName(img_hu:getParent():getParent(), "right_card_panel")
        self:showFanMa({}, hua_mj)
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)
        and self.gameOverDatas.winType == enGameOverType.FANG_PAO then
        img_hu:setVisible(true)
        img_hu:loadTexture("games/common/game/friendRoom/mjOver/fangpao.png", ccui.TextureResType.localType)
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED) -- 加入抢杠胡
        and self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
        img_hu:setVisible(true)
        img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qianggang.png", ccui.TextureResType.localType)
    else
        img_hu:setVisible(false)
    end
end

------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showFanMa(flowerCards, parent)
    -- dump()
    flowerCards = self.gameOverDatas.faI
    local total=0
    if flowerCards and #flowerCards > 0 and parent then
        for i,k in pairs(flowerCards) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k.faI6)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(32 / mjSize.width)
            flowSp:setScaleY(40 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
            flowSp:addTo(parent)
            if k.isM==1 then
                total=total+1
            else
                flowSp:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
            end
        end

        local ma=nil
        if total==#flowerCards then
            ma=display.newSprite(kResPath .. "icon_quanma.png")
        elseif total==0 then
            ma=display.newSprite(kResPath .. "icon_wuma.png")
        else
            ma=display.newSprite(kResPath .. "icon_zhongma.png")
           
        end
        ma:setPosition(cc.p(-15,30))
        ma:addTo(parent)
    end
end

local Mj     = require("app.games.common.mahjong.Mj")
local kLaiziPang = "games/common/game/friendRoom/mjOver/laizi.png"

local kResPath = "games/baisemj/game/fama/"
-- --加载公共模块
require("app.games.common.ui.gameover.FriendOverView")


-- 设置玩家详情
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
    local pos = scoreitems.policyScore or {}
    if #pon > 0  
        and #pos > 0 then
        local textUnit = " "
        local policyName = ""
        for i=1, #pon do
            policyName = pon[i]..textUnit--..pos[i]
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

-- 显示翻马
function FriendOverView:showFanMa(item, maimaList, isQiangGang, result, isEF)
    -- print("FriendOverView:showFanMa=============",#maimaList)
    -- dump(maimaList)
    Log.i("FriendOverView:showFanMa=============",maimaList)
    --UI只显示中的马
    local isHaveMa = false
    local isAllMa = true
    -- if self.gameOverDatas.isND ==1 then -- 有翻马
        local currentIndex = 1
        local maList = maimaList or {} --结算数据中有买马
        for i = 1, #maList do
            local tmpData = maList[i]

            -- --- 显示翻马牌
            -- local maMj = Mj.new(enMjType.MYSELF_PENG, tmpData.faI6)
            -- maMj:setScaleX(20 / maMj:getContentSize().width)
            -- maMj:setScaleY(28 / maMj:getContentSize().height)
            -- local mjSize = cc.size(maMj:getContentSize().width * maMj:getScaleX(), maMj:getContentSize().height * maMj:getScaleY())

            --- 显示翻马牌
            local maMj = Mj.new(enMjType.MYSELF_PENG, tmpData.faI6)
            maMj:setScaleX(20 / maMj:getContentSize().width)
            maMj:setScaleY(28 / maMj:getContentSize().height)
            local mjSize = cc.size(maMj:getContentSize().width * maMj:getScaleX(), maMj:getContentSize().height * maMj:getScaleY())

            -- 补马间距
            local lastDis = 0;
            if isEF and i == #maList then
                lastDis = 10;
            end
            if i <= 12 then
                maMj:setPosition(cc.p(mjSize.width * i + 30 +760 + lastDis, item:getContentSize().height*0.5 + 21 ))
            else
                maMj:setPosition(cc.p(mjSize.width * (i-12) + 30 +760 + lastDis, item:getContentSize().height*0.5 - 12 ))
            end
            
            maMj:setAnchorPoint(cc.p(0.5, 0))
            item:addChild(maMj)

            -- 中马
            if tmpData.isM == 1 then --isM  int  是否中马(0: 不中   1:中)
                isHaveMa = true
            else
                isAllMa = false
                maMj:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
            end
        end

        -- print("/////////////////////////////",#maList)
        -- 是否全马  games/luoyangmj/common/icon_ci.png
        if #maList > 0 then 
            local img=display.newSprite("package_res/games/shanweimj/game/icon_zhongma.png");
            img:setPosition(cc.p(776, item:getContentSize().height*0.5 +17))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            item:addChild(img)
        end
        
        --被抢杠胡
        -- if  self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU and isQiangGang then--(result == enResult.FANGPAO or result == enResult.FAILED) and self.gameOverDatas.winType == enGameOverType.FANG_PAO
        --      local img=display.newSprite("package_res/games/shanweimj/game/qianggang.png");
        --      img:setPosition(cc.p(850, item:getContentSize().height*0.5))
        --      img:setAnchorPoint(cc.p(0.5, 0.5))
        --      img:setScale(0.9)
        --      item:addChild(img)
        --  end 
    -- end
end


function FriendOverView:addPlayers()

    local players  = self.gameSystem:gameStartGetPlayers()       -- 玩家信息    
    self.playerNum = #players
    local itemInterval = 10              --默认四人房
    local offsetY = 30

    --修改 20171110 start 竖版换皮  diyal.yin
    --修改 20171110 end 竖版换皮 diyal.yin

    if self.playerNum == 3 then 
        itemInterval = itemInterval + 30
        offsetY = offsetY - 20
    elseif self.playerNum == 2 then
        itemInterval = itemInterval + 60
    end
    local bg = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg2");
    local bg_size = bg:getContentSize()
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_over_item.csb")
    math.randomseed(os.time())
    for i = 1, #players do
        self.m_PlayerCardList[i] = self.m_PlayerCardList[i] or {}
        local item  = itemModel:clone()
        item:setPosition(cc.p(14, bg_size.height - offsetY -(item:getContentSize().height + itemInterval) * i ))
        bg:addChild(item, 1);
        table.insert(self.playerPanels, item)
        local scoreitem = self.m_scoreitems[i]

        local lab_fan = ccui.Helper:seekWidgetByName(item, "event_text");
        self:setPlayerDetail(lab_fan, scoreitem)
        self:initHeadImage(item,players[i])
        self:initZhuangImg(item,players[i])
        self:initPlayerName(item,scoreitem)  
        self:initScore(item,scoreitem)                -- 区分正负，如果大于0就是正数，小于等于0就默认显示   
        self:initHuImage(item,scoreitem)

        local pan_mj = ccui.Helper:seekWidgetByName(item, "left_card_panel");  
        pan_mj.player = players[i]  
        self:addPlayerMjs(i,pan_mj)

        local line = ccui.Helper:seekWidgetByName(item, "line")
        -- line:setVisible(#scoreitem.flowerCards > 0)
        line:setVisible(false)

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj)
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards

        local usId = tostring(players[i]:getProp(enCreatureEntityProp.USERID))
        local maimaList = self.gameOverDatas.maima[usId] or {}
        self:showFanMa(item, maimaList, false, scoreitem.result, isEF)

        local laiziPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_pannel")
        local laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
        laiziName:setString("翻马:")
        --马牌信息
        self:showTotleMaPai(self.gameOverDatas.fanma,laiziPanel)
    end
end

function FriendOverView:showTotleMaPai(maCards,parent)
    print("FriendOverView:showTotleMaPai")

    -- if self.gameOverDatas.winType == 3 then
    --     parent:setVisible(false)

    --翻马数量为0的话就不显示翻马字体
    if self.gameOverDatas.fanma and #self.gameOverDatas.fanma == 0 then
        parent:setVisible(false)
    else
        parent:setVisible(true)
        -- print("FriendOverView:showTotleMaPai==============")
        -- dump(maCards)
        Log.i("FriendOverView:showTotleMaPai==============",maCards)
        for i,v in ipairs(maCards) do
            local maSp = Mj.new(enMjType.MYSELF_PENG,v.faI6)
            local mjSize = maSp:getContentSize()
             if v.isM == 0 then
                 maSp:setColor(cc.c3b(128,128,128))--暗显示
             elseif v.isM == 1 then
                 maSp:setColor(cc.c3b(255,255,0))                   --高亮显示
             end

            -- maSp:setScaleX(32/mjSize.width)
            -- maSp:setScaleY(40/mjSize.height)
            maSp:setScale(0.4)
            mjSize.width = mjSize.width * maSp:getScaleX()
            mjSize.height = mjSize.height * maSp:getScaleY()
            maSp:setPosition(cc.p((i-1)*mjSize.width+70,35))
            maSp:addTo(parent)
        end
    end
end

-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showFlower(flowerCards, parent)
    local lCardList = {}
    if flowerCards and #flowerCards > 0 and parent then
        local img=display.newSprite("package_res/games/shanweimj/game/icon_flower.png");
        img:setPosition(cc.p(-4, -7))
        img:setAnchorPoint(cc.p(0, 0))
        parent:addChild(img)

        for i,k in pairs(flowerCards) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(28 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5+(mjSize.width-1), (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 19))
            flowSp:addTo(parent)

            table.insert(lCardList, flowSp)
        end
    end

    return lCardList
end

-- 设置玩家详情
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
    local pos = scoreitems.policyScore or {}
    if #pon > 0  
        and #pos > 0 then
        local textUnit = "番 "
        local policyName = ""
        for i=1, #pon do
            if pon[i] ~= "直杠" and pon[i] ~= "补杠" and pon[i] ~= "暗杠" then
                policyName = pon[i]..pos[i]..textUnit
                detail = detail..policyName
            end
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

function FriendOverView:getMjGroup(operateType,firstMj)
    local cardGroup = {}
    if operateType == enOperate.OPERATE_CHI then
        cardGroup = {firstMj, firstMj + 1, firstMj + 2}
    elseif operateType == enOperate.OPERATE_PENG then
        cardGroup = {firstMj, firstMj, firstMj}
    elseif operateType == enOperate.OPERATE_MING_GANG 
        or operateType == enOperate.OPERATE_AN_GANG 
        or operateType == enOperate.OPERATE_JIA_GANG
        or operateType == enOperate.OPERATE_YANGMA then
        cardGroup = {firstMj, firstMj, firstMj, firstMj}
    else
        cardGroup = {}
    end
    return cardGroup
end

function FriendOverView:getBlackIndex(operateType,site)
    site = self:convertSiteByPlayerNum(site)   
    if operateType == enOperate.OPERATE_PENG then
        if site == enSiteDirection.SITE_RIGHT then    -- 下家
            return 3                                  -- 4人麻将，碰,下家的牌，第3张,变暗 
        elseif site == enSiteDirection.SITE_LEFT then -- 上家
            return 1
        elseif site == enSiteDirection.SITE_OTHER then -- 对家
            return 2
        end
    elseif operateType == enOperate.OPERATE_MING_GANG
        or operateType == enOperate.OPERATE_JIA_GANG
        or operateType == enOperate.OPERATE_YANGMA then
        if site == enSiteDirection.SITE_RIGHT then    -- 下家
            return 4                                  -- 4人麻将，杠,下家的牌，第4张,变暗 
        elseif site == enSiteDirection.SITE_LEFT then -- 上家
            return 1
        elseif site == enSiteDirection.SITE_OTHER then -- 对家
            return 2
        end
    end
    return 0
end

----------------------------
-- 添加麻将组的标记
function FriendOverView:addGroupIcon(groupNode, operateType, cardGroup)
    local groupSize = groupNode:getContentSize()
    local lTipsFilePath = ""
    if operateType == enOperate.OPERATE_AN_GANG then
        lTipsFilePath = "games/common/mj/common/angang.png"
    elseif operateType == enOperate.OPERATE_MING_GANG then
        lTipsFilePath = "games/common/mj/common/minggang.png"
    elseif operateType == enOperate.OPERATE_JIA_GANG then
        lTipsFilePath = "games/common/mj/common/bugang.png"
    elseif operateType == enOperate.OPERATE_YANGMA then
        local atBg = display.newSprite("games/common/mj/common/angang_bg.png")
        atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 + 8))
        atBg:setScale(groupSize.width / atBg:getContentSize().width)
        groupNode:addChild(atBg)

        local atIcon = display.newSprite("package_res/games/shanweimj/game/yangma.png")
        atIcon:setPosition(cc.p(atBg:getContentSize().width /2  , atBg:getContentSize().height / 2 ))
        atBg:addChild(atIcon)
        return
    elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
        -- 根据赢家的Index来获取胡的牌, 然后在与胡的牌相同的碰牌上, 显示抢杠标签
        local winnerIndex = 1
        for i = 1, #self.m_scoreitems do
            if self.m_scoreitems[i].result == enResult.WIN then
                winnerIndex = i
                break
            end
        end
        --  如果抢杠的牌是癞子，则用HuCard来识别
        local humj = {}
        local lHuCard = self.m_scoreitems[winnerIndex].HuCard
        if lHuCard then
            humj = lHuCard
        else
            humj = self.m_scoreitems[winnerIndex].lastCard
        end
        if humj == cardGroup[1] then
            Log.i("FriendOverView:addGroupIcon find qianggang", humj)
            local atBg = display.newSprite("games/common/game/friendRoom/mjOver/qianggang.png")

            --修改 20171110 start 竖版换皮  diyal.yin
            -- atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
            atBg:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height + 8))
            --修改 20171110 end 竖版换皮 diyal.yin

            atBg:setScale(groupSize.width / atBg:getContentSize().width)
            groupNode:addChild(atBg)
        end
        return
    else
        return
    end
    local lTipsBG = cc.Sprite:create("games/common/mj/common/angang_bg.png")
    groupNode:addChild(lTipsBG)

    --修改 20171110 start 竖版换皮  diyal.yin
    -- lTipsBG:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height / 2 - 28))
    lTipsBG:setPosition(cc.p(groupSize.width / 2 - 18, groupSize.height + 8))
    --修改 20171110 end 竖版换皮 diyal.yin
    lTipsBG:setScale(groupSize.width / lTipsBG:getContentSize().width)

    print("------------addGroupIcon",lTipsFilePath)
    local lTips = cc.Sprite:create(lTipsFilePath)
    lTips:setPosition(cc.p(lTipsBG:getContentSize().width / 2, lTipsBG:getContentSize().height / 2))
    lTipsBG:addChild(lTips)
end

return FriendOverView
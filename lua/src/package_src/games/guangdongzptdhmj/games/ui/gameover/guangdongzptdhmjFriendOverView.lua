require("app.DebugHelper")
local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")
local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")
local LayerTurnCardMultiplayer = require("app.games.common.custom.TurnCard.LayerTurnCardMultiplayer")

local flowerdeviation = 150 --- flowercard            防止杠四次麻将牌会和花牌界面重合的偏移量

local linedeviation = 141---------line

local SHOW_FANMA = 1  ---- 显示翻马
local NOT_SHOW_FANMA = 0  ---- 不显示翻马

local Mj    		= require "app.games.common.mahjong.Mj"
local guangdongzptdhmjFriendOverView = class("guangdongzptdhmjFriendOverView", FriendOverView)
local kLaiziPang2 = "package_res/games/guangdongzptdhmj/game/icon_guipaijiaobiao.png"
--GC_TurnLaiziPath_2 = "package_res/games/guangdongzptdhmj/game/icon_guipai.png"


function guangdongzptdhmjFriendOverView:ctor(data)
    self.super.ctor(self.super, data)
end

---------------------------------------------------------------------------
function guangdongzptdhmjFriendOverView:onInit()
    self.super.onInit(self) 
    local laiziPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_pannel")
    local laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
    laiziName:setString("鬼牌:")
    self:showAniTurnCard()
end

--function guangdongzptdhmjFriendOverView:showLaiziList()
--    laiziName:setString("鬼牌:") 
--    self.super.showLaiziList(self)
--end

function guangdongzptdhmjFriendOverView:addLaiziIcon(majiang)
    
    local laiziPng = cc.Sprite:create(kLaiziPang2)
--  laiziPng:setScale(0.5)
    laiziPng:setPosition(cc.p(-4, -6))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
end
function guangdongzptdhmjFriendOverView:addPlayers()
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
        line:setVisible(#self.gameOverDatas.faI > 0 and scoreitem.showMa == SHOW_FANMA)

        line:setPositionX(display.cx + linedeviation)--xiong
        line:getParent():requestDoLayout()

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")


        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj, scoreitem.showMa)----------------加多一个参数

        hua_mj:setPositionX(display.cx + flowerdeviation)--xiong
        hua_mj:getParent():requestDoLayout()
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards
    end
end

----------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function guangdongzptdhmjFriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setString("")
    -- 只显示赢的玩家
    -- if scoreitems.result == enResult.WIN then
    --     lab_fan:setVisible(true)
    -- else
    --     lab_fan:setVisible(false)
    -- end
    -- 显示胡牌提示
    local detail = ""
    local pon = scoreitems.policyName or {}
    local pos = scoreitems.policyScore or {}
    if #pon > 0 and #pos > 0 then
        local policyName = ""
        for i=1, #pon do
            local posStr = ""
            if pos[i] > 0 then
                posStr = "(x"..pos[i]..")"
            end
            policyName = " "..pon[i]..posStr  
            detail = detail..policyName
        end
    end
    lab_fan:setString(detail)

end

function guangdongzptdhmjFriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/guangdongzptdhmj/image/qiangganghu.png", ccui.TextureResType.localType)
        else
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        end
        img_hu:setVisible(true)
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED)
        and self.gameOverDatas.winType == enGameOverType.FANG_PAO then
        img_hu:setVisible(true)
        img_hu:loadTexture("games/common/game/friendRoom/mjOver/fangpao.png", ccui.TextureResType.localType)
    elseif (scoreitems.result == enResult.FANGPAO or scoreitems.result == enResult.FAILED ) -- 加入抢杠胡
        and self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
        img_hu:setVisible(true)
        img_hu:loadTexture("games/common/game/friendRoom/mjOver/icon_qianggang.png", ccui.TextureResType.localType)
    else
        img_hu:setVisible(false)
    end
end

function guangdongzptdhmjFriendOverView:showFlower(flowerCards, parent,result)
    local faI = self.gameOverDatas.faI
    local lCardList = {}
    --Log.i("faIfaIfaI",faI)
    local flower = {}
    for i = 1 , #faI do
        local ac  = faI[i]
        --Log.i("acacacac",ac)
        local ax = ac.faI6
       -- Log.i("axaxaxax",ax)
        table.insert(flower,ax)
        
    end
  --  Log.i("huapai",flower)

    
    if flower and #flower > 0 and parent and result == SHOW_FANMA then
        for i,k in pairs(flower) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k)
            flowSp:setOpacity(125)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(28 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
--            if faI[i].isM == 0 then  
--                flowSp:setOpacity(125)
--            end 
            for o,p in pairs (flowerCards) do 
                if p ==k then 
                    flowSp:setOpacity(255)
                end

            end

            flowSp:addTo(parent)

            table.insert(lCardList, flowSp)
        end
    end

    
    if flower and #flower > 0 and parent and result == SHOW_FANMA  then
        local zhongma = display.newSprite("package_res/games/guangdongzptdhmj/game/zhongma.png")
        zhongma:addTo(parent)
        zhongma:setPosition(cc.p(-25,parent:getContentSize().height/2))
    end

    return lCardList
end


--  展现翻牌动画
function guangdongzptdhmjFriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)   
    local scene = cc.Director:getInstance():getRunningScene()
    local lGameOverData = self.gameSystem:getGameOverDatas()

    local lTurnCardList = { }    -- 总翻马
    local tmp
    for k,v in pairs(lGameOverData.faI) do
        tmp = {}
        if v.isM == 0 then
            tmp.Lottery = v.isM
        else
            tmp.Lottery = 1
        end
        tmp.CardID = v.faI6
        table.insert(lTurnCardList, tmp)
    end

    local lTurnCardListMulti = { }  -- 玩家分开翻马

    for k,v in pairs(lGameOverData.score) do
        -----
        -- 需要显示翻马玩家的马牌
        if v.showMa == SHOW_FANMA then
            local lCardList = { }
            lCardList.UserID = v.userid

            local zhongmaList = v.flowerCards
            local tmpMaCardList = {}
            for _k,_v in pairs(lTurnCardList) do
                local tmpData = {}
                tmpData.CardID = _v.CardID
                if self:checkZhongma(_v.CardID, zhongmaList) then
                    tmpData.Lottery = 1
                else
                    tmpData.Lottery = 0
                end
                table.insert(tmpMaCardList, tmpData)
            end
            lCardList.CardList = tmpMaCardList
            table.insert(lTurnCardListMulti, lCardList)
        end
    end

    local function playFanma()
        local lLayerTurnCard = LayerTurnCard.new(lTurnCardList)
        scene:addChild(lLayerTurnCard, 999)
        lLayerTurnCard:doAniTurnCardOneByOne()
        local lDelayTime = lLayerTurnCard.m_AniTime + 3
        scene:performWithDelay( function()
            lLayerTurnCard:closed()
            self:setOverViewVisible(true)
        end , lDelayTime)
    end

    local function playFanmaMulti()
        local lLayerTurnCard = LayerTurnCardMultiplayer.new(lTurnCardListMulti)
        scene:addChild(lLayerTurnCard, 999)
        lLayerTurnCard:doAniTurnCardOneByOne()
        local lDelayTime = lLayerTurnCard.m_AniTime + 3
        scene:performWithDelay( function()
            lLayerTurnCard:closed()
            self:setOverViewVisible(true)
        end , lDelayTime)
    end

    --  没有翻牌数据则直接跳过翻牌动画
    if #lTurnCardList <= 0 then
        self:setOverViewVisible(true)
        return
    elseif #lTurnCardList > 0 and #lTurnCardListMulti <= 1 then
        playFanma()
        return
    elseif #lTurnCardList > 0 and #lTurnCardListMulti > 1 then
        playFanmaMulti()
        return
    end
end

-- 检查是否中马
-- maValue(number) 马牌值    zhongmaList(table)  中马列表
function guangdongzptdhmjFriendOverView:checkZhongma(maValue, zhongList)
    if maValue == nil or zhongList == nil then
        return
    end
    if type(zhongList) ~= "table" then
        return
    end
    for k,v in pairs(zhongList) do
        if maValue == v then
            return true
        end
    end
    return false
end

--  设置结算界面的可见性
function guangdongzptdhmjFriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end

return guangdongzptdhmjFriendOverView

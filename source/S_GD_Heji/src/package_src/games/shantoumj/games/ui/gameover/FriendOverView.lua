local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"
local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")
local LayerTurnCardMultiplayer = require("app.games.common.custom.TurnCard.LayerTurnCardMultiplayer")

require("app.DebugHelper")
require "app.games.common.ui.gameover.FriendOverView"

local getZhuangText = function(zhuangSite, site, playerCount)
    local siteMap4 = {
            [1] = {
            [2] = "庄下家",
            [3] = "庄对家",
            [4] = "庄上家",
            },
            [2] = {
            [1] = "庄上家",
            [3] = "庄下家",
            [4] = "庄对家",
            },
            [3] = {
            [1] = "庄对家",
            [2] = "庄上家",
            [4] = "庄下家",
            },
            [4] = {
            [1] = "庄下家",
            [2] = "庄对家",
            [3] = "庄上家",
            }
    }

    local siteMap3 = {
        [1] = {
        [2] = "庄下家",
        [3] = "庄上家",
        },
        [2] = {
        [1] = "庄上家",
        [3] = "庄下家",
        },
        [3] = {
        [1] = "庄下家",
        [2] = "庄上家",
        },
    }

    if playerCount == 4 then
        return siteMap4[zhuangSite][site]
    elseif playerCount == 3 then
        return siteMap3[zhuangSite][site]
    else
        return ""
    end

end

local function addButtomPanelInfo(rootWidget, roomId, userId)
    local roomText = ccui.Helper:seekWidgetByName(rootWidget, "root_text")
    roomText:setString(string.format("房号：%d", roomId))
    roomText:enableOutline(cc.c4b(63,34,4,255), 2)
    roomText:setFontSize(21)
    -- roomText:getLayoutParameter():setMargin({ left = 0, right = 10 , top = 0, bottom = 0})

    local userText = ccui.Helper:seekWidgetByName(rootWidget, "playerid_text")
    userText:setString(string.format("玩家ID：%d", userId))
    userText:setVisible(false) --在上面已经显示id了，不需要这个了
    
    local time = os.time()
    local timeStr = os.date("%y.%m.%d %H:%M", time)
    local timeText = ccui.Helper:seekWidgetByName(rootWidget, "time_text")
    timeText:setString(string.format("日期：%s", timeStr))

    local versionText = ccui.Helper:seekWidgetByName(rootWidget, "version_text")
    versionText:setString(string.format("版本号：%s", VERSION))
end

function FriendOverView:onInit()
    if Define.ViewSizeType == 1 then
        local scalePan = ccui.Helper:seekWidgetByName(self.m_pWidget, "panel_scale")
        scalePan:setScale(cc.Director:getInstance():getVisibleSize().height/720)
    end
    self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    self.m_scoreitems   = self.gameSystem:getGameOverDatas().score
    self.gameOverDatas  = self.gameSystem:getGameOverDatas()
    self.isOver  = self.gameSystem:getGameOverDatas().isOver or false
    self.myUserid       = self.gameSystem:getMyUserId()

    self.playerPanels = {}

    --  玩家卡牌列表
    self.m_PlayerCardList = {}

    self.btn_start = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_start");
    self.btn_start:addTouchEventListener(handler(self, self.onClickButton));

    self.lab_rule = ccui.Helper:seekWidgetByName(self.m_pWidget, "game_rules");
    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    self:setRule(self.lab_rule, palyingInfo.wa)

    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_shared")
    self.btn_share:addTouchEventListener(handler(self, self.onClickButton))

    if IS_YINGYONGBAO then
        self.btn_share:setVisible(false)
        local originMargin_start = self.btn_start:getLayoutParameter():getMargin()
        Log.i("originMargin", originMargin_start)
        originMargin_start.left = display.cx - self.btn_start:getContentSize().width / 2
        self.btn_start:getLayoutParameter():setMargin(originMargin_start)
    end
    
    local laiziList = self.gameSystem:getGameStartDatas().laizi
    local laiziPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_pannel")
    local laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
    self:showLaiziList(laiziPanel, laiziList, laiziName)

    local gameName = ccui.Helper:seekWidgetByName(self.m_pWidget, "game_name")
    gameName:enableOutline(cc.c4b(63,34,4,255), 2)
    gameName:setFontSize(21)
    self:setGameName(gameName) -- 设置游戏名称

    local startImage = ccui.Helper:seekWidgetByName(self.m_pWidget, "start_image")
    if kFriendRoomInfo:isGameEnd() or self:isLastGameCount() or self.isOver then --兼容旧版本逻辑所以三个全写上
        startImage:loadTexture("games/common/game/friendRoom/mjOver/text_total_score.png")
    end

    -- 战绩回放中替换为返回按钮
    if VideotapeManager.getInstance():isPlayingVideo() then
        startImage:loadTexture("hall/huanpi2/jiesuan/btn_back.png")
    end

    -- 赢了
    local titleBg = ccui.Helper:seekWidgetByName(self.m_pWidget, "title_bg")
    local img_title = ccui.Helper:seekWidgetByName(self.m_pWidget, "title");

    self:updateTitle(titleBg, img_title)

    local playerInfo = kFriendRoomInfo:getRoomInfo();

    addButtomPanelInfo(self.m_pWidget, playerInfo.pa, self.myUserid)

    -- 玩家信息
    self:addPlayers()

    self:showAniTurnCard()
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

        local img_zhuang = ccui.Helper:seekWidgetByName(item, "img_zhuang");
        --玩家 site  
        local site = players[i]:getProp(enCreatureEntityProp.SITE)
        local zhuangSite = self.gameSystem:gameStartGetBankerSite()

        if site and zhuangSite ~= site and self.playerNum > 2 then
            local imgZuiDetail = display.newSprite("package_res/games/shantoumj/common/site_detail.png")
            item:addChild(imgZuiDetail, 100)
            imgZuiDetail:setPosition(cc.p(55,60))
            print("zahung site ", zhuangSite, site)
            local text = getZhuangText(zhuangSite, site ,#players)
            local labelDesc = cc.Label:createWithTTF(text, "hall/font/fangzhengcuyuan.TTF", 16)
            imgZuiDetail:addChild(labelDesc)
            labelDesc:setAnchorPoint(cc.p(1, 0.5))
            labelDesc:setPosition(imgZuiDetail:getContentSize().width, imgZuiDetail:getContentSize().height * 0.5)
        end

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
        line:setVisible(false)
        if scoreitem.maimaInfo and #scoreitem.maimaInfo > 0 then
            line:setVisible(true)
            local lineParent = line:getParent()

            local maimaImg = ccui.ImageView:create("package_res/games/shantoumj/game/mjover_maima.png")
            maimaImg:setPosition(line:getPositionX() + 26, line:getPositionY() - 20)
            lineParent:addChild(maimaImg)

            local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
            self:showMaima(scoreitem.maimaInfo, hua_mj)
        end

        if (self.gameOverDatas.huCount == 1 and scoreitem.result == enResult.WIN and self.gameOverDatas.ho and #self.gameOverDatas.ho > 0)
        or (self.gameOverDatas.huCount > 1 and scoreitem.result == enResult.FAILED and self.gameOverDatas.ho and #self.gameOverDatas.ho > 0 ) then
            line:setVisible(true)
            local lineParent = line:getParent()

            local jiangmaImg = ccui.ImageView:create("package_res/games/shantoumj/game/mjover_jiangma.png")
            jiangmaImg:setPosition(line:getPositionX() + 26, line:getPositionY() + 20)
            lineParent:addChild(jiangmaImg)

            local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
            self:showJiangma(self.gameOverDatas.ho, hua_mj)
        elseif scoreitem.result == enResult.WIN and self.gameOverDatas.dice and #self.gameOverDatas.dice > 0 then
            line:setVisible(true)
            local lineParent = line:getParent()

            local diceText = ccui.Text:create("倍数：", "hall/font/fangzhengcuyuan.TTF", 24)
            diceText:setColor(cc.c3b(253, 235, 42))
            diceText:setPosition(line:getPositionX() + 40, line:getPositionY() - 15)
            lineParent:addChild(diceText)

            local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
            self:showDice(self.gameOverDatas.dice, hua_mj)
        end
    end
end

function FriendOverView:initZhuangImg(item,player)
    local img_zhuang = ccui.Helper:seekWidgetByName(item, "img_zhuang");
    if player:getProp(enCreatureEntityProp.BANKER) then
        img_zhuang:setVisible(true)
        local needLianzhuang = kFriendRoomInfo:isHavePlayByName("lzfanbei") or kFriendRoomInfo:isHavePlayByName("l4zfanbei") or kFriendRoomInfo:isHavePlayByName("l3zjm")
        local playSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local continueZhuang = playSystem:getGameStartDatas().conZhuang
        if type(continueZhuang) == "number" and continueZhuang > 0 and needLianzhuang then
            local img_textBg = display.newSprite("games/common/game/common/icon_text_bg.png")
            img_zhuang:addChild(img_textBg)
            img_textBg:setPosition(cc.p(38, 43))
            local lab_zhuangNum = cc.ui.UILabel.new(
            {
                UILabelType = 2,
                text = tostring( continueZhuang ),
                color = cc.c3b(253, 252, 172),
                size = 13,            
            })
            :addTo(img_textBg)
            lab_zhuangNum:setPosition(cc.p(9, 9))
            lab_zhuangNum:setAnchorPoint( cc.p(0.5, 0.5) )

            img_textBg:setScale(2)
        end
    else
        img_zhuang:setVisible(false)
    end
end

function FriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/shantoumj/common/qiangganghu.png", ccui.TextureResType.localType)
        else
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/hupai.png", ccui.TextureResType.localType)
        end
        img_hu:setVisible(true)
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
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function FriendOverView:setPlayerDetail(lab_fan, scoreitems)
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
    if #pon > 0  
        and #pos > 0 then
        local policyName = ""
        for i=1, #pon do
            local posStr = ""
            if pos[i] > 0 then
                posStr = "(x"..pos[i]..")"
            end
            policyName = " "..pon[i]..posStr  
            detail = detail..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end
    -- -- 显示杠牌数量
    -- if scoreitems.gang > 0 then
    --     local gangStr = string.format("杠牌(%d花)", scoreitems.gang)
    --     detail = detail .. " " .. gangStr
    -- end
    -- -- 显示花牌数量
    -- if #scoreitems.maimaInfo > 0 then
    --     local huaStr = string.format("花牌(%d花)", #scoreitems.maimaInfo)
    --     detail = detail .. " " .. huaStr
    -- end
    lab_fan:setString(detail)
end


------------------------
-- 结算界面花牌的显示
-- maimaInfo 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showMaima(maimaInfo, parent)
    if maimaInfo and #maimaInfo > 0 and parent then
        for i,k in pairs(maimaInfo) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k.faI6)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(25 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5 + 47, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 - 4))
            flowSp:addTo(parent)

            --显示翻马 是否翻中
            if k.isM == 0 then
                flowSp:blackMj(true)
            elseif k.isM > 0 then
                flowSp:highLight(true)
            end
        end
    end
end

function FriendOverView:showJiangma(maimaInfo, parent)
    if maimaInfo and #maimaInfo > 0 and parent then
        for i,k in pairs(maimaInfo) do
            local flowSp = Mj.new(enMjType.MYSELF_PENG, k.faI6)
            local mjSize = flowSp:getContentSize()
            flowSp:setScaleX(20 / mjSize.width)
            flowSp:setScaleY(25 / mjSize.height)

            mjSize.width = mjSize.width * flowSp:getScaleX()
            mjSize.height = mjSize.height * flowSp:getScaleY()

            local index_x = (i - 1)%12
            flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5 + 47, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 + 30))
            flowSp:addTo(parent)

            --显示翻马 是否翻中
            if k.isM == 0 then
                flowSp:blackMj(true)
            elseif k.isM > 0 then
                flowSp:highLight(true)
            end
        end
    end
end

function FriendOverView:showDice(diceList, parent)
    -- if diceList and #diceList > 0 and parent then
    --     for i,k in pairs(diceList) do
    --         local flowSp = Mj.new(enMjType.MYSELF_PENG, k.faI6)
    --         local mjSize = flowSp:getContentSize()
    --         flowSp:setScaleX(20 / mjSize.width)
    --         flowSp:setScaleY(25 / mjSize.height)

    --         mjSize.width = mjSize.width * flowSp:getScaleX()
    --         mjSize.height = mjSize.height * flowSp:getScaleY()

    --         local index_x = (i - 1)%12
    --         flowSp:setPosition(cc.p((mjSize.width + 1) * index_x + mjSize.width * 0.5 + 47, (mjSize.height + 6) * (1 + math.floor((i-1)/12)) + mjSize.height / 2 + 30))
    --         flowSp:addTo(parent)

    --         --显示翻马 是否翻中
    --         if k.isM == 0 then
    --             flowSp:blackMj(true)
    --         elseif k.isM > 0 then
    --             flowSp:highLight(true)
    --         end
    --     end
    -- end
    local diceCount = 0
    for i = #diceList, 1, -1 do 
        diceCount = diceCount + 1
        local diceImg =  ccui.ImageView:create("package_res/games/shantoumj/common/dice_" .. diceList[i] .. ".png")
        local diceSize = cc.size(diceImg:getContentSize().width, diceImg:getContentSize().height)
        diceImg:setPosition(cc.p(diceSize.width * diceCount + 30, diceSize.height - 40))
        diceImg:setAnchorPoint(cc.p(0, 0))
        diceImg:addTo(parent)
    end
end

--  展现翻牌动画
function FriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)   
    local scene = cc.Director:getInstance():getRunningScene()
    local lGameOverData = self.gameSystem:getGameOverDatas()
    dump(lGameOverData, "sunbin:lGameOverData ============")
    if lGameOverData.dice and #lGameOverData.dice > 0 then
        self:diceAnimation(lGameOverData.dice[1],lGameOverData.dice[2])
        scene:performWithDelay(function()
            self:setOverViewVisible(true)
        end, 3)
        return
    end

    local lTurnCardList = { }
    for k,v in pairs(lGameOverData.ho) do
        local tmp = {}
        if v.isM == 0 then
            tmp.Lottery = v.isM
        else
            tmp.Lottery = 1
        end
        tmp.CardID = v.faI6
        table.insert(lTurnCardList, tmp)
    end
    -- dump(lTurnCardList, "sunbin:lTurnCardList ========")


    local lTurnCardListMulti = { }
    for k,v in pairs(lGameOverData.score) do
        local maimaInfo = v.maimaInfo
        dump(v, "lGameOverData.score =============== ")
        if maimaInfo and #maimaInfo > 0 then
            local lCardList = { }
            lCardList.UserID = v.userid
            lCardList.CardList = { }
            for _k,_v in pairs(maimaInfo) do
                local tmp = {}
                if _v.isM == 0 then
                    tmp.Lottery = _v.isM
                else
                    tmp.Lottery = 1
                end
                tmp.CardID = _v.faI6
                table.insert(lCardList.CardList, tmp)
            end
            table.insert(lTurnCardListMulti, lCardList)
        end
    end
    Log.i("sunbin:lTurnCardListMulti ========",lTurnCardListMulti)

    local function playJiangma()
        local lLayerTurnCard = LayerTurnCard.new(lTurnCardList)
        scene:addChild(lLayerTurnCard, 999)
        lLayerTurnCard:doAniTurnCardOneByOne()
        local lDelayTime = lLayerTurnCard.m_AniTime + 3
        scene:performWithDelay( function()
            lLayerTurnCard:closed()
            self:setOverViewVisible(true)
        end , lDelayTime)
    end

    local function playMaima()
        local lLayerTurnCard = LayerTurnCardMultiplayer.new(lTurnCardListMulti)
        scene:addChild(lLayerTurnCard, 999)
        lLayerTurnCard:doAniTurnCardOneByOne()
        local lDelayTime = lLayerTurnCard.m_AniTime + 3
        scene:performWithDelay( function()
            lLayerTurnCard:closed()
            self:setOverViewVisible(true)
        end , lDelayTime)
    end

    local function playJiangmaAndMaima()
        local lLayerTurnCard = LayerTurnCard.new(lTurnCardList)
        scene:addChild(lLayerTurnCard, 999)
        lLayerTurnCard:doAniTurnCardOneByOne()
        local lDelayTime = lLayerTurnCard.m_AniTime + 3
        scene:performWithDelay( function()
            lLayerTurnCard:closed()
            playMaima()
        end , lDelayTime)
    end

    --  没有翻牌数据则直接跳过翻牌动画
    if #lTurnCardList <= 0 and #lTurnCardListMulti <= 0 then
        self:setOverViewVisible(true)
        return
    elseif #lTurnCardList > 0 and #lTurnCardListMulti <= 0 then
        playJiangma()
        return
    elseif #lTurnCardList <= 0 and #lTurnCardListMulti > 0 then
        playMaima()
        return
    elseif #lTurnCardList > 0 and #lTurnCardListMulti > 0 then
        playJiangmaAndMaima()
        return
    end
end

--[[
-- @brief  播放骰子动画函数
-- @param  void
-- @return void
--]]
function FriendOverView:diceAnimation(pointMin, pointMax)
    local curScene = cc.Director:getInstance():getRunningScene()
    SoundManager.playEffect("dasezi", false);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yaoshaizi.csb")
    local armature = ccs.Armature:create("yaoshaizi")
    armature:setPosition(cc.p(display.cx+120, display.cy))
    armature:getAnimation():play("Animation1")
    armature:performWithDelay(function()
            armature:removeFromParent(true)
        end, Define.shaizi_time)
    curScene:addChild(armature, 500)
    local function diceFunc()
        local dice_1_image = string.format("#00000%s.png",pointMin)
        local dice_2_image = string.format("#00000%s.png",pointMax)

        local dice_1_sprite = display.newSprite(dice_1_image)
        dice_1_sprite:setPosition(cc.p(display.cx-35,display.cy))
        dice_1_sprite:addTo(curScene,0)

        local dice_2_sprite = display.newSprite(dice_2_image)
        dice_2_sprite:setPosition(cc.p(display.cx+35,display.cy))
        dice_2_sprite:addTo(curScene,0)
        
        -- if gangAnim == nil then
        --     MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_TRICKS_END_NTF)
        -- end
        curScene:performWithDelay(function ()
            dice_1_sprite:removeFromParent()
            dice_2_sprite:removeFromParent()
        end, 2)
    end
    local diceCF = cc.CallFunc:create(diceFunc)
    local diceDT = cc.DelayTime:create(Define.shaizi_time)
    curScene:runAction(cc.Sequence:create(diceDT, diceCF))

--    local diceRemove = cc.CallFunc:create(function ()

--    end)
end

--  设置结算界面的可见性
function FriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end


return FriendOverView
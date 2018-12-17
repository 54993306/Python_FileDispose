local Define = require "app.games.common.Define"
local Mj     = require "app.games.common.mahjong.Mj"
local LayerTurnCard = require("app.games.common.custom.TurnCard.LayerTurnCard")
local LayerTurnCardMultiplayer = require("app.games.common.custom.TurnCard.LayerTurnCardMultiplayer")
require("app.DebugHelper")
require "app.games.common.ui.gameover.FriendOverView"

function FriendOverView:ctor(data)
    self.super.ctor(self, "games/common/game/mj_over.csb", data);
    self:setkLaiziPang("package_res/games/huaijimj/common/hunzi.png")
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

-------------------------------
-- 显示赖子
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function FriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    laiziName:setString("鬼牌")
    if #laiziList > 0 then
        for i = 1, #laiziList do
            local laiziMj = Mj.new(enMjType.MYSELF_PENG, laiziList[i])
            laiziMj:setScaleX(32 / laiziMj:getContentSize().width)
            laiziMj:setScaleY(40 / laiziMj:getContentSize().height)
            local mjSize = cc.size(laiziMj:getContentSize().width * laiziMj:getScaleX(), laiziMj:getContentSize().height * laiziMj:getScaleY())
            laiziMj:setPosition(cc.p(mjSize.width * i + 46, mjSize.height + 4))
            laiziMj:setAnchorPoint(cc.p(0, 0))
            laiziPanel:addChild(laiziMj)
            self:addLaiziIcon(laiziMj)
        end
    else
        laiziPanel:setVisible(false)
    end
end

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

        if site  and  zhuangSite ~= site and #players > 2 then
            local imgZuiDetail = display.newSprite("package_res/games/huaijimj/common/site_detail.png")
            item:addChild(imgZuiDetail, 100)
            imgZuiDetail:setPosition(cc.p(55,60))
            -- print("zhuang site ", zhuangSite, site)
            local text =  getZhuangText(zhuangSite, site, #players)
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
        -- line:setVisible(#scoreitem.flowerCards > 0)

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
        -- self:showFlower(scoreitem.flowerCards, hua_mj)
        line:setVisible(#scoreitem.faI > 0 )

        -- if isShowZhong then
            -- local maSign = display.newSprite("package_res/games/huaijimj/game/ma_sign.png")
            -- line:addChild(maSign)
            -- maSign:setPosition(cc.p(line:getPositionX() + 26, line:getPositionY() - 20))
            -- self:showFlower(scoreitem.flowerCards, hua_mj) --显示中的马
        -- end

        if scoreitem.result == enResult.WIN then 
            if self.gameOverDatas.yimaduorenhu == true then
                local lineParent = line:getParent()

                local maSign = ccui.ImageView:create("package_res/games/huaijimj/game/ma_sign.png")
                maSign:setPosition(line:getPositionX() + 26, line:getPositionY() - 20)
                lineParent:addChild(maSign)

                self:showFlower(scoreitem.faI, hua_mj)
            elseif self.gameOverDatas.faI and #self.gameOverDatas.faI > 0 then
                line:setVisible(true)
                local lineParent = line:getParent()

                local maSign = ccui.ImageView:create("package_res/games/huaijimj/game/ma_sign.png")
                maSign:setPosition(line:getPositionX() + 26, line:getPositionY() - 20)
                lineParent:addChild(maSign)

                local lTurnCardList = {}
                local lotteryList = scoreitem.flowerCards
                for k,v in pairs(self.gameOverDatas.faI) do
                    local tmp = {}
                    tmp.isM = 0
                        for _k,_v in pairs(lotteryList) do
                            if v.faI6 == _v then
                                tmp.isM = 1
                                break
                            end
                        end
                    tmp.faI6 = v.faI6
                    table.insert(lTurnCardList, tmp)
                end
                local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
                self:showFlower(lTurnCardList, hua_mj)
            end
        end
    end
end

function FriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/huaijimj/common/qiangganghu.png", ccui.TextureResType.localType)
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
            policyName = " "..pon[i].."(x"..pos[i]..")"
            detail = detail..policyName
        end
        Log.i("FriendOverView:addPlayers....gameId", MjProxy:getInstance():getGameId())
    end
    lab_fan:setString(detail)
end

------------------------
-- 结算界面花牌的显示
-- flowerCards 花牌的牌值
-- parent 花牌的父节点
function FriendOverView:showFlower(maimaInfo, parent)
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

--  展现翻牌动画
function FriendOverView:showAniTurnCard()
    self:setOverViewVisible(false)
    local lGameOverData = self.gameSystem:getGameOverDatas()
    dump(lGameOverData, "sunbin:lGameOverData ============")
    local lTurnCardList = {}
    local horseList = {}
    -- if lGameOverData.duoren == true then
        if lGameOverData.yimaduorenhu == true then
            horseList = lGameOverData.score[enSiteDirection.SITE_MYSELF].faI

            -- dump(horseList, "horseList ============")
            for k,v in pairs(horseList) do
                local tmp = {}
                tmp.Lottery = v.isM
                tmp.CardID = v.faI6
                table.insert(lTurnCardList, tmp)
            end
            -- dump(lTurnCardList,"lTurnCardList ===============")
        else
            local lotteryList
            local result = lGameOverData.score[enSiteDirection.SITE_MYSELF].result
            for k,v in pairs(lGameOverData.faI) do
                local tmp = {}
                tmp.Lottery = 0

                -- print("sunbin:faI6 =========== ", v.faI6)
                if enResult.WIN == result then
                    lotteryList = lGameOverData.score[enSiteDirection.SITE_MYSELF].flowerCards
                    for _k,_v in pairs(lotteryList) do
                        if v.faI6 == _v then
                            tmp.Lottery = 1
                            break
                        end
                    end
                else
                    for i=1, #lGameOverData.score do
                        lotteryList = lGameOverData.score[i].flowerCards
                        for _k,_v in pairs(lotteryList) do
                            -- print("sunbin:flc =========== ", _v)
                            if v.faI6 == _v then
                                tmp.Lottery = 1
                                break
                            end
                        end
                        if tmp.Lottery == 1 then
                            -- print("tmp.Lottery == 1")
                            break
                        end
                    end
                end
                tmp.CardID = v.faI6
                table.insert(lTurnCardList, tmp)
            end
        end
    -- else
    --     horseList = lGameOverData.faI

    --     -- dump(horseList, "horseList ============")
    --     for k,v in pairs(horseList) do
    --         local tmp = {}
    --         tmp.Lottery = v.isM
    --         tmp.CardID = v.faI6
    --         table.insert(lTurnCardList, tmp)
    --     end
    -- end

    local scene = cc.Director:getInstance():getRunningScene()
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

    --  没有翻牌数据则直接跳过翻牌动画
    if #lTurnCardList <= 0 then
        self:setOverViewVisible(true)
        return
    elseif #lTurnCardList > 0 then
        playJiangma()
    end
end

--  设置结算界面的可见性
function FriendOverView:setOverViewVisible(isVisible)
    local lBGPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg_panel")
    lBGPanel:setVisible(isVisible)
end

return FriendOverView
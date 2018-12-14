local Mj     = require("app.games.common.mahjong.Mj")
local kLaiziPang = "games/common/game/friendRoom/mjOver/laizi.png"

-- --加载公共模块
require("app.games.common.ui.gameover.FriendOverView")


-- local rules={
        
--         yougui={
--             ["false"]="不带鬼",
--             ["true"]="带鬼",
--         },

--         wuguikechihu={
--             ["false"]="",
--             ["true"]="无鬼可吃胡",
--         },

--         paishu={
--             ["136"]="136张牌",
--             ["120"]="120张牌",
--             ["112"]="112张牌",
--             ["108"]="108张牌",
--         },

--         gui={
--             ["47"]="白板鬼",
--             ["45"]="红中鬼",
--         },

--         laizishima={
--             ["false"]="鬼按位置看马",
--             ["true"]="鬼算所有人的马",
--         },

--         wuguihumapaishu={
--             ["0"]="无鬼胡正常翻马",
--             ["2"]="无鬼胡马牌数+2",
--             ["4"]="无鬼胡马牌数+4",
--         },

--         zipaimashu={
--             ["5"]="玩1马时字牌为5马",
--             ["10"]="玩1马时字牌为10马",
--         },

--         mashu={
--             ["6"]="6马",
--             ["4"]="4马",
--             ["8"]="8马",
--             ["10"]="10马",
--             ["1"]="1马",
--         },

--         mapailiebiao={
--             ["true"]="1,5,9鬼为马",
--             ["false"]="按位置看马",
--         },

--         dpfen={
--             ["1"]="1分",
--             ["2"]="2分",
--             ["5"]="5分",
--             ["10"]="10分",
--         },

--         zmfen={
--             ["2"]="1分2分",
--             ["4"]="2分4分",
--             ["10"]="5分10分",
--             ["20"]="10分20分",
--         },
-- }

------------------------
-- 设置规则 (调整规则位置)
-- @param lab_rule  待设置的规则label
-- @param wanfa     玩法字符串: palyingInfo.wa
-- function FriendOverView:setRule(lab_rule, wanfa)
--     local originWidth = lab_rule:getContentSize().width
--     local originMargin = lab_rule:getLayoutParameter():getMargin()
--     -- Log.i("getMargin()", originMargin)
--     local itemList= json.decode(wanfa)--Util.analyzeString_2(wanfa)
--     -- Log.i("itemList.....",itemList)
--     local ruleStr = ""
--     -- if (#itemList > 0 ) then
--     for i, v in pairs(itemList) do
--             -- print (i)
--             -- print (tostring(v))
--             if rules[i] then
--                 local str=""
--                 if i=="dpfen" then

--                 elseif i== "zmfen" then
--                     if itemList.dpfen ==  v then
--                         str=rules["dpfen"][tostring(v)]
--                     else
--                         str=rules[i][tostring(v)]
--                     end
--                 elseif i=="paishu" then
--                     str=rules[i][tostring(v)]
--                     if v==112 then
--                         if itemList.mapailiebiao then
--                             str=str..rules["mapailiebiao"]["true"]
--                         else
--                             str=str..rules["mapailiebiao"]["false"]
--                         end
--                     end
--                 elseif i=="wuguikechihu" then
--                     -- error(itemList.yougui)
--                     -- error(i)

--                     if itemList.yougui==true then
--                         str=rules[i][tostring(v)]
--                     else
--                         -- error("....")
--                     end
--                 else
--                     str=rules[i][tostring(v)]
--                 end

--                 if str then
--                     ruleStr=ruleStr.." "..str
--                 end
--             end
--     end
--     lab_rule:setString(ruleStr)
--     originMargin.left = originMargin.left + originWidth - lab_rule:getContentSize().width
--     Log.i("getMargin()", originMargin)
    
--     lab_rule:getLayoutParameter():setMargin(originMargin)
-- end

--------------------------
-- 设置游戏名称
-- function FriendOverView:setGameName(gameName)
--     local info = kFriendRoomInfo:getRoomBaseInfo()
--     gameName:setString(info.gameName and info.gameName or "中山麻将")
-- end

-------------------------------
-- 显示赖子
-- @laiziPanel 赖子层
-- @laiziList 赖子列表
-- @laiziName 赖子名称
function FriendOverView:showLaiziList(laiziPanel, laiziList, laiziName)
    laiziName:setString("鬼牌：");
    if #laiziList > 0 then
        for i = 1, #laiziList do
            if laiziList[i] == 0 then
                return
            end

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

    local data = self.gameSystem:getGameOverDatas();
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
        line:setVisible(#scoreitem.flowerCards > 0)

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")
        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj)
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards


         local fanmaList = data.score[i].faI9;
        -- local isEF = data.score[i].isEF;
        self:showFanMa(item, fanmaList, self.m_scoreitems[i].result)
    end
end

------------------------
-- 设置玩家详情 (只显示pon)
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function FriendOverView:setPlayerDetail(lab_fan, scoreitems)
    lab_fan:setString("")
    -- -- 只显示赢的玩家
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
        local textUnit = " "
        local policyName = ""
        for i=1, #pon do
            policyName = pon[i]..pos[i]..textUnit
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
-- 显示翻马
function FriendOverView:showFanMa(item, fanmaList, result)
    --UI只显示中的马
    local isHaveMa = false
    local isAllMa = true
    if self.gameOverDatas.isND == 1 and result ~= enResult.BUREAU then -- 有翻马
        local currentIndex = 1
        -- local maList = self.gameOverDatas.faI9 --结算数据中有马
        local maList = fanmaList --结算数据中有马
        for i = 1, #maList do
            local tmpData = maList[i]

            --- 显示翻马牌
            local maMj = Mj.new(enMjType.MYSELF_PENG, tmpData.faI6)
            -- maMj:setScale(0.5);
            maMj:setScaleX(20 / maMj:getContentSize().width)
            maMj:setScaleY(28 / maMj:getContentSize().height)
            local mjSize = cc.size(maMj:getContentSize().width * maMj:getScaleX(), maMj:getContentSize().height * maMj:getScaleY())

            -- 补马间距
            local lastDis = 0;
            if isEF and i == #maList then
                lastDis = 10;
            end
            if i <= 12 then
                maMj:setPosition(cc.p(mjSize.width * i + 30 +760 + lastDis, item:getContentSize().height*0.5 + 35 ))
            else
                maMj:setPosition(cc.p(mjSize.width * (i-12) + 30 +760 + lastDis, item:getContentSize().height*0.5 - 3 ))
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
        -- 是否全马  games/luoyangmj/common/icon_ci.png
        if isAllMa and #maList > 0 then 
            local img=display.newSprite("package_res/games/zhongshanmj/game/icon_quanma.png");
            img:setPosition(cc.p(770, item:getContentSize().height*0.5 + 5))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            -- img:setScale(0.9)
            item:addChild(img)
        elseif isHaveMa and #maList > 0 then
            local img=display.newSprite("package_res/games/zhongshanmj/game/icon_zhongma.png");
            img:setPosition(cc.p(770, item:getContentSize().height*0.5 +5))
            img:setAnchorPoint(cc.p(0.5, 0.5))
            -- img:setScale(0.9)
            item:addChild(img)
        else

        end
        
    end
end

--------------------------
-- 添加赖子角标 (调整位置)
function FriendOverView:addLaiziIcon(majiang)
    local laiziPng = cc.Sprite:create(GC_TurnLaiziPath_2)
    laiziPng:setScale(0.8)
    laiziPng:setPosition(cc.p(-12, -20))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
end
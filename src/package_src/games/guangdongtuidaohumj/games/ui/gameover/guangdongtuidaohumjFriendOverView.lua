
--
require("app.DebugHelper")
local FriendOverView = require("app.games.common.ui.gameover.FriendOverView")

local flowerdeviation = 150 --- flowercard            防止杠四次麻将牌会和花牌界面重合的偏移量

local linedeviation = 141---------line

local Mj    		= require "app.games.common.mahjong.Mj"
local guangdongtuidaohumjFriendOverView = class("guangdongtuidaohumjFriendOverView", FriendOverView)
 local kLaiziPang2 = "package_res/games/guangdongtuidaohumj/game/icon_guipaijiaobiao.png"
--GC_TurnLaiziPath_2 = "package_res/games/guangdongtuidaohumj/game/icon_guipai.png"


function guangdongtuidaohumjFriendOverView:ctor(data)
    self.super.ctor(self.super, data)
end

---------------------------------------------------------------------------
function guangdongtuidaohumjFriendOverView:onInit()
    self.super.onInit(self) 
    local laiziPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "laizi_pannel")
    local laiziName = ccui.Helper:seekWidgetByName(laiziPanel, "laizi_tip")
    laiziName:setString("鬼牌:") 
end

--function guangdongtuidaohumjFriendOverView:showLaiziList()
--    laiziName:setString("鬼牌:") 
--    self.super.showLaiziList(self)
--end

function guangdongtuidaohumjFriendOverView:addLaiziIcon(majiang)
    
    local laiziPng = cc.Sprite:create(kLaiziPang2)
--  laiziPng:setScale(0.5)
    laiziPng:setPosition(cc.p(-4, -6))
    laiziPng:setAnchorPoint(cc.p(0, 0))
    majiang:addChild(laiziPng, 1)
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
        line:setVisible(#scoreitem.flowerCards > 0)

        line:setPositionX(display.cx+linedeviation)--xiong
        line:getParent():requestDoLayout()

        local hua_mj = ccui.Helper:seekWidgetByName(item, "right_card_panel")


        local lFlowerCards = self:showFlower(scoreitem.flowerCards, hua_mj,scoreitem.result)----------------加多一个参数

        hua_mj:setPositionX(display.cx+flowerdeviation)--xiong
        hua_mj:getParent():requestDoLayout()
        self.m_PlayerCardList[i].FlowerCards = lFlowerCards
    end
end

----------------
-- 设置玩家详情
-- @param lab_fan       待设置的玩家详情label
-- @param scoreitems    玩家详情Table
function guangdongtuidaohumjFriendOverView:setPlayerDetail(lab_fan, scoreitems)
     if scoreitems.result == enResult.WIN then
        lab_fan:setVisible(true)
    else
        lab_fan:setVisible(false)
    end
    local buf = ""
    local name = scoreitems.policyName or {}
    local score = scoreitems.policyScore or {}
    
    if #name > 0 and #score > 0 then
        for i = 1, #name do
       -- for i, v in pairs(name) do
            local format = name[i] .." "         
            buf = buf .. format

        end
    end

   local wanfa = kFriendRoomInfo:getSelectRoomInfo().wa
   local itemList= Util.analyzeString_2(wanfa)
      for i, v in ipairs(itemList) do
        if v =="baozhama" then 
            local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
            local faI = lGameSystem:getGameOverDatas().faI
            --Log.i("爆炸马的数据",faI )
             local value = 0
            if faI[1] then 
                   value  =  faI[1].faI6 or 0--gai
            end

            local  mashu = 0 
            if value<40 and value>0  then
                mashu =  value%10
            end
            if value>40 then
                mashu = 5
            end
            if value ~= 0 then
            buf = buf .. mashu .."马"
            end
        end
      end
     --local hu = "胡".."(".."1".."底"..")" 
   -- buf = buf .. " " .. hu

--    if name[1] == "庄家(1番)" or name[2] == "庄家(1番)"or name[3] == "庄家(1番)" then

--     local zhuang = "庄"
--     buf = buf.." "..zhuang
--    end


    lab_fan:setString(buf)
    --Log.i("self.gameOverDatas结算",self.gameOverDatas)
    --self:fanMaShow()

end

function guangdongtuidaohumjFriendOverView:fanMaShow()
if #(self.gameOverDatas.faI)>0 then 
    local fanmalist = self.gameOverDatas.faI
    local groupX = -display.cx
    local fanma_label = display.newTTFLabel({
                        text = "翻马：",
                        font = "hall/font/fangzhengcuyuan.TTF",
                        size = 25,
                        color = cc.c3b(139, 137, 113),
                        align = cc.TEXT_ALIGNMENT_LEFT,
                        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                    })
    fanma_label:setPosition(cc.p(groupX, fanma_label:getContentSize().height/2 - 5))
    fanma_label:addTo(self.lab_rule)
    groupX = groupX+fanma_label:getContentSize().width/2+10

    if (#fanmalist)>1 then 
        for i=1,#fanmalist do
            local majiang   = Mj.new(enMjType.MYSELF_PENG, fanmalist[i].faI6)
            local mjSize    = majiang:getContentSize()
            majiang:setScaleX(24 / mjSize.width)
            majiang:setScaleY(30 / mjSize.height)

            mjSize.width = mjSize.width * majiang:getScaleX()
            mjSize.height = mjSize.height * majiang:getScaleY()
        
            self.lab_rule :addChild(majiang)
            majiang:setPosition(cc.p(groupX, mjSize.height + mjSize.height / 2 - 10)) 
            groupX = groupX + mjSize.width

        end
    end


    if (#fanmalist)== 1 then 
        local majiang   = Mj.new(enMjType.MYSELF_PENG, fanmalist.faI6)
        local mjSize    = majiang:getContentSize()
        majiang:setScaleX(24 / mjSize.width)
        majiang:setScaleY(30 / mjSize.height)

        mjSize.width = mjSize.width * majiang:getScaleX()
        mjSize.height = mjSize.height * majiang:getScaleY()
        
        self.lab_rule :addChild(majiang)
        majiang:setPosition(cc.p(groupX, mjSize.height + mjSize.height / 2 - 10)) 
        groupX = groupX + mjSize.width
    end

    end
end

function guangdongtuidaohumjFriendOverView:initHuImage(item,scoreitems)
    local img_hu = ccui.Helper:seekWidgetByName(item, "img_hu");
    Log.i("tuidoahures",self.m_scoreitems)
    if scoreitems.result == enResult.WIN then --胡牌玩家
        if self.gameOverDatas.winType == 1 then
            img_hu:loadTexture("games/common/game/friendRoom/mjOver/zimo.png", ccui.TextureResType.localType)
        elseif self.gameOverDatas.winType == enGameOverType.QIANG_GANG_HU then
            img_hu:loadTexture("package_res/games/guangdongtuidaohumj/image/qiangganghu.png", ccui.TextureResType.localType)
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

function guangdongtuidaohumjFriendOverView:showFlower(flowerCards, parent,result)
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

    
    if flower and #flower > 0 and parent and result == 1 then
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

    
    if flower and #flower > 0 and parent and result == 1  then
        local zhongma = display.newSprite("package_res/games/guangdongtuidaohumj/game/zhongma.png")
        zhongma:addTo(parent)
        zhongma:setPosition(cc.p(-25,parent:getContentSize().height/2))
    end

    return lCardList
end

return guangdongtuidaohumjFriendOverView

--
-- 玩家头像(加倍/积分/准备/角色/语音按钮条)
--
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDPlayerView = class("GDPlayerView", GDRoomView)
local PokerRoomPlayerInfoView = require("package_src.games.guandan.gdcommon.widget.PokerRoomPlayerInfoView")
local PokerClippingNode = require("package_src.games.guandan.gdcommon.commontool.PokerClippingNode")
local PokerUtils = require("package_src.games.guandan.gdcommon.commontool.PokerUtils")
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")
local UmengClickEvent = require("app.common.UmengClickEvent")
local GDCard = require("package_src.games.guandan.gd.utils.card.GDCard")
local PokerCardView = require("package_src.games.guandan.gdcommon.widget.PokerCardView")

--头像尺寸
local nHeadSize = 115
local eTagClipHead = 123

function GDPlayerView:initView()
    self.frame = ccui.Helper:seekWidgetByName(self.m_pWidget,"frame")
    self.img_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_head")
    self.img_head:setTouchEnabled(true)  
    self.img_head:addTouchEventListener(handler(self, self.onClickButton))
    self.say_panel = self:getWidget(self.m_pWidget,"panel_head_say")
    
    self.lb_name = self:getWidget(self.m_pWidget, "lb_name", {bold = true})
    self.img_state = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_state")
    self.img_state:setVisible(false)

    self.img_lixian = self:getWidget(self.m_pWidget,"img_lixian")
    self.img_lixian:loadTexture("games/common/game/friendRoom/text_offline.png")
    self.img_lixian:setVisible(false)

    self.imgRank = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_rank")
    self.imgRank:setVisible(false)
    --初始化前先隐藏掉头像信息框
    self:hide()

    if self.m_data.gameType == GDConst.GAME_UP_TYPE.NO_UP_GRADE then--不升级场
        local frameSize = cc.size(149, 228)
        self.m_pWidget:setContentSize(cc.size(110, 182))
        self.frame:setContentSize(frameSize)
        self.frame:setPosition(cc.p(56, 91))
        self.img_head:setPosition(cc.p(frameSize.width/2, frameSize.height-84))
        self.img_lixian:setPosition(cc.p(56, 120))
        self.lb_name:setPosition(cc.p(55, 36))

        local scoreBgSize = cc.size(102, 26)
        local imgScoreBg = ccui.ImageView:create("common/common_gold_bg.png", ccui.TextureResType.plistType)
        imgScoreBg:setScale9Enabled(true)
        imgScoreBg:setCapInsets(cc.rect(10, 5, 10, 1))
        imgScoreBg:setContentSize(scoreBgSize)
        imgScoreBg:setPosition(cc.p(56, 24))
        self.m_pWidget:addChild(imgScoreBg)

        self.txtScore = ccui.Text:create("0", "package_res/games/guandan/fnt/fangzhengcuyuan.TTF", 20)
        self.txtScore:setColor(cc.c3b(255, 238, 120))
        self.txtScore:setPosition(cc.p(scoreBgSize.width/2, scoreBgSize.height/2))
        imgScoreBg:addChild(self.txtScore)

        if self.m_data.seat == GDConst.SEAT_MINE then
            self.imgRank:setPositionY(187)
        elseif self.m_data.seat == GDConst.SEAT_RIGHT then
            self.imgRank:setPositionY(88)
        elseif self.m_data.seat == GDConst.SEAT_TOP then
            self.imgRank:setPositionY(72)
        else
            self.imgRank:setPositionY(91)
        end
    end
end

--检测ip是否相同
function GDPlayerView:ipXiangTong(playerModel)
    if not playerModel then return end
    local players = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local myIp = playerModel:getProp(GDDefine.IP)
    local ipA = {}
    local player = 0
    local isIpHand = false
    for i ,v in pairs(players) do
        if v ~= nil and playerModel:getProp(GDDefine.USERID) ~=v:getProp(GDDefine.USERID) then
            if v ~= nil then
                if myIp == v:getProp(GDDefine.IP) then
                    self:drawIpXiangTong()
                    isIpHand = true
                    break
                end
            end
        end
    end
    if isIpHand == false then
        local headOneIp = self.m_pWidget:getChildByName("ipxiangtong")
        if headOneIp ~= nil then
            headOneIp:removeFromParent()
        end
    end
end

--绘制ip相同
function GDPlayerView:drawIpXiangTong()
    local headOneIp = self.m_pWidget:getChildByName("ipxiangtong")
    if headOneIp == nil then
        local ip = display.newSprite("games/common/mj/common/ipxiangtong.png")
        self.m_pWidget:addChild(ip, 4, "ipxiangtong")
        ip:setPosition(cc.p(self.m_pWidget:getContentSize().width * 0.5, self.m_pWidget:getContentSize().height * 0.5))
    end
end

-----------------------------------------------------------------
-- @desc 重置
-----------------------------------------------------------------
function GDPlayerView:reset()
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:hide()
    end
    self.say_panel:setVisible(false)
    self.imgRank:setVisible(false)
    self:removeGongCard()
end

-----------------------------------------------------------------
-- @desc 离线
-----------------------------------------------------------------
function GDPlayerView:showOnline(status)
    if not tolua.isnull(self.img_lixian) then
        local player = self:getPlayerModel()
        local userId = player:getProp(GDDefine.USERID)        
        local info = kFriendRoomInfo:getRoomPlayerListInfo(userId)

        --Log.i("===========userIduserIduserId===========",userId,info.st)
        if info then
            self.img_lixian:setVisible(info.st ~= 0 )
        else
            self.img_lixian:setVisible(false)
        end
    end
end

-----------------------------------------------------------------
-- @desc 显示准备
-----------------------------------------------------------------
function GDPlayerView:showReady()
    if not tolua.isnull(self.img_state) then
        self.img_state:setVisible(true)
    end
end

-----------------------------------------------------------------
-- @desc 隐藏准备
-----------------------------------------------------------------
function GDPlayerView:hideReady()
    if not tolua.isnull(self.img_state) then
        self.img_state:setVisible(false)
    end
end

-----------------------------------------------------------------
-- @desc 更新头像
-- @pram :imgName 玩家头像路径
-----------------------------------------------------------------
function GDPlayerView:updateHeadImg(imgName)
    local PlayerModel = self:getPlayerModel()
    local userid = PlayerModel:getProp(GDDefine.USERID)
    local headImg = PlayerModel:getProp(GDDefine.ICON_ID)
    if imgName == (headImg .. "") then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName)
        if io.exists(imgName) then
            self.img_head:loadTexture(imgName)
        end
    end
    local strPre = string.sub(imgName, 1, 11)
    local length = string.len(imgName)
    local strUserId = string.sub(imgName, 12, length - 4)
    -- Log.i("更新头像", strPre, tonumber(strUserId), userid)
    if strPre == "wxHeadFile_" then
        if tonumber(strUserId) ~= userid then
            -- print("更新头像,return")
            return
        end
    end

    imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName)
    if io.exists(imgName) then
        self.img_head:loadTexture(imgName)
    end
end

-----------------------------------------------------------------
-- @desc 更新玩家信息
-- @pram :无
-----------------------------------------------------------------
function GDPlayerView:updatePlayerInfo()
    -- Log.i("GDPlayerView:updatePlayerInfo ")
    self:show()
    local player = self:getPlayerModel()
    self.lb_name:setString(PokerUtils:subUtfStrByCn(player:getProp(GDDefine.NAME), 1, 4, ".."))
    local sex = player:getProp(GDDefine.SEX)

    url = player:getProp(GDDefine.ICON_ID)
    self.img_head:setOpacity(0)
    local defMale = "package_res/games/guandan/head/defaultHead_male.png"
    local defFemale = "package_res/games/guandan/head/defaultHead_female.png"
    local stencil = "package_res/games/guandan/head/cicleHead.png"
    -- Log.i("head url ", url)
    local player = self:getPlayerModel()
    self:ipXiangTong(player)
    if not PokerUtils:isNetWorkHeadUrl(url) then
        local headFile = sex == GDConst.MALE and defMale or defFemale
        -- Log.i("head headFile ", headFile)
        self.head = PokerClippingNode.new(stencil, headFile, nHeadSize)
        self.head:setPosition(self.img_head:getPositionX(),self.img_head:getPositionY())
        self.frame:addChild(self.head)
        self.head:setTag(eTagClipHead)
        return
    end

    local fileName = player:getProp(GDDefine.USERID) .. ".jpg"
    local pos = cc.p(self.img_head:getPositionX(),self.img_head:getPositionY())
    PokerUtils:updateHead(fileName, url, stencil, nHeadSize, self.frame, self.head, eTagClipHead, pos)

    if self.txtScore then
        local score = player:getProp(GDDefine.MONEY)
        self.txtScore:setString(score)
    end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function GDPlayerView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        NativeCallUmengEvent(UmengClickEvent.GDGamePlayerHead)
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.img_head then
            local wpos = pWidget:getParent():convertToWorldSpace(cc.p(pWidget:getPositionX(),pWidget:getPositionY()))
            local data = {}
            data.pos = cc.p( (display.width *0.5 - wpos.x) * 0.5  + wpos.x, wpos.y)
            data.site = self.m_data.seat
            local PokerRoomPlayerInfoView = PokerUIManager.getInstance():pushWnd(PokerRoomPlayerInfoView, data)
            PokerRoomPlayerInfoView:setDelegate(self.m_delegate)
        end
    end
end

----------------------------------------------
-- @desc 获取玩家头像位置 
-- @pram 无
----------------------------------------------
function GDPlayerView:getPlayerPosition()
    return self.m_pWidget:getPosition()
end

---------------------------------------
-- @desc   显示语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function GDPlayerView:showSpeaking()
    self.say_panel:setVisible(true)
end

---------------------------------------
-- @desc   隐藏语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function GDPlayerView:hideSpeaking()
    -- Log.i("GDPlayerView:hideSpeaking ", self.m_data.seat)
    self.say_panel:setVisible(false)
end


-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function GDPlayerView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(GDDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(GDDefine.SITE) == self.m_data.seat then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end

-- @desc 添加贡牌
function GDPlayerView:addGongCard(card)
    local type, value = GDCard.cardConvert(card)
    local cardView = PokerCardView.new(type, value, card)
    cardView:setAnchorPoint(cc.p(0, 1))
    local size = self.m_pWidget:getContentSize()
    if self.m_data.gameType == GDConst.GAME_UP_TYPE.NO_UP_GRADE then--不升级场
        cardView:setPosition(cc.p(5 ,size.height-8))
    else
        cardView:setPosition(cc.p(5 ,size.height))
    end
    cardView:setScale(0.4)
    self.m_pWidget:addChild(cardView, 3, "gongCard")
end

-- @desc 添加贡牌
function GDPlayerView:removeGongCard()
    local node = self.m_pWidget:getChildByName("gongCard")
    if node then
        node:removeFromParent()
    end
end

function GDPlayerView:showRank(rank, playerId)
    local imgName = ""
    local effName = "rank_second"
    local rankEffName = ""
    if rank == 1 then
        effName = "rank_first"
        rankEffName = "rank_first_"
        imgName = "guadan_image_rank_first.png"
    elseif rank == 2 then
        rankEffName = "rank_second_"
        imgName = "guadan_image_rank_second.png"
    elseif rank == 3 then
        imgName = "guadan_image_rank_third.png"
    elseif rank == 4 then
        imgName = "guadan_image_rank_fourth.png"
    end
    self.imgRank:loadTexture(imgName, ccui.TextureResType.plistType)
    self.imgRank:setVisible(true)
    local player = self:getPlayerModel()
    local userId = player:getProp(GDDefine.USERID)  
    if playerId == userId then
        kPokerSoundPlayer:playEffect(effName)--you_second
        if rank <= 2 then
            local sex = player:getProp(GDDefine.SEX)
            kPokerSoundPlayer:playEffect(string.format("%s%d",rankEffName, sex))
        end
    end
end

return GDPlayerView
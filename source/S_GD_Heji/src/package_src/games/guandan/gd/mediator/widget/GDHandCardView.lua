
--[[---------------------------------------- 
-- 作者: 方明扬
-- 日期: 2018-05-07 
-- 摘要: 玩家手牌
]]-------------------------------------------
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDHandCardView = class("GDHandCardView", GDRoomView)
local GDDefine = require("package_src.games.guandan.gd.data.GDDefine")
local GDDataConst = require("package_src.games.guandan.gd.data.GDDataConst")
local GDMyHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDMyHandCardView")
local GDRightHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDRightHandCardView")
local GDLeftHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDLeftHandCardView")
local GDTopHandCardView = require("package_src.games.guandan.gd.mediator.widget.GDTopHandCardView")
local GDConst = require("package_src.games.guandan.gd.data.GDConst")

--剩余牌的数量
local CARD_REMAIN_NUM = 10

--函数功能：初始化UI
--返回值：  无
function GDHandCardView:initView()
    if self.m_data.seat == GDConst.SEAT_MINE then
        self.m_handCardView = GDMyHandCardView.new(self.m_pWidget)
        self.m_pWidget:addChild(self.m_handCardView)
    else
        self.txtCardNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "card_num")
        self.txtCardNum:setVisible(false)
        self.card = ccui.Helper:seekWidgetByName(self.m_pWidget, "card")
    end

    if self.m_data.gameType == GDConst.GAME_UP_TYPE.NO_UP_GRADE then
        local originMargin_start = self.m_pWidget:getLayoutParameter():getMargin()
        if self.m_data.seat == GDConst.SEAT_RIGHT
           or self.m_data.seat == GDConst.SEAT_LEFT then
            originMargin_start.top = originMargin_start.top + 60
            self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
            self.m_pWidget:getParent():requestDoLayout()
        elseif self.m_data.seat == GDConst.SEAT_TOP then
            originMargin_start.top = originMargin_start.top + 60
            originMargin_start.right = originMargin_start.right + 163
            self.m_pWidget:getLayoutParameter():setMargin(originMargin_start)
            self.m_pWidget:getParent():requestDoLayout()
        end
    end

    -- 这里为了回放显示出其他家手牌
    if VideotapeManager.getInstance():isPlayingVideo() then
        if self.m_data.seat == GDConst.SEAT_MINE then
            -- 自家牌组不在回放中也创建了
        elseif self.m_data.seat == GDConst.SEAT_RIGHT then
            self.m_rightHandCardView = GDRightHandCardView.new(self.m_pWidget)
            self.m_pWidget:addChild(self.m_rightHandCardView)

        elseif self.m_data.seat == GDConst.SEAT_LEFT then
            self.m_leftHandCardView = GDLeftHandCardView.new(self.m_pWidget)
            self.m_pWidget:addChild(self.m_leftHandCardView)
        elseif self.m_data.seat == GDConst.SEAT_TOP then
            self.m_topHandCardView = GDTopHandCardView.new(self.m_pWidget)
            self.m_pWidget:addChild(self.m_topHandCardView)
        end
    end
end


--函数功能：析构函数
--返回值：  无
function GDHandCardView:dtor()
    if not tolua.isnull(self.m_handCardView) then
        self.m_handCardView:close()
    end

    if not tolua.isnull(self.m_rightHandCardView) then
        self.m_rightHandCardView:close()
    end

    if not tolua.isnull(self.m_leftHandCardView) then
        self.m_leftHandCardView:close()
    end

    if not tolua.isnull(self.m_topHandCardView) then
        self.m_topHandCardView:close()
    end
end


--函数功能：显示可以的操作
--返回值：  无
--info：    显示操作信息
function GDHandCardView:showOpration(info)
    local gameStatus = DataMgr:getInstance():getNumberByKey(GDDataConst.DataMgrKey_GAMESTATUS)

    if gameStatus ~= GDConst.STATUS_ON_OUT_CARD then return end
    if not self.m_handCardView then return end

    self.m_handCardView:setTouchEnabled(true)
    local tuoguanState = DataMgr:getInstance():getObjectByKey(GDDataConst.DataMgrKey_TUOGUANSTATE)
    if tuoguanState == GDConst.TUOGUAN_STATE_0 then
        self.m_handCardView:checkIsBiggerCard()
    end
end

--函数功能：游戏结束
--返回值：  无
function GDHandCardView:onGameOver()
    if self.m_handCardView then
        self.m_handCardView:onTuoGuanChange()
        self.m_handCardView:onGameOver()
    else
        self.card:setVisible(false)
        self.txtCardNum:setVisible(false)
        self:clearJingdeng()
    end
end


--函数功能：    出牌
--返回值：      无
--info：        后台出过来的debug牌 
--isReconnect： 是否重连
function GDHandCardView:onPlayCard(info, isReconnect)
    local PlayerModel = self:getPlayerModel()
    local cards = PlayerModel:getProp(GDDefine.HAND_CARDS)
    -- Log.i("GDHandCardView:onPlayCard isReconnect ", isReconnect)
    -- Log.i("GDHandCardView:onPlayCard cards ", cards, #cards)
    if not isReconnect and cards and #cards >= 0 then
        self.card_num = #cards
        -- Log.i("GDHandCardView:onPlayCard cards self.card_num", self.card_num)
        if self.txtCardNum then
            self.txtCardNum:setVisible(true)
            self.txtCardNum:setString("" .. self.card_num)

            if self.card_num <= CARD_REMAIN_NUM and self.card_num > 0 then
                self:showJingdeng()
            else
                self:clearJingdeng()
            end
        end
        if self.card_num <= 0 then
            DataMgr:getInstance():setPlayerRank(PlayerModel:getProp(GDDefine.USERID))
        end
    end
end

--函数功能：    删除警示灯
--返回值：      无
function GDHandCardView:clearJingdeng()
    if self.jingdeng then
        self.m_pWidget:removeChild(self.jingdeng)
        self.jingdeng = nil
    end
end

--函数功能：    显示警示灯
--返回值：      无
function GDHandCardView:showJingdeng()
    self:clearJingdeng()
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/guandan/jingdeng/jingdeng.csb")
    ---警示灯特效
    self.jingdeng = ccs.Armature:create("jingdeng")
    self.m_pWidget:addChild(self.jingdeng)
    self.jingdeng:getAnimation():play("Animation1")
    local size = self.m_pWidget:getContentSize()
    if self.m_data.seat == GDConst.SEAT_RIGHT then
        self.jingdeng:setPosition(cc.p(size.width/2+4, size.height+30))
    elseif self.m_data.seat == GDConst.SEAT_TOP then
        self.jingdeng:setPosition(cc.p(size.width/2+4, size.height+30))
    else
        self.jingdeng:setPosition(cc.p(size.width/2+4, size.height+30))
    end
end

--函数功能：    更新操作
--返回值：      无
--info：        更新操作需要的信息
function GDHandCardView:updateOpration(info)
    info = checktable(info)
    Log.i("updateOpration info", info)
    
    if not self.m_handCardView then return end 
    
    if info.action == "buchu" then
        self.m_handCardView:onBuChuClick()
    elseif info.action == "tishi" then
        self.m_handCardView:onTiShiClick()
    elseif info.action == "chupai" then
        self.m_handCardView:onChuClick()
    elseif info.action == "chongxuan" then
        self.m_handCardView:onChongXuanClick()
    elseif info.action == "jingong" then
        self.m_handCardView:onJingongClick()
    elseif info.action == "huangong" then
        self.m_handCardView:onHuanGongClick()
    end
end

--函数功能：    发牌
--返回值：      无
--isReconnect： 是否重连
function GDHandCardView:dealCard(isReconnect)
    local PlayerModel = self:getPlayerModel()
    local handcards = PlayerModel:getProp(GDDefine.HAND_CARDS)
    handcards = checktable(handcards)
    self.m_pWidget:setVisible(true)
    self.card_num = handcards and #handcards or GDConst.DEFCARDSNUM

    if self.m_handCardView then
        self.m_handCardView:dealCard(handcards, isReconnect)
    elseif self.m_rightHandCardView then
        self.m_rightHandCardView:dealCard(handcards, isReconnect)
        if self.card_num <= CARD_REMAIN_NUM and self.card_num > 0 then
            self:showJingdeng()
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true)

        if self.txtCardNum then
            self.txtCardNum:setVisible(true)
            self.txtCardNum:setString("" .. self.card_num)
        end
    elseif self.m_leftHandCardView then
        self.m_leftHandCardView:dealCard(handcards, isReconnect)
        if self.card_num <= CARD_REMAIN_NUM and self.card_num > 0 then
            self:showJingdeng()
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true)

        if self.txtCardNum then
            self.txtCardNum:setVisible(true)
            self.txtCardNum:setString("" .. self.card_num)
        end
     elseif self.m_topHandCardView then
        self.m_topHandCardView:dealCard(handcards, isReconnect)
        if self.card_num <= CARD_REMAIN_NUM and self.card_num > 0 then
            self:showJingdeng()
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true)

        if self.txtCardNum then
            self.txtCardNum:setVisible(true)
            self.txtCardNum:setString("" .. self.card_num)
        end
    else
        if self.card_num <= CARD_REMAIN_NUM and self.card_num > 0 then
            self:showJingdeng()
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true)

        if self.txtCardNum then
            self.txtCardNum:setVisible(true)
            self.txtCardNum:setString("" .. self.card_num)
        end
    end  
end

--函数功能：    托管改变
--返回值：      无
function GDHandCardView:onTuoGuanChange()
    Log.i("GDHandCardView:onTuoGuanChange")
    if not tolua.isnull(self.m_handCardView) then
        self.m_handCardView:onTuoGuanChange()
    end
end

--函数功能：    重置
--返回值：      无
function GDHandCardView:reset()
    if not tolua.isnull( self.m_handCardView ) then
        self.m_handCardView:reset()
    else
        self:hide()
    end  
end


--函数功能：    根据view创建时传入的seat来获取到玩家的数据模型
--返回值：      返回玩家数据模型
function GDHandCardView:getPlayerModel()
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

--函数功能：    添加牌
function GDHandCardView:addCard(cards)
    self.card_num = self.card_num + #cards
    
    if self.txtCardNum then
        self.txtCardNum:setVisible(true)
        self.txtCardNum:setString("" .. self.card_num)
    end

    if self.m_handCardView then
        self.m_handCardView:addCards(cards)
        DataMgr:getInstance():getMyPlayerModel():addCards(cards)
    end 
end

return GDHandCardView

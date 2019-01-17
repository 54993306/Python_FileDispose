
--[[---------------------------------------- 
-- 作者: 方明扬
-- 日期: 2018-05-07 
-- 摘要: 玩家手牌
]]-------------------------------------------


local DDZRoomView = require("package_src.games.ddz.mediator.widget.DDZRoomView")
local DDZHandCardView = class("DDZHandCardView", DDZRoomView);
local DDZDefine = require("package_src.games.ddz.data.DDZDefine")
local DDZDataConst = require("package_src.games.ddz.data.DDZDataConst")
local DDZMyHandCardView = require("package_src.games.ddz.mediator.widget.DDZMyHandCardView")
local DDZRightHandCardView = require("package_src.games.ddz.mediator.widget.DDZRightHandCardView")
local DDZLeftHandCardView = require("package_src.games.ddz.mediator.widget.DDZLeftHandCardView")
local DDZConst = require("package_src.games.ddz.data.DDZConst")

--剩余牌的数量
local CARD_REMAIN_NUM_1 = 1
local CARD_REMAIN_NUM_2 = 2
local CARD_REMAIN_NUM_3 = 3


--函数功能：初始化UI
--返回值：  无
function DDZHandCardView:initView()
    
    --玩家最后3张牌是否已播放过音效
    self.playLastCard1 = false
    self.playLastCard2 = false
    self.playLastCard3 = false

    -- self.m_data:玩家位置
    if self.m_data == DDZConst.SEAT_MINE then
        self.m_handCardView = DDZMyHandCardView.new(self.m_pWidget);
        self.m_pWidget:addChild(self.m_handCardView);
    else
        --左右两家处理
        self.card_num_img = ccui.Helper:seekWidgetByName(self.m_pWidget, "card_num");
        local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
        self.card_num_img:setVisible(isPorkerNumber)
        self.card = ccui.Helper:seekWidgetByName(self.m_pWidget, "card");
        self.card_label = ccui.Helper:seekWidgetByName(self.m_pWidget,"card_label")
    end

    -- 这里为了回放显示出其他家手牌
    if VideotapeManager.getInstance():isPlayingVideo() then
        if self.m_data == DDZConst.SEAT_MINE then
            -- 自家牌组不在回放中也创建了
        elseif self.m_data == DDZConst.SEAT_RIGHT then
            Log.i("--wangzhi--创建右家牌组--")
            self.m_rightHandCardView = DDZRightHandCardView.new(self.m_pWidget);
            self.m_pWidget:addChild(self.m_rightHandCardView);

        elseif self.m_data == DDZConst.SEAT_LEFT then
            Log.i("--wangzhi--创建左家牌组--")
            self.m_leftHandCardView = DDZLeftHandCardView.new(self.m_pWidget);
            self.m_pWidget:addChild(self.m_leftHandCardView);
        end
    end
end


--函数功能：析构函数
--返回值：  无
function DDZHandCardView:dtor()
    if not tolua.isnull(self.m_handCardView) then
        Log.i("self.m_data dtor", self.m_data)
        self.m_handCardView:close()
    end

    if not tolua.isnull(self.m_rightHandCardView) then
        Log.i("self.m_data dtor", self.m_data)
        self.m_rightHandCardView:close()
    end

    if not tolua.isnull(self.m_leftHandCardView) then
        Log.i("self.m_data dtor", self.m_data)
        self.m_leftHandCardView:close()
    end
end


--函数功能：显示可以的操作
--返回值：  无
--info：    显示操作信息
function DDZHandCardView:showOpration(info)
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)

    if gameStatus ~= DDZConst.STATUS_PLAY then return end
    if not self.m_handCardView then return end

    self.m_handCardView:setTouchEnabled(true);
    local tuoguanState = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)

    if tuoguanState == DDZConst.TUOGUAN_STATE_0 then
        self.m_handCardView:checkIsBiggerCard();
    end
end

--函数功能：拼接牌
--返回值：  无
--infos：   后端传过来的牌
function DDZHandCardView:cardLink(infos)
    local cards = ""
    for i,v in ipairs(infos) do
        cards = cards .. v
    end

    return cards
end

--函数功能：游戏结束
--返回值：  无
function DDZHandCardView:onGameOver()
    self.playLastCard1 = false
    self.playLastCard2 = false
    self.playLastCard3 = false

    if self.m_handCardView then
        self.m_handCardView:onTuoGuanChange();
        self.m_handCardView:onGameOver();
    else
        self.card:setVisible(false);
        self.card_num_img:setVisible(false);
        self.card_label:setVisible(false)
        --SoundManager.stopEffect("baojin");
        self:clearJingdeng()
    end
end


--函数功能：    出牌
--返回值：      无
--info：        后台出过来的debug牌 
--isReconnect： 是否重连
function DDZHandCardView:onPlayCard(info, isReconnect)
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZDefine.SEX)
    local playerId = PlayerModel:getProp(DDZDefine.USERID)
    local cards = PlayerModel:getProp(DDZDefine.HAND_CARDS)

    Log.i("DDZHandCardView:onPlayCard isReconnect ", isReconnect)
    Log.i("DDZHandCardView:onPlayCard cards ", cards, #cards)

    if not isReconnect and cards and #cards >= 0 then
        self.card_num = #cards
        Log.i("DDZHandCardView:onPlayCard cards self.card_num", self.card_num)

        local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
        if self.card_num_img then

            if isPorkerNumber then
                self.card_num_img:setVisible(true);
                self.card_num_img:setString("" .. self.card_num);                
            end

            if self.card_num <= CARD_REMAIN_NUM_2 and self.card_num > 0 then
                self:showJingdeng();
            else
                self:clearJingdeng()
            end
            if self.card_num == 0 then
                self.card:setVisible(false);
                self.card_num_img:setVisible(false);
            end
        end

        if self.card_num == CARD_REMAIN_NUM_1 and (not self.playLastCard1) then
            self.playLastCard1 = true
            kPokerSoundPlayer:playEffect("op_last1" .. sex);
        elseif self.card_num == CARD_REMAIN_NUM_2 and (not self.playLastCard2) then
            self.playLastCard2 = true
            kPokerSoundPlayer:playEffect("op_last2" .. sex);
        elseif self.card_num == CARD_REMAIN_NUM_3 and (not self.playLastCard3) then
            self.playLastCard3 = true
            --kPokerSoundPlayer:playEffect("op_last3" .. sex);
        end
    end

    local debug = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_DEBUGSTATE)
    if debug and self.card_label and info.mapInfos then
        local cardStr = info.mapInfos[tostring(playerId)] and self:cardLink(info.mapInfos[tostring(playerId)]) or ""
        self.card_label:setVisible(true)
        self.card_label:setString(cardStr)
    end
end

--函数功能：    删除警示灯
--返回值：      无
function DDZHandCardView:clearJingdeng()
    if self.jingdeng then
        self.m_pWidget:removeChild(self.jingdeng);
        self.jingdeng = nil;
    end
end

--函数功能：    显示警示灯
--返回值：      无
function DDZHandCardView:showJingdeng()
    self:clearJingdeng()
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/jingdeng/jingdeng.csb");
    ---警示灯特效
    self.jingdeng = ccs.Armature:create("jingdeng");
    self.m_pWidget:addChild(self.jingdeng);
    self.jingdeng:getAnimation():play("Animation1");
    self.jingdeng:setPosition(cc.p(55, 110));
end

--函数功能：    更新操作
--返回值：      无
--info：        更新操作需要的信息
function DDZHandCardView:updateOpration(info)
    info = checktable(info);
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS);
    Log.i("updateOpration gameStatus = ", gameStatus);
    Log.i("updateOpration info", info);
    
    if not self.m_handCardView then return end 
    
    if info.action == "buchu" then
        self.m_handCardView:onBuChuClick();
    elseif info.action == "tishi" then
        self.m_handCardView:onTiShiClick();
    elseif info.action == "chupai" then
        self.m_handCardView:onChuClick();
    elseif info.action == "chongxuan" then
        self.m_handCardView:onChongXuanClick();
    elseif info.action == "sort" then
        self.m_handCardView:onSortClick();
    end

end

--函数功能：    发牌
--返回值：      无
--isReconnect： 是否重连
function DDZHandCardView:dealCard(isReconnect)
    self.playLastCard1 = false
    self.playLastCard2 = false
    self.playLastCard3 = false

    local PlayerModel = self:getPlayerModel()
    local handcards = PlayerModel:getProp(DDZDefine.HAND_CARDS)
    handcards = checktable(handcards)
    self.m_pWidget:setVisible(true);
    self.card_num = handcards and #handcards or DDZConst.DEFCARDSNUM

    Log.i("DDZHandCardView:dealCard：", self.card_num)

    if self.m_handCardView then
        self.m_handCardView:dealCard(handcards, isReconnect);
    elseif self.m_rightHandCardView then
        self.m_rightHandCardView:dealCard(handcards, isReconnect);
        if self.card_num <= CARD_REMAIN_NUM_2 and self.card_num > 0 then
            self:showJingdeng();
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true);

        local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
        if self.card_num_img and isPorkerNumber then
            self.card_num_img:setVisible(true);
            self.card_num_img:setString("" .. self.card_num);
        end
    elseif self.m_leftHandCardView then
        self.m_leftHandCardView:dealCard(handcards, isReconnect);
        if self.card_num <= CARD_REMAIN_NUM_2 and self.card_num > 0 then
            self:showJingdeng();
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true);

        local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
        if self.card_num_img and isPorkerNumber then
            self.card_num_img:setVisible(true);
            self.card_num_img:setString("" .. self.card_num);
        end
    else
        if self.card_num <= CARD_REMAIN_NUM_2 and self.card_num > 0 then
            self:showJingdeng();
        else
            self:clearJingdeng()
        end
        self.card:setVisible(true);

        local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
        if self.card_num_img and isPorkerNumber then
            self.card_num_img:setVisible(true);
            self.card_num_img:setString("" .. self.card_num);
        end
    end  
end

--函数功能：    添加底牌
--返回值：      无
function DDZHandCardView:addBottomCard()
    local bottomCards = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_BOTTOMCADS)    
    self.card_num = self.card_num + #bottomCards;
    
    local isPorkerNumber = DataMgr:getInstance():isVisitPokerNumber()
    if self.card_num_img and isPorkerNumber then
        self.card_num_img:setVisible(true)
        self.card_num_img:setString("" .. self.card_num);
    end

    if self.m_handCardView then
        self.m_handCardView:addBottomCard(bottomCards);
    end 
end

--函数功能：    托管改变
--返回值：      无
function DDZHandCardView:onTuoGuanChange()
    Log.i("DDZHandCardView:onTuoGuanChange")
    if not tolua.isnull(self.m_handCardView) then
        self.m_handCardView:onTuoGuanChange();
    end
end

--函数功能：    重置
--返回值：      无
function DDZHandCardView:reset()
    if not tolua.isnull( self.m_handCardView ) then
        self.m_handCardView:reset();
    else
        self:hide();
    end  
end


--函数功能：    根据view创建时传入的seat来获取到玩家的数据模型
--返回值：      返回玩家数据模型
function DDZHandCardView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.SITE) == self.m_data then
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

return DDZHandCardView

-------------------------------------------------------------------------
-- Desc:   二人斗地主游戏手牌UI 继承基类 DDZTWOPRoomView
-- Author:   
-------------------------------------------------------------------------

local DDZTWOPRoomView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPRoomView")
local DDZTWOPOtherHandCardView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPOtherHandCardView")
local DDZTWOPDefine = require("package_src.games.ddztwop.data.DDZTWOPDefine")
local DDZTWOPConst = require("package_src.games.ddztwop.data.DDZTWOPConst")
local DDZTWOPMyHandCardView = require("package_src.games.ddztwop.mediator.widget.DDZTWOPMyHandCardView")
local DDZTWOPHandCardView = class("DDZTWOPHandCardView", DDZTWOPRoomView)

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPHandCardView:initView()
    if self.m_data == DDZTWOPConst.SEAT_MINE then
        self.m_handCardView = DDZTWOPMyHandCardView.new(self.m_delegate)
        self.m_pWidget:addChild(self.m_handCardView)
    elseif self.m_data == DDZTWOPConst.SEAT_RIGHT then
        self.m_handCardView = DDZTWOPOtherHandCardView.new(self.m_delegate)
        self.m_pWidget:addChild(self.m_handCardView)
    else
        assert(false)
    end
end

---------------------------------------
-- 函数功能：   析构  用于移除监听事件
-- 返回值：     无
---------------------------------------
function DDZTWOPHandCardView:dtor()
    if tolua.isnull(self.m_handCardView) then
       Log.i(" i am not exist sorry zhuxi ") 
    end

    if self.m_handCardView then
        self.m_handCardView:close()
    end
end

---------------------------------------
-- 函数功能：    展示玩家操作UI  显示手牌如“没有牌能大过上家的牌”
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:showOpration(info)
    local gameStatus = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    if gameStatus == DDZTWOPConst.STATUS_PLAY then
        if self.m_handCardView then
            self.m_handCardView:setTouchEnabled(true)
        end
    end
end

---------------------------------------
-- 函数功能：    处理游戏结束手牌UI
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:onGameOver()
    if self.m_handCardView then
        if self.m_handCardView.onTuoGuanChange then
            self.m_handCardView:onTuoGuanChange()
        end
        self.m_handCardView:onGameOver()
    else
        self.card_label:setVisible(false)
        if self.jingdeng then
            self.m_pWidget:removeChild(self.jingdeng)
            self.jingdeng = nil
        end
    end
end

---------------------------------------
-- 函数功能：    通过action 处理回调事件
-- 返回值：      无
--[[
    参数：
    info        更新操作数据封装
    {
        action     操作名称
    }
]]
---------------------------------------
function DDZTWOPHandCardView:updateOpration(info)
    info = checktable(info)
    local gameStatus = DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_GAMESTATUS)
    
    if self.m_handCardView then
        if info.action == "buchu" then
            self.m_handCardView:onBuChuClick()
        elseif info.action == "tishi" then
            self.m_handCardView:onTiShiClick()
        elseif info.action == "chupai" then
            self.m_handCardView:onChuClick()
        elseif info.action == "chongxuan" then
            self.m_handCardView:onChongXuanClick()
        elseif info.action == "sort" then
            self.m_handCardView:onSortClick()
        end
    end
   
end

---------------------------------------
-- 函数功能：    手牌发牌函数
-- 返回值：      无
--[[
    参数：
    isReconnect    是否是重新连接
    lordIdx        发牌阶段明牌的下标
    lordCard       明牌数据
]]
---------------------------------------
function DDZTWOPHandCardView:dealCard(isReconnect, lordIdx, lordCard)
    self.m_pWidget:setVisible(true)
    local player = self:getPlayerModel()
    local handcards = clone(player:getProp(DDZTWOPDefine.HAND_CARDS))
    handcards = checktable(handcards)
    
    if handcards then
        self.card_num = #handcards
    else
        self.card_num = 17
    end

    if self.m_handCardView then
        self.m_handCardView:dealCard(handcards, isReconnect)
    end  

end

---------------------------------------
-- 函数功能：    添加二人斗地主底牌到手牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:addBottomCard()
    local bottomCards = clone(DataMgr.getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_BOTTOMCADS))
    self.card_num = self.card_num + #bottomCards

    if self.m_handCardView then
        self.m_handCardView:addBottomCard(bottomCards)
    end  
end

---------------------------------------
-- 函数功能：    托管状态改变处理手牌状态函数
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:onTuoGuanChange()
    if self.m_handCardView and self.m_data == DDZTWOPConst.SEAT_MINE then
        self.m_handCardView:onTuoGuanChange()
    end
end

---------------------------------------
-- 函数功能：    重置手牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:reset()
    if self.m_handCardView then
        self.m_handCardView:reset()
    else
        self:hide()
    end 
end

function DDZTWOPHandCardView:checkChuPai()
    if self.m_data ~= DDZTWOPConst.SEAT_MINE then
        return 
    end
    if self.m_handCardView and self.m_handCardView.onTouchEnd then
        self.m_handCardView:onTouchEnd()
    end
end

---------------------------------------
-- 函数功能：    展示让牌函数
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:showTipCount()
    if self.m_handCardView and self.m_handCardView.showTipCount then
        self.m_handCardView:showTipCount()
    end 
end


---------------------------------------
-- 函数功能：    设置让牌状态
-- 返回值：      无
---------------------------------------
function DDZTWOPHandCardView:setRangCardsStatus()
    if self.m_handCardView and self.m_handCardView.setRangCardsStatus then
        self.m_handCardView:setRangCardsStatus()
    end 
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZTWOPHandCardView:getPlayerModel()
    local playerList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(playerList) do
        if v:getProp(DDZTWOPDefine.SITE) == self.m_data then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("player is nil")
        return nil
    end
    return dstPlayer
end

return DDZTWOPHandCardView
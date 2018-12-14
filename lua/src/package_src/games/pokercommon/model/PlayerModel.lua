-------------------------------------------------------------
--  @file   PlayerModel.lua
--  @brief  玩家数据模型
-------------------------------------------------------------
local PlayerModel = class("PlayerModel")
local BasePlayerDefine = require("package_src.games.pokercommon.data.BasePlayerDefine")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
local DDZDataConst = require("package_src.games.ddz.data.DDZDataConst")
local DDZDefine = require("package_src.games.ddz.data.DDZDefine")
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function PlayerModel:ctor()
	self.props = {}
end

--[
-- @brief  设置属性
-- @param  prop_id 属性ID
-- @param  value 属性值
-- @param  disptch 当有属性改变时，是否要发送事件
-- @return void
--]
function PlayerModel:setProp(prop_id, value, disptch, extinfo)
    if type(prop_id) ~= "number" then
        printError("PropertypCom:setProp - prop_id不是数字")
        return
    end
    local oldvalue  = self:getProp(prop_id)
    local changed   = self.props[prop_id] ~= value

    self.props[prop_id] = value
    -- 属性变更就向外部发送通知
    if changed and disptch then
        --Log.i("disptch prop_id: ", prop_id)
        -- self:getTarget():dispatchCustomEvent(enEntityEvent.ENTITY_PROP_CHANGED_NTF, prop_id, value, oldvalue)
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.PLAYER_PROP_CHANGE, prop_id, value, oldvalue, extinfo)
    end
end

--[
-- @brief  取得属性
-- @param  prop_id 属性ID
-- @return number
--]
function PlayerModel:getProp(prop_id)
    return self.props[prop_id]
end

--[
-- @brief 添加牌
-- @param  cards 要添加牌的table
--]
function PlayerModel:addCards(cards, dispatch)
    local seat = self:getProp(BasePlayerDefine.SITE)
    Log.i("--wangzhi--seat--",seat)
    local handCards  = self:getProp(BasePlayerDefine.HAND_CARDS)
    --Log.i("PlayerModel:addCards before ",handCards)
    table.walk(cards, function(v)
        table.insert(handCards, v)
    end)
    --Log.i("PlayerModel:addCards after ",handCards)
    self.props[BasePlayerDefine.HAND_CARDS] = handCards

    Log.i("--wangzhi--PlayerModel--handCards-",handCards)
    if VideotapeManager.getInstance():isPlayingVideo() then
        local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
        for k,v in pairs(PlayerModelList) do
            if  seat == v:getProp(DDZDefine.SITE) then
                Log.i("--wangzhi--PlayerModel--seat-",seat)
                -- self.m_handCardViews[seat]:dealCard(isReconnect); 
                -- if dispatch then
                    Log.i("--wangzhi--send--add--handCards--", cards,seat)
                    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_ADD, cards,seat)
                -- end
            end
        end
    end

    -- if dispatch then
    --     HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_ADD, info)
    -- end
end

--[
-- @brief   删除牌
-- @param   cards 要删除牌的table
--]
function PlayerModel:delCards(cards, dispatch)
    cards = checktable(cards)
    local seat = self:getProp(BasePlayerDefine.SITE)
    local handCards  = self:getProp(BasePlayerDefine.HAND_CARDS)
    handCards = checktable(handCards)

    local tableFind = function(tb, value)
        for k,v in pairs(tb) do
            if value == v then
                return k
            end
        end
        return false
    end

    local delcard = {}
    for i = 1, #cards do 
        local k =tableFind(handCards, cards[i])
        if k then
            table.remove(handCards, k)
        end
    end
    --Log.i("after ",handCards)
    self.props[BasePlayerDefine.HAND_CARDS] = handCards

    if dispatch then
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.PLAYER_HANDCARDS_DEL,cards,seat)
    end
end

-- 定位信息更新
function PlayerModel:refreshLocationInfo(locationInfo)
    self:setProp(BasePlayerDefine.JING_DU,  locationInfo.jiD)
    self:setProp(BasePlayerDefine.WEI_DU,   locationInfo.weD)
    self:setProp(BasePlayerDefine.LOCATION_TIME,   locationInfo.gpT)  -- 定位时间
end

return PlayerModel

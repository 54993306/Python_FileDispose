local Define        = require "app.games.common.Define"
local Mj            = require "app.games.common.mahjong.Mj"

local HandCardsPanel = import("app.games.common.ui.playlayer.HandCardsPanel")

local jieyangmjHandCardsPanel = class("jieyangmjHandCardsPanel", HandCardsPanel)


--[[
-- @brief  触摸结束函数
-- @param  void
-- @return void
--]]
function jieyangmjHandCardsPanel:onTouchEnd(touch, event)
    -- 触摸结束


    self.super.onTouchEnd(self, touch, event)

    Log.d("<janlog> jieyangmjHandCardsPanel jieyangmjHandCardsPanel jieyangmjHandCardsPanel");


    local location = touch:getLocation()
    Log.d("onTouchEnded: %0.2f, %0.2f", location.x, location.y)

    local laiziList = self.playSystem:getGameStartDatas().laizi;
    local guipai;
    for i = 1, #laiziList do
        guipai = laiziList[i];
    end

    for i=1,#self.handCardsObjs do
        if self.handCardsObjs[i]:isContainsTouch(touch:getLocation().x, touch:getLocation().y) then
    --     and self.handCardsObjs[i]:getMjState() == enMjState.MJ_STATE_ALREADY_SELECTED then
            if self.handCardsObjs[i]:getValue() == guipai then
                Toast.getInstance():show("鬼牌不可点炮胡");
            end
        end
    end

    return true;

end

--[[
-- @brief  打牌能标志函数
-- @param  void
-- @return remainder = 1 不可以打牌 remainder = 2 可以打牌
--]]

function jieyangmjHandCardsPanel:isCanPlayCard(myCardsNum)
    -- 最后一轮不能出牌
    --剩余牌数
    local count = SystemFacade:getInstance():getRemainPaiCount()
    -- 人数
    -- local playerInfos = kFriendRoomInfo:getRoomInfo()
    self.gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local players   = self.gamePlaySystem:gameStartGetPlayers()

    local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    local itemList = Util.analyzeString_2(palyingInfo.wa);


    local shouldRemain = 0   --应该留几张奖马牌
    for _,v in ipairs(itemList) do
        if v == "jiangma" then
            shouldRemain = 0;
        end
        if v == "jiangma2" then
            shouldRemain = 2;
        end
        if v == "jiangma4" then
            shouldRemain = 4;
        end
        if v == "jiangma6" then
            shouldRemain = 6;
        end
        if v == "jiangma8" then
            shouldRemain = 8;
        end
        if v == "jiangma10" then
            shouldRemain = 10;
        end
    end
    if  count < shouldRemain then
        return false
    end


    local remainder = myCardsNum % 3

    -- 获取花牌
    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local flowers = playSystem:getGameStartDatas().isFlowers
    local hasFlower = false
    -- 遍历手牌判断是否有花牌
    if flowers and #flowers > 0 and self.handCardsObjs and #self.handCardsObjs > 0 then
        for i = 1, #self.handCardsObjs do
            for j=1, #flowers do
                if self.handCardsObjs[i]:getValue() == flowers[j] then
                    Log.d("hasFlower")
                    hasFlower = true
                    remainder = 1
                end
            end
        end
    end

    return remainder == enHandCardRemainder.CAN_PLAY
end

return jieyangmjHandCardsPanel
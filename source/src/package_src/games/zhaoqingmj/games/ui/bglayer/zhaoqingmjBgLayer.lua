--
-- Author: Jinds
-- Date: 2017-07-04 09:16:26
--
local BgLayer = require("app.games.common.ui.bglayer.BgLayer")
local zhaoqingmjBgLayer = class("zhaoqingmjBgLayer", BgLayer)

-- @brief  刷新剩余数据
-- @param  void
-- @return void
--]]
function zhaoqingmjBgLayer:refreshRemainCount(event)


    print("<jinds>: zhaoqingmjBgLayer")
    if self._shengyu then
        local count = SystemFacade:getInstance():getRemainPaiCount()
        if count < 0 then
            count = 0
        end
        -----------------------回放-----------------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            local jushu  = kPlaybackInfo:getCurrentGamesNum()
            local syText = string.format("剩余 %s 张    第 %d 局", count, jushu)
            self._shengyu:setString(syText)
        else
            if event then
                local animation = unpack(event._userdata)
                -- 胡牌动作发生时, 不再刷新牌局数量
                if animation == "AnimationHU" or animation == "AnimationTIANHU" then
                    return
                end
            end
            local currCount     = SystemFacade:getInstance():getCurrentGameCount() or 0
            local totalCount    = SystemFacade:getInstance():getTotalGameCount() or 0
            local syText = string.format("剩余 %s 张    第 %d/%d 局",count, (currCount<=totalCount) and currCount or totalCount, totalCount)
            self._shengyu:setString(syText)
------------------------------add--------------------------------------------------------------------------
            local players  =  self.gamePlaySystem:gameStartGetPlayers()       -- 玩家信息    
            local playerCount = #players

            local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
            dump(palyingInfo.wa)
            local noOutLastFour = false;

            if string.find(palyingInfo.wa,"buchushou") then
                noOutLastFour = true
            end

            print("<jinds>: count, playerCount ", count, playerCount)
            if count == playerCount then
                if noOutLastFour then
                    Toast.getInstance():show("最后一轮不出手")
                else
                    Toast.getInstance():show("最后一轮出手")
                    --todo
                end

            end

---------------------------------------------------------------------------------------------------------------------

        end
        ----------------------------------------------------------------
    end
end


return zhaoqingmjBgLayer
--
-- Author: Jinds
-- Date: 2017-06-19 21:03:09
--
local BgLayer = require("app.games.common.ui.bglayer.BgLayer")
local jieyangmjBgLayer = class("jieyangmjBgLayer", BgLayer)

local kRuleBtnSize = cc.size(70, 40)

-- @brief  刷新剩余数据
-- @param  void
-- @return void
--]]
function jieyangmjBgLayer:refreshRemainCount(event)
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

            -- if count == 4 then
            --     Toast.getInstance():show("最后一轮摸牌")    
            -- end
        end
        ----------------------------------------------------------------
    end
end

return jieyangmjBgLayer
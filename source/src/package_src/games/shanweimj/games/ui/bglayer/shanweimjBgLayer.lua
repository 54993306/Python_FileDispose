local BgLayer = require("app.games.common.ui.bglayer.BgLayer")
local shanweimjBgLayer       = class("shanweimjBgLayer", BgLayer)

-- @brief  刷新剩余数据
-- @param  void
-- @return void
--]]
function shanweimjBgLayer:refreshRemainCount(event)
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
                if animation == "AnimationHU" or animation == "AnimationTIANHU" then--or animation == "AnimationLiuJu" 
                    return
                end
            end

            local currCount     = SystemFacade:getInstance():getCurrentGameCount() or 0
            local totalCount    = SystemFacade:getInstance():getTotalGameCount() or 0

            --修复流局后 当前局数马上+1的问题（即不进行+1）
            if currCount and currCount<=totalCount and count == 0 then
                if self.lastJuShu ~= currCount then
                    currCount = currCount - 1
                end
            end
            self.lastJuShu = (currCount<=totalCount) and currCount or totalCount

            local syText = string.format("剩余 %s 张    第 %d/%d 局",count, (currCount<=totalCount) and currCount or totalCount, totalCount)
            self._shengyu:setString(syText)
        end
        ----------------------------------------------------------------
    end
end

return shanweimjBgLayer

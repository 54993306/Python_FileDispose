local  gamePalyingName={
    [1] = {title = "3zha",         ch = "8倍"},
    [2] = {title = "4zha",         ch = "16倍"},
    [3] = {title = "5zha",         ch = "32倍"},
    [4] = {title = "1b",           ch = "1倍"},
    [5] = {title = "2b",           ch = "2倍"},
    [6] = {title = "yjxj",         ch = "赢家先叫"},
    [7] = {title = "syp",          ch = "显示剩余牌数"},

    [8] = {title = "3zha",         ch = "16倍"},
    [9] = {title = "4zha",         ch = "32倍"},
    [10] = {title = "5zha",        ch = "64倍"},
}

-- local  gamePalyingName={
--     {title = "3zha",         ch = "8倍"},
--     {title = "4zha",         ch = "16倍"},
--     {title = "5zha",         ch = "32倍"},
--     {title = "1b",           ch = "1倍"},
--     {title = "2b",           ch = "2倍"},
--     {title = "yjxj",         ch = "赢家先叫"},
--     {title = "syp",          ch = "显示剩余牌数"},

--     {title = "3zha",         ch = "16倍"},
--     {title = "4zha",         ch = "32倍"},
--     {title = "5zha",        ch = "64倍"},
-- }


ddzbeishu = ddzbeishu or 1

return {
    -- 游戏玩法规则  
    -- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
    _gamePalyingName = gamePalyingName,
    -- 规则获取放在这儿, 方便不同游戏修改规则文本
    -- @return table: {ch = "xx"}

    -- kGetPlayingInfoByTitle = function (title)

    --     for k, v in pairs(gamePalyingName) do
    --         if (v.title == title) then
    --             return v
    --         end
    --     end
    --     return nil
    -- end

    kGetPlayingInfoByTitle = function (title)
        -- print(debug.traceback())
        -- for k, v in pairs(gamePalyingName) do
        --     Log.i("k", k)
        --     if (v.title == "1b") then
        --         Log.i("1bzzzzzzzzzzzz")
        --         ddzbeishu = 1
        --     elseif (v.title == "2b") then
        --         Log.i("2bzzzzzzzzzzzz")
        --         ddzbeishu = 2
        --     end
        -- end
        if title =="1b" then
            ddzbeishu = 1
        elseif title =="2b" then
            ddzbeishu = 2
        end
        
        -- Log.i("ddzbeishu", ddzbeishu)
        for k, v in pairs(gamePalyingName) do
            if ddzbeishu == 1 then 
                if (v.title == title) and k <=7 then
                    -- Log.i("--wangzhi--倍数为1时候--选择的倍数--",title,v)
                    return v
                end
            elseif ddzbeishu == 2 then 
                if (v.title == title) and k >=4 then
                    -- Log.i("--wangzhi--倍数为2时候--选择的倍数--",title,v)
                    return v
                end
            end
        end
        return nil
    end

    -- -- 获取额外的规则信息
-- getGamePalyingText = function getGamePalyingText
--     Log.i("getGamePalyingText", kFriendRoomInfo:getSelectRoomInfo())
--     local ret = {}
--     local fa = kFriendRoomInfo:getSelectRoomInfo().fa
--     local text = string.format(kFanMaInfo.fanmaText, fa)
--     if fa == kFanMaInfo.specialFanma then text = kFanMaInfo.specialText end
--     table.insert(ret, text)
--     return ret
-- end,
}
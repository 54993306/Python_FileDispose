local  gamePalyingName={
    [1] = {title = "hongzhongweigui",      ch = "红中为鬼"},
    [2] = {title = "budaihongzhong",       ch = "不带鬼"},
    [3] = {title = "yima",                 ch = "1马"},
    [4] = {title = "sima",                 ch = "4马"},
    [5] = {title = "liuma",                ch = "6马"},
    [6] = {title = "bama",                 ch = "8马"},
    [7] = {title = "shima",                ch = "10马"},
    [8] = {title = "anweizhiquerenma",     ch = "按位置确定马"},
    [9] = {title = "gudingma",             ch = "固定马"},
}
return {
    -- 游戏玩法规则  
    -- fangpaokehu|sihui|qihui|kepeng|bukebaoting|baotingjiafan
    _gamePalyingName = gamePalyingName,
    -- 规则获取放在这儿, 方便不同游戏修改规则文本
    -- @return table: {ch = "xx"}
    kGetPlayingInfoByTitle = function (title)
        for k, v in pairs(gamePalyingName) do
            if (v.title == title) then
                return v
            end
        end
        return nil
    end
}
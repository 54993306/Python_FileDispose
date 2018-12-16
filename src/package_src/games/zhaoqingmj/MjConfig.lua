local  gamePalyingName={
    [1] = {title = "gui",            ch = "白板为鬼"},
    [2] = {title = "wugui",           ch = "不带鬼"},
    [3] = {title = "onema",          ch = "1马"},
    [4] = {title = "fourma",             ch = "4马"},
    [5] = {title = "sixma",            ch = "6马"},
    [6] = {title = "eightma",             ch = "8马"},
    [7] = {title = "tenma",             ch = "10马"},
    [8] = {title = "fixma",          ch = "固定马"},
    [9] = {title = "positionma",             ch = "按位置确定马"},
    [10] = {title = "chushou",          ch = "最后一轮出手"},
    [11] = {title = "buchushou",             ch = "最后一轮不出手"},
    [12] = {title = "onedi",             ch = "1底"},
    [13] = {title = "fivedi",             ch = "5底"},
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
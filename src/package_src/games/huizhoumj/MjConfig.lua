local gamePalyingName={
    [1] = {title = "1_di",               ch = "1底"},
    [2] = {title = "2_di",               ch = "2底"},
    [3] = {title = "3_di",               ch = "3底"},
    [4] = {title = "4_di",               ch = "4底"},
    [5] = {title = "5_di",               ch = "5底"},
    [6] = {title = "6_di",               ch = "6底"},
    [7] = {title = "7_di",               ch = "7底"},
    [8] = {title = "8_di",               ch = "8底"},
    [9] = {title = "9_di",               ch = "9底"},
    [10] = {title = "10_di",             ch = "10底"},
    [11] = {title = "2_ma",               ch = "2马"},
    [12] = {title = "4_ma",               ch = "4马"},
    [13] = {title = "6_ma",               ch = "6马"},
    [14] = {title = "8_ma",               ch = "8马"},
    [15] = {title = "10_ma",              ch = "10马"},
    [16] = {title = "maigang",          ch = "买杠"},
    [17] = {title = "suanhua",          ch = "鸡胡算花"},
    [18] = {title = "fanma",            ch = "抢杠胡翻马"},
}


return {
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
local  gamePalyingName = {
    [1] = {title = "keqiangganghu",                             ch = "可抢杠胡"},
    [2] = {title = "qianggangbaosanjia",                        ch = "抢杠全包"},
    [3] = {title = "budaifeng",                                 ch = "无风"},
    [4] = {title = "genzhuang",                                 ch = "跟庄"},
    [5] = {title = "jiejiegao",                                 ch = "节节高"},
    [6] = {title = "wugui",                                     ch = "无鬼"},
    [7] = {title = "fangui",                                    ch = "翻鬼"},
    [8] = {title = "shuanggui",                                 ch = "双鬼"},
    [9] = {title = "erma",                                      ch = "2马"},
    [10] = {title = "sima",                                     ch = "4马"},
    [11] = {title = "liuma",                                    ch = "6马"},
    [12] = {title = "bama",                                     ch = "8马"},
    [13] = {title = "shima",                                    ch = "10马"},
    [14] = {title = "ershima",                                  ch = "20马"},
    [15] = {title = "wuma",                                     ch = "无马"},
    [16] = {title = "guipai",                                   ch = "鬼牌"},
    [17] = {title = "maima",                                     ch = "买马"},
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
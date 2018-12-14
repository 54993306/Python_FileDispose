local  gamePalyingName = {
    [1] = {title = "humasuanquanma",                        ch = "胡马算全马"},
    [2] = {title = "magengqingyise",                        ch = "马跟清一色"},
    [3] = {title = "magenghunyise",                         ch = "马跟混一色"},
    [4] = {title = "magengquanzi",                          ch = "马跟全字"},
    [5] = {title = "magengshisanyao",                       ch = "马跟十三幺"},
    [6] = {title = "erma",                                  ch = "2马"},
    [7] = {title = "sanma",                                 ch = "3马"},
    [8] = {title = "sima",                                  ch = "4马"},
    [9] = {title = "liuma",                                 ch = "6马"},
    [10] = {title = "bama",                                 ch = "8马"},
    [11] = {title = "yifenliangfen",                        ch = "1分2分"},
    [12] = {title = "liangfensifen",                        ch = "2分4分"},
    [13] = {title = "wufenshifen",                          ch = "5分10分"},
    [14] = {title = "shifenershifen",                       ch = "10分20分"},
    [15] = {title = "difen",                                ch = "底分"},
    [16] = {title = "fanma",                                ch = "翻马"},
    [17] = {title = "wanfa",                                ch = "玩法"},
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
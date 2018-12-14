local  gamePalyingName = {
    [1] = {title = "zhuangmaima",                           ch = "庄买马"},
    [2] = {title = "shuihushuifanma",                       ch = "谁胡谁翻马"},
    [3] = {title = "bufanma",                               ch = "不翻马"},
    [4] = {title = "zhigangbao",                            ch = "直杠杠爆全包"},
    [5] = {title = "huangjinbufanma",                       ch = "黄金不翻马"},
    [6] = {title = "shisanyaobufanma",                      ch = "十三幺不翻马"},
    [7] = {title = "genzhuang",                             ch = "跟庄"},
    [8] = {title = "1f2f",                                  ch = "1分2分"},
    [9] = {title = "2f4f",                                  ch = "2分4分"},
    [10] = {title = "5f10f",                                 ch = "5分10分"},
    [11] = {title = "10f20f",                                ch = "10分20分"},
    [12] = {title = "4ma",                                  ch = "4马"},
    [13] = {title = "6ma",                                  ch = "6马"},
    [14] = {title = "8ma",                                  ch = "8马"},
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
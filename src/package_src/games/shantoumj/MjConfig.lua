local  gamePalyingName={
    [1] = {title = "1fen",      ch = "1分2分"},
    [2] = {title = "2fen",      ch = "2分4分"},
    [3] = {title = "5fen",      ch = "5分10分"},
    [4] = {title = "10fen",      ch = "10分20分"},
    [5] = {title = "jm0",      ch = "奖马0马"},
    [6] = {title = "jm2",      ch = "奖马2马"},
    [7] = {title = "jm4",      ch = "奖马4马"},
    [8] = {title = "jm5",      ch = "奖马5马"},
    [9] = {title = "jm6",      ch = "奖马6马"},
    [10] = {title = "jm7",     ch = "奖马7马"},
    [11] = {title = "jm8",     ch = "奖马8马"},
    [12] = {title = "jm9",     ch = "奖马9马"},
    [13] = {title = "jm10",     ch = "奖马10马"},
    [14] = {title = "maima0",     ch = "买马0马"},
    [15] = {title = "maima1",     ch = "买马1马"},
    [16] = {title = "maima2",     ch = "买马2马"},
    [17] = {title = "maima3",     ch = "买马3马"},
    [18] = {title = "maima4",     ch = "买马4马"},
    [19] = {title = "maima5",     ch = "买马5马"},
    [20] = {title = "dahu*10",     ch = "天胡:大胡x10"},
    [21] = {title = "dahu*dice",     ch = "天胡:大胡x骰子数"},
    [22] = {title = "hzfanbei",     ch = "黄庄翻倍"},
    [23] = {title = "hziazjm",     ch = "黄庄加中奖马"},
    [24] = {title = "lzfanbei",     ch = "连庄翻倍"},
    [25] = {title = "l4zfanbei",     ch = "连四庄翻倍"},
    [26] = {title = "l3zjm",     ch = "连三庄加马"},
    [27] = {title = "jiangmabuliupai",     ch = "奖马不留牌"},
    [28] = {title = "hdlsdh",     ch = "海底捞算大胡"},
    [29] = {title = "daidihu",     ch = "带地胡"},
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
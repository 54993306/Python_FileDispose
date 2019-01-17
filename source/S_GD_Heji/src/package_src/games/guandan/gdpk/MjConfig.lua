local  gamePalyingName={
    [1]={title="suijizudui", ch="随机组队"},
    [2]={title="duiyouzudui", ch="组队"},
    [3]={title="shengji", ch="升级"},
    [4]={title="bushengji", ch="不升级"},
    [5]={title="guo6", ch="过6"},
    [6]={title="guo10", ch="过10"},
    [7]={title="guoA", ch="过A"},
}

return {
    -- 游戏玩法规则  
    _gamePalyingName = gamePalyingName,

    kGetPlayingInfoByTitle = function (title)
        for k, v in pairs(gamePalyingName) do
            if (v.title == title) then
                return v
            end
        end
        return nil
    end
}
local  gamePalyingName={
    [1]={title="16zhang", ch="16张"},
    [2]={title="heitao3", ch="黑桃3先"},
    [3]={title="yjxj", ch="赢家先(首局黑桃3)"},
    [4]={title="4dai2", ch="4带2"},
    [5]={title="AAAzhadan", ch="3个A算炸弹"},
    [6]={title="zhandanjiafen", ch="炸弹加分"},
    [7]={title="xianshipai", ch="显示牌数"},
    [8]={title="xiaoguan2", ch="小关x2"},
    [9]={title="daguan", ch="大关"},
    [10]={title="daguan2", ch="大关x2"},
    [11]={title="daguan3", ch="大关x3"},
    [12]={title="3zsdjw|fjsdjw", ch="三张、飞机可少带接完"},
    -- [13]={title="fjsdjw", ch="飞机可少带接完"},
    [13]={title="3dai2", ch="3带2"},
    [14]={title="3dai1", ch="3带1"},
    [15]={title="3zsdjw", ch="三张、飞机可少带接完"},
    [16]={title="fjsdjw", ch="三张、飞机可少带接完"}
}

local  gamePalyingName2={
    [1]={title="heitao3", ch="黑桃3先出"},
    [2]={title="yjxj", ch="赢家先手(首局黑桃3)"},
    [3]={title="AAAzhadan", ch="3个A算炸弹"},
    [4]={title="xiaoguan2", ch="小关x2"},
    [5]={title="daguan2", ch="大关x2"},
    [6]={title="daguan3", ch="大关x3"},
    [7]={title="3zsdjw|fjsdjw", ch="三张可少带接完"},
    -- [8]={title="fjsdjw", ch="飞机可少带接完"},
    [8]={title="3dai2", ch="3带2"},
    [9]={title="3dai1", ch="3带1"},
    [10]={title="4dai2", ch="4带2"},
    [11]={title="zhandanjiafen", ch="炸弹加分"},
    [12]={title="3zsdjw", ch="三张可少带接完"},
    [13]={title="fjsdjw", ch="飞机可少带接完"},
}

if tostring(PRODUCT_ID) == tostring(3422) then
    gamePalyingName={
        [1]={title="16zhang", ch="16张"},
        [2]={title="heitao3", ch="黑桃3先"},
        [3]={title="yjxj", ch="赢家先(首局黑桃3)"},
        [4]={title="4dai2", ch="4带2"},
        [5]={title="AAAzhadan", ch="3个A算炸弹"},
        [6]={title="zhandanjiafen", ch="炸弹加分"},
        [7]={title="xianshipai", ch="显示牌数"},
        [8]={title="xiaoguan2", ch="小关x2"},
        [9]={title="daguan", ch="大关"},
        [10]={title="daguan2", ch="大关x2"},
        [11]={title="daguan3", ch="大关x3"},
        [12]={title="3zsdjw|fjsdjw", ch="三张、飞机可少带接完"},
        [13]={title="3dai1", ch="3带1"},
        [14]={title="3dai2", ch="3带2"},
		[15]={title="3zsdjw", ch="三张、飞机可少带接完"},
		[16]={title="fjsdjw", ch="三张、飞机可少带接完"}
        
    }

    gamePalyingName2={
        [1]={title="heitao3", ch="黑桃3先出"},
        [2]={title="yjxj", ch="赢家先手(首局黑桃3)"},
        [3]={title="AAAzhadan", ch="3个A算炸弹"},
        [4]={title="xiaoguan2", ch="小关x2"},
        [5]={title="daguan2", ch="大关x2"},
        [6]={title="daguan3", ch="大关x3"},
        [7]={title="3zsdjw", ch="三张可少带接完"},
        [8]={title="fjsdjw", ch="飞机可少带接完"},
        [9]={title="3dai1", ch="3带1"},
        [10]={title="3dai2", ch="3带2"},
        [11]={title="4dai2", ch="4带2"},
        [12]={title="zhandanjiafen", ch="炸弹加分"},
    }
end

ddzbeishu = ddzbeishu or 1

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
    end,
    kGetPlayingInfoByTitle2 = function (title)
        for k, v in pairs(gamePalyingName2) do
            if (v.title == title) then
                return v
            end
        end
        return nil
    end
}
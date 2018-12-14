-------------------------------------------------------------
--  @file   RuleTable.lua
--  @brief  规则内容
--  @author Linxiancheng
--  @DateTime:2017-04-20 16:30:22
--  Version: 1.0.0
--  Company  SteveSoft LLC.colourSliderValueChanged(sender, controlEvent)
--  Copyright  Copyright (c) 2016
--============================================================

local textIndent = "　　" -- 首行缩进
local commonSmallTitle = textIndent .. "跑得快，也称：“争上游”，此游戏主要流行于江浙一带，大学校园当中亦很盛行。游戏规则决定了玩家需要尽快把自己手中的牌尽量多的打出去，先把手中的牌出完的玩家获得胜利。失败的玩家，根据手中所剩的牌的张数计算，剩余的牌越多扣的分数越多。"

local Content =
{
    {
        redTitle = "\n【游戏规则】",
        content  = textIndent .. "1.牌数:扑克牌中去掉大小王，三张2及黑桃A，共计48张牌。"
    },
    {
        content  = textIndent .. "2.发牌:系统随机发牌，首局摸到黑桃3的玩家先出牌，然后按顺序出牌，最先出完手上牌的玩家获胜，能管必管，不能过牌。"
    },
    {
        redTitle = "\n【玩法】",
    },
    {
        content = textIndent .. "1.黑桃三先出:摸到黑桃3的玩家先出牌(第一手须含黑桃3)。"
    },
    {
        content = textIndent .. "2.三带二:三张带任意两张牌，最后一手时且玩家先出牌时，可以出三张、三带一(不是最后一手时不可出三张、三带一)。"
    },
    {
        content = textIndent .. "3.对子：任意两张一样点数的牌，例：44"
    },
    {
        content  = textIndent .. "4.连对:二对起，张数不限。"
    },
    {
        content  = textIndent .. "5.四带二：四张相同点数的牌可以带上二张牌，两张牌可为一对对牌或两张任意单牌，例：4444+5+6或4444+55"
    },
    {
        content  = textIndent .. "6.飞机:大于或等于两个相连的三张点数相同的牌，必须带三张对应组数(X)的2X张牌，例:333444+589J。"
    },
    {
        content = textIndent .. "7.炸弹：四张点数一样的牌，例：KKKK"
    },
    {
        redTitle = "\n【特殊玩法】",
    },
    {
        content  = textIndent .. "1.三个A算炸弹，为最大的炸弹。"
    },
        {
        content  = textIndent .. "2.赢家先出:首局拿黑桃3的玩家先出，则这个玩家第一手牌必须带黑桃3。次局开始由上局赢家先出。"
    },

    {
        content  = textIndent .. "3.三带一:勾选三带一时，最后一手时且玩家先出牌时，可以出三张(不是最后一手时不可出三张)。"
    },
    {
        content  = textIndent .. "4.下家报单时，轮到其上家出牌时必须出任意非单牌的牌型或单牌牌型中最大的牌。"
    },
    {
        content  = textIndent .. "5.三张可少带接完:玩家最后一手牌跟牌时，在点数大于最近一手玩家的前提下，可以带0-三张该出的牌。"
    },
    {
        content  = textIndent .. "6.飞机可少带接完:玩家最后一手牌跟牌时，在点数大于最近一手玩家的前提下，可以带0-几组三张该出的牌。"
    },
    {
        redTitle = "\n【结算】",
    },
    {
        content  = textIndent .. "1.胜利玩家与另外两名玩家分别结算，胜家赢分=上家输分+下家输分。"
    },
    {
        content  = textIndent .. "2.玩家剩余一张牌不扣分。"
    },
    {
        content  = textIndent .. "3.小关*2:剩余13至15张，此时总分X2。"
    },
    {
        content  = textIndent .. "4.大关*2:一张牌没出，此时总分X2。"
    },
    {
        content  = textIndent .. "5.大关*3:一张牌没出，此时总分X3。"
    },
    {
        content  = textIndent .. "6.当出现炸弹时，最后管牌的玩家+20分，其余玩家各-10分，炸弹实时结算。"
    },
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
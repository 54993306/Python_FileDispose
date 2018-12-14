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
local commonSmallTitle = textIndent .. "您需要邀请3个好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！"

local Content =
{
    {
        redTitle = "\n【麻将用具】",
        content  = textIndent .. "由条、饼、万、东南西北中发白组成，合计136张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. " 霸王庄，一炮多响放炮者当庄，多家抢杠胡倍抢杠者当庄，黄庄庄家不变。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "牌抓完未胡牌黄庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1.可碰、可杠、不可吃牌，根据开局选项可以吃炮，可自摸。"
    },
    {
        content  = textIndent .. "2.底分1分，放炮付3，自摸3家各付3，明杠3家各付1，暗杠3家各付2，直杠放杠者出3。"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "1.10倍听牌可以接炮：当玩家听在10倍以上（包括10倍）大胡时，可以被点炮。被点炮的情况胡牌时，不计算抓马和买马分，自摸胡牌计算抓马和买马分。"
    },
    {
        content  = textIndent .. "2.10倍听牌可以免分：玩家听10倍牌时，再打牌时点炮或者点杠都不会被计算分数。"
    },

    {
        content  = textIndent .. "3.地胡首圈未抓牌可胡牌:首圈地胡在未抓牌的情况下，可以自摸和吃胡。地胡只胡庄炮:首圈地胡只能胡庄家打出的牌。"
    },

     {
        content  = textIndent .. "4.鬼牌：鬼牌可以替换牌型中所缺的任意一张牌。鬼牌可以选择白板做鬼、红中做鬼或者翻鬼，系统随机翻一张牌，翻到牌的下一张为鬼牌，如翻到东风则南风为鬼。鬼牌可以打出，可碰可杠，打出后只能当牌本身用，不能当鬼牌用。翻鬼中确定鬼牌的这张牌不可被抓走，鬼牌打出去别人不能抓炮。"
    },

     {
        content  = textIndent .. "5.买马：即为奖马，由胡牌的人在胡牌后翻马。"
    },
     {
        content  = textIndent .. "6.抓马：开局时从牌墙后摸4张牌，在每位玩家牌墙前放一张扣着的牌，若买中赢家则每家（此处每家不包括赢家，但包括自己）付给该玩家2底分分。如果没买中，则不用给额外的积分。"
    },
    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "1.以推倒胡为规则。"
    },
    {
        content  = textIndent .. "2.不可胡十三乱（十三不靠）、大乱。"
    }
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
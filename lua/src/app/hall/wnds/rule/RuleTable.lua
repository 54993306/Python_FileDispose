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
        content  = textIndent .. "“来来宿州麻将”由条、饼、万、东南西北中发白、春夏秋冬、梅兰菊竹组成，合计144张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "轮庄。起始东风玩家为庄，之后如果庄家胡牌或黄庄，上局庄家继续坐庄，如果闲家胡牌，下局则庄家的下家当庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "剩下20张牌黄庄，有一个杠加2张（花牌不算）。剩下黄庄牌数时不能在杠（补花）。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1、中、发、白、为花牌，抓到可直接选择杠（补花），打到什么风圈时什么是花。（例：东风圈时东风为花，西风圈时西风为花。）（起始为东风圈，每个人都当过庄后，坐东风玩家第二次上庄时为下一风圈，风圈顺序为东、南、西、北。）"
    },
    {
        content  = textIndent .. "2、花牌不能被打出"
    },
    {
        content  = textIndent .. "3、4会可碰、不可吃；7会不可吃，不可碰，不可明杠。"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "1、有癞子（会），打色子确定癞子（翻起的牌加1为癞子，如果翻起的牌为花牌，则该张牌为癞子）（例：翻起的牌为4万，则五万为癞子；如果翻起的牌为红中，则红中为癞子）"
    },
    {
        content  = textIndent .. "2、癞子牌可以被打出，对打出者没有影响。其他玩家不能吃碰这张牌。"
    },
    {
        content  = textIndent .. "3、翻出确定癞子的那张牌不能被抓走。"
    },
    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "1、以推倒胡为规则。"
    },
    {
        content  = textIndent .. "2、4会只能自摸胡牌，7会自摸和放炮可胡。"
    }
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
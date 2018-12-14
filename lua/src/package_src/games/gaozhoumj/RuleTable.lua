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
local commonSmallTitle = textIndent .. "您需要邀请好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！"

local Content =
{
    {
        redTitle = "\n【麻将用具】",
        content  = textIndent .. "由条、饼、万、东南西北中发白组成，合计136张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "谁胡谁坐庄；首局按照东南西北的位置，东位先做庄。但是多家抢杠胡的时候则被抢的人为庄。黄庄后，下局庄家的选定有两种情况，会在创建房间的时候做选项：（1）黄庄抓尾坐庄；（2）黄庄不换庄。默认不换庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "玩几马的后面留几张牌，例如玩6马，后面要留6张牌，摸到倒数第7张牌的玩家如果没有自摸，就直接黄庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1、系统抓牌时顺时针抓牌，玩家出牌时按逆时针出牌；"
    },
    {
        content  = textIndent .. "2、玩家只能碰和杠，不许吃；"
    },
    {
        content  = textIndent .. "3、自摸胡牌，能抢杠胡；"
    },
     {
        content  = textIndent .. "4、玩几马的后面留几张牌；"
    },
     {
        content  = textIndent .. "5、杠牌后，杠牌的玩家需在码牌的最后面抓一张牌，如果后面只剩下马牌则不再抓牌直接黄庄；"
    },
     {
        content  = textIndent .. "6、有谁胡谁翻马和不翻马的玩法；"
    },
     {
        content  = textIndent .. "7、有黄庄抓尾坐庄或者黄庄不换庄的玩法，默认黄庄不换庄；"
    },
     {
        content  = textIndent .. "8、可以选择杠参与马或者杠不参与马的玩法，默认杠不参与马；"
    },
        {
        content  = textIndent .. "9、出手：最后一张牌要去抓，但是不出手。"
    },
        

    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "无"
    },
   

    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "1、自摸：玩家自己摸牌胡（“高州麻将”玩家只能自摸胡牌）；"
    },
    {
        content  = textIndent .. "2、七对：由七个对子组成的胡牌；"
    },
    {
        content  = textIndent .. "3、豪华七对：七个对子中由两个及以上的对子相同所组成的胡牌"
    },
     {
        content  = textIndent .. "4、清一色：全部由一种花色组成的牌，包括万一色、饼一色、条一色、字一色；"
    },
     {
        content  = textIndent .. "5、十三幺：由一九万、条、筒、字牌各一张再加上这十三张牌的任一张组成的胡牌；"
    },



}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
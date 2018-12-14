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

local ruleContent =
{
    {
        redTitle = "\n【麻将用具】",
        content  = textIndent .. "由条、饼、万、东南西北中发白组成，合计136张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "谁胡牌谁当庄家，首次开局按照玩家座位的东南西北方向，选定东为首次庄家。荒庄后，不变化庄家，多家抢杠胡后，谁被抢杠胡谁坐庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "玩几马留几马，黄庄不换庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1、系统抓牌时顺时针抓牌，玩家出牌时按逆时针出牌；"
    },
    {
        content  = textIndent .. "2、玩家只能碰和杠，不许吃；"
    },
    {
        content  = textIndent .. "3、只许自摸胡牌。能抢杠胡；"
    },
    {
        content  = textIndent .. "4、可以选择庄买马（自带杠参与马），谁胡谁翻马（自带杠不参与马），不翻马三种玩法，选择不同的玩法，胡牌结算相应不同；"
    },
    {
        content  = textIndent .. "5、系统默认直杠杠爆包三家，黄金不翻马，十三幺不翻马（黄金胡牌后*4，十三幺*13，7小对*2.）；"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "无"
    },
    {
        redTitle = "\n【胡牌规则】",
        content  = textIndent .. "1.自摸：玩家自己摸牌胡（“茂名麻将”玩家只能自摸胡牌）；"
    },
    {
        content  = textIndent .. "2.七对：由七个对子组成的胡牌；"
    },
    {
        content  = textIndent .. "3.豪华七对：七个对子中由两个及以上的对子相同所组成的胡牌；"
    },
    {
        content  = textIndent .. "4.清一色：全部由一种花色组成的牌，包括万一色、饼一色、条一色、字一色；"
    },
    {
        content  = textIndent .. "5.十三幺：由一九万、条、筒、字牌各一张再加上这十三张牌的任一张组成的胡牌；"
    },
}



local ruleTable =
{
    smallTitle = commonSmallTitle,
	ruleContent = ruleContent
}

return ruleTable
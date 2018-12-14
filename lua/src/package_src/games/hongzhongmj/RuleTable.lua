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
        content  = textIndent .. "由饼、条、万、红中组成，合计112张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "霸王庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "剩下4张牌时黄庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1、可以吃（选项）、碰、杠。"
    },
    {
        content  = textIndent .. "2、可以点炮（选项）、可以自摸胡牌、也可以抢杠胡牌（选项）。"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "1、红中为百搭（赖子）。"
    },
    {
        content  = textIndent .. "2、抢杠胡付三份，可多家抢杠，有红中就不能抢杠胡。"
    },
    {
        content  = textIndent .. "3、胡牌1个底，庄加2底。"
    },
    {
        content  = textIndent .. "4、手中无红中胡牌，加一底。"
    },
    {
        content  = textIndent .. "5、直杠，点杠者付3个底。"
    },
    {
        content  = textIndent .. "6、补杠，每人付1个底。"
    },
    {
        content  = textIndent .. "7、暗杠，每人付2个底。"
    },
    {
        content  = textIndent .. "8、抓到4张红中，牌局结束，直接结算，不翻马，直接加全马数量。"
    },
    {
        content  = textIndent .. "9、荒庄不黄杠，杠单独计算。"
    },
    {
        content  = textIndent .. "10、翻马，红中、159为马。"
    },
    {
        content  = textIndent .. "11、翻1马则翻几乘几。"
    },
    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "以推倒胡为规则。"
    },
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
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

local xinpumj =
{
    smallTitle = commonSmallTitle,
    ruleContent = {
        {
            redTitle = "\n【麻将用具】",
            content  = textIndent .. [[分别有136.120.112.108张牌。]]
        },
        {
            content  = textIndent .. "136：条筒万1-9，东南西北中发白。"
        },
        {
            content  = textIndent .. "120：只有条筒万1-9，中发白。"
        },
        {
            content  = textIndent .. "112：条筒万1-9，留下白板或者红中。"
        },
        {
            content  = textIndent .. "108：条筒万1-9.没有字牌。"
        },
        {
            redTitle = "\n【庄家规则】",
            content  = textIndent .. [[霸王庄，一炮多响是输家当庄，多家抢杠胡被抢杠的人当庄。]]
        },
        {
            redTitle = "\n【黄庄规则】",
            content  = textIndent .. [[玩几个马就剩下几张牌流局。]]
        },
        {
            content  = textIndent .. "玩1马时抓完黄庄。"
        },
        {
            content  = textIndent .. "无鬼胡马牌数+2，或者+4时，增加几张流局。"
        },
        {
            redTitle = "\n【基本玩法】",
            content  = textIndent .. [[可碰，可杠，不可吃，默认自摸，点炮必须无鬼。]]
        },
        {
            redTitle = "\n【特殊玩法】",
            content  = textIndent .. "1、分为1-10的固定底。"
        },
        {
            content  = textIndent .. "2、分为1分2分-10分-20分的底。"
        },
        {
            content  = textIndent .. "3、根据不同的底分，结算。"
        },
        {
            content  = textIndent .. "4、暗杠亮三张。"
        },
        {
            content  = textIndent .. "5、杠上杠并杠爆，点杠的人要包牌。"
        },
        {
            content  = textIndent .. "6、杠136.120.112白板或者红中是鬼，108张是抓完牌以后正数第一张牌加1是鬼。"
        },
        {
            redTitle = "\n【胡牌规则】",
            content  = textIndent .. [[推倒胡，不可胡七小对、十三烂、十三幺。]]
        },
    }
}

return xinpumj
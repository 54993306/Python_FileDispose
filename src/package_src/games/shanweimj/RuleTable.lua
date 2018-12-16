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
        content  = textIndent .. "144张牌，1-9万，1-9筒，1-9索，东南西北中发白，春夏秋冬、梅兰竹菊。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "首局房主庄；胡牌者庄；若一炮多响则点炮者庄；若抢杠胡则被抢者庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "全部抓完。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "可碰不可吃，可杠，可自摸，点炮，抢杠胡"
    },
   
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "清一色，带花，碰字有番（东南西北，中发白）"
    },
    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "推倒胡，抢杠胡"
    }
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
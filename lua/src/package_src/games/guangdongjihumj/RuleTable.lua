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

local ruleContent =
{
    {
        redTitle = "\n【麻将用具】",
        content  = textIndent .. "由条、饼、万、东南西北中发白组成，合计136张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "谁胡谁坐庄；多家抢杠胡被抢杠的人坐庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "抓完所有的牌。杠了就有，黄庄不黄杠，杠在游戏中即时计算；黄庄不下庄算连庄；多家抢杠胡被抢杠的人坐庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "自摸：三家输给赢家；"
    },
    {
        content  = textIndent .. "点炮：不可以点炮；"
    },
    {
        content  = textIndent .. "明杠：就是你手里有三张一样的牌，别人打出另外一张，你杠了；"
    },
    {
        content  = textIndent .. "暗杠：自己抓到四张相同的牌杠下来，称为暗杠；暗杠要亮出；"
    },
    {
        content  = textIndent .. "补杠：你自己已经碰了的牌，自己在抓到最后一张杠了，称为补杠；"
    },
    {
        content  = textIndent .. "最后一张：最后一张牌要去抓并出手，最后一张胡牌并中马算全马；"
    },
    {
        content  = textIndent .. "直杠不杠先碰可以再杠；"
    },
    {
        content  = textIndent .. "杠开：杠开正常结算。点杠杠开也正常结算，点杠给杠分即可；"
    },
    {
        content  = textIndent .. "抢杠胡：抢杠胡包三家，多家抢杠胡，被抢杠者分别包三家，（杠分不用包），多家抢杠胡，被抢杠者坐庄。多家抢杠胡，翻马，马共用，胡家分别看自己的马；"
    },
    {
        content  = textIndent .. "不可一炮多响；"
    },
    {
        content  = textIndent .. "不需要报听；"
    },
    {
        content  = textIndent .. "无过圈碰胡；"
    },
    {
        content  = textIndent .. "无杠后炮说法；"
    },
    {
        content  = textIndent .. "7小对、十三幺、十三烂不可胡；"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "节节高：第一把是庄，然后胡牌（正常抓马），第二把继续坐庄，如果胡牌则多翻2个马，第三把继续坐庄如果胡牌则多翻4个马，第四把继续坐庄再胡，则多翻6个马，以此类推（连一庄多翻2个马）；"
    },
    {
        content  = textIndent .. "跟庄:开局庄家打出一张牌，其他三位闲家依次打出这张牌（鬼牌也算），算作跟庄，庄家，庄家输给其他三位闲家每人一分（任意一圈跟庄打都算跟庄，庄都给分），第一跟庄给1分，连续跟庄给的分数*2。"
    },
    {
        redTitle = "\n【胡牌规则】",
        content  = textIndent .. "胡牌结算：胡牌2分，马2分；"
    },
    {
        content  = textIndent .. "明杠谁点谁付3分，补杠三家各付1分；"
    },
    {
        content  = textIndent .. "自摸不加番不加底正常结算；"
    },
    {
        content  = textIndent .. "暗杠三家各付2分；"
    },
    {
        content  = textIndent .. "在翻鬼模式下，胡牌为无鬼牌+2分；"
    },
    {
        content  = textIndent .. "杠开算自摸，无杠后炮；"
    },
    {
        content  = textIndent .. "抢杠胡包三家，抢杠的杠不算分。如果被一家抢杠，那被抢杠者就要给3份相同的分给赢家，如果被多家抢杠，被抢杠者要给所有抢杠者的分。但是之前的杠分该怎么给就怎么给，不用被抢杠者付。"
    },
}



local ruleTable =
{
    smallTitle = commonSmallTitle,
	ruleContent = ruleContent
}

return ruleTable
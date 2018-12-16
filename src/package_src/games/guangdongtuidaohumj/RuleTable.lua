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
        content  = textIndent .. "谁胡谁坐庄；多家抢杠胡被抢杠的人坐庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "抓完所有的牌。杠了就有，黄庄不黄杠，杠在游戏中即时计算；黄庄不下庄算连庄；多家抢杠胡被抢杠的人坐庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "1、自摸：三家输给赢家；点炮：不可以点炮；"
    },
    {
        content  = textIndent .. "2、明杠：就是你手里有三张一样的牌，别人打出另外一张，你杠了。明杠谁点谁给3分；"
    },
    {
        content  = textIndent .. "3、暗杠：自己抓到四张相同的牌杠下来，称为暗杠；暗杠要亮出。暗杠每家给2分；"
    },
     {
        content  = textIndent .. "4、补杠：你自己已经碰了的牌，自己在抓到最后一张杠了，称为补杠。补杠每家给1分；"
    },
     {
        content  = textIndent .. "5、最后一张：最后一张牌要去抓并出手；"
    },
     {
        content  = textIndent .. "6、杠开：杠开正常结算。点杠杠开也正常结算；点杠杠开需要包三家；抢杠胡包三家，多家抢杠胡，被抢杠者分别包三家，多家抢杠胡，翻马，马共用，胡家分别看自己的马。"
    },
     {
        content  = textIndent .. "7、不可一炮多响；不需要报听；无过圈碰胡；无杠后炮说法；"
    },
     {
        content  = textIndent .. "8、无天胡地胡说法，正常算；"
    },
        {
        content  = textIndent .. "9、七对为选项，勾选时可胡，正常算；勾选7对加番时7对加番；"
    },
        {
        content  = textIndent .. "10、十三幺、十三烂不可胡；"
    },
        {
        content  = textIndent .. "11、鬼牌：发牌后，随机翻牌+1为鬼牌，双鬼模式为翻牌+1、翻牌+2都是鬼牌，鬼牌为万能牌；"
    },
     


    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "1、爆炸马：翻一张，翻到几就是几马，字牌为5马；爆炸马加分和爆炸马翻倍分别有不同算法；"
    },
    {
       content  = textIndent .. "2、节节高：第一把是庄，然后胡牌，第二把继续坐庄，如果胡牌有额外加分；跟庄:开局庄家打出一张牌，其他三位闲家依次打出这张牌（鬼牌也算），算作跟庄，庄家输给其他三位闲家每人一分；"
    },
    
    

    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "1、胡牌结算：胡牌2分，马2分；明杠谁点谁付3分，补杠三家各付1分；"
    },
    {
        content  = textIndent .. "2、自摸不加番不加底正常结算；暗杠三家各付2分；"
    },
    {
        content  = textIndent .. "3、在翻鬼模式下，胡牌为无鬼牌*2；无鬼胡翻倍再*2；杠开算自摸，无杠后炮。抢杠胡包三家；马跟底分：即胡多大马多大；"
    },



}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
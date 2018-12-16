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
        content  = textIndent .. "使用筒（1至9）、条（1至9）、东南西北中发白（各四张）共100张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "谁胡牌谁坐庄，黄庄后不换庄。多家抢杠时，被抢杠者坐庄，玩家进入房间时，随机分配座位，第一把牌由在“东风”的玩家当庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "抓完所有的牌；最后一张不出手；但如果抓马情况下，最后几马，最后的几张要保留显示，最后胡牌的人会计算“马”；如“四马”；最后四张要记录，如最后一张人自摸了。之前的3张算这个人抓的马。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "黄庄：抓完所有的牌；最后一张不出手；但如果抓马情况下，最后几马，最后的几张要保留显示，最后胡牌的人会计算“马”；如“四马”；最后四张要记录，如最后一张人自摸了。之前的3张算这个人抓的马。"
    },
    {
        content  = textIndent .. "庄家：第一次是东风坐庄，黄庄不黄杠，抓完黄庄，黄庄庄家不下庄，谁胡谁做庄；"
    },
    {
        content  = textIndent .. "自摸：三家输给赢家；每家2底。"
    },
    {
        content  = textIndent .. "胡牌：只能自摸胡，不能点炮；"
    },
    {
        content  = textIndent .. "明杠：自己手中有三张一样的牌，其他玩家打出一张牌和手中的牌可以形成“杠”，称为“明杠”。明杠谁点谁付3底；杠了直接就结算；"
    },
    {
        content  = textIndent .. "暗杠：自己抓到四张相同的牌杠下来，称为“暗杠”；暗杠要亮出。暗杠三家各付2底；杠了直接就结算；"
    },
    {
        content  = textIndent .. "补杠：别人打给你，你碰了，在自己摸到了就叫补杠。补杠三家各付1底；杠了直接就结算；"
    },
    {
        content  = textIndent .. "过圈：无过圈胡和过圈碰，但是碰要过人，例如：要碰8万，第一张8万出来，没碰，只要不是紧接着有人打8万，在打第二张8万之前还有人打了一张别的牌，就能碰；"
    },
    {
        content  = textIndent .. "吃：可碰、可杠、不可吃；"
    },
    {
        content  = textIndent .. "碰后杠：不可以；"
    },
    {
        content  = textIndent .. "不可胡牌型：七小对、十三幺、大烂不可胡；"
    },
    {
        content  = textIndent .. "杠开：杠开三家付；"
    },
    {
        content  = textIndent .. "抢杠胡：抢杠胡包3家（而且抢杠胡翻马的牌数乘2，比如玩4马就翻8张牌。如果有多人抢杠胡，那么另外胡的人分别再各自去翻8张牌，如果一共不够16张牌，那么就翻出8张，公用，各人算各人的马。如果不够8张，就翻4张，公用，而且翻出的马每个马都当2个马算，）；"
    },
    {
        content  = textIndent .. "翻马：一般自摸以后顺拿后面的四张牌作为马，一个马算一个自摸（2分）中马以座位顺序来订，例如庄家就是1.5.9.東风.红中。"
    },
    
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "庄马：1.5.9东风.红中是马；"
    },
	{
        content  = textIndent .. "下家马：2.6.南风.发财是马；"
    },
    {
        content  = textIndent .. "对家马：3.7.西风.白板是马；"
    },
    {
        content  = textIndent .. "上家马：4.8.北风是马。"
    },
    {
        redTitle = "\n【胡牌规则】",
        content  = textIndent .. "明杠谁点谁付3底，补杠三家各付1底，暗杠三家各付2底。"
    },
    {
        content  = textIndent .. "自摸2底。"
    },
    {
        content  = textIndent .. "马2底，有几个算几个。"
    },
}



local ruleTable =
{
    smallTitle = commonSmallTitle,
	ruleContent = ruleContent
}

return ruleTable
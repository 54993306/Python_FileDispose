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
        content  = textIndent .. "使用筒（1至9）、条（1至9）、万（1和9）、东南西北中发白（各四张）共108张牌。"
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
        content  = textIndent .. "吃：韶关麻将不能吃牌；"
    },
    {
        content  = textIndent .. "碰：玩家有两张相同的牌，其他玩家打出一张与此相同的牌时，系统提示为“碰”； 碰完牌不能直接开杠；"
    },
    {
        content  = textIndent .. "马：庄家的马是1，5，9，东风，红中；庄家下家的马是2，6，南风，发；庄家对家的马是3，7，西风，白；"
    },
    {
        content  = textIndent .. "杠：韶关麻将可以直杠和补杠，以及暗杠；"
    },
    {
        content  = textIndent .. "霸王庄：谁赢谁坐庄，首局按照东南西北的位置，东位先做庄；"
    },
    {
        content  = textIndent .. "墩：两张麻将为一墩，码牌阶段闲门前均码13墩牌，庄家码15墩牌；"
    },
    {
        content  = textIndent .. "和牌：只可自摸和牌。自摸输三家，庄家胡牌的情况下下局不会更换庄家；"
    },
    {
        content  = textIndent .. "荒庄：抓完打完荒庄。也就是摸到最后一张牌以后必须打出后无玩家胡牌才算荒庄；"
    },
    {
        content  = textIndent .. "荒庄又称黄庄，黄庄后下局不换庄；"
    },
    {
        content  = textIndent .. "明杠：韶关明杠包含直杠和补杠；"
    },
    {
        content  = textIndent .. "暗杠：自己摸到4张一样的牌，并选择开杠，即为暗杠；"
    },
    {
        content  = textIndent .. "杠开：杠后抓上来的牌自摸，点杠包三家；"
    },
    {
        content  = textIndent .. "抢杠胡：抢杠胡包3家；"
    },
    {
        content  = textIndent .. "自摸：自己摸牌和牌。韶关麻将自摸2底，三人给；"
    },
    {
        content  = textIndent .. "多家抢杠胡：被抢杠者包三家，有两个人胡牌，那被抢杠的人也要给这两个人分别付三家积分，3家都胡，那就给每人三家积分。杠积分已经游戏中正常结算，不计算在内；"
    },
    {
        content  = textIndent .. "报听：韶关麻将不能报听。"
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
        content  = textIndent .. "上家马：4.8.北风是马；"
    },
    {
        content  = textIndent .. "12张落地：手里只剩四张牌，其他牌都已碰牌时，其他人再点碰，就成12张落地，单吊碰碰胡，若此时和牌，则点最后一碰的人包三家。若有一个暗杠则此规则作废。"
    },
    {
        redTitle = "\n【胡牌规则】",
        content  = textIndent .. "和牌条件：推倒胡，胡牌2底；"
    },
    {
        content  = textIndent .. "杠立即结算，黄庄不黄杠；"
    },
    {
        content  = textIndent .. "碰碰胡：由四副刻子加一对将组成，和牌结算时翻两倍；"
    },
    {
        content  = textIndent .. "混一色：条筒万搭配东南西北中发白组成，和牌时翻两倍；"
    },
    {
        content  = textIndent .. "清一色：只有条筒万里的一种牌，胡牌结算时翻4倍；"
    },
    {
        content  = textIndent .. "全幺九碰碰胡：就是全部是1和9 组成的碰碰胡，胡牌结算时翻8倍，111.999.111.999.111.99；"
    },
    {
        content  = textIndent .. "清一色碰碰胡：就是碰碰胡都是一种花色，胡牌结算时翻8倍；"
    },
    {
        content  = textIndent .. "全字：就是碰碰胡都是字牌，胡牌结算时翻8倍；"
    },
    {
        content  = textIndent .. "十三幺：东南西北中发白各一张，1万配9万，1条配九条，一筒配九筒，最后随便摸到手里任意一张牌就算自摸。胡牌结算时翻16倍。"
    },
}



local ruleTable =
{
    smallTitle = commonSmallTitle,
	ruleContent = ruleContent
}

return ruleTable
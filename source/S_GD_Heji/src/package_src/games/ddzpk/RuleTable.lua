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
local commonSmallTitle = textIndent .. "您需要邀请好友，创建房间，好友按照房间号加入房间，就可以在一起斗地主了！就等于手机上有了棋牌室！建个好友地主群，组局更迅速！"

local Content =
{
    {
        redTitle = "\n【游戏规则】",
        content  = textIndent .. "1.发牌\n"
    },
    {
        content  = textIndent .. "每个人发17张牌，留三张底牌。确定地主后，底牌归地主，所有玩家可以看到底牌。\n"
    },
    {
        content  = textIndent .. "2.叫地主及抢地主\n"
    },
    {
        content  = textIndent .. "二人斗地主发牌前，牌库中有一张明牌显示出来，拿到明牌玩家首叫地主，双方均不叫则重新洗牌发牌。\n"
    },
    
    {
        content  = textIndent .. "在玩家叫地主后，玩家可以选择是否抢地主，最多可来回抢4次。"
    },
    {
        content  = textIndent .. "不同的抢地主次数对应不同倍数，抢0/1/2/3/4次分别对应2/3/4/5/6倍。\n"
    },
    {
        content  = textIndent .. "三人斗地主为系统随机抽取一个玩家来叫地主，此名玩家可以选择是否叫地主；如果三位玩家都不叫，则重新发牌。\n"
    },
    {
        content  = textIndent .. "3.出牌\n"
    },
    {
        content  = textIndent .. "地主有首先出牌权，按逆时针出牌。玩家可以选择用更大的牌或不跟牌。玩家打出牌后无人出牌，该玩家继续出牌。\n"
    },
    {
        content  = textIndent .. "4.牌型大小对比\n"
    },
        {
        content  = textIndent .. "火箭＞炸弹＞一般牌型。一般牌型之间的比较只有牌型和张数相同，才可以按照点数比较大小。\n"
    },
        {
        content  = textIndent .. "三带一、飞机带翅膀、四带二这些牌型是看其中牌型中最大的点数（带的牌不看），进行比较。\n"
    },

    {
        content  = textIndent .. "所有顺子都是比较其中点数最大的牌。\n"
    },
    {
        content  = textIndent .. "单牌点数大小:\n"
    },
    {
        content  ="大王>小王>2>A>K>Q>J>10>9>8>7>6>5>4>3\n"
    },

    --     {
    --     content  = textIndent .. "所有顺子都是比较其中点数最大的牌。\n"
    -- },
    --     {
    --     content  =  textIndent .. "单牌点数大小：\n"
    -- },
    -- {
    --     content  =  textIndent .. "大王>小王>10>9>8>7>6>5>4>3。\n"
    -- },
    {
        content  = textIndent .. "5.春天\n"
    },
    {
        content  =  textIndent .. "地主获胜且农民未出一张牌称为“春天”。农民获胜且地主只出过一手牌也称为“春天”。"
    },
    -- {
    --     content  =  textIndent .. "农民获胜且地主只出过一手牌也称为“春天”。"
    -- },
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
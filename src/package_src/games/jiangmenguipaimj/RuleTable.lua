-------------------------------------------------------------
--  @file   RuleTable.lua
--  @brief  规则内容
--  @author Linxiancheng
--  @DateTime:2017-04-20 16:30:22
--  Version: 1.0.0
--  Company  SteveSoft LLC.colourSliderValueChanged(sender, controlEvent)
--  Copyright  Copyright (c) 2016
-- ============================================================

local textIndent = "　　" -- 首行缩进
local commonSmallTitle = textIndent .. "您需要邀请好友，创建房间，好友按照房间号加入房间，就可以在一起打麻将了！就等于手机上有了棋牌室！建个好友麻将群，组局更迅速！"

local Content =
{
    {
        redTitle = "\n【麻将用具】",
        content = textIndent .. "由条、饼、万、东南西北中发白组成，合计136张牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content = textIndent .. "谁胡牌谁坐庄，黄庄后不换庄。抢杠时，被抢杠者坐庄，玩家进入房间时，随机分配座位，第一把牌由在“东风”的玩家当庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content = textIndent .. "抓完所有的牌。杠了就有，黄庄黄杠；杠在结算时结算，黄庄不下庄。"
    },
    {
        redTitle = "\n【基本玩法】",
        content = textIndent .. "1、庄家：谁胡牌谁坐庄，黄庄后不换庄。抢杠时，被抢杠者坐庄，玩家进入房间时，随机分配座位，第一把牌由在“东风”的玩家当庄。"
    },
    {
        content = textIndent .. "2、墩：两张麻将为一墩，码牌阶段每位玩家门前均码17墩牌；"
    },
    {
        content = textIndent .. "3、碰：玩家有两张相同的牌，其他玩家打出一张与此相同的牌时，系统提示为“碰”；"
    },
    {
        content = textIndent .. "4、杠：四张相同的牌；杠算花，随胡走，暗杠亮出；"
    },
    {
        content = textIndent .. "5、不能吃；"
    },
    {
        content = textIndent .. "6、黄庄：抓完所有的牌。杠了就有，黄庄黄杠；杠在结算时结算，黄庄不下庄；"
    },
    {
        content = textIndent .. "7、自摸：三家输给赢家。"
    },
    {
        content = textIndent .. "8、明杠：就是你手里有三张一样的牌，别人打出另外一张，你杠了。（手中有3张不杠先碰就不能再补杠了）"
    },
    {
        content = textIndent .. "9、暗杠：自己抓到四张相同的牌杠下来，称为暗杠；暗杠要亮出。"
    },
    {
        content = textIndent .. "10、补杠：你自己已经碰了的牌，自己在抓到最后一张杠了，称为补杠。"
    },
    {
        content = textIndent .. "11、出手：最后一张牌要去抓，但是不出手。"
    },
    {
        content = textIndent .. "12、鬼牌：鬼牌就是赖子，牌墩倒数第3个翻牌+1为赖子；人手4个鬼牌直接胡牌。"
    },
    {
        content = textIndent .. "13、翻子：确定赖子的牌的那张叫翻子，翻子不能被抓走，不能加入抓马。"
    },
    {
        content = textIndent .. "14、无鬼胡：本牌局不需要赖子。"
    },
    {
        content = textIndent .. "15、有鬼胡：本牌局有赖子牌。"
    },
    {
        content = textIndent .. "16、十二张落地：玩家通过碰，杠（只限明杠）；形成单吊的情况，为十二张落地，十二张落地最后一个碰或者直杠的放碰或者放杠者在胡牌后包三家；最后一个是暗杠的不算十二张落地。"
    },
    {
        content = textIndent .. "17、杠开：直杠杠开包三家（放杠的人包）；如果是直杠再杠再杠开也是放杠的人包。暗杠杠开或者补杠杠开不需要包三家，正常结算。"
    },
    {
        redTitle = "\n【特殊玩法】",
        content = textIndent .. "1、庄马：1.5.9东风.红中是马"
    },
    {
        content = textIndent .. "2、下家马：2.6.南风.发财是马"
    },
    {
        content = textIndent .. "3、对家马：3.7.西风.白板是马"
    },
    {
        content = textIndent .. "4、上家马：4.8.北风是马"
    },
    {
        content = textIndent .. "5、直杠不杠先碰，之后不能再杠，系统只会提醒一次。"
    },
    {
        content = textIndent .. "6、杠开（杠爆）：谁点杠谁付3三家积分，如果是自己抓的杠，杠开3家付（付自己的），正常翻马。"
    },
    {
        content = textIndent .. "7、尾3的上面一张牌翻开加1就是赖子牌，不可以被抓走，也不算马，可以打出无后果，赖子牌的其他三张牌不算杠，赖子牌全被一人抓去，可以直接胡。"
    },
    {
        content = textIndent .. "8、翻马的牌不足4张时，有几张算几张。"
    },
    {
        content = textIndent .. "9、最后一张牌，不胡就黄庄黄杠，有杠也不算，只提示一次。"
    },
    {
        content = textIndent .. "10、多家抢杠胡，大家都看被抢杠的人的马，例如，被抢者的马是2 6 南 发 ，那所有胡牌者都看2 6 南 发。"
    },
    {
        redTitle = "\n【胡牌类型】",
        content = textIndent .. "1、胡牌结算：自摸胡2底，马1底"
    },
    {
        content = textIndent .. "2、明杠谁点谁付3底，补杠三家各付1底。"
    },
    {
        content = textIndent .. "3、自摸不加番不加底。"
    },
    {
        content = textIndent .. "4、暗杠三家各付2底。"
    },
    {
        content = textIndent .. "5、杠了的分数胡牌时结算，若黄庄则黄杠。"
    },
    {
        content = textIndent .. "6、杠开谁点杠谁包三家，如果自己暗杠或者补杠并杠开则3家各自付，正常翻马。（杠积分在包的范围中）"
    },
    {
        content = textIndent .. "7、12张落地包三家。（也就是说手里只剩一张牌单吊的情况下算12张落地，但是最后一个是暗杠不算12张落地。）"
    },
    {
        content = textIndent .. "8、抢杠胡包三家，抢杠的杠不算分。如果被一家抢杠，那被抢杠者就要给3份相同的积分给赢家，如果被两家，三家抢杠，那么按照打牌的顺序提示胡牌，被抢杠者要给三家相同的分。但是之前的杠积分该怎么给就怎么给，不用被抢杠者付。"
    },
    {
        content = textIndent .. "9、胡牌翻马，正常翻，不够时有几张算几张。"
    },
}

local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
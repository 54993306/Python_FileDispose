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
        content  = textIndent .. "136张牌，万条筒+字牌。"
    },
    {
        redTitle = "\n【庄家规则】",
        content  = textIndent .. "霸王庄，胡牌者下轮坐庄。"
    },
    {
        content  = textIndent .. "多家抢杠胡后，被抢杠者下轮坐庄。"
    },
    {
        redTitle = "\n【黄庄规则】",
        content  = textIndent .. "未勾选马跟杠玩法后玩几马留几马，黄庄不黄杠。"
    },
    {
        content  = textIndent .. "勾选马跟杠后玩几马留几马，黄庄黄杠。"
    },
    {
        redTitle = "\n【基本玩法】",
        content  = textIndent .. "能碰、能杠、不能吃，不可点炮。"
    },
    {
        content  = textIndent .. "最后一张牌可以打出手。"
    },
    {
        redTitle = "\n【特殊玩法】",
        content  = textIndent .. "固定鬼牌玩法：白板为鬼牌。"
    },
    {
        content  = textIndent .. "翻鬼玩法：翻开牌的下一张为鬼牌。"
    },
    {
        content  = textIndent .. "位置马牌为："
    },
    {
        content  = textIndent .. "庄家：1、5、9、东风、红中是马。"
    },
    {
        content  = textIndent .. "下家：2、6、南风、发财是马。"
    },
    {
        content  = textIndent .. "对家：3、7、西风、白板是马。"
    },
     {
        content  = textIndent .. "上家：4、8、北风是马。"
    },
    {
        redTitle = "\n【胡牌类型】",
        content  = textIndent .. "推倒胡。"
    },
    {
        content  = textIndent .. "不能胡牌牌型：十三烂。"
    },
}
local ruleTable =
{
    smallTitle = commonSmallTitle,
    ruleContent = Content
}

return ruleTable
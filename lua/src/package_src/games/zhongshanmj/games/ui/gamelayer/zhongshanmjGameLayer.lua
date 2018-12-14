
local GameUIView        = require "app.games.common.ui.bglayer.GameUIView"
local PlayerFlower      = require "app.games.common.ui.gamelayer.PlayerFlower"
-- 加入回放层
local VideoControlLayer = require "app.games.common.ui.video.VideoControlLayer"
local AnimLayer      = require "app.games.common.ui.bglayer.AnimLayer"
-- local GamePlayLayer     = require "package_src.games.zhongshanmj.games.ui.playlayer.BranchGamePlayerLayer"
local OperateBtnLayer   = require "app.games.common.ui.operatelayer.OperateBtnLayer"

local GameLayer     = require("app.games.common.ui.gamelayer.GameLayer")
local zhongshanmjGameLayer = class("zhongshanmjGameLayer", GameLayer)

-- 结算配置
local kGameOverConfig = {
    overLayerColor = cc.c4b(0, 0, 0, 100), -- 暗层配置
    needFanma = 1, -- 是否需要显示翻马
    localZOrderFanma = 50, -- 层级
    timeFanma = 3, -- 显示翻马层的时间
}

-- 替换跳转结算界面逻辑(以翻马为例)
-- data: getGameOverDatas() 结算数据
function zhongshanmjGameLayer:customOverView(gameOverData)
    -- Log.i("是否要显示翻马UI(0: 不用显示, 1: 要显示)", gameOverData.isND)
    if gameOverData.isND ~= kGameOverConfig.needFanma or gameOverData.winType == enGameOverType.BUREAU then --是否显示翻马UI(0: 不用显示, 1: 要显示)
        return false
    else
        local MJFanMa= require("app.games.common.ui.gameover.MJFanMa")
        local famaLayer= MJFanMa.new(self:getFanmaData(gameOverData), self:getFanmaConfig(gameOverData))

        self:addChild(famaLayer, kGameOverConfig.localZOrderFanma)
        self:performWithDelay(function ()
            famaLayer:removeFromParent()
            self:defaultOverView()
        end, kGameOverConfig.timeFanma)
        return true
    end
end

--[[
type = 2,code=22021, 游戏中分数发生改变  client  <--  server
PlayerInfo      
##    usI  long  玩家id
##    sc  long  更改后的分数
##    chS  long  更改分数的值
##  pl:[PlayerInfo]  pl  List<PlayerInfo>   玩家列表
]]
--杠积分结算
function zhongshanmjGameLayer:handleGangJieSuan(info)
    --[[ local pl={}
    pl[1]={usI=1102464,sc=998,chS=-2}
    pl[2]={usI=1102465,sc=998,chS=-2}
    pl[3]={usI=1102462,sc=998,chS=6}
    pl[4]={usI=1102463,sc=998,chS=-2}]]

    for i=1,#info.pl do
        local netPlayerInfo = info.pl[i]
        Log.i("杠积分结算",netPlayerInfo)

        -- 获取对应的玩家
        local playerInfo = self.gameSystem:gameStartGetPlayerByUserid(netPlayerInfo.usI);

        local tmpSite = playerInfo:getProp(enCreatureEntityProp.SITE) --玩家方位
        Log.i("当前玩家位置" .. tmpSite)
        --更改后的分数
        playerInfo:setProp(enCreatureEntityProp.FORTUNE, netPlayerInfo.sc or 0)
        self.m_playerHeadNode:refreshFortune(tmpSite)

        -- 显示分数动画
        local tmpMoney = netPlayerInfo.chS

        local moneyLable = nil
        if(tmpMoney>0) then --玩家增加了积分
            local tx = "+" .. tmpMoney
            local jifen = {
                text = tx,
                font = "games/hongzhongmj/game/add_num.fnt",
            }
            moneyLable = display.newBMFontLabel(jifen);

        elseif(tmpMoney<0) then --玩家减了积分
            local tx = "" .. tmpMoney
            local jifen = {
                text = tx,
                font = "games/hongzhongmj/game/sub_num.fnt",
            }
            moneyLable = display.newBMFontLabel(jifen);
        end

        if(moneyLable~=nil) then
            moneyLable:setScale(2)
            moneyLable:addTo(self, self._uiLayerZOrder)

            if(tmpSite == Define.site_self) then
                moneyLable:setPosition(cc.p(display.cx-150,250));

            elseif(tmpSite == Define.site_right) then
                moneyLable:setPosition(cc.p(display.cx+150, display.cy));

            elseif(tmpSite == Define.site_other) then
                moneyLable:setPosition(cc.p(display.cx-150, display.height-150));

            elseif(tmpSite == Define.site_left) then
                moneyLable:setPosition(cc.p(display.cx-450, display.cy));
            end

            moneyLable:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveBy:create(1,cc.p(200,0)),3),cc.RemoveSelf:create()))

        end

    end  
end

return zhongshanmjGameLayer
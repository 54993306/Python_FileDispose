local Define            = require("app.games.common.Define")

local GameLayer = import("app.games.common.ui.gamelayer.GameLayer")

local hongzhongmjGameLayer = class("hongzhongmjGameLayer", GameLayer)

--[[
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function hongzhongmjGameLayer:onGameOver()
    Log.i("处理结算逻辑")
    local data = self.gameSystem:getGameOverDatas()
    assert(data ~= nil)
    --停止背景音乐
    audio.stopMusic()
    local clock = self._bgLayer._clock
    if clock then
        clock:stoptUpdate()
    end
    self._opOverTimeTip:stopOverTimeTip()
    
    local showResult = false
    if data.winType == 3 then --流局了
        showResult = true
        SoundManager.playEffect("liuju", false);
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
        local armature = ccs.Armature:create("CpghAnimation")
        armature:getAnimation():play("AnimationLIUJV")
        armature:performWithDelay(function()
                armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)

        ---------- 流局不显示流局界面录像回放相关-----------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            return      
        end
        ----------------------------------------------------
    end
    -- self._playLayer:setPlayerTouchEnabled(false)

    -- local actionList = self._playLayer:getChildByTag(Define.e_tag_player_layer_action)
    -- if actionList then
    --     actionList:removeFromParent()
    --     actionList = nil
    -- end

    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

    -- for i=1, #self.gameSystem:gameStartGetPlayers() do
    --     local lastCard = 0
    --     if i == winnerSite then
    --         lastCard = data.score[i].lastCard
    --     end
        
    --     self._playLayer:gameEndMingPai(i, data.score[i].closeCards, lastCard)
    -- end
    -- 
    -- 结算界面
    local delayTime = 1.5
    -- 游戏层
    self._playLayer:onGameOver(delayTime)
    --查胡提示
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    gamePlaySystem:gameStartLogic_setHuMjs();
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    -- 补花层
    self.m_flowerNode:onGameOver()
    
    Log.i("GameLayer:on_msgGameOver winnerSite="..winnerSite..';winType='..data.winType)
    
    local isPaoPei = false
    if winnerSite == 1 then
        showResult = true
        local pon = data.score[winnerSite].policyName
        if pon ~= nil and #pon> 0 then 
            for i=1, #pon do
                if pon[i] == "跑配" then
                    isPaoPei = true
                end
            end
        end
    end

    if data.huCount > 1 then --一炮多响
        showResult = true

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
        local armature = ccs.Armature:create("yipaoduoxiang")
        armature:getAnimation():play("Animation1")
        armature:performWithDelay(function()
                 armature:removeFromParent(true)
            end, 0.7);
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)
    end

    -- if isPaoPei == true and MjProxy:getInstance():getGameId() == Define.gameId_xuzhou then
    --     delayTime = 3
    --     self:performWithDelay(function ()
    --         local paoPeiAnimLayer = PaoPeiAnimLayer.new()
    --         cc.Director:getInstance():getRunningScene():addChild(paoPeiAnimLayer)
    --         paoPeiAnimLayer:performWithDelay(function ()
    --             paoPeiAnimLayer:removeFromParent()
    --         end, 2)
    --     end, 1)        

    -- end

    -- 结算界面
    self:showGameOverUI(data, delayTime)    
end

function hongzhongmjGameLayer:showGameOverUI(data, delayTime)
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    layer:addTo(self)

    self:performWithDelay(function ()
        -- 重设头像位置
        self.m_playerHeadNode:setHeadSrcPos()
        -- 移除指示
        self._playLayer:removeIndicator()
        layer:removeFromParent()
        Log.i("是否要显示翻马UI,0:不用显示,1:要显示"  .. data.isND )
        if( data.isND==1) then --是否显示翻马UI 0:不用显示, 1：要显示
            local tmpFanUI = UIManager:getInstance():pushWnd(MJFanMa, data);
            tmpFanUI.m_pWidget:performWithDelay(function ()
            
                UIManager:getInstance():popWnd(MJFanMa);
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);
            
            end, 3)
        else
            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);     
        end
        -- 隐藏操作
        self.operateLayer:onHide()
    end, delayTime)
end

-- --[[
-- type = 2,code=22021, 游戏中分数发生改变  client  <--  server
-- PlayerInfo      
-- ##    usI  long  玩家id
-- ##    sc  long  更改后的分数
-- ##    chS  long  更改分数的值
-- ##  pl:[PlayerInfo]  pl  List<PlayerInfo>   玩家列表
-- ]]
-- --杠积分结算
-- function hongzhongmjGameLayer:handleGangJieSuan(info)
--     --[[ local pl={}
--     pl[1]={usI=1102464,sc=998,chS=-2}
--     pl[2]={usI=1102465,sc=998,chS=-2}
--     pl[3]={usI=1102462,sc=998,chS=6}
--     pl[4]={usI=1102463,sc=998,chS=-2}]]

--     for i=1,#info.pl do
--         local netPlayerInfo = info.pl[i]
--         Log.i("杠积分结算",netPlayerInfo)

--         -- 获取对应的玩家
--         local playerInfo = self.gameSystem:gameStartGetPlayerByUserid(netPlayerInfo.usI);

--         local tmpSite = playerInfo:getProp(enCreatureEntityProp.SITE) --玩家方位
--         Log.i("当前玩家位置" .. tmpSite)
--         --更改后的分数
--         playerInfo:setProp(enCreatureEntityProp.FORTUNE, netPlayerInfo.sc or 0)
--         self.m_playerHeadNode:refreshFortune(tmpSite)

--         -- 显示分数动画
--         local tmpMoney = netPlayerInfo.chS

--         local moneyLable = nil
--         if(tmpMoney>0) then --玩家增加了积分
--             local tx = "+" .. tmpMoney
--             local jifen = {
--                 text = tx,
--                 font = "package_res/games/hongzhongmj/game/add_num.fnt",
--             }
--             moneyLable = display.newBMFontLabel(jifen);

--         elseif(tmpMoney<0) then --玩家减了积分
--             local tx = "" .. tmpMoney
--             local jifen = {
--                 text = tx,
--                 font = "package_res/games/hongzhongmj/game/sub_num.fnt",
--             }
--             moneyLable = display.newBMFontLabel(jifen);
--         end

--         if(moneyLable~=nil) then
--             moneyLable:setScale(2)
--             moneyLable:addTo(self, self._uiLayerZOrder)

--             if(tmpSite == Define.site_self) then
--                 moneyLable:setPosition(cc.p(display.cx-150,250));

--             elseif(tmpSite == Define.site_right) then
--                 moneyLable:setPosition(cc.p(display.cx+150, display.cy));

--             elseif(tmpSite == Define.site_other) then
--                 moneyLable:setPosition(cc.p(display.cx-150, display.height-150));

--             elseif(tmpSite == Define.site_left) then
--                 moneyLable:setPosition(cc.p(display.cx-450, display.cy));
--             end

--             moneyLable:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveBy:create(1,cc.p(200,0)),3),cc.RemoveSelf:create()))

--         end

--     end  
-- end

return hongzhongmjGameLayer
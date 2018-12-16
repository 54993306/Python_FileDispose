

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
--local GameUIView        = require ("package_src.games.guangdongtuidaohumj.games.ui.gameover.changepoint")
local FanMaAnimation = require "package_src.games.guangdongtuidaohumj.games.ui.fanma.FanMaAnimation"
--jmplayLayer = require("package_src.games.guangdongtuidaohumj.games.ui.playlayer.BranchGamePlayLayer") ---- 翻马actionId

local guangdongtuidaohumjGameLayer = class("guangdongtuidaohumjGameLayer", GameLayer)

function guangdongtuidaohumjGameLayer:ctor()
    self.super.ctor(self)
end



function guangdongtuidaohumjGameLayer:onAction()
    self.super.onAction(self)
    --获取操作系统中吃碰杠等牌局数据数据
    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    self:updatePlayScore(operateSysData)
end

function guangdongtuidaohumjGameLayer:updatePlayScore(operateData)
Log.i("guangdongtuidaohumjGameLayer:updatePlayScore.........................",operateData)
    if operateData.actionID == enOperate.OPERATE_AN_GANG 
        or operateData.actionID == enOperate.OPERATE_MING_GANG 
        or operateData.actionID == enOperate.OPERATE_JIA_GANG  
        or operateData.actionID ==90 then
        if not operateData.losIds then
            return
        end
        local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        for i,v in pairs(operateData.losIds) do
            local operateSite   = gamePlaySystem:getPlayerSiteById(v)
            local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(operateSite)
            local strMoney = playerObj:getProp(enCreatureEntityProp.FORTUNE)
            Log.i("v.....",v,operateSite,strMoney,operateData.score)
            playerObj:setProp(enCreatureEntityProp.FORTUNE,strMoney-operateData.score)
            self.m_playerHeadNode:refreshFortune(operateSite)
             self:drawScoreAction(operateSite,-operateData.score)
        end


        local actionSite   = gamePlaySystem:getPlayerSiteById(operateData.userid)
        local actionPlayerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(actionSite)
        local actionstrMoney = actionPlayerObj:getProp(enCreatureEntityProp.FORTUNE)
        Log.i("tuidaohuaction.....",operateData)
        local renshu = kFriendRoomInfo:getSelectRoomInfo()
        Log.i('tuidaohudatas',renshu)


        if operateData.score ==0 then
            if renshu.plS ==4 then 
            operateData.score =3
            end

            if renshu.plS ==3 then 
            operateData.score =2
            end
            if renshu.plS ==2 then 
            operateData.score =1
            end
        end

        local score = operateData.score
        if operateData.actionID == enOperate.OPERATE_MING_GANG or enOperate.OPERATE_JIA_GANG  then
          score = operateData.score*(#(operateData.losIds))
        end
        
        
        actionPlayerObj:setProp(enCreatureEntityProp.FORTUNE,actionstrMoney+score)
        self.m_playerHeadNode:refreshFortune(actionSite)
        self:drawScoreAction(actionSite,score)
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
     end




     
    -------------------------------及时结算
   if operateData.actionID == 61  then
        if not operateData.losIds then
            return
        end
        local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        --for i,v in pairs(operateData.userid) do
            local operateSite   = gamePlaySystem:getPlayerSiteById(operateData.userid)
            local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(operateSite)
            local strMoney = playerObj:getProp(enCreatureEntityProp.FORTUNE)
           -- Log.i("v.....",v,operateSite,strMoney,operateData.score)
            playerObj:setProp(enCreatureEntityProp.FORTUNE,strMoney-3)
            self.m_playerHeadNode:refreshFortune(operateSite)
             self:drawScoreAction(operateSite,-3)

        --end

        for z,c in pairs(operateData.losIds) do
            local actionSite   = gamePlaySystem:getPlayerSiteById(c)
            local actionPlayerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(actionSite)
            local actionstrMoney = actionPlayerObj:getProp(enCreatureEntityProp.FORTUNE)
            Log.i("actionChaozuo.....",operateData.userid,operateSite,strMoney,operateData.score)
            local score = operateData.score 
            actionPlayerObj:setProp(enCreatureEntityProp.FORTUNE,actionstrMoney+1)
            self.m_playerHeadNode:refreshFortune(actionSite)
            self:drawScoreAction(actionSite,1)
            MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF)
        end
    end


end
function guangdongtuidaohumjGameLayer:drawScoreAction(site,score)
    local point = nil
    if score < 0 then
        point = cc.Label:createWithBMFont("games/common/gameCommon/sub_num.fnt", score)
    else
        point = cc.Label:createWithBMFont("games/common/gameCommon/add_num.fnt", "+"..score)
    end
    local playerHead = self.m_playerHeadNode:getHead(site)
    point:setAnchorPoint(cc.p(0.5, 0.5))
    playerHead:addChild(point, 10)
    point:setScale(1.5)
    if site == enSiteDirection.SITE_MYSELF or site == enSiteDirection.SITE_LEFT then
        point:setPosition(cc.p(200,60))
    else
        point:setPosition(cc.p(-200,60))
    end
    local cf = cc.CallFunc:create(function()
        point:removeFromParent()
        point = nil
    end)
    local move = cc.EaseOut:create(cc.MoveTo:create(0.5,cc.p(80,50)),0.5)
    local sequence = cc.Sequence:create(move,cf)
    point:runAction(sequence)
end


function guangdongtuidaohumjGameLayer:onGameOver()
    package.loaded["app.games.common.ui.gameover.FriendOverView"] = nil
    package.loaded["package_src.games.guangdongtuidaohumj.games.ui.gameover.guangdongtuidaohumjFriendOverView"] = nil
    FriendOverView = require "package_src.games.guangdongtuidaohumj.games.ui.gameover.guangdongtuidaohumjFriendOverView"
    --self.super.onGameOver(self)
     local data = self.gameSystem:getGameOverDatas()
    Log.i("guangdongtuidaohumjGameLayer:onGameOver............................................",data)
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
    
    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 
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
    --local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    --layer:addTo(self)
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
        self:addChild(armature,50)
    end


    self:showGameOverUI(data, delayTime)    
end

function guangdongtuidaohumjGameLayer:showGameOverUI(data, delayTime)
    MJFanMa = require"package_src.games.guangdongtuidaohumj.games.ui.MJFanMa"
    --local MJFan = require"package_src.games.guangdongtuidaohumj.games.ui.MJFanMac"
     layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
    layer:addTo(self)

    self:performWithDelay(function ()
        -- 重设头像位置
        self.m_playerHeadNode:setHeadSrcPos()
        -- 移除指示
        self._playLayer:removeIndicator()
        layer:removeFromParent()
        --Log.i("是否要显示翻马UI,0:不用显示,1:要显示"  .. data.isND )

      --Log.i("guangdongtuidaohudatas",data)
      local mafa = {}
      if  data.ma.zhongMa then 
        local faI = data.faI
       
       for i= 1,#faI do 
            table.insert(mafa,faI[i])
       end

        Log.i("MAFAMAFA",mafa)
       for  i,p in pairs(mafa) do 
            mafa[i].isM = 0
            --if #data.ma.zhongMa>0 then
            for z,c in pairs(data.ma.zhongMa) do 
                if mafa[i].faI6 == c then 
                    mafa[i].isM = 1
                end
            end
            --end
       end 
       end
      
        Log.i("ASAS",data)

        if( #(data.faI)>0) and data.fanmaTypeInfo~=3 then ---1 2 4 翻马  3 不翻马

      --  if data.
      if data.wi ==11 then
            MJFanMac = require"package_src.games.guangdongtuidaohumj.games.ui.MJFanMac"
             local tmpFanUI = UIManager:getInstance():pushWnd(MJFanMac, mafa);
            tmpFanUI.m_pWidget:performWithDelay(function ()
            
                UIManager:getInstance():popWnd(MJFanMac);
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);
            
            end, 3)
            else
              
            local tmpFanUI = UIManager:getInstance():pushWnd(MJFanMa, data);
            tmpFanUI.m_pWidget:performWithDelay(function ()
            
                UIManager:getInstance():popWnd(MJFanMa);
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);
            
            end, 3)
            end

        else
            self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
            self.m_gameOverDialogUI:setDelegate(self);     
        end
        -- 隐藏操作
        self.operateLayer:onHide()
    end, delayTime)
end
return guangdongtuidaohumjGameLayer
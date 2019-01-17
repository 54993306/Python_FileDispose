--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
local OperateBtnLayer   = require "app.games.common.ui.operatelayer.OperateBtnLayer"
-- local OperateBtnLayer   = require "package_src.games.shanweimj.games.ui.operatelayer.shanweimjOperateBtnLayer"

local GamePlayLayer     = require "package_src.games.shanweimj.games.ui.playlayer.shanweimjGamePlayLayer"
local GameUIView        = require "app.games.common.ui.bglayer.GameUIView"
local PlayerContitech   = require "app.games.common.ui.gamelayer.PlayerFlower"
-- 加入回放层
local MJFanma = require "package_src.games.shanweimj.custom.MJFanma"
local Mj     = require "app.games.common.mahjong.Mj"

local GameLayer = require("app.games.common.ui.gamelayer.GameLayer")
local shanweimjGameLayer = class("shanweimjGameLayer", GameLayer)
--[[
-- @brief  构造函数
-- @param  isResume: 是否是恢复牌局
-- @return void
--]]
-- function shanweimjGameLayer:ctor()
--     -- print("shanweimjGameLayer===============================")
--     self.super.ctor(self)
-- end

--[[
-- @brief  游戏结束函数
-- @param  void
-- @return void
--]]
function shanweimjGameLayer:onGameOver()
    Log.i("处理结算逻辑")
    -- print("shanweimjGameLayer:onGameOver++++++++++++++",socket.gettime())
    local data = self.gameSystem:getGameOverDatas()
    assert(data ~= nil)
    --停止背景音乐
    audio.stopMusic()
    local clock = self._bgLayer._clock
    if clock then
        clock:stoptUpdate()
    end
    local fanmaTime = 2--定义翻马前的动画时间
    local showResult = false
    -- data.hasF = true
    if data.winType == 3 then --流局了
        local socket = require "socket"
        -- print("999999999999999999999999",socket.gettime())
        -- data.hasF = false
        showResult = true
        SoundManager.playEffect("liuju", false);
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/CpghAnimation.csb")
        local armature = ccs.Armature:create("CpghAnimation")
        armature:getAnimation():play("AnimationLIUJV")
        armature:performWithDelay(function()
                armature:removeFromParent(true)
            end, 0.7);
        -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_ACT_ANIMATE_FINISH_NTF, "AnimationLiuJu")
        armature:setPosition(cc.p(display.cx, display.cy))
        self:addChild(armature,5)

        ---------- 流局不显示流局界面录像回放相关-----------------------------
        if VideotapeManager.getInstance():isPlayingVideo() then
            return      
        end
        ----------------------------------------------------
        -- 结算界面
        local delayTime = 1.5
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
        layer:addTo(self)
        -- Log.i("GameLayer:on_msgGameOver winnerSite="..winnerSite..';winType='..data.winType)
        self:performWithDelay(function ()
            -- 重设头像位置
            --print("sunbinLog ****** setHeadSrcPos")
            self.m_playerHeadNode:setHeadSrcPos()
            -- 移除指示
            self._playLayer:removeIndicator()
            layer:removeFromParent()
                self.m_gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                self.m_gameOverDialogUI:setDelegate(self);   
                -- 隐藏操作
                self.operateLayer:onHide()
            --朋友开房逻辑特殊处理
            -- if(kFriendRoomInfo:isFriendRoom()) then
            -- else            
            -- end
        
        end, delayTime)
    else
        --结算界面
          self.m_widget = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/shanweimj/dfqp_3.csb")
          local btn_maima1 = ccui.Helper:seekWidgetByName(self.m_widget, "Image_24");     --自家
          local btn_maima2 = ccui.Helper:seekWidgetByName(self.m_widget, "Image_27");     --下家(右边)
          local btn_maima3 = ccui.Helper:seekWidgetByName(self.m_widget, "Image_26");     --对家
          local btn_maima4 = ccui.Helper:seekWidgetByName(self.m_widget, "Image_25");     --上家(左边)
         -- btn_maima1
          self:addChild(self.m_widget,1000)

          ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/shanweimj/Maima.csb")
         local armature = ccs.Armature:create("Maima")
          armature:getAnimation():play("MAIMA")

         ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/shanweimj/Maima.csb")
         local armature2 = ccs.Armature:create("Maima")
        armature2:getAnimation():play("MAIMA")

          ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/shanweimj/Maima.csb")
          local armature3 = ccs.Armature:create("Maima")
         armature3:getAnimation():play("MAIMA")

          ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/shanweimj/Maima.csb")
          local armature4 = ccs.Armature:create("Maima")
          armature4:getAnimation():play("MAIMA")
          
         self.gameSystem     = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
         self.m_data = self.gameSystem:getGameOverDatas()


       --显示买马动画的玩家座位
        local siteMap = {
            {},
            {1,3},
            {1,2,4},
            {1,2,3,4},
        }

        local maiMaNumber = table.nums(self.m_data.maima)--打牌人数
        local isShowMaiMa = false
        local index = 0
        for k,v in pairs(self.m_data.maima) do
            
           local index = 1

           local site = self.gameSystem:getPlayerSiteById(tonumber(k))
           -- print("*************************************************"..site.."***************id"..k)
           for i,ma in pairs(v) do
            isShowMaiMa = true
            local maSp = Mj.new(enMjType.MYSELF_NORMAL,ma.faI6)
            local mjSize = maSp:getContentSize()
            local posX = mjSize.width*(index-1)
            local siteIndex = siteMap[maiMaNumber][site]
            if (siteIndex == 1) then
                maSp:setPosition(posX,70)
                btn_maima1:addChild(maSp,120);
            elseif (siteIndex == 2) then
                maSp:setPosition(posX,70)
                -- btn_maima4:addChild(maSp,120);
                btn_maima2:addChild(maSp,120);
            elseif (siteIndex == 3) then
                maSp:setPosition(posX,70)
                btn_maima3:addChild(maSp,120);
            elseif (siteIndex == 4) then
                maSp:setPosition(posX,70)
                -- btn_maima2:addChild(maSp,120);
                btn_maima4:addChild(maSp,120);
            end
            
            index = index+1
           end
        end

        --有买马才显示买马动画
        if isShowMaiMa then
            if maiMaNumber == 2 then
                btn_maima1:addChild(armature,110);
                btn_maima3:addChild(armature3,110);
            elseif maiMaNumber == 3 then
                btn_maima1:addChild(armature,110);
                btn_maima2:addChild(armature2,110);
                btn_maima4:addChild(armature4,110);
            elseif maiMaNumber == 4 then
                btn_maima1:addChild(armature,110);
                btn_maima2:addChild(armature2,110);
                btn_maima3:addChild(armature3,110);
                btn_maima4:addChild(armature4,110);
            end
        end

        -- print("shanweimjGameLayer:onGameOver=============",socket.gettime())
        self.colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), cc.Director:getInstance():getVisibleSize().width, cc.Director:getInstance():getVisibleSize().height)
        self.colorLayer:addTo(self)

        
        if data.huCount > 1 then --一炮多响
            fanmaTime = 1--一炮多响的时候肯定没有买马和奖马，所以只保留一秒的一炮多响动画时间
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("games/common/mj/armature/yipaoduoxiang.csb")
            local armature = ccs.Armature:create("yipaoduoxiang")
            armature:getAnimation():play("Animation1")
            armature:performWithDelay(function()
                     armature:removeFromParent(true)
                end, 0.7);
            armature:setPosition(cc.p(display.cx, display.cy))
            self.colorLayer:addChild(armature,2000)
        end

        --翻马前的延迟后判断是否有翻马并显示
        self:performWithDelay(function ()
            -- self:performWithDelay(function ()
                self.colorLayer:removeFromParent()
                self.m_widget:setVisible(false)
                self.m_widget:removeFromParent()
                -- if data.isND == 1 then --是否显示翻马UI false:不用显示, true：要显示
                    self:showGameOverUI(data, 0.1)
                -- else
                --     self.m_playerHeadNode:setHeadSrcPos()
                --     local gameOverDialogUI = UIManager.getInstance():pushWnd(FriendOverView);
                --     gameOverDialogUI:setDelegate(self);     
                -- end
            -- end,0.25)        
        end,fanmaTime+0.25)          
       
    end

    -- --结算时把手牌全制为不能打出状态
    -- local myCards    = self._playLayer.playerPannel[enSiteDirection.SITE_MYSELF]:getHandCardsList()
    -- for i=1,#myCards do
    --     myCards[i]:setMjState(enMjState.MJ_STATE_TOUCH_INVALID)
    -- end

    -- -- 亮出其他玩家的牌
    local winnerSite = self.gameSystem:getPlayerSiteById(data.winnerId) 

    --查胡提示
    local gamePlaySystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    gamePlaySystem:gameStartLogic_setHuMjs();
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
    end
    -- 游戏层
    self._playLayer:onGameOver(fanmaTime+0.25)
    -- 补花层
    self.m_flowerNode:onGameOver()
    self._opOverTimeTip._operatorOverTimeTip:endUpdate()
end

--[[
-- @brief  拿牌函数
-- @param  void
-- @return void
--]]
function shanweimjGameLayer:onDispenseCard(packageInfo)
    Log.i("------shanweimjGameLayer:onDispenseCard")
    local info = packageInfo
    local clock = self._bgLayer._clock
    SoundManager.playEffect("fapai", false);
    self._playLayer:onDispenseCard()
    self._bgLayer:onDispenseCard()
    self._opOverTimeTip:onDispenseCard()

    --摸牌数据
    local dispenseData    = self.gameSystem:getDispenseCardDatas()
    local site  = self.gameSystem:getPlayerSiteById(dispenseData.userId)

    if dispenseData.needBM then
        self.m_flowerNode:setBuhuaNumber(site,dispenseData.card)
    end

    --查胡状态
    if self.m_gameUIView then
        self.m_gameUIView:checkChahuStatus();
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_CANCEL_SELECTED_CHAHU_NTF)
    end

    -- -- 拿牌结束
    -- MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjNtfEvent.GAME_DISPENSE_FINISH_NTF)
end


return shanweimjGameLayer

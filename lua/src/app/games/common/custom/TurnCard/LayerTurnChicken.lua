--
-- Author: RuiHao Lin
-- Date: 2017-07-03 16:23:10
-- @brief   LayerTurnCard 单人翻牌层
--

local CardPanel = require("app.games.common.custom.TurnCard.CardPanel")

--  标题图片路径
local lTitleFilePath = "games/common/game/catch_chicken/title_turn_chicken.png"
local lCSBFilePath = "games/common/game/catch_chicken/animation/guizhouAnimation.csb"

local LayerTurnCard = class("LayerTurnCard", function ()
    local ret = cc.LayerColor:create()
    ret:setContentSize(cc.size(display.width, display.height))
    ret:setColor(cc.c3b(256, 256, 256))
    ret:setOpacity(128)
	return ret
end)

--[[
    @brief  构造函数
    @data   数据结构
    {
        {CardID = 31, Lottery = 0}, --  CardID：卡牌ID， Lottery：1 --高亮；0 --灰暗
        {CardID = 32, Lottery = 0},
        {CardID = 33, Lottery = 1},
    }
--]]
function LayerTurnCard:ctor(data)
    self.m_Data = data or {}
	self:init()
end

function LayerTurnCard:init()
	self:initData()
	self:initUI()
    self:initListener()
end

function LayerTurnCard:initData()    
    --  动画时间
    self.m_AniTime = 0
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(lCSBFilePath)
end

function LayerTurnCard:initUI()
    --  标题——翻马
    self.m_ImgTitle = cc.Sprite:create(lTitleFilePath)
    self:addChild(self.m_ImgTitle)
    self.m_ImgTitle:setPosition(cc.p(display.cx, display.height * 0.85))
    self.m_ImgTitle:setScale(1.5)

    --  底板背景
    self.m_CardFloor = cc.LayerColor:create()
    self:addChild(self.m_CardFloor)
    self.m_CardFloor:setColor(cc.c3b(256, 256, 256))
    self.m_CardFloor:setOpacity(150)
    self.m_CardFloor:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_CardFloor:setPosition(cc.p(0, display.cy))

    --  卡牌面板
    self.m_CardPanel = CardPanel.new(self.m_Data)
    self.m_CardFloor:addChild(self.m_CardPanel)

    --  排版
    local lScale = 0.9
    local lCardSize = self.m_CardPanel.m_ListCard[1]:getContentSize()
    local lActualRow = self.m_CardPanel.m_ActualRow
    local lRowGap = self.m_CardPanel.m_Options.RowGap
    local lFloorWidth = display.width   --  底板宽
    local lFloorHeight = (lCardSize.height + lRowGap) * lActualRow * lScale --  底板高
    self.m_CardFloor:setContentSize(cc.size(lFloorWidth, lFloorHeight))
    self.m_CardFloor:setPosition(cc.p(0, (display.height - lFloorHeight) / 2))
    self.m_CardPanel:setScale(lScale)
    self.m_CardPanel:setPosition(cc.p(lFloorWidth / 2, lFloorHeight / 2))
end

--  初始化监听事件
function LayerTurnCard:initListener()
    --  注册单点触摸事件
    local function onTouchBegan(touch, event)
        Log.i("onTouchBegan")
        return true
    end
    local function onTouchMoved(touch, event)
        Log.i("onTouchMoved")
    end
    local function onTouchEnded(touch, event)
        Log.i("onTouchEnded")
    end

    self.m_Listener = cc.EventListenerTouchOneByOne:create()
    self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_Listener, self)
end

--  关闭
function LayerTurnCard:closed()
    self:removeFromParent()
end

--  设置界面的可见性
function LayerTurnCard:setLayerVisible(isVisible)
    self:setVisible(isVisible)
    self.m_Listener:setSwallowTouches(isVisible)
end

--  执行动画
function LayerTurnCard:doAniTurnChicken()
    local lCFSize = self.m_CardFloor:getContentSize()
    local lAniZhuoJiTime = 2
    self.m_CardPanel:setVisible(false)

    local lArmature = ccs.Armature:create("guizhouAnimation")
    self.m_CardFloor:addChild(lArmature)
    lArmature:setPosition(cc.p(lCFSize.width / 2, lCFSize.height / 2))

    lArmature:getAnimation():play("AnimationZHUOJI")
    self.m_CardFloor:performWithDelay( function()
        lArmature:runAction(cc.Sequence:create(
        cc.FadeOut:create(0.5),
        cc.RemoveSelf:create()
        ))

        self.m_CardPanel:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create( function()
            self.m_CardPanel:setVisible(true)
        end ),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create( function()
            self.m_CardPanel:doAniTurnCardOneByOne()
        end )
        ))
    end , lAniZhuoJiTime)
    self.m_CardPanel.m_AniTime = 2
    self.m_AniTime = self.m_CardPanel.m_AniTime + lAniZhuoJiTime + 1.5
end

return LayerTurnCard
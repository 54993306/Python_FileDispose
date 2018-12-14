--
-- Author: RuiHao Lin
-- Date: 2017-07-03 16:23:10
-- @brief   LayerTurnCard 单人翻牌层
--

local CardPanel = require("app.games.common.custom.TurnCard.CardPanel")

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
    @lConfig   卡牌面板的配置；
    {
        CardPanelConfig =
        {
            LayoutStyle = CardPanel.EnumLayoutStyle.Align_Center,   --  排列方式，默认为Align_Center
            ShowAniHighLight = true,                                --  是否播放高亮动画，默认为true
            ColGap = 30,                                            --  列间距，默认为30
            RowGap = 30,                                            --  行间距，默认为30
            MaxCol = 8,                                             --  最大列数，默认为8
        }
        CardPanelScale = 0.9    --  卡牌板块缩放值
    }
--]]
function LayerTurnCard:ctor(data, lConfig)
    self.m_Data = data or {}
    self.m_Config = lConfig or {}
	self:init()
end

function LayerTurnCard:init()
	self:initData()
	self:initUI()
    self:initListener()
end

function LayerTurnCard:initData()
    self:initConfig()    
    --  动画时间
    self.m_AniTime = 0
end

--  初始化配置列表
function LayerTurnCard:initConfig()
    --  卡牌板块配置表
    self.m_Config.CardPanelConfig = self.m_Config.CardPanelConfig or {}
    --  卡牌板块缩放值
    self.m_Config.CardPanelScale = self.m_Config.CardPanelScale or 0.9
end

function LayerTurnCard:initUI()
    --  标题——翻马
    self.m_ImgTitle = cc.Sprite:create("games/common/game/fanma.png")
    self:addChild(self.m_ImgTitle)
    self.m_ImgTitle:setPosition(cc.p(display.cx, display.height * 0.85))

    --  底板背景
    self.m_CardFloor = cc.LayerColor:create()
    self:addChild(self.m_CardFloor)
    self.m_CardFloor:setColor(cc.c3b(256, 256, 256))
    self.m_CardFloor:setOpacity(150)
    self.m_CardFloor:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_CardFloor:setPosition(cc.p(0, display.cy))

    --  卡牌面板
    self.m_CardPanel = CardPanel.new(self.m_Data, self.m_Config.CardPanelConfig)
    self.m_CardFloor:addChild(self.m_CardPanel)
    local size = self.m_CardPanel:getContentSize()

    --  排版
    local lScale = self.m_Config.CardPanelScale
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

--  关闭翻牌层
function LayerTurnCard:closed()
    self:removeFromParent()
end

--  设置翻牌界面的可见性
function LayerTurnCard:setLayerVisible(isVisible)
    self:setVisible(isVisible)
    self.m_Listener:setSwallowTouches(isVisible)
end

--  执行翻牌动画，逐个翻牌
function LayerTurnCard:doAniTurnCardOneByOne()
    self.m_CardPanel:doAniTurnCardOneByOne()
    self.m_AniTime = self.m_CardPanel.m_AniTime
end

return LayerTurnCard
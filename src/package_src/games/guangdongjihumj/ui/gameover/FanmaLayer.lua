--
-- Author: Van
-- Date: 2017-08-03 17:28:32
--
local CardPanel = import(".FanmaPanel")--require("app.games.common.custom.TurnCard.CardPanel")
local LayerTurnCardMultiplayer=require("app.games.common.custom.TurnCard.LayerTurnCardMultiplayer")
local FanmaLayer=class("FanmaLayer",LayerTurnCardMultiplayer)


function FanmaLayer:ctor(data,isTouchClose)
    FanmaLayer.super.ctor(self,data)
    self.m_isTouchClose=isTouchClose
    -- self.m_Data = data
    -- self:init()
end

function FanmaLayer:initUI()
    --  标题——翻马
    self.m_ImgTitle = cc.Sprite:create("games/common/game/fanma.png")
    self:addChild(self.m_ImgTitle,1)
    self.m_ImgTitle:setPosition(cc.p(display.cx, display.height * 0.9))

    self:initItem()
end

--  初始化监听事件
function FanmaLayer:initListener()
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
        if self.m_isTouchClose then
            self:closed()
        end
    end

    self.m_Listener = cc.EventListenerTouchOneByOne:create()
    self.m_Listener:setSwallowTouches(true)
    self.m_Listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.m_Listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.m_Listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_Listener, self)
end

--  初始化显示项
function FanmaLayer:initItem()
    local row = 1
    local lActualRow = #self.m_Data
    local lRowGap = lActualRow <= 2 and 90 or 30
    for i, v in pairs(self.m_Data) do
        if v and #v.CardList > 0 then
            --  底板背景
            local lItemBG = cc.LayerColor:create()
            self:addChild(lItemBG)
            lItemBG:setColor(cc.c3b(256, 256, 256))
             -- lItemBG:setColor(cc.c3b(255, 0, 0))
            lItemBG:setOpacity(150)

            --  卡牌板块
            lCardPanel = CardPanel.new(v.CardList, {LayoutStyle = CardPanel.EnumLayoutStyle.Align_Left})
            lItemBG:addChild(lCardPanel)
            lCardPanel:setMaxCol(16)
            lCardPanel:composing()
            table.insert(self.m_CardPanel, lCardPanel)

            --  头像板块
            local lHeadPanel = self:createHeadPanel(v.UserID)
            lItemBG:addChild(lHeadPanel)

            --  排版适配
            local lCardPanelSize = lCardPanel:getContentSize()
            local lCardSize = lCardPanel.m_ListCard[1]:getContentSize()
            
            local lItemBGWidth = display.width
            local lDefualtHeight = lCardPanelSize.height--lCardSize.height*#lCardPanel.m_ListCard
            local lItemBGScale = 1
            local lCardPanelScale = 1
            local lHeadPanelScale = 1

            if lActualRow == 1 then
                -- lDefualtHeight = lCardSize.height + lCardPanel.m_Options.RowGap
                lItemBGScale = 0.3
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.8

            elseif lActualRow == 4 then
                -- lDefualtHeight = lCardSize.height * 1.5 + lCardPanel.m_Options.RowGap
                lItemBGScale = 0.28
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.7
            else
                lItemBGScale = 0.3
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.8
                lDefualtHeight = lCardSize.height * 2 + lCardPanel.m_Options.RowGap
            end

            lDefualtHeight=lDefualtHeight*lCardPanelScale+20

            if lDefualtHeight<500 then
                lDefualtHeight=500
            end

            print(lDefualtHeight)

            local lItemBGHeight =(lDefualtHeight + lCardPanel.m_Options.RowGap * 2) * lItemBGScale

            local nY = -(row -((lActualRow + 1) / 2))
            local offsetY = - nY * - lRowGap
            local posY = lItemBGHeight * nY + offsetY
            row = row + 1

            lItemBG:setContentSize(cc.size(lItemBGWidth, lDefualtHeight))--lItemBGHeight))
            lItemBG:setPosition(cc.p(0, (display.height-lDefualtHeight)/2))-- * 0.4 + posY))
            

            lCardPanel:setScale(lCardPanelScale)
            lCardPanel:setPosition(cc.p(lItemBGWidth * 0.1+(lItemBGWidth*0.9-lCardSize.width)/2-lCardSize.width/2, lDefualtHeight/2)) --+

            lHeadPanel:setScale(lHeadPanelScale)
            lHeadPanel:setPosition(cc.p(lItemBGWidth * 0.06, lDefualtHeight / 2))
        end
    end
end

return FanmaLayer
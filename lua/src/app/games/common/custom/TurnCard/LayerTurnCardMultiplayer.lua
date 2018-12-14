--
-- Author: RuiHao Lin
-- Date: 2017-07-03 16:23:10
-- @brief   LayerTurnCardMultiplayer 多人翻牌层
--

local CardPanel = require("app.games.common.custom.TurnCard.CardPanel")

local LayerTurnCardMultiplayer = class("LayerTurnCardMultiplayer", function ()
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
        {
            UserID = 100045,    --  玩家ID
            CardList =          --  卡牌列表
            {
                {CardID = 31, Lottery = 0}, --  CardID：卡牌ID， Lottery：1 --高亮；0 --灰暗
                {CardID = 32, Lottery = 0},
                {CardID = 33, Lottery = 1},
            },
        },
        {
            UserID = 100046,
            CardList =
            {
                {CardID = 34, Lottery = 0},
                {CardID = 35, Lottery = 1},
                {CardID = 36, Lottery = 1},
            },
        },
    }
--]]
function LayerTurnCardMultiplayer:ctor(data)
    self.m_Data = data
	self:init()
end

function LayerTurnCardMultiplayer:init()
	self:initData()
	self:initUI()
    self:initListener()
end

function LayerTurnCardMultiplayer:initData()
    self.m_CardPanel = {}
    self.m_CardIndex = {}
    self.m_AniTime = {}
    self.m_SchedulerID = {}
end

function LayerTurnCardMultiplayer:initUI()
    --  标题——翻马
    self.m_ImgTitle = cc.Sprite:create("games/common/game/fanma.png")
    self:addChild(self.m_ImgTitle)
    self.m_ImgTitle:setPosition(cc.p(display.cx, display.height * 0.9))

    self:initItem()
end

--  初始化监听事件
function LayerTurnCardMultiplayer:initListener()
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
function LayerTurnCardMultiplayer:closed()
    self:removeFromParent()
end

--  设置翻牌界面的可见性
function LayerTurnCardMultiplayer:setLayerVisible(isVisible)
    self:setVisible(isVisible)
    self.m_Listener:setSwallowTouches(isVisible)
end

--  初始化显示项
function LayerTurnCardMultiplayer:initItem()
    local row = 1
    local lActualRow = #self.m_Data
    local lRowGap = lActualRow <= 2 and 90 or 30
    for i, v in pairs(self.m_Data) do
        if v and #v.CardList > 0 then
            --  底板背景
            local lItemBG = cc.LayerColor:create()
            self:addChild(lItemBG)
            lItemBG:setColor(cc.c3b(256, 256, 256))
            lItemBG:setOpacity(150)

            --  卡牌板块
            lCardPanel = CardPanel.new(v.CardList, {LayoutStyle = CardPanel.EnumLayoutStyle.Align_Left})
            lItemBG:addChild(lCardPanel)
            lCardPanel:setMaxCol(12)
            lCardPanel:composing()
            table.insert(self.m_CardPanel, lCardPanel)

            --  头像板块
            local lHeadPanel = self:createHeadPanel(v.UserID)
            lItemBG:addChild(lHeadPanel)

            --  排版适配
            local lCardPanelSize = lCardPanel:getContentSize()
            local lCardSize = lCardPanel.m_ListCard[1]:getContentSize()
            local lItemBGWidth = display.width
            local lDefualtHeight = 0
            local lItemBGScale = 1
            local lCardPanelScale = 1
            local lHeadPanelScale = 1

            if lActualRow == 1 then
                lDefualtHeight = lCardSize.height + lCardPanel.m_Options.RowGap
                lItemBGScale = 0.3
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.8

            elseif lActualRow == 4 then
                lDefualtHeight = lCardSize.height * 1.5 + lCardPanel.m_Options.RowGap
                lItemBGScale = 0.28
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.7
            else
                lItemBGScale = 0.3
                lCardPanelScale = 0.4
                lHeadPanelScale = 0.8
                lDefualtHeight = lCardSize.height * 2 + lCardPanel.m_Options.RowGap
            end
            local lItemBGHeight =(lDefualtHeight + lCardPanel.m_Options.RowGap * 2) * lItemBGScale

            local nY = -(row -((lActualRow + 1) / 2))
            local offsetY = - nY * - lRowGap
            local posY = lItemBGHeight * nY + offsetY
            row = row + 1

            lItemBG:setPosition(cc.p(0, display.height * 0.4 + posY))
            lItemBG:setContentSize(cc.size(lItemBGWidth, lItemBGHeight))

            lCardPanel:setScale(lCardPanelScale)
            lCardPanel:setPosition(cc.p(lItemBGWidth * 0.35, lItemBGHeight / 2))

            lHeadPanel:setScale(lHeadPanelScale)
            lHeadPanel:setPosition(cc.p(lItemBGWidth * 0.1, lItemBGHeight / 2))
        end
    end
end

--[[
    @brief  创建头像板块
    @playerID   玩家ID
--]]
function LayerTurnCardMultiplayer:createHeadPanel(playerID)
    local lGameSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local lPlayersInfo = lGameSystem:gameStartGetPlayers()
    local lPlayerIndex = lGameSystem:getPlayerSiteById(playerID)
    local lScoreItems = lGameSystem:getGameOverDatas().score

    --  头像节点
    local lHeadNode = cc.Node:create()

    --  头像
    local lHeadIMG = cc.Sprite:create()
    lHeadNode:addChild(lHeadIMG)

    --  获取头像文件
    local lUserID = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.USERID)
    local lImgURL = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.ICON_ID) .. "";
    if string.len(lImgURL) > 3 then
        local lImgName = lGameSystem:gameStartGetPlayerByUserid(lUserID):getProp(enCreatureEntityProp.USERID) .. ".jpg";
        local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName);
        if io.exists(lHeadFile) then
            lHeadIMG:setTexture(lHeadFile)
            -- lHeadIMG:setScale(0.14)
            lHeadIMG:setScale(90/lHeadIMG:getContentSize().width)
        end
    else
        local lImgName = "hall/Common/default_head_2.png"
        local lHeadFile = cc.FileUtils:getInstance():fullPathForFilename(lImgName)
        if io.exists(lHeadFile) then
            lHeadIMG:setTexture(lHeadFile)
            -- lHeadIMG:setScale(0.6)
            lHeadIMG:setScale(90/lHeadIMG:getContentSize().width)
        end
    end


    --  头像框
    local lHeadBG = cc.Sprite:create("games/common/game/friendRoom/mjOver/bg_head.png")
    lHeadNode:addChild(lHeadBG)
    local lHeadBGSize = lHeadBG:getContentSize()

    --  庄家图标
    local lBankerIcon = cc.Sprite:create("games/common/game/friendRoom/mjOver/zhuang.png")
    lHeadBG:addChild(lBankerIcon)
    lBankerIcon:setPosition(cc.p(0, lHeadBGSize.height))

    local lBanker = lPlayersInfo[lPlayerIndex]:getProp(enCreatureEntityProp.BANKER)
    if lBanker then
        lBankerIcon:setVisible(true)
    else
        lBankerIcon:setVisible(false)
    end

    --  昵称
    local lNameLab = cc.Label:create()
    lHeadBG:addChild(lNameLab)
    lNameLab:setSystemFontName("hall/font/fangzhengcuyuan.TTF")
    lNameLab:setColor(cc.c3b(252, 234, 67))
    lNameLab:setAnchorPoint(cc.p(0, 1))
    lNameLab:setPosition(cc.p(0, lHeadBGSize.height * 0.05))
    lNameLab:setSystemFontSize(30)

    local lStrName = ""
    lStrName = ToolKit.subUtfStrByCn(lScoreItems[lPlayerIndex].nick, 0, 5, "")
    lNameLab:setString(lStrName)
    Util.updateNickName(lNameLab, lStrName)

    return lHeadNode
end

--  执行翻牌动画，逐个翻牌
function LayerTurnCardMultiplayer:doAniTurnCardOneByOne()
    for i, v in pairs(self.m_CardPanel) do
        v:doAniTurnCardOneByOne()
    end
    self.m_AniTime = 0
    for i, v in pairs(self.m_CardPanel) do
        if v.m_AniTime > self.m_AniTime then
            self.m_AniTime = v.m_AniTime
        end
    end
end

--  执行翻牌动画，全部牌同时翻转
function LayerTurnCardMultiplayer:doAniTurnCardAll()
    for i, v in pairs(self.m_CardPanel) do
        v:doAniTurnCardAll()
    end
    self.m_AniTime = self.m_CardPanel[1].m_AniTime
end

return LayerTurnCardMultiplayer
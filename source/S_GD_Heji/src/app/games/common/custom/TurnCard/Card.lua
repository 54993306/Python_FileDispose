--
-- Author: RuiHao Lin
-- Date: 2017-07-03 16:22:56
--
--  @Card   创建一个具备翻牌动画的麻将对象

local Card = class("Card", function ( )
	local ret = cc.Node:create()
	return ret
end)

--[[
    @brief   创建一张牌，拥有翻牌动画
    @cardID  卡牌ID
--]]
function Card:ctor(cardID)
	self.m_CardID = cardID
	self:init()
end

function Card:init(  )
	self:initData()
	self:initUI()
end

function Card:initData( )
	cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008006.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("res_plist/1008009.plist")

    --  执行动画精灵
    self.m_AniSprite = {}
	--	正面
	self.m_IconFront = {}
	--	反面
	self.m_IconReverse = {}
end

function Card:initUI()
    self.m_AniSprite = cc.Sprite:create()
    self:addChild(self.m_AniSprite)

    self.m_IconFront = cc.Sprite:createWithSpriteFrameName("fanma5.png")
    self:addChild(self.m_IconFront)
    self.m_IconFront:setVisible(false)
    local lFrontSize = self.m_IconFront:getContentSize()

    local lOffsetH = 20
    local lCardTexture = getCardPngByValue(self.m_CardID)
    local lWrod = cc.Sprite:createWithSpriteFrameName(lCardTexture)
    lWrod:setPosition(cc.p(lFrontSize.width / 2, lFrontSize.height / 2 + lOffsetH))
    self.m_IconFront:addChild(lWrod)
    lWrod:setScale(1.4)

    self.m_IconReverse = cc.Sprite:createWithSpriteFrameName("startFrame.png")
    self:addChild(self.m_IconReverse)

    self:setContentSize(cc.size(lFrontSize.width, lFrontSize.height))
    self:setHighLight(false)
end

--  设置麻将是否高亮
function Card:setHighLight(isHighLight)
    if isHighLight then
        self.m_IconFront:setColor(display.COLOR_WHITE)
    else
        self.m_IconFront:setColor(cc.c3b(166, 166, 166))
    end
end

--  执行翻牌动画1
function Card:doAniTurnCard()
    local frames = display.newFrames("fanma%d.png", 1, 5)
    local animation = display.newAnimation(frames, 0.04)
    local lAniMate = cc.Animate:create(animation)
    local lHideReverse = cc.CallFunc:create( function()
        self.m_IconReverse:setVisible(false)
    end )
    local lShowFront = cc.CallFunc:create( function()
        self.m_IconFront:setVisible(true)
    end )
    local lNode = cc.Sprite:create()
    self:addChild(lNode)
    lNode:runAction(cc.Sequence:create(
    lHideReverse,
    lAniMate,
    lShowFront,
    cc.RemoveSelf:create()
    ))
end

--  执行翻牌动画2
function Card:doAniTurnCard2()
    local lDelayTime = 0.25
    self.m_IconReverse:runAction(cc.Sequence:create(
    cc.OrbitCamera:create(lDelayTime, 1, 0, 0, 90, 0, 0),
    cc.Hide:create(),
    cc.DelayTime:create(lDelayTime)
    ))

    self.m_IconFront:runAction(cc.Sequence:create(
    cc.DelayTime:create(lDelayTime),
    cc.Show:create(),
    cc.OrbitCamera:create(lDelayTime, 1, 0, 270, 90, 0, 0)
    ))
end

--  执行灯光特效动画
function Card:doAniHighLight()
    local lFrames = display.newFrames("fanmalight%d.png", 1, 14)
    local lLight = display.newSprite(lFrames[1])
    local lAniLight = display.newAnimation(lFrames, 1 / 14)
    local function AniCallBack()
        self.m_IconFront:setColor(display.COLOR_WHITE)
    end
    transition.playAnimationOnce(lLight, lAniLight, true, AniCallBack, 1 / 14)
    self.m_IconFront:addChild(lLight)
    lLight:setScale(3)
    lLight:setPosition(cc.p(self.m_IconFront:getContentSize().width / 2, self.m_IconFront:getContentSize().height / 2))
end

return Card
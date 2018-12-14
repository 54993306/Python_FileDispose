--
-- Author: mzd
-- Date: 2017-10-23 19:51:35
-- 裁剪
--

local PokerClippingNode = class("PokerClippingNode", function ()
	local clippingNode = cc.ClippingNode:create() 
    clippingNode:setPosition(0,0)
    clippingNode:setAlphaThreshold( 0.05 )
    clippingNode:setInverted( false )
    return clippingNode
end)

--网络头像下载成功后加载失败使用的默认头像
local defHead = "package_res/games/pokercommon/head/defaultHead_male.png"

function PokerClippingNode:ctor(stencilImgPath,spritePath, customSize)
	self.m_stencilSize = customSize or 100
    self:setImgFile(stencilImgPath,spritePath)
end

function PokerClippingNode:setImgFile(stencilImgPath,imgPath)
    local stencil = cc.Sprite:create(stencilImgPath)
    stencil:setPosition(0, 0)
    -- Log.i("self.m_stencilSize ", self.m_stencilSize)
    -- Log.i("stencil:getContentSize() ", stencil:getContentSize())
    stencil:setScale(self.m_stencilSize / stencil:getContentSize().width)
    stencil:setAnchorPoint( 0.5, 0.5)
    self:setStencil(stencil)

    local sp = cc.Sprite:create(imgPath)
    if not sp then
        sp = display.newSprite(defHead)
    end
    -- Log.i("imgPath is :", imgPath)
    sp:setScale( self.m_stencilSize / sp:getContentSize().width )
    sp:setAnchorPoint( 0.5, 0.5)
    sp:setPosition(0,0)
    self:addChild(sp)
end

return PokerClippingNode
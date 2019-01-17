
local CircleClippingNode = class("CircleClippingNode", function ()
	return cc.RenderTexture:create(100, 100)
end)

function CircleClippingNode:ctor(spritePath, useScale, customSize)
    self.m_useScale = useScale and useScale or false
	self.m_stencilSize = customSize or 76

    self:setImgFile(spritePath)


end

function CircleClippingNode:setImgFile(imgPath)

    local stencil = cc.Sprite:create("hall/Common/circleClipStencil.png")
    stencil:setScale(self.m_stencilSize/77)
    stencil:setPosition(50, 50)
    local sp = cc.Sprite:create(imgPath)
    if sp == nil or tolua.isnull(sp) then
        sp = cc.Sprite:create("hall/Common/defaultCircleHead.png")
    end
    sp:setPosition(50, 50)

    stencil:setBlendFunc(gl.SRC_COLOR, gl.ZERO)
    sp:setBlendFunc(gl.DST_ALPHA, gl.ZERO)


    if not self.m_useScale then
        sp:setScale(1)
    else
        local size = sp:getContentSize()
        if size.width > 0 then
            sp:setScale(self.m_stencilSize / size.width)
        else
            sp:setScale(1)
        end

    end

    self:clear(0,0,0,0)
    self:begin();
    stencil:visit();
    sp:visit();
    self:endToLua();
end

return CircleClippingNode
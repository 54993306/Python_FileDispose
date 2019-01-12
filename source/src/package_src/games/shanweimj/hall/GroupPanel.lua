--
-- Author: Van
-- Date: 2017-06-28 11:37:21
--
local GroupPanel=class("GroupPanel", function() 
    local ret = display.newNode()
    return ret
end)

function GroupPanel:ctor(data)
	local x=0
	for k,v in pairs(data.panels) do
		self:addChild(v)
		v:setPositionX(x)
		x=x+v:getContentSize().width+(data.pad or 0) + (data.offX and data.offX[k] or 0)
	end

	self:setContentSize(cc.size(x,60))

	if data.line then
		local line=display.newSprite("hall/Common/line2.png")
        line:setScaleX(100)
		line:setAnchorPoint(cc.p(0,0))
		line:addTo(self)
	end
	if data.zorder then
		self:setLocalZOrder(data.zorder)
	end
end

return GroupPanel
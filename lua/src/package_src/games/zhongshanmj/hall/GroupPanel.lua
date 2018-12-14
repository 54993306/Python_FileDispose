--
-- Author: Van
-- Date: 2017-06-28 11:37:21
--
local GroupPanel=class("GroupPanel", function() 
    local ret = display.newNode()
    return ret
end)

function GroupPanel:ctor(data)
	local x=data.initX or 0
	for k,v in pairs(data.panels) do
		self:addChild(v)
		v:setPositionX(x)
		x=x+v:getContentSize().width+(data.pad or 0)
	end

	self:setContentSize(cc.size(x,G_ROOM_INFO_FORMAT.lineHeight))

	if data.line then
		local line=display.newSprite("hall/Common/line2.png")
        line:setScaleX(100)
		line:setAnchorPoint(cc.p(0,0))
		line:addTo(self)
	end
end

return GroupPanel
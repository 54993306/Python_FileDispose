-- 筹码
-- Author: Jinds
-- Date: 2017-10-24 17:18:42
--
local PokerUtils = require("package_src.games.pokercommon.commontool.PokerUtils")

local Chip = class("Chip", function()
    return ccui.ImageView:create();
end)

local CHIPCOLOR = {
	"pszroom/img_chipblue.png",
	"pszroom/img_chipgrn.png",
	"pszroom/img_chippink.png",
	"pszroom/img_chippurple.png", -- 紫色
	"pszroom/img_chipred.png",
}


function Chip:ctor(value, arr)
	-- Log.i("Chip:ctor", value, arr)
	self.value = value
	self.valueArr = arr
	table.sort(self.valueArr, function(a, b) return a < b end)
	self.color, self.str = self:getColorAndText(value)
	-- Log.i("self.color, self.str :", self.color, self.str)
	self:composeTexture()
end

function Chip:composeTexture()
	self:loadTexture(self.color, ccui.TextureResType.plistType)
	self.label_num = cc.Label:createWithBMFont("games/pinsanzhang/pszroom/chipNum.fnt", self.str)
	if self.label_num then
		self:addChild(self.label_num)
		self.label_num:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.2)
	else
		printError("error lab is nil")
	end
end

function Chip:getValue()
	return self.value
end

function Chip:getColorAndText(value)
	local retValue, retColor
	retValue  = PokerUtils:formatChip(value)
	retValue = "" .. retValue
	local colorIdx = 1
	for i=1, #self.valueArr do
		if self.valueArr[i] == value then
			colorIdx = i + 1
		end	
	end
	return CHIPCOLOR[colorIdx] or CHIPCOLOR[1] , retValue
end

return Chip
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local PROP_IMG_MAP =
{
    [1] = "hall/huanpi2/Common/diamond.png",
    [2] = "hall/huanpi2/Common/gold_icon.png",
}

setmetatable(PROP_IMG_MAP, PROP_IMG_MAP)

PROP_IMG_MAP.__index = function(table, key)
    return "games/common/GUI/image.png"
end

return PROP_IMG_MAP
--endregion

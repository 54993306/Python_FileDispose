--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local PROP_IMG_MAP =
{
    [1] = "#1004575.png",
    [2] = "#1004583.png",
}

setmetatable(PROP_IMG_MAP, PROP_IMG_MAP)

PROP_IMG_MAP.__index = function(table, key)
    return "real_res/1004211.png"
end

return PROP_IMG_MAP
--endregion

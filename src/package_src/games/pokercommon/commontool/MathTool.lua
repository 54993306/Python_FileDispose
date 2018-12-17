--[[-----------------------------------------------------
-- 定义：数学工具
-- 作者：李海波
-- 日期：2018.05.05
-- 修改记录：
-- 2018.05.05  实现基本功能
]]-------------------------------------------------------

local MathTool = {}

-- 高4位掩码
local MASK_HIGHT_SITE = 0xF0

-- 低4位掩码
local MASK_LOW_SITE   = 0x0F

-- 函数功能：       获取高低位数字
-- 返回值：         高位数字、低位数字
-- originalNumber: 原始数字
function MathTool.GetHighAndLowNumber(originalNumber)
    if LUA_BASE_TYPE_NUMBER ~= type(originalNumber) then
        printError("MathTool.GetHighAndLowNumber 传入参数不正确！")
        return
    end

    local high = bit_and(originalNumber, MASK_HIGHT_SITE)
    local low = bit_and(originalNumber, MASK_LOW_SITE)
    return high, low
end



return MathTool
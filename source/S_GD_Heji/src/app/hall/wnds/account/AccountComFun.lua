-----------------------------------------------------------
--  @file   AccountComFun.lua
--  @brief  账号系统通用函数
--  @author At.Lin
--  @DateTime:2018-07-05 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
local ComFun = {}

local crypto = require "app.framework.crypto"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"

local cryptokey = "pykf"

local Password = nil

-- 判断是否为正常格式手机号
ComFun.isPhoneNumber = function(phone)
    if not phone then return false end
    phone = tostring(phone)
    return string.match(phone,"[1][3,4,5,6,7,8,9]%d%d%d%d%d%d%d%d%d") == phone
end

-- 格式化电话号码格式后输出
-- cryp 是否加密中间四个数
ComFun.formatPhoneNumber = function(phoneNum, cryp)
    if not ComFun.isPhoneNumber(phoneNum) then
        Log.d("kGiftData_logicInfo:getTaskByID(AccountStatus.PhoneTaskID)", kGiftData_logicInfo:getTaskByID(AccountStatus.PhoneTaskID))
        Log.e("phoneNum", tostring(phoneNum))
        return ""
    end -- 不是电话号码不做处理
    local formatNum = ""
    formatNum = string.sub(phoneNum,1,3) .. " "
    if cryp then
        formatNum = formatNum .. "**** "
    else
        formatNum = formatNum .. string.sub(phoneNum,4,7) .. " ";
    end
    formatNum = formatNum .. string.sub(phoneNum,8,11);
    return formatNum;
end

-- 判断验证码,strlen 为字符串长度
ComFun.isVerifyCode = function(str,strlen)
    if not str then return false end
    if strlen then
        return string.len(str) == strlen and not string.match(str,"[^%d%l%u]")
    else
        return not string.match(str,"[^%d%l%u]") --是否包含数字和字母外的其他字符
    end
end

-- 判断是否符合密码规范 只包含字母和数字，6-14位
ComFun.isPassword = function(str)
    if not str or string.match(str,"[^%d%l%u]") then  -- 包含数字和字母以外的字符
        return false
    end

    if string.len(str) < 6 or string.len(str) > 14 then  -- 密码长度不符合要求
        return false
    end
    return true
    -- if not string.match(str , "%d") then
    --     return false;
    -- else
    --     if not string.match(str , "%l") and not string.match(str , "%u") then
    --         return false
    --     else
    --         return true
    --     end
    -- end
end

-- 获取验证码等待时间
ComFun.getVerifyDelayTime = function()
    if AccountStatus.TEST then
        return 3
    else
        return 60  -- 默认为60秒
    end
end

-- 节点播放放大动画
ComFun.ShowNodeBigAction = function(node)
    node:setVisible(true)
    node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.1),cc.ScaleTo:create(0.25,1)))
end

-- 获取手机号
ComFun.getPhone = function()
    local phone = cc.UserDefault:getInstance():getStringForKey("phonenumber","0")
    if ComFun.isPhoneNumber(phone) then
        return phone
    end
    return "0"
end

-- 设置手机号
ComFun.setPhone = function(str)
    if str and ComFun.isPhoneNumber(str) then
        cc.UserDefault:getInstance():setStringForKey("phonenumber",tostring(str))
        Log.i("ComFun.setPhone 设置手机号成功")
    else
        cc.UserDefault:getInstance():setStringForKey("phonenumber","0")
    end
end

-- 设置密码
ComFun.setPassword = function(str, notSave)
    if str then
        Password = str
        if notSave then
            cc.UserDefault:getInstance():setStringForKey("phonepassword","0")
        else
            cc.UserDefault:getInstance():setStringForKey("phonepassword",tostring(str))
        end
        Log.i("ComFun.setPassword 设置密码成功")
        -- Log.i(debug.traceback(str))
    else
        cc.UserDefault:getInstance():setStringForKey("phonepassword","0")
    end
end

-- 获取密码
ComFun.getPassword = function()
    if Password then return Password end
    local password = cc.UserDefault:getInstance():getStringForKey("phonepassword","0")
    return password
end

-- 获取密码位数
ComFun.getPasswordNum = function()
    return ComFun.PasNum or 0
end

return ComFun

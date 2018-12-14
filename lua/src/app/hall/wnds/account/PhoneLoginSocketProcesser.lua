-----------------------------------------------------------
--  @file   PhoneLoginSocketProcesser.lua
--  @brief  邮件系统
--  @author linxiancheng
--  @DateTime:2018-07-03 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ========================================================

-- 手机号登陆服务器消息处理
local PhoneLoginSocketProcesser = class("PhoneLoginSocketProcesser", SocketProcesser)
-- PhoneLoginSocketProcesser = class("PhoneLoginSocketProcesser", SocketProcesser)

-- 接收获取验证码服务器返回
function PhoneLoginSocketProcesser:RecVerifyCode(cmd,packetInfo)
    Log.i("PhoneLoginSocketProcesser:RecVerifyCode..", packetInfo);
    packetInfo = checktable(packetInfo)
    LoadingView.getInstance():hide();
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

PhoneLoginSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_VERIFY]             = PhoneLoginSocketProcesser.RecVerifyCode;        -- 获取验证码状态返回
    [HallSocketCmd.CODE_REC_CODEVERIFY]         = PhoneLoginSocketProcesser.RecVerifyCode;        -- 获取验证码状态返回
    [HallSocketCmd.CODE_REC_BINDPHONE]          = PhoneLoginSocketProcesser.RecVerifyCode;        -- 绑定手机返回
    [HallSocketCmd.CODE_REC_CHANGE_PASSWORD]    = PhoneLoginSocketProcesser.RecVerifyCode;        -- 修改密码返回
    [HallSocketCmd.CODE_REC_GETPASSWORD]        = PhoneLoginSocketProcesser.RecVerifyCode;        -- 发送新密码返回
    [HallSocketCmd.CODE_REC_BINDWECHAT]         = PhoneLoginSocketProcesser.RecVerifyCode;        -- 绑定微信返回
}

return PhoneLoginSocketProcesser
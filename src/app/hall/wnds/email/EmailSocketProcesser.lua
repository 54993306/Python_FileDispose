-----------------------------------------------------------
--  @file   EmailPanel.lua
--  @brief  邮件系统
--  @author linxiancheng
--  @DateTime:2017-05-04 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================
--邮件服务器消息处理

EmailSocketProcesser = class("EmailSocketProcesser", SocketProcesser)

function EmailSocketProcesser:MainInfoTransmit(cmd,packetInfo)
    Log.i("EmailSocketProcesser:RepMailContent..", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

EmailSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_CONTEXTINFO]    = EmailSocketProcesser.MainInfoTransmit;        --邮件列表返回
    [HallSocketCmd.CODE_REC_GETITEM]        = EmailSocketProcesser.MainInfoTransmit;        --获取物品成功返回
    [HallSocketCmd.CODE_REC_NEWMAIL]        = EmailSocketProcesser.MainInfoTransmit;        --新邮件
    [HallSocketCmd.CODE_SEND_PICKUP]        = EmailSocketProcesser.MainInfoTransmit;        --删除成功
    [HallSocketCmd.CODE_REC_CLUB_APPLY]     = EmailSocketProcesser.MainInfoTransmit;        --申请结果
}

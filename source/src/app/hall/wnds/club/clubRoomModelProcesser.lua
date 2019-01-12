-----------------------------------------------------------
--  @file   clubSocketProcesser.lua
--  @brief  亲友圈服务器消息接收
--  @author linxiancheng
--  @DateTime:2017-07-26 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local clubRoomModelProcesser = class("clubRoomModelProcesser",SocketProcesser)

function clubRoomModelProcesser:onClubInfoMsgReceive(cmd,info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

function clubRoomModelProcesser:onDeleteRec(cmd , info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd , info)
end

clubRoomModelProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_JOINCLUB] = clubRoomModelProcesser.onJoinClubMsgReceive,
    [HallSocketCmd.CODE_REC_DELETECLUBMODEL] = clubRoomModelProcesser.onDeleteRec,
}

return clubRoomModelProcesser

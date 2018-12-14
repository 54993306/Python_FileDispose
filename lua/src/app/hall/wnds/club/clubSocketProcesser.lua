-----------------------------------------------------------
--  @file   clubSocketProcesser.lua
--  @brief  亲友圈
--  @author linxiancheng
--  @DateTime:2017-07-26 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local ClubSocketProcesser = class("ClubSocketProcesser",SocketProcesser)

function ClubSocketProcesser:onClubInfoMsgReceive(cmd,info)
    Log.i("--------------------------ClubSocketProcesser:onClubInfoMsgReceive",info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

function ClubSocketProcesser:onJoinClubMsgReceive(cmd,info)
    Log.i("-----------------------ClubSocketProcesser:onJoinClubMsgReceive",info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

function ClubSocketProcesser:onAngencyInfoReceive(cmd, info)
    Log.i("-----------------------ClubSocketProcesser:onAngencyInfoReceive",info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

function ClubSocketProcesser:onClubLisHeadReceive(cmd, info)
    Log.i("-----------------------ClubSocketProcesser:onClubLisHeadReceive",info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

ClubSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_JOINCLUB] = ClubSocketProcesser.onJoinClubMsgReceive,
    [HallSocketCmd.CODE_REC_QUERYCLUB] = ClubSocketProcesser.onClubInfoMsgReceive,
    -- [HallSocketCmd.CODE_REC_QUERYCLUBINFO] = ClubSocketProcesser.onAngencyInfoReceive,
    [HallSocketCmd.CODE_REC_QUERYCLUBHEAD] = ClubSocketProcesser.onClubLisHeadReceive,
}

return ClubSocketProcesser
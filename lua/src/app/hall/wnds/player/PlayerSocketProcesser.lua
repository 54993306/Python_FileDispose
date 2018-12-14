-----------------------------------------------------------
--  @file   PlayerSocketProcesser.lua
--  @brief  玩家信息界面socket处理
--  @author linxiancheng
--  @DateTime:2017-08-03 10:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local PlayerSocketProcesser = class("PlayerSocketProcesser",SocketProcesser)

function PlayerSocketProcesser:onClubUpdate(cmd, info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd,info)
end

function PlayerSocketProcesser:onRecPanelCardInfo(cmd, info)
    info = checktable(info)
    self.m_delegate:handleSocketCmd(cmd, info)
end

PlayerSocketProcesser.s_severCmdEventFuncMap = {
    -- [HallSocketCmd.CODE_REC_HALL_REFRESH_UI] = PlayerSocketProcesser.onClubUpdate
    [HallSocketCmd.CODE_REC_PLAYERCARDINFO] = PlayerSocketProcesser.onRecPanelCardInfo,
    [HallSocketCmd.CODE_REC_QUERYCLUBINFO]  = PlayerSocketProcesser.directForward;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST] = PlayerSocketProcesser.directForward;
}

return PlayerSocketProcesser




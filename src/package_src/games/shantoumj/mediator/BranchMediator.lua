-------------------------------------------------------------
--  @file   MjMediator.lua
--  @brief  调度器
--  @author Zhu Can Qin
--  @DateTime:2016-08-30 09:39:54
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local MjGameSocketProcesser = require ("package_src.games.shantoumj.mediator.MjGameSocketProcesser")


local BranchMediator = class("BranchMediator", MjMediator)

function BranchMediator:ctor()
	Log.i("BranchMediator:ctor........")
    -- BranchMediator.super.ctor(self)
    -- 初始化在socket处理之前
    self:init()
    self.m_socketProcesser = MjGameSocketProcesser.new(self)
    -- self.m_socketProcesser.s_severCmdEventFuncMap[enMjMsgReadId.MSG_READ_PROMPT_INFO] = 

    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser)
end

return BranchMediator
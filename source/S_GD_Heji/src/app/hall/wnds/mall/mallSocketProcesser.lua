-----------------------------------------------------------
--  @file   MallSocketProcesser.lua
--  @brief  兑换商城
--  @author linxiancheng
--  @DateTime:2017-05-16 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local MallSocketProcesser = class("MallSocketProcesser", SocketProcesser)

function MallSocketProcesser:MallExchangeRec(cmd,packetInfo)
    -- Log.i("MallSocketProcesser:MallExchangeRec...", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function MallSocketProcesser:RecMallPlayerInfo(cmd,packetInfo)
    -- Log.i("mallSocketProcesser:RecMallPlayerInfo...", packetInfo);
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function MallSocketProcesser:updateScrip(cmd,packet)
    -- Log.i("MallSocketProcesser:updateScrip.....",packet)
    packet = checktable(packet)
    self.m_delegate:handleSocketCmd(cmd, packet)
end

-- --兑换商城消息模块
-- HallSocketCmd.CODE_SEND_MALLINFO        = 70201;    -- 获取兑换商城数据请求
-- HallSocketCmd.CODE_REC_MALLINFO         = 70202;    -- 服务器兑换商城信息返回
-- HallSocketCmd.CODE_SEND_EXCHANGE        = 70203;    -- 兑换物品
-- HallSocketCmd.CODE_REC_EXCHANGE         = 70204;    -- 兑换物品返回
-- HallSocketCmd.CODE_SEND_MALLADD         = 70007;    -- 填写收货地址
-- HallSocketCmd.CODE_REC_MALLADD          = 70007;    -- 服务器数据返回

MallSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_REC_EXCHANGE]    = MallSocketProcesser.MallExchangeRec;        --
    [HallSocketCmd.CODE_REC_MALLADD]     = MallSocketProcesser.RecMallPlayerInfo;
    [HallSocketCmd.CODE_USERDATA_POINT]  = MallSocketProcesser.updateScrip;
}

return MallSocketProcesser
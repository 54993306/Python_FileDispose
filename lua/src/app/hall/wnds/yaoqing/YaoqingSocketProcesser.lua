YaoqingSocketProcesser = class("YaoqingSocketProcesser", SocketProcesser)

function YaoqingSocketProcesser:repYaoqingInfo(cmd, packetInfo)
    Log.i("YaoqingSocketProcesser:repYaoqingInfo..", packetInfo);
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function YaoqingSocketProcesser:repYaoqingResult(cmd, packetInfo)
    Log.i("YaoqingSocketProcesser:repYaoqingInfo..", packetInfo);
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

YaoqingSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_INFO]   = YaoqingSocketProcesser.repYaoqingInfo;
    [HallSocketCmd.CODE_RECV_YAOQING_ID]   = YaoqingSocketProcesser.repYaoqingResult;
};



-- 奖励socket处理类
-- 在一个文件中定义两个类的情况

InviteRewardSocketProcesser = class("InviteRewardSocketProcesser",SocketProcesser)

function InviteRewardSocketProcesser:receiveRewardInfo(cmd , packetInfo)
    Log.i("---------------receiveRewardInfo",packetInfo)
    packetInfo = checktable(packetInfo)
    self.m_delegate:handleSocketCmd(cmd, packetInfo)
end

function InviteRewardSocketProcesser:repYaoqingResult(cmd, packetInfo)
    Log.i("InviteRewardSocketProcesser:repYaoqingResult..", packetInfo);
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

function InviteRewardSocketProcesser:repYaoqingInfo(cmd, packetInfo)
    Log.i("YaoqingSocketProcesser:repYaoqingInfo..", packetInfo);
    packetInfo = checktable(packetInfo);
    self.m_delegate:handleSocketCmd(cmd, packetInfo);
end

InviteRewardSocketProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_INFO]   = InviteRewardSocketProcesser.repYaoqingInfo;
    [HallSocketCmd.CODE_RECV_YAOQING_REWARD] = InviteRewardSocketProcesser.receiveRewardInfo;
    [HallSocketCmd.CODE_RECV_YAOQING_ID]   = InviteRewardSocketProcesser.repYaoqingResult;
}

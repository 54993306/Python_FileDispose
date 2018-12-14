UserDataProcesser = class("UserDataProcesser", SocketProcesser)

function UserDataProcesser:repUserInfo(code, packetInfo)
    kUserData_userInfo:syncData(code, packetInfo);
    kChargeListInfo:repeatSendApplePay()
end

function UserDataProcesser:repUserExtInfo(code, packetInfo)
    kUserData_userExtInfo:syncData(code, packetInfo);
end

function UserDataProcesser:repUserPointInfo(code, packetInfo)
    kUserData_userPointInfo:syncData(code, packetInfo);
end

function UserDataProcesser:repUserRecordInfo(code, packetInfo)
    kUserData_userRecordInfo:syncData(code, packetInfo);
end

--接收礼包UI信息
function UserDataProcesser:recvGiftLogicInfo(code, packetInfo)
    kGiftData_logicInfo:syncData(code, packetInfo);
end

UserDataProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_USERDATA_USERINFO]   = UserDataProcesser.repUserInfo;
    [HallSocketCmd.CODE_USERDATA_EXT]   = UserDataProcesser.repUserExtInfo;
    [HallSocketCmd.CODE_USERDATA_POINT]   = UserDataProcesser.repUserPointInfo;
    [HallSocketCmd.CODE_USERDATA_RECORD_CODE]   = UserDataProcesser.repUserRecordInfo;
    [HallSocketCmd.CODE_USERDATA_QUEST]   = UserDataProcesser.recvGiftLogicInfo;
};
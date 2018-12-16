local GlobalDataProcesser = class("GlobalDataProcesser")

function GlobalDataProcesser.onRepYaoingInfo(code, packetInfo)
    kUserInfo:setInviteInfo(checktable(packetInfo))
end

function GlobalDataProcesser.onSyncData(cmd, code, packetInfo)
    if GlobalDataProcesser.s_severCmdEventFuncMap[cmd] then
        local done = GlobalDataProcesser.s_severCmdEventFuncMap[cmd](code, packetInfo);
        return done or true;
    end
    return false;
end

function GlobalDataProcesser.repHallRefreshUI( cmd, info)
    if info.frFS and info.frFMT then
        kServerInfo:setActivityStatus(info.frFS)
        kServerInfo:setActivityContent(info.frFMT)        
    end		
end

function GlobalDataProcesser.repClubRefreshUI(cmd, info)
    info = checktable(info)
    kSystemConfig:setClubConfig(info)    
end

function GlobalDataProcesser.recOwnerClubInfo(cmd, info)
    Log.i("---------GlobalDataProcesser----------recOwnerClubInfo",info)
    info = checktable(info)
    kSystemConfig:updateOwnClubInfo(info)
end

function GlobalDataProcesser.recJoinedClubInfo(cmd, info)
    Log.i("---------GlobalDataProcesser----------recJoinedClubInfo",info)
    info = checktable(info)
    info.clCI = checktable(info.clCI)
    kSystemConfig:updateJoinedClubInfo(info.clCI)
end

-- ##  clI  long  亲友圈Id
-- ##  clN  String  亲友圈名称
-- ##  apD  String  申请时间
-- ##  apT  String  申请类型（1加入 2退出）
-- ##  apS  String  申请状态（1已通过 2已拒绝 3审核中）
function GlobalDataProcesser.recClubApplyList(cmd, info)
    info = checktable(info)
    info.usAI = checktable(info.usAI)
    for i,v in ipairs(info.usAI) do
        v.clubID = v.clI
        v.clubName = v.clN
        v.applyTime = v.apD
        v.applyType = v.apT
        v.applyState = v.apS
    end
end

function GlobalDataProcesser.recvRecordData(cmd, info)
    local recordData = checktable(info)
    if type(recordData.li) == "table" then
        for _,data in ipairs(recordData.li) do
            if type(data.wiI) ~= "table" then
                data.wiI = {data.wiI}
            end
        end
    end
end

function GlobalDataProcesser.recvRedPoint(cmd, info)
    local recordData = checktable(info)
    if info.ty == 3 then --亲友圈申请信息
        kSystemConfig:setClubApplyChanged(true)
    end
end

function GlobalDataProcesser.recvServerNotify(cmd, info)
    local serverData = checktable(info)
    -- dump(serverData)
    local enable = serverData.en -- 是否启用提示
    if enable ~= nil then
        local serverNotifyData = serverData.js
        if serverNotifyData then
            local data = json.decode(serverNotifyData)
            -- dump(data)
            kServerInfo:setServerNotifyData(data, not enable)
        end
    end
end

GlobalDataProcesser.s_severCmdEventFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_INFO] = GlobalDataProcesser.onRepYaoingInfo;
    [HallSocketCmd.CODE_REC_HALL_REFRESH_UI] = GlobalDataProcesser.repHallRefreshUI;
    [HallSocketCmd.CODE_REC_CLUB_REFRESH_UI]  = GlobalDataProcesser.repClubRefreshUI;    

    --亲友圈部分
    [HallSocketCmd.CODE_REC_QUERYCLUBINFO] = GlobalDataProcesser.recOwnerClubInfo;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]     = GlobalDataProcesser.recJoinedClubInfo;
    [HallSocketCmd.CODE_REC_CLUBAPPLYLIST]     = GlobalDataProcesser.recClubApplyList;

    --战绩对wiI进行一次兼容处理
    [HallSocketCmd.CODE_RECV_RECORD_INFO]    = GlobalDataProcesser.recvRecordData;
    [HallSocketCmd.CODE_REC_REDPOINT]    = GlobalDataProcesser.recvRedPoint;
    [HallSocketCmd.CODE_REC_SERVER_NOTIFY]    = GlobalDataProcesser.recvServerNotify;
};

return GlobalDataProcesser
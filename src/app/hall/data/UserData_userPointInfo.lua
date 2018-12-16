--玩家账户数据

UserData_userPointInfo = class("UserData_userPointInfo", UserData_base);

UserData_userPointInfo.getInstance = function()
    if not UserData_userPointInfo.s_instance then
        UserData_userPointInfo.s_instance = UserData_userPointInfo.new();
    end

    return UserData_userPointInfo.s_instance;
end

UserData_userPointInfo.releaseInstance = function()
    if UserData_userPointInfo.s_instance then
        UserData_userPointInfo.s_instance:dtor();
    end
    UserData_userPointInfo.s_instance = nil;
end

--用户数据同步
function UserData_userPointInfo:syncData(code, info)
    if code == CODE_TYPE_INSERT then
        for k, v in pairs(info) do
            self.m_userData[v.keyID] = v;
        end
    elseif code == CODE_TYPE_UPDATE then
        for k, v in pairs(info) do
            local data = self.m_userData[v.keyID];
            if data then
                for k1, v1 in pairs(v) do
                    if k1 == "privateRoomDiamond" then
                        data["privateRoomDiamond_change"] = v1 - data[k1];
                    end

                    if k1 == "paper" then
                        data["paper_change"] = v1 - data[k1];
                    end

                    data[k1] = v1;
                end
            end
        end
    elseif code == CODE_TYPE_DELETE then
        for k, v in pairs(info) do
            if self.m_userData[v.keyID] then
                self.m_userData[v.keyID] = nil;
            end
        end
    end
end

function UserData_userPointInfo:ctor()
    self.super.ctor(self);
end

function UserData_userPointInfo:dtor()

end

kUserData_userPointInfo = UserData_userPointInfo.getInstance();
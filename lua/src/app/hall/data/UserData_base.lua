--玩家数据

UserData_base = class("UserData_base");

function UserData_base:ctor()
    self.m_userData = {};
end

function UserData_base:release()
    self.m_userData = {};
end

function UserData_base:dtor()

end

--用户数据同步
function UserData_base:syncData(code, info)
    if code == CODE_TYPE_INSERT then
        for k, v in pairs(info) do
            self.m_userData[v.keyID] = v;
        end
    elseif code == CODE_TYPE_UPDATE then
        for k, v in pairs(info) do
            local data = self.m_userData[v.keyID];
            if data then
                for k1, v1 in pairs(v) do
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

--获取用户数据
function UserData_base:getUserData()
    return self.m_userData;
end

--获取一条用户数据
function UserData_base:getUserDataByKeyID(keyID)
    return self.m_userData[keyID .. ""];
end
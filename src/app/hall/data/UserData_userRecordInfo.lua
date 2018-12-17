--玩家对战记录数据

UserData_userRecordInfo = class("UserData_userRecordInfo", UserData_base);

UserData_userRecordInfo.getInstance = function()
    if not UserData_userRecordInfo.s_instance then
        UserData_userRecordInfo.s_instance = UserData_userRecordInfo.new();
    end

    return UserData_userRecordInfo.s_instance;
end

UserData_userRecordInfo.releaseInstance = function()
    if UserData_userRecordInfo.s_instance then
        UserData_userRecordInfo.s_instance:dtor();
    end
    UserData_userRecordInfo.s_instance = nil;
end

function UserData_userRecordInfo:ctor()
    self.super.ctor(self);
end

function UserData_userRecordInfo:dtor()

end

kUserData_userRecordInfo = UserData_userRecordInfo.getInstance();
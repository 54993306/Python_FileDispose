--玩家数据

UserData_userInfo = class("UserData_userInfo", UserData_base);

UserData_userInfo.getInstance = function()
    if not UserData_userInfo.s_instance then
        UserData_userInfo.s_instance = UserData_userInfo.new();
    end

    return UserData_userInfo.s_instance;
end

UserData_userInfo.releaseInstance = function()
    if UserData_userInfo.s_instance then
        UserData_userInfo.s_instance:dtor();
    end
    UserData_userInfo.s_instance = nil;
end

function UserData_userInfo:ctor()
    self.super.ctor(self);
end

function UserData_userInfo:dtor()

end

kUserData_userInfo = UserData_userInfo.getInstance();
--消息基本数据

MsgData_baseInfo = class("MsgData_baseInfo", UserData_base);

MsgData_baseInfo.getInstance = function()
    if not MsgData_baseInfo.s_instance then
        MsgData_baseInfo.s_instance = MsgData_baseInfo.new();
    end

    return MsgData_baseInfo.s_instance;
end

MsgData_baseInfo.releaseInstance = function()
    if MsgData_baseInfo.s_instance then
        MsgData_baseInfo.s_instance:dtor();
    end
    MsgData_baseInfo.s_instance = nil;
end

function MsgData_baseInfo:ctor()
    self.super.ctor(self);
end

function MsgData_baseInfo:dtor()

end

kMsgData_baseInfo = MsgData_baseInfo.getInstance();
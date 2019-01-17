--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2019-01-14 11:42:15
]]
local BindSuccessful = class("BindSuccessful",UIWndBase)

function BindSuccessful:ctor(data)
    -- body
    self.super.ctor(self, "hall/bindSuccessful_dialog.csb",data)
end

function BindSuccessful:onInit()
    -- body
    self.pan_bind_succesful = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_bind_succesful")
    self.pan_change_in = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_change_in")
    self.pan_busy_system = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_busy_system")
    self.pan_public_tips = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_public_tips")

    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_return")
    self.btn_close:addTouchEventListener(handler(self,self.closeCallBack))

    if self.m_data.type == 1 then
        self:bindPhoneSuccesFul()
    elseif self.m_data.type == 2 then
        self:changeIn()
    elseif self.m_data.type == 3 then
        self:publicYips()
    end
end

--提示绑定手机成功
function BindSuccessful:bindPhoneSuccesFul()
    self.pan_bind_succesful:setVisible(true)
    self.pan_change_in:setVisible(false)
    self.pan_busy_system:setVisible(false)
    self.pan_public_tips:setVisible(false)

    local btn_determine = ccui.Helper:seekWidgetByName(self.pan_bind_succesful,"btn_determine")
    local function callBack(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            self:changeIn()
        end
    end
    btn_determine:addTouchEventListener(callBack)
end

--提示兑换中
function BindSuccessful:changeIn()
    -- body
    self.pan_bind_succesful:setVisible(false)
    self.pan_change_in:setVisible(true)
    self.pan_busy_system:setVisible(false)
    self.pan_public_tips:setVisible(false)

    local image_rota = ccui.Helper:seekWidgetByName(self.pan_change_in,"Image_rota")
    local image_hourglass = ccui.Helper:seekWidgetByName(self.pan_change_in,"Image_ hourglass")
    local label_time = ccui.Helper:seekWidgetByName(self.pan_change_in,"Label_time")
    math.randomseed(os.time())
    local runTime = math.random(2,6)
    local function downTime()
        label_time:setString(string.format( "%s秒",runTime))
        if runTime <= 0 then
            self:busySystem()
            return
        end
        runTime = runTime - 1
        local rota = cc.RotateBy:create(1,90)
        image_rota:runAction(rota)
        local hourRota = cc.RotateBy:create(0.3,180)
        image_hourglass:runAction(hourRota)
        local cf = cc.CallFunc:create(downTime)
        local dt = cc.DelayTime:create(1)
        label_time:runAction(cc.Sequence:create(dt,cf))
    end
    downTime()

end

--提示话费兑换繁忙
function BindSuccessful:busySystem( )
    -- body
    self.pan_bind_succesful:setVisible(false)
    self.pan_change_in:setVisible(false)
    self.pan_busy_system:setVisible(true)
    self.pan_public_tips:setVisible(false)

    local btn_determine = ccui.Helper:seekWidgetByName(self.pan_busy_system,"btn_determine")
    local function callBack(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            UIManager:getInstance():popWnd(BindSuccessful)
            LoadingView.getInstance():show("奖品兑换中...")
            local data = {}
            data.goI = self.m_data.goI   -- 给服务器发送的数据都要以json格式进行传输
            SocketManager:getInstance():send(CODE_TYPE_MALL,HallSocketCmd.CODE_SEND_EXCHANGE,data)
        end
    end
    btn_determine:addTouchEventListener(callBack)
end

--提示兑换公众号
function BindSuccessful:publicYips()
    -- body
    self.pan_bind_succesful:setVisible(false)
    self.pan_change_in:setVisible(false)
    self.pan_busy_system:setVisible(false)
    self.pan_public_tips:setVisible(true)
    -- UIManager:getInstance():popWnd(BindSuccessful)
    -- self.m_data.yesCallback()
    Log.i("data.....",self.m_data)
    local contentStr = string.format( "您的红包兑换码为:%s，一键前往公众号:%s，输入兑换码领取红包",self.m_data.re1.co,_OFFICIALWECHAT) 
    local txt_content = ccui.Helper:seekWidgetByName(self.pan_public_tips,"txt_content")
    txt_content:setString(contentStr)
    local btn_yes = ccui.Helper:seekWidgetByName(self.pan_public_tips,"btn_yes")
    btn_yes:addTouchEventListener(function()
        local data = {};
        data.cmd = NativeCall.CMD_CLIPBOARD_COPY;
        data.content  = string.format("%s",self.m_data.re1.co)--
        Log.i("copy code:" .. data.content)
        NativeCall.getInstance():callNative(data);
        UIManager:getInstance():popWnd(BindSuccessful)
    end)

    local btn_cancal = ccui.Helper:seekWidgetByName(self.pan_public_tips,"btn_cancal")
    btn_cancal:addTouchEventListener(function() UIManager:getInstance():popWnd(BindSuccessful) end)
end

function BindSuccessful:closeCallBack(pWidget, EventType)
    -- body
    if EventType == ccui.TouchEventType.ended then
        UIManager:getInstance():popWnd(BindSuccessful)
    end
end

return BindSuccessful
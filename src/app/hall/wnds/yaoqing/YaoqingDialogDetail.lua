YaoqingDialogDetail = class("YaoqingDialogDetail", UIWndBase)

function YaoqingDialogDetail:ctor(pNum)
    self.super.ctor(self, "hall/yaoqing.csb",pNum);
    self.m_socketProcesser = YaoqingSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function YaoqingDialogDetail:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function YaoqingDialogDetail:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_yaoqing = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share");
    self.btn_yaoqing:addTouchEventListener(handler(self, self.onClickButton));

    self.lb_des = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_des");
    self.lb_des:setString(string.format("填写邀请人ID即可获得%d钻石",self.m_data))

    self.lb_content = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_content");
    self.lb_content:setString(string.format("钻石x%d",self.m_data))

    self.tf_id = self:getWidget(self.m_pWidget, "tf_id");
end

function YaoqingDialogDetail:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_yaoqing then
            local account = self.tf_id:getText();
            if not account then
                Toast.getInstance():show("无效ID，请重新输入");
                return;
            elseif string.len(account) < 6 then
                Toast.getInstance():show("无效ID，请重新输入");
                return;
            else
                local len = string.len(account);
                local wAccount = string.match(account, "%w+")
                if not wAccount or len ~= string.len(wAccount) then
                    Toast.getInstance():show("无效ID，请重新输入");
                else
                    local data = {};
                    data.inI = tonumber(account);
                    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_YAOQING_ID, data);
                    LoadingView.getInstance():show();
                end
            end
        end
    end
end

function YaoqingDialogDetail:onRepYaoingResult(info)
    LoadingView.getInstance():hide();
    --0:操作成功，获得XX钻石  1:邀请人已达邀请上限哦  2:无效ID，请重新输入  3:已经设置过邀请人 4:对方设置过自己为邀请人，自己不能再设置对方为邀请人
    if info.re == 0 then
        UIManager.getInstance():popToWnd(FreeShareDialog);
    elseif info.re == 1 then
        Toast.getInstance():show("邀请人已达邀请上限哦");
    elseif info.re == 2 then
        Toast.getInstance():show("无效ID，请重新输入");
    elseif info.re == 3 then
        Toast.getInstance():show("已经设置过邀请人");
    elseif info.re == 4 then
        Toast.getInstance():show("对方设置您为邀请人,互设为邀请人无效");
    end
end

YaoqingDialogDetail.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_ID] = YaoqingDialogDetail.onRepYaoingResult;
};
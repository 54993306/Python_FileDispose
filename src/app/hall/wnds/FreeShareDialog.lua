FreeShareDialog = class("FreeShareDialog", UIWndBase)

function FreeShareDialog:ctor()
    self.super.ctor(self, "hall/share_diamond.csb")
    self.m_socketProcesser = YaoqingSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function FreeShareDialog:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function FreeShareDialog:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_share1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share1");
    self.btn_share1:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_share2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_share2");
    self.btn_share2:addTouchEventListener(handler(self, self.onClickButton))
    self.redBox = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_blink");

    self:initLogAnimation()

    self:freeEffect()
end

function FreeShareDialog:initLogAnimation()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/main/armature/FreeAnimation.csb")
    local armature = ccs.Armature:create("FreeAnimation")
    armature:getAnimation():play("FREE1")
    local _t = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn1");
    _t:setVisible(false)
    armature:setPosition(cc.p(_t:getPositionX()+30,_t:getPositionY()-40))
    _t:getParent():addChild(armature)

    local armature2 = ccs.Armature:create("FreeAnimation")
    armature2:getAnimation():play("FREE2")
    local _t2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn2");
    _t2:setVisible(false)
    armature2:setPosition(cc.p(_t2:getPositionX(),_t2:getPositionY()-40))
    _t2:getParent():addChild(armature2)
end

function FreeShareDialog:freeEffect()
    local shareGiftInfo = kGiftData_logicInfo:getShareGift();
    if shareGiftInfo then
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(kUserInfo:getUserId() .. "-" .. shareGiftInfo.Id);
        if userGiftInfo and userGiftInfo.status ~= 2 then    --  ==2 的情况是表示任务完成
            
            self.redBox:runAction(cca.repeatForever(cca.blink(4,5)))
        else
            self.redBox:stopAllActions()
            self.redBox:setVisible(false)
        end
    end
end

function FreeShareDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self:keyBack()
        elseif pWidget == self.btn_share1 then
            UIManager:getInstance():pushWnd(FreeShareDialogDetail);
        elseif pWidget == self.btn_share2 then
            -- Toast.getInstance():show("功能暂时未开放");
            local data = {};
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_YAOQING_INFO, data);
            LoadingView.getInstance():show();
        end
    end
end

function FreeShareDialog:keyBack()
    UIManager:getInstance():popWnd(FreeShareDialog)
end

function FreeShareDialog:onRepYaoingInfo(info)
    LoadingView.getInstance():hide();
    info = checktable(info)
    if #(info["reL"]) <= 0 then
        Toast.getInstance():show("服务器数据为空");
        return
    end
    UIManager:getInstance():pushWnd(YaoqingDialog, info);
end

FreeShareDialog.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_RECV_YAOQING_INFO] = FreeShareDialog.onRepYaoingInfo;
};
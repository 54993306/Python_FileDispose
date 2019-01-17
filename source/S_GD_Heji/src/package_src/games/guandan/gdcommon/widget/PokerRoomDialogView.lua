--提示界面

--使用方法
-- local data = {}
-- data.type = 1                              --对话框类型：1,一个"确定"按钮  2，一个“取消”按钮和一个“确定”按钮
-- data.title = "提示"                        --对话框标题
-- data.content = "提示内容"                  --对话框提示内容
-- data.yesCallback                           --确定按钮回调
-- data.cancelCallback                        --取消按钮回调
-- data.cancelTitlePath                           --取消按钮标题路径
-- data.yesTitlePath                              --确定按钮标题路径
-- data.cancelTitle                            --关闭按钮标题
-- data.autoCloseTime                         --自动关闭时间
-- data.canKeyBack                            --能按物理返回键关闭

local PokerRoomDialogView = class("PokerRoomDialogView", PokerUIWndBase);
local dialogViewPath ="package_src.games.guandan.gdcommon.widget.PokerRoomDialogView"
PokerRoomDialogView.POKERDIALOGTYPE=
{
    ONLYCERTAIN      = 1,--1,一个"确定"按钮
    CERTAINANDCANCEL = 2,--2，一个“取消”按钮和一个“确定”按钮
}

function PokerRoomDialogView:ctor(data, zOrder, delegate)
    if not zOrder then
        zOrder = 101
    end
    self.super.ctor(self,"package_res/games/guandan/tip_view.csb", data, zOrder, delegate);
end

--获取内容类型
function PokerRoomDialogView:getContentType()
    return self.m_data.contentType;
end

function PokerRoomDialogView:onInit()
    self.cancelTitlePath = self.m_data.cancelTitlePath or "btn/btn_cancel.png"
    self.btn_cancel = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_cancel")
    self.btn_cancel:addTouchEventListener(handler(self,self.onClickButton))
    ccui.Helper:seekWidgetByName(self.btn_cancel,"image"):loadTexture(self.cancelTitlePath, self.m_data.cancelTitlePathType or ccui.TextureResType.plistType)
    
    self.certainTitlePath = self.m_data.yesTitlePath or "btn/btn_certain.png"
    self.btn_certain = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_certain")
    self.btn_certain:addTouchEventListener(handler(self,self.onClickButton))
    ccui.Helper:seekWidgetByName(self.btn_certain,"image"):loadTexture(self.certainTitlePath, self.m_data.yesTitlePathType or ccui.TextureResType.plistType)

    self.content = ccui.Helper:seekWidgetByName(self.m_pWidget,"lbl_content")
    self.content:setString(self.m_data.content)

    if self.m_data.type and self.m_data.type == 1 then
        self.btn_cancel:setVisible(false)
        self.btn_certain:setPositionX(ccui.Helper:seekWidgetByName(self.m_pWidget,"bg"):getContentSize().width/2)
    end

    if self.m_data.autoCloseTime and self.m_data.autoCloseTime > 0 then
        self.m_pWidget:performWithDelay(function()
            self:onClickButton(self.btn_close, ccui.TouchEventType.ended);
        end, self.m_data.autoCloseTime)
    end
end

function PokerRoomDialogView:onShow()
end

function PokerRoomDialogView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        self:keyBack();
        if pWidget == self.btn_cancel then
            if self.m_data.cancelCallback then
                self.m_data.cancelCallback()
            end
        elseif pWidget == self.btn_certain then
            if self.m_data.yesCallback then
                self.m_data.yesCallback()
            end
        end
    end
end

function PokerRoomDialogView:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

return PokerRoomDialogView
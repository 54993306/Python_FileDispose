--
--新手提示
--

NewerTipsWnd1 = class("NewerTipsWnd1", UIWndBase)

function NewerTipsWnd1:ctor(data, zorder)
    self.super.ctor(self, "hall/newer_dialog1.csb", data, zorder);
end

function NewerTipsWnd1:onInit()
    --关闭                             
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_back");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
    --下一页                             
    self.btn_next = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_next");
    self.btn_next:addTouchEventListener(handler(self, self.onClickButton));
    --下一页                             
    self.btn_next1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_next1");
    self.btn_next1:addTouchEventListener(handler(self, self.onClickButton));
    --上一页                           
    self.btn_last = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_last");
    self.btn_last:addTouchEventListener(handler(self, self.onClickButton));
    --
    self.img_content = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_content");
    --
    self.m_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.content = ccui.Helper:seekWidgetByName(self.m_pWidget, "content");
    --
    if self.m_data.isBack then
        self.m_index = 6;
    else
        self.m_index = 1;
    end
    self:updateCotent();
end

function NewerTipsWnd1:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_close then
            self.m_root:setBackGroundColorOpacity(0);
            transition.scaleTo(self.content, {scale = 0, 
                time = 0.4,
                onComplete = function ()
                    self.content:setVisible(false);
                    UIManager.getInstance():popWnd(self);
                end});
            transition.moveTo(self.content, {
                x = display.width - 380,
                y = display.height * 0.82, 
                time = 0.4});
        elseif pWidget == self.btn_next or pWidget == self.btn_next1 then
            self.m_index = self.m_index + 1;
            self:updateCotent();
        elseif pWidget == self.btn_last then
            self.m_index = self.m_index - 1;
            self:updateCotent();
        end
    end
end

function NewerTipsWnd1:updateCotent()
    if self.m_index == 1 then
        self.btn_next:setVisible(true);
        self.btn_next1:setVisible(false);
        self.btn_last:setVisible(false);
    elseif self.m_index >= 2 and self.m_index <= 6 then
        self.btn_next:setVisible(false);
        self.btn_next1:setVisible(true);
        self.btn_last:setVisible(true);
    elseif self.m_index == 7 then
        UIManager.getInstance():popWnd(self);
        UIManager.getInstance():pushWnd(NewerTipsWnd2);
        return;
    end
    self.img_content:loadTexture("games/" .. _gameType .. "/hall/newer/tip_" .. self.m_index .. ".png");
end

--返回
function NewerTipsWnd1:keyBack()
    
end
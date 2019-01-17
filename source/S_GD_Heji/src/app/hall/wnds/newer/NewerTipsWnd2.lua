--
--新手提示
--

NewerTipsWnd2 = class("NewerTipsWnd2", UIWndBase)

function NewerTipsWnd2:ctor(data, zorder)
    self.super.ctor(self, "hall/newer_dialog2.csb", data, zorder);
end

function NewerTipsWnd2:onInit()
    --关闭                             
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_back");
    self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
    --下一页                             
    self.btn_next1 = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_next1");
    self.btn_next1:addTouchEventListener(handler(self, self.onClickButton));
    --上一页                           
    self.btn_last = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_last");
    self.btn_last:addTouchEventListener(handler(self, self.onClickButton));
    --
    self.img_content = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_content");

    self.m_root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.content = ccui.Helper:seekWidgetByName(self.m_pWidget, "content");
    --
    self.m_index = 7;
    self:updateCotent();
end

function NewerTipsWnd2:onClickButton(pWidget, EventType)
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
                y = display.height * 0.84, 
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

function NewerTipsWnd2:updateCotent()
    if self.m_index == 8 then
        UIManager.getInstance():popWnd(self);
        UIManager.getInstance():pushWnd(NewerTipsWnd);
        return;
    elseif self.m_index == 6 then
        UIManager.getInstance():popWnd(self);
        local data = {};
        data.isBack = true;
        UIManager.getInstance():pushWnd(NewerTipsWnd1, data);
        return;
    end
    self.img_content:loadTexture("games/" .. _gameType .. "/hall/newer/tip_" .. self.m_index .. ".png");
end

--返回
function NewerTipsWnd2:keyBack()
    
end
--聊天界面

RoomChatView = class("RoomChatView", UIWndBase);
local UmengClickEvent = require("app.common.UmengClickEvent")

function RoomChatView:ctor(data, zorder, delegate)
    self.super.ctor(self, "hall/chat.csb", data, zorder, delegate);
end

function RoomChatView:onInit()
    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));

--    self.btn_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_txt");
--    self.btn_txt:addTouchEventListener(handler(self, self.onClickButton));

--    self.btn_face = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_face");
--    self.btn_face:addTouchEventListener(handler(self, self.onClickButton));
    if device.platform ~= "ios" then
        self.tf_chat = self:getWidget(self.m_pWidget, "tf_chat");
    else
        self.tf_chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "tf_chat");
    end


    self.btn_send = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_send");
    self.btn_send:addTouchEventListener(handler(self, self.onClickButton));

    local pan_edit = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_edit");
    pan_edit:setVisible(true);

    --初始化聊天内容
    if self.m_delegate and self.m_delegate.init_gameChatCfg then
        self.m_delegate:init_gameChatCfg();
    end

    self.lis_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_txt");
     self.lis_txt:setVisible(true)
    local mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/chat_txt_item.csb");
    for k, v in pairs(_gameChatTxtCfg) do
        if IsPortrait then -- TODO
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChat..k)
        end
        local item = self.lis_txt:getItem(k -1);
        if item == nil then
            item = mItem:clone();
            self.lis_txt:pushBackCustomItem(item);
        end
        local lb_txt = ccui.Helper:seekWidgetByName(item, "lb_txt");
        --lb_txt:setFontName("font/bold.ttf");
        lb_txt:setString(v);

        local img_bg = ccui.Helper:seekWidgetByName(item, "img_bg");
        if k%2 == 1 then
            img_bg:loadTexture("games/ddz/common/blank.png");
        end
        img_bg:setTag(k);
        img_bg:setTouchEnabled(true);
        img_bg:addTouchEventListener(handler(self, self.onClickChatText));

    end

    self.lis_face = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_face");
    self.lis_face:setVisible(true);

    local lineModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    lineModel:setContentSize(cc.size(492, 123));
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/face_item.csb")
    local num = 23;
    for index = 0, num do
        local line = self.lis_face:getItem(index/4);
        if not line then
            line = lineModel:clone();
            self.lis_face:pushBackCustomItem(line);
        end
        local col = index%4;
        local item = line:getChildByTag(col);
        if item == nil then
            item = itemModel:clone();
            line:addChild(item, 0, col);
            item:setPosition(col * 123, 0);
        end
        local btn_face = ccui.Helper:seekWidgetByName(item, "btn_face");
        btn_face:setTag(index + 1);
        btn_face:addTouchEventListener(handler(self, self.onClickChatFace));

        btn_face:loadTextureNormal("hall/gameCommon/face/face_" .. (index + 1) .. ".png");
    end
end

function RoomChatView:onShow()

end

function RoomChatView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.root then
            self:keyBack();
--        elseif pWidget == self.btn_txt then
--            self.lis_txt:setVisible(true);
--            self.lis_face:setVisible(false);
--        elseif pWidget == self.btn_face then
--            self.lis_txt:setVisible(false);
--            self.lis_face:setVisible(true);
        elseif pWidget == self.btn_send then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatSend)

            local content = nil;
            if device.platform ~= "ios" then
                content = self.tf_chat:getText();
            else
                content = self.tf_chat:getString().." ";
            end
            Log.i("聊天内容....",content)
            if content and content ~= "" then
                if self.m_delegate and self.m_delegate.sendUserChat then
                    self.m_delegate:sendUserChat(content);
                end

                self:keyBack();
            else
                Toast.getInstance():show("请输入聊天内容");
            end
        end;
    end
end
function RoomChatView:onClose()
    local data = {};
    data.cmd = NativeCall.CMD_CLOSEEDITBOX;
    NativeCall.getInstance():callNative(data);
end
function RoomChatView:onClickChatText(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        local index = pWidget:getTag();
        if self.m_delegate and self.m_delegate.sendDefaultChat then
            self.m_delegate:sendDefaultChat(2, index);
        end
        self:keyBack();
    end
end

function RoomChatView:onClickChatFace(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        local index = pWidget:getTag();
        content = "face_"..index
        if IsPortrait then -- TODO
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatFace .. index)
        end
--        if self.m_delegate and self.m_delegate.sendDefaultChat then
--            self.m_delegate:sendDefaultChat(1, index);
--        end
        Log.i("表情....",content)
        if content and content ~= "" then
            if self.m_delegate and self.m_delegate.sendUserChat then
                self.m_delegate:sendUserChat(content);
            end
            self:keyBack();
        else
            Toast.getInstance():show("请输入聊天内容");
        end
    end
end
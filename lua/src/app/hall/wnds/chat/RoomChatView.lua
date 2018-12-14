--聊天界面

RoomChatView = class("RoomChatView", UIWndBase);
local UmengClickEvent = require("app.common.UmengClickEvent")

local face_pic_list = {
    [1] = 2,
    [2] = 6,
    [3] = 11,
    [4] = 1,
    [5] = 12,
}

function RoomChatView:ctor(data, zorder, delegate)
    self.roomData =kFriendRoomInfo:getRoomInfo()
    if IsPortrait then -- TODO
        self.super.ctor(self, "hall/chat.csb", data, zorder, delegate);
    else
        if self.roomData.gaID == 20009 or self.roomData.gaID ==  20010 then
            -- 如果为斗地主，加载斗地主的聊天界面
            self.super.ctor(self, "package_res/games/pokercommon/chat_view2.csb", data, zorder, delegate);
        else
            self.super.ctor(self, "hall/chat.csb", data, zorder, delegate);
        end   
    end
end

function RoomChatView:setTextFieldToEditBox(textfield)
    -- print("hahahahahah555")
    local tfS = textfield:getContentSize()
    local parent = textfield:getParent()
    local tfPosX = textfield:getPositionX()
    local tfPosY = textfield:getPositionY()
    local tfPH = textfield:getPlaceHolder()
    local anchor = textfield:getAnchorPoint()
    local zorder = textfield:getLocalZOrder()
    local tfColor = textfield:getColor()
    local ispe = textfield:isPasswordEnabled()
    local tfFS = textfield:getFontSize()
    local ftMaxLength = 0
    if textfield:isMaxLengthEnabled() then
        ftMaxLength = textfield:getMaxLength()
    end
    local function onEdit(event, editbox)
        if event == "began" then
            -- 开始输入
            Log.i("began778899")
            if IsPortrait then -- TODO
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatText)
            end

            local function setItemsTouchDisable()
                for k,v in pairs(self.lis_txt:getItems()) do
                -- print("disable ",k)
                local item = v --self.lis_txt:getItem(1)
                if item == nil then
                    -- print("ghghghg------item is null!-------")
                else
                    local img_bg = ccui.Helper:seekWidgetByName(item, "img_bg")
                    img_bg:setTouchEnabled(false)
                end
                end

                local num = 15;
                for index = 0, num do
                    local line = self.lis_face:getItem(index/4);
                    if not line then
                        break
                    end
                    local col = index%4;
                    local item = line:getChildByTag(col);
                    if item == nil or not item:isVisible() then
                        break
                    end
                    local btn_face = ccui.Helper:seekWidgetByName(item, "btn_face");
                    btn_face:setTouchEnabled(false)
                end

                --self.root:setTouchEnabled(false)
                self.onEditing = true
            end
            setItemsTouchDisable()

        elseif event == "changed" then
            Log.i("changed778899")
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            Log.i("ended778899")
        elseif event == "return" then
            -- 从输入框返回
            Log.i("return778899")

            local function setItemsTouchEnable()
                for k,v in pairs(self.lis_txt:getItems()) do
                    -- print("enable ",k)
                    local item = v
                    if item == nil then
                        -- print("ghghghg------item is null!-------")
                    else
                        local img_bg = ccui.Helper:seekWidgetByName(item, "img_bg")
                        img_bg:setTouchEnabled(true)
                    end
                end

                local num = 15;
                for index = 0, num do
                    local line = self.lis_face:getItem(index/4);
                    if not line then
                        break
                    end
                    local col = index%4;
                    local item = line:getChildByTag(col);
                    if item == nil or not item:isVisible() then
                        break
                    end
                    local btn_face = ccui.Helper:seekWidgetByName(item, "btn_face");
                    btn_face:setTouchEnabled(true)
                end
                --self.root:setTouchEnabled(true)
                self.onEditing = false
            end

            self.lis_txt:performWithDelay(setItemsTouchEnable, 0.2)
            
        end
    end
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "hall/Common/blank.png",
        listener = onEdit,
        size = tfS
    })
--    local imageNormal = display.newScale9Sprite("hall/Common/blank.png")

--    local editbox = ccui.EditBox:create(cc.size(tfS.width,tfS.height), imageNormal)
    editbox:setContentSize(tfS)
    editbox:setName(tfName)
    editbox:setPosition(cc.p(tfPosX,tfPosY))
    editbox:setPlaceHolder(tfPH)
    editbox:setFontName("hall/font/bold.ttf")
    editbox:setPlaceholderFontColor(cc.c3b(128,128,128))
    editbox:setAnchorPoint(cc.p(anchor.x,anchor.y))
    editbox:setLocalZOrder(zorder)
    editbox:setFontColor(tfColor)
    editbox:setFontSize(tfFS)

    if ftMaxLength ~= 0 then
        editbox:setMaxLength(ftMaxLength)
    end
    if ispe then
        editbox:setInputFlag(0)
    end
    parent:removeChild(textfield,true)
    parent:addChild(editbox)

    return editbox
end

function RoomChatView:onInit()
    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget, "root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));

--    self.btn_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_txt");
--    self.btn_txt:addTouchEventListener(handler(self, self.onClickButton));

--    self.btn_face = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_face");
--    self.btn_face:addTouchEventListener(handler(self, self.onClickButton));
    -- if device.platform ~= "ios" then
        self.tf_chat = self:getWidget(self.m_pWidget, "tf_chat");
    -- else
    --     self.tf_chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "tf_chat");
    -- end


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
    if not IsPortrait then -- TODO
        if self.roomData.gaID == 20009 or self.roomData.gaID == 20010 then
            -- 如果为斗地主，加载斗地主的聊天界面
            mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/chat_txt_item.csb");
        end
    end
    local itemIndex = 0
    if not IsPortrait then -- TODO
        _gameChatTxtCfg = nil 
        MjProxy:getInstance():get_gameChatTxtCfg()
        if self.roomData.gaID == 20009 then
            MjProxy:getInstance():get_gameChatTxtCfg2()
        elseif self.roomData.gaID == 20010 then
            MjProxy:getInstance():get_gameChatTxtCfg3()
        else
            MjProxy:getInstance():get_gameChatTxtCfg()
        end
    end
    Log.i("--wangzhi--_gameChatTxtCfg",_gameChatTxtCfg)
    for i,v in ipairs(_gameChatTxtCfg) do
        if string.len(v) > 1 then
            local item = self.lis_txt:getItem(itemIndex);
            itemIndex = itemIndex + 1
            if item == nil then
                item = mItem:clone();
                self.lis_txt:pushBackCustomItem(item);
            end
            local lb_txt = ccui.Helper:seekWidgetByName(item, "lb_txt");
            if not IsPortrait then -- TODO
                if self.roomData.gaID ==20009 or self.roomData.gaID ==20010 then
                    lb_txt = ccui.Helper:seekWidgetByName(item, "lbl_txt");
                end
            end
            
            --lb_txt:setFontName("font/bold.ttf");
            lb_txt:setString(ToolKit.subUtfStrByCn(v, 0, 17, "..."));

            local img_bg = ccui.Helper:seekWidgetByName(item, "img_bg");
            img_bg:setTag(i);
            img_bg:setTouchEnabled(true);
            img_bg:addTouchEventListener(handler(self, self.onClickChatText))
        end
    end

    self.lis_face = ccui.Helper:seekWidgetByName(self.m_pWidget, "lis_face");
    self.lis_face:setVisible(true);

    local lineModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/null_layer.csb");
    lineModel:setContentSize(cc.size(410, 100));
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/face_item.csb")
    local num = 15;
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
            item:setPosition(col * 100, 0);
        end
        local btn_face = ccui.Helper:seekWidgetByName(item, "btn_face");
        if face_pic_list[index + 1] then
            btn_face:setTag(index + 1);
        end
        btn_face:addTouchEventListener(handler(self, self.onClickChatFace));
        if(index >= #face_pic_list) then
            btn_face:setTouchEnabled(false)
        end
        if(index >= #face_pic_list) then
            btn_face:loadTextureNormal("hall/gameCommon/face/face_0.png");
            btn_face:setVisible(false)
        else
            btn_face:loadTextureNormal("hall/gameCommon/face/armature_pic/face_" .. face_pic_list[index + 1] .. ".png");
        end
    end

    self.onEditing = false
end

function RoomChatView:onShow()

end

function RoomChatView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.root then
            if not self.onEditing then
                self:keyBack();
            end
--        elseif pWidget == self.btn_txt then
--            self.lis_txt:setVisible(true);
--            self.lis_face:setVisible(false);
--        elseif pWidget == self.btn_face then
--            self.lis_txt:setVisible(false);
--            self.lis_face:setVisible(true);
        elseif pWidget == self.btn_send then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatSend)
            local content = nil;
            -- if device.platform ~= "ios" then
                content = self.tf_chat:getText().." ";
            -- else
            --     content = self.tf_chat:getString().." ";
            -- end
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
        local UmengKey = index
        for k,v in pairs(face_pic_list) do
            if index == v then
                key = k
            end
        end
        if IsPortrait then -- TODO
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChat..UmengKey)
        else
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatText..UmengKey)
        end
        content = "duanyu_" .. index;
        Log.i("--wangzhi--RoomChatView--content--",content)
        if self.m_delegate and self.m_delegate.sendUserChat then
            self.m_delegate:sendUserChat(content);
        end
        self:keyBack();
    end
end

function RoomChatView:onClickChatFace(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        local index = pWidget:getTag();
        local UmengKey = index
        for k,v in pairs(face_pic_list) do
            if index == v then
                key = k
            end
        end
        NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GameChatFace..UmengKey)
        content = "face_"..face_pic_list[index]
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
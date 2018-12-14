 --聊天界面

 local PokerRoomChatView = class("PokerRoomChatView", PokerUIWndBase);
 local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")
 local PokerUtils =require("package_src.games.pokercommon.commontool.PokerUtils")
 local chatViewPath ="package_src.games.pokercommon.widget.PokerRoomChatView"
 local UmengClickEvent = require("app.common.UmengClickEvent")
 function PokerRoomChatView:ctor(data, zorder, delegate)
     self.super.ctor(self,"package_res/games/pokercommon/chat_view.csb",data);
 end

local tfName = ""
-- function PokerRoomChatView:setTextFieldToEditBox(textfield)
--     local tfS = textfield:getContentSize()
--     local parent = textfield:getParent()
--     local tfPosX = textfield:getPositionX()
--     local tfPosY = textfield:getPositionY()
--     local tfPH = textfield:getPlaceHolder()
--     local anchor = textfield:getAnchorPoint()
--     local zorder = textfield:getLocalZOrder()
--     local tfColor = textfield:getColor()
--     local ispe = textfield:isPasswordEnabled()
--     local tfFS = textfield:getFontSize()
--     local ftMaxLength = 0
--     if textfield:isMaxLengthEnabled() then
--         ftMaxLength = textfield:getMaxLength()
--     end
--    local imageNormal = display.newScale9Sprite("package_res/games/pokercommon/image/bg_1.png")

--        local editbox = cc.ui.UIInput.new({
--         UIInputType = 1,
--         image = imageNormal,
--         listener = onEdit,
--         size = tfS
--     })

--    -- local editbox = ccui.EditBox:create(cc.size(tfS.width,tfS.height), imageNormal)
--     editbox:setContentSize(tfS)
--     editbox:setName(tfName)
--     editbox:setPosition(cc.p(tfPosX,tfPosY))
--     editbox:setPlaceHolder(tfPH)
--     editbox:setFontName("hall/font/bold.ttf")
--     editbox:setPlaceholderFontColor(cc.c3b(128,128,128))
--     editbox:setAnchorPoint(cc.p(anchor.x,anchor.y))
--     editbox:setLocalZOrder(zorder)
--     editbox:setFontColor(tfColor)
--     editbox:setFontSize(tfFS)

--     if ftMaxLength ~= 0 then
--         editbox:setMaxLength(ftMaxLength)
--     end
--     if ispe then
--         editbox:setInputFlag(0)
--     end
--     parent:removeChild(textfield,true)
--     parent:addChild(editbox)

--     return editbox
-- end


function PokerRoomChatView:setTextFieldToEditBox(textfield)

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
            Log.i("began。。。。。。。")
        elseif event == "changed" then
            Log.i("changed。。。。。。。")
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
            Log.i("ended。。。。。。。")
        elseif event == "return" then
            -- 从输入框返回
            Log.i("从输入框返回")
        end
    end
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "hall/Common/blank.png",
        listener = onEdit,
        size = tfS
    })
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

function PokerRoomChatView:onEdit(event,pWidget)
    if event == "began" then
        self.shade_panel:setVisible(true)
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        Log.i("changed","changed");
    elseif event == "ended" then
        -- 输入结束
        --self.shade_panel:setVisible(false)
        --计算输入的字符数
    elseif event == "return" then
        -- 从输入框返回
        transition.execute(self.shade_panel,cc.DelayTime:create(0.2),{onComplete = function( )
            self.shade_panel:setVisible(false)
        end})
    end
end
 
 function PokerRoomChatView:onInit()
     self.root = self:getWidget(self.m_pWidget,"root")
     self.root:addTouchEventListener(handler(self, self.onClickButton));
 
     if device.platform ~= "ios" then
         self.tf_chat = self:getWidget(self.m_pWidget, "tf_chat");
     else
         self.tf_chat = self:getWidget(self.m_pWidget, "tf_chat");
     end
     self.face_pic_list = {
        [1] = 2,
        [2] = 6,
        [3] = 11,
        [4] = 1,
        [5] = 12,
    }
     --内置表情数量
     self.faceCount = #self.face_pic_list - 1
     --每行有多少个表情
     self.faceLineCount = 4
     --表情x偏移
     self.faceOffsetX = 50
     --表情宽度
     self.faceWidth = 100
     --表情每行大
     self.lineSize = cc.size(400,102)

     --没行表情偏移
     self.lineOffy = 105
 
     local txtContainer = self:getWidget(self.m_pWidget,"txtContainer")
     local mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/chat_txt_item.csb")
     local height = txtContainer:getContentSize().height - 67
     local width = txtContainer:getContentSize().width
     Log.i("--wangzhi--self.m_data--",self.m_data)
     -- for k, v in pairs(self.m_data) do
    for i,v in ipairs(self.m_data) do
         local item = mItem:clone();
         local lb_txt = self:getWidget(item, "lbl_txt");
         lb_txt:setString(v.content);
         local img_bg = self:getWidget(item, "img_bg");
        
         item:setPosition(4,height)
         height = height - 70
         txtContainer:addChild(item)
         img_bg:setTag(i);
         img_bg:setTouchEnabled(true);
         img_bg:addTouchEventListener(handler(self, self.onClickChatText));
     end
 
     local faceContainer = self:getWidget(self.m_pWidget,"faceContainer")
     local height1 = faceContainer:getContentSize().height - 50
     local width1 = faceContainer:getContentSize().width
     local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/face_item.csb")
     for index = 0, math.floor(self.faceCount/self.faceLineCount) do
         local line = display.newNode()
         line:setContentSize(self.lineSize)
         for i=1,self.faceLineCount do
             local faceIndex = self.face_pic_list[i+index*self.faceLineCount]
             if faceIndex ~= nil then
                 local face = itemModel:clone()
                 face:setAnchorPoint(cc.p(0.5,0.5))
                 local btn_face = self:getWidget(face,"btn_face")
                 btn_face:setTag(i+index*self.faceLineCount)
                 btn_face:addTouchEventListener(handler(self, self.onClickChatFace))

                 btn_face:loadTextureNormal("hall/gameCommon/face/armature_pic/face_" .. faceIndex .. ".png")
                 --btn_face:loadTextureNormal("common/face_" .. (faceIndex + 1) .. ".png",ccui.TextureResType.plistType)
                 face:setPosition((i-1)*self.faceWidth+self.faceOffsetX,self.lineSize.height/2)
                 line:addChild(face)
             end
         end
         line:setAnchorPoint(cc.p(0.0,0.5))
         line:setPosition(4,height1)
         height1 = height1 - self.lineOffy
         --PokerUtils:debugDraw(line)
         faceContainer:addChild(line)
     end

     self.chat_input = ccui.Helper:seekWidgetByName(self.m_pWidget,"text_input")
     -- self.chat_input = self:setTextFieldToEditBox(self.input)
     -- self.chat_input:registerScriptEditBoxHandler(handler(self,self.onEdit));
     -- if self.chat_input.setInputMode then self.chat_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE) end

     self.btn_send = self:getWidget(self.m_pWidget,"btn_send")
     self.btn_send:addTouchEventListener(handler(self,self.onClickButton))

     self.shade_panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"shade_panel")
 end
 
 function PokerRoomChatView:onShow()
    
 end
 
 function PokerRoomChatView:keyBack()
     PokerUIManager.getInstance():popWnd(self)
 end
 
 function PokerRoomChatView:onClickButton(pWidget, EventType)
     
     if EventType == ccui.TouchEventType.ended then
         kPokerSoundPlayer:playEffect("btn");
         if pWidget == self.btn_send then
             local content = self.chat_input:getString();
             Log.i("content", content)
             if content and content ~= "" then
                local data  = {}
                data.usI    = HallAPI.DataAPI:getUserId()
                data.roI    = HallAPI.DataAPI:getRoomId()
                data.co     = content
                data.ty     = CHATTYPE.CUSTOMCHAT
                data.niN    = HallAPI.DataAPI:getUserName()
                Log.i("dispatchEvent send custom msg")
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,data)
                NativeCallUmengEvent(UmengClickEvent.DDZGameChatSend)
                self:keyBack();
             else
                 HallAPI.ViewAPI:showToast("请输入聊天内容");
             end
         end;
         self:keyBack()
     end
 end
 
 function PokerRoomChatView:onClickChatText(pWidget, EventType)
     if EventType == ccui.TouchEventType.ended then
         Log.i("PokerRoomChatView:onClickChatText ")
         kPokerSoundPlayer:playEffect("btn");
         local index = pWidget:getTag();
         Log.i("--wangzhi--onClickChatText--",index)
         HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT, 2, index)
         NativeCallUmengEvent(UmengClickEvent.DDZGameChat..index)
         self:keyBack();
     end
 end
 
 function PokerRoomChatView:onClickChatFace(pWidget, EventType)
     if EventType == ccui.TouchEventType.ended then
         kPokerSoundPlayer:playEffect("btn");
         local index = pWidget:getTag();
         -- if self.m_delegate and self.m_delegate.sendDefaultChat then
             -- self.m_delegate:sendDefaultChat(1, index);
         -- end
         content =self.face_pic_list[index]
         HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT, 1, content)
         NativeCallUmengEvent(UmengClickEvent.DDZGameChatFace..index)
 
         self:keyBack();
     end
 end
 
 return PokerRoomChatView
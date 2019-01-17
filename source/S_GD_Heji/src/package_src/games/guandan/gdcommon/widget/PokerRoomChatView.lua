 --聊天界面
local PokerRoomChatView = class("PokerRoomChatView", PokerUIWndBase)
local PokerEventDef = require("package_src.games.guandan.gdcommon.data.PokerEventDef")
local UmengClickEvent = require("app.common.UmengClickEvent")

function PokerRoomChatView:ctor(data, zorder, delegate)
    self.super.ctor(self,"package_res/games/guandan/chat_view.csb",data)
end

function PokerRoomChatView:onInit()
    self.root = self:getWidget(self.m_pWidget,"root")
    self.root:addTouchEventListener(handler(self, self.onClickButton))

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

    --每行表情偏移
    self.lineOffy = 105

    local txtContainer = self:getWidget(self.m_pWidget,"txtContainer")
    local mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/guandan/chat_txt_item.csb")
    local height = txtContainer:getContentSize().height - 67
    local width = txtContainer:getContentSize().width
    for i,v in ipairs(self.m_data) do
        local item = mItem:clone()
        local lb_txt = self:getWidget(item, "lbl_txt")
        lb_txt:setString(v.content)
        local img_bg = self:getWidget(item, "img_bg")

        item:setPosition(4,height)
        height = height - 70
        txtContainer:addChild(item)
        img_bg:setTag(i)
        img_bg:setTouchEnabled(true)
        img_bg:addTouchEventListener(handler(self, self.onClickChatText))
    end

    local faceContainer = self:getWidget(self.m_pWidget,"faceContainer")
    local height1 = faceContainer:getContentSize().height - 50
    local width1 = faceContainer:getContentSize().width
    local itemModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/guandan/face_item.csb")
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
                face:setPosition((i-1)*self.faceWidth+self.faceOffsetX,self.lineSize.height/2)
                line:addChild(face)
            end
        end
        line:setAnchorPoint(cc.p(0.0,0.5))
        line:setPosition(4,height1)
        height1 = height1 - self.lineOffy
        faceContainer:addChild(line)
    end

    --由于基类getWidget函数中判断节点为TextField，会调用基类方法setTextFieldToEditBox设置输入框
    self.chat_input = ccui.Helper:seekWidgetByName(self.m_pWidget,"text_input")

    self.btn_send = self:getWidget(self.m_pWidget,"btn_send")
    self.btn_send:addTouchEventListener(handler(self,self.onClickButton))
end

function PokerRoomChatView:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerRoomChatView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.btn_send then
            local content = self.chat_input:getString()
            Log.i("content", content)
            if content and content ~= "" then
                local data  = {}
                data.usI    = HallAPI.DataAPI:getUserId()
                data.roI    = HallAPI.DataAPI:getRoomId()
                data.co     = content
                data.ty     = CHATTYPE.CUSTOMCHAT
                data.niN    = HallAPI.DataAPI:getUserName()
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,data)
                NativeCallUmengEvent(UmengClickEvent.GDGameChatSend)
            else
                HallAPI.ViewAPI:showToast("请输入聊天内容")
            end
        end
        self:keyBack()
    end
end

function PokerRoomChatView:onClickChatText(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        local index = pWidget:getTag()
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT, 2, index)
        NativeCallUmengEvent(UmengClickEvent.GDGameChat..index)
        self:keyBack()
    end
end

function PokerRoomChatView:onClickChatFace(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        local index = pWidget:getTag()
        content =self.face_pic_list[index]
        HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.REQSENDDEFCHAT, 1, content)
        NativeCallUmengEvent(UmengClickEvent.GDGameChatFace..index)

        self:keyBack()
    end
end

return PokerRoomChatView
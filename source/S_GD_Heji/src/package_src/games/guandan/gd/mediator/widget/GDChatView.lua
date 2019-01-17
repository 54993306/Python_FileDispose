--
-- Author: Machine
-- Date: 2017-12-26
-- 聊天显示界面,设置聊天文本背景自适应文字大小
local GDRoomView = require("package_src.games.guandan.gd.mediator.widget.GDRoomView")
local GDChatView = class("GDChatView", GDRoomView)
local GDConst = require("package_src.games.guandan.gd.data.GDConst")

local facaeBgSize = cc.size(156, 91)
local showTime = 2
local maxWidth = 240
local widthMore = 25	--背景图比文本多增加的X
local heightMore = 30	--背景图比文本多增加的X

-----------------------------------------------
-- @desc 初始化ui
-----------------------------------------------
function GDChatView:initView()
    self.m_pWidget:setVisible(true)
	self.pan_chat = {}
	for i = 1, GDConst.PLAYER_NUM do
		local strChatPanel = "chat" .. i
		self.pan_chat[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, strChatPanel)
        self.pan_chat[i]:setVisible(false)
	end

    if self.m_data == GDConst.GAME_UP_TYPE.NO_UP_GRADE then
        local originMargin_start = self.pan_chat[1]:getLayoutParameter():getMargin()
        originMargin_start.bottom = originMargin_start.bottom + 60
        self.pan_chat[1]:getLayoutParameter():setMargin(originMargin_start)
        self.pan_chat[1]:getParent():requestDoLayout()

        local originMargin_start = self.pan_chat[2]:getLayoutParameter():getMargin()
        originMargin_start.top = originMargin_start.top + 60
        self.pan_chat[2]:getLayoutParameter():setMargin(originMargin_start)
        self.pan_chat[2]:getParent():requestDoLayout()

        local originMargin_start = self.pan_chat[4]:getLayoutParameter():getMargin()
        originMargin_start.top = originMargin_start.top + 60
        self.pan_chat[4]:getLayoutParameter():setMargin(originMargin_start)
        self.pan_chat[4]:getParent():requestDoLayout()
    end
end

-----------------------------------------------
-- @desc 显示聊天
--[[
    info.ty 
    info.seat = seat
    info.headPos = self:getHeadPosBySeat(seat)
]]
-----------------------------------------------
function GDChatView:showDefaultChat(info)
	-- Log.i("GDChatView:showDefaultChat", info)
	local seat = info.seat
	local chatType = info.ty

    self.pan_chat[seat]:stopAllActions();

    local face = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "face") 
    local lb_chat = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "lb_chat") 
    local chat_bg = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "bg")

    if chat_bg.anim then 
        chat_bg.anim:removeFromParent()
        chat_bg.anim = nil 
        -- if info.usI == HallAPI.DataAPI:getUserId() then
        --     Toast.getInstance():show("你发送的太快了，请稍后再发！");
        -- end
    end
        
    if chatType == GDConst.FACETYPE then
        local faceAni, faceSize = self:createFaceBy(info.emI)
        chat_bg.anim = faceAni
        if info.emI == 1 then
            faceAni:setPosition(cc.p(faceSize.width/2+10,faceSize.height/2-20))
        elseif info.emI == 2 then
            faceAni:setPosition(cc.p(faceSize.width/2,faceSize.height/2-10))
        else
            faceAni:setPosition(cc.p(faceSize.width/2,faceSize.height/2))
        end

        faceAni:addTo(chat_bg)
        chat_bg:setContentSize(faceSize)
        if seat == 2 then
            chat_bg:setFlippedX(true)
            local originMargin_start = chat_bg:getLayoutParameter():getMargin()
            originMargin_start.right = 7 - chat_bg:getContentSize().width
            chat_bg:getLayoutParameter():setMargin(originMargin_start)
            chat_bg:getParent():requestDoLayout()
        elseif seat == 3 then
            local originMargin_start = self.pan_chat[seat]:getLayoutParameter():getMargin()
            originMargin_start.top = 56
            self.pan_chat[seat]:getLayoutParameter():setMargin(originMargin_start)
            self.pan_chat[seat]:getParent():requestDoLayout()

            chat_bg:setFlippedX(true)
            local originMargin_start = chat_bg:getLayoutParameter():getMargin()
            originMargin_start.right = chat_bg:getContentSize().width
            chat_bg:getLayoutParameter():setMargin(originMargin_start)
            chat_bg:getParent():requestDoLayout()
        end

        lb_chat:setVisible(false)
        face:setVisible(false)       
        -- face:loadTexture("common/face_" .. info.emI .. ".png",ccui.TextureResType.plistType)
    elseif chatType == GDConst.TEXTTYPE then
        local sex = info.sex
        local content = info.content
        if content then
            local txt = lb_chat:clone()
            txt:setString(content)
            local curSize = txt:getContentSize()
            if txt:getContentSize().width > maxWidth then
                lb_chat:setTextAreaSize(cc.size(maxWidth, 0))
            end
            lb_chat:setTextAreaSize(curSize)

            lb_chat:setString(content);  
            
            chat_bg:setContentSize(cc.size(lb_chat:getContentSize().width + widthMore, lb_chat:getContentSize().height + heightMore))
            if seat == 2 then
                chat_bg:setFlippedX(true)
                local originMargin_start = chat_bg:getLayoutParameter():getMargin()
                originMargin_start.right = 7 - chat_bg:getContentSize().width
                chat_bg:getLayoutParameter():setMargin(originMargin_start)
                chat_bg:getParent():requestDoLayout()

            elseif seat == 3 then
                local originMargin_start = self.pan_chat[seat]:getLayoutParameter():getMargin()
                originMargin_start.top = 24
                originMargin_start.right = 426
                self.pan_chat[seat]:getLayoutParameter():setMargin(originMargin_start)
                self.pan_chat[seat]:getParent():requestDoLayout()

                chat_bg:setFlippedX(true)
                local originMargin_start = chat_bg:getLayoutParameter():getMargin()
                originMargin_start.right = chat_bg:getContentSize().width
                chat_bg:getLayoutParameter():setMargin(originMargin_start)
                chat_bg:getParent():requestDoLayout()
            end
            kPokerSoundPlayer:playEffect("ddzchat_txt" .. info.emI .. sex);
            face:setVisible(false)
            lb_chat:setVisible(true)
        end     
    end

    self.pan_chat[seat]:setVisible(true)
    self.pan_chat[seat]:performWithDelay(function()
        self.pan_chat[seat]:setVisible(false)
        if chat_bg.anim then
            chat_bg.anim:removeFromParent()
            chat_bg.anim = nil 
        end
    end, showTime)
end

--函数功能：创建表情动画
--返回值：  无
--emId：表情id
function GDChatView:createFaceBy(emId)
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("hall/gameCommon/face/armature/face.csb")
    local face = ccs.Armature:create("face")
    face:setScale(0.6);
    local index = tostring(emId);
    local size = cc.size(228, 141)
    if index == "1" then
        face:getAnimation():play("PRAY")
    elseif index == "2" then
        face:setScale(0.4);
        face:getAnimation():play("CHOP")
    elseif index == "3" then
        face:getAnimation():play("FAINTED",-1,0)
        face:getAnimation():setSpeedScale(0.75)
    elseif index == "4" then
        face:getAnimation():play("DEPRESSED")
    elseif index == "5" then
        face:getAnimation():play("HAPPY")
    elseif index == "6" then
        face:setScale(0.5);
        face:getAnimation():play("THUMB")
    elseif index == "7" then
        face:getAnimation():play("CHARMED")
    elseif index == "8" then
        face:getAnimation():play("SURRENDER")
    elseif index == "9" then
        face:getAnimation():play("BOOST")
    elseif index == "10" then
        face:getAnimation():play("SCORN")
    elseif index == "11" then
        face:getAnimation():play("UPSET")
    elseif index == "12" then
        face:setScale(0.5);
        face:getAnimation():play("COCKY")
    elseif index == "13" then
        face:getAnimation():play("APATHY")
    end
    size.width = size.width * 0.6 + 40
    return face, size
end

-----------------------------------------------
-- @desc 显示自定义聊天
--[[
    info.ty 
    info.seat = seat
    info.headPos = self:getHeadPosBySeat(seat)
]]
-----------------------------------------------
function GDChatView:showCustomChat(info)
    -- Log.i("GDChatView:showCustomChat", info)
    local seat = info.seat

    self.pan_chat[seat]:stopAllActions();

    local face = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "face") 
    local lb_chat = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "lb_chat") 
    local chat_bg = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "bg")


    local sex = info.sex
    local content = info.content
    if content then
        local txt = lb_chat:clone()
        txt:setString(content)
        local curSize = txt:getContentSize()
        if txt:getContentSize().width > maxWidth then
            lb_chat:setTextAreaSize(cc.size(maxWidth, 0))
        end
        lb_chat:setTextAreaSize(curSize)

        lb_chat:setString(content);  
        chat_bg:setContentSize(cc.size(lb_chat:getContentSize().width + widthMore, lb_chat:getContentSize().height + heightMore))
        face:setVisible(false)
        lb_chat:setVisible(true)
    end     

    if seat == 2 then
        local originMargin_start = chat_bg:getLayoutParameter():getMargin()
        originMargin_start.left = 0
        chat_bg:getLayoutParameter():setMargin(originMargin_start)
    end
    self.pan_chat[seat]:setVisible(true)
    self.pan_chat[seat]:performWithDelay(function()
        self.pan_chat[seat]:setVisible(false)
    end, showTime)
end

return GDChatView
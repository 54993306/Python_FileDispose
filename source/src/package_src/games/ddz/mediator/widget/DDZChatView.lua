--
-- Author: Machine
-- Date: 2017-12-26
-- 聊天显示界面,设置聊天文本背景自适应文字大小
--

local DDZRoomView = require("package_src.games.ddz.mediator.widget.DDZRoomView")
local DDZConst = require("package_src.games.ddz.data.DDZConst")
local DDZChatView = class("DDZChatView", DDZRoomView)

local facaeBgSize = cc.size(156, 91)
local offset = 0
local showTime = 2
local maxWidth = 240
local offsetY = 40		--其他人聊天相对与头像上移位置
local widthMore = 25	--背景图比文本多增加的X
local heightMore = 30	--背景图比文本多增加的X
local faceMargin = { left = 0, right = 0, top = 0, bottom = 0}
local txtMargin = { left = -305, right = 0, top = 0, bottom = 0}

-----------------------------------------------
-- @desc 初始化ui
-----------------------------------------------
function DDZChatView:initView()
	self.pan_chat = {}
	for i = 1, DDZConst.PLAYER_NUM do
		local strChatPanel = "chat" .. i
		-- Log.i("name is ", strChatPanel)
		self.pan_chat[i] = ccui.Helper:seekWidgetByName(self.m_pWidget, strChatPanel)
        self.pan_chat[i]:setVisible(false)
		-- Log.i("self.pan_chat[i]", self.pan_chat[i])
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
function DDZChatView:showDefaultChat(info)
	Log.i("DDZChatView:showDefaultChat", info)
	local seat = info.seat
	local chatType = info.ty

    self.pan_chat[seat]:stopAllActions();
    -- self.pan_chat[seat]:setPosition(info.headPos.x, info.headPos.y + offsetY)

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
        
    if chatType == DDZConst.FACETYPE then
        Log.i("--wangzhi--进入表情--")
        local faceAni = self:createFaceBy(info.emI)
        local faceSize = faceAni:getContentSize()
        chat_bg.anim = faceAni
        faceAni:setPosition(cc.p(150/2,faceSize.height/2 - 10))
        faceAni:addTo(chat_bg)

        chat_bg:setContentSize(facaeBgSize);
            
        if seat == 2 then
            -- Log.i("setMargin")
            -- chat_bg:setPositionX(100) 
            chat_bg:getLayoutParameter():setMargin({left = -lb_chat:getContentSize().width+140})
            -- chat_bg:getLayoutParameter():setMargin({left = -lb_chat:getContentSize().width-20})
            --chat_bg:getLayoutParameter():setMargin(faceMargin)
        end

        lb_chat:setVisible(false)
        face:setVisible(false)       
        face:loadTexture("common/face_" .. info.emI .. ".png",ccui.TextureResType.plistType)
    elseif chatType == DDZConst.TEXTTYPE then
        Log.i("--wangzhi--进入语句--")
        local sex = info.sex
        local content = info.content
        if content then
            -- lb_chat:setTextAreaSize(cc.size(0, 0))
            local txt = lb_chat:clone()
            txt:setString(content)
            local curSize = txt:getContentSize()
            Log.i("------curSize",  curSize)
            if txt:getContentSize().width > maxWidth then
                lb_chat:setTextAreaSize(cc.size(maxWidth, 0))
            end
            lb_chat:setTextAreaSize(curSize)

            lb_chat:setString(content);  
            Log.i("lb_chat:getContentSize()", lb_chat:getContentSize())
            
            chat_bg:setContentSize(cc.size(lb_chat:getContentSize().width + widthMore, lb_chat:getContentSize().height + heightMore))
            if seat == 2 then
                -- chat_bg:setPositionX(0)
                -- 处理一个未知的偏移问题
                chat_bg:getLayoutParameter():setMargin({left = -lb_chat:getContentSize().width-20})
            end
            -- chat_bg = chat_bg:clone()
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
function DDZChatView:createFaceBy(emId)
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("hall/gameCommon/face/armature/face.csb")
    local face = ccs.Armature:create("face")
    face:setScale(0.6);
    local index = tostring(emId);
    if index == "1" then
        face:getAnimation():play("PRAY")
    elseif index == "2" then
        face:getAnimation():play("CHOP")
    elseif index == "3" then
        face:getAnimation():play("FAINTED",-1,0)
        face:getAnimation():setSpeedScale(0.75)
    elseif index == "4" then
        face:getAnimation():play("DEPRESSED")
    elseif index == "5" then
        face:getAnimation():play("HAPPY")
    elseif index == "6" then
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
        face:getAnimation():play("COCKY")
    elseif index == "13" then
        face:getAnimation():play("APATHY")
    end
    return face
end

-----------------------------------------------
-- @desc 显示自定义聊天
--[[
    info.ty 
    info.seat = seat
    info.headPos = self:getHeadPosBySeat(seat)
]]
-----------------------------------------------
function DDZChatView:showCustomChat(info)
    Log.i("DDZChatView:showCustomChat", info)
    local seat = info.seat

    self.pan_chat[seat]:stopAllActions();
    -- self.pan_chat[seat]:setPosition(info.headPos.x, info.headPos.y + offsetY)

    local face = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "face") 
    local lb_chat = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "lb_chat") 
    local chat_bg = ccui.Helper:seekWidgetByName(self.pan_chat[seat], "bg")


    local sex = info.sex
    local content = info.content
    if content then
        -- lb_chat:setTextAreaSize(cc.size(0, 0))
        local txt = lb_chat:clone()
        txt:setString(content)
        local curSize = txt:getContentSize()
        Log.i("------curSize",  curSize)
        if txt:getContentSize().width > maxWidth then
            lb_chat:setTextAreaSize(cc.size(maxWidth, 0))
        end
        lb_chat:setTextAreaSize(curSize)

        lb_chat:setString(content);  
        Log.i("lb_chat:getContentSize()", lb_chat:getContentSize())
        chat_bg:setContentSize(cc.size(lb_chat:getContentSize().width + widthMore, lb_chat:getContentSize().height + heightMore))
        face:setVisible(false)
        lb_chat:setVisible(true)
    end     

    if seat == 2 then
        chat_bg:getLayoutParameter():setMargin(txtMargin)
    end
    self.pan_chat[seat]:setVisible(true)
    self.pan_chat[seat]:performWithDelay(function()
        self.pan_chat[seat]:setVisible(false)
    end, showTime)
end



return DDZChatView
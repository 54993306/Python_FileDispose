--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Define = require "app.games.common.Define"
PlayerChat = class("PlayerChat")
local CapInsets = cc.rect(43,40,1,1)
function PlayerChat:ctor(site, head, type, info, chat_bg)
    -- print(debug.traceback())
    Log.i("self.m_type.....",type,info)
    self.m_type = type
    self.m_info = info
    self.m_chat_bg = chat_bg
    -- self.m_site = site
    self:initSite(site) 
    self.m_head = head
    if self.m_type == 1 then                  --输入框输入
        self:showChat(self.m_info.co)
    elseif self.m_type == 2 then              --表情内容或短语
        self:showDefaultChat()
    end
end

function PlayerChat:initSite(site)
    local playerNum  =  4
    if VideotapeManager.getInstance():isPlayingVideo() then
        local gameSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local players       = gameSystem:gameStartGetPlayers()       -- 玩家信息
        playerNum     = #players  or 4
    else
        playerNum = kFriendRoomInfo:getRoomInfo().plS or 4
    end

    if playerNum == 4 then
       self.m_site = site
    elseif playerNum == 3 then
        if site == enSiteDirection.SITE_OTHER then   --三人房没有对家
            self.m_site = enSiteDirection.SITE_LEFT
        else
            self.m_site = site
        end
    elseif playerNum == 2 then
        if site == enSiteDirection.SITE_MYSELF then
            self.m_site = enSiteDirection.SITE_MYSELF
        else
            self.m_site = enSiteDirection.SITE_OTHER
        end
    end
    -- print("-----------site = "..site.." turnsite = "..self.m_site.."playerNum = "..playerNum)
end

function PlayerChat:showDefaultChat()
    Log.i("PlayerChat:showDefaultChat....",self.m_site)
    local site = self.m_site
    if self.m_info.ty == 1 then
        local face = self:createFaceBy()
        local faceSize = face:getContentSize()
        local faceHeight = faceSize.height < 91 and 91 or faceSize.height
        local cat_bg = self:createChatBg(face)
        cat_bg:setContentSize(cc.size(150,faceHeight)) 
        face:setPosition(cc.p(150/2,faceSize.height/2))
        self:setFaceOffset(face)
        face:addTo(cat_bg)
        cat_bg:performWithDelay(function()
        cat_bg:removeFromParent()
        end, 2);
    elseif self.m_info.ty == enChatType.PHRASE then             --短语 
        if _gameChatTxtCfg == nil or #_gameChatTxtCfg <= 0 then  --初始化短语
            MjProxy:getInstance():get_gameChatTxtCfg()
        end  
        local content = _gameChatTxtCfg[self.m_info.emI];
        self:showChat(content)
    end
end

function PlayerChat:showChat(data) 
    local Lab = self:createChatLab(data)
    local posX,posY = self.m_chat_bg:getPosition()
    local cat_bg = display.newScale9Sprite("hall/gameCommon/face/chat_bg.png",posX,posY)
    cat_bg:setCapInsets(CapInsets)
    cat_bg:setLocalZOrder(3)
    cat_bg:addTo(self.m_head)
    Lab:addTo(cat_bg)
    local labSize = Lab:getContentSize() 
    local with   = labSize.width  < 56 and 56 or labSize.width + 30
    local height = labSize.height < 25 and 72 or labSize.height + 72 - 25
    -- print("labSize.width = "..labSize.width.."/labSize.height = "..labSize.height.."/with = "..with.."/height = "..height)
    cat_bg:setContentSize(cc.size(with,height))
    if self.m_site == Define.site_self then
        cat_bg:setAnchorPoint(cc.p(0.2,0.4))
        Lab:setPosition(cc.p(with/2,height/2 + 9))
    elseif self.m_site == Define.site_right then
        cat_bg:setScaleX(-1)
        Lab:setScaleX(-1)
        cat_bg:setAnchorPoint(cc.p(0,0))
        Lab:setPosition(cc.p(with/2,height/2 + 9))
    elseif self.m_site == Define.site_other then
        cat_bg:setScaleX(-1)
        Lab:setScaleX(-1)
        cat_bg:setAnchorPoint(cc.p(0,1))
        -- 全面屏对家的语音会超框，所以把位置下调20
        cat_bg:setPositionY(cat_bg:getPositionY()-20)
        if IsPortrait then -- TODO
            cat_bg:setAnchorPoint(cc.p(0,1))
        end
        Lab:setPosition(cc.p(with/2,height/2 + 9))
    elseif self.m_site == Define.site_left then
        cat_bg:setAnchorPoint(cc.p(0.2,0.3))
        Lab:setPosition(cc.p(with/2,height/2 + 9))
    end


    --[[local drawNode = cc.DrawNode:create()
    local rc = Lab:getBoundingBox()
    Log.i("Lab height :", Lab:getContentSize().height)
    local poses = {cc.p(rc.x, rc.y), cc.p(rc.x + rc.width, rc.y), cc.p(rc.x + rc.width, rc.y + rc.height), cc.p(rc.x, rc.y + rc.height)}
    if color == nil then
        color = cc.c4f(0, 1, 0, 0.5)
    end
    drawNode:drawSolidPoly(poses, 4, color)
    drawNode:setPosition(cc.p(0, 0))
    cat_bg:addChild(drawNode, 1000)]]


    cat_bg:performWithDelay(function()
        cat_bg:removeFromParent()
    end, 2);
end

function PlayerChat:createFaceBy()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("hall/gameCommon/face/armature/face.csb")
    local face = ccs.Armature:create("face")
    face:setScale(0.6);
    local index = self.m_info.emI;
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

function PlayerChat:setFaceOffset(face)
    local index = self.m_info.emI;
    if index == "1" then
        if self.m_site == Define.site_other then
            face:setPosition(face:getPositionX() -10,face:getPositionY() - 15)
        elseif self.m_site == Define.site_right then
            face:setPosition(face:getPositionX() -10,face:getPositionY() - 15)
        else
            face:setPosition(face:getPositionX() + 10,face:getPositionY() - 15)
        end
    elseif index == "5" then
        if self.m_site == Define.site_other then
            face:setPositionX(face:getPositionX() - 10)
        elseif self.m_site == Define.site_right then
            face:setPositionX(face:getPositionX() - 10)
        else
            face:setPositionX(face:getPositionX() + 10)
        end
    elseif index == "6" then
        face:setPositionY(face:getPositionY() + 5)
    elseif index == "8" then
        face:setPositionY(face:getPositionY() + 15)
    elseif index == "13" then
        face:setPositionY(face:getPositionY() + 15)
    end
end

function PlayerChat:createChatBg(face)
    local posX,posY = self.m_chat_bg:getPosition()
    local cat_bg = display.newScale9Sprite("hall/gameCommon/face/chat_bg.png",posX,posY)
    if self.m_site == Define.site_self then
        cat_bg:setAnchorPoint(cc.p(0,0))
    elseif self.m_site == Define.site_right then
        cat_bg:setFlippedX(true)
        face:setScaleX(-face:getScaleX())
        cat_bg:setAnchorPoint(cc.p(0,0))
    elseif self.m_site == Define.site_other then
        cat_bg:setFlippedX(true)
        face:setScaleX(-face:getScaleX())
        cat_bg:setAnchorPoint(cc.p(0,1))
        cat_bg:setPosition(cc.p(cat_bg:getPositionX(),cat_bg:getPositionY()))
    elseif self.m_site == Define.site_left then
        cat_bg:setAnchorPoint(cc.p(0,0))
    end
    cat_bg:setCapInsets(CapInsets)
    cat_bg:addTo(self.m_head)
    return cat_bg
end
-- 计算字符串宽度
function PlayerChat:widthSingle(inputstr)
    local lenInByte = #inputstr
    local width = 0
    local i = 1
    while (i<=lenInByte)
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        local bytewidth = 2
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
            bytewidth = 1
        elseif curByte>=192 and curByte<=223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        end
        local char = string.sub(inputstr, i, i+byteCount-1)
        i = i + byteCount                                               -- 重置下一字节的索引
        width = width + bytewidth                                       -- 字符的个数（长度）
    end
    return width
end

function PlayerChat:labAnchorpointOffset(Lab,line)
    if line == 2 then
        Lab:setAnchorPoint(cc.p(0,0.61)) 
    elseif line == 3 then
        Lab:setAnchorPoint(cc.p(0,0.63))
    else
        Lab:setAnchorPoint(cc.p(0,0.55)) 
    end
end

function PlayerChat:createChatLab(data)
    local lenth = self:widthSingle(data or "")
    local textSize = 20
    local params = {}
    params.text = data or ""
    params.font = "hall/font/fangzhengcuyuan.TTF"
    params.size = textSize
    params.x = 0
    params.y = 0
    params.color = display.COLOR_BLACK
    local Lab = display.newTTFLabel(params)
    Lab:setAnchorPoint(cc.p(0.5,0.5))
    -- print("----------------createChatLab",lenth)
    Lab:setDimensions(0,0)
    Lab:setLineBreakWithoutSpace(true)

    if lenth <= 32 then
        Lab:setMaxLineWidth(lenth*textSize*0.5)
    else
        if Lab:getContentSize().width > 15*textSize then
            Lab:setDimensions(15*textSize,0)
        end
    end
    --Lab:setDimensions(150,0)
    --Lab:setDimensions(15*textSize,0)
    --[[
    Lab:setAnchorPoint(cc.p(0,0.47))                           
    -- print("----------------createChatLab",lenth)
    if lenth <= 16 then
        Lab:setDimensions(lenth*textSize,textSize+20)
    else
        local line = math.ceil(lenth/16)
        self:labAnchorpointOffset(Lab,line)
        Lab:setDimensions(15*textSize,(textSize+25)*line)
    end]]
    return Lab
end

--显示正在说话
function PlayerChat:showSpeaking(site,head)
    Log.i("------showSpeaking site", site);
    self.m_site = site
    if not self.speakingBgs then
        self.speakingBgs = {};
    end
    if self.speakingBgs[site] then
        return;
    end
    local bgSize = cc.size(160, 80);
    if site == Define.site_self then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", 100, 50, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        voice_bg:setPosition(cc.p(36, 40));
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setScaleX(-1);
    elseif site == Define.site_right then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", -150, 50, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        voice_bg:setPosition(cc.p(124, 40));
        self.speakingBgs[site]:addChild(voice_bg);
    elseif site == Define.site_other then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", -150, 0, bgSize);
        local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setPosition(cc.p(124, 40));
    elseif site == Define.site_left then
        self.speakingBgs[site] = display.newScale9Sprite("games/common/speaking_bg.png", 100, 50, bgSize);
         local voice_bg = ccui.ImageView:create("games/common/speak_voice_0.png");
        self.speakingBgs[site]:addChild(voice_bg);
        voice_bg:setPosition(cc.p(36, 40));
        voice_bg:setScaleX(-1);
    end
    self.speakingBgs[site]:setCapInsets(cc.rect(42, 40, 1, 1));
    self.speakingBgs[site]:addTo(self.m_head)
    self.speakingBgs[site]:setAnchorPoint(cc.p(0, 0));
end

--说话完毕
function PlayerChat:hideSpeaking(site)
    Log.i("------hideSpeaking site", site,self.speakingBgs);
    if self.speakingBgs and self.speakingBgs[site] then
        Log.i("self.speakingBgs[site]...不为空....")
        self.speakingBgs[site]:setVisible(false);
        self.speakingBgs[site]:removeFromParent(true);
        self.speakingBgs[site] = nil;
    end
end
-------------------------------------------------------------------------
-- Desc:   二人斗地主玩家头像UI
-- Author:   
-------------------------------------------------------------------------
local DDZTWOPRoomView = require("package_src.games.paodekuai.pdktwop.mediator.widget.DDZTWOPRoomView")
local PokerUtils =require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZTWOPDefine = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPDefine")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local PokerClippingNode = require("package_src.games.paodekuai.pdkcommon.commontool.PokerClippingNode")
local DDZTWOPConst = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPConst")
local PorkerRoomPlayerInfoView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomPlayerInfoView")
local DDZTWOPPlayerView = class("DDZTWOPPlayerView", DDZTWOPRoomView)

--头像尺寸
local nHeadSize = 80
--头像tag
local eTagClipHead = 123

---------------------------------------
-- 函数功能：   初始化UI数据
-- 返回值：     无
---------------------------------------
function DDZTWOPPlayerView:initView()
    self.frame = ccui.Helper:seekWidgetByName(self.m_pWidget,"frame")
    self.frame:addTouchEventListener(handler(self,self.onClickButton))
    self.ready = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_ready")
    self.ready:setVisible(false)
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self.money = self:getWidget(self.m_pWidget,"gold_num",{bold = true})
        self:getWidget(self.m_pWidget,"lbl_friend_gold"):setVisible(false)
        self:getWidget(self.m_pWidget,"gold"):setVisible(true)
    else

        self.money = self:getWidget(self.m_pWidget,"lbl_friend_gold",{bold = true})
        self:getWidget(self.m_pWidget,"gold_num"):setVisible(false)
        self:getWidget(self.m_pWidget,"gold"):setVisible(false)
    end
    self.money:setVisible(true)
    self.img_role = ccui.Helper:seekWidgetByName(self.m_pWidget, "dizhu")
    self.double = self:getWidget(self.m_pWidget,"doublenum",{bold = true})
    self.img_tg = ccui.Helper:seekWidgetByName(self.m_pWidget,"tuoguan_tag")
    self.lb_name = self:getWidget(self.m_pWidget, "name", {bold = true})
    self.say_panel = self:getWidget(self.m_pWidget,"panel_head_say")

    self.chat = ccui.Helper:seekWidgetByName(self.m_pWidget, "chat")
    self.chat:setVisible(false)
    self.chat_bg = ccui.Helper:seekWidgetByName(self.chat, "bg")
    self.face = ccui.Helper:seekWidgetByName(self.m_pWidget, "face")
    self.lb_chat = self:getWidget(self.m_pWidget,"lb_chat",{bold = true})
    self.lb_chat:ignoreContentAdaptWithSize(false)

    --聊天字符串长度
    self.chatStrLength = 40
    --移除聊天ui延迟时间
    self.moveTime = 2
    --判断头像字符长度限制
    self.headStrLength = 10

    --表情背景大小
    self.facebgSize = cc.size(100, 80)


    --文字聊天位置和背景大小设置
    self.sMineSize = cc.size(256, 60)
    self.sMinePos = cc.p(121, 50)
    self.sOtherSize = cc.size(256, 60)
    self.sOtherPos = cc.p(142, 30)
    self.bMineSize = cc.size(250, 75)
    self.bMinePos = cc.p(124, 57)
    self.bOtherSize = cc.size(250, 75)
    self.bOtherPos = cc.p(130, 48)

    --添加监听事件
    self.nHandle=HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_PROP_CHANGE, handler(self, self.onRecvEvent))
    table.insert(self.listeners, self.nHandle)
end

---------------------------------------
-- 函数功能：  用于更新玩家数据函数
-- 返回值：     无
--[[
    参数：
    prop_id    玩家信息属性ID
    value      需要更新的数据
    oldvalue   之前的数据
    extinfo    存在信息
]]
---------------------------------------
function DDZTWOPPlayerView:onRecvEvent(prop_id, value, oldvalue, extinfo)
    local PlayerModel = self:getPlayerModel()
    if prop_id == DDZTWOPDefine.MONEY and extinfo == self.m_data then
        self:setMoney(value)
    end
end

---------------------------------------
-- 函数功能：   用于设置更新玩家的倍数
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:setDouble()
    local multi = DataMgr:getInstance():getNumberByKey(DDZTWOPConst.DataMgrKey_MUTIPLE) 
    self.double:setString("x"..multi)
end

---------------------------------------
-- 函数功能：   显示准备
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:showReady()
    self.ready:setVisible(true)
end

---------------------------------------
-- 函数功能：   显示准备
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:hideReady()
    self.ready:setVisible(false)
end


---------------------------------------
-- 函数功能：   显示语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:showSpeaking()
    self.say_panel:setVisible(true)
end

---------------------------------------
-- 函数功能：   隐藏语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:hideSpeaking()
    self.say_panel:setVisible(false)
end

---------------------------------------
-- 函数功能：   关闭函数  用于清除注册的消息
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:reset()
    self.img_role:setVisible(false)
    self.say_panel:setVisible(false)
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:hide()
    else
        self.double:setString("x" .. tostring(1))
    end
end

---------------------------------------
-- 函数功能：   朋友房清除UI
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:friendReset()
    self.img_role:setVisible(false)
    self.say_panel:setVisible(false)
    self.double:setString("x"..tostring(1))
end

---------------------------------------
-- 函数功能：    展示聊天结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPPlayerView:showDefaultChat(info)
    self.chat:stopAllActions()
    if info.ty == DDZTWOPConst.CHATTYPE1 then
        self.chat:setVisible(true)
        self.face:setVisible(true)
        self.chat_bg:setContentSize(self.facebgSize)
        self.lb_chat:setVisible(false)
        self.face:loadTexture("common/face_" .. info.emI .. ".png", ccui.TextureResType.plistType)
    elseif info.ty == DDZTWOPConst.CHATTYPE2 then
        local PlayerModel = self:getPlayerModel()
        local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)
        local content = info.content
        if content then
            if string.len(content) > self.chatStrLength then
                if self.m_data == DDZTWOPConst.SEAT_MINE then
                    self.chat_bg:setContentSize(self.bMineSize)
                    self.lb_chat:setPosition(self.bMinePos)
                else
                    self.chat_bg:setContentSize(self.bOtherSize)
                    self.lb_chat:setPosition(self.bOtherPos)
                end
                
            else
                if self.m_data == DDZTWOPConst.SEAT_MINE then
                    self.chat_bg:setContentSize(self.sMineSize)
                    self.lb_chat:setPosition(self.sMinePos)
                else
                    self.chat_bg:setContentSize(self.sOtherSize)
                    self.lb_chat:setPosition(self.sOtherPos)
                end
            end
            self.lb_chat:setString(content)
            kPokerSoundPlayer:playEffect("ddzchat_txt" .. info.emI .. sex)
            self.face:setVisible(false)
            self.lb_chat:setVisible(true)
        end
    end
    self.chat:setVisible(true)
    self.chat:performWithDelay(function()
        self.chat:setVisible(false)
    end, self.moveTime)
end

---------------------------------------
-- 函数功能：    展示自定义聊天结果函数
-- 返回值：      无
---------------------------------------
function DDZTWOPPlayerView:showCustomChat(info)
    self.chat:stopAllActions()
    local PlayerModel = self:getPlayerModel()
    local sex = PlayerModel:getProp(DDZTWOPDefine.SEX)
    local content = info.content
    if content then
        if string.len(content) > self.chatStrLength then
            if self.m_data == DDZTWOPConst.SEAT_MINE then
                self.chat_bg:setContentSize(self.bMineSize)
                self.lb_chat:setPosition(self.bMinePos)
            else
                self.chat_bg:setContentSize(self.bOtherSize)
                self.lb_chat:setPosition(self.bOtherPos)
            end
            
        else
            if self.m_data == DDZTWOPConst.SEAT_MINE then
                self.chat_bg:setContentSize(self.sMineSize)
                self.lb_chat:setPosition(self.sMinePos)
            else
                self.chat_bg:setContentSize(self.sOtherSize)
                self.lb_chat:setPosition(self.sOtherPos)
            end
        end
        self.lb_chat:setString(content)
        self.face:setVisible(false)
        self.lb_chat:setVisible(true)
    end
    self.chat:setVisible(true)
    self.chat:performWithDelay(function()
        self.chat:setVisible(false)
    end, self.moveTime)
end

---------------------------------------
-- 函数功能：   更新玩家的信息
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:updatePlayerInfo()
    Log.i("DDZPlayerView:updatePlayerInfo ")
    self:show()
    local player = self:getPlayerModel()
    self.lb_name:setString(PokerUtils:subUtfStrByCn(player:getProp(DDZTWOPDefine.NAME), 1, 4, ".."));
    self:setMoney(player:getProp(DDZTWOPDefine.MONEY))
    local sex = player:getProp(DDZTWOPDefine.SEX)

    url = player:getProp(DDZTWOPDefine.ICON_ID)
    --url ="http://wx.qlogo.cn/mmopen/w9vnwdyIABAibjKlvkSmpn6yQsnJoYZoiaeFZh542lwZTIVqKhAtm0G5ScVt8jibFXGSqbrgZblfT0tqmRzzEaH1S3tnMB1ZYCQ/0";
    local defMale = DDZTWOPConst.DEFMALEFILEPATH
    local defFemale = DDZTWOPConst.DEFFEMALEFILEPATH
    local stencil = DDZTWOPConst.STENCILFILEPATH
    Log.i("head url ", url)
    if not url or string.len(url) < self.headStrLength then
        local headFile = sex == DDZTWOPConst.MALE and defMale or defFemale
        Log.i("head headFile ", headFile)

        self.head = PokerClippingNode.new(stencil, headFile, nHeadSize)
        self.head:setPosition(self.frame:getContentSize().width/2,self.frame:getContentSize().height/2)
        self.frame:addChild(self.head)
        self.head:setTag(eTagClipHead)
        return
    end

    local fileName = player:getProp(DDZTWOPDefine.USERID) .. ".jpg"
    local pos = cc.p(self.frame:getContentSize().width/2,self.frame:getContentSize().height/2)
    PokerUtils:updateHead(fileName, url, stencil, nHeadSize, self.frame, self.head, eTagClipHead, pos)
end

---------------------------------------
-- 函数功能：   显示和隐藏玩家的地主标志
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZTWOPPlayerView:setRole()
    local PlayerModel = self:getPlayerModel()
    local userid = PlayerModel:getProp(DDZTWOPDefine.USERID)
    if userid == DataMgr:getInstance():getObjectByKey(DDZTWOPConst.DataMgrKey_LORDID) then
        self.img_role:setVisible(true)
    else
        self.img_role:setVisible(false)
    end
end

---------------------------------------
-- 函数功能：   设置玩家金豆
-- 返回值：     无
-- money：      需要设置的金豆值
---------------------------------------
function DDZTWOPPlayerView:setMoney(money)
    if self.money then
        local strCoin, suffix = PokerUtils.formatCoin(self, tostring(money))
        local st = (suffix == "wan" and "万") or (suffix == "yi" and "亿") or ""
        if strCoin then
            self.money:setString(strCoin .. st)
        end
    end
end

---------------------------------------
-- 函数功能：   托管信息更新
-- 返回值：     无
-- packetInfo:   托管信息封装
--[[
    参数：
    maPI            托管玩家ID
    isM             是否托管（0：不托管  1：托管）
    serializeType   序列化类型
]]
---------------------------------------
function DDZTWOPPlayerView:onTuoGuanChange(packetInfo)
    local tuoguanStates =  DataMgr.getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_TUOGUANSTATE)
    local playerId = DataMgr.getInstance():getIdBySeat(self.m_data)
    if tuoguanStates[playerId] and tuoguanStates[playerId] == DDZTWOPConst.TUOGUAN_STATE_1 then
        self.img_tg:setVisible(true)
    else
        self.img_tg:setVisible(false)
    end
end

---------------------------------------
-- 函数功能：   按钮点击事件回调
-- 返回值：     无
--[[
    参数:
    pWidget:   点击的ui节点
    EventType:  点击事件
]]
---------------------------------------
function DDZTWOPPlayerView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.frame then
            local info = {}
            local widget = ccui.Helper:seekWidgetByName(self.m_pWidget,"info_point")
            info.pos = self.m_pWidget:convertToWorldSpace(cc.p(widget:getPositionX(),widget:getPositionY()))
            info.site = self.m_data
            PokerUIManager.getInstance():pushWnd(PorkerRoomPlayerInfoView,info)
        end
    end
end

---------------------------------------
-- 函数功能：   获取玩家头像位置
-- 返回值：     头像位置
---------------------------------------
function DDZTWOPPlayerView:getPlayerPosition()
    return self.m_pWidget:getPosition();
end

-- 函数功能：   获取玩家数据
-- 返回值：     玩家数据
---------------------------------------
function DDZTWOPPlayerView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZTWOPConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZTWOPDefine.SITE) == self.m_data then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end

return DDZTWOPPlayerView
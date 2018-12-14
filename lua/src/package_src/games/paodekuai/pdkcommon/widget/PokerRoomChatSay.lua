 --聊天界面

 local PokerRoomChatSay = class("PokerRoomChatView", PokerUIWndBase);
 local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
 local PokerUtils =require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
 local chatViewPath ="package_src.games.paodekuai.pdkcommon.widget.PokerRoomChatView"
 function PokerRoomChatSay:ctor(data, zorder, delegate)
     self.super.ctor(self,"package_res/games/pokercommon/chat_say.csb",data);
     self.img_mic_index = 0;
 end
 ---------------------------------------
-- 函数功能：  UI初始化
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:onInit()
     self.root = self:getWidget(self.m_pWidget,"root")
     self.img_mic = self:getWidget(self.m_pWidget,"img_chat")
 end
 
 ---------------------------------------
-- 函数功能：  UI开始展示
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:onShow()
    self:onTouchBegen()
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
 end


 ---------------------------------------
-- 函数功能：  播放语音动画
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:updateMic()
    self.img_mic_index = self.img_mic_index + 1;
    if self.img_mic_index > 4 then
        self.img_mic_index = 0;
    end
    self.img_mic:loadTexture("common/" .. self.img_mic_index .. ".png" , ccui.TextureResType.plistType)
    self.img_mic:performWithDelay(function ()
        self:updateMic();
    end, 0.2);
 end

---------------------------------------
-- 函数功能：  检测语音上传状态
-- 返回值：    无
---------------------------------------
function PokerRoomChatSay:getUploadStatus()
    Log.i("*************************PokerRoomChatSay4")
    if self.m_getUploadThread then
        scheduler.unscheduleGlobal(self.m_getUploadThread);
        self.m_getUploadThread = nil
    end
    self.m_getUploadThread = scheduler.scheduleGlobal(function()
        Log.i("*************************PokerRoomChatSay5")
        local data = {};
        data.cmd = NativeCall.CMD_YY_UPLOAD_SUCCESS;
        NativeCall.getInstance():callNative(data, self.onUpdateUploadStatus, self);
    end, 0.1);
end

---------------------------------------
-- 函数功能：  检测完成发送语音消息
-- 返回值：    无
---------------------------------------
function PokerRoomChatSay:onUpdateUploadStatus(info)
    Log.i("*************************PokerRoomChatSay6")
    Log.i("--------onUpdateUploadStatus", info.fileUrl);
    if info.fileUrl then
        if self.m_getUploadThread then
            scheduler.unscheduleGlobal(self.m_getUploadThread);
            self.m_getUploadThread = nil;
        end
        local matchStr = string.match(info.fileUrl,"http://");
        Log.i("--------onUpdateUploadStatus", matchStr);

        --发送语音聊天
        if matchStr and HallAPI.DataAPI:getRoomInfo().roI then
            local tmpData  ={};
            tmpData.usI = HallAPI.DataAPI:getUserId();
            tmpData.niN = HallAPI.DataAPI:getUserName();
            tmpData.roI = HallAPI.DataAPI:getRoomInfo().roI;
            tmpData.ty = 1;
            tmpData.co = info.fileUrl;
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SAY_CHAT,tmpData)
        end

    end
end
 
---------------------------------------
-- 函数功能：  语音开始录制
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:onTouchBegen()
     --开始录音
     self.m_isTouchBegan = true;
     local data = {};
     data.cmd = NativeCall.CMD_YY_START;
     NativeCall.getInstance():callNative(data);
 end

 ---------------------------------------
-- 函数功能：  语音录制结束
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:onTouchEnded()
    if self.m_isTouchBegan then
        --停止录音
        local data = {};
        data.cmd = NativeCall.CMD_YY_STOP;
        data.send = 1;
        NativeCall.getInstance():callNative(data);
        -- self.beginSayTxt:setString("按住 说话");
        Log.i("*************************PokerRoomChatSay1")
        if YY_IS_LOGIN then
            Log.i("*************************PokerRoomChatSay2")
            self:getUploadStatus();
        else
            Toast.getInstance():show("功能未初始化完成，请稍后");
        end
        Log.i("*************************PokerRoomChatSay3")
        self.m_isTouchBegan = false;
        self.m_isTouching = true;
        self.m_pWidget:performWithDelay(function ()
            self.m_isTouching = false;
        end, 0.5);
        self:keyBack()
    end
 end

 ---------------------------------------
-- 函数功能：  语音录制结束
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:onTouchCancel()
    if  self.m_isTouchBegan or self.m_speaking then
        --停止录音
        local data = {};
        data.cmd = NativeCall.CMD_YY_STOP;
        data.send = 0;
        NativeCall.getInstance():callNative(data);
        -- self.beginSayTxt:setString("按住 说话");

        self.m_isTouchBegan = false;
        self:keyBack()
    end
 end

  ---------------------------------------
-- 函数功能：  
-- 返回值：    无
---------------------------------------
function PokerRoomChatSay:checkCanSay()
    return self.m_isTouchBegan
end
 ---------------------------------------
-- 函数功能：  返回事件
-- 返回值：    无
---------------------------------------
 function PokerRoomChatSay:keyBack( )
    self.m_speaking  = false
    self.img_mic:stopAllActions();
    PokerUIManager.getInstance():popWnd(self)
 end

 function PokerRoomChatSay:onClose()
    -- if self.m_getUploadThread then
    --     scheduler.unscheduleGlobal(self.m_getUploadThread);
    -- end
 end
 
 return PokerRoomChatSay
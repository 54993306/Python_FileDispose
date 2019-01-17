--
FriendRoomRedPacket = class("FriendRoomRedPacket", UIWndBase);

function FriendRoomRedPacket:ctor(...)
    self.super.ctor(self, "hall/redPacket.csb", ...);
    self.m_data=...;
end

function FriendRoomRedPacket:onClose()
end

function FriendRoomRedPacket:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self:addShowder()

    self.closeBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeBtn");
    self.closeBtn:addTouchEventListener(handler(self, self.onClickButton));
   
    self.bg =  ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
    self.bg:loadTexture(GC_GameHallRedpacketAdPath or _gameRedpacketAdPath);
    if IS_YINGYONGBAO == false then
        local imgName = kServerInfo:getMainAdUrl2();
        if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
            local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
            if io.exists(imgFile) then
                self.bg:loadTexture(imgFile);
            else
                HttpManager.getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName);
            end
        end
    end
end

--增加阴影
function FriendRoomRedPacket:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end
--返回网络图片
function FriendRoomRedPacket:onResponseNetImg(fileName)
    Log.i("------FriendRoomRedPacket:onResponseNetImg fileName", fileName);
    if kServerInfo:getMainAdUrl2() == fileName then
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        if io.exists(imgFile) then
            self.bg:loadTexture(imgFile);
        end 
    end
end

function FriendRoomRedPacket:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.closeBtn then
		   UIManager:getInstance():popWnd(FriendRoomRedPacket);
        end
    end
end

FriendRoomRedPacket.s_socketCmdFuncMap = {

};
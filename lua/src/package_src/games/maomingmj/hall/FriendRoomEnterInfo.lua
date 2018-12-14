--
-- Author: Van
-- Date: 2017-09-15 09:33:57
--

--创建与进入房间UI
FriendRoomEnterInfo = class("FriendRoomEnterInfo", UIWndBase);

function FriendRoomEnterInfo:ctor(...)
    self.super.ctor(self.super, "hall/friendRoomEnterInfo.csb", ...);
    self.m_data=...;
end

function FriendRoomEnterInfo:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	
end

function FriendRoomEnterInfo:onInit()

   self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_sure");
   self.btn_sure:addTouchEventListener(handler(self, self.onClickButton));

   self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close");
   self.btn_close:addTouchEventListener(handler(self, self.onClickButton));
  
   self:addShowder()

   self:updateUI()
   
end

--增加阴影
function FriendRoomEnterInfo:addShowder()
  
end

function FriendRoomEnterInfo:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_sure or pWidget == self.btn_close then
			    UIManager:getInstance():popWnd(FriendRoomEnterInfo);
        end
    end
end

--
function FriendRoomEnterInfo:updateUI()
    
	local tmpData = kFriendRoomInfo:getSelectRoomInfo();
  local roomInfo = kFriendRoomInfo:getRoomInfo();
  Log.i("房主所设置游戏信息：", tmpData);
 
	--牌局
  local  nameLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
	local retName = ToolKit.subUtfStrByCn(tmpData.niN,0,5,"")
  nameLabel:setString(string.format("%s的牌局",retName))

   --游戏名字
  local  gameName= ccui.Helper:seekWidgetByName(self.m_pWidget, "label_name");
  -- Util.printAllChildren(self.m_pWidget)
  gameName:setString(roomInfo.gaN or "麻将")

  local  gameNameTitle= ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_17_0");
  Log.i("--wangzhi--gameNameTitle--",gameNameTitle:getString())
  if roomInfo.gaN == "斗地主" then
      gameNameTitle:setString("棋牌类型:")
  end
   
  --局数
	local sushouLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_count");
   -- if tmpData.RoJST == 3 then
   --      sushouLabel:setString(string.format("%s局(每人%s钻)",tmpData.roS,tmpData.RoFS))
   --  else
        sushouLabel:setString(string.format("%s局(%s钻)",tmpData.roS,tmpData.RoFS))
    -- end

  --人数
  local label_player_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_player_num");
  label_player_num:setString(string.format("%s人",roomInfo.plS))
	
  --房费
  local label_pay = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_pay");
  -- label_player_num:setString(string.format("%s人",tmpData.plS))
  if tmpData.RoJST == 1 then          --是否需要考虑写成可拓展可配置的？
      label_pay:setString("房主付费")
  elseif tmpData.RoJST == 2 then
      label_pay:setString("大赢家付费")
  elseif tmpData.RoJST == 3 then
      label_pay:setString("AA付费")
  end

	--胡牌后加底:
    -- local boomNumLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "boomNumLabel");
    -- boomNumLabel:setString(string.format("%s底",tmpData.ji))

	--玩法
    local playingListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "playingListView");
    playingListView:removeAllChildren()
   	local itemList=Util.analyzeString_2(tmpData.wa);
    local playingInfo = self:getPlayingInfo()
	if(#playingInfo>0) then
	   for i=1,#playingInfo do
		local w = playingInfo[i]
        local strRule = ""
        
		local ch = w
		local text = ccui.Text:create()
        text:setString(ch)
        text:setFontSize(36)
        text:setOpacity(200)
        text:setContentSize(cc.size(680,100))
        -- text:setColor(cc.c3b(0,0,0))
        text:setFontName("hall/font/fangzhengcuyuan.TTF")
        text:setAnchorPoint(cc.p(0,0.5))
		playingListView:pushBackCustomItem(text)
		text:setColor(cc.c3b(0,0,0))
		Log.i("玩法:",ch)
	   end
	end

end
function FriendRoomEnterInfo:getPlayingInfo()
local roomInfo      = kFriendRoomInfo:getRoomBaseInfo()
    local playerInfos   = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo = kFriendRoomInfo:getSelectRoomInfo();
    local playingInfo   = kFriendRoomInfo:getPlayingInfo()

    local ruleStr = {}
    for k, v in pairs(playingInfo) do
--        ruleStr = ruleStr..v
        table.insert(ruleStr,v)
    end
--     local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
--     local fenzhi = {
--         [1] = "1分2分",
--         [2] = "2分4分",
--         [5] = "5分10分",
--         [10] = "10分20分",
--     }
-- --    ruleStr = ruleStr.." "..fenzhi[ tonumber(palyingInfo.ji)]
--     table.insert(ruleStr,"  "..fenzhi[tonumber(palyingInfo.ji)])
--     if palyingInfo.fa ~=nil and palyingInfo.fa ~= "0" then
-- --        ruleStr = ruleStr.." "..palyingInfo.fa.."马"
--         table.insert(ruleStr,"  "..palyingInfo.fa.."马")
--     end

    return ruleStr
end
return FriendRoomEnterInfo
--endregion

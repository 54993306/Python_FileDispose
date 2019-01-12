--
-- Author: Van
-- Date: 2017-09-15 09:33:57
--

--创建与进入房间UI
FriendRoomEnterInfo = class("FriendRoomEnterInfo", UIWndBase);
local UITool = require("app.common.UITool")
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

    UITool.setTitleStyle(ccui.Helper:seekWidgetByName(self.m_pWidget,"lab_title"))
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
  Log.i("房主所设置游戏信息：", tmpData,roomInfo);
 
	--牌局
  local  nameLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "nameLabel");
	local retName = ToolKit.subUtfStrByCn(tmpData.niN,0,5,"")
  nameLabel:setString(string.format("%s的牌局",retName))

   --游戏名字
  local  gameName= ccui.Helper:seekWidgetByName(self.m_pWidget, "label_name");
  gameName:setString(roomInfo.gaN or "麻将")

  local  gameNameTitle= ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_17_0");
  -- if roomInfo.gaN == "斗地主" then
      gameNameTitle:setString("游戏类型:")
  -- end

   
  --局数
	local sushouLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_count");
    if roomInfo.RoJST == 3 then
        local zhuanshi = math.ceil( tonumber(tmpData.RoFS)/tonumber(roomInfo.plS))
        sushouLabel:setString(string.format("%s局(每人%s钻)",tmpData.roS,zhuanshi))
    else
        sushouLabel:setString(string.format("%s局(%s钻)",tmpData.roS,tmpData.RoFS))
    end
    sushouLabel:getLayoutParameter():setMargin({left = sushouLabel:getLayoutParameter():getMargin().left-30,top = sushouLabel:getLayoutParameter():getMargin().top})
  --人数
  local label_player_num = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_player_num");
  label_player_num:setString(string.format("%s人",roomInfo.plS))
	
  --房费
  local label_pay = ccui.Helper:seekWidgetByName(self.m_pWidget, "label_pay");
  -- label_player_num:setString(string.format("%s人",tmpData.plS))

  if roomInfo.clI and roomInfo.clI > 0 then
    label_pay:setString("亲友圈付费")
  else
      if roomInfo.RoJST == 1 then          --是否需要考虑写成可拓展可配置的？
        label_pay:setString("房主付费")
    elseif roomInfo.RoJST == 2 then
        label_pay:setString("大赢家付费")
    elseif roomInfo.RoJST == 3 then
        label_pay:setString("AA付费")
    end
  end


	--胡牌后加底:
    -- local boomNumLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "boomNumLabel");
    -- boomNumLabel:setString(string.format("%s底",tmpData.ji))

	--玩法
  local playingListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "playingListView");
  playingListView:removeAllChildren()
 	local itemList=Util.analyzeString_2(tmpData.wa);
	if(#itemList>0) then
    for i=1,#itemList do
    		local w = itemList[i]
        if roomInfo.gaN == "跑得快" then 
            if kFriendRoomInfo:getPlayingInfoByTitle2(w) then
                local ch ="  " .. kFriendRoomInfo:getPlayingInfoByTitle2(w).ch;
                local text = ccui.Text:create()
                text:setString(ch)
                text:setFontSize(36)
                text:setOpacity(200)
                text:setColor(cc.c3b(0,0,0))
                text:setFontName("hall/font/fangzhengcuyuan.TTF")
                text:setAnchorPoint(cc.p(0,0.5))
                playingListView:pushBackCustomItem(text)

                Log.i("玩法:",ch)
            end
        elseif kFriendRoomInfo:getPlayingInfoByTitle(w) then
      		local ch ="  " .. kFriendRoomInfo:getPlayingInfoByTitle(w).ch;
      		local text = ccui.Text:create()
          text:setString(ch)
          text:setFontSize(36)
          text:setOpacity(200)
          text:setColor(cc.c3b(0,0,0))
          text:setFontName("hall/font/fangzhengcuyuan.TTF")
          text:setAnchorPoint(cc.p(0,0.5))
      		playingListView:pushBackCustomItem(text)
    		
    		  Log.i("玩法:",ch)
        end
    end
	end
end
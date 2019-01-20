--排行榜ui
RankingMatchUI = class("RankingMatchUI", UIWndBase);

local RankingNode= require "app.hall.wnds.ranking.RankingNode"


function RankingMatchUI:ctor(...)
    self.super.ctor(self, "hall/ranking/RankingMatch.csb", ...);
	self.m_maxNum=3;--最多显示3个
	self.m_socketProcesser = RankingSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end

function RankingMatchUI:onClose()
    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
end

function RankingMatchUI:onInit()
 
   --关闭按钮
   self.closeButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "closeButton");
   self.closeButton:addTouchEventListener(handler(self, self.onCloseButton));
   --详情按钮
   self.jiangqingButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "jiangqingButton");
   self.jiangqingButton:addTouchEventListener(handler(self, self.onJiangQingButton));
   --排名按钮
   self.baimingButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "baimingButton");
   self.baimingButton:addTouchEventListener(handler(self, self.onBaiMingButton));
   --领取奖励
   self.getWardButton = ccui.Helper:seekWidgetByName(self.m_pWidget, "getWardButton");
   
   --我的排名信息描述 
   self.baiMingLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "baiMingLabel"); 
  
   --增加阴影
   self:addShowder()
end

-- 响应窗口显示
function RankingMatchUI:onShow()
   self.m_rankingEnterData = kRankingSystem:getRankingEnterData();
   --玩家不能领取奖励
   if(self.m_rankingEnterData.btS==0) then 
       self.getWardButton:loadTextureNormal("real_res/1004775.png")
   else
       self.getWardButton:loadTextureNormal("real_res/1004774.png")
       self.getWardButton:addTouchEventListener(handler(self, self.onGetWardButton));
   end

   --我的排名信息描述
   local s =""
   if(self.m_rankingEnterData.myR<=0) then
      s = string.format("我的排名:未上榜       开房%d次",self.m_rankingEnterData.myRN);
   else
      s = string.format("我的排名:%d       开房%d次",self.m_rankingEnterData.myR,self.m_rankingEnterData.myRN);
   end
   self.baiMingLabel:setString(s);

   --活动状态和剩余时间
   local ativeTimetitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "ativeTimetitle");
   local ativeTimeNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "ativeTimeNum");
   local ativeTimetitle2 = ccui.Helper:seekWidgetByName(self.m_pWidget, "ativeTimetitle2");
   ativeTimetitle:setVisible(true);
   ativeTimeNum:setVisible(true);
   ativeTimetitle2:setVisible(true);
	   
   local d=0;
   local dataUnit=""
   if(self.m_rankingEnterData.leH>=24)then--距下一阶段剩余时间（单位：小时，0为已结束）
        d = math.floor(self.m_rankingEnterData.leH / 24)
		dataUnit="天"
   else
        d = self.m_rankingEnterData.leH 
		dataUnit="小时"
   end 
   ativeTimeNum:setString(""..d);   
	
   --活动状态（1：未开始 2：活动阶段 3：领奖阶段 4：已结束）
   if(self.m_rankingEnterData.acS==1)then

   elseif(self.m_rankingEnterData.acS==2)then
       ativeTimetitle:setString("活动剩余:");
	   ativeTimetitle2:setString(dataUnit);
   elseif(self.m_rankingEnterData.acS==3)then
       ativeTimetitle:setString("领奖剩余:");
	   ativeTimetitle2:setString(dataUnit);
   elseif(self.m_rankingEnterData.acS==4)then
       ativeTimetitle:setString("活动已结束");
       ativeTimeNum:setVisible(false);
	   ativeTimetitle2:setVisible(false);
   end
      
   local tipLabel = ccui.Helper:seekWidgetByName(self.m_pWidget, "tipLabel");
   local rd = kRankingSystem:getRankingDataArray();
   if(#rd<=0)then
       tipLabel:setVisible(true);
   else
       tipLabel:setVisible(false);
	   self.m_headImageList={}
	   local rankingNode = RankingNode.new();
	   local infoListView = ccui.Helper:seekWidgetByName(self.m_pWidget, "infoListView"); 
	   infoListView:removeAllChildren()
	   local rankingNodeCSB = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/ranking/RankingNode.csb"); 
	   local playerInfoPanel = ccui.Helper:seekWidgetByName(rankingNodeCSB, "playerInfoPanel");
      
	   for i=1,#rd do
	   
	     if(i>self.m_maxNum) then break end;
		 local v = rd[i];
		 local cloneUI = playerInfoPanel:clone();
		 infoListView:addChild(cloneUI)
		 rankingNode:updateUI(cloneUI,v);
		
		 --动态拉取玩家头像
		 local headImageUI = rankingNode:getHeadImage(cloneUI)
         self.m_headImageList[i] = headImageUI;
         local imgUrl = v.ic;
         Log.i("------imgUrl", imgUrl);
         if string.len(imgUrl) > 4 and string.sub(imgUrl,1,4) == "http" then
			local imgName = v.usI .. ".jpg";
			local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
			if io.exists(headFile) then
               headImageUI:loadTexture(headFile);
            else
               HttpManager.getNetworkImage(imgUrl,imgName);
		    end
         end
		 
	    end
   end
end

--增加阴影
function RankingMatchUI:addShowder()
  --self:getWidget(self.m_pWidget,"Label_23",{shadow=true})
  --self:getWidget(self.m_pWidget,"Label_5",{shadow=true})
end

--关闭按钮
function RankingMatchUI:onCloseButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():popWnd(RankingMatchUI);
    end
end

--详情按钮
function RankingMatchUI:onJiangQingButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
		UIManager:getInstance():pushWnd(RankingSpecification);
    end
end

--排名按钮
function RankingMatchUI:onBaiMingButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    local tmpData={}
		tmpData.pa=0;
		tmpData.buI=0;
	    RankingSocketProcesser.sendAllRankingData(tmpData)
    end
end

--获取奖励按钮
function RankingMatchUI:onGetWardButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    --根据奖励类型出现不同ui  服务器信息： btS  int  按钮状态（0：不能领取  1：实物，弹出界面  2：非实物，直接领取）
		if(self.m_rankingEnterData.btS==1) then
	        UIManager:getInstance():pushWnd(RankingAddressNameInfo);
		elseif(self.m_rankingEnterData.btS==2) then
		    RankingSocketProcesser.sendRankingAwardResult();
		end
    end
end

function RankingMatchUI:keyBack()
    UIManager:getInstance():popWnd(RankingMatchUI);
end

--接收所有排行榜数据
function RankingMatchUI:recvRankingNextPageData(packetInfo)
   UIManager:getInstance():pushWnd(RankingInfo,packetInfo);
end

--获取奖励结果
function RankingMatchUI:recvRankingAwardResult(packetInfo)
 --##  re  int  结果(0:操作成功 1:未上榜 2:无奖励 3:实物奖励)
 if(packetInfo.re==0)then
    --已经在用户数据增加相关获取钻石功能
 elseif(packetInfo.re==4) then
    Toast.getInstance():show("活动已经结束");
 end
end

--返回网络图片
function RankingMatchUI:onResponseNetImg(fileName)
    Log.i("------RankingMatchUI:onResponseNetImg fileName", fileName);
    if fileName == nil then
        return;
    end
	local rd = kRankingSystem:getRankingDataArray();
	for i=1,#rd do
	    if(i>self.m_maxNum) then break end; --最多只显示3个
	    local v=rd[i]
	    local imgName = v.usI .. ".jpg"
	    if fileName == imgName then
		    local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
			if io.exists(headFile) then
               self.m_headImageList[i]:loadTexture(headFile);
            end
        end
	end
end

--更新ui(排名和领奖状态)
--[[function RankingMatchUI:recvRankingData(packetInfo)
    Log.i("更新ui(排名和领奖状态)");
	self:onShow();
end]]

RankingMatchUI.s_socketCmdFuncMap = {
 --[HallSocketCmd.CODE_RECV_RANKING_GETRANKINGDATA] = RankingMatchUI.recvRankingData; --接收排行榜UI数据
 [HallSocketCmd.CODE_RECV_RANKING_ALLDATA_Next] = RankingMatchUI.recvRankingNextPageData, --接收所有排行榜数据
 [HallSocketCmd.CODE_RECV_RANKING_GETAWARDRESULT] = RankingMatchUI.recvRankingAwardResult,
};
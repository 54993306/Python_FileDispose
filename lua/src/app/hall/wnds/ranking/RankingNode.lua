--玩家排名节点信息:第几名，姓名。id, 头像等
--
local RankingNode = class("RankingNode")

function RankingNode:ctor(...)
   
end

function RankingNode:dtor()

end

function RankingNode:setDelegate(delegate)
    self.m_delegate = delegate;
end

--更新ui数据
function RankingNode:updateUI(cloneUI,tmpData)
   --排名数字
   local baimingLabel = ccui.Helper:seekWidgetByName(cloneUI, "baimingLabel"); 
   --排名图片 1，2，3名才显示
   local paiMingImage = ccui.Helper:seekWidgetByName(cloneUI, "paiMingImage"); 
   if(tmpData.ra> 0  and tmpData.ra<=3) then
        paiMingImage:setVisible(true);
		baimingLabel:setVisible(false);
        paiMingImage:loadTexture("hall/ranking/bai_" .. tmpData.ra .. ".png" );
   else
        baimingLabel:setVisible(true);
		paiMingImage:setVisible(false);
        baimingLabel:setString(tmpData.ra .. "");
   end
   

   --玩家名字
   local nameLabel = ccui.Helper:seekWidgetByName(cloneUI, "nameLabel"); 
   local retName = ToolKit.subUtfStrByCn(tmpData.na, 0, 6, "...");
   -- nameLabel:setString(retName);
   Util.updateNickName(nameLabel, retName)
   
   --玩家ID
   local IDNumberLabel = ccui.Helper:seekWidgetByName(cloneUI, "IDNumberLabel"); 
   IDNumberLabel:setString("" .. tmpData.usI);
   --开房次数
   local openRoomNum = ccui.Helper:seekWidgetByName(cloneUI, "openRoomNum"); 
   openRoomNum:setString("" .. tmpData.roN .."次");
   
   --奖励名称
   local getwardLabel = ccui.Helper:seekWidgetByName(cloneUI, "getwardLabel"); 
   local s = kRankingSystem:getRewardDescribing(tmpData.reI)
   getwardLabel:setString(s);
  
end

--获取玩家头像
function RankingNode:getHeadImage(cloneUI)
    --头像
    local headImage = ccui.Helper:seekWidgetByName(cloneUI, "headImage"); 
	return headImage;
end

return RankingNode;
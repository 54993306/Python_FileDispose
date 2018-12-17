--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

function FriendRoomScene:updateUI()
    
	local roomInfo      = kFriendRoomInfo:getRoomBaseInfo()
    local playerInfos   = kFriendRoomInfo:getRoomInfo();
    local selectSetInfo = kFriendRoomInfo:getSelectRoomInfo();
    local playingInfo   = kFriendRoomInfo:getPlayingInfo()

    --房间号
    local roomNumberLabel= ccui.Helper:seekWidgetByName(self.m_pWidget, "roomNumberLabel");
    roomNumberLabel:setFontName("hall/font/fangzhengcuyuan.TTF")
    roomNumberLabel:setString(string.format("房间号:%d", playerInfos.pa));
    self:playerListViewUpdate();

    local ruleStr = ""
    for k, v in pairs(playingInfo) do
        ruleStr = ruleStr..v
    end
    -- local palyingInfo = kFriendRoomInfo:getSelectRoomInfo()
    -- local fenzhi = {
    --     [1] = "1分2分",
    --     [2] = "2分4分",
    --     [5] = "5分10分",
    --     [10] = "10分20分",
    -- }
    -- ruleStr = ruleStr.." "..fenzhi[ tonumber(palyingInfo.ji)]
    -- if palyingInfo.fa ~=nil and palyingInfo.fa ~= "0" then
    --     ruleStr = ruleStr.." "..palyingInfo.fa.."马"
    -- end

    if #playingInfo > 0 then
        local ruleTip = self:createRuleTip(ruleStr)
        local x, y = self.ruleText[1]:getPosition()
        ruleTip:setPosition(cc.p(x, y))
        self.ruleText[1]:setAnchorPoint(cc.p(0.5, 1))
        ruleTip:setAnchorPoint(self.ruleText[1]:getAnchorPoint())
        self.ruleText[1]:getParent():addChild(ruleTip, 10)
    end
end
return FriendRoomScene

--endregion

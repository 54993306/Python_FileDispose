-------------------------------------------------------------
--  @file   LiangYouClubTips.lua
--  @brief  粮油活动Club展示界面
--  @author army
--  @DateTime:2018-09-13
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

local LiangYouClubTips = class("LiangYouClubTips", UIWndBase)

function LiangYouClubTips:ctor(...)
    self.super.ctor(self, "hall/liangyouClubTipsView.csb", ...)
end

function LiangYouClubTips:onInit()

    -- local data = {}
    -- data.status = 0
    -- self:HttpRequestFunc(data)
    local viewBg = ccui.Helper:seekWidgetByName(self.m_pWidget,"itemModel_club")
    local nodeSize = self.m_pWidget:getContentSize()
    self.m_pWidget:setPosition(cc.p(display.cx - nodeSize.width/2,140))
    self:onLostFocus()

    self.m_ScrollView = ccui.Helper:seekWidgetByName(self.m_pWidget,"ScrollView")
    -- item_ListView:setVisible(false)
    self.m_content_Panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"content_Panel")
    -- self.m_content_Panel:setVisible(false)
    
    local curUserid = kUserInfo:getUserId()
    local userToken = kUserInfo:getUserToken()
    -- local url = "http://192.168.7.26:18603/PullNewUserByoil/winnerList"
    -- local htURL = string.format("%s?userid=%s&product_id=%s&usertoken=%s&clubid=%s",url,curUserid,PRODUCT_ID,userToken,self.m_data.clubid)
    -- self:getURLData(htURL,function(data) self:HttpRequestFunc(data) end)

    self:HttpRequestFunc(self.m_data.activityData)
end

function LiangYouClubTips:onResume( )
    Log.i("回到最上层")
    self:onLostFocus()
    self.m_pBaseNode:setVisible(false)
    UIManager:getInstance():popWnd(LiangYouClubTips)
end
function LiangYouClubTips:HttpRequestFunc(data)
    Log.i("HttpRequestFunc...",data.data)
    -- if tonumber(data.status) ~= 0 then
    --     Toast:getInstance():show("获取列表失败")
    --     UIManager:getInstance():popWnd(LiangYouClubTips)
    -- end
    
    local scrollView    = ccui.Helper:seekWidgetByName(self.m_pWidget,"ScrollView")
    local aa = {1,2,3,4,5}

    local function scrollFunc(data,mWight,nIndex,from)
		self:setContentPanel(data,mWight,nIndex,from)
	end
    self.scrollViewUI = new_cScrollView(scrollView,self.m_content_Panel,data,scrollFunc,5,5)
end

function LiangYouClubTips:setContentPanel(data,mWight,nIndex,from)
    local name_Label = ccui.Helper:seekWidgetByName(mWight,"name_Label")
    name_Label:setColor(cc.c4b(245, 162, 12,255))
    name_Label:enableShadow(cc.c4b(255, 162, 12,255),cc.size(0.5,-0.5))
    local nickName = ToolKit.subUtfStrByCn(data.winner_name,0,3,"")
    local nickWidth,nickNumber = Util.getTextWidth(nickName,30)
    if nickNumber == 1  then
        nickName = nickName.."****"
    else
        nickName = nickName.."***"
    end
    Util.updateNickName(name_Label, nickName, 19)
    local jiangli_Label = ccui.Helper:seekWidgetByName(mWight,"jiangli_Label")
    jiangli_Label:setString(data.gift_name)
    jiangli_Label:enableShadow(cc.c4b(255, 162, 12,255),cc.size(0.5,-0.5))

    self.m_pWidget:performWithDelay(function()
        UIManager:getInstance():popWnd(LiangYouClubTips)
    end,5)
end

return LiangYouClubTips
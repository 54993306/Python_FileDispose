-- 牌局中消息处理
-- local Define 			= require "app.games.common.Define"
local MjGameSocketProcesserSuper = require("app.games.common.mediator.MjGameSocketProcesser")
local branchMjGameSocketProcesser = class("branchMjGameSocketProcesser", MjGameSocketProcesserSuper)

function branchMjGameSocketProcesser:ctor( ... )
	print("sunbinlog:-----------------branchMjGameSocketProcesser")
	self.super.ctor(self, ...)
end

function branchMjGameSocketProcesser:repPromptInfo(cmd, packetInfo)
    Log.i("麻将信息提示 1 包牌提示 2 不能胡提示 3 不杠不算分提示",packetInfo);
    local m_pWidget=nil;
    if packetInfo.type==1 then --1 包牌提示 2 不能胡提示
       m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mjGameCrossband.csb")
    elseif packetInfo.type==2 then 
       m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mjGameFanHuCrossband.csb")
    else
       m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/mjGameCrossband.csb")
    end 
	display.getRunningScene():addChild(m_pWidget);
	m_pWidget:setName("repPrompt")
		
	local text = ccui.Helper:seekWidgetByName(m_pWidget,"text")
	text:setString(packetInfo.text);
	
	local w = text:getContentSize().width;
	local midPanel = ccui.Helper:seekWidgetByName(m_pWidget,"midPanel")
	local tw = w+35;
	midPanel:setContentSize(cc.size(tw,midPanel:getContentSize().height));
	m_pWidget:setPosition(cc.p(display.width/2,220));
	midPanel:setAnchorPoint(0.5,0.5);
	
    
    if packetInfo.type==3 then 
	    local cloneText = text:clone()
	    text:removeFromParent()
	    midPanel:addChild(cloneText)
	    cloneText:setString(packetInfo.text)
	    cloneText:ignoreContentAdaptWithSize(false)
	    cloneText:setContentSize(cc.size(220, 60))
	    cloneText:setPosition(18, 65)
	    cloneText:setAnchorPoint(cc.p(0, 1))
        cloneText:setFontSize(20)
        midPanel:setContentSize(cc.size(260, 80));
        m_pWidget:setPosition(cc.p(display.width/2 + 70, 340));
        midPanel:setAnchorPoint(0,0.5);
        m_pWidget:setVisible(false)
    else
		Util.runScaleToHideAction(midPanel,m_pWidget,0.1,6);
    end

end

branchMjGameSocketProcesser.s_severCmdEventFuncMap[enMjMsgReadId.MSG_READ_PROMPT_INFO] = branchMjGameSocketProcesser.repPromptInfo

return branchMjGameSocketProcesser
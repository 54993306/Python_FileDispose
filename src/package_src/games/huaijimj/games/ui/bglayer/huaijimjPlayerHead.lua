local PlayerHead = require("app.games.common.ui.bglayer.PlayerHead")
local huaijimjPlayerHead = class("huaijimjPlayerHead", PlayerHead)

function huaijimjPlayerHead:ctor(data)
	self.super.ctor(self, data)
end

function huaijimjPlayerHead:showLapaozupOp(site, visible)
	Log.i("<sunbin>: in huijiHead ", visible)
	--parseLaPaoZuoWidget(self.panel_heads[site], "la_panel", "text_la", num)
    local paoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_pao")
    if paoIcon then
    	paoIcon:setVisible(visible)
    end
    local diIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_di")
    if diIcon then
    	diIcon:setVisible(visible)
    end
    local zuoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_zuo")
    if zuoIcon then
    	zuoIcon:setVisible(visible)
    end
end



return huaijimjPlayerHead 
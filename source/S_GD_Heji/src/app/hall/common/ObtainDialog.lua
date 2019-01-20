local PROP_IMG_MAP = require("app.games.common.common.PropImageDef")
local ObtainDialog = class("ObtainDialog", UIWndBase)

function ObtainDialog:ctor()
    self.super.ctor(self, "hall/obtain_prop_dialog.csb")
end

function ObtainDialog:onInit()
	self.lqBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_lq")
    self.icon = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_icon")
    self.addNum = ccui.Helper:seekWidgetByName(self.m_pWidget, "BitmapLabel_addNum")
    self.effect = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_effect")

    self.effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 180)))
	self.lqBtn:addTouchEventListener(handler(self, self.onClick))

    if not IsPortrait then -- TODO    
        self.m_pWidget:runAction(cc.Sequence:create(cc.DelayTime:create(500),cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
            self:keyBack() 
        end)))
    end
end

function ObtainDialog:setPropData(propType, num, propIconUrl)
    self.icon:loadTexture(PROP_IMG_MAP[propType])
    if propType == 2 then -- 元宝的情况
        self.icon:setScale(2)
    end
    self.addNum:setString("+"..num)
    self.propType = propType;
    self.propNum = num
    self:starEffect(self.icon, 70, 70)
end

-- btn_about
function ObtainDialog:starEffect(pWidget,x,y)
    math.randomseed(os.time())
    local data  = {}
    data.widget = pWidget
    data.x      = x
    data.y      = y

    local romdomSet = cc.CallFunc:create(handler(data,function(data)
        local num = math.random(1,3)
        for i=1,num do
            local spark = display.newSprite("real_res/1004409.png")
            spark:setOpacity(0)
            local delay = cc.DelayTime:create(math.random(3,8)/10)
            local fadein = cc.FadeIn:create(0.5)
            local fadeout = cc.FadeOut:create(0.25)
            local removeself = cc.RemoveSelf:create()
            spark:setPosition(cc.p(math.random(10,data.x), math.random(10,data.y)))
            spark:setScale(math.random(3,8)/10)
            local act = cc.Sequence:create(delay,fadein,fadeout,removeself)
            spark:runAction(act)
            data.widget:addChild(spark)
        end
    end))
    pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),romdomSet)))
end

function ObtainDialog:onClick(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if self.propType == 1 then
            local preVal = CommonAnimManager.getInstance():getHideMoneyWinAnim()
            CommonAnimManager.getInstance():setHideMoneyWinAnim(false)
            CommonAnimManager.getInstance():showMoneyWinAnim()
            Toast.getInstance():show("获得"..tostring(self.propNum).."钻石");
            CommonAnimManager.getInstance():setHideMoneyWinAnim(preVal)
        elseif self.propType == 2 then
            if IsPortrait then -- TODO
                Toast.getInstance():show("获得"..tostring(self.propNum).."元宝");
            else
                Toast.getInstance():show("获得"..tostring(self.propNum).."金元宝");
            end
        end
	    UIManager:getInstance():popWnd(ObtainDialog);
    end
end

return ObtainDialog
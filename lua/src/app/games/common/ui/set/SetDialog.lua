
local SetDialog = class("SetDialog", function ()
    return display.newLayer()
end)

function SetDialog:ctor()
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/common/setting.csb");
   	self.m_pWidget:setTouchEnabled(true);
    self.m_pWidget:setTouchSwallowEnabled(true);
    self.m_pWidget:addTo(self)
    self.m_pWidget:addTouchEventListener(handler(self, self.onClickButton));
    self.Btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"Btn_close");
    self.Btn_close:addTouchEventListener(handler(self, self.onClickButton));
    
    local Pan_bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"Pan_bg");
    --背景音乐设置
    local onImageMusic =  cc.MenuItemImage:create("games/common/common/common/set/set_switch_on.png", "games/common/common/common/set/set_switch_on.png")
    local offImageMusic = cc.MenuItemImage:create("games/common/common/common/set/set_switch_off.png", "games/common/common/common/set/set_switch_off.png")
    local toggleClickMusic = cc.MenuItemToggle:create( onImageMusic, offImageMusic )
    if MjProxy.getInstance():getMusicPlaying() then
        toggleClickMusic:setSelectedIndex(0)
        audio.resumeMusic()
    else
        toggleClickMusic:setSelectedIndex(1)
        audio.pauseMusic()
    end
    toggleClickMusic:registerScriptTapHandler(handler(self, function ()
	    if toggleClickMusic:getSelectedIndex() == 0 then
            audio.resumeMusic()
            MjProxy.getInstance():setMusicPlaying(true)
	    elseif toggleClickMusic:getSelectedIndex() == 1 then
            audio.pauseMusic()
            MjProxy.getInstance():setMusicPlaying(false)
	    end
    end)) 
    local Lab_music = ccui.Helper:seekWidgetByName(Pan_bg,"Lab_music");
    toggleClickMusic:setPosition(cc.p(Lab_music:getPositionX() + 230 , Lab_music:getPositionY()))
    --音效设置
    local onImageSound =  cc.MenuItemImage:create("games/common/common/common/set/set_switch_on.png", "games/common/common/common/set/set_switch_on.png")
    local offImageSound = cc.MenuItemImage:create("games/common/common/common/set/set_switch_off.png", "games/common/common/common/set/set_switch_off.png")
    local toggleClickSound = cc.MenuItemToggle:create( onImageSound, offImageSound )
    if MjProxy.getInstance():getSoundPlaying() then
        toggleClickSound:setSelectedIndex(0)
        audio.resumeAllSounds()
    else
        toggleClickSound:setSelectedIndex(1)
        audio.stopAllSounds()
    end
    
    toggleClickSound:registerScriptTapHandler(handler(self, function ()
	    if toggleClickSound:getSelectedIndex() == 0 then
            audio.resumeAllSounds()
            MjProxy.getInstance():setSoundPlaying(true)
	    elseif toggleClickSound:getSelectedIndex() == 1 then
            audio.stopAllSounds()
            MjProxy.getInstance():setSoundPlaying(false)
	    end
    end)) 
    local Lab_sound = ccui.Helper:seekWidgetByName(Pan_bg,"Lab_sound");
    toggleClickSound:setPosition(cc.p(Lab_sound:getPositionX() + 230 , Lab_sound:getPositionY()))

    -- -- 方言开关
    local onImage2 =  cc.MenuItemImage:create("games/common/common/common/set/set_switch_on.png", "games/common/common/common/set/set_switch_on.png")
    local offImage2 = cc.MenuItemImage:create("games/common/common/common/set/set_switch_off.png", "games/common/common/common/set/set_switch_off.png")
    local toggleDialectItem = cc.MenuItemToggle:create( onImage2, offImage2 )
    Log.i("MjProxy.getInstance():getDialectPlaying()....",MjProxy.getInstance():getDialectPlaying())
    if MjProxy.getInstance():getDialectPlaying() then
        toggleDialectItem:setSelectedIndex(0)
    else
        toggleDialectItem:setSelectedIndex(1)
    end
    toggleDialectItem:registerScriptTapHandler(handler(self, function ()
	    if toggleDialectItem:getSelectedIndex() == 0 then
            MjProxy.getInstance():setDialectPlaying(true)
	    elseif toggleDialectItem:getSelectedIndex() == 1 then
            MjProxy.getInstance():setDialectPlaying(false)
	    end
    end)) 
    local Lab_dialect = ccui.Helper:seekWidgetByName(Pan_bg,"Lab_dialect");

    toggleDialectItem:setPosition(cc.p(Lab_dialect:getPositionX() + 260 , Lab_dialect:getPositionY()))

    -- --出牌开关
    local onImage3 =  cc.MenuItemImage:create("games/common/common/common/set/set_switch_on.png", "games/common/common/common/set/set_switch_on.png")
    local offImage3 = cc.MenuItemImage:create("games/common/common/common/set/set_switch_off.png", "games/common/common/common/set/set_switch_off.png")   
    local toggleClickPokerItem = cc.MenuItemToggle:create( onImage3, offImage3 )
    if MjProxy.getInstance():getSinglePlaying() then
        toggleClickPokerItem:setSelectedIndex(0)
    else
        toggleClickPokerItem:setSelectedIndex(1)
    end
    toggleClickPokerItem:registerScriptTapHandler(handler(self, function ()
	    if toggleClickPokerItem:getSelectedIndex() == 0 then
            MjProxy.getInstance():setSinglePlaying(true)
	    elseif toggleClickPokerItem:getSelectedIndex() == 1 then
            MjProxy.getInstance():setSinglePlaying(false)
	    end
    end)) 
    local Lab_single_click = ccui.Helper:seekWidgetByName(Pan_bg,"Lab_single_click");

    toggleClickPokerItem:setPosition(cc.p(Lab_single_click:getPositionX() + 260 , Lab_single_click:getPositionY()))
	local menu = cc.Menu:create(toggleClickMusic, toggleClickSound, toggleDialectItem, toggleClickPokerItem)
	menu:setPosition(cc.p(0, 0))
	menu:addTo(Pan_bg)       
end
function SetDialog:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if pWidget == self.Btn_close or pWidget == self.m_pWidget then
            self:removeFromParent()
            SoundManager.playEffect("btn", false);
        end
    end
end
return SetDialog
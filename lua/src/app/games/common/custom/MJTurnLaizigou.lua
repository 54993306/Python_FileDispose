--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Define = require "app.games.common.Define"
--local WWFacade = require("app.games.common.custom.WWFacade")
local MJTurnLaizigou = class("MJTurnLaizigou", function ()
	return display.newNode()
end)

function MJTurnLaizigou:ctor(atomType)
    SoundManager.playEffect("lianglaizi", false);
--    local bg = display.newSprite("games/common/mj/games/laizidi.png")
--    bg:setPosition(cc.p(155+3,display.height - 51))
--    bg:addTo(self)
    self._myPoker = display.newSprite("#self_poker.png")
    local cardImage = getCardPngByValue(atomType)
    local myCard = display.newSprite("#" .. cardImage)
    myCard:addTo(self._myPoker)
    local pokerSz = self._myPoker:getContentSize()
    myCard:setPosition(cc.p(pokerSz.width/2,pokerSz.height/2-5))
    myCard:setScale(0.8)
    myCard:setName("myCard")
    self._myPoker:addTo(self)
    self._myPoker:setPosition(cc.p(display.cx,display.cy))
    self._myPoker:setScale(4)
    self:atomAnimation()
end
function MJTurnLaizigou:atomAnimation()
    local scaleto = cc.ScaleTo:create(0.5,0.5)
    local moveTo = cc.MoveTo:create(0.5,cc.p(250, display.height - 61))
    self._myPoker:runAction(cc.Sequence:create(scaleto,moveTo))
    local pokeSize = self._myPoker:getContentSize()
    local fjaoCallFunc = cc.CallFunc:create(function () 
        local laizifjaowijef = nil
        local gameid = MjProxy:getInstance():getGameId()
        if GC_TurnLaiziPath then
            laizifjaowijef = display.newSprite(GC_TurnLaiziPath)
        else
            laizifjaowijef = display.newSprite("games/common/mj/games/laizifjaowijef.png")
        end
        laizifjaowijef:addTo(self)
        laizifjaowijef:setPosition(cc.p(250+pokeSize.width/2-7,display.height-61))
        laizifjaowijef:setOpacity(0)
        laizifjaowijef:runAction(cc.FadeIn:create(1))
    end)
    self._myPoker:runAction(cc.Sequence:create(cc.DelayTime:create(1),fjaoCallFunc))
end

-- 改变翻子图片
function MJTurnLaizigou:changeTo(mjValue)
    local mjPng = getCardPngByValue(mjValue)
    if mjPng then
        local myCard = self._myPoker:getChildByName("myCard")
        if myCard then
            myCard:setSpriteFrame(display.newSpriteFrame(mjPng))
        end
    end
end

return MJTurnLaizigou

--endregion

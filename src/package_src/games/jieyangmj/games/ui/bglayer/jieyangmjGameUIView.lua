--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--local WWFacade = require("app.games.common.custom.WWFacade")
local Define = require "app.games.common.Define"
local GameUIView = require("app.games.common.ui.bglayer.GameUIView")

local jieyangmjGameUIView = class("jieyangmjGameUIView",GameUIView)
local Event_Signal  = "Event_Signal"
local Event_Battery = "Event_Battery"

function jieyangmjGameUIView:ctor(data)
    self.m_pWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/gameItem.csb");
    self.m_data = data
    self._selectBtn = {
        agree = false,
        agreeTime = 0.5,
    }
    self.finishXia = false -- 下嘴完成标志
    self.chaHuBtnStatus = 0 --查胡状态
    
    self.handlers = {};
    self.Events   = {};
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_dingque_Anim_start, 
        handler(self, self.onDingqueAnimStart)))
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(enMjPlayEvent.GAME_SET_CHAHU_BUTTON_STATUS_NTF, 
        handler(self, self.setChaHuButtonHide)))
    -- table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(MJ_EVENT.GAME_setRuleVisible, 
    --     handler(self, self.setRuleVisible)))
    self:listenerExit() 

    self:initRule()
end


--查胡状态
function jieyangmjGameUIView:checkChahuStatus()
    -- 如果在听之后才能显示胡牌提示, 那么非听牌状态直接return
    local players   = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayers()
    local huHintNeedTing = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):getIsHuHintNeedTing()
    local tingState = players[enSiteDirection.SITE_MYSELF]:getState(enCreatureEntityState.TING)
    if huHintNeedTing and (tingState == enTingStatus.TING_FALSE or tingState == enTingStatus.TING_BTN_OFF) then
        self.Button_chahu:setVisible(false)
        return
    end

    local playSystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM);
    local huCards = playSystem:gameStartLogic_getHuMjs();
    if #huCards > 0 then
        self.Button_chahu:setVisible(self.chaHuBtnStatus ~= 1);
    else
        self.Button_chahu:setVisible(false);
        MjMediator.getInstance():getEventServer():dispatchCustomEvent(enMjPlayEvent.GAME_SELECTED_CHAHU_NTF);
    end

end


return jieyangmjGameUIView
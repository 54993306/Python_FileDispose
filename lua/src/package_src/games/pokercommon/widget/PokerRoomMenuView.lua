--
-- Author: Your Name
-- Date: 2017-08-24 14:39:56
--
local PokerRoomMenuView = class("PokerRoomMenuView", PokerUIWndBase);
local PokerRoomDialogView = require("package_src.games.pokercommon.widget.PokerRoomDialogView")
local PokerRoomSettingView = require("package_src.games.pokercommon.widget.PokerRoomSettingView")
local PokerEventDef = require("package_src.games.pokercommon.data.PokerEventDef")

function PokerRoomMenuView:ctor(data)
    self.super.ctor(self, "package_res/games/pokercommon/room_menu2p.csb", data);
    self.gamepath = data.gamepath
    self.startNum = 2
    self.btnList = {}
    self.endPosList = {}
    self.btnSize = cc.size(307/2,408/2)
    self.posLimit = {
        maxY = display.height - 260,
        minY = 260,
        maxX = display.width - 300,
        minX = 300,
    }
    self.isRandom = false
end

function PokerRoomMenuView:onInit()
    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_setting");
    self.btn_setting:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_setting.posX = self.btn_setting:getPositionX()
    table.insert(self.endPosList,cc.p(self.btn_setting:getPositionX(),self.btn_setting:getPositionY()))

    self.btn_tuoguan = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_tuoguan");
    self.btn_tuoguan:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_tuoguan.posX = self.btn_tuoguan:getPositionX()
    table.insert(self.endPosList,cc.p(self.btn_tuoguan:getPositionX(),self.btn_tuoguan:getPositionY()))

    self.btn_exit = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_exit");
    self.btn_exit:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_exit.posX = self.btn_exit:getPositionX()
    table.insert(self.endPosList,cc.p(self.btn_exit:getPositionX(),self.btn_exit:getPositionY()))

    table.insert(self.btnList,self.btn_exit)
    table.insert(self.btnList,self.btn_setting)
    if HallAPI.DataAPI:isFriendRoom() then
        self.btn_tuoguan:setVisible(false)
        self.btn_exit:loadTextureNormal("common/jiesan.png",ccui.TextureResType.plistType)
    else
        table.insert(self.btnList,self.btn_tuoguan)
    end

    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_back");
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton));

    self.root = ccui.Helper:seekWidgetByName(self.m_pWidget,"root");
    self.root:addTouchEventListener(handler(self, self.onClickButton));
    self.root:setEnabled(true)

    if self.isRandom then
        self:randomPos()
    else
        self:startAnimation(self.endPosList)
    end
end

function PokerRoomMenuView:startAnimation(endPosList)
    local speed = 2500 --位移速度
    for i=#self.btnList,1,-1 do
        local startPos = cc.p(-230,self.btnList[i]:getPositionY())
        local endPos = endPosList[i]--cc.p(self.btnList[i].posX,self.btnList[i]:getPositionY())
        local distance = math.sqrt((startPos.x-endPos.x)*(startPos.x-endPos.x)+(startPos.y-endPos.y)*(startPos.y-endPos.y))
        self.btnList[i]:setPositionX(-230)
        self.btnList[i]:setRotation(-180)
        local seq = cc.Sequence:create(cc.DelayTime:create(0),cc.Spawn:create(cc.RotateTo:create(distance/speed,0),cc.MoveTo:create(distance/speed,endPos)))
        self.btnList[i]:runAction(seq)
    end
end


function PokerRoomMenuView:randomPos()
    local endPosList = {}
    for i = 0,#self.btnList do
        endPosList[i] = cc.p(math.random(self.posLimit.minX,self.posLimit.maxX),math.random(self.posLimit.minY,self.posLimit.maxY))
    end
    if self:checkCollision(endPosList) then
        self:randomPos()
    else
       self:startAnimation(endPosList)
    end
 end

 function PokerRoomMenuView:checkCollision(posList)
     for i=1,#posList do
         for j=1,#posList do
             if j ~= i then
                if posList[i].x <= posList[j].x and posList[i].y <= posList[j].y then
                    if posList[i].x + self.btnSize.width >= posList[j].x-self.btnSize.width and posList[i].y + self.btnSize.height >= posList[j].y - self.btnSize.height then
                        return true
                    end
                elseif posList[i].x >= posList[j].x and posList[i].y >= posList[j].y then
                    if posList[i].x -self.btnSize.width <= posList[j].x + self.btnSize.width and posList[i].y - self.btnSize.height <= posList[j].y + self.btnSize.height then
                        return true
                    end
                elseif posList[i].x <= posList[j].x and posList[i].y >= posList[j].y then
                    if posList[i].x + self.btnSize.width >= posList[j].x - self.btnSize.width and posList[i].y - self.btnSize.height <= posList[j].y + self.btnSize.height then
                        return true
                    end 
                elseif posList[i].x >= posList[j].x and posList[i].y <= posList[j].y then
                    if posList[i].x - self.btnSize.width <= posList[j].x - self.btnSize.width and posList[i].y + self.btnSize.height >= posList[j].y - self.btnSize.height then
                        return true
                    end
                end
             end
         end
     end
     return false
 end

function PokerRoomMenuView:onShow()
   
end

function PokerRoomMenuView:keyBack()
    PokerUIManager.getInstance():popWnd(self)
end

function PokerRoomMenuView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        self:keyBack()
        if pWidget == self.btn_setting then
            local data = {}
            data.gamepath = self.gamepath
            PokerUIManager:getInstance():pushWnd(PokerRoomSettingView, data)
            --HallAPI.ViewAPI:showSettingView()        
        elseif pWidget == self.btn_tuoguan  then
            HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_TUOGUAN, 1)
        elseif pWidget == self.btn_back then
        elseif pWidget == self.btn_exit then
            if HallAPI.DataAPI:isFriendRoom() then
                local data = {}
                data.title = "提示" 
                data.type = 2
                data.content = "确认申请解散牌局吗？\n\n解散后按目前得分最终排名。"
                --data.switchBtn = true
                data.yesCallback = function() 
                --[[
                    type = 2,code=22020, 私有房解散牌局问询  client  <-->  server
                    ##  usI  long  玩家id
                    ##  re  int  结果(-1:没有问询   0:还没有回应   1:同意  2:不同意)
                    ##  niN  String  发起的用户昵称
                    ##  isF  int  是否是刚发起的问询, 如果是刚发起的需要起定时器(0:是  1:不是)]]
                    local tmpData={}
                    tmpData.usI =  HallAPI.DataAPI:getUserId()
                    tmpData.re = 1
                    tmpData.niN = HallAPI.DataAPI:getUserName()
                    tmpData.isF = 0
                    -- HallAPI.DataAPI:send(CODE_TYPE_ROOM, DDZSocketCmd.CODE_FRIEND_ROOM_LEAVE,tmpData);
                    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_FRIEND_EXIT, tmpData)
                end

                data.cancalCallback = function()
                end

                data.yesCallback = function()
                end

                --data.switchBtn = true                           --互换按钮位置
                data.yesTitlePath = "btn/btn_certain.png"                               --确定按钮文本
                data.canTitlePath = "btn/btn_cancel.png"                            --取消按钮文本
                PokerUIManager:getInstance():pushWnd(PokerRoomDialogView, data)
                --HallAPI.ViewAPI:showCommonDialog(data)   
            else
                local data = {}
                data.type = 2;
                data.title = "提示";                        
                data.content = "现在离开会由笨笨的机器人代打哦！\n\n 输了不能怪它哟";
                data.yesCallback = function()
                    --朋友开房逻辑特殊处理
                    -- self.m_delegate:requestExitRoom();
                    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_COIN_EXIT)

                end
                PokerUIManager.getInstance():pushWnd(PokerRoomDialogView, data);
                --HallAPI.ViewAPI:showCommonDialog(data)
            end
        end;
    end
end

return PokerRoomMenuView
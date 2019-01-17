--
-- 玩家操作界面 (叫地主/抢地主/加倍/出牌/提示等)
--
local DDZRoomView = require("package_src.games.ddz.mediator.widget.DDZRoomView")
local DDZOprationView = class("DDZOprationView", DDZRoomView);
local DDZGameEvent = require("package_src.games.ddz.data.DDZGameEvent")
local DDZDataConst = require("package_src.games.ddz.data.DDZDataConst")
local DDZSocketCmd = require("package_src.games.ddz.proxy.delegate.DDZSocketCmd")
local PokerUtils = require("package_src.games.pokercommon.commontool.PokerUtils")
local DDZDefine = require("package_src.games.ddz.data.DDZDefine")
local DDZConst = require("package_src.games.ddz.data.DDZConst")
local DDZCard = require("package_src.games.ddz.utils.card.DDZCard")

local friendDefTimwe = 15

function DDZOprationView:initView()
    self.lb_time = self:getWidget(self.m_pWidget, "clock");
    if self.m_data == DDZConst.SEAT_MINE then
        self.btn_bjiao = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bjiao");
        self.btn_jiao = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_jiao");
        self.btn_bqiang = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bqiang");
        self.btn_qiang = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_qiang");
        self.btn_bjia = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bjia");
        self.btn_jia = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_jia");
        self.btn_bchu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bchu");
        self.btn_tshi = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_tshi");
        self.btn_chu = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_chu");
        --self.btn_cx = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_cx");

        self.btn_bjiao:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_jiao:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_bqiang:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_qiang:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_bjia:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_jia:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_bchu:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_tshi:addTouchEventListener(handler(self, self.onClickButton));
        self.btn_chu:addTouchEventListener(handler(self, self.onClickButton));
        --self.btn_cx:addTouchEventListener(handler(self, self.onClickButton));
    end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function DDZOprationView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        local isNotColse = false;
        local actionName = ""
        local gamePlayeId = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
        if pWidget == self.btn_bjiao then
            local data = {};
            data.gaPI = gamePlayeId
            data.fl = 0;
            data.usI = HallAPI.DataAPI:getUserId();
            -- print(debug.traceback("onClickButton"))
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_CALLLORD, data);
        elseif pWidget == self.btn_jiao then
            local data = {};
            data.gaPI = gamePlayeId
            data.fl = 1;
            data.usI = HallAPI.DataAPI:getUserId();
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_CALLLORD, data);
        elseif pWidget == self.btn_bqiang then
            local data = {};
            data.gaPI = gamePlayeId
            data.fl = 0;
            data.usI = HallAPI.DataAPI:getUserId();
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_ROBLORD, data);
        elseif pWidget == self.btn_qiang then
            local data = {};
            data.gaPI = gamePlayeId
            data.fl = 1;
            data.usI = HallAPI.DataAPI:getUserId();
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_ROBLORD, data);
        elseif pWidget == self.btn_bjia then
            self:buJiaCallBack()
        elseif pWidget == self.btn_jia then
            local data = {};
            data.gaPI = gamePlayeId
            data.usI = HallAPI.DataAPI:getUserId();
            data.cuD = 2;
            Log.i("--wangzhi--发送加倍--001--")
            HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_DOUBLE, data);
        elseif pWidget == self.btn_bchu then
            local info = {};
            info.action = "buchu"
            -- self.m_delegate:onClickBChuBtn(info);
            HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
        elseif pWidget == self.btn_tshi then
            local info = {};
            info.action = "tishi"
            -- self.m_delegate:onClickTShiBtn(info);
            HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
            isNotColse = true;
        elseif pWidget == self.btn_chu then
            local info = {};
            info.action = "chupai"
            local isLegal = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_SELECARDLEGAL)
            Log.i("+++++++++++++++++++++select++++++++++++++++++++++++ isLegal:", isLegal)
            if not isLegal or isLegal == 0 then
                PokerToast.getInstance():show("您选择的牌不符合规则")
                isNotColse = true
            else
                -- self.m_delegate:onClickChuBtn(info);
                HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
            end
        elseif pWidget == self.btn_cx then
            local info = {};
            info.action = "chongxuan"
            -- self.m_delegate:onClickChongXuanBtn(info);
            HallAPI.EventAPI:dispatchEvent(DDZGameEvent.UPDATEOPERATION, HallAPI.DataAPI:getUserId(), info)
            isNotColse = true;
        end;
        if not isNotColse then
            self:hideOpration();
        end
    end
end

function  DDZOprationView:buJiaCallBack()
    local gamePlayeId = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_GAMEPLAYID)
    local data = {};
    data.gaPI = gamePlayeId
    data.usI = HallAPI.DataAPI:getUserId();
    data.cuD = 1;
    Log.i("--wangzhi--发送加倍--002--")
    HallAPI.DataAPI:send(CODE_TYPE_GAME, DDZSocketCmd.CODE_SEND_DOUBLE, data);   
end

----------------------------------------------
-- @desc 显示玩家操作 
-- @pram info:显示玩家操作需要的相关信息
--       notUpdateTime:是否更新操作倒计时
----------------------------------------------
function DDZOprationView:showOpration(info, notUpdateTime)
    -- Log.i(debug.traceback(""))
    Log.i("DDZOprationView:showOpration",info, notUpdateTime)
    local player = self:getPlayerModel()
    local tuoguanState = player:getProp(DDZDefine.HASTUOGUAN)
    Log.i("tuoguanState ", tuoguanState)
    if tuoguanState == DDZConst.TUOGUAN_STATE_1 and self.m_data == 1 then
        return 
    end

    self.isBigger = info and info.isBigger
    self.playCard = info and info.playCard
    info = checktable(info);
    local status = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    Log.i("------showOpration gameStatus = ", status);
    self.m_pWidget:setVisible(true);

    if not notUpdateTime then
        local reconnectTime = DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LEFTTIME);
        DataMgr:getInstance():setObject(DDZDataConst.DataMgrKey_LEFTTIME, nil);
        if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
            self.m_Time = reconnectTime or (not self.isBigger and self.m_data == DDZConst.SEAT_MINE and self.playCard) and 5 or DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_LIMITTIME)
        else
            self.m_Time = friendDefTimwe
        end
        Log.i("self.lb_time:", reconnectTime);
        local strTime = self.m_Time
        if self.m_Time < 10 then
            strTime = "0" .. self.m_Time
        end
        self.lb_time:setString(strTime);
        self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateTime), 1);
    end

    if self.m_data == DDZConst.SEAT_MINE then
        self:showOprationBtns(info);
    end
end

----------------------------------------------
-- @desc 更新玩家操作 
-- @pram info:显示玩家操作需要的相关信息
--       handview:玩家的手牌的ui
----------------------------------------------
function DDZOprationView:updateOpration(info, handview)
    info = checktable(info);
    Log.i("--wangzhi--info--",info)
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS);
    if gameStatus == DDZConst.STATUS_PLAY then
        if info.action == "sort" then

        elseif info.action == "tishibuchu" then
            self:hideOpration();
        elseif info.action == "handCardSelect" then
            local cards = handview.m_handCardView:getCardsByStatus(DDZCard.STATUS_POP)
            --增加了判断，不仅要选中牌，还要能够出出去的牌
            if #cards > 0 and info.selCardLegal == true then
                self:setBtnGray(self.btn_chu, false);
            else
                self:setBtnGray(self.btn_chu, true);
            end
        elseif info.action == "chongxuan" then
            self:setBtnGray(self.btn_chu, true);
        end
    end
end

----------------------------------------------
-- @desc 显示玩家操作按钮
-- @pram info:显示玩家操作需要的相关信息
----------------------------------------------
function DDZOprationView:showOprationBtns(info)
    Log.i("DDZOprationView:showOprationBtns info", info)
    self.m_info = info;
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
    self.btn_bjiao:setVisible(false);
    self.btn_jiao:setVisible(false);
    self.btn_bqiang:setVisible(false);
    self.btn_qiang:setVisible(false);
    self.btn_bjia:setVisible(false);
    self.btn_jia:setVisible(false);
    self.btn_bchu:setVisible(false);
    self.btn_tshi:setVisible(false);
    self.btn_chu:setVisible(false);
    --self.btn_cx:setVisible(false);
    
    local tuoguanState = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
    print("<mzd>:tuoguanState***************************************=" .. tostring(tuoguanState))
    Log.i("DDZOprationView:showOprationBtns gameStatus : ",gameStatus)

    if tuoguanState == DDZConst.TUOGUAN_STATE_0 then
        if gameStatus == DDZConst.STATUS_CALL then
            self.btn_bjiao:setVisible(true);
            self.btn_jiao:setVisible(true);
        elseif gameStatus == DDZConst.STATUS_ROB then
            self.btn_bqiang:setVisible(true);
            self.btn_qiang:setVisible(true);
        elseif gameStatus == DDZConst.STATUS_DOUBLE then
            -- self.btn_bjia:setVisible(true);
            -- self.btn_jia:setVisible(true);
            self:buJiaCallBack()
        elseif gameStatus == DDZConst.STATUS_PLAY then
            self.btn_bchu:setVisible(true);
            self.btn_tshi:setVisible(true);
            self.btn_chu:setVisible(true);
            --self.btn_cx:setVisible(true);
            --必须出
            if info.isMustOut then
                self.btn_bchu:setVisible(false);
                self.btn_tshi:setPositionX(168);
                self.btn_chu:setPositionX(360);
                self:setTiShiBtnGray(self.btn_tshi,true)
            else
                self.btn_bchu:setVisible(true);
                self.btn_tshi:setPositionX(262);
                self.btn_chu:setPositionX(449);
                self:setTiShiBtnGray(self.btn_tshi,false)

                if not info.isBigger then
                    --self.btn_bchu:setVisible(true)
                    self.btn_bchu:setPositionX(262)
                    self.btn_tshi:setVisible(false)
                    self.btn_chu:setVisible(false)
                    local  image = ccui.Helper:seekWidgetByName(self.btn_bchu,"image")
                    --image:loadTexture("btn/btn_nobigger.png",ccui.TextureResType.plistType)
                    image:loadTexture("package_res/games/ddz/btn_nobigger.png")
                    image:ignoreContentAdaptWithSize(true)
                    self.btn_bchu:loadTextureNormal("btn/btn_green_bg.png",ccui.TextureResType.plistType)
                else
                    self.btn_chu:setVisible(true)
                    self.btn_tshi:setVisible(true)
                    self.btn_bchu:setPositionX(76)
                    local  image = ccui.Helper:seekWidgetByName(self.btn_bchu,"image")
                    image:loadTexture("btn/btn_pass.png",ccui.TextureResType.plistType)
                    image:ignoreContentAdaptWithSize(true)
                    self.btn_bchu:loadTextureNormal("btn/btn_green_bg.png",ccui.TextureResType.plistType)
                end
            end
            -- print("<mzd>____________________________buchu X "..self.btn_bchu:getPositionX())
        end
    end

    if DDZConst.STATUS_GAMEOVER == gameStatus then
        self.lb_time:setVisible(false);
    else
        self.lb_time:setVisible(true);
    end
    
    
    self:setBtnGray(self.btn_chu, true);

    --上手牌王炸自动不出
    if info.autoNotOut and HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:onClickButton(self.btn_bchu, ccui.TouchEventType.ended);
    end
end

----------------------------------------------
-- @desc 显示玩家托管状态改变后
-- @pram 无
----------------------------------------------
function DDZOprationView:onTuoGuanChange()
    if self.m_data == DDZConst.SEAT_MINE then
        local tuoguanState = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_TUOGUANSTATE)
        if tuoguanState == DDZConst.TUOGUAN_STATE_1 then
            self.btn_bjiao:setVisible(false);
            self.btn_jiao:setVisible(false);
            self.btn_bqiang:setVisible(false);
            self.btn_qiang:setVisible(false);
            self.btn_bjia:setVisible(false);
            self.btn_jia:setVisible(false);
            self.btn_bchu:setVisible(false);
            self.btn_tshi:setVisible(false);
            self.btn_chu:setVisible(false);
            --self.btn_cx:setVisible(false);
        else
            local opeSeat = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_OPERATESEATID)
            local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS)
            local myDbStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_DOUBLESTATUS)
            if opeSeat == DDZConst.SEAT_MINE or (gameStatus == DDZConst.STATUS_DOUBLE and myDbStatus == -1) then
                self:showOpration(self.m_info, true);
            end
        end
    end  
end

----------------------------------------------
-- @desc 更新操作时间
-- @pram 无
----------------------------------------------
function DDZOprationView:updateTime()
    self.m_Time = self.m_Time - 1;
    if self.m_Time < 0 then
        if not self.isBigger and self.playCard and HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM  then
            self:onClickButton(self.btn_bchu,ccui.TouchEventType.ended)
            return
        end
        self.m_Time = 0;
    end
    local timeStr = nil;
    if self.m_Time < 10 then
        timeStr = 0 .. self.m_Time;
    else
        timeStr = self.m_Time;
    end
    self.lb_time:setString(timeStr);
    self.m_time_update = self.m_pWidget:performWithDelay(handler(self, self.updateTime), 1);
end

----------------------------------------------
-- @desc 隐藏操作
-- @pram 无
----------------------------------------------
function DDZOprationView:hideOpration()
    Log.i("hideOpration seat = ", self.m_data);
    self.m_pWidget:setVisible(false);
    if self.m_time_update then
        transition.removeAction(self.m_time_update);
        self.m_time_update = nil;
    end
end

function DDZOprationView:setTiShiBtnGray(btn, isGray)
    if isGray then
        btn:setTouchEnabled(false);
        btn:setBright(false)
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        PokerUtils:setGreyAll(btn_text:getVirtualRenderer():getSprite(),1)
    else
        btn:setBright(true)
        btn:setTouchEnabled(true);
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        PokerUtils:setGreyAll(btn_text:getVirtualRenderer():getSprite(),0)
    end
end


----------------------------------------------
-- @desc 让按钮置灰
-- @pram btn:改变的按钮
--       isGary:是否要置灰
----------------------------------------------
function DDZOprationView:setBtnGray(btn, isGray)
    if isGray then
        btn:setTouchEnabled(false);
        btn:setBright(false)
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        btn_text:loadTexture("btn/btn_gray_chu.png", ccui.TextureResType.plistType)
    else
        btn:setBright(true)
        btn:setTouchEnabled(true);
        btn_text = ccui.Helper:seekWidgetByName(btn,"image")
        btn_text:loadTexture("btn/btn_yellow_chu.png", ccui.TextureResType.plistType)
    end
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZOprationView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil

    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.SITE) == self.m_data then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end

return DDZOprationView
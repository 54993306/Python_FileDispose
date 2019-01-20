--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--local WWFacade = require("app.games.common.custom.WWFacade")

local kOverTimeTipPaths =
{
    ["zuo"] = "real_res/1004315.png",
    ["dui"] = "real_res/1004311.png",
    ["you"] = "real_res/1004314.png",
    ["other"] = "real_res/1004313.png",

    ["pointPath"] = "real_res/1004312.png"
}


OperatorOverTimeTip = class("OperatorOverTimeTip", function()
    return display.newLayer()
end)


function OperatorOverTimeTip:ctor()
    self.gamePlaySystem = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)

    self:initOverTimeTip()
    self.handlers = {}

       -- 监听动作通知
    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        enMjNtfEvent.GAME_ACT_ANIMATE_START_NTF,
        handler(self, self.onAction)))

    table.insert(self.handlers, MjMediator.getInstance():getEventServer():addCustomEventListener(
        MJ_EVENT.GAME_REFRESH_OPERATOR_OVER_TIME,
        handler(self, self.refreshIsMyTurn)))
end

function OperatorOverTimeTip:dtor()
end

function OperatorOverTimeTip:onClose()
    -- 移除监听
    table.walk(self.handlers, function(h)
        MjMediator.getInstance():getEventServer():removeEventListener(h)
    end)
    self.handlers = {}

    self._delegate = nil
end

function OperatorOverTimeTip:setDelegate(delegate)
    self._delegate = delegate
end

function OperatorOverTimeTip:initOverTimeTip()
    local visibleWidth  = cc.Director:getInstance():getVisibleSize().width
    local visibleHeight = cc.Director:getInstance():getVisibleSize().height
    self._operatorOverTimeTip = display.newNode():addTo(self)
    if IsPortrait then -- TODO
        self._operatorOverTimeTip:setPosition(cc.p(visibleWidth / 2, visibleHeight /2 + 145))
    else
        self._operatorOverTimeTip:setPosition(cc.p(visibleWidth / 2, visibleHeight /2 + 155))
    end

    self._operatorOverTimeTip.content = display.newSprite():addTo(self._operatorOverTimeTip)

    self._operatorOverTimeTip.points = {}
    for i = 1, 3 do
        self._operatorOverTimeTip.points[i] = display.newSprite(kOverTimeTipPaths.pointPath):addTo(self._operatorOverTimeTip)
        self._operatorOverTimeTip.points[i]:setPositionY(-16)
    end

    self._operatorOverTimeTip:setVisible(false)

    function self._operatorOverTimeTip:refreshPointPos()
        local cw = self.content:getContentSize().width/2
        for i,v in ipairs(self.points) do
            cw = cw + v:getContentSize().width/2
            v:setPositionX(cw)
            cw = cw + v:getContentSize().width/2
        end
    end

    function self._operatorOverTimeTip:endUpdate()
        Log.i("self._operatorOverTimeTip:endUpdate")
        self:stopAllActions()
        self:setVisible(false)
    end

    function self._operatorOverTimeTip:startUpdate(overtime)
        Log.i("self._operatorOverTimeTip:startUpdate")
        if overtime == nil then
            overtime = 10
        end
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(overtime),
            cc.CallFunc:create(
                function()
                    self:setVisible(true)
                    for i,v in ipairs(self.points) do
                        v:setVisible(false)
                    end
                    self.content:setTag(0)
                    self:runAction(
                        cc.RepeatForever:create(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.5),
                                cc.CallFunc:create(
                                    function()
                                        local tg = (self.content:getTag() + 1) % (#self.points + 1)
                                        self.content:setTag(tg)
                                        if tg == 0 then
                                            for i,v in ipairs(self.points) do
                                                v:setVisible(false)
                                            end
                                        else
                                            self.points[tg]:setVisible(true)
                                        end
                                    end
                                )
                            )
                        )
                    )
                end
                )
            )
        )
    end
end

--[
-- @brief  操作超时
-- @param  nil show other.
-- @return void
--]
function OperatorOverTimeTip:setOperateTimeTip(pointType, overtime)
    Log.i("OperatorOverTimeTip:setOperateTimeTip pointType=", tostring(pointType))
    -- 先关闭

    self._operatorOverTimeTip:endUpdate()

    if VideotapeManager.getInstance():isPlayingVideo() then
        return
    end
    self._pointType = pointType
    if pointType == enSiteDirection.SITE_MYSELF then
        return
    end


    local spPath = kOverTimeTipPaths.other
    if pointType ~= nil then
        local sys = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local playerNum = sys:getGameStartDatas().playerNum
        local subVal = pointType - enSiteDirection.SITE_MYSELF
        if playerNum == 2 then
            spPath = kOverTimeTipPaths.dui
        elseif playerNum == 3 then
            if subVal == 1 then
                spPath = kOverTimeTipPaths.you
            else
                spPath = kOverTimeTipPaths.zuo
            end
        elseif playerNum == 4 then
            if subVal == 1 then
                spPath = kOverTimeTipPaths.you
            elseif subVal == 2 then
                spPath = kOverTimeTipPaths.dui
            else
                spPath = kOverTimeTipPaths.zuo
            end
        end
    end

    self._operatorOverTimeTip.content:setTexture(spPath)
    self._operatorOverTimeTip:refreshPointPos()
    self._operatorOverTimeTip:startUpdate(overtime)
end

function OperatorOverTimeTip:stopOverTimeTip()
    self:setOperateTimeTip(enSiteDirection.SITE_MYSELF)
end


--[[
-- @brief  动作监听函数
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:onAction()
    Log.i("------OperatorOverTimeTip:onAction")
    local playSystem = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
    local checkGameStart = playSystem:checkGameStart()
    if not checkGameStart then
        return
    end

    local operateSysData = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getOperateSystemDatas()
    local site  = self.gamePlaySystem:getPlayerSiteById(operateSysData.userid)

    if site == enSiteDirection.SITE_MYSELF then
        self:stopOverTimeTip()
        if operateSysData.actionID == enOperate.OPERATE_MING_GANG
            or operateSysData.actionID == enOperate.OPERATE_JIA_GANG
            or operateSysData.actionID == enOperate.OPERATE_AN_GANG
            or operateSysData.actionID == enOperate.OPERATE_DIAN_PAO_HU
            or operateSysData.actionID == enOperate.OPERATE_ZI_MO_HU
            or operateSysData.actionID == enOperate.OPERATE_QIANG_GANG_HU
            or operateSysData.actionID == enOperate.OPERATE_TIAN_HU
            or operateSysData.actionID == enOperate.OPERATE_DIAN_TIAN_HU then
            self:setOperateTimeTip(nil)
        end
    else
        if operateSysData.actionID == enOperate.OPERATE_DIAN_PAO_HU
            or operateSysData.actionID == enOperate.OPERATE_ZI_MO_HU
            or operateSysData.actionID == enOperate.OPERATE_QIANG_GANG_HU
            or operateSysData.actionID == enOperate.OPERATE_TIAN_HU
            or operateSysData.actionID == enOperate.OPERATE_DIAN_TIAN_HU then
            if self._pointType ~= enSiteDirection.SITE_MYSELF then
                self:setOperateTimeTip(nil)
            end
            --do nothing
        elseif operateSysData.actionID == enOperate.OPERATE_MING_GANG
            or operateSysData.actionID == enOperate.OPERATE_JIA_GANG
            or operateSysData.actionID == enOperate.OPERATE_AN_GANG then
            self:setOperateTimeTip(nil)
        elseif operateSysData.actionID ~= enOperate.OPERATE_DINGQUE then
            --定缺不走时钟和光标
            self:setOperateTimeTip(site)
        else
            self:stopOverTimeTip()
        end

    end
end

-- 函数功能: 点击过或出牌后, 将提示改为"等待其他玩家出牌"
-- 返回值: 无
function OperatorOverTimeTip:refreshIsMyTurn()
    -- fix bug KJZX-1189: self._pointType存在时(即已经有明确指向其他人的出牌提示时, 不需要再刷新出牌提示, 避免自己出牌后0.2秒延迟导致的问题)
    if self._pointType and self._pointType ~= enSiteDirection.SITE_MYSELF then return end

    self:stopOverTimeTip()
    local isGameStarted = self.gamePlaySystem:isGameStarted() -- 增加一个判断, 避免游戏结束后还显示提示
    if not isGameStarted then return end
    if self._delegate ~= nil and self._delegate.getCanDoCardSite then
        if self._delegate:getCanDoCardSite() ~= enSiteDirection.SITE_MYSELF then
            self:setOperateTimeTip(nil)
        end
    end
end

--[[
-- @brief  显示视图函数
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:showViews(delayTime)
    Log.i("------OperatorOverTimeTip:showViews")
    local startData = self.gamePlaySystem:getGameStartDatas()
    local actions = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.OPERATE_SYSTEM):getActions()

    if #actions > 0 then
        if #actions == 1 and #startData.closeCards % 3 ~= 2 and actions[1] == enOperate.OPERATE_TING_RECONNECT then --只有听但是不是能出牌的数,那么不是到自己出牌
            self:setOperateTimeTip(nil, delayTime)
        else
            self:setOperateTimeTip(enSiteDirection.SITE_MYSELF, delayTime)
        end
    else
        if #startData.closeCards % 3 == 2 and #startData.closeCards > 0 then
            self:setOperateTimeTip(enSiteDirection.SITE_MYSELF, delayTime)
        else
            self:setOperateTimeTip(nil, delayTime)
        end
    end
end

function OperatorOverTimeTip:onGameResume()
    self:showViews(1)
end
function OperatorOverTimeTip:onGameStart()
    --self:showViews(10)
end


--[[
-- @brief  发牌结束函数
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:onMjDistrubuteEnd()
    Log.i("------OperatorOverTimeTip:onMjDistrubuteEnd")
    local data      = self.gamePlaySystem:getGameStartDatas()
    local players   = self.gamePlaySystem:gameStartGetPlayers()
    assert(data ~= nil)
    for i=1,#players do
        if players[i]:getProp(enCreatureEntityProp.BANKER) then
            self:setOperateTimeTip(i)
        end
    end
end

--[[
-- @brief  拿牌操作函数
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:onDispenseCard()
    local dispenseData  = self.gamePlaySystem:getDispenseCardDatas()
    local players       = self.gamePlaySystem:gameStartGetPlayers()
    for i=1, #players do
        if players[i]:getProp(enCreatureEntityProp.USERID) == dispenseData.userId then
            self:setOperateTimeTip(i)
            break
        end
    end
end

--[[
-- @brief  出牌消息处理函数
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:onPlayCard()
    Log.i("------OperatorOverTimeTip:onPlayCard")
    -- 打出去的牌消息
    local playCardData = self.gamePlaySystem:getPlayCardDatas()
    -- 通过id获取玩家座位索引
    if playCardData.nextplayerID ~= 0 then
         local index = self.gamePlaySystem:getPlayerSiteById(playCardData.nextplayerID)
        self:setOperateTimeTip(index)
    else
        self:setOperateTimeTip()
    end
end

--[[
-- @brief  显示吃碰杠消息
-- @param  void
-- @return void
--]]
function OperatorOverTimeTip:onShowOperateLab(event)
    local site = self.gamePlaySystem:getCurrentPlayer()
    self:setOperateTimeTip(site)
end

return OperatorOverTimeTip;
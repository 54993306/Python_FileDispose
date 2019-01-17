--
-- Author: Huang Rulin
-- Date: 2017-10-16
--
require("app.DebugHelper")

local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local FriendRoomDataManager = require("app.hall.friendRoom.FriendRoomDataManager")

local GameRoomInfoUIBase = class("GameRoomInfoUIBase", function()
    local ret = display.newNode()
    ret.contentNode = display.newNode()
    ret:addChild(ret.contentNode)

    return ret
end )

function GameRoomInfoUIBase:ctor(viewSize, roomBaseInfo, clubInfo,friendRoomMode, gameID, viewLayoutCallBack, ...)
    self.m_roomBaseInfo = roomBaseInfo
    self.m_clubInfo = clubInfo
    self.m_viewSize = viewSize
    self.m_mode = friendRoomMode
    self.m_gameID = gameID
    self.viewLayoutCallBack = viewLayoutCallBack
    self.playerNumbers = {4, 3, 2}
    self.payTypes = {enFriendRoomPayType.Owner, enFriendRoomPayType.Winer, enFriendRoomPayType.AA}

    self.m_setData = { }
    self.m_wanfa = {}
    self.m_baseItemChildren = {}

    if IsPortrait then -- TODO
        self.mNumberInfoLineCount = 4
        self.mRoundInfoLineCount = 3
    end
    --在人数之前的item
    self.m_headItemChildren = { }
    --玩法的item
    self.m_itemChildren = { }

    --调用地方麻将的初始化
    self:initConfig()
    self:onInit()

    self.m_viewWanfaBaseHrl = display.newNode()
    self.m_viewHeadItemBaseHrl = display.newNode()
    local mode = (self.m_clubInfo and table.nums(self.m_clubInfo) > 0) and self.m_clubInfo.clubID or self.m_mode
    --初始化存儲數據類
    self._friendRoomDataManager = FriendRoomDataManager.new(string.format( "%s%s%s",tostring(_GameIdentification),tostring(self.m_roomBaseInfo.gameId), mode))
    self:initUI()
end

function GameRoomInfoUIBase:setChangePayData(payString1,payString2,priveData,isChangeLine)
    self.newPayStringAA = payString1
    self.newPayStringCommon = payString2
    self.newPriceData = priveData
    self.isChangeLine = isChangeLine
end


--地方组重写 初始化自己特有的数据或者更改人数，局数等配置
function GameRoomInfoUIBase:onInit()
end
--地方组重写 填充玩法item
function GameRoomInfoUIBase:initWanFa()
end

--地方组重写 付费类型（房主付费 大赢家付费 AA付费类型改变时的回调）
--对self.m_setData.RoJST的赋值在GameRoomInfoUIBase已经做了
--这里如果地方麻将的玩法选项对付费类型改变时有变化，可以重写这个方法。
--亲友圈付费现在走的就是房主付费的，那个可以不用关心，亲友圈模式的房间也不会走这里。。
--[[
payType取值：enFriendRoomPayType = {
    Owner = 1, -- 房主付费
    Winer = 2, -- 大赢家付费
    AA    = 3, -- AA付费
}--]]
function GameRoomInfoUIBase:payTypeChange(payType)
    dump(payType)
end

--地方组重写 人数项改变时的回调
--对self.m_setData.plS的赋值在GameRoomInfoUIBase已经做了
--这里如果地方麻将的玩法选项对付人数项改变时有变化，可以重写这个方法。
--[[
playerNum:玩家人数（如：4,3,2）
--]]
function GameRoomInfoUIBase:playerNumChange(playerNum)
    dump(playerNum)
end

--支持地方组重写，该函数功能为填充self.m_setData.wa字段
function GameRoomInfoUIBase:wanFaFactory()
    -- 拼装字符串
    local str = ""
    for i, v in pairs(self.m_wanfa) do
        if type(v) == "table" then
            if table.nums(v) > 0 then
                for j, k in pairs(v) do
                    str = str == "" and k or string.format("%s|%s", str, k)
                end
            end
        else
            str = str == "" and v or string.format("%s|%s", str, v)
        end
    end
    self.m_setData.wa = str
end
--保存房间信息
function GameRoomInfoUIBase:saveRoomInfo()

end
--提供给地方组动态改变view大小
function GameRoomInfoUIBase:viewLayout()
    local offsetY = 0
    local size = #self.m_headItemChildren
    local height = 0
    local order = 1
    for i = size, 1, -1  do
        local v = self.m_headItemChildren[i]
        local h = v:getContentSize().height
        v:setPosition(cc.p(0, height + offsetY))
        v:setAnchorPoint(cc.p(0, 0))
        v:setLocalZOrder(order)
        order = order + 1
        height = height + h + offsetY
    end
    self.m_viewHeadItemBaseHrl:setContentSize(cc.size(self.m_viewSize.width, height))

    size = #self.m_itemChildren
    height = 0
    for i = size, 1, -1  do
        local v = self.m_itemChildren[i]
        if not IsPortrait or v:isVisible() then -- TODO
            local h = v:getContentSize().height
            v:setPosition(cc.p(0, height + offsetY))
            v:setAnchorPoint(cc.p(0, 0))
            v:setLocalZOrder(order)
            order = order + 1
            height = height + h + offsetY
        end
    end
    self.m_viewWanfaBaseHrl:setContentSize(cc.size(self.m_viewSize.width, height))


    size = #self.m_baseItemChildren
    height = 0
    order = 1
    for i = size, 1, -1  do
        local v = self.m_baseItemChildren[i]
        local h = v:getContentSize().height
        v:setPosition(cc.p(0, height + offsetY))
        v:setAnchorPoint(cc.p(0, 0))
        v:setLocalZOrder(order)
        order = order + 1
        height = height + h + offsetY
        if IsPortrait then -- TODO
            local UITool = require("app.common.UITool")
            UITool.addRuleBgPanel(v)
        end
    end
    self.contentNode:setContentSize(cc.size(self.m_viewSize.width, height))

    if height >= self.m_viewSize.height then
        self.contentNode:setPosition(0, 0)
        self:setContentSize(cc.size(self.m_viewSize.width, height))
    else
        self.contentNode:setPosition(0, self.m_viewSize.height - height)
        self:setContentSize(self.m_viewSize)
    end

    if self.viewLayoutCallBack then self.viewLayoutCallBack(self:getContentSize()) end
end
--提供给地方组移除所有的玩法item
function GameRoomInfoUIBase:removeAllWanfaItem()
    self.m_itemChildren = {}
    self.m_viewWanfaBaseHrl:removeAllChildren()
end
--提供给地方组动态改变人数设置可选项{4， 3， 2}
function GameRoomInfoUIBase:changPlayerNumber(numberTable)
    self.playerNumbers = numberTable
    local numberInfo = {
        numbers = clone(self.playerNumbers),
        lineCount = G_ROOM_INFO_FORMAT.groupColMax,
        callFunc = function(plS)
            self.m_setData.plS = plS
            Log.i("new plS =", plS)
        end
    }
    self.numberData = numberInfo
    self:createNumberRadio()
end

--提供给地方组动态设置付费项整体是否可用
--value 是否可用 bool 设置为true时会对房费字段重新赋值，设置为false后，不会对房费字段赋值
--hide 是否隐藏局数项 true 隐藏， false 不隐藏， 默认不隐藏 value为true时，hide为不隐藏
function GameRoomInfoUIBase:setRoundItemEnable(value, hide)
    if value == nil or tolua.isnull(self.roundRadioGroup) then
        return
    end

    if hide == nil then
        hide = false
    end

    if value then --启用的时候，肯定是不能隐藏的啦~千万别改哦
        self.roundRadioGroup:setSelectEnable(value, false)
    else
        self.roundRadioGroup:setSelectEnable(value, hide)
    end

    self:viewLayout()
end

function GameRoomInfoUIBase:initConfig()
    local numberInfo = {
            numbers = clone(self.playerNumbers),
            lineCount = G_ROOM_INFO_FORMAT.groupColMax,
            callFunc = function(plS)
                self.m_setData.plS = plS
                Log.i("plS =", plS)
            end
        }

    local tmpData = clone(self.m_roomBaseInfo)
    local roundInfo = {
        roundSum = tmpData.roundSum,
        roundFreeSum = tmpData.roomFeeSum,
        lineCount = G_ROOM_INFO_FORMAT.groupColMax,
        callFunc = function(roS, RoFS)
            self.m_setData.roS = roS;
            self.m_setData.RoFS = RoFS;
            Log.i("roS =", roS)
            Log.i("RoFS =", RoFS)
        end
    }

    local payTypeInfo = {
        payTypes = clone(self.payTypes),
        lineCount = G_ROOM_INFO_FORMAT.groupColMax,
        callFunc = function(RoJST)
            self.m_setData.RoJST = RoJST
            Log.i("RoJST =", RoJST)
        end
    }

    if IsPortrait then -- TODO
        numberInfo.lineCount = self.mNumberInfoLineCount
        roundInfo.lineCount = self.mRoundInfoLineCount
    end
    self.numberData = numberInfo;
    self.roundData = self:formatRoundData(roundInfo);
    self.payTypeData = payTypeInfo;
end

--提供给地方组添加玩法项 支持替换
function GameRoomInfoUIBase:addScrollItem(item, idx)
    if item then
        if idx == nil or (idx < 0 or idx > #self.m_itemChildren) then
            self.m_itemChildren[#self.m_itemChildren + 1] = item
            self.m_viewWanfaBaseHrl:addChild(item, 10)
        else
            item:retain()
            if not tolua.isnull(self.m_itemChildren[idx]) then
                self.m_viewWanfaBaseHrl:removeChild(self.m_itemChildren[idx], cleanup)
            end
            self.m_itemChildren[idx] = item
            self.m_viewWanfaBaseHrl:addChild(item, 10)
            item:release()
        end
    end
end

--提供给地方组添加在人数之前的项 支持替换
function GameRoomInfoUIBase:addHeadScrollItem(item, idx)
    if item then
        if idx == nil or (idx < 0 or idx > #self.m_headItemChildren) then
            self.m_headItemChildren[#self.m_headItemChildren + 1] = item
            self.m_viewHeadItemBaseHrl:addChild(item, 10)
        else
            item:retain()
            if not tolua.isnull(self.m_headItemChildren[idx]) then
                self.m_viewHeadItemBaseHrl:removeChild(self.m_headItemChildren[idx], cleanup)
            end
            self.m_headItemChildren[idx] = item
            self.m_viewHeadItemBaseHrl:addChild(item, 10)
            item:release()
        end
    end
end
function GameRoomInfoUIBase:addBaseScrollItem(item)
    if item then
        self.m_baseItemChildren[#self.m_baseItemChildren + 1] = item
        self.contentNode:addChild(item, 10)
    end
end

function GameRoomInfoUIBase:formatRoundData(data)
    local ret = clone(data)

    ret.roundSum = Util.analyzeString_2(ret.roundSum);
    local jsonRet = json.decode(ret.roundFreeSum)

    if jsonRet == nil then
        local ffTable = Util.analyzeStringEx(ret.roundFreeSum, ",", "|")
        if #self.numberData.numbers > 1 then
            for i=2, #self.numberData.numbers do
                if ffTable[i] == nil then
                    ffTable[i] = {}
                end

                for j=1, #ret.roundSum do
                    if ffTable[i][j] == nil then
                        ffTable[i][j] = ffTable[i-1][j]
                    end
                end
            end
        end

        local priceInfo = { common = {} }
        for i=1, #self.numberData.numbers do
            local key = tostring(self.numberData.numbers[i])
            priceInfo.common[key] = {}
            for j=1, #ret.roundSum do
                priceInfo.common[key][tostring(ret.roundSum[j])] = ffTable[i][j]
            end
        end
        ret.roundFreeSum = priceInfo
    else
        ret.roundFreeSum = jsonRet
    end

    if ret.roundFreeSum.AA ~= nil then
        ret.roundFreeSum[tostring(enFriendRoomPayType.AA)] = ret.roundFreeSum.AA
    else
        ret.roundFreeSum[tostring(enFriendRoomPayType.AA)] = ret.roundFreeSum.common
    end
    ret.roundFreeSum.AA = clone(ret.roundFreeSum.AA)
    -- Log.i(ret.roundFreeSum)
    return ret
end

function GameRoomInfoUIBase:initUI()
    local groupRenShu, groupJuShu, groupPayType = self:createWdiget()
    if self.m_mode == enFriendRoomMode.Club then
        groupPayType:setContentSize(cc.size(groupPayType:getContentSize().width, 0))
        groupPayType:setVisible(false)
    end
    self:addBaseScrollItem(self.m_viewHeadItemBaseHrl)
    self:addBaseScrollItem(groupRenShu)
    self:addBaseScrollItem(groupJuShu)
    self:addBaseScrollItem(self.m_viewWanfaBaseHrl)
    self:addBaseScrollItem(groupPayType)
    self:initOtherItems()

    self:initWanFa()

    self:viewLayout()

    self:initRoomInfo()
end

--初始化房间选择信息
function GameRoomInfoUIBase:initRoomInfo()

end

function GameRoomInfoUIBase:initOtherItems()
    if self.m_mode == enFriendRoomMode.Club and kFriendRoomInfo:getRoomState() == CreateRoomState.normal then
        local hideModeData = {
            title = "模式" .. G_ROOM_INFO_FORMAT.titleSuffix,
            radios = { "公开房间", "隐藏房间"},
            width = G_ROOM_INFO_FORMAT.radioItemOffset,
            hiddenLine = true,
            count = G_ROOM_INFO_FORMAT.groupColMax
        }
        local groupHideMode = SelectRadioPanel.new(hideModeData, function(index)
            if index == 1 then
                self.m_setData.isH = 0
            else
                self.m_setData.isH = 1
            end
        end)
        self:addBaseScrollItem(groupHideMode)
    end
end

--[[
    设置子项的可见性
    调用该方法后需要手动调用composition()方法重新排版
--]]
function GameRoomInfoUIBase:setItemVisible(item, isVisible)
    if not item then
        return
    end
    item:setVisible(isVisible)
end

function GameRoomInfoUIBase:getData()
    self.m_setData.gaI = self.m_gameID;
    -- 玩法工厂
    self:wanFaFactory()
    Log.i("getData.self.m_setData.wa", self.m_setData.wa)
    self:saveRoomInfo()
    return self.m_setData;
end

--提供给地方组动态改变人数设置可选项{4， 3， 2}
function GameRoomInfoUIBase:changRoundNumber(isChangePay)
    local payType = self.payTypeData.payTypes[self.payTypeRadioGoup:getSelectedIndex()]
    local number = self.numberData.numbers[self.numberRadioGoup:getSelectedIndex()]
    self.isChangePay = isChangePay
    self:refreshRoundWidget(payType, number)
end

--Ret = 人数行，局数行，付费类型行
function GameRoomInfoUIBase:createWdiget()
    self:createNumberRadio()
    self:createPayTypeRadio()
    local payType = self.payTypeData.payTypes[self.payTypeRadioGoup:getSelectedIndex()]
    local number = self.numberData.numbers[self.numberRadioGoup:getSelectedIndex()]
    self:refreshRoundWidget(payType, number)

    return self.numberRadioGoup, self.roundRadioGroup, self.payTypeRadioGoup
end

--创建的时候调用的。
function GameRoomInfoUIBase:tryRefeshRoundRadio()
    if tolua.isnull(self.roundRadioGroup) or tolua.isnull(self.numberRadioGoup) or tolua.isnull(self.payTypeRadioGoup) then
        return
    else
        local payType = self.payTypeData.payTypes[self.payTypeRadioGoup:getSelectedIndex()]
        local number = self.numberData.numbers[self.numberRadioGoup:getSelectedIndex()]
        self:refreshRoundWidget(payType, number)
    end
end

function GameRoomInfoUIBase:createNumberRadio()
    local personDatas = {
        title = "人数" .. G_ROOM_INFO_FORMAT.titleSuffix,
        radios = {},
        width = G_ROOM_INFO_FORMAT.radioItemOffset,
        hiddenLine = self.numberData.hideLine,
        count = self.payTypeData.lineCount or G_ROOM_INFO_FORMAT.groupColMax
    }
    if IsPortrait then -- TODO
        personDatas.width = G_ROOM_INFO_FORMAT.lineWidth / (self.mNumberInfoLineCount + 1)
        personDatas.count = self.numberData.lineCount or G_ROOM_INFO_FORMAT.groupColMax
    end

    for i,v in ipairs(self.numberData.numbers) do
        if IsPortrait then -- TODO
            personDatas.radios[i] = tostring(v)
        else
            personDatas.radios[i] = tostring(v).."人"
        end
    end


    if not self.numberRadioGoup then
        self.numberRadioGoup = SelectRadioPanel.new(personDatas, function(index)
            if self.numberData.callFunc then self.numberData.callFunc(self.numberData.numbers[index]) end
            self:playerNumChange(self.numberData.numbers[index])
            self:tryRefeshRoundRadio()
        end)
        if IsPortrait then -- TODO
            -- 更改默认选项为4人
            self.numberRadioGoup:setSelectedIndex(1)
        end
    else
        self.numberRadioGoup:refreshRadios(personDatas.radios, self.numberRadioGoup:getSelectedIndex(), function(index)
            if self.numberData.callFunc then self.numberData.callFunc(self.numberData.numbers[index]) end
            self:playerNumChange(self.numberData.numbers[index])
            self:tryRefeshRoundRadio()
        end)
    end


    return self.numberRadioGoup
end

function GameRoomInfoUIBase:createPayTypeRadio()
    local txt = {"房主付费", "大赢家付费", "AA付费"}
    local chargeDatas = {
        title = "房费" .. G_ROOM_INFO_FORMAT.titleSuffix,
        radios = {},
        width = G_ROOM_INFO_FORMAT.radioItemOffset,
        hiddenLine = self.payTypeData.hideLine,
        count = self.payTypeData.lineCount or G_ROOM_INFO_FORMAT.groupColMax
    }

    for i,v in ipairs(self.payTypeData.payTypes) do
        chargeDatas.radios[i] = txt[v]
    end

    self.payTypeRadioGoup = SelectRadioPanel.new(chargeDatas, function(index)
        if self.payTypeData.callFunc then self.payTypeData.callFunc(self.payTypeData.payTypes[index]) end
        self:payTypeChange(self.payTypeData.payTypes[index])
        self:tryRefeshRoundRadio()
    end)
    self.payTypeRadioGoup:setLineVisible(false)
    return self.payTypeRadioGoup
end

function GameRoomInfoUIBase:refreshRoundWidget(payType, number)
    local textDatas = { }
    local priceData = self.roundData.roundFreeSum.common
    local payTypeStr = tostring(payType)
    local numberStr = tostring(number)
    local formatStr = "%s局(%d钻)"
    if IsPortrait then -- TODO
        formatStr = "%s(%d钻)"
    end
    local radioNum = 1
    if payType == enFriendRoomPayType.AA and self.roundData.roundFreeSum[payTypeStr]  then
        priceData = self.roundData.roundFreeSum[payTypeStr]
        formatStr = "%s局(每人%d钻)"
        if IsPortrait then -- TODO
            formatStr = "%s(每人%d钻)"
        end
        radioNum = tonumber(number)
    end

    local buf = {}
    for i, v in ipairs(self.roundData.roundSum) do
        --Log.i("self.roundData.roundSum", formatStr, v, priceData, radioNum)
        if IsPortrait then -- TODO
            if IS_YINGYONGBAO then
                buf[#buf+1] = tostring(v)
            else
                buf[#buf+1] = string.format(formatStr, v, math.ceil(tonumber(priceData[numberStr][v])/radioNum))
            end
        else
            buf[#buf+1] = string.format(formatStr, v, math.ceil(tonumber(priceData[numberStr][v])/radioNum))
        end
    end

    if self.isChangePay then

        if #self.newPayStringAA>0 and #self.newPayStringCommon>0 and #self.newPriceData>0 then
            buf = {}
            for i, v in ipairs(self.roundData.roundSum) do
                if payType == enFriendRoomPayType.AA and self.roundData.roundFreeSum[payTypeStr] then
                    buf[#buf+1] = string.format(self.newPayStringAA[i], math.ceil(tonumber(self.newPriceData[i])/radioNum))
                else
                    buf[#buf+1] = string.format(self.newPayStringCommon[i], math.ceil(tonumber(self.newPriceData[i])))
                end
            end
        else

        end
    end

    local juShuDatas = {
        title = "局数" .. G_ROOM_INFO_FORMAT.titleSuffix,
        radios = buf,
        width = G_ROOM_INFO_FORMAT.radioItemOffset,
        hiddenLine = self.roundData.hideLine,
        count = self.roundData.lineCount or G_ROOM_INFO_FORMAT.groupColMax
    }
    if IsPortrait then -- TODO
        juShuDatas.width = G_ROOM_INFO_FORMAT.lineWidth / (self.mRoundInfoLineCount + 1)
        if payType == enFriendRoomPayType.AA or self.isChangeLine then
            juShuDatas.width = G_ROOM_INFO_FORMAT.radioItemOffset
            juShuDatas.count = G_ROOM_INFO_FORMAT.groupColMax
        end
    end

    if not self.roundRadioGroup then
        self.roundRadioGroup = SelectRadioPanel.new(juShuDatas, function(index)
            if self.roundData.callFunc then
                local roundSum = self.roundData.roundSum[index]
                self.roundData.callFunc(roundSum, priceData[numberStr][roundSum])
            end
        end)
    else
        if IsPortrait then -- TODO
            self.roundRadioGroup.m_data.width = juShuDatas.width
            self.roundRadioGroup.m_data.count = juShuDatas.count
        end
        self.roundRadioGroup:refreshRadios(juShuDatas.radios, self.roundRadioGroup:getSelectedIndex(), function(index)
            if self.roundData.callFunc then
                local roundSum = self.roundData.roundSum[index]
                self.roundData.callFunc(roundSum, priceData[numberStr][roundSum])
            end
        end)
        if IsPortrait then -- TODO
            self:viewLayout()
        end
    end
end

return GameRoomInfoUIBase

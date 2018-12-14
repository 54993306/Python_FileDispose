local SelectRadioPanel = require("app.hall.common.SelectRadioPanel")

local RoomCreateBaseItemManager = class("RoomCreateBaseItemManager")

--[[
{
    numbers = { 4, 3, 2 },
    itemWidth = 220,
    lineCount = 4,
    hideLine = false;
    callFunc = function(number) end
}
}]]


function RoomCreateBaseItemManager:ctor(numberData, roundData, payTypeData)
    self.m_callbacks = {};

    self.numberData = numberData;
    self.roundData = self:formatData(roundData);
    self.payTypeData = payTypeData;
end

function RoomCreateBaseItemManager:formatData(data)
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
        ret.roundFreeSum["3"] = ret.roundFreeSum.AA
    end
    return ret
end

--Ret = 人数行，局数行，付费类型行
function RoomCreateBaseItemManager:createWdiget()
    self:createNumberRadio()
    self:createPayTypeRadio()
    local payType = self.payTypeData.payTypes[self.payTypeRadioGoup:getSelectedIndex()]
    local number = self.numberData.numbers[self.numberRadioGoup:getSelectedIndex()]
    self:refreshRoundWidget(payType, number)

    return self.numberRadioGoup, self.roundRadioGroup, self.payTypeRadioGoup
end

--创建的时候调用的。
function RoomCreateBaseItemManager:tryRefeshRoundRadio()
    if self.roundRadioGroup and self.numberRadioGoup and self.payTypeRadioGoup then
        local payType = self.payTypeData.payTypes[self.payTypeRadioGoup:getSelectedIndex()]
        local number = self.numberData.numbers[self.numberRadioGoup:getSelectedIndex()]
        self:refreshRoundWidget(payType, number)
    end
end

function RoomCreateBaseItemManager:createNumberRadio()    
    local personDatas = {
        title = "人数:", 
        radios = {},
        width = self.numberData.itemWidth or 220,
        hiddenLine = self.numberData.hideLine,
        count = self.payTypeData.lineCount or 4
    }

    for i,v in ipairs(self.numberData.numbers) do
        personDatas.radios[i] = tostring(v).."人"
    end

    self.numberRadioGoup = SelectRadioPanel.new(personDatas, function(index)
        if self.numberData.callFunc then self.numberData.callFunc(self.numberData.numbers[index]) end
        self:tryRefeshRoundRadio()
    end)
    return self.numberRadioGoup
end

function RoomCreateBaseItemManager:createPayTypeRadio()
    local txt = {"房主付费", "大赢家付费", "AA付费"}
    local chargeDatas = {
        title = "房费:",
        radios = {}, 
        width = self.payTypeData.itemWidth or 220,
        hiddenLine = self.payTypeData.hideLine,
        count = self.payTypeData.lineCount or 4
    }

    for i,v in ipairs(self.payTypeData.payTypes) do
        chargeDatas.radios[i] = txt[v]
    end

    self.payTypeRadioGoup = SelectRadioPanel.new(chargeDatas, function(index)
        if self.payTypeData.callFunc then self.payTypeData.callFunc(self.payTypeData.payTypes[index]) end
        self:tryRefeshRoundRadio()
    end)
    return self.payTypeRadioGoup
end

function RoomCreateBaseItemManager:refreshRoundWidget(payType, number)    
    local textDatas = { }
    local priceData = self.roundData.roundFreeSum.common
    local payTypeStr = tostring(payType)
    local numberStr = tostring(number)
    local formatStr = "%s局(%d钻)"
    local radioNum = 1
    if payType and self.roundData.roundFreeSum[payTypeStr]  then
        priceData = self.roundData.roundFreeSum[payTypeStr]
        formatStr = "%s局(每人%d钻)"
        radioNum = tonumber(number)
    end

    local buf = {}
    for i, v in ipairs(self.roundData.roundSum) do
        if IsPortrait then -- TODO
            if IS_YINGYONGBAO then
                buf[#buf+1] = string.format("%s局", v)
            else
                buf[#buf+1] = string.format(formatStr, v, math.ceil(tonumber(priceData[numberStr][v])/radioNum))
            end
        else
            buf[#buf+1] = string.format(formatStr, v, math.ceil(tonumber(priceData[numberStr][v])/radioNum))
        end
    end


    local juShuDatas = {
        title = "局数:",
        radios = buf, 
        width = self.roundData.itemWidth or 220,
        hiddenLine = self.roundData.hideLine,
        count = self.roundData.lineCount or 4
    }

    if not self.roundRadioGroup then
        self.roundRadioGroup = SelectRadioPanel.new(juShuDatas, function(index)
            if self.roundData.callFunc then
                local roundSum = self.roundData.roundSum[index]
                self.roundData.callFunc(roundSum, priceData[numberStr][roundSum])
            end
        end)
    else
        self.roundRadioGroup:refreshRadios(juShuDatas.radios, self.roundRadioGroup:getSelectedIndex(), function(index)
            if self.roundData.callFunc then
                local roundSum = self.roundData.roundSum[index]
                self.roundData.callFunc(roundSum, priceData[numberStr][roundSum])
            end
        end)
    end   
end

return RoomCreateBaseItemManager
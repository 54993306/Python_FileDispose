-- 朋友开房基本信息
FriendRoomInfo = class("FriendRoomInfo");

-- 游戏类型
FriendRoomGameType =
{
    DDZ = 1,-- 地主
    MJ = 2,-- 麻将
    GD = 3, --掼蛋
}

-- 开始游戏入口
StartGameType =
{
    NONE = 0,
    -- 未知状态
    FIRENDROOM = 1,
    -- 朋友开房
    MATCH = 2,-- 比赛
}



-- 玩家在游戏过程中的状态
FriendRoomPlayerState = {
    EnterState = 1,
    -- 进入状态
    ExitState = 2,
    -- 退出状态
    playingState = 3,-- 玩游戏状态
}


-- 玩家排名信息
FriendRoomPlayerRankingStruct = {
    [1] = { title = "第一名", r = 255, g = 227, b = 0 },
    [2] = { title = "第二名", r = 206, g = 206, b = 206 },
    [3] = { title = "第三名", r = 140, g = 85, b = 65 },
    [4] = { title = "第四名", r = 130, g = 130, b = 130 }
}

FriendRoomInfo.g_isReturnFriendRoom = false;-- 是否是返回到朋友开房UI

CreateRoomState = {
    normal = 1,     -- 普通创建房间
    clubmodel = 2,  -- 创建俱乐部模版
    resetmodel = 3, -- 修改俱乐部模版
}

function FriendRoomInfo:getPlayingInfoByTitle(title, gameID)
    --妈的 不知道谁写的旧代码 微信分享里面居然用的FriendRoomInfo，搞得这里只能用kFriendRoomInfo
    local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
    local gameId = gameID or kFriendRoomInfo:getGameID()
    return MjGameConfigManager[gameId].kGetPlayingInfoByTitle(title, gameId)
end

function FriendRoomInfo:getPlayingInfoByTitle2(title, gameID)
    local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
    local gameId = gameID or kFriendRoomInfo:getGameID()
    return MjGameConfigManager[gameId].kGetPlayingInfoByTitle2(title, gameId)
end

function FriendRoomInfo:getPlayingInfoByChina(ch, gameID)
    for k, v in pairs(MjGameConfigManager[gameID or self:getGameID()]._gamePalyingName) do
        if (v.ch == ch) then
            return v
        end
    end
    return nil;
end

FriendRoomInfo.getInstance = function()
    if not FriendRoomInfo.s_instance then
        FriendRoomInfo.s_instance = FriendRoomInfo.new();
    end

    return FriendRoomInfo.s_instance;
end

FriendRoomInfo.releaseInstance = function()
    if FriendRoomInfo.s_instance then
        FriendRoomInfo.s_instance:dtor();
    end
    FriendRoomInfo.s_instance = nil;
end

function FriendRoomInfo:ctor()
    self.m_roomBaseInfo = { };
    -- 配置数据
    self.m_roomInfo = { }
    -- 邀请房信息
    self.m_isFriendRoom = StartGameType.NONE
	self.m_AreaBaseInfo = {}

    self.m_selectRoomInfo = {}

    if IsPortrait then -- TODO
        self.m_AreasRelation = {}
        self.m_AreaAndComman = {}    -- 地区玩法和通用玩法
    end

    
    self.m_Roomstate = CreateRoomState.normal  -- 默认为正常创建模式

    self.m_ClubModel = {}   -- 俱乐部房间模版信息
end


-- 当前房间模版信息
function FriendRoomInfo:setClubModel(model)
    self.m_ClubModel = model
end

-- 获取当前房间模版信息
function FriendRoomInfo:getClubModel()
    return self.m_ClubModel or {}
end

-- 设置房间状态
function FriendRoomInfo:setRoomState(state)
    if not state then return end
    local hasState = false
    for _,v in pairs(CreateRoomState) do
        if v == state then
            hasState = true
        end
    end
    if not hasState then
        Log.i("ERROR : FriendRoomInfo:setRoomState" , state)
        return
    end
    self.m_Roomstate = state
end

function FriendRoomInfo:getRoomState()
    return self.m_Roomstate
end

-- 获取游戏ID
function FriendRoomInfo:getGameID()
    if self.m_roomBaseInfo then
        return self.m_roomBaseInfo.gameId or CONFIG_GAEMID
    end
    return CONFIG_GAEMID;
end

function FriendRoomInfo:getGameType()
    return _gameType;
end


function FriendRoomInfo:clearData()
    Log.i("..................................重新初始化朋友开房数据.............................")
    self.m_isFriendRoom = StartGameType.NONE
    self.m_gameEnd = false;
    self.m_roomInfo = { };
end

function FriendRoomInfo:dtor()

end
--存储地区信息数组,初始化本地房间数据
function FriendRoomInfo:setAreaBaseInfo(roomConfigInfo)
    local datas = checktable(roomConfigInfo.coI)
    if IsPortrait then -- TODO
        self.m_AreasRelation = json.decode(roomConfigInfo.plG) or {}
        Log.i("玩法归属信息 : " , self.m_AreasRelation)
    end
    self.m_MjDescInfoMap = {}
    if #datas > 0 then
        self.m_AreaBaseInfo = {}
        for i, v in ipairs(datas) do
            local data = json.decode(v)
            if data.gameId > 0 then
                self.m_AreaBaseInfo[#self.m_AreaBaseInfo+1] = data
                self.m_MjDescInfoMap[data.gameId] = {
                    gameName = Util.cutMjName(data.gameName),
                }
            end
        end
        Log.i("规则信息", self.m_AreaBaseInfo)
    else
        local data = json.decode(roomConfigInfo.coI)
        self.m_AreaBaseInfo = {[1] = data}
    end
    self:initRoomInfo()
end

function FriendRoomInfo:getMjDescInfoMap()
    return self.m_MjDescInfoMap or {}
end

function FriendRoomInfo:getAreaBaseInfo()
    return self.m_AreaBaseInfo or {};
end

if IsPortrait then -- TODO
-- 获取地区关系
function FriendRoomInfo:getAreaRelation()
    return self.m_AreasRelation or {}
end

-- 初始化地区玩法和通用玩法表
function FriendRoomInfo:initAreaAndCommon(selectCityID)
    self.m_AreaAndComman = {}
    selectCityID = selectCityID or kSettingInfo:getSelectAreaPlaceID()
    local areaRelations = self:getAreaRelation()     -- 地区对应的玩法
    if areaRelations[tostring(selectCityID)] then                         -- 插入
        -- Log.i("-------------arearelations" , areaRelations[tostring(selectCityID)])
        for _,v in pairs(areaRelations[tostring(selectCityID)]) do        -- 将地区玩法的id插入到表中
            table.insert(self.m_AreaAndComman,v)
        end
    else
        -- Log.i(" [ Tips ] FriendRoomCreate:initShowArea id : " ..  selectCityID, areaRelations ) -- 选择的地区找不到相应的玩法
    end
    -- Log.i(" show common game " , self.m_AreaAndComman)

    for k,v in pairs(areaRelations) do
        if string.len(k) == 4 and k == tostring(PRODUCT_ID) then    -- 地区通用玩法，地区id是4位数
            for _,_v in pairs(v) do
                table.insert(self.m_AreaAndComman,_v)
            end
        end
    end
    Log.i(" show common game2 " , self.m_AreaAndComman)
end

-- 获取地区玩法和通用玩法表
function FriendRoomInfo:getAreaAndCommon()
    return self.m_AreaAndComman or {}
end
end
--[[
 ["coI"] = {
 "configMap":{
"10007":{"gameId":10007,"initScore":1000,"roomFeeType":10006,"expiredTime":24,
"playerSum":4,
"roundSum":"4|8|12|16",
"roomFeeSum":"1|1|2|2",
"difen":"1|2|5|10",
"fengding":"3|4|5",
"wanfa":"dingque|huansanzhang|zimojiadi|zimojiafan|yaojiujiangdui|jingougou|zhigangcagua|jishiyu|sanhuaqihu|yifanqihu|kechi",
"wanfahuchi":["zimojiadi|zimojiafan", "zimojiafan|zimojiadi"],
"shareTitle":"d邀请您进入一个d房间！","shareDesc":"d邀请您进入一个d房间，邀请码是d！",
"shareLink":"http://wxpt.stevengame.com/wxdsqp/front/downdetail",
"roomFeeTip":"钻石不足，请联系管理员或以下微信号xxxxxxxx。点击任意位置关闭提示信息。"},
"jiadi":"2|3|4"
]]
--选择地区后初始化房间规则信息
function FriendRoomInfo:initRoomInfo()
    if #self.m_AreaBaseInfo > 0 then
        if SettingInfo.getInstance():getSelectAreaGameID() ~= 0 then
            for k, roomBaseInfo in pairs(self.m_AreaBaseInfo) do
                if SettingInfo.getInstance():getSelectAreaGameID() == roomBaseInfo.gameId then
                    self.m_roomBaseInfo = roomBaseInfo;
                    return
                end
            end
        else
            self.m_roomBaseInfo = self.m_AreaBaseInfo[1];
        end
        --存储的游戏ID找不到房间的规则数据
        print("[ ERROR ]FriendRoomInfo:initRoomInfo]")
    else
        print("[ Tips ] FriendRoomInfo:initRoomInfo m_AreaBaseInfo is nil")
    end
end

function FriendRoomInfo:setRoomBaseInfo(roomConfigInfo)
    self.m_roomBaseInfo = nil
    self.m_roomBaseInfo = roomConfigInfo;
    -- Log.i("房间信息", self.m_roomBaseInfo)
end

function FriendRoomInfo:getRoomBaseInfo()
    --协议字段改变 做个兼容处理
    --付费字段
    if self.m_roomBaseInfo and self.m_roomBaseInfo.roomFeeSum == nil then
        self.m_roomBaseInfo.roomFeeSum = self.m_roomBaseInfo.RoomFeeSum
    end

    --分享字段
    local shareInfo = nil
    if self.m_roomBaseInfo.roomShare then
        shareInfo = json.decode(self.m_roomBaseInfo.roomShare)
    end
    if shareInfo ~= nil then
        if shareInfo.shareTitle then self.m_roomBaseInfo.shareTitle = shareInfo.shareTitle end
        if shareInfo.shareDesc then self.m_roomBaseInfo.shareDesc = shareInfo.shareDesc end
        if shareInfo.shareLink then self.m_roomBaseInfo.shareLink = shareInfo.shareLink end
        if shareInfo.landingPage then self.m_roomBaseInfo.landingPage = shareInfo.landingPage end
        if shareInfo.iosurl then self.m_roomBaseInfo.iosurl = shareInfo.iosurl end
        if shareInfo.iosOpenurl then self.m_roomBaseInfo.iosOpenurl = shareInfo.iosOpenurl end
    end

    if self.m_roomBaseInfo == nil then return {} end

    local roomBaseInfo = clone(self.m_roomBaseInfo)

    if kServerInfo:isFreeActivityOpen() then
        roomBaseInfo.roomFeeSum = "0|0|0"
    end
    --兼容处理完成
    return roomBaseInfo

end


-- 从房间列表中取出一个房间基本信息
function FriendRoomInfo:getRoomInfoByGameID(gameID)
    Log.i("游戏ID", gameID)
    return self.m_roomBaseInfo
end


function FriendRoomInfo:setRoomInfo(packInfo)
    self.m_roomInfo = packInfo
end

function FriendRoomInfo:removeRoomPlayerInfo(playerid)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == playerid) then
                v = nil
                table.remove(self.m_roomInfo.pl, k)
                return
            end
        end
    end
end

-- 获取游戏名字
function FriendRoomInfo:getGameName(gameId)
    if not gameId  then return "麻将" end
    if #self.m_AreaBaseInfo < 1 then return "麻将" end
    for k,areaData in pairs(self.m_AreaBaseInfo) do
        if gameId == areaData.gameId then
            self.mjNameCache[gameId] = areaData.gameName
            return areaData.gameName
        end
    end
end

--获取房间信息
function FriendRoomInfo:getGameInfo(gameId)

    if not gameId or #self.m_AreaBaseInfo < 1 then return nil end
    for k,areaData in pairs(self.m_AreaBaseInfo) do
        if gameId == areaData.gameId then
            return areaData
        end
    end
end

---当前房间是否是亲友圈房间
function FriendRoomInfo:isClubMode()
    if not self.m_roomInfo then return false end
    local clubId = self.m_roomInfo.clI
    if clubId == 0 then
        return false
    end
    return true
end



-- 获取当前房间id
function FriendRoomInfo:getRoomId()
    return self.m_roomInfo.pa;
end

-- 设置房间id
function FriendRoomInfo:setRoomId(roomid)
    self.m_roomInfo.pa = roomid
end


-- 获取正在提审的版本号
function FriendRoomInfo:getReViewVersion()

    if #self.m_AreaBaseInfo > 0 then
        for k, roomBaseInfo in pairs(self.m_AreaBaseInfo) do
            if CONFIG_GAEMID == roomBaseInfo.gameId then
                Log.i("------getReViewVersion CONFIG_GAEMID", CONFIG_GAEMID);
                Log.i("------getReViewVersion", roomBaseInfo.reviewVersion);
                return roomBaseInfo.reviewVersion;
            end
        end
    end
    Log.i("------getReViewVersion", self.m_roomBaseInfo.reviewVersion);
    
    return self.m_roomBaseInfo.reviewVersion;
end

-- 获取当前房间人数
function FriendRoomInfo:getRoomPlayerNum()
    local i = 0
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            i = i + 1
        end
    end
    return i
end

-- 获取邀请房全部信息
function FriendRoomInfo:getRoomInfo()
    return self.m_roomInfo;
end

-- 当前用户是否房主
function FriendRoomInfo:isRoomMain(userID)
    if (self.m_roomInfo.owI == userID) then
        return true
    end
    return false
end

function FriendRoomInfo:getRoomMainID()
    return self.m_roomInfo.owI;
end

function FriendRoomInfo:getRoomPlayerListInfo(playerID)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == playerID) then
                return v
            end
        end
    end
    return nil
end


-- 获取当前所开房间对应的房间基本信息
function FriendRoomInfo:getCurRoomBaseInfo()
    -- 测试
    local tmpData = { }
    tmpData.roS = tonumber(self:getSelectRoomInfo().roS)
    -- 发奖的对局数
    tmpData.roS0 = tmpData.roS
    -- 总对局数
    tmpData.an = self.m_roomBaseInfo.difen
    return tmpData
    -- kFriendRoomInfo:getRoomInfoByID(self.m_roomInfo.coI)
end

-- 从服务器获取房间配置信息
function FriendRoomInfo:getRoomConfigFromServer()
    if (self.m_getRoomConfigSucess == nil or self.m_getRoomConfigSucess == false) then
        -- 是否获取成功
        local tmpData = { }
        HallSocketProcesser.sendRoomConfig(tmpData)
        self.m_getRoomConfigSucess = false
    end
end

function FriendRoomInfo:isFriendRoom()
    if (self.m_isFriendRoom == StartGameType.FIRENDROOM) then
        -- 是否获取成功
        return true
    end
    return false
end

-- 按玩家排名返回玩家信息
function FriendRoomInfo:sortPlayerInfo()
    local playerInfo = { }
    if (self.m_roomInfo.pl ~= nil) then
        playerInfo = self.m_roomInfo.pl;
    end
    function comps(a, b)
        return a.ra < b.ra
    end
    table.sort(playerInfo, comps);

    return playerInfo
end

function FriendRoomInfo:setMoneyInfo(packetInfo)
    self.m_moneyInfo = packetInfo
end

function FriendRoomInfo:getMoneyInfo()
    return self.m_moneyInfo
end

function FriendRoomInfo:setSelectRoomInfo(packetInfo)
    self.m_selectRoomInfo = packetInfo
end

function FriendRoomInfo:getSelectRoomInfo()
    return self.m_selectRoomInfo
end

-- 取玩法规则
function FriendRoomInfo:getPlayingInfo()
    return self:formatWafaData(self.m_selectRoomInfo.wa, self:getGameID())
end

function FriendRoomInfo:formatWafaData(wa, gameID)
    local itemList = Util.analyzeString_2(wa);
    local retTable = { }
    if (#itemList > 0) then
        for i = 1, #itemList do
            local w = itemList[i]
            local info = self:getPlayingInfoByTitle(w, gameID)
            if info ~= nil then
                local ch = "  " .. info.ch;
                table.insert(retTable, ch)
            end
        end
    end


    --针对不同游戏，可能有不同逻辑才能得出玩法
    local MjGameConfigManager = require("app.games.common.MjGameConfigManager")
    local getGamePalyingText = MjGameConfigManager[gameID or self:getGameId()].getGamePalyingText
    if(getGamePalyingText~=nil) then
       local ret = getGamePalyingText()
       for i=1,#ret do
          table.insert(retTable, "  " .. ret[i])
       end
    end

    return retTable
end

----------------
-- 取玩法规则
-- @float maxWidth 最大宽度
function FriendRoomInfo:getRuleStrRet(maxWidth, fontSize)
    local ret = {
        ruleStr = "",
        rows = 0,
    }
    local playingInfo = self:getPlayingInfo()
    if #playingInfo == 0 then -- 规则为空时返回默认值
        return ret
    else
        ret.rows = 1
    end
    local noWrap = false -- 若某一个规则的宽度超过了最大宽度, 那么将采用另外的一套方法来创建规则文本(不换行, 直接连接)
    if maxWidth and fontSize then -- 若不传入maxWidth, 那么直接连接文本
        local width = 0
        -- playingInfo = {"  测试规则", "  测试规则", "  测试规则", "  规a", "  测1X", "  测试规则", "  测试超长规则: 那么将采用另外的一套方法来创建规则文本"}
        for i, v in ipairs(playingInfo) do
            local ruleWidth = Util.getFontWidth(v, fontSize) / 2
            if ruleWidth > maxWidth then
                noWrap = true
                break
            end
            width = width + ruleWidth
            if width > maxWidth then -- 换行
                width = ruleWidth
                ret.rows = ret.rows + 1
                ret.ruleStr = ret.ruleStr .. "\n" .. v
            else
                ret.ruleStr = ret.ruleStr .. v
            end
        end
    else
        noWrap = true
    end

    if noWrap then
        ret.ruleStr = ""
        for i, v in ipairs(playingInfo) do
            ret.ruleStr = ret.ruleStr..v
        end
    end
    return ret
end

--是否存在当前玩法
--playName:玩法名称
function FriendRoomInfo:isHavePlayByName(playName)
    local retTable = { }
    local itemList = Util.analyzeString_2(self.m_selectRoomInfo.wa);
    if (#itemList > 0) then
        for i = 1, #itemList do
            local w = itemList[i]
			if(w==playName) then
			  return true;
			end
        end
    end
	return false;
end

-- --总对局数
-- function FriendRoomInfo:getTotalCount()
--   return tonumber(self:getSelectRoomInfo().roS);
-- end

-- --获取剩余局数
-- function FriendRoomInfo:getShengYuCount()
--    local totalNum=self:getTotalCount()--总对局数
--    local playingNum = kFriendRoomInfo:getRoomInfo().noRS
--    return (totalNum-playingNum)
-- end

-- 总对局数
function FriendRoomInfo:getTotalCount()
    local count = self:getSelectRoomInfo().roS or 0
    return tonumber(count);
end

-- 获取剩余局数
function FriendRoomInfo:getShengYuCount()
    local totalNum = self:getTotalCount() or 0
    -- 总对局数
    local playingNum = kFriendRoomInfo:getRoomInfo().noRS or 0
    return(totalNum - playingNum)
end

-- 获取当前局数
function FriendRoomInfo:getNowCount()
    return (kFriendRoomInfo:getRoomInfo().noRS or 0) + 1
end

function FriendRoomInfo:saveNumber(number)
    if number ~= nil then
        cc.UserDefault:getInstance():setStringForKey("roomNumberKey", number .. "");
        cc.UserDefault:getInstance():flush()
    end
end

-- 如果本局为房主所设局数的最后一局,“开始游戏”按钮改成“查看总战绩”按钮
function FriendRoomInfo:isGameEnd()
    return self.m_gameEnd;
end

function FriendRoomInfo:setGameEnd(isEnd)
    self.m_gameEnd = isEnd;
end

function FriendRoomInfo:getPalyerNameByID(tmpID)
    if (self.m_roomInfo.pl ~= nil) then
        for k, v in pairs(self.m_roomInfo.pl) do
            if (v.usI == tmpID) then
                return v.niN
            end
        end
    end
    return nil
end

-- 是否有免费活动
function FriendRoomInfo:isFreeActivities()
    local tmpInfo = self:getRoomBaseInfo()
    if (tmpInfo.isNeedRoomFee ~= nil and tmpInfo.isNeedRoomFee == "N") then
        return true
    end
    return false
end

--好友房等待界面是否正在交换状态
function FriendRoomInfo:setExchangeState(state)
    self.exchangeState = state
end

function FriendRoomInfo:getExchangeState()
    return self.exchangeState
end

kFriendRoomInfo = FriendRoomInfo.getInstance();

-------------------------------------------------------------------------
-- Desc:   扑克牌框架数据管理单例
-- Last: 
-- Author:   diyal.yin
-- Content:  数据管理对象
-- 2017-11-04  新建
-------------------------------------------------------------------------
DataMgr = class("DataMgr");
local BasePlayerDefine = require("package_src.games.paodekuai.pdkcommon.data.BasePlayerDefine")
local PokerDataConst = require("package_src.games.paodekuai.pdkcommon.data.PokerDataConst")

DataMgr.getInstance = function()
    if not DataMgr.s_instance then
        DataMgr.s_instance = DataMgr.new();
    end
    return DataMgr.s_instance;
end

------------------------------------------
-- @desc 注意！！！！！！！！！！！！！！
-- @      由于dataMgr是扑克游戏公用的单例 
-- @      所以在每次切换游戏时一定要release一下
--------------------------------------------
DataMgr.releaseInstance = function()
    if DataMgr.s_instance then
        DataMgr.s_instance:dtor();
    end
    DataMgr.s_instance = nil;
end

function DataMgr:ctor()
    self.wanfaData = nil  ---扑克玩法数据
    self.ensureLordId = false
    self.matchTotalRecord = {}
	self:init()
end

function DataMgr:dtor()
    self:init()
    self.ensureLordId = false
    self.matchTotalRecord = nil
end

function DataMgr:init()
	self._objectPool = {} --对象池，不关注对象成员的类型
end

-- 设置存储对象
-- @param key: 键
-- @param obj: 值 （所有类型）
function DataMgr:setObject(key, obj)
    assert(type(key) == "number", "DataMgr:setObject- invalid key")
    if key == 42 then
        print(key)
        Log.i("aaaaaaaaaaaa",obj)
    end
	self._objectPool[key] = obj
end

-- 设置存储对象
-- @param key: 键
-- @param obj: 值 （所有类型）
-- @param dispatch：是否分发事件, 分发的事件id为key
function DataMgr:setObject(key, obj, dispatch)
    assert(type(key) == "number", "DataMgr:setObject- invalid key")
    if key == 42 then
        print(key)
        Log.i("aaaaaaaaaaaa",obj)
    end
    self._objectPool[key] = obj
    if dispatch then
        HallAPI.EventAPI:dispatchEvent(key, obj )
    end
end

-- 获取数据对象
-- @param key: 队列管理消息
function DataMgr:getObjectByKey(key)
	assert(type(key) ~= nil, "DataMgr:getObject- invalid key")
	return self._objectPool[key]
end

function DataMgr:getNumberByKey(key)
    return checknumber(self._objectPool[key])
end

function DataMgr:getTableByKey(key)
    return checktable(self._objectPool[key])
end

function DataMgr:getBoolByKey(key)
    return checkbool(self._objectPool[key])
end

function DataMgr:getSeatByPlayerId(playerId)
    local PlayerModelList = self:getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.USERID) == playerId then
            return v:getProp(BasePlayerDefine.SITE)
        end
    end

    printError("[Error]: cant't find Player", playerId)
    return -1
end

function DataMgr:getIdBySeat(seat)
    local PlayerModelList = self:getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.SITE) == seat then
            return v:getProp(BasePlayerDefine.USERID)
        end
    end

    -- Log.i("PlayerModelList: ", PlayerModelList)
    printError("[Error]: cant't find Player", playerId)
    
    return -1
end

function DataMgr:getPlayerInfo(playerId)
    local PlayerModelList = self:getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.USERID) == playerId then
            return v
        end
    end

    -- Log.i("PlayerModelList: ", PlayerModelList)
    printError("[Error]: cant't find Player", playerId)
end

function DataMgr:isPlayerExist(playerId)
    local PlayerModelList = self:getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.USERID) == playerId then
            return true
        end
    end

    return false
end

function DataMgr:getMyPlayerModel()
    local PlayerModelList = self:getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    Log.i("HallAPI.DataAPI:getUserId()", HallAPI.DataAPI:getUserId())

    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.USERID) == HallAPI.DataAPI:getUserId() then
            return v
        end
    end
    return nil
end

-- 函数功能：   保存倍数
-- 返回值：     无
-- info:        倍数信息
function DataMgr:setPlayerMultiple(info)
    self.playerMultipleList = {}
    self.playerMultipleList = info
end

-- 函数功能：   获取玩家倍数
-- 返回值：     玩家倍数
-- playerId:    玩家id
function DataMgr:getPlayerMultipleById(playerId)
    if not self.playerMultipleList then
        return 0
    end
    for i, v in pairs(self.playerMultipleList) do
        if i and i == tostring(playerId) then
            return v
        end
    end
end

--函数功能：    保存玩家分数
--返回值：      无
--userid:       玩家ID
--score：       需要保存的分数
function DataMgr:SetPlayerScore(userid,score)
    if userid then
        self.playerScore = self.playerScore or {}
        self.playerScore[userid] = score
    else
        self.playerScore = {}
    end
end
--函数功能：    获取保存的玩家分数
--userid:       玩家的id
--返回值：       玩家已保存的分数
function DataMgr:GetPlayerScore(userid)
    if not self.playerScore or table.nums(self.playerScore) <= 0 or not self.playerScore[userid] then
        return 0
    end 
    return self.playerScore[userid]
end


-- 函数功能：   获取地主倍数
-- 返回值：     地主倍数
function DataMgr:getDiZhuMultiple()
    if not self.playerMultipleList then
        return 0
    end
    local multiple_list= {}
    for i, v in pairs(self.playerMultipleList) do
        multiple_list[#multiple_list + 1] = v
    end
    table.sort(multiple_list,function (a,b)
        return a < b
    end) 

    return multiple_list[#multiple_list]
end

-- 函数功能：   保存玩法数据
-- 返回值：     无
-- info :      玩法数据
function DataMgr:setWanfaData(info)
    self.wanfaData =  info
end

-- 函数功能：   获取当前玩法
-- 返回值：     无
-- info :      玩法数据
function DataMgr:getWanfaData()
    return self.wanfaData
end

-- 函数功能：   保存玩法数据
-- 返回值：     无
function DataMgr:isVisitPokerNumber()
    if not self.wanfaData then
        return false 
    end 

    for k,v in pairs(self.wanfaData) do
        if v == "syp" then
            return true
        end
    end
    return false
end

-- 函数功能：   确保已经是地主了
-- 返回值：     无
function DataMgr:setSureLordFlag(key)
    self.ensureLordId = true
end

-- 函数功能：   确保已经是地主了
-- 返回值：     无
function DataMgr:reSureLordFlag()
    self.ensureLordId = false
end


-- 函数功能：   确保已经是地主了
-- 返回值：     无
function DataMgr:getsureLordFlag()
    return self.ensureLordId
end

function DataMgr:getFullBeiShu()
    if not self.wanfaData then
        return false 
    end 

    local jiaodizhu = 1
    local topBeiShu = 1
    for k,v in pairs(self.wanfaData) do
        if v == "1b" then
            jiaodizhu = 1
        elseif  v == "2b" then
            jiaodizhu = 2
        elseif  v == "3zha" then
            topBeiShu = 1
        elseif  v == "4zha" then
            topBeiShu = 2
        elseif  v == "5zha" then
            topBeiShu = 4
        end
    end

    return jiaodizhu*topBeiShu*8
end

function DataMgr:setMatchRecord(matchRecordInfo)
    self.matchRecord = matchRecordInfo
end


function DataMgr:getMatchRecord()
    return self.matchRecord
end

function DataMgr:getDisMissFlag()
    return self.m_disMissFlag
end

function DataMgr:setDisMissFlag(disMissFlag)
    self.m_disMissFlag = disMissFlag
end

function DataMgr:setMatchTotalRecord(matchTotalRecordInfo)
    self.matchTotalRecord = matchTotalRecordInfo
end

function DataMgr:getMatchTotalRecord()
    return self.matchTotalRecord
end
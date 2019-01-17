--DataAPI
local DataAPI = class("DataAPI")

function DataAPI:ctor()
    --print("===========DataAPI============ssssssssssssss")
end

--desc: 获取用户数据
--return{number}
function DataAPI:getUserId()
	return kUserInfo:getUserId()
end

--desc: 获取用户名字
--return{string}
function DataAPI:getUserName( )
    return kUserInfo:getUserName()
end

--desc:性别
--@return{number}
function DataAPI:getUserSex()
    return kUserInfo:getUserSex()
end

--返回游戏ID
function DataAPI:getGameId()
    return kFriendRoomInfo:getGameID()
end

--返回房间id
function DataAPI:getRoomId()
    return kFriendRoomInfo:getRoomId()
end

--返回游戏类型
function DataAPI:getGameType()
    return StartGameType.FIRENDROOM
end

--返回金豆？？
function DataAPI:getMoney()
    return kUserInfo:getMoney()
end
--返回银行金豆？？
function DataAPI:getBagMoney()
    return kUserInfo:getBagMoney()
end

-----------------------------------------------房间信息
--desc: 获取房间信息
--return{table}
function DataAPI:getRoomInfo()
	return kFriendRoomInfo:getRoomInfo()
end

--desc: 根据id获取朋友房房间玩家的信息
function DataAPI:getRoomPlayerListInfo(playerID)
    return kFriendRoomInfo:getRoomPlayerListInfo(playerID)
end

--获得朋友房间玩家信息列表
function DataAPI:getRoomPlayerList()
    return kFriendRoomInfo:sortPlayerInfo()
end

--@desc: 根据游戏ID，获取当前房间信息
--@param nGameId{number} 游戏ID
--@param nRoomId{number} 房间ID
--return
function DataAPI:getRoomInfoById(nGameId,nRoomId)
    return kFriendRoomInfo:getRoomInfo()
end

---游戏名字
function DataAPI:getGameName(gameId)
    return kFriendRoomInfo:getGameName(gameId)
end

--desc: 是否是房主
--return{bool}
--param userID{type:number} 角色ID
function DataAPI:isRoomMain(userId)
    return kFriendRoomInfo:isRoomMain(userId)
end

--获取当前局数
function DataAPI:getJuNowCnt()
    return kFriendRoomInfo:getNowCount()
end

--总局数
function DataAPI:getJuTotal()
    return kFriendRoomInfo:getTotalCount()
end

--剩余局数
function DataAPI:getJuRemain()
    return kFriendRoomInfo:getShengYuCount()
end

--设置默认玩法
function DataAPI:setSelectAreaGameID(gameId)
    SettingInfo.getInstance():setSelectAreaGameID(gameId)
end

--获取当前钻石
function DataAPI:getDiamond()
    return kUserInfo:getPrivateRoomDiamond()
end


--获取头像
function DataAPI:getHeadImg()
    return kUserInfo:getHeadImg()
end

---清除房间信息
function DataAPI:clearRoomData()
    kFriendRoomInfo:clearData()
end

--是否亲友圈房间
function DataAPI:isClubMode()
    return kFriendRoomInfo:isClubMode()
end

--desc: 设置房间信息
--packInfo: 服务器的房间信息(22006)
function DataAPI:setRoomInfo(packInfo)
    kFriendRoomInfo:setRoomInfo(packInfo)
end


--所设局数的最后一局
function DataAPI:setGameEnd(isEnd)
     kFriendRoomInfo:setGameEnd(isEnd)
end

--所设局数的最后一局
function DataAPI:isGameEnd()
    return  kFriendRoomInfo:isGameEnd()
end

----------------------------------------------发送协议
function DataAPI:send(nCode, nSubcode,tMsgData)
    SocketManager.getInstance():send(nCode, nSubcode, tMsgData);
end

------------------计算距离
---自己的经度，纬度，其他人的经度，纬度
function DataAPI:getDistance(LonA, LatA, LonB, LatB)
    local juli
    if IsPortrait then -- TODO
        if LonA == 0 or LatA == 0 or LonB == 0 or LatB == 0 then
            juli = "无法获取位置"
        else
            local distance = ToolKit.getDistance(LonA, LatA, LonB, LatB);
            juli = string.format("%s",ToolKit.formatDistance(distance))
        end
    else
        if (LonA == 0 and LatA == 0) or (LonB == 0 and LatB == 0) then
            juli = "无法获取位置"
        else
            local distance = ToolKit.getDistance(LonA, LatA, LonB, LatB);
            juli = string.format("%s",ToolKit.formatDistance(distance))
        end
    end
    return juli
end

function DataAPI:setNetStateInfo(info)
    kSystemConfig:setNetStateInfo(info)
end

function DataAPI:getNetStateInfo()
    return kSystemConfig:getNetStateInfo()
end

function DataAPI:isWifi()
    return kSystemConfig:isWifi()
end

return DataAPI
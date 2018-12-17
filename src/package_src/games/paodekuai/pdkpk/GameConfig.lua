local DDZPLAYERCOUNT = {
    DDZCOUNT = 3,
    DDZTWOPCOUNT = 2,
}

local DDZPKPath = {
    PDK = "pdk",
    PDKTWOP = "pdktwop",
}

function enterDDZPKGame(gameId, playerCount)
    loadGame(gameId)
	local gameType = kFriendRoomInfo:getGameType();
	HallAPI.DataAPI:setSelectAreaGameID(HallAPI.DataAPI:getGameId())
	
	local pathName = " "
	Log.i("playerCount", playerCount)
	if playerCount == DDZPLAYERCOUNT.DDZCOUNT then

		pathName = DDZPKPath.PDK
		Log.i("pathName1", pathName)
	elseif playerCount == DDZPLAYERCOUNT.DDZTWOPCOUNT then

		pathName = DDZPKPath.PDKTWOP
		Log.i("pathName2", pathName)
    else
        pathName = DDZPKPath.PDK
	end

	local gameName = string.upper(pathName);

	
	local gameConfig = "package_src.games.paodekuai." .. pathName .. ".GameConfig";
	package.loaded[gameConfig] = nil;
    Log.i("--wangzhi--gameConfig--",gameConfig)
	local isSuccess, errMsg = pcall(require, gameConfig);
	if not isSuccess then
		Toast.getInstance():show("请先下载此游戏！333");
		Log.i("errMsg", errMsg)
		return;
	end

	local gameUpperConfig = "package_src.games.paodekuai." .. pathName .. "." .. gameName .. "Config";
	package.loaded[gameUpperConfig] = nil;
	require(gameUpperConfig);
	enterGame();
end
--进入游戏界面
function enterGame(data)
    local roomInfo = kFriendRoomInfo:getRoomInfo()
    Log.i("roomInfo ", roomInfo)
    -- if roomInfo.plS == DDZPLAYERCOUNT.DDZCOUNT then
    enterDDZPKGame(roomInfo.gaID, roomInfo.plS)
    -- elseif roomInfo.plS == DDZPLAYERCOUNT.DDZTWOPCOUNT then
    --     enterDDZPKGame(POKERGAMEID.DDZTWOP)
    -- end
end

-- 获取分享信息
function getWxShareInfo(roomInfo, playerInfo, selectSetInfo)
    -- Log.i("getWxShareInfo....", roomInfo, playerInfo, selectSetInfo)
    local paramData = {}
    paramData[1] = playerInfo.pa .. ""
    local title = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        title = Util.replaceFindInfo(roomInfo.shareTitle, '房间号', {'亲友圈房间号'})
        title = Util.replaceFindInfo(title, 'd', paramData)
    else
        title = Util.replaceFindInfo(roomInfo.shareTitle, 'd', paramData)
    end

    local itemList=Util.analyzeString_2(selectSetInfo.wa);
    if(#itemList>0) then
        local str=""
        for i=1,#itemList do
            local st = string.format("%s,",kFriendRoomInfo:getPlayingInfoByTitle(itemList[i]).ch)
            Log.i("st", st)
            str = str .. st 
        end
        paramData[1] = str
    else
        paramData[1] = ""
    end      
    --
    local playernum = (selectSetInfo.plS and selectSetInfo.plS > 1 and selectSetInfo.plS <= 4 and selectSetInfo.plS or 4 ) .. "人房,"
    paramData[2] = playernum

    paramData[2]= paramData[2] .. selectSetInfo.roS;
    -- Log.i("------roomInfo.shareDesc",roomInfo.shareDesc);
    local wanjiaStr = "";
    for k, v in pairs(playerInfo.pl) do
       local retName = ToolKit.subUtfStrByCn(v.niN, 0,  5, "");
       wanjiaStr = wanjiaStr .. retName .. ","
    end
    paramData[1] = paramData[1] .. wanjiaStr
    local charge = ""
    if selectSetInfo.clI and selectSetInfo.clI > 0 then
        charge = "亲友圈付费"
    else
        local texts = {"房主付费", "大赢家付费", "AA付费"}
        charge = (selectSetInfo.RoJST and selectSetInfo.RoJST >= 1 and selectSetInfo.RoJST <= 3) and texts[selectSetInfo.RoJST] or texts[1]
    end
    paramData[2] = paramData[2] .. "局," .. charge

    local s = Util.replaceFindInfo(roomInfo.shareDesc, '局', {[1]=""})

    local desc = Util.replaceFindInfo(s, 'd', paramData)

    return title, desc
end
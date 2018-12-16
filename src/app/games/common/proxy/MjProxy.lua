-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local Define = require "app.games.common.Define"
--local WWFacade = require("app.games.common.custom.WWFacade")

MjProxy = class("MjProxy")

MjProxy.getInstance = function()
    if not MjProxy.s_instance then
        local filePath = "src/package_src/games/".._gameType.."/proxy/BranchProxy.lua"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
        local file = io.exists(filePath)
        assert(file ~= nil)
        local moduleProxy = nil
        if not file then
            filePath = "src/package_src/games/".._gameType.."/proxy/BranchProxy.luac"
            filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath);
            file = io.exists(filePath)
            assert(file ~= nil)
        end
        if file then
            moduleProxy = require("package_src.games.".._gameType..".proxy.BranchProxy")
        end
        if moduleProxy ~= nil then
            MjProxy.s_instance = moduleProxy.new();
        else
            MjProxy.s_instance = MjProxy.new()
        end
    end

    return MjProxy.s_instance;
end

MjProxy.releaseInstance = function()
    if MjProxy.s_instance then
        MjProxy.s_instance:dtor();
    end
    MjProxy.s_instance = nil;
end

MjProxy.ctor = function(self)
	self:init()
end

MjProxy.dtor = function(self)
end

function MjProxy:init()
    self._buhua = false
    self.laizi  = 0
    self.playId = 0
    self.gameId = 0 
    self.roomId = 0
    self.huMj   = 0
    self.actionType = 0
    self.deskDismiss = false
    self._is_playmahjong = false
    self.roomInfo = {}
    self._players = {}
	self.gameOver = false
	self.substitute = false	
	-- self._allPlayerHasXiaPao = false
    self._isShowFlow = true
    self._defaultChar = {}
    self._reflashMyMJ = {}
    -- 设置动作类型，为了给拉庄和跑使用

    self.actionType   = Define.action_xiaPao
    self.modeTypeNum  = {} -- 模式类型数量
    self.isResume     = false -- 是否是恢复对局

    self.systemDatasQueue = {}
end

-- 初始化游戏辅助数据
function MjProxy:initAuxiliaryData()
	Log.i("MjProxy:initAuxiliaryData")
	self.gameOver = false
	self.substitute = false	
	self._gameOverData = { }
	for i = 1, 4 do 
	 	if self._players[i] then
		self._players[i]:setHasClickTing(false)
		self._players[i]:setHasSendTing(false)
		self._players[i]:setCanPlay(false)
		self._players[i]:setActionTimes(0)
		self._players[i]:setGangTimes(0)
		self._players[i]:setFapaiFished(false)
		self._players[i]:setTaskFinished(false)
		self._players[i]:setTaskMultiple(0)
		self._players[i].m_arrMyActionMj = {} 
		self._players[i].m_arrMyActionType = {} 
		self._players[i].cards = { }
		self._players[i].gameInfo = { }
		end    
	end  
end

function MjProxy:getPlayId()
	return self.playId
end

function MjProxy:setPlayId(playId)
	self.playId = playId
end

function MjProxy:getSubstitute()
	return self.substitute or false
end

function MjProxy:setSubstitute(substitute)
	self.substitute = substitute
end

function MjProxy:getGameOver()
	return self.gameOver or false
end

function MjProxy:setGameOver(gameOver)
	self.gameOver = gameOver
end

function MjProxy:setBuHua(buhua)
    self._buhua = buhua
end
function MjProxy:getBuHua()
    return self._buhua or false
end

function MjProxy:getMyUserId()
	return kUserInfo:getUserId() or 0
end
function MjProxy:getUserSex()
    return kUserInfo:getUserSex() or 0
end


function MjProxy:setLaizi(laizi)
    self.laizi = laizi
end

function MjProxy:getLaizi()
    return self.laizi or 1
end

function MjProxy:setGameId(gameId)
    self.gameId = gameId
end

function MjProxy:getGameId()
    return self.gameId or 0
end

function MjProxy:setRoomInfo(roomInfo)
    self.roomInfo = roomInfo
end

function MjProxy:getRoomInfo()
    return self.roomInfo
end

function MjProxy:setRoomId(roomId)
    self.roomId = roomId
end

function MjProxy:getRoomId()
    return self.roomId or 0
end

function MjProxy:setHuMj(mj)
    self.huMj = mj
end

function MjProxy:getHuMj()
    return self.huMj or 0
end

function MjProxy:getIsPlayMahjong()
    return self._is_playmahjong or false
end
--背景音乐的开关
function MjProxy:setMusicPlaying(playing)
    kSettingInfo:setMusicStatus(playing)
end
function MjProxy:getMusicPlaying()
    local playingInfo = kSettingInfo:getMusicStatus()
    return playingInfo
end
--音效的开关
function MjProxy:setSoundPlaying(playing)
    kSettingInfo:setSoundStatus(playing)
end
function MjProxy:getSoundPlaying()
    local playingInfo = kSettingInfo:getSoundStatus()
    return playingInfo 
end
--方言的开关
function MjProxy:setDialectPlaying(playing)
    kSettingInfo:setGameDialectStatus(playing)
end
function MjProxy:getDialectPlaying()
    local playingInfo = kSettingInfo:getGameDialectStatus()
    return playingInfo
end
--单点设置
function MjProxy:setSinglePlaying(playing)
    kSettingInfo:setGameSingleStatus(_gameAudioEffectPath,playing)
end
function MjProxy:getSinglePlaying()
    local playingInfo = kSettingInfo:getGameSingleStatus(_gameAudioEffectPath)
    return playingInfo
end

function MjProxy:get_gameChatTxtCfg()
    local gameId = self:getGameId()
    local sex = self:getUserSex()
    local yuyan = "putong"
    if sex == 0 then
        --因为以前设定为第一句一定为男声第二句一定为女生
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            -- "",
            "不打的你满脸桃花开，你就不知道花儿为什么这样红！",
            "没了吧？用不用给你留点盘缠回家啊？",
            "哇！土豪，咱们做朋友吧!",
            "不是吧？这样都能赢！",
        };
    else
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            -- "",
            "不打的你满脸桃花开，你就不知道花儿为什么这样红！",
            "没了吧？用不用给你留点盘缠回家啊？",
            "哇！土豪，咱们做朋友吧!",
            "不是吧？这样都能赢！",
        };
    end
end

function MjProxy:get_gameChatTxtCfg2()
    local gameId = self:getGameId()
    local sex = self:getUserSex()
    local yuyan = "putong"
    if sex == 0 then
        _gameChatTxtCfg = {
            "不怕神一样的对手,就怕猪一样的队友！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要和我抢,地主是我的！",
            "不要走,再战三百回合！",
            "和我斗,你还嫩了点！",
        };
    else
        -- self.gameChatTxtCfg = csvConfig.femaleChatList
        -- _gameChatTxtCfg = csvConfig.femaleChatList
        _gameChatTxtCfg = {
            "不怕神一样的对手,就怕猪一样的队友！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要和我抢,地主是我的！",
            "不要走,再战三百回合！",
            "和我斗,你还嫩了点！",
        };
    end
end

function MjProxy:get_gameChatTxtCfg3()
    local gameId = self:getGameId()
    local sex = self:getUserSex()
    local yuyan = "putong"
    if sex == 0 then
        --因为以前设定为第一句一定为男声第二句一定为女生
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "和我斗，你还嫩了点！",
            "不是吧！这样都能赢！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要走再战300回合!",
        };
    else
        -- self.gameChatTxtCfg = csvConfig.femaleChatList
        -- _gameChatTxtCfg = csvConfig.femaleChatList
        _gameChatTxtCfg = {
            "你这呆子！快点快点啊！",
            "和我斗，你还嫩了点！",
            "不是吧！这样都能赢！",
            "不要吵了!不要吵了!专心玩游戏吧！",
            "不要走再战300回合!",
        };
    end
end

function MjProxy:setDeskDismiss(deskDismiss)
    self.deskDismiss = deskDismiss
end

function MjProxy:getDeskDismiss()
    return self.deskDismiss or false
end

--[[
-- @brief  设置拉或者跑动作类型函数
-- @param  void
-- @return void
--]]
function MjProxy:setModeType(hasXiaPao)
    self.actionType = hasXiaPao
end
--[[
-- @brief  获取拉或者跑动作类型函数
-- @param  void
-- @return void
--]]
function MjProxy:getModeType()
    return self.actionType or Define.action_xiaPao
end

--[[
-- @brief  获取开局标志
-- @param  void
-- @return void
--]]
function MjProxy:getStartGame()
    return self.m_gameStart or false
end

--[[
-- @brief  设置开局标志
-- @param  startFlag 开局标志
-- @return void
--]]
function MjProxy:setStartGame(startFlag)
    self.m_gameStart = startFlag 
end

--[[
-- @brief  获取需要显示加注的列表
-- @param  site 座位
-- @return 需要显示的列表值
--]]

function MjProxy:getShowFillingListBySite(site)
    local showList = {}
    -- 判断是否是庄家,庄家只能坐和跑，不能拉
    local fillingList   = MjProxy:getInstance()._players[site]:getFillingNum()
    local needList      = MjProxy:getInstance()._players[site]:getNeedFilling()
    local userid        = MjProxy:getInstance()._players[site]:getUserId()
    if MjProxy:getInstance()._gameStartData.bankPlay == userid then
        for k, v in pairs(fillingList) do
            -- 不能拉庄
            if k ~= Define.action_laZhuang 
                and v < 0 
                and needList[k]  then
                showList[k] = v
            end
        end
    else
        -- 不是庄家只能跑和拉
        for k, v in pairs(fillingList) do
            -- 不能坐
            if k ~= Define.action_zuo 
                and v < 0 
                and needList[k] then
                showList[k] = v
            end
        end
    end
    return showList
end
--[[
-- @brief  插入系统数据到队列表函数
-- @param  data 系统数据
-- @return void
--]]
function MjProxy:pushSystemData(data)
    table.insert(self.systemDatasQueue, data)
end
--[[
-- @brief  从系统数据队列弹出函数
-- @param  void
-- @return void
--]]
function MjProxy:popSystemData()
    table.remove(self.systemDatasQueue, 1)
end

--[[
-- @brief  获取数据队列函数
-- @param  void
-- @return void
--]]
function MjProxy:getSystemDatas()
    return self.systemDatasQueue
end






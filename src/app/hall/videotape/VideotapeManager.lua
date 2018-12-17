-------------------------------------------------------------
--  @file   VideotapeManager.lua
--  @brief  录像管理者类
--  @author ZCQ
--  @DateTime:2016-10-21 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
-- ============================================================
VideotapeManager = class("VideotapeManager")
VideotapeManager.getInstance = function()
    if not VideotapeManager.s_instance then
        VideotapeManager.s_instance = VideotapeManager.new();
    end

    return VideotapeManager.s_instance;
end

VideotapeManager.releaseInstance = function()
    if VideotapeManager.s_instance then
        VideotapeManager.s_instance:dtor();
    end
    VideotapeManager.s_instance = nil;
end
-- 字码类型
local kSubCodeType = {
    -- 接收消息Id
    gameStart = 31001,
    -- 接收消息Id
    ddzGameStart = 32012,

    ddzGameOver = 32020,

    ddzReconnect = 32016,

    -- 开局
    reqPlayCard = 31002,
    -- 请求出牌
    playCard = 31003,
    -- 打牌
    mjAction = 31004,
    -- 特殊操作
    gameOver = 31006,
    -- 结算
    flower = 31008,
    -- 补花
    substitute = 30008,
    -- 托管
    gameResume = 31009,
    -- 恢复对局响应
    dispenseCard = 31011,
    -- 摸牌
    xiapao = 31012,
    -- 下炮
    continue = 30006,
    -- 玩家确定续局
    user_chat = 30009,
    -- 用户自定义输入
    default_char = 30010,
    -- 用户使用系统操作
    update_taken_cash = 30002,
    -- 更新携带
    dismissDesk = 30012,
    -- 散桌
    leaveStatus = 30017-- 同步离开状态
}
-- 运行时间
local kActionTime = {
    -- 接收消息Id
    [kSubCodeType.gameStart] = 9,
    -- 开局
    [kSubCodeType.playCard] = 1.5,
    -- 打牌
    [kSubCodeType.mjAction] = 1.5,
    -- 特殊操作
    [kSubCodeType.gameOver] = 2,
    -- 结算
    [kSubCodeType.flower] = 2,
    -- 补花
    [kSubCodeType.substitute] = 2,
    -- 托管
    [kSubCodeType.gameResume] = 2,
    -- 恢复对局响应
    [kSubCodeType.dispenseCard] = 0.8,
    -- 摸牌
    [kSubCodeType.xiapao] = 1,
    -- 下炮
    [kSubCodeType.continue] = 2,
    -- 玩家确定续局
    [kSubCodeType.user_chat] = 2,
    -- 用户自定义输入
    [kSubCodeType.default_char] = 2,
    -- 用户使用系统操作
    [kSubCodeType.update_taken_cash] = 2,
    -- 更新携带
    [kSubCodeType.dismissDesk] = 2,
    -- 散桌
    [kSubCodeType.leaveStatus] = 1-- 同步离开状态
}
local kSpeedTime = 16 -- 允许快进时间
local kXiaZui   = 29 -- 下嘴
local kLaZhuang = 32 -- 拉庄
local kZuo      = 33 -- 坐
local kPiao     = 34 -- 飘
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function VideotapeManager:ctor()
    self.isPlaying = false
    self.leaveMsgNum = 0
    self:init()
end
--[[
-- @brief  析构函数
-- @param  void
-- @return void
--]]
function VideotapeManager:dtor()
    self:stopSchedule()
    self.isPlaying = false
    self.leaveMsgNum = 0
end

--[[
-- @brief  初始数据函数
-- @param  void
-- @return void
--]]
function VideotapeManager:init()
    self.playHandle = nil
    self.intervalTime = kActionTime[kSubCodeType.gameStart]
    -- 默认第一步是9秒间隔
    self.count = 0
    self.startTime = 0
    self.isPaused = false
    -- 是否暂停开关
    self.isSpeed = false
    -- 是否是快进
    self.isPlayingEnd = false
    -- 是否播放结束
    self.isShowTipView = false

    -- self.leaveMsgNum = 0
    -- self.allowTime  = 0     -- 允许快进时间标志
    -- self.allowFlag  = false -- 允许快进标志
end


--[[
-- @brief  激活
-- @param  void
-- @return void
--]]
function VideotapeManager:activate()
    self:beginPlayVideo()
end

--[[
-- @brief  反激活
-- @param  void
-- @return void
--]]
function VideotapeManager:deactivate()
    self.isPlaying = false
    self:stopSchedule()
end

--[[
-- @brief  反激活
-- @param  void
-- @return void
--]]
function VideotapeManager:beginPlayVideo()
    self:init()
    self.isPlaying = true
    self:startSchedule()
end

--[[
-- @brief  启动定时器
-- @param  void
-- @return void
--]]
function VideotapeManager:startSchedule()
    -- 初始化动作
    self:startScheduleInfo()
end

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function VideotapeManager:startScheduleInfo()
    -- local playbackInfo = kPlaybackInfo:getPlaybackData()
    local playbackInfo = kPlaybackInfo:getPlaybackData()
    -- 先要判断是否有下嘴,下嘴处理情况
    local jsonCont = json.decode(playbackInfo[1].content)
    -- 下嘴特殊处理
    local gameStartTime = kActionTime[kSubCodeType.gameStart]
    if self.laPaoZuNum > 0 then
        local delayTime = kActionTime[kSubCodeType.gameStart]
        + self.leaveMsgNum * kActionTime[kSubCodeType.leaveStatus]
        + self.laPaoZuNum * kActionTime[kSubCodeType.xiapao]
        + 2
        kPlaybackInfo:setSpeedDelayTime(delayTime)
    else
        kPlaybackInfo:setSpeedDelayTime(kActionTime[kSubCodeType.gameStart] + 2)
    end

    local hasXiaoNum = 0
    -- 已经下跑的人数
    self.playHandle = scheduler.scheduleGlobal( function(dt)
        self.startTime = self.startTime + dt
        if playbackInfo[self.count] then
            -- 下跑开局时间是1
            if self.laPaoZuNum > 0
                and playbackInfo[self.count].subcode == kSubCodeType.gameStart then
                self.intervalTime = 1
            else
                self.intervalTime = kActionTime[playbackInfo[self.count].subcode] or 1
            end
        else
            self.intervalTime = 1
        end

        -- 等待四个人全下嘴或者下跑之后重置发牌延时
        if hasXiaoNum >= self.laPaoZuNum 
            and hasXiaoNum ~= 0 then
            self.intervalTime = gameStartTime
        end
        -- 没有到最后一步就可以执行分发消息函数
        if self.startTime >= self.intervalTime then

            if hasXiaoNum >= self.laPaoZuNum then
                hasXiaoNum = -1
            end
            --  设置快进允许标志
            self.startTime = 0
            if self.count < #playbackInfo and self.count >= 0 then
                local info = { }
                table.insert(info, playbackInfo[self.count + 1])
                if playbackInfo[self.count + 1].subcode == kSubCodeType.mjAction then
                    local content = json.decode(playbackInfo[self.count + 1].content)
                    if content.acID == kXiaZui-- 下嘴
                        or content.acID == kLaZhuang 
                        or content.acID == kZuo 
                        or content.acID == kPiao then
                        -- 拉庄
                        hasXiaoNum = hasXiaoNum + 1
                    end
                end
                self.count = self.count + 1
                SocketManager:getInstance():onRecordReceivePacket(info)
            else
                self:stopSchedule()
                self.count = -1
                self.isPlayingEnd = true
                self:showEndReturnUI();
            end
        end

    end , 0.2)
end

--[[
-- @brief  停止定时器
-- @param  void
-- @return void
--]]
function VideotapeManager:stopSchedule()
    if self.playHandle then
        scheduler.unscheduleGlobal(self.playHandle)
        self.playHandle = nil
    end
end

--[[
-- @brief  回放信息
-- @param  void
-- @return void
--]]
function VideotapeManager:reSponseInfo(fileName)
    if fileName == nil then
        return;
    end

    Log.i("reSpeonnnn==============>>>", fileName)
    local jsonFile = CACHEDIR .. fileName

    -- -- 解压缩
    -- if string.find(fileName, "zip") then
    --     local unzipPath = CACHEDIR .. "unzip/"
    --     require("lfs")
    --     lfs.mkdir(unzipPath)
    --     luckyUnCompress(jsonFile, unzipPath)

    --     cc.FileUtils:getInstance():removeFile(jsonFile)
    --     jsonFile = unzipPath .. fileName
    -- end

    -- 获取文件数据
    local levelFileStr
    if string.find(fileName, "zip") then
        -- 解压缩
        local FileLog = require('app.common.FileLog')
        levelFileStr = FileLog.decompress(jsonFile)
    else
        levelFileStr = cc.HelperFunc:getFileData(jsonFile)
    end

    local levelFileData = json.decode(levelFileStr)
    -- dump(levelFileData)
    local myInfo = { }
    local startInfo = { }
    local ddzStartInfo = { }
    local site = 1
    -- 座次
    self.leaveMsgNum    = 0
    -- 拉跑坐次数
    self.laPaoZuNum     = 0 
    local finishXia = false
    local myUserid = kUserInfo:getUserId()
    local startMsgIndex = 1
    for i = 1, #levelFileData.messages do
        if levelFileData.messages[i].code == kSubCodeType.gameStart then
            startMsgIndex = i
            break
        end
    end
    local jsonCont = json.decode(levelFileData.messages[startMsgIndex].jsonContent)

    local startGameCount = 0
    for i = 1, #levelFileData.messages do
        local jsonCont = json.decode(levelFileData.messages[i].jsonContent)
        -- 过滤掉游戏结束结算信息
        if jsonCont.recUserId == myUserid then
            -- if (levelFileData.messages[i].code == kSubCodeType.gameOver
                -- and jsonCont.wi ~= 3) then
                -- -- 流局的信息保留

            -- else
                local tempInfo = self:contentNameChange(levelFileData.messages[i])
                local jsonCont = json.decode(tempInfo.content)
                -- 过滤听牌消息
                if tempInfo.subcode == kSubCodeType.reqPlayCard or tempInfo.subcode == kSubCodeType.ddzReconnect then

                else
                    table.insert(myInfo, tempInfo)
                end

                if tempInfo.subcode ~= kSubCodeType.gameStart then
                    if tempInfo.subcode ~= kSubCodeType.leaveStatus
                        or tempInfo.subcode ~= kSubCodeType.mjAction
                        and not finishXia then
                        if tempInfo.subcode == kSubCodeType.mjAction then
                            if jsonCont.acID == kXiaZui-- 下嘴
                                or jsonCont.acID == kLaZhuang 
                                or jsonCont.acID == kZuo
                                or jsonCont.acID  == kPiao then
                                self.laPaoZuNum = self.laPaoZuNum + 1
                            else
                                finishXia = true
                            end
                        end
                    else
                        finishXia = true
                    end
                end
               
                -- 记录打牌过程中离开的消息数
                if not finishXia then
                    if tempInfo.subcode == kSubCodeType.leaveStatus then
                        self.leaveMsgNum = self.leaveMsgNum + 1
                    end
                end
            -- end
        end

        if levelFileData.messages[i].code == kSubCodeType.gameStart then
            local startData = self:contentNameChange(levelFileData.messages[i])
            -- 转换协议内容为json
            local jsonContent = json.decode(startData.content)
            startData.content = jsonContent
            startData.site = site
            site = site + 1
            startInfo[jsonContent.recUserId] = startData
        elseif levelFileData.messages[i].code == kSubCodeType.ddzGameStart then
            local startData = self:contentNameChange(levelFileData.messages[i])
            -- 转换协议内容为json
            local jsonContent = json.decode(startData.content)
            startData.content = jsonContent
            startData.site = site
            site = site + 1
            startInfo[jsonContent.recUserId] = startData
            startGameCount = startGameCount + 1
            if startGameCount == 3 then
                startGameCount = 0
                local tmpStartInfo = clone(startInfo)
                table.insert(ddzStartInfo,tmpStartInfo)
                kPlaybackInfo:setddzStartGameData(ddzStartInfo)
            end
        end

        -- 统计离桌的消息
    end
    -- 接收进入房间邀请请求
    local enterRoom = self:contentNameChange(levelFileData.messages[1])
    local enterData = { }
    table.insert(enterData, enterRoom)
    local roominfo = json.decode(enterRoom.content)
    kFriendRoomInfo:setSelectRoomInfo(roominfo);
    kFriendRoomInfo:setRoomInfo(roominfo)
    Log.i("--wangzhi--战绩回放的开局数据--",startInfo)
    -- 进入好友开房
    -- 设置回放数据
    kPlaybackInfo:setPlaybackData(myInfo)
    kPlaybackInfo:setStartGameData(startInfo)

    -- 判断是不是需要用其它字段名去取消息内容
    local isChangeInfo = false
    if REPLAY_ID_LIST_CHANGER then
        for k,v in pairs(REPLAY_ID_LIST_CHANGER) do
            if v == roominfo.gaI then
                isChangeInfo = true
            end
        end                
    end

    local roomidOne
    local roomid
    local gameId

    -- 因为麻将和斗地主的回放文件字段名不一样，这里做一下区分
    if not isChangeInfo then
        roomidOne = self:getJsonFileName(startInfo[myUserid].content.plID, "-", false)
        roomid = self:getJsonFileName(roomidOne, "_", true)
        gameId = startInfo[myUserid].content.gaID
    elseif isChangeInfo then
        roomidOne = self:getJsonFileName(startInfo[myUserid].content.gaPI, "-", false)
        roomid = self:getJsonFileName(roomidOne, "_", true)
        gameId = startInfo[myUserid].content.gaI
    end
    local packetInfo = {
        re = 1,
        roI = tonumber(roomid),
        gaI = gameId,
        isRusumeGame = false,
    }
    self:activate()
    kFriendRoomInfo:setRoomId(roomid)

    cc.FileUtils:getInstance():removeFile(jsonFile)
    kGameManager:enterFriendRoomGame(packetInfo)
end

-- 改变变量名字
--[[
-- @brief  拼装消息函数
-- @param  void
-- @return void
--]]
function VideotapeManager:contentNameChange(messages)
    local message = { }
    message.subcode = messages.code
    message.content = messages.jsonContent
    message.code = messages.type
    return message
end

function VideotapeManager:getJsonFileName(strurl, strchar, bafter)
    local ts = string.reverse(strurl)
    local param1, param2 = string.find(ts, strchar)

    -- 这里以"/"为例
    local m = string.len(strurl) - param2 + 1
    local result
    if (bafter == true) then
        result = string.sub(strurl, m + 1, string.len(strurl))
    else
        result = string.sub(strurl, 1, m - 1)
    end
    return result
end

--[[
-- @brief 恢复视频
--]]
function VideotapeManager:resume()
    self:startSchedule()
    self.isPaused = false
    self.isSpeed = false
end

--[[
-- @brief  暂停视频播放
-- @param  void
-- @return void
--]]
function VideotapeManager:pause()
    self:stopSchedule()
    self.isPaused = true
end

--[[
-- @brief  快进视频播放
-- @param  void 31003
-- @return void
--]]
function VideotapeManager:speed()
    -- if self.isPaused and self.allowTime > kSpeedTime then
    if self.isPaused then
        self.isSpeed = true
        local playbackInfo = kPlaybackInfo:getPlaybackData()
        local start = self.count + 1
        -- 第一步不能快进
        -- if start <= 2 then
        --     return
        -- end
        for i = start, #playbackInfo do
            if playbackInfo[i].subcode == nil then
                return
            end
            -- 发送命令
            if self.count < #playbackInfo and self.count >= 0 then
                local info = { }
                table.insert(info, playbackInfo[i])
                SocketManager:getInstance():onRecordReceivePacket(info)
                self.count = self.count + 1
            else
                self.count = -1
            end
            -- 遇到打牌子命令直接返回
            if playbackInfo[i].subcode == kSubCodeType.playCard then
                break
            end

            if (i >= #playbackInfo or self.count == -1) then
                -- 打牌结束
                self.isPlayingEnd = true
                self:stopSchedule()
                self:showEndReturnUI();
            end
        end
        -- self.isSpeed = false
    end
end

-- 打牌结束返回Ui
function VideotapeManager:showEndReturnUI(isDely)
    if self.isShowTipView then
        return
    end
    self.isShowTipView = true
    local function callFun()
        if not self.isPlaying then
            return
        end
        local data = { }
        data.type = 2;
        data.title = "提示";
        data.yesTitle = "确定";
        data.cancelTitle = "取消";
        data.content = "播放结束，是否退出";
        self.handle = nil
        data.yesCallback = function()
            -- 避免界面不存在还去退出游戏
            if self.isPlaying then
                kPlaybackInfo:setVideoReturn(true)
                MjMediator:getInstance():exitGame();
            end

        end
        -- 防止点击快进又出现当前提示框UI
        if (UIManager.getInstance():getWnd(CommonDialog) == nil) then
            UIManager.getInstance():pushWnd(CommonDialog, data);
        end
        self:stopSchedule()
    end
    --
    if (isDely ~= nil and isDely == false) then
        callFun();
    else
        scheduler.performWithDelayGlobal( function()
            callFun();
        end ,
        3.5)
    end
end

--[[
-- @brief  是否正在播放
-- @param  void
-- @return true/false
--]]
function VideotapeManager:isPlayingVideo()
    return self.isPlaying or false
end

--[[
-- @brief  是否是快进
-- @param  void
-- @return true/false
--]]
function VideotapeManager:isSpeedVideo()
    return self.isSpeed or false
end

--[[
-- @brief  是否允许快进
-- @param  void
-- @return true/false
--]]
function VideotapeManager:isAllowSpeedVideo()
    return self.allowFlag or false
end



--[[
-- @brief  创建视频对象
-- @param  void
-- @return Video
--]]
function VideotapeManager:createVideo()

end

--[[
-- @brief  视频是否播放结束
-- @param  void
-- @return Video
--]]
function VideotapeManager:isPlayingEndState()
    return self.isPlayingEnd or false
end


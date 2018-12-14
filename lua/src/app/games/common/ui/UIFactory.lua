-------------------------------------------------------------
--  @file   UIFactory.lua
--  @brief  UI工厂
--============================================================
local kCurrentModule = ...

local UIFactory = class("UIFactory")


--[
-- 创建实体
-- @return 实体
--]
function UIFactory.createEntity(gameType, path, className, ...)
    local tmpPath = "package_src.games." .. gameType .. ".games." .. path .. gameType .. className
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.".. path .. className
        if not UIFactory.isFileExist(tmpPath) then
            print("[ ERROR ] UIFactory.createEntity")
            return nil
        end
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createEntity 创建UI失败")
        return nil
    end
    local entity = cls.new(...)
    return entity
end

--[
-- 创建麻将
-- @return 文件句柄
--]
function UIFactory.createMj(gameType,data)
    -- app.games.suzhoumj.games.common.mahjong.suzhouMj.lua
    local tmpPath = "package_src.games." .. gameType .. ".games.common.mahjong." .. gameType .. "Mj"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.mahjong.Mj"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("MjGroupFactory.createMj 创建UI失败")
        return nil
    end
    local entity = cls.new(data)
    return entity
end

--[
-- 创建牌局 UI界面
-- @param  data 现场
-- @return 实体
--]
function UIFactory.createPlayerPanelBase(gameType, data)
    local tmpPath = "package_src.games."..gameType..".games.ui.palyerlayer." .. gameType .. "PlayerPanelBase"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.palyerlayer.PlayerPanelBase"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("[ ERROR ]UIFactory.createPlayerPanelBase 创建UI失败")
        return nil
    end

    local entity = cls.new(data)
    return entity
end

--[
-- 创建牌局 UI界面
-- @param  data 现场
-- @return 实体
--]
function UIFactory.createGameUIView(gameType, data)
    local tmpPath = "package_src.games."..gameType..".games.ui.bglayer." .. gameType .. "GameUIView"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.bglayer.GameUIView"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("[ ERROR ]UIFactory.createGameUIView 创建UI失败")
        return nil
    end

    local entity = cls.new(data)
    return entity
end

--[
-- 创建牌局总结算界面
-- @param  data 现场
-- @return 实体
--]
function UIFactory.createTotalOverView(gameType, data)
    local tmpPath = "package_src.games."..gameType..".games.ui.gameover." .. gameType .. "FriendTotalOverView"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.gameover.FriendTotalOverView"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("[ ERROR ]UIFactory.createTotalOverView 创建UI失败")
        return nil
    end

    local entity = cls.new(data)
    return entity
end

--[
-- 创建牌局结算界面
-- @param  data 现场
-- @return 实体
--]
function UIFactory.createFriendOverView(gameType, data)
    local tmpPath = "package_src.games."..gameType..".games.ui.gameover." .. gameType .. "FriendOverView"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.gameover.FriendOverView"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("[ ERROR ]UIFactory.createFriendOverView 创建UI失败")
        return nil
    end

    local entity = cls.new(data)
    return entity
end

--[
-- 创建牌局等待界面
-- @param  data 现场
-- @return 实体
--]
function UIFactory.createRoomScene(gameType, data)
    -- 先试图载入游戏自己的BgLayer
    local tmpPath = "package_src.games." .. gameType .. ".hall.friendRoom." .. gameType .. "FriendRoomScene"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.hall.friendRoom.FriendRoomScene"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("[ ERROR ]UIFactory.createRoomScene 创建UI失败")
        return nil
    end

    local entity = cls.new(data)
    return entity
end

--[
-- 创建背景层
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createBgLayer(gameType, context)
    -- 先试图载入游戏自己的BgLayer
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.bglayer." .. gameType .. "BgLayer"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.bglayer.BgLayer"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createBgLayer 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

--[
-- 创建背景层
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createGameLayer(gameType, context)
    -- 先试图载入游戏自己的GameLayer
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.gamelayer." .. gameType .. "GameLayer"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.gamelayer.GameLayer"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createGameLayer 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

--[
-- 创建手牌层
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createHandCardsPanel(gameType, context)
    -- 先试图载入游戏自己的HandCardsPanel
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.playlayer." .. gameType .. "HandCardsPanel"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.playlayer.HandCardsPanel"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createHandCardsPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end
function UIFactory.createPlayerOtherPanel(gameType, context)
    -- 先试图载入游戏自己的PlayerOtherPanel
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.playlayer." .. gameType .. "PlayerOtherPanel"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.playlayer.PlayerOtherPanel"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createPlayerOtherPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end
function UIFactory.createPlayerLeftPanel(gameType, context)
    -- 先试图载入游戏自己的PlayerLeftPanel
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.playlayer." .. gameType .. "PlayerLeftPanel"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.playlayer.PlayerLeftPanel"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createPlayerLeftPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end
function UIFactory.createPlayerRightPanel(gameType, context)
    -- 先试图载入游戏自己的PlayerRightPanel
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.playlayer." .. gameType .. "PlayerRightPanel"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.playlayer.PlayerRightPanel"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createPlayerRightPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end
--[
-- 创建玩家头像
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createPlayerHead(gameType,context)
    -- 先试图载入游戏自己的HandCardsPanel
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.bglayer." .. gameType .. "PlayerHead"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.bglayer.PlayerHead"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createHandCardsPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

--[
-- 创建GameUIView
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createGameUIView(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.bglayer." .. gameType .. "GameUIView"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.bglayer.GameUIView"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createGameUIView 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end


--[
-- 创建GamePlayLayer
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createGamePlayLayer(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.playlayer." .. gameType .. "GamePlayLayer"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.playlayer.GamePlayLayer"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createGamePlayLayer 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

--[
-- 创建GameOperateBtnLayer
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createOperateBtnLayer(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.operatelayer." .. gameType .. "OperateBtnLayer"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.operatelayer.OperateBtnLayer"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createOperateBtnLayer 创建UI失败")
        return nil
    end
    print("UIFactory.createOperateBtnLayer 创建UIsuccess")
    local entity = cls.new(context)
    return entity
end

--[
-- 创建PlayerFlower
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createPlayerFlower(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.gamelayer." .. gameType .. "PlayerFlower"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.gamelayer.PlayerFlower"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createPlayerFlower 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

--[
-- 创建MJTurnLaizigou
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createMJTurnLaizigou(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.common.custom." .. gameType .. "MJTurnLaizigou"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.custom.MJTurnLaizigou"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.createMJTurnLaizigou 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end


--[
-- 创建OperatorOverTimeTip
-- @param  context 现场
-- @return 实体
--]
function UIFactory.createOpOverTimeLayer(gameType, context)
    -- 先试图载入游戏自己的OperatorOverTimeTip
    local tmpPath = "package_src.games." .. gameType .. ".games.ui.bglayer." .. gameType .. "OperatorOverTimeTip"
    if not UIFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.ui.bglayer.OperatorOverTimeTip"
    end
    
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("UIFactory.OperatorOverTimeTip 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

function UIFactory.isFileExist(requirePath)
    -- requirePath暂定为app起始, filePath需要为src起始的路径
    
    local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    Log.i("UIFactory.isFileExist: filePath", filePath)
    -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
    local re, err = io.exists(filePath)
    if not re then
        local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".luac"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
        Log.i("UIFactory.isFileExist: filePath", filePath)
        -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
        re, err = io.exists(filePath)
    end
    if re then
        return true
    else
        Log.i("file load failed", err)
        return false
    end
end

return UIFactory

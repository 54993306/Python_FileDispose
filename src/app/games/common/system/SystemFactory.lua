-------------------------------------------------------------
--  @file   UIFactory.lua
--  @brief  UI工厂
--============================================================
local kCurrentModule = ...

local SystemFactory = class("SystemFactory")

--[
-- 获取游戏开始逻辑层
-- @param  context 现场
-- @return 实体
--]
function SystemFactory.getGameStartLogicPath(gameType)
    -- 先试图载入公共的路径
    local tmpPath = "package_src.games." .. gameType .. ".games.system.gameplay." .. gameType .. "GameStartLogic"
    if not SystemFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.system.gameplay.GameStartLogic"
    end
    return tmpPath;
end

--[
-- 获取游戏结算逻辑层
-- @param  context 现场
-- @return 实体
--]
function SystemFactory.getGameOverLogicPath(gameType)
    -- 先试图载入公共的路径
    local tmpPath = "package_src.games." .. gameType .. ".games.system.gameplay." .. gameType .. "GameOverLogic"
    if not SystemFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.system.gameplay.GameOverLogic"
    end

    return tmpPath;
end

--[
-- 获取游戏打牌逻辑层
-- @param  context 现场
-- @return 实体
--]
function SystemFactory.getPlayCardLogicPath(gameType)
    -- 先试图载入公共的路径
    local tmpPath = "package_src.games." .. gameType .. ".games.system.gameplay." .. gameType .. "PlayCardLogic"
    if not SystemFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.system.gameplay.PlayCardLogic"
    end

    return tmpPath;
end

--[
-- 获取游戏结算逻辑层
-- @param  context 现场
-- @return 实体
--]
function SystemFactory.getGameDispenseLogicPath(gameType)
    -- 先试图载入公共的路径
    local tmpPath = "package_src.games." .. gameType .. ".games.system.gameplay." .. gameType .. "GameDispenseLogic"
    if not SystemFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.system.gameplay.GameDispenseLogic"
    end 

    return tmpPath;
end

--[
-- 创建OperateSystem
-- @param  context 现场
-- @return 实体
--]
function SystemFactory.getOperateSystemPath(gameType, context)
    -- 先试图载入游戏自己的GameUIView
    local tmpPath = "package_src.games." .. gameType .. ".games.system.operate." .. gameType .. "OperateSystem"
    if not SystemFactory.isFileExist(tmpPath) then
        print("<jinds>: cannot getOperateSystemPath ")
        tmpPath = "app.games.common.system.operate.OperateSystem"
    end

    return tmpPath;
end


function SystemFactory.isFileExist(requirePath)
    -- requirePath暂定为app起始, filePath需要为src起始的路径
    local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    Log.i("SystemFactory.isFileExist: filePath", filePath)
    -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
    local re, err = io.exists(filePath)
    if re then
        return true
    else
        Log.i("file load failed", err2)
        return false
    end
end

return SystemFactory

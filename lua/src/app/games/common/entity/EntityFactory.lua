-------------------------------------------------------------
--  @file   EntityFactory.lua
--  @brief  实体工厂
--  @author Zhu Can Qin
--  @DateTime:2016-08-29 16:08:26
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local kCurrentModule = ...

--[
-- @class EntityFactory
-- @brief 实体工厂
--
--]
local EntityFactory = class("EntityFactory")
local classes = {
    [enEntityType.PLAYER]        = ".object.Player",
    [enEntityType.HAND_MJ]       = ".object.HandMj",
}

--[
-- @brief  生成实体
-- @param  entityType 实体类型
-- @param  context 现场
-- @return 实体
--]
function EntityFactory.createEntity(entityType, context)
    assert(classes[entityType],
        "EntityFactory.createEntity - 无效的类型："..tostring(entityType))

    local cls = import(classes[entityType], kCurrentModule)
    if nil == cls then
    	printError("EntityFactory.createEntity 创建实体失败,类型=%s", tostring(entityType))
    	return nil
    end
    local entity = cls.new(context)

    return entity
end

--[
-- 创建玩家
-- @param  context 现场
-- @return 实体
--]
function EntityFactory.createPlayerEntity(gameType,context)
    local tmpPath = "package_src.games." .. gameType .. ".games.entity.object." .. gameType .. "Player"
    if not EntityFactory.isFileExist(tmpPath) then
        tmpPath = "app.games.common.entity.object.Player"
    end
    local cls = import(tmpPath, kCurrentModule)
    if nil == cls then
        print("EntityFactory.createHandCardsPanel 创建UI失败")
        return nil
    end

    local entity = cls.new(context)
    return entity
end

function EntityFactory.isFileExist(requirePath)
    -- requirePath暂定为app起始, filePath需要为src起始的路径
    local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    Log.i("EntityFactory.isFileExist: filePath", filePath)
    -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
    local re, err = io.exists(filePath)
    if re then
        return true
    else
        Log.i("file load failed", err)
        return false
    end
end

return EntityFactory


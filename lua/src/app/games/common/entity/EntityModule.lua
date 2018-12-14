-------------------------------------------------------------
--  @file   EntityModule.lua
--  @brief  实体模块
--  @author Zhu Can Qin
--  @DateTime:2016-08-30 10:06:26
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local EntityFactory = import(".EntityFactory")

--[
-- @class EntityModule
-- @brief 实体模块
--
--]
local EntityModule = class("EntityModule")

--[
-- @brief  构造函数
-- @param  void
-- @return void
--]
function EntityModule:ctor()
   
end

--[
-- @brief  释放函数
-- @param  void
-- @return void
--]
function EntityModule:release()
   
end

--[[
-- @brief  激活
-- @param  void
-- @return void
--]]
function EntityModule:activate()

end

--[[
-- @brief  反激活
-- @param  void
-- @return void
--]]
function EntityModule:deactivate()
   
end

--[[
-- @brief  注册事件
-- @param  void
-- @return void
--]]
function EntityModule:registerEvents()
   
end

--[[
-- @brief  反注册事件
-- @param  void
-- @return void
--]]
function EntityModule:unregisterEvents()
   
end

--[
-- @brief  生成实体对象
-- @param  entityType 实体类型，见enEntityType定义
-- @param  context 构造现场
-- @return 成功则返回实体对象，否则返回nil
--]
function EntityModule:createEntity(entityType, context)
    local entity
    if not entity then
        entity = EntityFactory.createEntity(entityType, context)
        if nil == entity then
            printError("EntityModule:createEntity - 创建实体失败，类型=%s", tostring(entityType))
            return nil
        end
    end
    return entity
end

--[
-- @brief  释放实体对象
-- @param  entity
-- @return true / false
--]
function EntityModule:releaseEntity(entity)
    entity:release()
    return true
end

--[[
-- @brief  缓存创建实体
-- @param  entityType   实体类型
-- @param  context      现场
-- @return void
--]]
function EntityModule:cacheEntity(entityType, context)
    local contextString = json.encode(context or {})

    local entity = self:createEntity(entityType, context, true)
    if not entity then
        printError("EntityModule:cacheEntity - 创建实体失败，类型：%s，现场：%s",
            entityType, contextString)
        return
    end

    local key = string.format("%s-%s", entityType, contextString)
    self.caches[key] = self.caches[key] or {}
    table.insert(self.caches[key], entity)
end

--[[
-- @brief  清空缓存
-- @param  void
-- @return void
--]]
function EntityModule:clearCache()
    table.walk(self.caches, function(group)
        table.walk(group, function(entity)
            self:releaseEntity(entity)
        end)
    end)
    self.caches = {}
end

--[
-- @brief  根据类型取得所有实体
-- @param  entityType 实体类型
-- @return table
--]
function EntityModule:getEntitysByType(entityType)
    local entitys = {}
    table.walk(self.eigenTable, function(entity)
        if entity:getType() == entityType then
            table.insert(entitys, entity)
        end
    end)
    return entitys
end

return EntityModule


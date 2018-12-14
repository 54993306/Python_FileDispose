-------------------------------------------------------------
--  @file   MjGroupFactory.lua
--  @brief  麻将列表显示
--  @author Zhu Can Qin
--  @DateTime:2016-08-06 16:14:02
--  Version: 1.0.0
--  Company  Steve LLC.
--  Copyright  Copyright (c) 2016
--============================================================
local Define 			= require "app.games.common.Define"
-- local LayoutChiPeng 	= require "app.games.common.ui.playlayer.exhibition.LayoutChiPeng"
-- local LayoutMingGang    = require "app.games.common.ui.playlayer.exhibition.LayoutMingGang"
-- local LayoutAnGang 	    = require "app.games.common.ui.playlayer.exhibition.LayoutAnGang"

local CURRENT_MODULE_NAME = ...
local MjGroupFactory = class("MjGroupFactory")
-- 玩家的操作
local classes = {
    [enOperate.OPERATE_CHI]          = ".LayoutChiPeng",
    [enOperate.OPERATE_PENG]         = ".LayoutChiPeng",
    [enOperate.OPERATE_MING_GANG]    = ".LayoutMingGang",
    [enOperate.OPERATE_JIA_GANG]     = ".LayoutMingGang",
    [enOperate.OPERATE_AN_GANG]      = ".LayoutAnGang",
    [enOperate.OPERATE_YANGMA]      = ".LayoutMingGang",
}

--[
-- @brief  生成单元对象
-- @param  content{
--	mjs 	=  {},  麻将的列表
--  actionType		动作类型 吃 碰 明杠 暗杠 加杠, 里面的 enOperate
--  operator		操作者的座次	
--  beOperator    	被操作的座位，暗杠和加杠不需要传进来	
-- }
-- @return unit
--]
function MjGroupFactory:createMjGroup(content)
    if nil == classes[content.actionType] then
        printError("MjGroupFactory:createMjGroup - 无效的条件类型：%s",
            tostring(content.actionType))
        return nil
    end

    local cls
    if MjGroupFactory.getMjGroupPath(_gameType, content.actionType) then
        cls = require(MjGroupFactory.getMjGroupPath(_gameType, content.actionType)) 
    else
        cls = import(classes[content.actionType], CURRENT_MODULE_NAME)
    end
    return cls.new(content)
end

--[
-- 创建OperateSystem
-- @param  context 现场
-- @return 实体
--]
function MjGroupFactory.getMjGroupPath(gameType, actionType)
    local fileName = string.gsub(classes[actionType], "%.", gameType)
    local requirePath = "package_src.games." .. gameType .. ".games.ui.playlayer.exhibition." .. fileName
    if not MjGroupFactory.isFileExist(requirePath) then
        return nil
    end

    return requirePath
end

function MjGroupFactory.isFileExist(requirePath)
    -- requirePath暂定为app起始, filePath需要为src起始的路径
    
    local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".lua"
    filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    Log.i("MjGroupFactory.isFileExist: filePath", filePath)
    -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
    local re, err = io.exists(filePath)
    if not re then
        local filePath = "src/" .. string.gsub(requirePath, "%.", "/") .. ".luac"
        filePath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
        Log.i("MjGroupFactory.isFileExist: filePath", filePath)
        -- local re, err = loadfile(filePath) -- 在安卓平台上无法加载成功, 是因为加密?
        re, err = io.exists(filePath)
    end
    if re then
        return true
    else
        Log.i("file load failed", err2)
        return false
    end
end
return MjGroupFactory


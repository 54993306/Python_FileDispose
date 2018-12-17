-----------------------------------------------------------
--  @file   ServerNoticeCfg.lua
--  @brief  维护公告配置
--  @author zhousiyu
--  @DateTime:2018-03-30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
-- ============================================================

local ServerNoticeCfg = {}
local defaultCfg = {}
defaultCfg.title = "维护公告"
defaultCfg.textTab = {
    "为了给大家带来更好的游戏体验，服务器将于3月14日(周三)早上6:30-9:00进行停服维护，如未能按时完成，则开服时间将会顺延。具体更新详情请留意稍后更新公告，或维护结束后至游戏登录界面查看。维护期间将暂时无法进入服务器进行游戏，给各位带来的不便，敬请谅解，非常感谢大家一如既往的支持!(鞠躬)",
}
defaultCfg.fontCfg = {opacity = 255, contentSize = 34, lineHeight = 60}

local getTextTabFromServer = function(serverTips)
    local textTab = {}
    if type(serverTips) == "table" then
        textTab = serverTips
    elseif type(serverTips) == "string" then
        table.insert(textTab, serverTips)
    end
    return textTab
end

ServerNoticeCfg.getData = function(data)
    local resultData = clone(data)
    for k, v in pairs(defaultCfg) do
        if not resultData[k] then
            resultData[k] = v
        end
    end
    if data.serverTips then
        resultData.textTab = getTextTabFromServer(data.serverTips)
    end
    return resultData
end

return ServerNoticeCfg
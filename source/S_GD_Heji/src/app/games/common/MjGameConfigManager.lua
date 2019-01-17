local MjGameConfigManager = class("MjGameConfigManager")

MjGameConfigManager.s_instance = nil

function MjGameConfigManager.getInstance()
    if MjGameConfigManager.s_instance == nil then
        MjGameConfigManager.s_instance = MjGameConfigManager.new()
    end
    return MjGameConfigManager.s_instance
end

function MjGameConfigManager:ctor()
    self.m_MjGameConfigs = {}
    local mt = {
        __index = function(t, k)
            return _G
        end
    }
    setmetatable(self.m_MjGameConfigs, mt)

    local submt = {
        __index = function(t, k)
            return _G[k]
        end
    }

    for gameID, _gameType in pairs(GC_GameTypes) do
        local fileName = "src/package_src/games/".._gameType.."/MjConfig"
        --跑的快特殊处理
        if _gameType == "pdkpk" then
            fileName = "src/package_src/games/paodekuai/".._gameType.."/MjConfig"
        elseif _gameType == "gdpk" then
            fileName = "src/package_src/games/guandan/".._gameType.."/MjConfig"
        end
        -- Log.i("--wangzhi--MjGameConfigManager--fileName--",fileName)
        local isFileExist = cc.FileUtils:getInstance():isFileExist(fileName..".luac") or cc.FileUtils:getInstance():isFileExist(fileName..".lua") 

        if isFileExist then
            local requirePath = "package_src.games.".._gameType..".MjConfig"
            --跑的快特殊处理
            if _gameType == "pdkpk" then
                requirePath = "package_src.games.paodekuai.".._gameType..".MjConfig"
            elseif _gameType == "gdpk" then
                requirePath = "package_src.games.guandan.".._gameType..".MjConfig"
            end
            package.loaded[requirePath] = nil
            local MjConfig = require(requirePath)
            assert(type(MjConfig) == "table")
            self.m_MjGameConfigs[gameID] = clone(MjConfig)
            setmetatable(self.m_MjGameConfigs[gameID], submt)
        end
    end
end

function MjGameConfigManager.get(gameID, propertyName)
    assert(gameID~=nil and propertyName ~= nil)
    return MjGameConfigManager.getInstance().m_MjGameConfigs[gameID][propertyName]
end

local ProxyMt = {
    __index = function(t, k)
        return MjGameConfigManager.getInstance().m_MjGameConfigs[k]
    end
}

local ManagerProxy = {}

setmetatable(ManagerProxy, ProxyMt)


return ManagerProxy 
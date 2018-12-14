--[[
    @desc: 数据保存类
    author:徐志军
    time:2018-03-25 10:25:26
    return
]]

GAME_STATE_ENCRYPTION_XXTEA="ds2018"
GAME_STATE_ENCRYPTION_OPERATION_SAVE="save"
GAME_STATE_ENCRYPTION_OPERATION_LOAD="load"

local DataStore = class( "DataStore")

local instance = nil;

function DataStore:getInstance()
    if instance == nil then
        instance = DataStore.new()
    end
    return instance
end

function DataStore:init(stateFilename)
    self._dataStore = {}
    self._gameState = require( cc.PACKAGE_NAME..".cc.utils.GameState") --初始化gamestate（这个类是quick 自己api里面封装的）
    self._gameState.init( function(param)
            local returnValue = nil
            if param.errorCode then
                printError( "errorCode", param.errorCode )
            else
                if param.name == GAME_STATE_ENCRYPTION_OPERATION_SAVE then
                    local str = json.encode( param.values )
                    str = crypto.encryptXXTEA( str, GAME_STATE_ENCRYPTION_XXTEA )  --使用 XXTEA 算法加密内容
                    returnValue = { data = str }
                elseif param.name == GAME_STATE_ENCRYPTION_OPERATION_LOAD then
                    local str = crypto.decryptXXTEA( param.values.data, GAME_STATE_ENCRYPTION_XXTEA ) --使用 XXTEA 算法解密内容
                    returnValue = json.decode( str )
                end
            end
            return returnValue
        end, stateFilename,GAME_STATE_ENCRYPTION_XXTEA )

    if io.exists( self._gameState.getGameStatePath() ) then
        self._dataStore = self._gameState.load()
        -- print( "savePath:"..self._gameState.getGameStatePath() )
    end
end
--添加数据
function DataStore:setData( __key, __value)
    self._dataStore[ __key ] = __value
    self._gameState.save(  self._dataStore )
end

--获取单独数据数据
function DataStore:getData( __key )
    return self._dataStore[ __key ]
end
--获取所有数据
function DataStore:getAllData()
    return self._dataStore
end

return DataStore
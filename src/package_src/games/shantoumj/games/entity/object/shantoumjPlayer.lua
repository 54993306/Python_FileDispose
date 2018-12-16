local Player = require("app.games.common.entity.object.Player")
local shantoumjPlayer = class("shantoumjPlayer", Player)


--[
-- @brief  初始化函数
-- @param  context 现场
-- @return 本身
--]
function shantoumjPlayer:initialize(context)
	self.super.initialize(self, context)
	self:setProp(enCreatureEntityProp.FLOWER, 	context.buyMaCards or {})
end



return shantoumjPlayer
local Player = require("app.games.common.entity.object.Player")
local huaijimjPlayer = class("huaijimjPlayer", Player)


--[
-- @brief  初始化函数
-- @param  context 现场
-- @return 本身
--]
function huaijimjPlayer:initialize(context)

	self.super.initialize(self, context)
	-- 报马的牌放在补花里
	self:setProp(enCreatureEntityProp.FLOWER, 	context.showBmCards or {})
end



return huaijimjPlayer
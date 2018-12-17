--
-- Author: Jinds
-- Date: 2017-06-26 17:36:10
--

local Player = require("app.games.common.entity.object.Player")
local huizhoumjPlayer = class("huizhoumjPlayer", Player)

function huizhoumjPlayer:initialize(context)

	self.super.initialize(self, context)
	--------------------------------------add-----------------------------------
	self:setProp(enCreatureEntityProp.XIA_PAO_NUM, 	context.isBDG or false)  --将报大哥的状态存到下跑的这个属性里面
	----------------------------------------------------------------------------

	return self

end


return huizhoumjPlayer
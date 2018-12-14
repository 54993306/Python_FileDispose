--
-- Author: Jinds
-- Date: 2017-06-26 17:36:10
--

local Player = require("app.games.common.entity.object.Player")
local zhaoqingmjPlayer = class("zhaoqingmjPlayer", Player)

function zhaoqingmjPlayer:initialize(context)

	zhaoqingmjPlayer.super.initialize(self, context)

	self:setProp(enCreatureEntityProp.FLOWER, 	context.bhC or {})  --将报听的牌显示



end


return zhaoqingmjPlayer
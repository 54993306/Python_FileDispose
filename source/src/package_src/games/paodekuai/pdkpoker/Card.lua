-------------------------------------------------------------
--  @file   Card.lua
--  @brief  逻辑运算的最小单元
--  @author 徐志军
--  @DateTime:2018-06-27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

local Card = class("package_src.games.paodekuai.pdkpoker.Card")

function Card:ctor()

    self.shape = 0            --花色
    self.number = 0           --点数
    self.kind = 0             --牌的类型（如：主与非主）
    self.level = 0            --牌的权值（牌的大小） 
    self.originalVal = 0      --牌的元数值 
end

function Card:cardTag()

end

--函数功能：     设置牌值
--card          客户端牌型结构
--返回值：       void
function Card:setCard(card)
	self.shape = card.shape
	self.number = card.number
	self.kind = card.kind
	self.level = card.level
	self.originalVal = card.originalVal
end

-- -- --函数功能：     设置牌值
-- -- --oriNum        元值
-- -- --返回值：       void
-- function Card:setOriCard(oriNum)

-- end

return Card


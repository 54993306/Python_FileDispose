-------------------------------------------------------------
--  @file   Card.lua
--  @brief  牌型接口，用于牌型拓展
--  @author 徐志军
--  @DateTime:2018-06-27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

local ICardsType = class("package_src.games.guandan.gdpoker.ICardsType")

function ICardsType:ctor()

end

--@brief 根据level查找obCards的牌型 virtual 
--@param obCards 需要查找牌型的目标牌集
--@return 目标牌集的牌型
function ICardsType:CardsType(obCards)
--TODO 本接口需要实现
end

--@brief 根据level对两牌集的比较 virtual 
--@param selfCards 被比较的牌集
--@param obCards 参照的目标牌集
--@return 比较结果
--@sa 比较结果枚举变量 ENM_TYPE_COMPARE_RESULT
function ICardsType:Compare(selfCards, obCards)
--TODO 本接口需要实现
end

return ICardsType
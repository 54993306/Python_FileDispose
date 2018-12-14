-------------------------------------------------------------
--  @file   Cards.lua
--  @brief  逻辑运算的最小单元
--  @author 徐志军
--  @DateTime:2018-06-27
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2018
--============================================================

local Cards = class("package_src.games.paodekuai.pdkpoker.Cards")

-- 函数功能：   构造函数
-- 返回值：     无
function Cards:ctor()
	-- 牌列表
    self.m_Cards = {}
    -- 牌长度
    self.m_nCurrentLength = 0
end


-- 函数功能：    析构函数
-- 返回值：     无
function CardBase:__destructor()
    self.m_Cards = nil
    self.m_nCurrentLength = nil
end


--函数功能：    设置牌组
--cards:       牌组
--返回值：      无
function Cards:setCards(cards)
    self.m_Cards = cards
end

--函数功能：    获取牌组
--返回值：      cards
function Cards:getCards()
    return self.m_Cards
end

--函数功能：    牌组当前长度
--返回值：      牌组长度
function Cards:currentLength()
    if self.m_nCurrentLength or self.m_nCurrentLength == 0 then
        --防止无序长度获取
        function table_leng(t)
            local leng=0
            for k, v in pairs(t) do
              leng=leng+1
            end
            return leng;
        end
        self.m_nCurrentLength = table_leng(self:getCards())
    end
    return self.m_nCurrentLength
end


return Cards
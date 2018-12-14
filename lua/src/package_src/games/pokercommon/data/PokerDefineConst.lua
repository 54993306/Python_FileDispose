--[[-----------------------------------------------------
-- 定义：扑克通用定义
-- 作者：李海波
-- 日期：2018.05.05
-- 修改记录：
-- 2018.05.05  实现定义
]]-------------------------------------------------------

-- 花色数量
NUM_OF_FLOWERS = 5

-- 点数 数量
NUM_OF_POINTS = 16

-- 一副牌的牌数
NUM_OF_A_PAIR_OF_CARDS = 54

-- 扑克花色
POKER_FLOWER_ENUM =
{
    FLOWER_NONE    = 0,   -- 大小王或者无花色
    FLOWER_DIAMOND = 1,   -- 方块
    FLOWER_CLUB    = 2,   -- 梅花
    FLOWER_HEARTS  = 3,   -- 红桃
    FLOWER_SPADE   = 4,   -- 黑桃
}

-- 扑克点数
POKER_POINT_ENUM =
{
    POINT_NONE        = 0,                 -- 牌背
    POINT_A           = POINT_NONE + 1,
    POINT_TWO         = POINT_NONE + 2,
    POINT_THREE       = POINT_NONE + 3,
    POINT_FOUR        = POINT_NONE + 4,
    POINT_FIVE        = POINT_NONE + 5,
    POINT_SIX         = POINT_NONE + 6,
    POINT_SEVEN       = POINT_NONE + 7,
    POINT_EIGHT       = POINT_NONE + 8,
    POINT_NINE        = POINT_NONE + 9,
    POINT_TEN         = POINT_NONE + 10,
    POINT_J           = POINT_NONE + 11,
    POINT_Q           = POINT_NONE + 12,
    POINT_K           = POINT_NONE + 13,
    POINT_BLACK_JOKER = POINT_NONE + 14,   -- 小王
    POINT_RED_JOKER   = POINT_NONE + 15,   -- 大王
}

LUA_BASE_TYPE_NUMBER = "number"
LUA_BASE_TYPE_STRING = "string"
LUA_BASE_TYPE_TABLE  = "table"





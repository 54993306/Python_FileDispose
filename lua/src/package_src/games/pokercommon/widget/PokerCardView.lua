--[[---------------------------------------- 
-- 作者: 方明扬
-- 日期: 2018-05-05 
-- 摘要: 单个扑克实现
]]-------------------------------------------


local PokerCardView = class("PokerCardView", function()
    return ccui.ImageView:create();
end);
local PokerUtils = require("package_src.games.pokercommon.commontool.PokerUtils")

--黑红梅方王的类型
local JOKER_TYPE = 5
local MEI_TYPE   = 3
local HONG_TYPE  = 2
local HEI_TYPE   = 1
local FANG_TYPE  = 0

--牌值的缩放比例
local PAI_VALUE_SCALE = 0.45

--牌值
local SMALL_JOKER_VALUE = 29
local BIG_JOKER_VALUE   = 30

--大小王的资源
local BIG_JOKER_IMG_PATH     = "card/jokerred.png"
local BIG_JOKER_VALUE_PATH   = "card/jokerwordred.png"
local SMALL_JOKER_IMG_PATH   = "card/jokerblack.png"
local SMALL_JOKER_VALUE_PATH = "card/jokerwordblack.png"

--函数功能：构造函数
--返回值：  无
--type：    扑克类型
--value：   扑克值
--card：    扑克信息
function PokerCardView:ctor(type,value,card)
    --Log.i("=============PokerCardView======ctor=============")
    self.m_card = card;
    --type:花色，value：牌值
    self.m_type, self.m_value = type, value;

    --牌的上个状态,例如选中
    self.m_lastStatus = nil;

    --牌的当前状态
    self.m_status = 1;

    --牌花的缩放
    self.flowerImgScale = 1

    self:createPokerCard()
end

--函数功能：析构函数
--返回值：  无
function PokerCardView:dtor()
end


--函数功能：创建扑克
--返回值：  无
function PokerCardView:createPokerCard()
    local cardType = self.m_type
    local cardValue = self.m_value

    --牌背
    if cardType == 0 and cardValue == 0 then
        self:loadTexture("card/cardbg.png", ccui.TextureResType.plistType)
        return 
    end

    self:loadTexture("card/frontbg.png", ccui.TextureResType.plistType)

    --大小王
    if cardType == JOKER_TYPE then
        local img_path = (cardValue == SMALL_JOKER_VALUE) and SMALL_JOKER_IMG_PATH or BIG_JOKER_IMG_PATH
        local value_img_path = (cardValue == SMALL_JOKER_VALUE) and SMALL_JOKER_VALUE_PATH or BIG_JOKER_VALUE_PATH
        self:createJoker(img_path, value_img_path)

    elseif cardType == HEI_TYPE or cardType == MEI_TYPE then
        self:createNomall(cardValue, cardType, "black.png")

    elseif cardType == FANG_TYPE or cardType == HONG_TYPE then
        self:createNomall(cardValue, cardType, "red.png")
    end

    self.lordTag = ccui.ImageView:create("card/lordtag.png", ccui.TextureResType.plistType)
    :addTo(self)
    :setPosition(cc.p(95, 130))
    self.lordTag:setVisible(false)
end

--函数功能： 创建普通牌
--返回值：   无
--cardValue：牌值
--cardType： 牌类型
--card_png： 资源路径
function PokerCardView:createNomall(cardValue,cardType,card_png)
    local size = self:getContentSize()
    self.imgVal = ccui.ImageView:create("card/" .. cardValue .. card_png, ccui.TextureResType.plistType)

    self.imgVal:setAnchorPoint(cc.p(0.5,1))
    self:addChild(self.imgVal)
    self.imgVal:setPosition(cc.p(32, size.height - 10))

    --创建大牌值img
    self.imgType = ccui.ImageView:create("card/type" .. cardType .. ".png", ccui.TextureResType.plistType)
    self:addChild(self.imgType)
    self.imgType:setPosition(cc.p(80, 60))

    --创建小牌值img
    self.smallTmgType = ccui.ImageView:create("card/type" .. cardType .. ".png", ccui.TextureResType.plistType)
    self:addChild(self.smallTmgType)
    self.smallTmgType:setPosition(cc.p(33, 100))
    self.smallTmgType:setScale(PAI_VALUE_SCALE)
end

--函数功能：  创建大小王
--返回值：    无
--img_path:   面花资源
--value_path：数值资源
function PokerCardView:createJoker(img_path,value_path)
    local size = self:getContentSize()
    self.jokerimgType = ccui.ImageView:create(img_path, ccui.TextureResType.plistType)
    self:addChild(self.jokerimgType)
    self.jokerimgType:setScale(self.flowerImgScale)
    self.jokerimgType:setAnchorPoint(cc.p(1.0,0.0))
    self.jokerimgType:setPosition(cc.p(size.width-10,10))
    self.jokerimgType:setVisible(false)

    local imgVal = ccui.ImageView:create(value_path, ccui.TextureResType.plistType)
    imgVal:setAnchorPoint(cc.p(0.5,1))
    self:addChild(imgVal)
    imgVal:setPosition(cc.p(22, size.height - 10))    
end

--函数功能：将牌转换为底牌的显示样式
--返回值：  无
function PokerCardView:convertToBottomType()

    local size = self:getContentSize()
    if self.imgVal then
        self.imgVal:setScale(self.imgVal:getScale() * 1.6)
        self.imgVal:setPosition(cc.p(40, size.height - 10))
    end
    if self.smallTmgType then
        self.smallTmgType:setVisible(false)
    end

    if self.imgType then
        self.imgType:setPosition(cc.p(82, 48))
        self.imgType:setScale(0.8)
    end

    if self.jokerimgType then
        self.jokerimgType:setVisible(true)
    end
end

--函数功能：添加地主图标
--返回值：  无
function PokerCardView:addLordTag()
    if self.lordTag then
        self.lordTag:setVisible(true)
    end
end

--函数功能：隐藏地主图标
--返回值：  无
function PokerCardView:hideLordTag()
    if self.lordTag then
        self.lordTag:setVisible(false)
    end
end

--函数功能：添加破裂图标
--返回值：  无
function PokerCardView:addBrokenTag()
    if not tolua.isnull(self.brokenTag) then
        self.brokenTag:removeself()
        self.brokenTag = nil
    end

    self.brokenTag = ccui.ImageView:create("card/broken.png", ccui.TextureResType.plistType)
    :addTo(self)
    :setLocalZOrder(10)
    :setPosition(cc.p(70, 107))
end

--函数功能：隐藏破裂图标
--返回值：  无
function PokerCardView:hideBrokenTag()
    if not tolua.isnull(self.brokenTag) then
        self.brokenTag:setVisible(false)
    end
end

--函数功能：添加废弃牌图标
--返回值：  无
function PokerCardView:addDespatchTag()
    if self.despatchTag then
        return 
    end
    self.despatchTag = ccui.ImageView:create("card/despatchedtag.png", ccui.TextureResType.plistType)
    :addTo(self)
    :setPosition(cc.p(110, 169))
end

--函数功能：花牌图案显示
--返回值：  无
function PokerCardView:showFlowerImg()
    if self.flowerImg then
        self.flowerImg:setVisible(true)
    end
    if self.jokerimgType then
        self.jokerimgType:setVisible(true)
    end
    if self.imgType then
        self.imgType:setVisible(true)
    end
end

--函数功能：花牌图案隐藏
--返回值：  无
function PokerCardView:hideFlowerImg()
    if self.flowerImg then
        self.flowerImg:setVisible(false)
    end
    if self.jokerimgType then
        self.jokerimgType:setVisible(false)
    end
    if self.imgType then
        self.imgType:setVisible(false)
    end
end

--函数功能：牌置灰处理
--返回值：  无
--isGray：  是否变灰
function PokerCardView:setGray(isGray)
    local isGray = isGray and 1 or 0
    for i,v in ipairs(self:getChildren()) do
         -- PokerUtils:setGreyAll(v:getVirtualRenderer():getSprite(),isGray)
    end
end

--函数功能：将牌设置为牌背显示
--返回值：  无
function PokerCardView:showAsBackBg()
    self:loadTexture("card/cardbg.png", ccui.TextureResType.plistType)
    for k,v in pairs(self:getChildren()) do
        v:setVisible(false)
    end
end

--函数功能：将牌设置为让牌后的牌背显示
--返回值：  无
function PokerCardView:showAsRangBg()
    self:loadTexture("card/darkcardbg.png", ccui.TextureResType.plistType)
    for k,v in pairs(self:getChildren()) do
        v:setVisible(false)
    end
end

--函数功能：设置为牌面背景
--返回值：  无
function PokerCardView:showAsCard()
    self:loadTexture("card/frontbg.png", ccui.TextureResType.plistType)
    for k,v in pairs(self:getChildren()) do
        v:setVisible(true)
    end
    self.lordTag:setVisible(false)
end

--函数功能： 判断牌是否点击
--返回值：   是否点击
--x：        x坐标
--y:         y坐标
function PokerCardView:isClick(x, y)
    local rc = self:getCascadeBoundingBox();
    if rc and rc:containsPoint(x, y) then
        return true;
    end
end

-- function PokerCardView:setCard(card)
--     self.m_card = card;
--     self.m_type, self.m_value = self:cardConvert(card);
-- end

--函数功能：获取牌的信息
--返回值：  牌的信息
function PokerCardView:getCard()
    return self.m_card;
end

--函数功能：设置牌的状态
--返回值：  无
--status：  牌的状态
function PokerCardView:setStatus(status)
    self.m_lastStatus = self.m_status;
    self.m_status = status;
end

--函数功能：判断牌的状态是否改变
--返回值：  状态是否改变
function PokerCardView:isStatusChanged()
    return self.m_status ~= self.m_lastStatus;
end

--函数功能：获得牌的类型
--返回值：  牌的类型
function PokerCardView:getValue()
    return self.m_value;
end

--函数功能：获得牌的值
--返回值：  牌的值
function PokerCardView:getType()
    return self.m_type;
end

--函数功能：获取牌当前的状态
--返回值：  当前的状态
function PokerCardView:getStatus()
    return self.m_status;
end

--函数功能：获取牌上次的状态
--返回值：  上次的状态
function PokerCardView:getLastStatus()
    return self.m_lastStatus;
end

return PokerCardView
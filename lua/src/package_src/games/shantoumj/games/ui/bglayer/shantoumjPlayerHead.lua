local PlayerHead = require("app.games.common.ui.bglayer.PlayerHead")
local shantoumjPlayerHead = class("shantoumjPlayerHead", PlayerHead)

local kSiteNames = 
{
    {},
    {"Panel_head_my", "Panel_head_other"},
    {"Panel_head_my", "Panel_head_right", "Panel_head_left"},
    {"Panel_head_my", "Panel_head_right", "Panel_head_other", "Panel_head_left"}
}

function shantoumjPlayerHead:ctor(data)
	self.super.ctor(self, data)
end

function shantoumjPlayerHead:onInit()
    --自己的头像
    local wNames = kSiteNames[self.playerCount]
    for i = 1, #wNames do
        self.panel_heads[i] = self:getWidget(self.m_pWidget, wNames[i])
        self.panel_heads[i]:setVisible(true)
        self:updateHead(self.panel_heads[i], i)
    end
    -- self.panel_heads[1] = self:getWidget(self.m_pWidget, "Panel_head_my")
    -- self:updateHead(self.panel_heads[1], Define.site_self)
    -- --右家的头像
    -- self.panel_heads[2] = self:getWidget(self.m_pWidget,"Panel_head_right")
    -- self:updateHead(self.panel_heads[2], Define.site_right)
    -- --对家的头像
    -- self.panel_heads[3] = self:getWidget(self.m_pWidget,"Panel_head_other")
    -- self:updateHead(self.panel_heads[3], Define.site_other)

    -- --左家的头像
    -- self.panel_heads[4] = self:getWidget(self.m_pWidget,"Panel_head_left")
    -- self:updateHead(self.panel_heads[4], Define.site_left)

    self:initReadySprite()
    -- 更新庄家
    self:updateBan()

    self:updateDingQue()

    -- 更新买马信息
    self:updateMaima()

    if not VideotapeManager.getInstance():isPlayingVideo() then
        self:refreshHeadState()

        --开始检测离线状态
        self.m_pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() self:refreshHeadState() end))))
    end
end

--[[
 -- @brief 设置拉跑坐头像显示的结果
 -- @param type 类型，num 多少底，多少坐，多少拉，多少跑等, site 位置
 -- @return void
]]
function PlayerHead:setLaPaoZuoResualt(type, num, site)
    Log.i("PlayerHead:setLaPaoZuoResult===>>", type, num, site)
    if not type or (not num or num <= 0) then
        return
    end

    if type == enOperate.OPERATE_XIA_PAO then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "pao_panel", "text_pao", num, site)
    elseif type == enOperate.OPERATE_LAZHUANG then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "la_panel", "text_la", num)
        local zuoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_la")
        zuoIcon:loadTexture("games/common/game/common/icon_la.png")
    elseif type == enOperate.OPERATE_ZUO then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "la_panel", "text_la", num)
        local zuoIcon = ccui.Helper:seekWidgetByName(self.panel_heads[site], "img_la")
        zuoIcon:loadTexture("games/common/game/common/icon_zuo.png")
    elseif type == enOperate.OPERATE_XIADI then
        self:parseLaPaoZuoWidget(self.panel_heads[site], "di_panel", "text_di", num)
    end
end

function shantoumjPlayerHead:parseLaPaoZuoWidget(parent, wName, tName, num, site)
    local paoPanel = ccui.Helper:seekWidgetByName(parent, wName)
    if wName == "pao_panel" then
        paoPanel:setVisible(true)
        -- paoPanel:setPosition()
        local paoImg = ccui.Helper:seekWidgetByName(paoPanel, "img_pao")
        paoImg:loadTexture("package_res/games/shantoumj/common/maima_circle.png")
        
        local numBg = ccui.Helper:seekWidgetByName(paoPanel, "img_text_bg")
        numBg:setVisible(false)
    else
        local paoPanel = ccui.Helper:seekWidgetByName(parent, wName)
        paoPanel:setVisible(true)
        local paoText = ccui.Helper:seekWidgetByName(paoPanel, tName)
        paoText:setString("" .. num)
        paoText:setFontSize(16)
    end

    local pos
    if site == 1 or site == 4  then
        pos = cc.p(-35, 35)
    elseif site == 2  then
        pos = cc.p(35, 35)
    elseif site == 3  then
        if self.playerCount == 3 then
            pos = cc.p(-35, 35)
        else
            pos = cc.p(35, 35)
        end
    end
    paoPanel:setPosition(pos)
end

function shantoumjPlayerHead:updateMaima()
    for i = 1, self.playerCount do
        local head = self:getHead(i)
        local image_maima = self:getWidget(head, "pao_panel")
        local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(i)
        local maimaNum = playerObj:getProp(enCreatureEntityProp.XIA_PAO_NUM)
        if maimaNum then
            self:setLaPaoZuoResualt(enOperate.OPERATE_XIA_PAO, maimaNum, i)
        end
    end
end

--庄家
function shantoumjPlayerHead:updateBan()

    print("<sunbin>: in my shantou show head")
    for i = 1, self.playerCount do
        local head = self:getHead(i)
        local image_zhuang = self:getWidget(head, "Image_zhuang")
        local playerObj = MjMediator:getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM):gameStartGetPlayerBySite(i)
        local banSiteFlag = playerObj:getProp(enCreatureEntityProp.BANKER)

        local playSystem    = MjMediator.getInstance():getSystemManager():getSystem(enSystemDef.GAME_PLAY_SYSTEM)
        local continueZhuang        = playSystem:getGameStartDatas().conZhuang

        if banSiteFlag then
            image_zhuang:setVisible(true)
            
            print("<sunbin>:  continueZhuang is ", continueZhuang)

            local needLianzhuang = kFriendRoomInfo:isHavePlayByName("lzfanbei") or kFriendRoomInfo:isHavePlayByName("l4zfanbei") or kFriendRoomInfo:isHavePlayByName("l3zjm")
            if type(continueZhuang) == "number" and continueZhuang > 0 and needLianzhuang then
                local img_textBg = display.newSprite("games/common/game/common/icon_text_bg.png")
                image_zhuang:addChild(img_textBg)
                img_textBg:setPosition(cc.p(38, 43))
                local lab_zhuangNum = cc.ui.UILabel.new(
                {
                    UILabelType = 2,
                    text = tostring( continueZhuang ),
                    color = cc.c3b(253, 252, 172),
                    size = 13,            
                })
                :addTo(img_textBg)
                lab_zhuangNum:setPosition(cc.p(9, 9))
                lab_zhuangNum:setAnchorPoint( cc.p(0.5, 0.5) )

                img_textBg:setScale(2)
            end
        else
            image_zhuang:setVisible(false)
        end
    end
end

return shantoumjPlayerHead 
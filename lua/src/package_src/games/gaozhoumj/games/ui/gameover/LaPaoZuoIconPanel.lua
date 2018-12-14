--
-- Author: RuiHao Lin
-- Date: 2017-06-02 10:13:47
--

local LaPaoZuoIconPanel = class("LaPaoZuoIconPanel", function()
    local ret = display.newNode()
    return ret
end )

--function LaPaoZuoIconPanel:ctor()
--    self:init()
--end

--function LaPaoZuoIconPanel:init()
--    self:initData()
--    self:initUI()
--end

--function LaPaoZuoIconPanel:initData()
--    self.m_iconTexture = {}
--    self.m_imgIcon = {}
--    self.m_labNum = {}

--    self.m_iconTag =
--    {
--        ICON_1 = 1,
--        ICON_2 = 2,
--    }
--    self.m_iconType =
--    {
--        ICON_LA = 1,--  À­
--        ICON_PAO = 2,--  ÅÜ
--        ICON_ZUO = 3,--  ×ø
--    }
--    --self.m_iconTexture[self.m_iconType.ICON_LA] = "games/common/game/common/icon_la.png"
--    self.m_iconTexture[self.m_iconType.ICON_PAO] = "games/common/game/common/icon_pao.png"
--   -- self.m_iconTexture[self.m_iconType.ICON_ZUO] = "games/common/game/common/icon_zuo.png"
--end

--function LaPaoZuoIconPanel:initUI()
--    local panelModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_over_item_lapaozuo.csb")
--    self:addChild(panelModel)

--    self.m_imgIcon[self.m_iconTag.ICON_1] = ccui.Helper:seekWidgetByName(panelModel, "Image_Icon1")
--    self.m_labNum[self.m_iconTag.ICON_1] = ccui.Helper:seekWidgetByName(self.m_imgIcon[self.m_iconTag.ICON_1], "Label_Num")
--    self.m_imgIcon[self.m_iconTag.ICON_1]:setVisible(true)

--    self.m_imgIcon[self.m_iconTag.ICON_2] = ccui.Helper:seekWidgetByName(panelModel, "Image_Icon2")
--    self.m_labNum[self.m_iconTag.ICON_2] = ccui.Helper:seekWidgetByName(self.m_imgIcon[self.m_iconTag.ICON_2], "Label_Num")
--    self.m_imgIcon[self.m_iconTag.ICON_2]:setVisible(false)
--end

--function LaPaoZuoIconPanel:showIcon(iconTag, iconType, iconNum)
--    if iconNum < 0 then
--        return
--    end
--    self.m_imgIcon[iconTag]:loadTexture(self.m_iconTexture[iconType])
--    self.m_imgIcon[iconTag]:setVisible(true)
--    self.m_labNum[iconTag]:setString("" .. iconNum)
--end

return LaPaoZuoIconPanel


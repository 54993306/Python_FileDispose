--
-- Author: RuiHao Lin
-- Date: 2017-06-02 10:13:47
--

local LaPaoZuoIconPanel = class("LaPaoZuoIconPanel", function()
    local ret = display.newNode()
    return ret
end )

function LaPaoZuoIconPanel:ctor()
    self:init()
end

function LaPaoZuoIconPanel:init()
    self:initData()
    self:initUI()
end

function LaPaoZuoIconPanel:initData()
    --   图标纹理
    self.m_iconTexture = { }
    -- 图标对象
    self.m_imgIcon = { }
    -- 数量
    self.m_labNum = { }

    --  图标标签
    self.m_iconTag =
    {
        --   图标1
        ICON_1 = 1,
        --   图标2
        ICON_2 = 2,
    }

    --  图标类型
    self.m_iconType =
    {
        --  拉
        ICON_LA = 1,
        --  跑
        ICON_PAO = 2,
        --  坐
        ICON_ZUO = 3,
        --  底
        ICON_DI = 4,
    }
    self.m_iconTexture[self.m_iconType.ICON_LA] = "games/common/game/common/icon_la.png"
    self.m_iconTexture[self.m_iconType.ICON_PAO] = "games/common/game/common/icon_pao.png"
    self.m_iconTexture[self.m_iconType.ICON_ZUO] = "games/common/game/common/icon_zuo.png"
    self.m_iconTexture[self.m_iconType.ICON_DI] = "games/common/game/common/icon_di.png"
end

function LaPaoZuoIconPanel:initUI()
    local panelModel = ccs.GUIReader:getInstance():widgetFromBinaryFile("games/common/game/mj_over_item_lapaozuo.csb")
    self:addChild(panelModel)

    self.m_imgIcon[self.m_iconTag.ICON_1] = ccui.Helper:seekWidgetByName(panelModel, "Image_Icon1")
    self.m_labNum[self.m_iconTag.ICON_1] = ccui.Helper:seekWidgetByName(self.m_imgIcon[self.m_iconTag.ICON_1], "Label_Num")
    self.m_imgIcon[self.m_iconTag.ICON_1]:setVisible(false)

    self.m_imgIcon[self.m_iconTag.ICON_2] = ccui.Helper:seekWidgetByName(panelModel, "Image_Icon2")
    self.m_labNum[self.m_iconTag.ICON_2] = ccui.Helper:seekWidgetByName(self.m_imgIcon[self.m_iconTag.ICON_2], "Label_Num")
    self.m_imgIcon[self.m_iconTag.ICON_2]:setVisible(false)
end

function LaPaoZuoIconPanel:showIcon(iconTag, iconType, iconNum)
    if iconNum <= 0 then
        return
    end
    self.m_imgIcon[iconTag]:loadTexture(self.m_iconTexture[iconType])
    self.m_imgIcon[iconTag]:setVisible(true)
    self.m_labNum[iconTag]:setString("" .. iconNum)
end

return LaPaoZuoIconPanel


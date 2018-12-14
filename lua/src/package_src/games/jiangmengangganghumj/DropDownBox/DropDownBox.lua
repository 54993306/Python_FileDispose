--
-- Author: RuiHao Lin
-- @brief   RadioButtonGroup   创建【下拉框】
-- Date: 2017-05-15 09:59:09
--


local DropDownBox = class("DropDownBox", function()
    local ret = cc.Node:create()
    ret:setContentSize(cc.size(200, 60))
    return ret
end )

--[[
    --  data结构
    data =
    {
        --  选项1
        {
            --  文本
            text = "1马",
            --  是否为选中项，不写则作false处理
            isSelected = true
        },
        --  选项2
        {
            --  文本
            text = "2马",
        }
    }
    @callback   下拉框内按钮的额外事件回调
]]
function DropDownBox:ctor(data, callback)
    self.m_data = data
    self.m_callback = callback
    self:initData()
    self:initUI()
    self:updateBoxState()
end

--  初始化数据
function DropDownBox:initData()
    --  下拉框最大行数
    local lMaxRow = 5
    --  下拉框行数
    self.m_row = #self.m_data >= lMaxRow and lMaxRow or #self.m_data
    --  下拉框按钮列表    
    self.m_btnItem = {}
    --  当前选中项
    self.m_currItem = {}
    --  按钮尺寸
    self.m_btnBoxSize = cc.size(230, 38)
    --  通用纹理
    self.m_commonTexture =
    {
        BoxNormal = "package_res/games/jiangmengangganghumj/friendRoom/drop_down_box_bg.png",
        IconNormal = "package_res/games/jiangmengangganghumj/friendRoom/handle_down.png",
        IconShow = "package_res/games/jiangmengangganghumj/friendRoom/handle_up.png",
    }
    --  文本参数
    self.m_parLabel =
    {
        ColorNormal = cc.c3b(255, 255, 255),
        ColorSelected = cc.c3b(38, 204, 38),

        FontSize = 28,
        FontName = "hall/font/fangzhengcuyuan.TTF",
    }
end

--  设置下拉框最大行数
function DropDownBox:setMaxRow(maxRow)
   self.m_row = #self.m_data >= maxRow and maxRow or #self.m_data
   self.m_boxListView:setContentSize(cc.size(self.m_btnBoxSize.width, self.m_btnBoxSize.height * self.m_row))
end

--  初始化UI界面
function DropDownBox:initUI()
    local lLayoutSize = self:getContentSize()
    --  选中框
    self.m_btnBox = ccui.Button:create(self.m_commonTexture.BoxNormal, "")
    self:addChild(self.m_btnBox)
    self.m_btnBox:setAnchorPoint(cc.p(0, 0.5))
    self.m_btnBox:setPosition(cc.p(20, lLayoutSize.height * 0.5))
    self.m_btnBox:setScale9Enabled(true)
    self.m_btnBox:setContentSize(self.m_btnBoxSize)
    self.m_btnBox:addTouchEventListener(handler(self, self.onBoxBtnEvent))

    --  选中框文本

    self.m_labBox = display.newTTFLabel( {
        text = "",
        font = self.m_parLabel.FontName,
        size = self.m_parLabel.FontSize,
        color = self.m_parLabel.ColorSelected,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_btnBox:addChild(self.m_labBox)
    self.m_labBox:setAnchorPoint(cc.p(0, 0.5))
    self.m_labBox:setPosition(cc.p(self.m_btnBoxSize.width * 0.05, self.m_btnBoxSize.height * 0.5))

    --  把柄图标
    self.m_iconHandle = cc.Sprite:create(self.m_commonTexture.IconNormal)
    self.m_btnBox:addChild(self.m_iconHandle)
    self.m_iconHandle:setAnchorPoint(cc.p(1, 0.5))
    self.m_iconHandle:setPosition(cc.p(self.m_btnBoxSize.width, self.m_btnBoxSize.height * 0.5))

    --  下拉框
    self.m_boxListView = ccui.ListView:create()
    self.m_btnBox:addChild(self.m_boxListView)
    self.m_boxListView:setAnchorPoint(cc.p(0, 1))
    self.m_boxListView:setBackGroundImage(self.m_commonTexture.BoxNormal)
    self.m_boxListView:setBackGroundImageScale9Enabled(true)
    self.m_boxListView:setContentSize(cc.size(self.m_btnBoxSize.width, self.m_btnBoxSize.height * self.m_row))

    --  添加下拉框选项
    for i, v in pairs(self.m_data) do
        self:addListViewItem(i, v.text)
        if v.isSelected then
            self.m_currItem = self.m_btnItem[i]
        end
    end
    --xiong可以设置初始化传入的选项
end

--  设置下拉框可视性
function DropDownBox:setListViewVisible(isVisible)
    self.m_boxListView:setVisible(isVisible)
    if isVisible then
        self.m_iconHandle:setTexture(self.m_commonTexture.IconShow)
    else
        self.m_iconHandle:setTexture(self.m_commonTexture.IconNormal)
    end
end

--  选中框按钮响应事件
function DropDownBox:onBoxBtnEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        local isVisible = self.m_boxListView:isVisible()
        self:setListViewVisible(not isVisible)
    end
end

--  更新下拉框状态
function DropDownBox:updateBoxState()
    self:setListViewVisible(false)
    local tag = self.m_currItem:getTag()
    self.m_labBox:setString(self.m_data[tag].text)
end

--  下拉框选项按钮响应事件
function DropDownBox:onListViewBtnEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        self.m_currItem = obj
        self:updateBoxState()
        self.m_callback(self.m_currItem:getTag())
    end
end

--  添加下拉框选项
function DropDownBox:addListViewItem(tag, strText)
    local lLayout = ccui.Layout:create()
    lLayout:setContentSize(self.m_btnBoxSize)
    lLayout:setTag(tag)
    self.m_boxListView:pushBackCustomItem(lLayout)
    
    self.m_btnItem[tag] = ccui.Button:create(self.m_commonTexture.BoxNormal, "")
    lLayout:addChild(self.m_btnItem[tag])
    self.m_btnItem[tag]:setScale9Enabled(true)
    self.m_btnItem[tag]:setContentSize(self.m_btnBoxSize)
    self.m_btnItem[tag]:setAnchorPoint(cc.p(0, 0))
    self.m_btnItem[tag]:setTag(tag)
    self.m_btnItem[tag]:addTouchEventListener(handler(self, self.onListViewBtnEvent))
    self.m_btnItem[tag]:setOpacity(0)

    local text = display.newTTFLabel( {
        text = "",
        font = self.m_parLabel.FontName,
        size = self.m_parLabel.FontSize,
        color = self.m_parLabel.ColorNormal,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_btnItem[tag]:addChild(text)
    text:setAnchorPoint(cc.p(0, 0.5))
    text:setPosition(cc.p(self.m_btnBoxSize.width * 0.05, self.m_btnBoxSize.height * 0.5))
    text:setString(strText)
end

return DropDownBox
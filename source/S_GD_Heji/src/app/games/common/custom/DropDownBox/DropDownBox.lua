--
-- Author: RuiHao Lin
-- Date: 2017-05-15 09:59:09
--


--  背景框
local lBoxNormal = "real_res/1004080.png"
-- 展开后背景框
local lBoxContentNormal = "real_res/1004081.png"
--  拉下手把
local lIconNormal = "real_res/1004212.png"
--  拉起手把
local lIconShow = "real_res/1004213.png"
--  字体路径
local lFontFilePath = "res_TTF/1016001.TTF"

-- 为了与DropItem看起来一样做出的微调
-- 文字框高度微调
local kTextBgAddHeight = 9 
-- 按钮位置微调
local kBtnOffX = 3
local kBtnOffY = 5
----------------------------------

-- @brief   RadioButtonGroup   创建【下拉框】
local DropDownBox = class("DropDownBox", function()
    local ret = cc.Node:create()
    ret:setContentSize(cc.size(200, 60))
    return ret
end )

--[[
    --  data结构
    data =
    {
        options =
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

        --  可配置属性，详见 DropDownBox:initConfigList()
        Config =
        {
            --  @brief  设置下拉框最大行数；
            --  @MaxRow 小于或等于1的时设置为1
            MaxRow = 3,
        }
        boxBtnCallBack 点击下拉按钮事件
    }
    @callback   下拉框内按钮的额外事件回调
]]
function DropDownBox:ctor(data, callback)
    self.m_Data = data
    self.m_FuncCallBack = callback
    self:init()
end

--  初始化
function DropDownBox:init()
    self:initData()
    self:initUI()
    self:updateBoxState()
end

--  初始化数据
function DropDownBox:initData()
    --  初始化可配置属性
    self:initConfigList()

    --  下拉框按钮列表    
    self.m_BtnItem = {}

    --  当前选中项
    self.m_CurrItem = {}

    --  下拉框行数
    self.m_CurrRow = #self.m_Data.options >= self.m_ConfigList.MaxRow and self.m_ConfigList.MaxRow or #self.m_Data.options
end

--  初始化可配置属性
function DropDownBox:initConfigList()
    if IsPortrait then -- TODO
        -- 点击下拉按钮回调
        self.m_onBoxBtnCallBack = self.m_Data.boxBtnCallBack
    end
    --  可配置属性列表
    self.m_ConfigList = self.m_Data.Config or {}

    --	下拉框最大行数
    self.m_ConfigList.MaxRow = self.m_ConfigList.MaxRow or 5

    --  按钮尺寸
    self.m_ConfigList.BtnBoxSize = self.m_ConfigList.BtnBoxSize or G_ROOM_INFO_FORMAT.dropDwonBoxSize

    --  文本正常颜色
    self.m_ConfigList.LabNormalColor = self.m_ConfigList.LabNormalColor or G_ROOM_INFO_FORMAT.normalDropFontColor

    --  文本选中颜色
    self.m_ConfigList.LabSelectedColor = self.m_ConfigList.LabSelectedColor or G_ROOM_INFO_FORMAT.selectColor

    --  文本字体尺寸
    self.m_ConfigList.LabFontSize = self.m_ConfigList.LabFontSize or G_ROOM_INFO_FORMAT.fontSize

    --  文本字体文件路径
    self.m_ConfigList.LabFontName = self.m_ConfigList.LabFontName or lFontFilePath
end

--  初始化UI界面
function DropDownBox:initUI()
    local lLayoutSize = self:getContentSize()

    --  选中框
    self.m_BtnBox = ccui.Button:create(lBoxNormal, "")
    self:addChild(self.m_BtnBox)
    self.m_BtnBox:setAnchorPoint(cc.p(0, 0.5))
    self.m_BtnBox:setPosition(cc.p(0, lLayoutSize.height * 0.5))
    self.m_BtnBox:setScale9Enabled(true)
    if IsPortrait then -- TODO
        self.m_BtnBox:setContentSize(cc.size(self.m_ConfigList.BtnBoxSize.width, self.m_ConfigList.BtnBoxSize.height + kTextBgAddHeight))
    else
        self.m_BtnBox:setContentSize(self.m_ConfigList.BtnBoxSize)
    end
    self.m_BtnBox:addTouchEventListener(handler(self, self.onBoxBtnEvent))

    --  选中框文本
    self.m_LabBox = display.newTTFLabel( {
        text = "",
        font = self.m_ConfigList.LabFontName,
        size = self.m_ConfigList.LabFontSize,
        color = self.m_ConfigList.LabSelectedColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_BtnBox:addChild(self.m_LabBox)
    self.m_LabBox:setAnchorPoint(cc.p(0.5, 0.5))
    if IsPortrait then -- TODO
        self.m_LabBox:setPosition(cc.p(self.m_ConfigList.BtnBoxSize.width * 0.5 - 20, self.m_ConfigList.BtnBoxSize.height * 0.5 + kBtnOffY))
    else
        self.m_LabBox:setPosition(cc.p(self.m_ConfigList.BtnBoxSize.width * 0.5 - 20, self.m_ConfigList.BtnBoxSize.height * 0.5))
    end

    --  把柄图标
    self.m_IconHandle = cc.Sprite:create(lIconNormal)
    self.m_BtnBox:addChild(self.m_IconHandle)
    self.m_IconHandle:setAnchorPoint(cc.p(1, 0.5))
    if IsPortrait then -- TODO
        self.m_IconHandle:setPosition(cc.p(self.m_ConfigList.BtnBoxSize.width + kBtnOffX, self.m_ConfigList.BtnBoxSize.height * 0.5 + kBtnOffY))
    else
        self.m_IconHandle:setPosition(cc.p(self.m_ConfigList.BtnBoxSize.width, self.m_ConfigList.BtnBoxSize.height * 0.5))
    end

    --  下拉框
    self.m_BoxListView = ccui.ListView:create()
    self.m_BtnBox:addChild(self.m_BoxListView)
    self.m_BoxListView:setAnchorPoint(cc.p(0, 1))
    self.m_BoxListView:setBackGroundImage(lBoxContentNormal)
    self.m_BoxListView:setBackGroundImageScale9Enabled(true)
    self.m_BoxListView:setContentSize(cc.size(self.m_ConfigList.BtnBoxSize.width, self.m_ConfigList.BtnBoxSize.height * self.m_CurrRow))

    --  添加下拉框选项
    for i, v in pairs(self.m_Data.options) do
        self:addListViewItem(i, v.text)
        if v.isSelected then
            self.m_CurrItem = self.m_BtnItem[i]
        end
    end
end

--[[
    @brief  改变数据，重新绘制控件
    @data   数据
--]]
function DropDownBox:changeData(data)
    self.m_Data = data
    self:init()
end

--  添加下拉框选项
function DropDownBox:addListViewItem(tag, strText)
    local lLayout = ccui.Layout:create()
    lLayout:setContentSize(self.m_ConfigList.BtnBoxSize)
    lLayout:setTag(tag)
    self.m_BoxListView:pushBackCustomItem(lLayout)
    
    self.m_BtnItem[tag] = ccui.Button:create(lBoxNormal, "")
    lLayout:addChild(self.m_BtnItem[tag])
    self.m_BtnItem[tag]:setScale9Enabled(true)
    self.m_BtnItem[tag]:setContentSize(self.m_ConfigList.BtnBoxSize)
    self.m_BtnItem[tag]:setAnchorPoint(cc.p(0, 0))
    self.m_BtnItem[tag]:setTag(tag)
    self.m_BtnItem[tag]:addTouchEventListener(handler(self, self.onListViewBtnEvent))
    self.m_BtnItem[tag]:setOpacity(0)

    local text = display.newTTFLabel( {
        text = "",
        font = self.m_ConfigList.LabFontName,
        size = self.m_ConfigList.LabFontSize,
        color = self.m_ConfigList.LabNormalColor,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )
    self.m_BtnItem[tag]:addChild(text)
    text:setAnchorPoint(cc.p(0.5, 0.5))
    text:setPosition(cc.p(self.m_ConfigList.BtnBoxSize.width * 0.5, self.m_ConfigList.BtnBoxSize.height * 0.5))
    text:setString(strText)

    -- 增加下划线
    if tag ~= #self.m_Data.options then
        local line=display.newSprite("real_res/1004757.png")
        line:setPositionX(self.m_BtnItem[tag]:getContentSize().width/2)
        line:setScale(0.2*(self.m_BtnItem[tag]:getContentSize().width/200),1.3)
        self.m_BtnItem[tag]:addChild(line)
    end
end

--  设置下拉框可视性
function DropDownBox:setListViewVisible(isVisible)
    self.m_BoxListView:setVisible(isVisible)
    if isVisible then
        self.m_IconHandle:setTexture(lIconShow)
    else
        self.m_IconHandle:setTexture(lIconNormal)
    end
end

--[[
    @brief  设置下拉框最大行数
    @maxRow 小于或等于1的时设置为1
--]]
function DropDownBox:setMaxRow(maxRow)
    maxRow = maxRow < 1 and 1 or maxRow
    self.m_ConfigList.MaxRow = maxRow
    self.m_CurrRow = #self.m_Data.options >= maxRow and maxRow or #self.m_Data.options
    self.m_BoxListView:setContentSize(cc.size(self.m_ConfigList.BtnBoxSize.width, self.m_ConfigList.BtnBoxSize.height * self.m_CurrRow))
end

--  选中框按钮响应事件
function DropDownBox:onBoxBtnEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        local isVisible = self.m_BoxListView:isVisible()
        self:setListViewVisible(not isVisible)
        if IsPortrait then -- TODO
            if self.m_onBoxBtnCallBack then
                self.m_onBoxBtnCallBack()
            end
        end
    end
end

--  更新下拉框状态
function DropDownBox:updateBoxState()
    self:setListViewVisible(false)
    local tag = self.m_CurrItem:getTag()
    self.m_LabBox:setString(self.m_Data.options[tag].text)
end

--  下拉框选项按钮响应事件
function DropDownBox:onListViewBtnEvent(obj, event)
    if event == ccui.TouchEventType.ended then
        self.m_CurrItem = obj
        self:updateBoxState()
        self.m_FuncCallBack(self.m_CurrItem:getTag())
    end
end

return DropDownBox
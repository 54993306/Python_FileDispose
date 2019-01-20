-------------------------------------------------------------
--  @file   RuleDialog.lua
--  @brief  规则显示对话框
--  @author Linxiancheng
--  @DateTime:2017-04-20 16:30:22
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================
RuleDialog = class("RuleDialog", UIWndBase)

local kWidgets = {
    tagCloseBtn         = "clost_button",
    tagAreaListView     = "AreaListView",
    tagTextListView     = "TextListView",
    tagAreaItem         = "listItemModel",
    FrontName           = "res_TTF/1016001.TTF"
}
if IsPortrait then -- TODO
    kWidgets.tagTitleLabel = "Label_select_wanfa"
    kWidgets.panelWanfa = "wafan_Panel"
    kWidgets.areaHeight = 80
    kWidgets.tagAreaLabelName = "label_name"
    kWidgets.tagAreaBgImg = "Image_bg"
    kWidgets.areaLabelColor = {selected = cc.c3b(255,243,66), normal = cc.c3b(0x33, 0x33, 0x33), }
    kWidgets.contentPadding = 20 -- 规则文字左右两边的间距
    kWidgets.smallTitleFont = {color = cc.c3b(41,124, 0), size = 36,}
    kWidgets.titleFont = {color = cc.c3b(0x83, 0x40, 0x05), size = 40,}
    kWidgets.contentFont = {color = cc.c3b(0x33, 0x33, 0x33), size = 36,}
    kWidgets.tagTextBg = "Image_guizhe_bg"
    kWidgets.designHeight = 1280
    kWidgets.textBgConfig = {offHeight = -355, }
    kWidgets.textPanelConfig = {offHeight = -370, offY = 7}
    kWidgets.singleAreaTitle = "游戏玩法：" -- 单一地区时的标题
end
--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function RuleDialog:ctor(info)
    self.super.ctor(self, "hall/rule_dialog.csb", info)
    self.baseShowType = UIWndBase.BaseShowType.RTOL
end
--[[
-- @brief  显示函数
-- @param  void
-- @return void
--]]
function RuleDialog:onShow()
    Log.i("RuleDialog:onShow")
    if IsPortrait then -- TODO
        self:initRuleTable()
        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        if #areatable <= 1 then -- 当仅有一个地区选项时，直接选中
            self:areaVisible(false)
            self.m_Button_drop:setVisible(false)
            self.m_Button_packup:setVisible(false)
            ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTitleLabel):setString(kWidgets.singleAreaTitle)
        end
    end
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function RuleDialog:onClose()
    Log.i("RuleDialog:onClose")
end
--[[
-- @brief  初始化函数
-- @param  void
-- @return void
--]]

function RuleDialog:onInit()
    if not IsPortrait then -- TODO
        self:addWidgetClickFunc(self.m_pWidget, handler(self, self.popSelf))
    end
    self.button_close   = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagCloseBtn)
    self.button_close:addTouchEventListener(handler(self, self.onClickButton))
    self.pListView      = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTextListView)
    if IsPortrait then -- TODO
        self.pListView:addTouchEventListener(handler(self, self.onScrollClick))
        self.pan_content=ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content");
        self.pan_content:addTouchEventListener(handler(self, self.onScrollClick))

        self.panelWanfa = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.panelWanfa)
    else
        -- 文本内容
        self.smallTitleColor = cc.c3b(41,124, 0)
        self.redColor = cc.c3b(242,46,0)
        self.contentColor = cc.c3b(43,76,1)
    end
    self.rulePath = ""

    if IsPortrait then -- TODO
        self:liftButton()
    end
    
    self:initAreaListView();

    if IsPortrait then -- TODO
        self:refreshTextPanelHeight()
    end
end

if IsPortrait then -- TODO
    function RuleDialog:onScrollClick(pWidget, EventType)
        if EventType == ccui.TouchEventType.began then
            if self.select_game_Panel:getContentSize().height > 0 then
                self:areaVisible(false)
            end
        end
    end

    --监听升降按钮
    function RuleDialog:liftButton()
        self.m_Button_drop = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_drop");
        self.m_Button_drop:addTouchEventListener(handler(self,self.onClickLiftButton))
        self.m_Button_packup = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_packup");
        self.m_Button_packup:addTouchEventListener(handler(self,self.onClickLiftButton))
    end
    function RuleDialog:updateListViewonTouch()
        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        local count=math.ceil((#areatable - 1)/4)  -- 此处减1是因为有多一项传版本信息的（非麻将玩法）
        if count* kWidgets.areaHeight >self.pan_content:getContentSize().height*0.5 then
            local content = self.list_view_select:getInnerContainer()
            local icPosY = content:getPositionY()
            if self.listViewPosY ~= icPosY then
                self.listViewPosY = icPosY
                local listVSize = self.list_view_select:getContentSize()
                local listICSize = self.list_view_select:getInnerContainerSize()
                if listICSize and listVSize and icPosY and self.scrollBar then
                    local touchY = (listICSize.height-listVSize.height+icPosY)
                    self.scrollBar:setProgress(touchY/(listICSize.height-listVSize.height))
                    Log.i("touchY/(listICSize.height-listVSize.height...",touchY,touchY/(listICSize.height-listVSize.height))
                end
            end
        end
    end
    function RuleDialog:onClickLiftButton(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            pWidget:setVisible(false)
            if pWidget == self.m_Button_drop then
                -- self.m_Button_drop:setVisible(true)
                self:areaVisible(true)
            else
                -- self.m_Button_packup:setVisible(true)
                self:areaVisible(false)
            end
           
        end
    end

    --设置游戏选择项是否可见
    function RuleDialog:areaVisible(b)
        self.m_Button_drop:setVisible(not b)
        self.m_Button_packup:setVisible(b)

        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        local count=math.ceil((#areatable - 1)/4)
        if b then
            local height=count* kWidgets.areaHeight >self.pan_content:getContentSize().height*0.5 and self.pan_content:getContentSize().height*0.5 or count* kWidgets.areaHeight
            self.select_game_Panel:setContentSize(cc.size( self.select_game_Panel:getContentSize().width,height))
            self.list_view_select:setContentSize(self.select_game_Panel:getContentSize())
        else
            self.select_game_Panel:setContentSize(cc.size( self.select_game_Panel:getContentSize().width,0))
        end

        self:doViewLayout()

        if b and count* kWidgets.areaHeight >self.pan_content:getContentSize().height*0.5 then
            local data = {
                parent = self.select_game_Panel;                   --父节点
                bgSprite = "#1004623.png";                  --背景层资源
                scrollSprite = "real_res/1004622.png";              --滚动块资源
                bgSize = cc.size(1,self.pan_content:getContentSize().height*0.5);          --背景大小
            }
            self.scrollBar = ClientScrollBar.new(data)
            local sgpSize = self.select_game_Panel:getContentSize()
            self.scrollBar:setPosition(cc.p(sgpSize.width,data.bgSize.height/2))
            
        end
    end

    function RuleDialog:doViewLayout(  )
        local desWanfaHeight = self.pan_content:getContentSize().height
                                -self.select_game_Panel:getContentSize().height
                                -10
        if desWanfaHeight > 0 then
            self.panelWanfa:setContentSize(
                cc.size(self.panelWanfa:getContentSize().width, desWanfaHeight)
                )

            if not tolua.isnull(self.pListView) then
                local panelWanfaHeight = self.panelWanfa:getContentSize().height
                local entityHeight = self.pListView:getContentSize().height

                if panelWanfaHeight > entityHeight then
                    self.pListView:setInnerContainerSize(cc.size(self.panelWanfa:getContentSize().width, panelWanfaHeight))
                    self.pListView:setPositionY(panelWanfaHeight - entityHeight - 10)
                else
                    self.pListView:setInnerContainerSize(cc.size(self.panelWanfa:getContentSize().width, entityHeight))
                    self.pListView:setPositionY(-10)
                end
            end
            self.pan_content:forceDoLayout()
        end    
    end

    --监听点击哪个游戏
    function RuleDialog:onClickAreaButton(data,nIndex)

        self.gameId=data.gameId
        self:initRuleTable()
        self:areaVisible(false)
        -- self.m_Button_drop:setVisible(false)
        -- self.m_Button_packup:setVisible(true)

        local Label_wanfa_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_wanfa_name");
        Label_wanfa_name:setString(data.gameName)
        Label_wanfa_name:setVisible(true)
    end
end

if IsPortrait then -- TODO
    function RuleDialog:initAreaListView()
        local areatable = kFriendRoomInfo:getAreaBaseInfo()

        self.pan_content=ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content");
        self.select_game_Panel=ccui.Helper:seekWidgetByName(self.m_pWidget, "select_game_Panel");
        self.list_view_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "list_view_select");
        self.list_view_select:addTouchEventListener(handler(self, self.onScrollClick))
        local item_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "item_select");
        item_select:setVisible(false)
        local count=math.ceil((#areatable - 1)/4)
        self.areaNames={}
        for i=1,count do
            local item=item_select:clone()
            item:setVisible(true)
            self.list_view_select:pushBackCustomItem(item)
            for j=1,4 do
                local btn_select=ccui.Helper:seekWidgetByName(item, "btn_select"..j);
                local index=(i-1)*4+j
                if areatable[index] and areatable[index].gameName and areatable[index].gameName ~= "" then
                    local label_name=btn_select:getChildByName(kWidgets.tagAreaLabelName)
                    label_name:setString(areatable[index].gameName)
                    label_name:setOpacity(255)
                    table.insert(self.areaNames,btn_select)
                    btn_select:setTouchEnabled(true)
                    btn_select:addTouchEventListener(function(pWidget, EventType) 
                    if EventType == ccui.TouchEventType.ended then
                        self:onClickAreaButton(areatable[index],index)
                        for k,v in pairs(self.areaNames) do
                            if k==index then
                                v:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.selected)
                                v:getChildByName(kWidgets.tagAreaBgImg):setVisible(true)
                            else
                                v:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.normal)
                                v:getChildByName(kWidgets.tagAreaBgImg):setVisible(false)
                            end
                        end
                        
                    end 
                    end);
                else
                    btn_select:setVisible(false)
                    btn_select:setTouchEnabled(false)
                end
            end

        end
        self.list_view_select:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            self:updateListViewonTouch()
        end))))
        --设置默认选项
        self.gameId=SettingInfo.getInstance():getSelectAreaGameID()
        local Label_wanfa_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_wanfa_name");
        Label_wanfa_name:setString("")

        for k,data in pairs(areatable) do
            if self.gameId==0 then
                self.gameId=data.gameId
                Label_wanfa_name:setString(data.gameName)
                self.areaNames[k]:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.selected)
                self.areaNames[k]:getChildByName(kWidgets.tagAreaBgImg):setVisible(true)
                break
            else
                if data.gameId == self.gameId then
                    Label_wanfa_name:setString(data.gameName)
                    self.areaNames[k]:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.selected)
                    self.areaNames[k]:getChildByName(kWidgets.tagAreaBgImg):setVisible(true)
                    break
                end
            end
        end
    end
    -- otherHeight 额外应减去的高度
    function RuleDialog:refreshTextPanelHeight(otherHeight)
        self.pListView:setContentSize(cc.size(self.pListView:getContentSize().width, display.top + kWidgets.textPanelConfig.offHeight - (otherHeight or 30)))
        self.pListView:setPositionY(kWidgets.designHeight - display.top + kWidgets.textPanelConfig.offY + 10)
        local textBg = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTextBg)
        textBg:setContentSize(cc.size(textBg:getContentSize().width, display.top + kWidgets.textBgConfig.offHeight - (otherHeight or 0)))
        textBg:setPositionY(kWidgets.designHeight - display.top )
    end
else
    function RuleDialog:initAreaListView()
        self.areaBtns = {}
        local tAreaDataTable = kFriendRoomInfo:getAreaBaseInfo();
        local tAreaListView = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagAreaListView)
        --local tAreaItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/area_item.csb");
        local tAreaItem = ccui.Helper:seekWidgetByName(self.m_pWidget,kWidgets.tagAreaItem)
        tAreaItem:setVisible(false)
        if #tAreaDataTable <= 0 then
            print("[ ERROR ] RuleDialog:initAreaListView data is nil")
            return
        end

        for k,tAreaData in pairs(tAreaDataTable) do
            local tItem = tAreaItem:clone()
            tItem:setVisible(true)
            tAreaListView:pushBackCustomItem(tItem)
            local Label_nor = ccui.Helper:seekWidgetByName(tItem, "Label_nor");
            local Label_select = ccui.Helper:seekWidgetByName(tItem, "Label_select");

            local tmpName = Util.cutMjName(tAreaData.gameName)
            -- 请在config.lua中添加GC_GameName
            Label_nor:setString(tmpName or tAreaData.gameName or GC_GameName)
            Label_select:setString(tmpName or tAreaData.gameName or GC_GameName)
            local tAreaBtn = ccui.Helper:seekWidgetByName(tItem,"AreaButton")
            tAreaBtn.norLabel = Label_nor
            tAreaBtn.selectLabel = Label_select
            tAreaBtn.gameId = tAreaData.gameId
            tAreaBtn.selectBgs = {ccui.Helper:seekWidgetByName(tItem, "img_select"), ccui.Helper:seekWidgetByName(tItem, "img_unselect")}
            tAreaBtn:addTouchEventListener(handler(self,self.AreaBtnCallBack))
            table.insert(self.areaBtns,tAreaBtn)

            -- local size = self:setFontSize(tAreaBtn,Label_nor,tmpName,Label_nor:getFontSize())
            -- Label_select:setFontSize(size)
        end
        self:initFirstBtn()
    end

    --设置默认选中按钮
    function RuleDialog:initFirstBtn()
        if #self.areaBtns <= 0 then
            Log.e("RuleDialog:initFirstBtn Data Error by Linxiancheng===========================")
            return
        end
        for k,btn in pairs(self.areaBtns) do
            if btn.gameId ==  SettingInfo.getInstance():getSelectAreaGameID() then
                btn.selectBgs[1]:setVisible(true)
                btn.selectBgs[2]:setVisible(false)
                self.gameId = btn.gameId
                btn.selectLabel:setVisible(true)
                btn.norLabel:setVisible(false)
                self:initRuleTable()
                return;
            end
        end
        Log.i("RuleDialog:initFirstBtn Data by Linxiancheng===========================")
        --初始化的情况
        local btn1 = self.areaBtns[1]    
        btn1.selectBgs[1]:setVisible(true)
        btn1.selectBgs[2]:setVisible(false)
        self.gameId = btn1.gameId
        btn1.selectLabel:setVisible(true)
        btn1.norLabel:setVisible(false)
        self:initRuleTable()
    end
    
    --选择了区域后改变规则内容
    function RuleDialog:AreaBtnCallBack(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            for k,v in pairs(self.areaBtns) do
                if v == pWidget then
                    self.gameId = v.gameId
                    v.selectBgs[1]:setVisible(true)
                    v.selectBgs[2]:setVisible(false)
                    v.norLabel:setVisible(false)
                    v.selectLabel:setVisible(true)
                    self:initRuleTable()
                else
                    v.selectBgs[1]:setVisible(false)
                    v.selectBgs[2]:setVisible(true)
                    v.selectLabel:setVisible(false)
                    v.norLabel:setVisible(true)
                end
            end
        end
    end
end

function RuleDialog:setFontSize(areaButton,label,value,fontSize)
    local textSize = Util.getFontWidth(value,fontSize)
    local size = fontSize
    if textSize/2 > areaButton:getContentSize().width-20 then
        local poor = (areaButton:getContentSize().width-20)
        local len = Util.utfstrlen(value)
        size = poor/len
--        size = 28
        label:setFontSize(size)
    end
    return size
end

function RuleDialog:initRuleTable()
    self.pListView:removeAllItems();
    self.pListView:refreshView();
    --释放旧的加载新的
    if self.rulePath ~= "" then
        package.loaded[self.rulePath] = nil;
    end
    --dump(self.gameId)
    if GC_GameTypes[self.gameId] then
        local path = "package_src.games." .. GC_GameTypes[self.gameId] .. ".RuleTable"
        if GC_GameTypes[self.gameId] == "pdkpk" then
            path = "package_src.games." .."paodekuai.".. GC_GameTypes[self.gameId] .. ".RuleTable"
        elseif GC_GameTypes[self.gameId] == "gdpk" then
            path = "package_src.games." .."guandan.".. GC_GameTypes[self.gameId] .. ".RuleTable"
        end
        local isSuccess, errMsg = pcall(require, path);
        if isSuccess then
            local ruleTable
            if GC_GameTypes[self.gameId] == "pdkpk" then
                ruleTable = require("package_src.games." .."paodekuai.".. GC_GameTypes[self.gameId] .. ".RuleTable")
            elseif GC_GameTypes[self.gameId] == "gdpk" then
                ruleTable = require("package_src.games." .."guandan.".. GC_GameTypes[self.gameId] .. ".RuleTable")
            else
                ruleTable = require("package_src.games." .. GC_GameTypes[self.gameId] .. ".RuleTable")
            end
            if ruleTable then
                if GC_GameTypes[self.gameId] == "pdkpk" then
                    self.rulePath = "package_src.games." .."paodekuai.".. GC_GameTypes[self.gameId] .. ".RuleTable"
                elseif GC_GameTypes[self.gameId] == "gdpk" then
                    self.rulePath = "package_src.games." .."guandan.".. GC_GameTypes[self.gameId] .. ".RuleTable"
                else
                    self.rulePath = "package_src.games." .. GC_GameTypes[self.gameId] .. ".RuleTable"
                end  
                self:ParseRuleTable(ruleTable)
            else
                self.rulePath = ""
                Log.e("RuleDialog:initRuleTable 中尚未添加该游戏 "..self.gameId)
            end
        else
            Log.e("RuleDialog:initRuleTable "..GC_GameTypes[self.gameId].." RuleTable 文件不存在")
        end
    else
        Log.e("RuleDialog:initRuleTable GC_GameTypes 未配置ID"..self.gameId)
    end
end

--具体解析配置表
function RuleDialog:ParseRuleTable(pRuleTable)
    for k,v in pairs(pRuleTable) do
        if k == "smallTitle" then
            if IsPortrait then -- TODO
                self:insertLabelInLisiView(v, kWidgets.smallTitleFont)
            else
                self:insertLabelInLisiView(v,self.smallTitleColor)
            end
        elseif k == "ruleContent" then
            for tIndex,contentTable in pairs(v) do
                for tTitle,tContent in pairs(contentTable) do
                    if tTitle == "redTitle" then
                        if IsPortrait then -- TODO
                            self:insertLabelInLisiView(tContent, kWidgets.titleFont)
                        else
                            self:insertLabelInLisiView(tContent,self.redColor)
                        end
                    elseif tTitle == "content" then
                        if IsPortrait then -- TODO
                            self:insertLabelInLisiView(tContent, kWidgets.contentFont)
                        else
                            self:insertLabelInLisiView(tContent,self.contentColor)
                        end
                    end
                end
            end
        end
    end
end

if IsPortrait then -- TODO
    function RuleDialog:insertLabelInLisiView(ContentText, fontConfig)
        local content = ccui.Text:create();
        content:setFontName(kWidgets.FrontName)
        -- local color = cc.c3b(255,255,255)
        content:setColor(fontConfig.color or display.COLOR_WHITE)
        content:setTextAreaSize(cc.size(self.pListView:getContentSize().width - kWidgets.contentPadding * 2, 0));
        content:setString(ContentText or "");
        content:setFontSize(fontConfig.size or 26);
        -- content:enableShadow();
        content:ignoreContentAdaptWithSize(false)
        self.pListView:pushBackCustomItem(content);
    end
else
    function RuleDialog:insertLabelInLisiView(ContentText,Frontcolor)
        local content = ccui.Text:create();
        content:setFontName(kWidgets.FrontName)
        local color = cc.c3b(255,255,255)
        content:setColor(color)
        content:setTextAreaSize(cc.size(880, 0));
        content:setString(ContentText or "提示内容");
        content:setFontSize(26);
        -- content:enableShadow();
        content:ignoreContentAdaptWithSize(false)
        self.pListView:pushBackCustomItem(content);
    end
end
--[[
-- @brief  按钮响应函数
-- @param  void
-- @return void
--]]
function RuleDialog:onClickButton(pWidget, EventType)
    print(EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.button_close then
            self:keyBack()
        end
    end
end

function RuleDialog:keyBack()
    UIManager:getInstance():popWnd(RuleDialog)
end


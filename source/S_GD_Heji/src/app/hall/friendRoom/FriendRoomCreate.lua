-------------------------------------------------------------
--  @file   FriendRoomCreate.lua
--  @brief  创建房间规则界面
--  @author ZCQ
--  @DateTime:2016-11-07 12:08:58
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2016
--============================================================

require("app.DebugHelper")
local UmengClickEvent = require("app.common.UmengClickEvent")

local LocalEvent = require("app.hall.common.LocalEvent")

FriendRoomCreate = class("FriendRoomCreate", UIWndBase);

local kWidgets = {
    tagConfirm = "btn_sure", -- 确定
    tagCancel  = "clost_button",  -- 取消

    tagTips1 = "tips", -- 提示1
    tagTips2 = "tips_0",-- 提示2

    panelNorMode = "panel_normalMode",
    btnSwitchClubMode = "btn_switchClubMode",

    panelclubMode = "panel_clubMode",
    labClubName = "lab_clubName",
    labClubDiamond = "lab_clubDiamond",
    labClubDiamondSt = "lab_clubDiamondSt",
    btnSwitchNormalMode = "btn_switchNormalMode",
    btnSwitchClub = "btn_switchClub",
    labOtherTip1 = "lab_otherTip1",
    labOtherTip2 = "lab_otherTip2",

    bgPanel = "bg_Panel",

    scrollViewRuler = "guizhe_ScrollView",
}

if IsPortrait then -- TODO
    kWidgets.panelWanfa = "wafan_Panel"

    kWidgets.tagTitleLabel = "Label_select_wanfa"
    kWidgets.areaHeight = 80
    kWidgets.tagAreaLabelName = "label_name"
    kWidgets.tagAreaSelectedImg = "img_selected"
    kWidgets.areaLabelColor = {selected = cc.c3b(255,243,66), normal = cc.c3b(0x33, 0x33, 0x33), }
    kWidgets.designHeight = 1280
    kWidgets.ruleBgConfig = {offHeight = 380}
    kWidgets.singleAreaTitle = "游戏玩法：" -- 单一地区时的标题
end


local kResPath = "hall/"

--俱樂部房間查看的偏移量
local clubPanelOffest_y = -120

local bgColor = cc.c4b(224, 233, 236, 255)

--[[
-- @brief  构造函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:ctor(...)
    self.super.ctor(self, kResPath.."friendRoomCreate.csb", ...);
    self.m_data=...;
    if self.m_data == nil then self.m_data = {} end
    self.m_isOpen=false --是否打开下拉列表
    self.baseShowType = UIWndBase.BaseShowType.RTOL

    self.m_socketProcesser = FriendRoomSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
end
--[[
-- @brief  关闭函数
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onClose()

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end

end
--[[
-- @brief  初始函数
-- @param  void
-- @return void
--]]

function FriendRoomCreate:isClubMode()
    return self.m_data.clubInfo ~= nil
end

function FriendRoomCreate:onInit()
    --[[
        ##  gaI  int  游戏ID
        ##  roS  String  局数
        ##  RoFS  String  房费数量
        ##  di  String  底分
        ##  fe  String  封顶
        ##  wa  String  玩法
        ##  plS int     人数
        ##  RoJST int   付费类型 1 =房主付费，2 =大赢家付费，3 =AA付费
        ##  re  int  结果（-1 =创建失败不够资源，-2 =创建失败无可用房间， 非0 = 房间密码）
    ]]
    if IsPortrait then -- TODO
        self._isAreaListViewShow = true --显示玩法状态
    else
        self:addWidgetClickFunc(self.m_pWidget,
            function()
                if self.m_pan_newer and self.m_pan_newer:isVisible() then
                    return;
                end
                self:popSelf()
            end)

        local bgPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.bgPanel)
        local bgPanelSize = bgPanel:getContentSize()
        bgPanel:addChild(cc.LayerColor:create(bgColor, bgPanelSize.width, bgPanelSize.height))
    end

    self.cancleBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagCancel);
    self.cancleBtn:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagConfirm);
    self.btn_sure:addTouchEventListener(handler(self, self.onClickButton));

    self.scrollViewRuler = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.scrollViewRuler);
    if IsPortrait then -- TODO
        self.panelWanfa = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.panelWanfa);

        self.scrollViewRuler:addTouchEventListener(handler(self, self.onScrollClick));

        self.pan_content=ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content");
        self.pan_content:addTouchEventListener(handler(self, self.onScrollClick));
    end

    if self.m_data and self.m_data.newerType then
        self.m_NewerType = self.m_data.newerType;
        self:showNewer();
    end

    if not IsPortrait then -- TODO
        self:initAreaListView()
        self:areaSelectBack()
    end

    -- 应用宝隐藏钻石提示
    if IS_YINGYONGBAO then
        local tagTips1 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTips1)
        if tagTips1 then tagTips1:setVisible(false) end
        local tagTips2 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTips2)
        if tagTips2 then tagTips2:setVisible(false) end
    end

    self.btn_switchClubMode = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.btnSwitchClubMode)
    self.btn_switchNormalMode = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.btnSwitchNormalMode)

    self.btn_switchClub = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.btnSwitchClub)

    self.btn_switchClubMode:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_switchNormalMode:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_switchClub:addTouchEventListener(handler(self, self.onClickButton));

    self.panelNorMode = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.panelNorMode)
    self.panelclubMode = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.panelclubMode)

    if IsPortrait then -- TODO
        self.btn_switchNormalMode:setVisible(false)
        self.btn_switchClub:setVisible(false)
        self.panelclubMode:setTouchEnabled(false)
    end

    self.panelclubMode:addTouchEventListener(handler(self, self.onScrollClick));
    self.panelNorMode:addTouchEventListener(handler(self, self.onScrollClick));

    self.m_panNormal_height = self.panelNorMode:getContentSize().height
    self.m_panClub_height = self.panelclubMode:getContentSize().height

    if IsPortrait then -- TODO
        self.showSelectArea = true  -- 显示玩家选择的区域数据和通用玩法,否则显示所有的玩法
        self:liftButton()
        self:initAreaListView()
    end

    if Util.debug_shield_value("club") then
        self.btn_switchClubMode:setVisible(false)
        self.m_data.clubInfo = nil
        if IsPortrait then -- TODO
            self.panelNorMode:setContentSize(self.panelNorMode:getContentSize().width, 0)
            self.panelclubMode:setContentSize(self.panelclubMode:getContentSize().width, 0)
            self.panelclubMode:setVisible(false)
            self.panelNorMode:setVisible(false)
            self:doViewLayout()
        end
    end

    self:refreshUIInfo()
    local state = kFriendRoomInfo:getRoomState()
    if IsPortrait then -- TODO
        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        if #areatable <= 1 then -- 当仅有一个地区选项时，直接选中
            self:areaVisible(false)
            self.m_Button_drop:setVisible(false)
            self.m_Button_packup:setVisible(false)
            self.m_PanelTitle:setTouchEnabled(false)
            ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.tagTitleLabel):setString(kWidgets.singleAreaTitle)
        end

        local img_sure = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_sure");

        if state == CreateRoomState.clubmodel then
            self.btn_switchClubMode:setVisible(false)
            self.btn_switchClub:setVisible(false)
            img_sure:loadTexture ( "hall/huanpi2/Common/img_t_qj.png" )
        elseif state == CreateRoomState.resetmodel then
            img_sure:loadTexture ( "hall/huanpi2/Common/img_t_qd.png" )
            self.btn_switchClubMode:setVisible(false)
            self.btn_switchClub:setVisible(false)
        end
    else
        if state == CreateRoomState.clubmodel then
            self.btn_sure:setTitleText("创建模版")
        elseif state == CreateRoomState.resetmodel then
            self.btn_sure:setTitleText("确定更改")
        end
    end
end

function FriendRoomCreate:onScrollClick(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if not self.m_Button_drop:isVisible() then
            self:areaVisible(false)
        end

    end
end

function FriendRoomCreate:refreshUIInfo()
    local labClubDiamond = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labClubDiamond)
    if IsPortrait then -- TODO
        labClubDiamond:setString("亲友圈钻石：")
    end
    local labClubDiamondSt = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labClubDiamondSt)
    local labOtherTip1 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labOtherTip1)
    local labOtherTip2 = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labOtherTip2)

    if Util.debug_shield_value("club") then
        if not IsPortrait then -- TODO
            self.panelNorMode:setVisible(true)
            self.panelclubMode:setVisible(false)
            labClubDiamond:setVisible(false)
            labClubDiamondSt:setVisible(false)
            self.btn_switchClubMode:setVisible(false)
            labOtherTip1:setString("钻石在第一局牌局结束后扣除")
            labOtherTip2:setString("第一局提前结算不扣除钻石")
        end
    else
        if not self:isClubMode() then
            self.panelNorMode:setVisible(true)
            self.panelclubMode:setVisible(false)
            labClubDiamond:setVisible(false)
            labClubDiamondSt:setVisible(false)
            if IsPortrait then -- TODO
                self.panelNorMode:setContentSize(self.panelNorMode:getContentSize().width, self.m_panNormal_height)
                self.panelclubMode:setContentSize(self.panelclubMode:getContentSize().width, 0)
                self.panelWanfa:setContentSize(self.panelWanfa:getContentSize().width, self.pan_content:getContentSize().height-self.m_panNormal_height)

                labOtherTip1:setString("钻石在第一局牌局结束后扣除,第一局提前结算不扣除钻石")
                self.panelNorMode:getLayoutParameter():setMargin({top = 0})
                self.panelWanfa:getLayoutParameter():setMargin{top = self.panelNorMode:getContentSize().height }
            else
                self.btn_switchClubMode:setVisible(true)
                labOtherTip1:setString("钻石在第一局牌局结束后扣除")
                labOtherTip2:setString("第一局提前结算不扣除钻石")
            end
        else
            self.panelNorMode:setVisible(false)
            self.panelclubMode:setVisible(true)
            labClubDiamond:setVisible(true)
            labClubDiamondSt:setVisible(true)
            if IsPortrait then -- TODO
                labOtherTip1:setString("第一局结束后扣除亲友圈钻石,第一局提前结算不扣除钻石")

                self.panelNorMode:setContentSize(self.panelNorMode:getContentSize().width, 0)
                self.panelclubMode:setContentSize(self.panelclubMode:getContentSize().width, self.m_panClub_height)
                self.panelWanfa:setContentSize(self.panelWanfa:getContentSize().width, self.pan_content:getContentSize().height-self.m_panClub_height)
            else
                self.btn_switchClubMode:setVisible(false)
                labOtherTip1:setString("第一局结束后扣除亲友圈钻石")
                labOtherTip2:setString("第一局提前结算不扣除钻石")
            end

            local labClubName = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labClubName)
            local labClubDiamondSt = ccui.Helper:seekWidgetByName(self.m_pWidget, kWidgets.labClubDiamondSt)

            local diaStr, diaClr = Util.formatClubDiamondSt(self.m_data.clubInfo.diamondSt)
            labClubDiamondSt:setString(diaStr)
            labClubDiamondSt:setColor(diaClr)
            if IsPortrait then -- TODO
                Util.updateNickName(labClubName, ToolKit.subUtfStrByCn(self.m_data.clubInfo.clubName, 0, 11, "..."))
                self.panelclubMode:getLayoutParameter():setMargin({top = clubPanelOffest_y})
                self.panelWanfa:getLayoutParameter():setMargin{top = self.panelclubMode:getContentSize().height + clubPanelOffest_y}
            else
                Util.updateNickName(labClubName, self.m_data.clubInfo.clubName)
            end
        end
        if IsPortrait then -- TODO
            if IS_YINGYONGBAO then
                labOtherTip1:setVisible(false)
            end
            self:doViewLayout()
        end
    end
end

if IsPortrait then -- TODO
    -- 初始化需要显示的地区列表
    function FriendRoomCreate:initShowArea()
        local tab = kFriendRoomInfo:getAreaAndCommon()   -- 需要显示出来的地区
        if #tab == 0 then
            kFriendRoomInfo:initAreaAndCommon()
            tab = kFriendRoomInfo:getAreaAndCommon()
        end
        tab = clone(tab)
        Log.i("-----------------game2" , tab)
        local allAreaInfo = kFriendRoomInfo:getAreaBaseInfo()       -- 总玩法数据
        local RecommendID = kSettingInfo:getRecommendID()          -- 推荐游戏id
        Log.i(" show common game1 " , RecommendID)
        if RecommendID ~= 0 then      -- 上次玩的玩法是否在通用玩法和地区玩法中，不在则加入到显示列表
            local insert = true
            for _,v in pairs(tab) do
                if v == RecommendID then
                    insert = false
                end
            end
            if insert then
                table.insert(tab,RecommendID)
            end
        end
        Log.i(" show common game3 " , tab)

        self.areaGames = {}
        for _,v in pairs(tab) do
            for _,gamedata in pairs(allAreaInfo) do
                if v == gamedata.gameId then
                    table.insert(self.areaGames , gamedata)
                end
            end
        end
        -- Log.i("show game data " , self.areaGames)

        local areadata = {}
        areadata.gameName = "more"   -- 添加更多按钮
        areadata.gameId = 100
        table.insert(self.areaGames, areadata)
        -- Log.i(" show common game4 " , #self.areaGames)
    end

    -- 点击了更多按钮后，将多余的玩法都直接添加在后面并绘制出来
    function FriendRoomCreate:updateAreaList()
        -- 需要在最后加一个收起的按钮，点击按钮后，把该隐藏的隐藏起来
        local allAreaInfo = kFriendRoomInfo:getAreaBaseInfo()       -- 总玩法数据
        self.areaGames[#self.areaGames].gameName = "backup"         -- 修改内容为收起
        for _,v in pairs(allAreaInfo) do
            if v.gameName and v.gameName ~= "" then
                local insert = true
                for _,_v in pairs(self.areaGames) do
                    if v.gameId == _v.gameId then
                        insert = false
                    end
                end
                if insert then
                    table.insert(self.areaGames , #self.areaGames ,v) -- 在更多面前进行插入
                end
            end
        end
        table.unique(self.areaGames)
    end
    -- 每次对列表的操作都需要刷新地区选择项，选择了地区后要将列表收缩起来

    --编辑器scrollview
    function FriendRoomCreate:initAreaListView()
        self:initShowArea()
        if self.showSelectArea then      -- 控制是否需要显示所有内容
            self.showSelectArea = false
        else
            self.showSelectArea = true
            self:updateAreaList()
        end
        local areatable = self.areaGames

        local ddzGuidanceStatus = kSettingInfo.getDDZGuidanceStatus()
        local ddzIdx = 0 -- 检测斗地主的指引是否需要开启, 后续逻辑中用ddzIdx做判断
        local resortedTab = {}
        for i, v in ipairs(areatable) do
            if v.gameName and v.gameName ~= "" then -- 服务器数据中最后一项玩法数据没有玩法名称
                if ddzGuidanceStatus <= 0 and v.gameId == GLOBAL_DEFINE.DDZID then
                    ddzIdx = i
                end
                table.insert(resortedTab, v)
            end
        end
        areatable = resortedTab

        self.pan_content=ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_content");
        self.select_game_Panel=ccui.Helper:seekWidgetByName(self.m_pWidget, "select_game_Panel");
        self.list_view_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "list_view_select");
        local item_select=ccui.Helper:seekWidgetByName(self.m_pWidget, "item_select");
        item_select:setVisible(false)

        local count=math.ceil(#areatable/4)
        self.m_AreaBtns={}
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
                    table.insert(self.m_AreaBtns,btn_select)
                    btn_select:setTouchEnabled(true)
                    if areatable[index].gameId == 100 then
                        label_name:setString("")
                        ccui.Helper:seekWidgetByName(btn_select, "img_add"):setVisible(true)
                        if areatable[index].gameName == "more" then
                            ccui.Helper:seekWidgetByName(btn_select, "Image_more"):setVisible(true)
                            ccui.Helper:seekWidgetByName(btn_select, "Image_back"):setVisible(false)
                        else
                            ccui.Helper:seekWidgetByName(btn_select, "Image_more"):setVisible(false)
                            ccui.Helper:seekWidgetByName(btn_select, "Image_back"):setVisible(true)
                        end
                    end
                    btn_select:addTouchEventListener(function(pWidget, EventType)
                        if EventType == ccui.TouchEventType.ended then
                            SoundManager.playEffect("btn");
                            if areatable[index].gameId == 100 then
                                self.list_view_select:removeAllItems()
                                self:initAreaListView()
                                self:areaVisible(true)
                                return
                            end
                            self:onClickAreaButton(areatable[index],index)
                            dump(index)
                            for k,v in pairs(self.m_AreaBtns) do
                                if k==index then
                                    v:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.selected)
                                    v:getChildByName(kWidgets.tagAreaSelectedImg):setVisible(true)
                                else
                                    v:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.normal)
                                    v:getChildByName(kWidgets.tagAreaSelectedImg):setVisible(false)
                                end
                            end

                        end
                    end);
                    -- 在斗地主图标上方增加一个"新"字
                    if areatable[index].gameId == GLOBAL_DEFINE.DDZID then
                        self:showNewArea(btn_select)
                    end
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
        local Label_wanfa_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_wanfa_name");
        Label_wanfa_name:setString("")

        -- 选择默认按钮
        local function selectBtn(index, data)
            kFriendRoomInfo:setRoomBaseInfo(data)
            self:areaSelectBack()
            SettingInfo.getInstance():setSelectAreaGameID(data.gameId)
            Label_wanfa_name:setString(data.gameName)
            self.m_AreaBtns[index]:getChildByName(kWidgets.tagAreaLabelName):setColor(kWidgets.areaLabelColor.selected)
            self.m_AreaBtns[index]:getChildByName(kWidgets.tagAreaSelectedImg):setVisible(true)
        end

        if ddzIdx > 0 then
            -- 显示斗地主提示
            Log.i("Hint DDZ Guidance!!!")
            selectBtn(ddzIdx, areatable[ddzIdx])
            self:showNewerDDZ()
        else
            local state = kFriendRoomInfo:getRoomState()
            for k,data in pairs(areatable) do
                if state == CreateRoomState.resetmodel and kFriendRoomInfo:getClubModel().gaI then -- 重置模版状态
                    if data.gameId == kFriendRoomInfo:getClubModel().gaI then
                        selectBtn(k, data)
                        break
                    elseif k == #areatable then
                        selectBtn(1, areatable[1])
                        break
                    end
                else
                    if SettingInfo.getInstance():getSelectAreaGameID()==0 then
                        selectBtn(k, data)
                        break
                    else
                        if data.gameId == SettingInfo.getInstance():getSelectAreaGameID() then
                            selectBtn(k, data)
                            break
                        elseif k == #areatable then
                            --当循环到最后一个并且没有设置默认选项时（默认设置最后一个）
                            --这边测试到当文件里面已经有了别的游戏的UserDefault数据存储时，会导致设定不了默认选择的游戏，当该游戏只有一个子游戏时就会有bug
                            local index = self.m_AreaBtns[k] ~= nil and k or k-1
                            -- selectBtn(index, areatable[index])
                            selectBtn(1, areatable[1])
                            break
                        end
                    end
                end

            end
        end

        if ddzIdx > 0 then
            -- self:areaVisible(false) -- 直接调用false的话会显示错位, 目前默认就是收缩的, 所以不需要再去设置
            -- 竖版增加一个裁切效果
            self:clipNewerDDZ()
        elseif (type(kLoginInfo:getPlayerInfo().roA) == "number" and kLoginInfo:getPlayerInfo().roA <= 0) then
            self:areaVisible(true)
        end
    end

    --监听升降按钮
    function FriendRoomCreate:liftButton()
        self.m_Button_drop = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_drop");
        self.m_Button_drop:addTouchEventListener(handler(self,self.onClickLiftButton))
        self.m_Button_packup = ccui.Helper:seekWidgetByName(self.m_pWidget, "Button_packup");
        self.m_Button_packup:addTouchEventListener(handler(self,self.onClickLiftButton))

        self.m_PanelTitle = ccui.Helper:seekWidgetByName(self.m_pWidget, "PanelTitle");
        self.m_PanelTitle:addTouchEventListener(handler(self,self.onClickLiftButton))

        self.Label_more = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_more");
        self.Label_packup = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_packup");

        self.Label_more:enableOutline(cc.c4b(0,0,0,255), 2);
        self.Label_packup:enableOutline(cc.c4b(0,0,0,255), 2);
    end
    function FriendRoomCreate:onClickLiftButton(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            -- print(".......")
            if pWidget ~= self.m_PanelTitle then
                pWidget:setVisible(false)
            end

            if (pWidget == self.m_Button_drop) then
                self:areaVisible(true)
            else
                self:areaVisible(false)
            end

            --新增 20171117 start 竖版换皮 点击名称展开  diyal.yin
            self._isAreaListViewShow = not self._isAreaListViewShow

            if (pWidget == self.m_PanelTitle) then
                if self._isAreaListViewShow then
                    self:areaVisible(true)
                else
                    self:areaVisible(false)
                end
            end
            --新增 20171117 end 竖版换皮 diyal.yi
        end
    end
    function FriendRoomCreate:updateListViewonTouch()
        local areatable = self.areaGames
        local count=math.ceil((#areatable-1)/4)
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
    --    Log.i("FriendRoomCreate:updateListViewonTouch.......",listVSize,listICSize)
    end
    --监听点击哪个游戏
    function FriendRoomCreate:onClickAreaButton(data,nIndex)
        -- Log.i("pWidget",data,nIndex)
    --    local areaData = data
        kFriendRoomInfo:setRoomBaseInfo(data)
        self:areaSelectBack()
        --SettingInfo.getInstance():setSelectAreaGameID(btn1.data.gameId)
        self:areaVisible(false)

        local Label_wanfa_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "Label_wanfa_name");
        Label_wanfa_name:setString(data.gameName)
        Label_wanfa_name:setVisible(true)

        -- self._isAreaListViewShow = true
        self._isAreaListViewShow = not self._isAreaListViewShow

    end

    function FriendRoomCreate:doViewLayout()
        local desWanfaHeight = self.pan_content:getContentSize().height
                                -self.panelNorMode:getContentSize().height
                                -self.panelclubMode:getContentSize().height
                                -self.select_game_Panel:getContentSize().height
        if desWanfaHeight > 0 then
            self.panelWanfa:setContentSize(
                self.panelWanfa:getContentSize().width, desWanfaHeight
                )
            if not tolua.isnull(self.entity) then
                local panelWanfaHeight = self.panelWanfa:getContentSize().height
                local entityHeight = self.entity:getContentSize().height
                if panelWanfaHeight > entityHeight then
                    self.scrollViewRuler:setInnerContainerSize(cc.size(self.panelWanfa:getContentSize().width, panelWanfaHeight))
                    self.entity:setPositionY(panelWanfaHeight - entityHeight)
                else
                    self.scrollViewRuler:setInnerContainerSize(cc.size(self.panelWanfa:getContentSize().width, entityHeight))
                    self.entity:setPositionY(0)
                end
            end
            self.pan_content:forceDoLayout()
        end
    end

    -- 设置斗地主指引的底板裁切
    function FriendRoomCreate:clipNewerDDZ()
        local panel_newer_ddz = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_newer_ddz")
        Util.printAllChildren(panel_newer_ddz)
        -- 创建裁切节点
        local clpNode = cc.ClippingNode:create()
        clpNode:setContentSize(panel_newer_ddz:getContentSize())
        clpNode:setAlphaThreshold(0.05)
        clpNode:setInverted(true) -- 显示剩余底板

        -- 底板
        local pan_bg = panel_newer_ddz:getChildByName("pan_bg")
        local bgSize = pan_bg:getContentSize()
        Log.i("pan_bg bgSize", bgSize)
        panel_newer_ddz:removeChild(pan_bg, false)
        clpNode:addChild(pan_bg)

        local pan_tip = panel_newer_ddz:getChildByName("pan_tip")
        -- 位置计算
        local tipSize = pan_tip:getContentSize()
        local btn_sure = pan_tip:getChildByName("btn_sure")
        local btnSize = btn_sure:getCascadeBoundingBox().size
        -- local btnSize = btn_sure:getContentSize()
        -- btnSize.width = btnSize.width * btn_sure:getScaleX()
        -- btnSize.height = btnSize.height * btn_sure:getScaleY()

        local pos = cc.p(btn_sure:getPosition())
        local toPosX = (bgSize.width - tipSize.width) * 0.5 + pos.x
        local toPosY = bgSize.height - tipSize.height + pos.y
        Log.i("toPos", toPosX, toPosY)

        local circle = display.newSolidCircle(btnSize.width * 0.5 + 1, {x = toPosX, y = toPosY, color = cc.c4f(1, 1, 1, 1)})
        clpNode:setStencil(circle)

        clpNode:addTo(panel_newer_ddz, 0)

        -- 创建一个亮的顶部按钮
        local function getCloneBtn(btn)
            local dropClone = btn:clone()
            local Label_more = ccui.Helper:seekWidgetByName(dropClone, "Label_more");
            Label_more:enableOutline(cc.c4b(0,0,0,255), 2);
            dropClone:setPosition(pos)
            local originSize = dropClone:getContentSize()
            dropClone:addTo(pan_tip, 999)
            dropClone:setContentSize(originSize)
            dropClone:setTouchEnabled(false)
            -- dropClone:setSwallowTouches(false)
        end

        getCloneBtn(self.m_Button_drop)
        -- getCloneBtn(self.m_Button_packup)
    end
else
    function FriendRoomCreate:initAreaListView()
        Log.i("FriendRoomCreate:initAreaListView")
        self.areaButtons = {}
        local areatable = kFriendRoomInfo:getAreaBaseInfo()
        local lis_txt = ccui.Helper:seekWidgetByName(self.m_pWidget, "AreaListView");
        local mItem = ccs.GUIReader:getInstance():widgetFromBinaryFile(kResPath.."area_item.csb");
        if #areatable <= 0 then
            print("[ ERROR ] FriendRoomCreate:initAreaListView Data is nil")
            return
        end

        local ddzGuidanceStatus = kSettingInfo.getDDZGuidanceStatus()
        local ddzIdx = 0
        local resortedTab = {}
        for i, v in ipairs(areatable) do
            if v.gameName and v.gameName ~= "" then
                if ddzGuidanceStatus <= 0 and v.gameId == GLOBAL_DEFINE.DDZID then
                    ddzIdx = i
                end
                table.insert(resortedTab, v)
            end
        end
        areatable = resortedTab

        for k,areaData in pairs(areatable) do
            local item = lis_txt:getItem(k-1);
            if item == nil then
                item = mItem:clone();
                lis_txt:pushBackCustomItem(item);
                local Label_nor = ccui.Helper:seekWidgetByName(item, "Label_nor");
                local Label_select = ccui.Helper:seekWidgetByName(item, "Label_select");

                local tmpName = Util.cutMjName(areaData.gameName)
                -- 请在config.lua中添加GC_GameName
                Label_nor:setString(tmpName or GC_GameName)
                Label_select:setString(tmpName or GC_GameName)
                Label_select:setVisible(false)
                local areaButton = ccui.Helper:seekWidgetByName(item, "AreaButton");
                areaButton:addTouchEventListener(handler(self, self.areaButtonBack));
                areaButton.norLabel = Label_nor
                areaButton.selectLabel = Label_select
                areaButton.data = areaData
                areaButton:setTag(areaData.gameId)
                areaButton.item = item
                areaButton.selectBgs = {ccui.Helper:seekWidgetByName(item, "img_select"), ccui.Helper:seekWidgetByName(item, "img_unselect")}
                --Label_nor:setOpacity(128)
                if string.len(Label_nor:getString()) > 15 then
                    Label_nor:setFontSize(30)
                    Label_select:setFontSize(30)
                else
                    Label_nor:setFontSize(40)
                    Label_select:setFontSize(40)
                end
                table.insert(self.areaButtons, areaButton)

                if areaData.gameId == GLOBAL_DEFINE.DDZID then
                    self:showNewArea(areaButton)
                end
            end
        end
        --设置默认选中按钮
        if #self.areaButtons > 0 then
            local selectedBtn = self.areaButtons[1]
            if ddzIdx > 0 then
                -- 显示斗地主提示
                Log.i("Hint DDZ Guidance!!!")
                selectedBtn = self.areaButtons[ddzIdx]
                self:showNewerDDZ()
            else
                for i,btn in ipairs(self.areaButtons) do
                    if btn.data.gameId ==  SettingInfo.getInstance():getSelectAreaGameID() then
                        selectedBtn = btn
                    end
                end
            end
            selectedBtn.selectBgs[1]:setVisible(true)
            selectedBtn.selectBgs[2]:setVisible(false)
            self.areatBtn = selectedBtn
            kFriendRoomInfo:setRoomBaseInfo(selectedBtn.data)
            selectedBtn.selectLabel:setVisible(true)
            selectedBtn.norLabel:setVisible(false)

            --listview初始化位置调整到当前选择的项目
            lis_txt:doLayout()
            local innerHeight = lis_txt:getInnerContainerSize().height
            local contentHeight = lis_txt:getContentSize().height
            if innerHeight > contentHeight then
                local idx = lis_txt:getIndex(selectedBtn.item)
                if idx >= 4 then
                    local itemPosY = innerHeight-(selectedBtn.item:getContentSize().height+lis_txt:getItemsMargin())*(idx-0.5)
                    local desY = contentHeight - itemPosY
                    if desY < 0 then
                        lis_txt:getInnerContainer():setPositionY(desY)
                    else
                        lis_txt:getInnerContainer():setPositionY(0)
                    end
                end
            end
        end
    end

    function FriendRoomCreate:areaButtonBack(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            for k,v in pairs(self.areaButtons) do
                if v == pWidget then
                    self.areatBtn = v
                    kFriendRoomInfo:setRoomBaseInfo(v.data)
                    self:areaSelectBack()
                    --SettingInfo.getInstance():setSelectAreaGameID(v.data.gameId)
                    v.selectBgs[1]:setVisible(true)
                    v.selectBgs[2]:setVisible(false)
                    v.norLabel:setVisible(false)
                    v.selectLabel:setVisible(true)
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

--设置游戏选择项是否可见
function FriendRoomCreate:areaVisible(b)
    self.m_Button_drop:setVisible(not b)
    self.m_Button_packup:setVisible(b)

    local areatable, count
    if IsPortrait then -- TODO
        areatable = self.areaGames
        -- print ("========>>>>>>>>>areaVisible" .. tostring(#areatable))
        count = math.floor((#areatable-1)/4) + 1
    else
        areatable = kFriendRoomInfo:getAreaBaseInfo()
        count = math.ceil((#areatable-1)/4)
    end
    if b then
        local height=count* kWidgets.areaHeight >self.pan_content:getContentSize().height*0.5 and self.pan_content:getContentSize().height*0.5 or count* kWidgets.areaHeight
        self.select_game_Panel:setContentSize(cc.size( self.select_game_Panel:getContentSize().width,height))
        self.list_view_select:setContentSize(self.select_game_Panel:getContentSize())
        self.select_game_Panel:getLayoutParameter():setMargin({ left = 0, right = 0, top = -self.select_game_Panel:getContentSize().height, bottom = 0})
        self.pan_content:getLayoutParameter():setMargin({ left = 0, right = 0, top = self.list_view_select:getContentSize().height+90, bottom = 0})
        self.pan_content:setPositionY(-(self.list_view_select:getContentSize().height-151))
        if not self:isClubMode() then
            self.panelNorMode:getLayoutParameter():setMargin({top = 0})
            if Util.debug_shield_value("club") then
                self.panelWanfa:getLayoutParameter():setMargin{top = 0}
            else
                self.panelWanfa:getLayoutParameter():setMargin{top = self.panelNorMode:getContentSize().height}
            end
        else
            if IsPortrait then -- TODO
                self.panelclubMode:getLayoutParameter():setMargin({top = clubPanelOffest_y})
                self.panelWanfa:getLayoutParameter():setMargin{top = self.panelclubMode:getContentSize().height + clubPanelOffest_y}
            else
                self.panelclubMode:getLayoutParameter():setMargin({top = 0})
                self.panelWanfa:getLayoutParameter():setMargin{top = self.panelclubMode:getContentSize().height}
            end
        end
    else
        if IsPortrait then -- TODO
            self.select_game_Panel:setContentSize(cc.size( self.select_game_Panel:getContentSize().width,0))
            self.pan_content:getLayoutParameter():setMargin({ left = 0, right = 0, top = 51, bottom = 0})
            self.pan_content:setPositionY(151)
        end
    end

    if IsPortrait then -- TODO
        self:doViewLayout()

        if b and count* kWidgets.areaHeight >self.pan_content:getContentSize().height*0.5 then
            local data = {
                parent = self.select_game_Panel;                   --父节点
                bgSprite = "hall/huanpi2/Common/select_wight.png";                  --背景层资源
                scrollSprite = "hall/huanpi2/Common/scroll_bar.png";              --滚动块资源
                bgSize = cc.size(1,self.pan_content:getContentSize().height*0.5);          --背景大小
            }
            self.scrollBar = ClientScrollBar.new(data)
            local sgpSize = self.select_game_Panel:getContentSize()
            self.scrollBar:setPosition(cc.p(sgpSize.width,data.bgSize.height/2))
        end
    end
end

function FriendRoomCreate:setFontSize(areaButton,label,value,fontSize)
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

--[[
--选中的按钮 self.areatBtn  里面的游戏数据存储在亲友 data当中
--也可以通过  kFriendRoomInfo:getRoomBaseInfo()  来直接获取
]]
function FriendRoomCreate:areaSelectBack()
    local gameId = kFriendRoomInfo:getGameID()
    local viewLayoutCallBack = function(size)
        if IsPortrait then -- TODO
            self:doViewLayout()
        else
            if not tolua.isnull(self.scrollViewRuler) then
                self.scrollViewRuler:setInnerContainerSize(size)
            end
        end
    end
    self.scrollViewRuler:removeAllChildren()
    if GC_GameTypes[gameId] then
        -- loadGame(gameId)
        local tmpPath = "package_src.games." .. GC_GameTypes[gameId] .. ".hall.GameRoomInfoUI_" .. GC_GameTypes[gameId]
        --跑的快特殊处理
        if GC_GameTypes[gameId] == "pdkpk" then
            tmpPath = "package_src.games." .."paodekuai.".. GC_GameTypes[gameId] .. ".hall.GameRoomInfoUI_" .. GC_GameTypes[gameId]
        elseif GC_GameTypes[gameId] == "gdpk" then
            tmpPath = "package_src.games." .."guandan.".. GC_GameTypes[gameId] .. ".hall.GameRoomInfoUI_" .. GC_GameTypes[gameId]
        end
        Log.i("--wangzhi--tmpPath--",tmpPath)
        local cls = import(tmpPath, kCurrentModule)
        if nil == cls then
            print("FriendRoomCreate:areaSelectBack 创建UI失败")
            return
        end
        local bgSize = self.scrollViewRuler:getContentSize()
        self.entity = cls.new(bgSize, kFriendRoomInfo:getRoomBaseInfo(),self.m_data.clubInfo, self:isClubMode() and enFriendRoomMode.Club or enFriendRoomMode.Normal, gameId, viewLayoutCallBack)
        self.scrollViewRuler:removeAllChildren()
        self.scrollViewRuler:addChild(self.entity)
        self.scrollViewRuler:jumpToTop()
        viewLayoutCallBack(self.entity:getContentSize())
    else
        Toast.getInstance():show("GC_GameTypes中尚未添加该游戏" .. gameId);
    end
end


-- 发送创建房间消息
function FriendRoomCreate:createRoom()
    if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
        Toast.getInstance():show("服务器即将进行维护! ")
        return
    end
    if not self.entity then return end
    local tmpData = self.entity:getData()
    if not tmpData then
        Log.e("friendRoomCreate:createRoom data nil")
        return
    end
    local isFree = kServerInfo:isFreeActivityOpen()
    local diamond = kUserInfo:getPrivateRoomDiamond() < tonumber(tmpData.RoFS)
    local person = kUserInfo:getPrivateRoomDiamond() < math.ceil(tmpData.RoFS / tmpData.plS)
    if not isFree and not self:isClubMode() then
        local function showTip()
            local data = {}
            data.type = 1;
            local tips = kSystemConfig:getDataByKe("config_noDiamondTips")
            local content = _NoDiamondTips
            if tips and tips.va then
                content = tips.va
            end
            data.content = content; --kServerInfo:getRechargeInfo();
            UIManager.getInstance():pushWnd(CommonDialog, data);
        end
        if tmpData.RoJST == 1 and diamond then  -- RoJST int   付费类型 1 =房主付费，2 =大赢家付费，3 =AA付费
            if IS_YINGYONGBAO then
                Toast.getInstance():show("创建房间失败")
                return
            end
            showTip()
            return
        elseif tmpData.RoJST == 2 and diamond then
            showTip()
            return
        elseif tmpData.RoJST == 3 and person then
            showTip()
            return
        end
    end

    if self:isClubMode() then
        tmpData.clI = self.m_data.clubInfo.clubID
    end
    FriendRoomSocketProcesser.sendRoomCreate(tmpData)
    LoadingView.getInstance():show("正在创建房间,请稍后...");
    NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.CreateRoomButton)
end

function FriendRoomCreate:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if IsPortrait then -- TODO
            SoundManager.playEffect("btn");
        end
        if pWidget == self.cancleBtn then
            if self.m_pan_newer and self.m_pan_newer:isVisible() then
                return;
            end

           UIManager:getInstance():popWnd(FriendRoomCreate);

        elseif pWidget == self.btn_sure then
            local state = kFriendRoomInfo:getRoomState()
            if state == CreateRoomState.clubmodel or state == CreateRoomState.resetmodel then
                self:createClubModel()
            else
                self:createRoom()
            end
        elseif pWidget == self.btn_switchClubMode or pWidget == self.btn_switchClub then
            LoadingView.getInstance():show("正在获取亲友圈信息,请稍后...");
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_JOINEDCLUBLIST)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.CreateClubButton)
        elseif pWidget == self.btn_switchNormalMode then
            self:switchNormalMode()
        end
    end
end

-- 创建俱乐部房间模版
function FriendRoomCreate:createClubModel()
    self.modelData = self.entity:getData()
    local state = kFriendRoomInfo:getRoomState()
    if state == CreateRoomState.resetmodel and kFriendRoomInfo:getClubModel().gaI then -- 重置模版状态
        self.modelData.id = kFriendRoomInfo:getClubModel().id -- 有模板id表示修改
        LoadingView.getInstance():show("模版重置中...");
    else
        LoadingView.getInstance():show("模版创建中...");
    end
    Log.i("-------------createClubModel2 ：", self.modelData,state,#kFriendRoomInfo:getClubModel())
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_CREATECLUBMODEL,self.modelData)
end

function FriendRoomCreate:switchNormalMode()
    if self.m_data.clubInfo ~= nil then
        self.m_data.clubInfo = nil
        self:refreshUIInfo()
        self:areaSelectBack()
    end
end

function FriendRoomCreate:switchClubMode(clubInfo)
    self.m_data.clubInfo = clubInfo
    self:refreshUIInfo()
    self:areaSelectBack()
end
--新手
function FriendRoomCreate:showNewer()
    if not self.m_pan_newer then
        self.m_pan_newer = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_newer");
        self.btn_newer_over = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_over");
        if self.m_NewerType == 1 then
            self.btn_newer_over:setVisible(false);
        end
        --self.btn_newer_enter = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn");
        self.btn_newer_over:addTouchEventListener(handler(self,self.onClickButtonNewer));
        --self.btn_newer_enter:addTouchEventListener(handler(self,self.onClickButtonNewer));
        self.btn_newer_over = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_over");
        --手指动画
        local img_point = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_point");
        img_point:stopAllActions();
        local sequence = transition.sequence({
                     cc.MoveBy:create(0.3, cc.p(15, 0)),
                     cc.MoveBy:create(0.3, cc.p(-15, 0))
        });
        img_point:runAction(cc.RepeatForever:create(sequence));
    end
    self.m_pan_newer:setVisible(true);
end

--斗地主新手引导
function FriendRoomCreate:showNewerDDZ()
    SettingInfo:setDDZGuidanceStatus(1)
    local panel_newer_ddz = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_newer_ddz");
    local btn_sure = ccui.Helper:seekWidgetByName(panel_newer_ddz, "btn_sure");
    btn_sure:addTouchEventListener(function(pWidget, EventType)
        if EventType == ccui.TouchEventType.ended then
            SoundManager.playEffect("btn");
            panel_newer_ddz:setVisible(false);
            if IsPortrait then -- TODO
                self:areaVisible(true)
            end
        end
    end);
    panel_newer_ddz:setVisible(true);
    if PRODUCT_ID == 4444 then
        local ddzTip = ccui.Helper:seekWidgetByName(panel_newer_ddz, "text_tip_ddz");
        ddzTip:loadTexture("package_res/games/guandan/image/text_tip_ddz.png")
    end
end


-- 在btn上显示"新"字提示
function FriendRoomCreate:showNewArea(selectedBtn)
    local newArea = display.newSprite("hall/friendRoom/ddz/img_new_area.png", 200, 66)
    if IsPortrait then -- TODO
        newArea = display.newSprite("hall/friendRoom/ddz/img_new_area.png", 150, 60)
    end
    newArea:addTo(selectedBtn)
end

function FriendRoomCreate:onClickButtonNewer(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_newer_over then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
                self.m_NewerType = nil;
                self:keyBack();
            end
        end
    end
end


function FriendRoomCreate:keyBack()
    if self.m_pan_newer and self.m_pan_newer:isVisible() then
        return;
    end
    UIManager.getInstance():popWnd(self);
end


--[[
-- @brief  复选框按钮
-- @param  void
-- @return void
--]]
function FriendRoomCreate:onCheckBoxBtn(obj, event)

    if event == ccui.CheckBoxEventType.selected then

    end
end

function FriendRoomCreate:recvRoomSceneInfo(packetInfo)
    Log.i("FriendRoomCreate:recvRoomSceneInfo 获取邀请房信息------")
    Log.i("packetInfo", packetInfo)
    LoadingView.getInstance():hide();
    -- 保存房间号, 便于再次加入(该功能是否需要?)
    if device.platform == "windows" or device.platform == "mac" then
        cc.UserDefault:getInstance():setStringForKey("roomNumberKey", packetInfo.roI)
    end
    UIManager:getInstance():popWnd(FriendRoomCreate);
    local data = {};
    data.newerType = self.m_NewerType;
    self.m_NewerType = nil;
    loadGame( kFriendRoomInfo:getGameID() )
    UIManager:getInstance():pushWnd(FriendRoomScene, data);
    -- UIManager:getInstance():pushWnd(FriendRoomEnterInfo);
    -- kGameManager:enterFriendRoomGame(packetInfo);
end


function FriendRoomCreate:recvRoomCreate(packetInfo)
    ------##  re  int  结果（-1 =钻石不足，-2 = 无可用房间，1 成功）
    if IsPortrait then -- TODO
        LoadingView.getInstance():hide();
    end
    local tmpData= packetInfo
    if(-1 == tmpData.re) then
        if IsPortrait then -- TODO
            if IS_YINGYONGBAO then
                Toast.getInstance():show("创建失败");
            else
                Toast.getInstance():show("您的钻石不足,请充值!");
            end
        else
            Toast.getInstance():show("您的钻石不足,请充值!");
        end
    elseif(-2 == tmpData.re) then
        Toast.getInstance():show("无可用房间!");
    elseif(-5 == tmpData.re) then
        Toast.getInstance():show("服务器即将进行维护!");
    elseif(1==tmpData.re) then
        Log.i("等待获取房间信息才能进入房间。。。。。")
    elseif (-6 == tmpData.re) then
        local data = {}
        data.type = 2;
        data.title = "提示";
        data.yesStr = "确定"
        data.cancalStr = "联系客服"
        data.content = "请联系客服";
        data.yesCallback = function()
            -- MyAppInstance:exit()
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        end
        data.closeCallback = function ()
            self:onOpenKf()
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
        LoadingView.getInstance():hide()
    end
end

function FriendRoomCreate:onOpenKf()
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = {count = 0}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    local data = {};
    data.cmd = NativeCall.CMD_KE_FU;
    data.uid, data.uname = self.getKfUserInfo()
    NativeCall.getInstance():callNative(data, self.openKeFuCallBack, self);
end

function FriendRoomCreate:getKfUserInfo()
    local uid = kUserInfo:getUserId();
    local uname = kUserInfo:getUserName();
    if uid == 0 then
        local lastAccount = kLoginInfo:getLastAccount();
        if lastAccount and lastAccount.usi then
            uid = lastAccount.usi
        end
    end

    if uname == "" or uname == nil then
        if uid == nil or uid == 0 then
            uname = "游客"
        else
            uname = "游客"..uid
        end
    end

    --此时uid需要传入字符串类型.否则ios那边解析会出问题.
    return ""..uid, uname
end

function FriendRoomCreate:recvJoinedClubList()
    LoadingView.getInstance():hide()
    local ClubSwitchCreateRoomWnd = require("app.hall.wnds.club.clubSwitchCreateRoomWnd")
    local myClubsInfo = kSystemConfig:getMyClubsInfo()
    if #myClubsInfo > 0 then
        UIManager:getInstance():pushWnd(ClubSwitchCreateRoomWnd, myClubsInfo, self:isClubMode() and self.m_data.clubInfo.clubID or nil);
    else
        Toast.getInstance():show("您尚未加入亲友圈!");
    end
end

-- 创建俱乐部房间模版返回
function FriendRoomCreate:recCreateClubModel(data)
    Log.i("recCreateClubModel : " , data)
    if data.re == 0 then -- 成功
        LoadingView.getInstance():hide();
        if _isChooseServerForTest then
            Toast.getInstance():show("俱乐部模版创建成功!");
        end
        local event = cc.EventCustom:new(LocalEvent.CreateClubModel)
        self.modelData.id = data.id
        event._userdata = self.modelData
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
        self:keyBack()
    elseif data.re == 1 then -- 无权限操作
        Toast.getInstance():show("无权限操作!");
    elseif data.re == 2 then -- 模版已满
        Toast.getInstance():show("模版已满!");
    elseif data.re == 3 then -- 编辑不存在的模版
        Toast.getInstance():show("编辑不存在的模版!");
    elseif data.re == 4 then -- 账号异常
        Toast.getInstance():show("账号异常!");
    else                     -- 其他
        Toast.getInstance():show("系统发生异常，请联系客服!");
    end
end

FriendRoomCreate.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_FRIEND_ROOM_CREATE] = FriendRoomCreate.recvRoomCreate;  --InviteRoomCreate   创建邀请房结果
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO] = FriendRoomCreate.recvRoomSceneInfo; --InviteRoomInfo    邀请房信息

    [HallSocketCmd.CODE_REC_QUERYCLUBINFO]      = FriendRoomCreate.recvJoinedClubList;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]     = FriendRoomCreate.recvJoinedClubList;
    [HallSocketCmd.CODE_REC_CREATECLUBMODEL]     = FriendRoomCreate.recCreateClubModel;
};

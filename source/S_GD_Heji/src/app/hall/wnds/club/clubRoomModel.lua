-----------------------------------------------------------
--  @file   clubRoomModel.lua
--  @brief  俱乐部房间模版
--  @author linxiancheng
--  @DateTime:2018-10-10 10:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================


local clubRoomModel = class("clubRoomModel", UIWndBase)
local clubRoomModelProcesser = require("app.hall.wnds.club.clubRoomModelProcesser")
local LocalEvent = require("app.hall.common.LocalEvent")
function clubRoomModel:ctor(...)
    self.super.ctor(self,"hall/roommodel.csb",...)
    self.m_SocketProcesser = clubRoomModelProcesser .new(self)
    SocketManager.getInstance():addSocketProcesser(self.m_SocketProcesser)
end

function clubRoomModel:onClose()
    self:removeListen()   -- 没有删除监听会出现野指针异常bug报错
end

-- 添加事件监听
function clubRoomModel:initEventListen()
    self.Events = {}
    local listenBindState = cc.EventListenerCustom:create(LocalEvent.CreateClubModel,function(event)
        Log.i("==================== clubRoomModel2 :" , event._userdata)
        if not self.m_data.teL then self.m_data.teL = {} end
        for k,data in pairs(self.m_data.teL) do  -- 删除已经存在相同id的模版(编辑模版的情况)
            if data.id == event._userdata.id then
                self.m_data.teL[k] = event._userdata   -- 如果已经存在则表示修改，不改变原来的模版位置
                self:initList()
                return
                -- table.remove(self.m_data.teL,k)
            end
        end
        table.insert(self.m_data.teL , event._userdata)
        self:initList()-- 刷新模版列表
    end)
    table.insert(self.Events, listenBindState);
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenBindState , 1);
end

-- 移除事件监听
function clubRoomModel:removeListen()
    table.walk(self.Events , function(event)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
    end)
    self.Events = {}
end

function clubRoomModel:onInit()
    local btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    btn_close:addTouchEventListener(function (pWidget, EventType)
                    if EventType == ccui.TouchEventType.ended then
                        self:keyBack()
                        local data = kSystemConfig:getOwnerClubInfo();
                        if kSystemConfig:IsClubOwner() and next(data) then
                            local ClubRoomListWnd = require("app.hall.wnds.club.clubRoomListWnd")
                            UIManager.getInstance():pushWnd(ClubRoomListWnd, data, true)
                        end
                    end
                end)
    -- Log.i(" childsName : " , self.m_pWidget:getChildren())

    -- 房间模版
    self.model = ccui.Helper:seekWidgetByName(self.m_pWidget , "pan_model")
    self.model:setVisible(false)
    -- 创建房间模版
    self.roommodel = ccui.Helper:seekWidgetByName(self.m_pWidget , "roommode")
    -- 背景界面
    self.bg_mag = ccui.Helper:seekWidgetByName(self.m_pWidget , "bg_mag")
    -- 模版容器
    self.list_rooms = ccui.Helper:seekWidgetByName(self.m_pWidget , "list_rooms")
    self.img_down = ccui.Helper:seekWidgetByName(self.m_pWidget , "img_down")
    self.img_up = ccui.Helper:seekWidgetByName(self.m_pWidget , "img_up")
    -- cc.Place:create(cc.p(x, y))
    local move1 = cc.MoveBy:create(0.5,cc.p(0,15))
    local move2 = cc.MoveBy:create(0.5,cc.p(0,-15))
    self.img_up:runAction(cc.RepeatForever:create(cc.Sequence:create(move1:clone(),cca.fadeOut(0.2),move2:clone(),cca.fadeIn(0.1))))
    self.img_down:runAction(cc.RepeatForever:create(cc.Sequence:create(move2:clone(),cca.fadeOut(0.2),move1:clone(),cca.fadeIn(0.1))))

    local first = true
    self.list_rooms:addScrollViewEventListener(
    function(pListWidget, pEventType)
        if #self.m_data.teL <= 4 then
            self.img_down:setVisible(false)
            self.img_up:setVisible(false)
            return
        end   -- 4个item不显示箭头
        if pEventType == ccui.ScrollviewEventType.scrollToBottom then
            -- print("clubRoomModel scrollToBottom")
             self.img_down:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.bounceBottom then
            -- print("clubRoomModel bounceBottom")
             self.img_down:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.scrolling then
            if first then
                first = false
                self.img_up:setVisible(false)
                if #self.m_data.teL <= 4 then
                    self.img_down:setVisible(false)
                else
                    self.img_down:setVisible(true)
                end
                return
            end
            self.img_down:setVisible(true)
            self.img_up:setVisible(true)
        elseif pEventType == ccui.ScrollviewEventType.scrollToTop then
            -- print("clubRoomModel scrollToTop")
            self.img_up:setVisible(false)
        elseif pEventType == ccui.ScrollviewEventType.bounceTop then
            self.img_up:setVisible(false)
            -- print("clubRoomModel bounceTop")
        end
    end)

    self.list_rooms:setItemModel(self.model:clone():setVisible(true))

    self.lab_num = ccui.Helper:seekWidgetByName(self.m_pWidget , "lab_num")

    -- 提示界面
    self.pan_tip = ccui.Helper:seekWidgetByName(self.m_pWidget , "pan_tip")

    local btn_sure = ccui.Helper:seekWidgetByName(self.pan_tip,"btn_sure")
    btn_sure:addTouchEventListener(function (pWidget, EventType)
                    if EventType == ccui.TouchEventType.ended then
                        if IsPortrait then
                            self:keyBack()
                        else
                            self.pan_tip:setVisible(false)
                        end
                    end
                end)

    Log.i("-------club models : " , self.m_data)

    self:initEventListen()

    if not IsPortrait then
        local btn_whatmodel = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_whatmodel")
        btn_whatmodel:addTouchEventListener(function (pWidget, EventType)
                        if EventType == ccui.TouchEventType.ended then
                            self.pan_tip:setVisible(true)
                            -- self.bg_mag:setVisible(false)
                        end
                    end)
    end

    if self.m_data.showtips then
        self.pan_tip:setVisible(true)
        self.bg_mag:setVisible(false)
    else
        self:initList()
    end
end

function clubRoomModel:addMaJiangRule(content,btn)
    if not content or content == ""then
        return
    end
    if self.mjRuleTips then
        self.mjRuleTips:removeFromParent()
        self.mjRuleTips = nil
    end
    self.mjRuleTips = ccs.GUIReader:getInstance():widgetFromBinaryFile("hall/mjRuleTips.csb")
    self.mjRuleTips:addTouchEventListener(function(obj,event)
        if event == ccui.TouchEventType.ended then
            self.mjRuleTips:setVisible(false)
            self.mjRuleTips:removeAllChildren()
            self.mjRuleTips = nil
        end
    end)
    self.m_pWidget:addChild(self.mjRuleTips,10)
    self.mjRuleTips:setAnchorPoint(cc.p(0,1))
    rule_lable = ccui.Helper:seekWidgetByName(self.mjRuleTips, "rule_lable")
    rule_lable:setString("")
    bg_img = ccui.Helper:seekWidgetByName(self.mjRuleTips, "bg_img")
    local pos_x,pos_y = btn:getPosition()
    local parentPos_Y = btn:getParent():getPositionY()
    local listPosY = self.list_rooms:getContentSize().height--setMargin
    local world_pos = btn:getParent():convertToWorldSpace(cc.p(pos_x,pos_y))
    local content_txt = ccui.Text:create();
    content_txt:setFontName("res_TTF/1016001.TTF")
    content_txt:setColor(cc.c3b(255,255,255))
    content_txt:setTextAreaSize(cc.size(330, 0));
    content_txt:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    content_txt:setString(content);
    content_txt:setFontSize(26);
    content_txt:ignoreContentAdaptWithSize(false)
    local visibleWidth = cc.Director:getInstance():getOpenGLView():getFrameSize().width
    local visibleHeight = cc.Director:getInstance():getOpenGLView():getFrameSize().height

    if visibleHeight/visibleWidth >= 1.78 then
        world_pos.y = world_pos.y - 1280*(visibleHeight/visibleWidth - 1.78)/2 - 50
    end

    local tab_size = content_txt:getContentSize()
    bg_img:setContentSize(cc.size(tab_size.width + 20, tab_size.height + 20))
    local size = bg_img:getContentSize()
    bg_img:setPosition(cc.p(world_pos.x - size.width/2 - 10, world_pos.y + 30))
    content_txt:setPosition(cc.p(size.width/2,size.height/2))
    bg_img:addChild(content_txt)
end

-- 根据数据初始化模版列表，这个数据应该从上层的界面传过来
-- 数据的格式应该是跟房间列表类似的数据。主要是用于显示规则信息
function clubRoomModel:initList()
    self.list_rooms:removeAllChildren()
    Log.i("=================== clubRoomModel : " , self.m_data)
    self.lab_num:setString(string.format(" 当前俱乐部房间模版数量：%s/%s" , #self.m_data.teL , self.m_data.clRTN))
    for _,data in pairs(self.m_data.teL) do
        self.list_rooms:pushBackDefaultItem()
        local lay = self.list_rooms:getItem(#self.list_rooms:getItems() - 1)
        lay.data = data  -- 存储模版数据
        local btn_deletemodel = ccui.Helper:seekWidgetByName(lay , "btn_deletemodel")
        btn_deletemodel:addTouchEventListener(function(obj,event)
            if event == ccui.TouchEventType.ended then
                local data1 = {}
                data1.type = 2
                data1.content = "确定删除当前模版？"
                data1.yesCallback = function()
                    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_DELETECLUBMODEL,{id = data.id})
                end
                UIManager:getInstance():pushWnd(CommonDialog, data1)
            end
        end)
        -- 重置模版内容
        local btn_rewirte = ccui.Helper:seekWidgetByName(lay , "btn_rewirte")
        btn_rewirte:addTouchEventListener(function(obj,event)
            if event == ccui.TouchEventType.ended then
                kFriendRoomInfo:setRoomState(CreateRoomState.resetmodel)
                kFriendRoomInfo:setClubModel(data)
                local data2 = {}
                data2.clubInfo = self.m_data.clubInfo
                UIManager:getInstance():pushWnd(FriendRoomCreate , data2);
            end
        end)

        local btn_mj_rule = ccui.Helper:seekWidgetByName(lay , "btn_mj_rule")
        btn_mj_rule:addTouchEventListener(function(obj,event)
            if event == ccui.TouchEventType.ended then
                local wfList = kFriendRoomInfo:formatWafaData(data.ru or data.wa, data.gaI)
                -- Log.i("================>>>formatWafaData", data.ru)
                local wfStr = ""
                if #wfList > 0 then
                    for len = 1, #wfList-1, 1 do
                        wfStr = wfStr..wfList[len]..","
                    end
                    wfStr = wfStr..wfList[#wfList]
                else
                    wfStr = "当前房主未自定义玩法"
                end
                self:addMaJiangRule(wfStr,btn_mj_rule)  -- 显示模版规则信息
            end
        end)

        self:initItemInfo(lay, data)
    end
    -- or not kSystemConfig:IsClubOwner()
    if #self.list_rooms:getItems() > (self.m_data.clRTN - 1)  then
        return
    end
    -- 如果模版数量超过3个，则不显示这个面板了
    local item = self.roommodel:clone()
    local btn_roommodel = ccui.Helper:seekWidgetByName(item  , "btn_roommodel")
    btn_roommodel:addTouchEventListener(function(obj,event)
        if event == ccui.TouchEventType.ended then
            kFriendRoomInfo:setRoomState(CreateRoomState.clubmodel)
            local data2 = {}
            data2.clubInfo = self.m_data.clubInfo
            UIManager:getInstance():pushWnd(FriendRoomCreate, data2);
        end
    end)
    item:setVisible(true)
    self.list_rooms:pushBackCustomItem(item);
end

-- 初始化房间模版显示信息
function clubRoomModel:initItemInfo(item , data)
    local mjDescMap = kFriendRoomInfo:getMjDescInfoMap()
    local lab_roomInfo = ccui.Helper:seekWidgetByName(item , "lab_roomInfo")
    local lab_roundNum = ccui.Helper:seekWidgetByName(item , "lab_roundNum")
    local lab_modelindex = ccui.Helper:seekWidgetByName(item , "lab_modelindex")
    lab_roundNum:setString(string.format("共%s局" , data.roS))
    if data.gaI == 20011 then--掼蛋升级场特殊处理
        local waData = data.ru or data.wa
        if string.find(waData,"|shengji") then
            if tonumber(data.roS) == 4 or tonumber(data.roS) == 40 then
                lab_roundNum:setString("过6")
            elseif tonumber(data.roS) == 8 or tonumber(data.roS) == 80 then
                lab_roundNum:setString("过10")
            elseif tonumber(data.roS) == 12 or tonumber(data.roS) == 120 then
                lab_roundNum:setString("过A")
            end
            lab_roundNum:setVisible(true)
        end
    end
    lab_modelindex:setString(string.format("房间模版 %s" , #self.list_rooms:getItems()))
    lab_roomInfo:setString(string.format("%s(%s人房)", mjDescMap[data.gaI].gameName,data.plS))
end

function clubRoomModel:refreshModels(data)
    Log.i("------------------ refreshModels " , data)
    for k,v in pairs(self.m_data.teL) do
        if v.id == data.id then
            table.remove(self.m_data.teL , k)
        end
    end
    self:initList()
end

--网络接收接口定义
clubRoomModel.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_REC_DELETECLUBMODEL] = clubRoomModel.refreshModels;
}


return clubRoomModel

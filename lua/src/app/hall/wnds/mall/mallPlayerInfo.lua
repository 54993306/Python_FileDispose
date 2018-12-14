-----------------------------------------------------------
--  @file   MallPlayerInfo.lua
--  @brief  兑换信息面板
--  @author linxiancheng
--  @DateTime:2017-06-8 17:22:30
--  Version: 1.0.0
--  Company  SteveSoft LLC.
--  Copyright  Copyright (c) 2017
-- ============================================================

local MallPlayerInfo = class("MallPlayerInfo",UIWndBase)

function MallPlayerInfo:ctor()
    self.super.ctor(self,"hall/mall_playerinfo.csb")
end

function MallPlayerInfo:onInit()
    self.btn_close = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_close")
    self.btn_close:addTouchEventListener(handler(self,self.btnCallBack))

    self.btn_submit = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_submit")
    self.btn_submit:addTouchEventListener(handler(self,self.btnCallBack))

    self.tex_name       = self:getWidget(self.m_pWidget, "tex_name");
    self.tex_address    = self:getWidget(self.m_pWidget, "tex_address");
    self.tex_mail       = self:getWidget(self.m_pWidget, "tex_mail");

    self.tex_phone      = self:getWidget(self.m_pWidget, "tex_phone");
    if self.tex_phone.setInputMode then 
        self.tex_phone:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) 
    end
end

function MallPlayerInfo:btnCallBack(pwidget,touchType)
    if touchType == ccui.TouchEventType.ended then
        if pwidget:getName() == "btn_close" then
            self:keyBack();
        elseif pwidget == self.btn_submit then
            self:Submit()
        end
    end
end

function MallPlayerInfo:Submit()
    local data = {}
    self:infoInit(data)   
    local right = self:infoJudge(data)
    if not right then
        return 
    end
    local _data = {}
    _data.type = 2;
    _data.content = "个人资料填写完毕，是否确认提交？"
    _data.tipsLab = "*我们将以您提供的信息为准，请您再三检查。如果信息错误，可能导致您无法收到物品"
    _data.tipsSize = 20
    _data.tipsLabColor = cc.c3b(255, 0, 0)
    _data.tipsIncise = 25
    _data.offsetY = 40
    _data.yesCallback = function()
        self:sendInfo(data);
    end
    UIManager.getInstance():pushWnd(CommonDialog, _data);
end

--  type = 7,code=70007, 填写收货地址  Client<->Activity
-- ##  na  String  姓名
-- ##  ad  String  住址
-- ##  ph  String  电话
-- ##  em  String  email
-- ##  re  int  结果(0:操作成功  非0:失败)
function MallPlayerInfo:sendInfo(data)
    LoadingView.getInstance():show("信息发送中...")
    local sendData = {};
    sendData.na = data.name;
    sendData.ad  = data.address;
    sendData.ph  = data.phone;
    sendData.em  = data.mail;
    SocketManager.getInstance():send(CODE_TYPE_MALL,HallSocketCmd.CODE_REC_MALLADD,sendData)
    self:keyBack();
end

function MallPlayerInfo:infoInit(data)
    data.name       = self.tex_name:getText();
    data.address    = self.tex_address:getText();
    data.phone      = self.tex_phone:getText(); 
    data.mail       = self.tex_mail:getText();
end

local function getTextSize(inputstr)
   local lenInByte = #inputstr
   local width = 0
   local i = 1
    while (i<=lenInByte)
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        end
        local char = string.sub(inputstr, i, i+byteCount-1)
        print(char)                                                     --看看这个字是什么
        i = i + byteCount                                               -- 重置下一字节的索引
        width = width + 1                                               -- 字符的个数（长度）
    end
    return width
end

--单独去显示错误信息，不要统一显示,例如提示姓名未输入
function MallPlayerInfo:infoJudge(data)
    if  not data.name       
        or  data.name == "" then
        Toast.getInstance():show("请输入姓名");
    elseif getTextSize(data.name) < 2 then       -- 名字最少为两个字符
        Toast.getInstance():show("请输入正确的姓名");      
    elseif not data.address  
            or data.address == "" then
        Toast.getInstance():show("请输入联系地址");
    elseif getTextSize(data.address) < 7 then    -- 地址最少为7个字符
        Toast.getInstance():show("请输入正确的地址");
    elseif not data.phone  
            or data.phone == "" then
        Toast.getInstance():show("请输入联系电话");
    elseif getTextSize(data.phone) < 7 then      -- 电话最少为7个字符
        Toast.getInstance():show("请输入正确的联系电话");
    else
        return true
    end
    return false
end

return MallPlayerInfo
--个人信息界面

local PokerRoomPlayerInfoView = class("PokerRoomPlayerInfoView", PokerUIWndBase);
local PokerUtils = require("package_src.games.guandan.gdcommon.commontool.PokerUtils")
local BasePlayerDefine = require("package_src.games.guandan.gdcommon.data.BasePlayerDefine")
local PokerDataConst = require("package_src.games.guandan.gdcommon.data.PokerDataConst")
local PokerClippingNode = require("package_src.games.guandan.gdcommon.commontool.PokerClippingNode")

--头像尺寸
local nHeadSize = 98
local eTagClipHead = 123
--------------------------------------------------
-- @param data: table
--      site : 显示的玩家座位
--      pos：    ui显示的位置
--------------------------------------------------
function PokerRoomPlayerInfoView:ctor(data)
    self.super.ctor(self, "package_res/games/guandan/playerinfo.csb", data);
end
-----------------------------------------
-- 函数功能：    初始化游戏数据
-- 返回值：      无
-----------------------------------------
function PokerRoomPlayerInfoView:onInit()
    local player = self:getPlayerModel()
    self.headUrl = player:getProp(BasePlayerDefine.ICON_ID)
    self.userName = player:getProp(BasePlayerDefine.NAME)
    self.userid = player:getProp(BasePlayerDefine.USERID)
    self.userSex = player:getProp(BasePlayerDefine.SEX)
    self.userMoney = player:getProp(BasePlayerDefine.MONEY)
    self.userLevel = player:getProp(BasePlayerDefine.LEVEL)
    self.ip = player:getProp(BasePlayerDefine.IP)
    self.jiD = player:getProp(BasePlayerDefine.JING_DU) or 0
    self.weD = player:getProp(BasePlayerDefine.WEI_DU) or 0
    Log.i("self.jiD,self.weD,", self.jiD, self.weD)

    local root = ccui.Helper:seekWidgetByName(self.m_pWidget,"root")
    root:addTouchEventListener(handler(self,self.onClickButton))

    local info_panel = ccui.Helper:seekWidgetByName(self.m_pWidget,"bg")
    info_panel:setAnchorPoint(cc.p(0.5, 0.5))
    if self.m_data.pos then
        local panelPos = root:convertToNodeSpace(self.m_data.pos)
        if self.m_data.site == 1 then
            info_panel:setAnchorPoint(cc.p(0.5, 0))
        elseif self.m_data.site == 3 then
            info_panel:setAnchorPoint(cc.p(0.5, 1))
            panelPos.y = panelPos.y - 70
        end
        info_panel:setPosition(panelPos)
    end

    self.frame = ccui.Helper:seekWidgetByName(self.m_pWidget, "frame");

    local lb_name = ccui.Helper:seekWidgetByName(self.m_pWidget, "lbl_name")
    lb_name:setString(self.userName)
    -- lb_name = ToolKit.subUtfStrByCn(self.userName,0,2,"...")

    local lb_id = ccui.Helper:seekWidgetByName(self.m_pWidget, "lbl_id");
    lb_id:setString("ID:"..self.userid);

    local lb_ip = ccui.Helper:seekWidgetByName(self.m_pWidget,"lbl_ip")
    lb_ip:setString("IP:"..self.ip)

    self:initDistance()
    
    local url = self.headUrl
    --local url ="http://wx.qlogo.cn/mmopen/w9vnwdyIABAibjKlvkSmpn6yQsnJoYZoiaeFZh542lwZTIVqKhAtm0G5ScVt8jibFXGSqbrgZblfT0tqmRzzEaH1S3tnMB1ZYCQ/0";
    if not url or string.len(url) < 4 then
        local headFile = self.userSex == 0 and "package_res/games/guandan/head/defaultHead_male.png" or "package_res/games/guandan/head/defaultHead_female.png"

        -- local headFile = "package_res/games/pokercommon/head/default_icon.png"
        self.head = PokerClippingNode.new("package_res/games/guandan/head/cicleHead.png",headFile, nHeadSize)
        self.head:setPosition(self.frame:getContentSize().width/2-2,self.frame:getContentSize().height/2)
        self.frame:addChild(self.head)
        self.head:setTag(eTagClipHead)
        return
    end

    local fileName = player:getProp(BasePlayerDefine.USERID) .. ".jpg"
    PokerUtils:updateHead(fileName, url, "package_res/games/guandan/head/cicleHead.png", nHeadSize, self.frame, self.head, eTagClipHead)
end

function PokerRoomPlayerInfoView:onShow()
    --刚打开暂停发送
    self.isPause = true;
    self.m_pWidget:performWithDelay(function()
        self.isPause = false;
    end, 0.2);
end

-----------------------------------------
-- 函数功能：    初始化玩家距离
-- 返回值：      无
-----------------------------------------
function PokerRoomPlayerInfoView:initDistance()
    local playerInfos = DataMgr.getInstance():getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    local index = 1
    for i,v in ipairs(playerInfos) do
        -- 加了不等于自身的判断，只显示
        -- if v:getProp(BasePlayerDefine.USERID) ~= self.userid and v:getProp(BasePlayerDefine.USERID)~= kUserInfo:getUserId() then
        if v:getProp(BasePlayerDefine.USERID) ~= self.userid  and index <= 3 then
            local item = ccui.Helper:seekWidgetByName(self.m_pWidget,"panel_dis"..index)
            item:setVisible(true)
            local lbl_name = ccui.Helper:seekWidgetByName(item,"txt2")
            local lbl_dis = ccui.Helper:seekWidgetByName(item,"txt4")
            Log.i("--wangzhi--PokerRoomPlayerInfoView:initDistance--",self.jiD,self.weD,v:getProp(BasePlayerDefine.JING_DU),v:getProp(BasePlayerDefine.WEI_DU))
            local dis = HallAPI.DataAPI:getDistance(self.jiD,self.weD,v:getProp(BasePlayerDefine.JING_DU) or 0,v:getProp(BasePlayerDefine.WEI_DU) or 0)
            local name = v:getProp(BasePlayerDefine.NAME)
            nickName = ToolKit.subUtfStrByCn(name,0,5,"...")
            lbl_name:setString(nickName)
            lbl_dis:setString(dis)
            index = index + 1
        end
    end
end

-----------------------------------------
-- 函数功能：    对距离ui做偏移
-- 返回值：      无
-----------------------------------------
function PokerRoomPlayerInfoView:updateDisPos(widget)
    local x = ccui.Helper:seekWidgetByName(widget,"tex1")
end

function PokerRoomPlayerInfoView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn");
        self:keyBack();
    end
end

function PokerRoomPlayerInfoView:onClickChatProp(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if self.isPause then
            return;
        end
        local PlayerModel = self:getPlayerModel()
        local userid = PlayerModel:getProp(BasePlayerDefine.USERID)
        kPokerSoundPlayer:playEffect("btn");
        local index = pWidget:getTag();
        if HallAPI.DataAPI:getMoney() > 0 then
            if self.m_delegate and self.m_delegate.sendMagicFace then
                self.m_delegate:sendMagicFace(userid, index);
            end
            self:keyBack();
        else
            HallAPI.ViewAPI:showToast("您的背包无金豆请存放金豆");
        end
    end
end

-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function PokerRoomPlayerInfoView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(PokerDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer =nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(BasePlayerDefine.SITE) == self.m_data.site then
            dstPlayer = v
            break
        end
    end

    if not dstPlayer then
        printError("playermodel is nil")
        return nil
    end
    return dstPlayer
end

return PokerRoomPlayerInfoView
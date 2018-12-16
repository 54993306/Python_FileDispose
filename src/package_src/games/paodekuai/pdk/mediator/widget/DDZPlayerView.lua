--
-- 玩家头像(加倍/积分/准备/角色/语音按钮条)
--
local PokerRoomPlayerInfoView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomPlayerInfoView")
local PokerClippingNode = require("package_src.games.paodekuai.pdkcommon.commontool.PokerClippingNode")
local PokerUtils = require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZDefine = require("package_src.games.paodekuai.pdk.data.DDZDefine")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local DDZRoomView = require("package_src.games.paodekuai.pdk.mediator.widget.DDZRoomView")
local DDZPlayerView = class("DDZPlayerView", DDZRoomView);
local DDZDataConst = require("package_src.games.paodekuai.pdk.data.DDZDataConst")
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local UmengClickEvent = require("app.common.UmengClickEvent")

--头像尺寸
local nHeadSize = 115
--透明度
local options = 
{
    full = 255,
    half = 128,
    zero = 0,
}

local eTagClipHead = 123

function DDZPlayerView:initView()
    self.frame = ccui.Helper:seekWidgetByName(self.m_pWidget,"frame")
    self.img_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_head");
    self.img_head1 = ccui.Helper:seekWidgetByName(self.frame, "img_head");
    self.img_head:setTouchEnabled(true);  
    self.img_head:addTouchEventListener(handler(self, self.onClickButton));
    self.money = ccui.Helper:seekWidgetByName(self.m_pWidget, "text_jindou");
    self.img_lord = ccui.Helper:seekWidgetByName(self.m_pWidget, "role");
    self.img_lord:setVisible(false)
    self.say_panel = self:getWidget(self.m_pWidget,"panel_head_say")
    
    --self.img_jiabei = ccui.Helper:seekWidgetByName(self.m_pWidget, "jiabei");
    self.lb_name = self:getWidget(self.m_pWidget, "lb_name", {bold = true});
    self.img_state = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_state")
    --TODO
    -- self.img_state:setVisible(HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM)
    --self.img_state:setVisible(HallAPI.DataAPI:isFriendRoom())
    --self.img_tg = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_tg");

    self.img_multi = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_multi")
    self.lab_times = ccui.Helper:seekWidgetByName(self.m_pWidget,"Label_times")
    self.img_lixian = self:getWidget(self.m_pWidget,"img_lixian")
    self.img_lixian:loadTexture("games/common/game/friendRoom/text_offline.png")
    self.img_lixian:setVisible(false)


    local img_coinIcon = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_coinicon")

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        ccui.Helper:seekWidgetByName(self.m_pWidget, "text_jindou"):setVisible(false)
        self.money = ccui.Helper:seekWidgetByName(self.m_pWidget, "text_base")
        img_coinIcon:setVisible(false)
    else
        self.money = ccui.Helper:seekWidgetByName(self.m_pWidget, "text_jindou")
        ccui.Helper:seekWidgetByName(self.m_pWidget, "text_base"):setVisible(false)
        img_coinIcon:setVisible(true)
    end
    self.money:setVisible(true)

    --初始化前先隐藏掉头像信息框
    self:hide()

    --添加监听事件
    self.nHandle=HallAPI.EventAPI:addEvent(PokerEventDef.GameEvent.PLAYER_PROP_CHANGE, handler(self, self.onRecvEvent))
    table.insert(self.listeners, self.nHandle)

end

-----------------------------------------------------------------
-- @desc 重置
-----------------------------------------------------------------
function DDZPlayerView:reset()
    if HallAPI.DataAPI:getGameType() ~= StartGameType.FIRENDROOM then
        self:hide()
    else
        self.lab_times:setString("x" .. tostring(1))
    end
    self.say_panel:setVisible(false)
    self.img_lord:setVisible(false)
    self.img_multi:setVisible(false)
end

-----------------------------------------------------------------
-- @desc 收到监听事件 监听玩家属性改变
-- @pram: prop_id 属性id  
--        value:新的值
--        oldvalue:旧的值
--        extinfo:其他信息 一般是seat用来区分那个人来接受这个事件
-----------------------------------------------------------------
function DDZPlayerView:onRecvEvent(prop_id, value, oldvalue, extinfo)

    if prop_id == DDZDefine.MONEY and extinfo == self.m_data then
        self:setMoney(value)
    elseif prop_id == DDZDefine.USERTIMES and extinfo == self.m_data then
        self:setMultiple(value)
    end
end

-----------------------------------------------------------------
-- @desc 设置玩家倍数
-----------------------------------------------------------------
function DDZPlayerView:setMultiple()
    self.img_multi:setVisible(false)

    -- local userID = self:getPlayerModel():getProp(DDZDefine.USERID)
    -- local userMulti = DataMgr:getInstance():getPlayerMultipleById(userID)    
    -- if userMulti <= 0 then
    --     self.img_multi:setVisible(false)
    -- else
    --     self.img_multi:setVisible(true)
    --     self.lab_times:setString("x" .. userMulti)
    -- end
end

-----------------------------------------------------------------
-- @desc 加倍  暂时不用显示
-- @desc multi:玩家加倍数
-----------------------------------------------------------------
function DDZPlayerView:onDouble(multi)
    if multi > 1 then
       --self.img_jiabei:setVisible(true);
    end
end


-----------------------------------------------------------------
-- @desc 离线
-----------------------------------------------------------------
function DDZPlayerView:showOnline(status)
    if not tolua.isnull(self.img_lixian) then
        local player = self:getPlayerModel()
        local userId = player:getProp(DDZDefine.USERID)        
        local info = kFriendRoomInfo:getRoomPlayerListInfo(userId)

        --Log.i("===========userIduserIduserId===========",userId,info.st)
        if info then
            self.img_lixian:setVisible(info.st ~= 0 )
        else
            self.img_lixian:setVisible(false)
        end
    end
end

-----------------------------------------------------------------
-- @desc 显示准备
-----------------------------------------------------------------
function DDZPlayerView:showReady()
    if not tolua.isnull(self.img_state) then
        self.img_state:setVisible(true)
    end
end

-----------------------------------------------------------------
-- @desc 隐藏准备
-----------------------------------------------------------------
function DDZPlayerView:hideReady()
    if not tolua.isnull(self.img_state) then
        self.img_state:setVisible(false)
    end
end

-----------------------------------------------------------------
-- @desc 更新头像
-- @pram :imgName 玩家头像路径
-----------------------------------------------------------------
function DDZPlayerView:updateHeadImg(imgName)
    local PlayerModel = self:getPlayerModel()
    local userid = PlayerModel:getProp(DDZDefine.USERID)
    local headImg = PlayerModel:getProp(DDZDefine.ICON_ID)
    if imgName == ( headImg .. "") then
        imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgName) then
            self.img_head:loadTexture(imgName);
        end
    end
    local strPre = string.sub(imgName, 1, 11)
    local length = string.len(imgName)
    local strUserId = string.sub(imgName, 12, length - 4)
    Log.i("更新头像", strPre, tonumber(strUserId), userid)
    if strPre == "wxHeadFile_" then
        if tonumber(strUserId) ~= userid then
            print("更新头像,return")
            return
        end
    end

    imgName = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if io.exists(imgName) then
        self.img_head:loadTexture(imgName)
    end
end

-----------------------------------------------------------------
-- @desc 更新玩家信息
-- @pram :无
-----------------------------------------------------------------
function DDZPlayerView:updatePlayerInfo()
    Log.i("DDZPlayerView:updatePlayerInfo ")

    self:show()
    local player = self:getPlayerModel()
    self.lb_name:setString(PokerUtils:subUtfStrByCn(player:getProp(DDZDefine.NAME), 1, 4, ".."));
    self:setMoney(player:getProp(DDZDefine.MONEY))
    local sex = player:getProp(DDZDefine.SEX)

    url = player:getProp(DDZDefine.ICON_ID)
    -- url ="http://wx.qlogo.cn/mmopen/w9vnwdyIABAibjKlvkSmpn6yQsnJoYZoiaeFZh542lwZTIVqKhAtm0G5ScVt8jibFXGSqbrgZblfT0tqmRzzEaH1S3tnMB1ZYCQ/0";
    self.img_head:setOpacity(options.zero)
    local defMale = "package_res/games/pokercommon/head/defaultHead_male.png"
    local defFemale = "package_res/games/pokercommon/head/defaultHead_female.png"
    local stencil = "package_res/games/pokercommon/head/cicleHead.png"
    Log.i("head url ", url)
    if not PokerUtils:isNetWorkHeadUrl(url) then
        local headFile = sex == DDZConst.MALE and defMale or defFemale
        Log.i("head headFile ", headFile)

        self.head = PokerClippingNode.new(stencil, headFile, nHeadSize)
        self.head:setPosition(self.img_head:getPositionX(),self.img_head:getPositionY())
        self.frame:addChild(self.head)
        self.head:setTag(eTagClipHead)
        -- self.head:setScale( self.img_head:getContentSize().width / self.head:getContentSize().width )
        return
    end

    local fileName = player:getProp(DDZDefine.USERID) .. ".jpg"
    local pos = cc.p(self.img_head:getPositionX(),self.img_head:getPositionY())
    PokerUtils:updateHead(fileName, url, stencil, nHeadSize, self.frame, self.head, eTagClipHead, pos)

end

-----------------------------------------------------------------
-- @desc 设置玩家角色
-- @pram :无
-----------------------------------------------------------------
function DDZPlayerView:setRole()
    local PlayerModel = self:getPlayerModel()
    local userid = PlayerModel:getProp(DDZDefine.USERID)
    self.img_lord:setVisible(false);
    local gameStatus = DataMgr:getInstance():getNumberByKey(DDZDataConst.DataMgrKey_GAMESTATUS) 
    if userid == DataMgr:getInstance():getObjectByKey(DDZDataConst.DataMgrKey_LORDID) and gameStatus>=3 then
        self.img_lord:setVisible(true)
    else
        self.img_lord:setVisible(false)
    end
end

-----------------------------------------------------------------
-- @desc 设置玩家金币或积分
-- @pram :money:金币积分数
-----------------------------------------------------------------
function DDZPlayerView:setMoney(money)
    if not tolua.isnull(self.money) then
        if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
            self.money:setString(tostring(money))
        else
            local suf= ""
            local strCoin, suffix = PokerUtils.formatCoin(self, tostring(money))
            if suffix == "wan"  then
                suf = "万"
            elseif suffix == "yi" then
                suf = "亿"
            end
            self.money:setString(strCoin .. suf)
        end
    end
end

-----------------------------------------------------------------
-- @desc 玩家托管改变  暂不需要显示玩家托管在头像上
-- @pram :无
-----------------------------------------------------------------
function DDZPlayerView:onTuoGuanChange()
    -- if packetInfo and packetInfo.isM == 1 then
    --     self.img_tg:setVisible(true);
    -- else
    --     self.img_tg:setVisible(false);
    -- end
end

----------------------------------------------
-- @desc 按钮点击处理 
-- @pram pWidget :点击的ui
--       EventType:点击的类型
----------------------------------------------
function DDZPlayerView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
    NativeCallUmengEvent(UmengClickEvent.PDKGamePlayerHead)
        kPokerSoundPlayer:playEffect("btn");
        if pWidget == self.img_head then
            local wpos = pWidget:getParent():convertToWorldSpace(cc.p(pWidget:getPositionX(),pWidget:getPositionY()))

            local data = {}
            data.pos = cc.p( (display.width *0.5 - wpos.x) * 0.5  + wpos.x, wpos.y)
            data.site = self.m_data
            local PokerRoomPlayerInfoView = PokerUIManager.getInstance():pushWnd(PokerRoomPlayerInfoView, data);
            PokerRoomPlayerInfoView:setDelegate(self.m_delegate);
        end;
    end
end

----------------------------------------------
-- @desc 获取玩家头像位置 
-- @pram 无
----------------------------------------------
function DDZPlayerView:getPlayerPosition()
    return self.m_pWidget:getPosition();
end

----------------------------------------------
-- @desc 获取玩家默认头像地址
-- @pram 无
----------------------------------------------
function DDZPlayerView:getDefalutHeadFile(sex)
    -- if(sex == 1) then
    --     return "package_res/games/pokercommon/head/male.png"
    -- else
    --     return "package_res/games/pokercommon/head/female.png"
    -- end

    return "package_res/games/pokercommon/head/default_icon.png"
end

---------------------------------------
-- @desc   显示语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZPlayerView:showSpeaking()
    self.say_panel:setVisible(true)
end

---------------------------------------
-- @desc   隐藏语音聊天图标
-- 返回值：     无
-- 参数：       无
---------------------------------------
function DDZPlayerView:hideSpeaking()
    Log.i("DDZPlayerView:hideSpeaking ", self.m_data)
    self.say_panel:setVisible(false)
end


-------------------------------------------------------
-- @desc 根据view创建时传入的seat来获取到玩家的数据模型
-- @return 返回玩家数据模型
-------------------------------------------------------
function DDZPlayerView:getPlayerModel()
    local PlayerModelList = DataMgr:getInstance():getTableByKey(DDZDataConst.DataMgrKey_PLAYERLIST)
    local dstPlayer = nil
    for k,v in pairs(PlayerModelList) do
        if v:getProp(DDZDefine.SITE) == self.m_data then
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

return DDZPlayerView
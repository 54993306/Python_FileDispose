-------------------------------------------------------------------------
-- Desc:   斗地主游戏结束面板
-- Author:   
-------------------------------------------------------------------------

local PokerUtils = require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local DDZTWOPDefine = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPDefine")
local DDZTWOPGameEvent = require("package_src.games.paodekuai.pdktwop.data.DDZTWOPGameEvent")
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")
local PokerConst = require("package_src.games.paodekuai.pdkcommon.data.PokerConst")
local BasePlayerDefine = require("package_src.games.paodekuai.pdkcommon.data.BasePlayerDefine")
local PokerDataConst = require("package_src.games.paodekuai.pdkcommon.data.PokerDataConst")
local DDZPKGameoverView = class("DDZPKGameoverView", PokerUIWndBase)

---------------------------------------
-- 函数功能：   构造函数 初始化数据
-- 返回值：     无
---------------------------------------
function DDZPKGameoverView:ctor(data)
    self.super.ctor(self, "package_res/games/pokercommon/gameover.csb", data)
    self.btn_detail = {}
    --背景开始缩放比例
    self.bg_scale = 0.95
    --背景动画第一次放大时间
    self.bg_first_bscaleTime = 0.2
    --背景动画第一次放大比例
    self.bg_first_bscale = 1.1
    --背景动画第一次缩小比例
    self.bg_first_sscale = 0.9
    --背景动画第一次缩小时间
    self.bg_first_sscaleTime = 0.2
    --背景动画第二次放大小比例
    self.bg_second_bscale = 1.02
    --背景动画第二放大时间
    self.bg_second_bscaleTime = 0.1
    --背景动画第二次缩小比例
    self.bg_second_sscale = 0.95
    --背景动画第二次缩小时间
    self.bg_second_sscaleTime = 0.08
    --背景动画最后回复正常时间
    self.bg_threeTime = 0.1

    --内容开始缩小比例
    self.content_scale = 0.2
    --内容缩放时间
    self.content_scale_time = 0.3
    
    --标题延时出现时间
    self.titleDealyTime = 0.2
    --封顶倍数
    self.fengding = 0

end

---------------------------------------
-- 函数功能：   初始化UI
-- 返回值：     无
---------------------------------------
function DDZPKGameoverView:onInit()
    DataMgr:getInstance():reSureLordFlag()
    self.btn_change = ccui.Helper:seekWidgetByName(self.m_pWidget,"Button_change")
    self.btn_change:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_continue = ccui.Helper:seekWidgetByName(self.m_pWidget,"Button_next")
    self.btn_continue:addTouchEventListener(handler(self, self.onClickButton))
	-- 回放不用显示继续游戏按钮
    if VideotapeManager.getInstance():isPlayingVideo() then
        self.btn_continue:setVisible(false)
    end

    self.img_continue = ccui.Helper:seekWidgetByName(self.btn_continue,"Image_7")
    if self.m_data.over then
        self.img_continue:loadTexture("btn/btn_total.png",ccui.TextureResType.plistType)
    end


    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"Button_back")
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton))


    self.listView = ccui.Helper:seekWidgetByName(self.m_pWidget,"ListView_datail")
    self.img_tilte = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_title")
    for i=1,4 do
        ccui.Helper:seekWidgetByName(self.m_pWidget,"label_title_"..i):setFontName(PokerConst.FONT)
    end
    self.bg_container = ccui.Helper:seekWidgetByName(self.m_pWidget,"bgContainer")
    self.content_container = ccui.Helper:seekWidgetByName(self.m_pWidget,"contentContainer")
    local diShu_label = ccui.Helper:seekWidgetByName(self.content_container,"label_title_2")
    diShu_label:setString("底分")
    diShu_label:setVisible(false)

    --隐藏右下角的文字
    local room_cost = ccui.Helper:seekWidgetByName(self.m_pWidget,"room_cost")
    room_cost:setVisible(false)

    local wanfaString = ""
    -- for i,v in ipairs(self.m_data.JSFX) do
    --     wanfaString = wanfaString..v.fanName..":"..v.fan.. "  "
    --     if v.fanName == "封顶倍数" then
    --         self.fengding = v.fan
    --     end
    -- end
    wanfaString = string.gsub(wanfaString, "_", ":")
    self.wanfaLbl = self:getCustomWidget2(self.content_container, "label_wanfa",{bold = true},info):setString(wanfaString)
    self.wanfaLbl:setFontSize(18)
    self:showAnimation()

    if HallAPI.DataAPI:getGameType() == StartGameType.FIRENDROOM then
        self.btn_change:setVisible(false)
        self.btn_back:setVisible(false)
    end
end
---------------------------------------
-- 函数功能：    展示UI
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:onShow()
    HallAPI.SoundAPI:pauseMusic()
    self:initGameInfo()
    local myIndex = 1
    for k, v in pairs(self.m_data.plI1) do
        if v.plI == HallAPI.DataAPI:getUserId() then
            myIndex = k
        end
    end
    table.sort(self.m_data.plI1,function(a,b)
        return a.plI == HallAPI.DataAPI:getUserId()
    end)
    for k, v in pairs(self.m_data.plI1) do
        self:initPlayerInfo(v)
    end
end
---------------------------------------
-- 函数功能：    初始化玩家游戏数据
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:initGameInfo()
    self.img_tilte:setVisible(false)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/gameover/AnimationDDZ2.csb")
    local armature = ccs.Armature:create("AnimationDDZ2")
    armature:setPosition(cc.p(self.img_tilte:getPositionX(),self.img_tilte:getPositionY()))
    self.img_tilte:getParent():addChild(armature)
    if self:checkIsWin() then
        kPokerSoundPlayer:playEffect("win")
        armature:getAnimation():play("AnimationWIN")
    else
        kPokerSoundPlayer:playEffect("lose")
        armature:getAnimation():play("AnimationLOSE")
    end
end

---------------------------------------
-- 函数功能：    检查玩家是否是赢家
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:checkIsWin()
    for i,v in ipairs(self.m_data.wiIds) do
            if HallAPI.DataAPI:getUserId() == v then
                return true
            end
    end
    return false
 end

---------------------------------------
-- 函数功能：    初始化玩家游戏结束UI
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:initPlayerInfo(info)
    local playerInfoItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/gameover_item.csb")
    if not playerInfoItem then
        return
    end

    -- local fanbeiString = ""
    -- for i,v in ipairs(info.Fan) do
    --     -- fanbeiString = fanbeiString..v.fanName.."*"..v.fan.. "  "
    --     if v.fanName == "炸弹" then
    --         fanbeiString = fanbeiString..v.fanName.."x"..v.fan.. "  "
    --     else
    --         fanbeiString = fanbeiString..v.fanName.. "  "
    --     end
    -- end

    local isMe = HallAPI.DataAPI:getUserId() == info.plI
    local PlayerModel = DataMgr:getInstance():getPlayerInfo(info.plI)
    local userName = PlayerModel:getProp(BasePlayerDefine.NAME)
    -- local nameLbl = self:getCustomWidget(playerInfoItem, "Label_name",{bold = true},info):setString(PokerUtils:subUtfStrByCn(userName, 1, 4, ".."))
    -- local baseLbl = self:getCustomWidget(playerInfoItem, "Label_base",{bold = true},info):setString(self.m_data.foB)

    local nameLbl = self:getCustomWidget(playerInfoItem, "Label_name",{bold = true},info)
    Util.updateNickName(nameLbl, PokerUtils:subUtfStrByCn(userName, 1, 4, ".."))
    -- local baseLbl = self:getCustomWidget(playerInfoItem, "Label_base",{bold = true},info):setString(fanbeiString)
    -- baseLbl:setFontSize(20)

    -- if info.mu > self.fengding then
    --     info.mu = self.fengding .. "(封顶)"
    --     if info.plI == self.m_data.baUID then
    --         local dizhuFengding = self.fengding*2
    --         info.mu = dizhuFengding.. "(封顶)"
    --     end
    -- end 

    -- if info.plI == self.m_data.baUID then
    --     if info.mu > self.fengding*2 then
    --         local dizhuFengding = self.fengding*2
    --         info.mu = dizhuFengding.. "(封顶)"
    --     end
    -- else
    --     if info.mu > self.fengding then
    --         info.mu = self.fengding .. "(封顶)"
    --     end
    -- end

    local multiLbl = self:getCustomWidget(playerInfoItem, "Label_muti",{bold = true},info):setString(info.mu)
    local scoreLbl = self:getCustomWidget(playerInfoItem, "Label_score",{bold = true},info):setString(info.foC)

    local fanbeiString = ""
    -- for i,v in ipairs(info.Fan) do
    --     fanbeiString = fanbeiString..v.fanName.."*"..v.fan.. "  "
    -- end

    local fanbeiLbl = self:getCustomWidget(playerInfoItem, "label_fanbei",{bold = true},info):setString(fanbeiString)
    fanbeiLbl:setVisible(false)
    self:getWidget(playerInfoItem, "Image_lordTag"):setVisible(info.plI == self.m_data.baUID)
    local re_icon = self:getWidget(playerInfoItem,"re_icon")
    re_icon:setPositionX(scoreLbl:getPositionX() + scoreLbl:getContentSize().width/2 +25)
    re_icon:setVisible(false)
    if info.winFull then 
        re_icon:setVisible(true)
        re_icon:loadTexture("common/fengding.png",ccui.TextureResType.plistType)
    end
    if info.isB == 1 then
        re_icon:setVisible(true)
        re_icon:loadTexture("common/pochan.png",ccui.TextureResType.plistType)
    end
    self.btn_detail = ccui.Helper:seekWidgetByName(playerInfoItem,"Button_beidetail")
    self.btn_detail:setVisible(false)
    if self.btn_detail:isVisible() then
        self.btn_detail:addTouchEventListener(handler(self, self.onClickButtonDetail))
    end
    self.listView:pushBackCustomItem(playerInfoItem)
end

---------------------------------------
-- 函数功能：    获取子节点
-- 返回值：      子节点
---------------------------------------
function DDZPKGameoverView:getCustomWidget(parent,name,args,info)
    local widget = self:getWidget(parent,name,args)
    local isMe = HallAPI.DataAPI:getUserId() == info.plI
    widget:setColor(isMe and PokerConst.MINECOLOR or PokerConst.OTHERCOLOR)
    return widget
end

---------------------------------------
-- 函数功能：    获取子节点
-- 返回值：      子节点
---------------------------------------
function DDZPKGameoverView:getCustomWidget2(parent,name,args,info)
    local widget = self:getWidget(parent,name,args)
    local isMe = HallAPI.DataAPI:getUserId() == info.plI
    -- widget:setColor(isMe and PokerConst.MINECOLOR or PokerConst.OTHERCOLOR)
    -- widget:setColor(cc.c3b(236, 201, 145))
    return widget
end


---------------------------------------
-- 函数功能：    点击事件处理
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.btn_continue then
            if HallAPI.DataAPI:isGameEnd() then
                Log.i("****************************end")
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_SHOWTOTALOVER)
            else
                Log.i("****************************not end")
                HallAPI.EventAPI:dispatchEvent(POKERCONST_EVENT_NETDISPATCH, true)
                HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_REQ_REQCONTINUE,1)
            end
        end
    end
end


---------------------------------------
-- 函数功能：    返回键事件处理
-- 返回值：      无
---------------------------------------
function DDZPKGameoverView:keyBack()

end

---------------------------------------
-- 函数功能：  播放动画
-- 返回值： 无
---------------------------------------
function DDZPKGameoverView:showAnimation()
    self.bg_container:setScaleY(self.bg_scale)
    self.content_container:setScale(self.content_scale)
    transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_first_bscaleTime,1,self.bg_first_bscale),{onComplete = function()
        transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_first_sscaleTime,1,self.bg_first_sscale),{onComplete = function()
            transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_second_bscaleTime,1,self.bg_second_bscale),{onComplete = function()
                transition.execute(self.bg_container,cc.ScaleTo:create(self.bg_second_sscaleTime,1,1),{onComplete = function()
                end})
            end})
        end})
    end})
    transition.execute(self.content_container,cc.ScaleTo:create(self.content_scale_time,1))
end

return DDZPKGameoverView
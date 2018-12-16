-------------------------------------------------------------------------
-- Desc:   二人斗地主游戏结束总结算面板
-- Author:   
-------------------------------------------------------------------------
local PokerUtils = require("package_src.games.paodekuai.pdkcommon.commontool.PokerUtils")
local BasePlayerDefine = require("package_src.games.paodekuai.pdkcommon.data.BasePlayerDefine")
local DDZGameEvent = require("package_src.games.paodekuai.pdk.data.DDZGameEvent")
local PokerRoomDialogView = require("package_src.games.paodekuai.pdkcommon.widget.PokerRoomDialogView")
local DDZPKTotalGameoverView = class("DDZPKTotalGameoverView", PokerUIWndBase)
local DDZConst = require("package_src.games.paodekuai.pdk.data.DDZConst")
local PokerEventDef = require("package_src.games.paodekuai.pdkcommon.data.PokerEventDef")


local titleCnt = 5 --title的个数
local fontName = "package_res/games/pokercommon/font/main.ttf"--字体
local mineColor = cc.c3b(255,212,0)
local otherColor = cc.c3b(222,222,219)

---------------------------------------
-- 函数功能：   构造函数 初始化数据
-- 返回值：     无
---------------------------------------
function DDZPKTotalGameoverView:ctor(data)
    self.super.ctor(self, "package_res/games/pokercommon/totalgameover.csb", data)
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
end

---------------------------------------
-- 函数功能：   初始化UI
-- 返回值：     无
---------------------------------------
function DDZPKTotalGameoverView:onInit()
    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_certain")
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton))

    self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_share")
    self.btn_share:addTouchEventListener(handler(self,self.onClickButton))

    self.listView = ccui.Helper:seekWidgetByName(self.m_pWidget,"ListView_datail")
    self.img_tilte = ccui.Helper:seekWidgetByName(self.m_pWidget,"Image_title")
    for i=1,titleCnt do
        ccui.Helper:seekWidgetByName(self.m_pWidget,"label_title_"..i):setFontName(fontName)
    end
    self.bg_container = ccui.Helper:seekWidgetByName(self.m_pWidget,"bgContainer")
    self.content_container = ccui.Helper:seekWidgetByName(self.m_pWidget,"contentContainer")

    self:showAnimation()
end

function DDZPKTotalGameoverView:initWinner(playerData)
    local maxValue = -99999
    for i=1,#playerData do
       local data = playerData[i]
       if(data.to>maxValue) then
          maxValue =data.to
       end
    end
    
    for i=1,#playerData do
        local data = playerData[i]
        if data.to > 0 and data.to >= maxValue then   -- 大赢家的分数必定大于0
            playerData[i].winner = true;
        else
            playerData[i].winner = false;
        end
    end
end
---------------------------------------
-- 函数功能：   初始化后执行的函数
-- 返回值：     无
---------------------------------------
function DDZPKTotalGameoverView:onShow()
    self:initGameInfo()
    table.sort(self.m_data.plL,function(a,b)
        return a.usI == HallAPI.DataAPI:getUserId()
    end)

    --Log.i("================初始化后执行的函数===========",self.m_data.plL)
    self:initWinner(self.m_data.plL)

    for k, v in pairs(self.m_data.plL) do
        self:initPlayerInfo(v)
    end
end

--------------------------------------------
-- @desc 初始化标题信息
--------------------------------------------
function DDZPKTotalGameoverView:initGameInfo()
    self.img_tilte:setVisible(false)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("package_res/games/pokercommon/anim/gameover/AnimationDDZ2.csb")
    local armature = ccs.Armature:create("AnimationDDZ2")
    armature:setPosition(cc.p(self.img_tilte:getPositionX(),self.img_tilte:getPositionY()))
    self.img_tilte:getParent():addChild(armature)
    armature:getAnimation():play("AnimationZONGFEN")
end

---------------------------------------
-- 函数功能：    初始化玩家游戏结束UI
-- 返回值：      无
---------------------------------------
function DDZPKTotalGameoverView:initPlayerInfo(info)
    local playerInfoItem = ccs.GUIReader:getInstance():widgetFromBinaryFile("package_res/games/pokercommon/totalgameover_item.csb")
    if not playerInfoItem then
        return
    end
    local player = DataMgr:getInstance():getPlayerInfo(info.usI)
    local userName = player:getProp(BasePlayerDefine.NAME)
    local nameLbl = self:getCustomWidget(playerInfoItem, "lbl_name",{bold = true},info)
    Util.updateNickName(nameLbl, PokerUtils:subUtfStrByCn(userName, 1, 4, ".."))
    local boomLbl = self:getCustomWidget(playerInfoItem, "lbl_boom",{bold = true},info):setString(info.boomCount)
    local singleScore = 0 
    if info.singleScore > 0 then
        singleScore =  info.singleScore
    end
    local sigleLbl = self:getCustomWidget(playerInfoItem, "lbl_sigle_score",{bold = true},info):setString(singleScore or 0)
    local inningLbl = self:getCustomWidget(playerInfoItem, "lbl_inning",{bold = true},info):setString(info.winCount.."胜"..info.losCount.."负")
    local totalLbl = self:getCustomWidget(playerInfoItem, "lbl_total_score",{bold = true},info):setString(info.to)
    
    local img_tag = self:getWidget(playerInfoItem,"img_tag")
    local img_win = self:getWidget(playerInfoItem,"img_win")
    img_tag:setVisible(false)
    img_win:setVisible(false)

    --Log.i("================初始化玩家游戏结束UI===========",info.winner)
    if info.winner then
        img_win:setVisible(true)
        img_win:loadTexture("common/dayingjia.png", ccui.TextureResType.plistType)
    end

    if HallAPI.DataAPI:isRoomMain(info.usI) then
        img_tag:setVisible(true)
        img_tag:loadTexture("common/fangzhu.png", ccui.TextureResType.plistType)
    end
    self.listView:pushBackCustomItem(playerInfoItem)
end

---------------------------------------
-- 函数功能：    获取子节点
-- 返回值：      子节点
---------------------------------------
function DDZPKTotalGameoverView:getCustomWidget(parent,name,args,info)
    local widget = self:getWidget(parent,name,args)
    local isMe = HallAPI.DataAPI:getUserId() == info.usI
    widget:setColor(isMe and mineColor or otherColor)--todo
    return widget
end

---------------------------------------
-- 函数功能：    点击事件处理
-- 返回值：      无
---------------------------------------
function DDZPKTotalGameoverView:onClickButton(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        kPokerSoundPlayer:playEffect("btn")
        if pWidget == self.btn_share then
           HallAPI.ViewAPI:shareScreen()
        elseif pWidget == self.btn_back then
            self:keyBack()
        end
    end
end

---------------------------------------
-- 函数功能：    返回键事件处理
-- 返回值：      无
---------------------------------------
function DDZPKTotalGameoverView:keyBack()
    HallAPI.EventAPI:dispatchEvent(PokerEventDef.GameEvent.GAME_EXIT_GAME)
end

---------------------------------------
-- 函数功能：  播放动画
-- 返回值： 无
---------------------------------------
function DDZPKTotalGameoverView:showAnimation()
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

return DDZPKTotalGameoverView
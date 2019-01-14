-- 大厅主页
local CircleClippingNode = require("app.games.common.custom.CircleClippingNode")
local InviteFriendView = require("app.hall.wnds.yaoqing.InviteFriendView")

local AdvertView = require("app.hall.wnds.advert.AdvertView")

local AdvertView_page = require("app.hall.wnds.advert.AdvertView_page")

local AdvertViewDialog = require("app.hall.wnds.advert.AdvertViewDialog")

local UmengClickEvent = require("app.common.UmengClickEvent")
local BackEndStatistics = require("app.common.BackEndStatistics")
local crypto = require "app.framework.crypto"

HallMain = class("HallMain", UIWndBase);

local LocalEvent = require("app.hall.common.LocalEvent")
local ChargeIdTool = require("app.PayConfig")

local Club = require("app.hall.wnds.club.club")
local Mall = require("app.hall.wnds.mall.mall")
local MyClub = require("app.hall.wnds.club.myclub")
local PlayerPanel = require("app.hall.wnds.player.PlayerPanel")
local EmailPanel = require "app.hall.wnds.email.EmailPanel"
local ShareToWX = require "app.hall.common.ShareToWX"
local HallBindPhone = require "app.hall.wnds.account.halloption.HallBindPhone"
local BindPhone = require "app.hall.wnds.account.halloption.BindPhone"
local AccountStatus = require "app.hall.wnds.account.AccountStatus"
local ComFun = require("app.hall.wnds.account.AccountComFun")
local LiangYouActivity = require("app.hall.wnds.activity.LiangYouActivity")
local ActivityDialog = require("app.hall.wnds.activity.ActivityDialog")
local CommonTips = require "app.hall.common.CommonTips"

local TurnEnterLayer = require("app.hall.main.TurnEnterLayer")

local GAME_ROUND_FLAG = 0
--redIcon pos param
local hratio = 13/16
local vratio = 15/16
--redIcon pos param

function HallMain:ctor(info)
    self.super.ctor(self, "real_res/hall.csb", info);
    self.m_socketProcesser = HallSocketProcesser.new(self);
    SocketManager.getInstance():addSocketProcesser(self.m_socketProcesser);
    self.Events = {}

    self.m_isWaitInviteInfo = false
    self.m_isWaitClubInfo = false

    ---请求玩家信息
    self:sendPlayerInfo()
end

function HallMain:onResume()
    Log.i("HallMain:onResume....")
    self:updateUserInfo();
    -- 从其他界面恢复到大厅时尝试显示亲友圈指引
    self:addQinyouquan()
    self:joinRoomByScheme()
    self:JoinRoomByXianLaiScheme()
end

function HallMain:onTouchBegan(touch, event)
    return false;
end


function HallMain:onClose()

    if(self.m_timer_marquee~=nil) then
        self.m_timer_marquee:finalizer()
        self.m_timer_marquee:removeTimer("marquee_wechatId_update_timer");
        self.m_timer_marquee=nil
    end

    if self.m_socketProcesser then
        SocketManager.getInstance():removeSocketProcesser(self.m_socketProcesser);
        self.m_socketProcesser = nil;
    end
	if(self.m_advertView) then
	    self.m_advertView:dtor();
        if IsPortrait then -- TODO
            self.m_advertView:removeFromParent()
            self.m_advertView = nil
        end
	end
    table.walk(self.Events,function(event)
        cc.Director:getInstance():getEventDispatcher():removeEventListener(event)
    end)
    self.Events = {}
    if IsPortrait then -- TODO
        --退出的时候置空
        self.m_pWidget:removeFromParent()
        self.m_pWidget = nil
    end
end

function HallMain:onInit()

    self.nickName = ccui.Helper:seekWidgetByName(self.m_pWidget, "nickName");
    self.money = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_diamond");
    self.lb_id = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_id");
    --self.money = self:getWidget(self.m_pWidget, "lb_diamond",{shadow_bold = true});

    Util.updateNickName(self.nickName, ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 6, "..."), 20)
    self.nickName:enableShadow(cc.c4b(0, 0, 0,255),cc.size(2,-2));

    self.money:setString("钻石x"..kUserInfo:getPrivateRoomDiamond());
    self.lb_id:setString("ID:".. kUserInfo:getUserId());
    if not IsPortrait then -- TODO
        self.lb_id:enableShadow(cc.c4b(0, 0, 0,255),cc.size(2,-2));
    end

    self.img_head = ccui.Helper:seekWidgetByName(self.m_pWidget, "img_head");
    self.img_head:setTouchEnabled(true);
    self.img_head:addTouchEventListener(handler(self, self.onClickButton));

    self.headPanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "head_panel")
    self.headPanel:addTouchEventListener(handler(self, self.onClickButton))

    -- 创建房间按钮
    self.btn_new = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_new");
    self.btn_new:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_more = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_more");
    self.btn_more:addTouchEventListener(handler(self, self.onClickButton));

    self.morepanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "morepanel");
    self.morepanel:addTouchEventListener(handler(self, self.closeMorePanel))

    self.btn_closeMorePanel = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_close_morepanel")
    self.btn_closeMorePanel:addTouchEventListener(handler(self, self.closeMorePanel))

    self.morepanel:setVisible(false)

    if not IsPortrait then -- TODO
        self.btn_exchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange");
        self.btn_exchange:addTouchEventListener(handler(self, self.onClickButton));
    end

    self.btn_task = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_task");
    self.btn_task:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_ruler = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_ruler");
    self.btn_ruler:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_join = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_join");
    self.btn_join:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_record = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_record");
    self.btn_record:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_help = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_help");
    self.btn_help:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_setting = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_setting");
    self.btn_setting:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_newer = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_newer");
    self.btn_newer:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_diamond_add = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_diamond_add");
    self.btn_diamond_add:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_back = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_back");
    self.btn_back:addTouchEventListener(handler(self, self.onClickButton));

    if IsPortrait then -- TODO
        self.btn_exchange = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_exchange");
        self.btn_exchange:addTouchEventListener(handler(self, self.onClickButton));
    else
        self.btn_recruit_agency = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_recruit_agency");
        self.btn_recruit_agency:addTouchEventListener(handler(self, self.onClickButton));
        self:addRecruitAgencyBtnEffect()
    end

    self.btn_notice = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_notice");
    self.btn_notice:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_activity = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_activity");
    self.btn_activity:addTouchEventListener(handler(self, self.onClickButton));

    if IsPortrait then -- TODO
        self.btn_bag = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bag")
        self.btn_bag:addTouchEventListener(handler(self, self.onClickButton));
    end

    self.btn_mail = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_mail");
    self.btn_mail:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_box = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_box")
    self.btn_box:addTouchEventListener(handler(self, self.onClickButton))
    if IsPortrait then -- TODO
        --TODO 不可领取设置透明度 暂时写死
        local chids=self.btn_box:getChildren()
        for k,v in pairs(chids) do
            v:setOpacity(150)
        end
    end
    -- self.btn_box:setBright(false)
    --广告面板
    self.m_pan_ad = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_ad");

    self.btn_ad = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_ad");
    self.btn_ad:addTouchEventListener(handler(self, self.onClickButton));
    self.btn_ad:loadTexture(GC_GameHallAdPath or _gameHallAdPath);

    if IsPortrait then -- TODO
        self.btn_ad:setVisible(false)
        self.m_pan_ad:setVisible(true)
    end
    --广告图微信号轮播，以后有需求再实现callBack
    --callBack记得对使用到的控件进行判空，或者通过事件来做。
    if not IsPortrait then -- TODO
        local callBack = function() end
        kUserData_userExtInfo:getAddWechatStr(callBack)
        --kUserData_userExtInfo:setDiamoundWechatID()
    end

    self.btn_room_match = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_room_match");
    self.btn_room_match:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_room_coin = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_room_coin");
    self.btn_room_coin:addTouchEventListener(handler(self, self.onClickButton));

    self.btn_diamond = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_free");
    self.btn_diamond:addTouchEventListener(handler(self, self.onClickButton));

    if not IsPortrait then -- TODO
        local game_round_num = tonumber(kLoginInfo:getRoundNum())
        if game_round_num < GAME_ROUND_FLAG then
            self.btn_diamond:loadTextureNormal("hall/huanpi2/main/btn_free_2.png")
        else
            self.btn_diamond:loadTextureNormal("real_res/1000954.png")
        end
    end

    --活动描述
    self.activeLable = ccui.Helper:seekWidgetByName(self.m_pWidget, "activeLable");
    self.active_img = ccui.Helper:seekWidgetByName(self.m_pWidget, "active_img")
    self.active_img:setVisible(false)
    self.activeLable:setVisible(false);

    self.btn_yaoqing = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_yaoqing")
    self.btn_yaoqing:addTouchEventListener(handler(self, self.onClickButton));

    if not IsPortrait then -- TODO
        self.btn_bag = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bag")
        self.btn_bag:addTouchEventListener(handler(self, self.onClickButton));
    end
    self.btn_club = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_club")
    self.btn_club:addTouchEventListener(handler(self, self.onClickButton));
    local refreshClubRedPoint = function()
        local visible = kSystemConfig:isClubApplyChanged()
        local clubBtnSize = self.btn_club:getContentSize()
        if IsPortrait then -- TODO
            Util.createRedPointTip(self.btn_club, visible, cc.p(clubBtnSize.width*0.72, clubBtnSize.height*0.84))
        else
            Util.createRedPointTip(self.btn_club, visible, cc.p(clubBtnSize.width*0.84, clubBtnSize.height*0.84))
        end
    end
    local updateClubRedPoint = cc.EventListenerCustom:create(LocalEvent.ClubApplyRedChange, handler(self, refreshClubRedPoint))
    if IsPortrait then -- TODO
        self.btn_club:getEventDispatcher():addEventListenerWithSceneGraphPriority(updateClubRedPoint, self.btn_club)
    else
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(updateClubRedPoint, self.btn_club)
    end
    refreshClubRedPoint()
    -- self:addClubBtnEffect()

    if not IsPortrait then -- TODO
        self.btn_match_game = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_match_game")
        self.btn_gold_game = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_gold_game")
        if self.btn_match_game then self.btn_match_game:setVisible(false) end
        if self.btn_gold_game then self.btn_gold_game:setVisible(false) end
    end
    if IS_YINGYONGBAO then
        local moeny_bg = ccui.Helper:seekWidgetByName(self.m_pWidget,"money_bg");
        moeny_bg:setVisible(false);
        self.btn_newer:setVisible(false);
        local bg_money  = ccui.Helper:seekWidgetByName(self.m_pWidget,"bg_money")
        if bg_money then bg_money:setVisible(false) end

        local diamond_bg  = ccui.Helper:seekWidgetByName(self.m_pWidget,"diamond_bg")
        diamond_bg:setVisible(false)

        self.btn_yaoqing:setVisible(false)
        if IsPortrait then -- TODO
            self.btn_exchange:setVisible(false)
            self.btn_activity:setVisible(false)
        end
    end
    ---------- 回放相关-------------------
    if kPlaybackInfo:getVideoReturn() then
        scheduler.performWithDelayGlobal(function()
            UIManager:getInstance():pushWnd(RecordDialog);
            end,
        0.3)
        kPlaybackInfo:setVideoReturn(false)
    end
    ------------------------------------

    self.pan_notice = ccui.Helper:seekWidgetByName(self.m_pWidget,"pan_notice")
    self.pan_notice:addTouchEventListener(handler(self,self.onClickButton))
    self.pan_notice:setVisible(false)
    if IsPortrait then -- TODO
        --修改 20171110 start 竖版换皮 分享按钮监听 diyal.yin
        self.btn_share = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_share")
        self.btn_share:addTouchEventListener(handler(self,self.onClickButton))
        if IS_YINGYONGBAO then
            self.btn_share:setVisible(false)
            self.btn_record:getLayoutParameter():setMargin(self.btn_share:getLayoutParameter():getMargin())
        end

        self.btn_room_coin = ccui.Helper:seekWidgetByName(self.m_pWidget,"btn_coin")
        self.btn_room_coin:addTouchEventListener(handler(self,self.onClickButton))

        self.lb_ip = ccui.Helper:seekWidgetByName(self.m_pWidget, "lb_ip");
        --self.lb_ip:setString("IP:".. kUserInfo:getUserIp());

        local refreshPlayerIp = function()
            self.lb_ip:setString("IP:".. kUserInfo:getUserNewIp())
        end

        local updatePlyerIp = cc.EventListenerCustom:create(LocalEvent.PlayerIp, handler(self, refreshPlayerIp))
        self.lb_ip:getEventDispatcher():addEventListenerWithSceneGraphPriority(updatePlyerIp, self.lb_ip)
        refreshPlayerIp()

        --修改 20171110 end

        self:sendPlayerInfo()
    end
    self:showFreeHongDian()
    if IsPortrait then -- TODO
        self:showFreeEffect()
    end
    -- 注册客服监听
    if not IS_YINGYONGBAO then
        self:updateHelp()
    end
    --显示排行榜ui
    self:showRankingUI()

    self:moreBtnTips()
    --邮件红点显示
    self:MailTips()

    --邀请好友红点
    self:InviteBtnTip()

    --钻石特效
    self.img_card = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_card")
    self:starEffect(self.img_card,60,60)

    --创建房间特效
    self:CreateRoomEffect()

    --金币特效
    self.img_coin = ccui.Helper:seekWidgetByName(self.m_pWidget,"img_coin")
    self:starEffect(self.img_coin,40,40)

    --玩家对局数
    self:updateRound()
    if not IsPortrait then -- TODO
        self:regTouchEvent()
    end
    self:onInitClubBtn()

    self:updateFreeActivityUI( )

    -- 尝试提示亲友圈
    if SettingInfo.getInstance():getSelectAreaPlaceID() > 0 then
        self:addQinyouquan()
        self:joinRoomByScheme()
        self:JoinRoomByXianLaiScheme()
    end

    if not IsPortrait then -- TODO
        -- 改变登录/ 更新/ 大厅 界面的logo
        local logo = ccui.Helper:seekWidgetByName(self.m_pWidget, "Image_78")
        if logo then
            Util.changeHallLogo(logo, 0, 10)
        end
    end
    self:initBindBtn()

    local listener = cc.EventListenerCustom:create(LocalEvent.IosScheme, handler(self, self.JoinRoomByXianLaiScheme))
    table.insert(self.Events,listener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

    self:recvPHPActivityData()

    self:haveNewBgimage()
end

-- 是否有新的背景图需要更新
function HallMain:haveNewBgimage()
    if HANENEWBGIMAGE and PRODUCT_ID == 5542 then
        self.bg_image = ccui.Helper:seekWidgetByName(self.m_pWidget, "bg");
        self.bg_image:loadTexture ( "real_res/1000959.png" )
    end
end

-- 初始化绑定手机按钮状态
function HallMain:initBindBtn()
    local data = kGiftData_logicInfo:getTaskByID(AccountStatus.PhoneTaskID)
    if not data or next(data) == nil then
        Log.d("task is nil")
        return
    end
    Log.i("--------initBindBtn :",kGiftData_logicInfo:getUserData())
    self.btn_bind_phone = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bind_phone");
    self.btn_bind_phone:addTouchEventListener(function(pWidget, EventType)
        if EventType ~= ccui.TouchEventType.ended then
            return
        end
        UIManager:getInstance():pushWnd(BindPhone,data.status)
    end);
    local tipsimg = ccui.Helper:seekWidgetByName(self.btn_bind_phone, "img_phone_tips")
    if data.status == AccountStatus.TaskUnDeal then
        self.btn_bind_phone:setVisible(true)
        tipsimg:setVisible(false)
    elseif data.status == AccountStatus.TaskFinish then
        self.btn_bind_phone:setVisible(true)
        tipsimg:setVisible(true)
    elseif data.status == AccountStatus.TaskGiftGet then
        self.btn_bind_phone:setVisible(false)
    else
        Log.e()
    end
end

--添加活动判断
function HallMain:initActivityBtn()
    local bindPhone = self.m_showbind
    if not self.btn_bind_phone then
        self.btn_bind_phone = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_bind_phone");
    end
    local pos = cc.p(self.btn_bind_phone:getPositionX(),self.btn_bind_phone:getPositionY())
    local posX = pos.x + 10
    local posY = pos.y
    if bindPhone then
        posY = pos.y - 130
    end
    if not self.m_actionBtn then
        self.m_actionBtn = ccui.Button:create()
        self.m_actionBtn:loadTextureNormal("hall/huanpi2/liangyouaction/btn_sly.png")
        self.m_actionBtn:addTouchEventListener(handler(self, self.onClickedAction))
        self.m_actionBtn:setTouchEnabled(true)
        self.m_actionBtn:addTo(self.btn_bind_phone:getParent())
    end
    self.m_actionBtn:setPosition(cc.p(posX,posY))
    self.m_actionBtn:setVisible(true)
end


function HallMain:onClickedAction(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        self:openAcitvityView()
	end
end

function HallMain:openAcitvityView(index)
    if not Util.debug_shield_value("openActivity") and not Util.debug_shield_value("closeActivity") then return false end -- 是否开启活动
    -- local activity = kSystemConfig:getDataByKe("php_activity_config")
    local phpVa = kSystemConfig:getPHPActivityList()
    local url = nil
    if phpVa and  phpVa.act_switch and  tonumber(phpVa.act_switch) == 1 and phpVa.act_list and phpVa.act_list ~= "" then
        local sign = crypto.encodeBase64( string.format( "%s|%s",crypto.md5(string.format( "%s%s","ujiE$23S#$%",UUID)),UUID))
        url = string.format( "%s?user_id=%s&&product_id=%s&&user_token=%s&&sign=%s",phpVa.act_list,kUserInfo:getUserId(), PRODUCT_ID,kUserInfo:getUserToken(),sign)
        if self:notCompatible() then
            return true
        end
    else
        local config = kSystemConfig:getDataByKe("config_activity_URL")
        if type(config) == "table" then
            if tostring(config.gaI) == "0" or tostring(config.gaI) == tostring(PRODUCT_ID) then -- 筛选自己省包的配置
                url = config.va
            end
        end
    end
    if type(url) == "string" and string.len(url) > 7 then
        self:openWebView(url, "活动")
        return true
    end
    return false
end


function HallMain:openAcitvityListView(activityData)
    if self:notCompatible() then
        return
    end
    -- local activity = kSystemConfig:getDataByKe("php_activity")
    -- if not activity then
    --     return
    -- end
    -- local va = json.decode(activity.va)
    -- if activity and va and va[1].act_1_address then
        local curUserid = kUserInfo:getUserId()
        local userToken = kUserInfo:getUserToken()
        local sign = crypto.encodeBase64( string.format( "%s|%s",crypto.md5(string.format( "%s%s","ujiE$23S#$%",UUID)),UUID))
        local url = string.format("%s?user_id=%s&product_id=%s&user_token=%s&sign=%s",activityData.login_tips_address,curUserid,PRODUCT_ID,userToken,sign)
        self:openWebView(url, "活动")
        -- return true
    -- end
    -- return false
end

-- 做兼容模式判断
function HallMain:notCompatible()
    if device.platform == "ios" or Util.debug_shield_value("closeActivity") then
        if not COMPATIBLE_VERSION or tonumber(COMPATIBLE_VERSION) < 1 or Util.debug_shield_value("closeActivity") then
            -- self:keyBack()
            local data = {}
            data.type = 2
            data.content = "您需要安装新版本才能使用此功能！请联系客服获取最新下载地址！"
            data.yesCallback = function()
                local data1 = {};
                data1.cmd = NativeCall.CMD_KE_FU;
                data1.uid, data.uname = kUserInfo:getKfUserInfo()
                NativeCall.getInstance():callNative(data1, function()end);
                NativeCallUmengEvent(UmengClickEvent.MoreKeFuOnline)
            end

            data.cancalCallback = function()
            end

            data.closeCallback = function()
            end

            data.yesStr = "联系客服"                               --确定按钮文本
            data.cancalStr = "取消"                            --取消按钮文本
            UIManager:getInstance():pushWnd(CommonDialog, data)

            return true
        end
    end
    return false
end

function HallMain:shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
    if(info.errCode ==0) then --成功
        Toast.getInstance():show("分享成功");
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end

-- 弹出亲友圈指引
function HallMain:addQinyouquan()
    if SettingInfo.getInstance():getClubGuidance() then return end -- 已经提示过, 不再提示
    -- 延迟一定时间后弹窗, 避免popToWnd(HallMain)陷入死循环
    scheduler.performWithDelayGlobal(
        function()
            -- 必须在HallMain界面上才能弹出亲友圈指引
            if UIManager:getInstance():getTopWnd() == self
            and not SettingInfo.getInstance():getClubGuidance() then
                local HallQinyouquanZhiYin = require("app.hall.main.HallQinyouquanZhiYin")
                UIManager:getInstance():pushWnd(HallQinyouquanZhiYin)
            end
        end, 0.2)
end

function HallMain:addClubBtnEffect()
    if self.btn_club then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/main/armature/clubfx.csb")
        local armature = ccs.Armature:create("clubfx")
        local size = self.btn_club:getContentSize()
        armature:setPosition(cc.p(size.width*0.5, size.height*0.55))
        armature:getAnimation():play("clubfx")
        self.btn_club:addChild(armature)
    end
end

-- 招募代理效果
function HallMain:addRecruitAgencyBtnEffect()
    if self.btn_recruit_agency then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall/main/armature/clubfx.csb")
        local armature = ccs.Armature:create("clubfx")
        armature:setScale(0.7)
        local size = self.btn_recruit_agency:getContentSize()
        armature:setPosition(cc.p(size.width*0.5, size.height*0.6))
        armature:getAnimation():play("clubfx")
        self.btn_recruit_agency:addChild(armature)
    end
end


--配置开启游戏时弹出广告图
--isNeedCheckFirst是否检查第一次打开
function HallMain:openAdvertViewDialog(isNeedCheckFirst)
    if OPEN_ADVERTPAGEVIEW then
        local tmpInfo = kServerInfo:getPoAURL()
        local userId = kUserInfo:getUserId()
        Log.i("HallMain:openAdvertViewDialog===tmpInfo====",tmpInfo)
        Log.i("HallMain:openAdvertViewDialog===userId====",userId)
        if tmpInfo and tmpInfo ~= "" and userId then
            local isCanShow = false
            local lastDate = cc.UserDefault:getInstance():getStringForKey("advert_time" .. userId, "0")
            local date = os.date("%Y%m%d%H%M%S", os.time())
            local curDate = string.sub(date,7,8)
            if isNeedCheckFirst then
                if tonumber(lastDate) ~= tonumber(curDate) then
                    isCanShow = true
                end
                Log.i("HallMain:openAdvertViewDialog=======",date,curDate,lastDate)
            else
                isCanShow = true
            end
            if isCanShow then
                UIManager:getInstance():pushWnd(AdvertView_page)
                cc.UserDefault:getInstance():setStringForKey("advert_time" .. userId, curDate)
            end
            if IsPortrait then -- TODO
                local advertView_page = UIManager:getInstance():getWnd(AdvertView_page)
                if advertView_page then
                    advertView_page:getAdvertFromServer()
                end
            end
        end
    end
end

function HallMain:onInitClubBtn()
    if IsPortrait then -- TODO
        return
    end
    if Util.debug_shield_value("club") then
        self.btn_club:setVisible(false)
        self.btn_club:setScale9Enabled(true)
        self.btn_club:setContentSize(cc.size(0, self.btn_club:getContentSize().height))
        ccui.Helper:doLayout(self.btn_club:getParent())
    end
    --[[if G_CLOSE_CLUB or not kSystemConfig:IsClubOwner()and    -- 不是管理员且亲友圈ID不为0
        kSystemConfig:getClubID() ~= 0 then
        local clubBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_club")
        clubBtn:setVisible(false)
    else
        local clubBtn = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_club")
        clubBtn:setVisible(true)
    end]]
end

function HallMain:onShow()
    self:updateUserInfo();

    self:ActivityPosition() --先用默认数据初始化一次位置，收到服务器数据时再刷新一次

    --文字广告
    if kServerInfo:getPaoMaDengTxt() then
        self:showBrocast();
    end

    --图片广告
    if kServerInfo:getMainAdUrl1() then
        self:repServerInfo();
    end
    if IsPortrait then -- TODO
        if kLoginInfo:getIsLogin() and kLoginInfo:checkHasResumeRoom() > 0 then
            LoadingView.getInstance():show("正在恢复牌局",nil,nil, "PlayerGameState")
            kLoginInfo:setIsLogin(false)
        else
            LoadingView.getInstance():show("",nil,nil, "PlayerInfo")
        end
    else
        if kLoginInfo:getIsLogin() and kLoginInfo:checkHasResumeRoom() > 0 then
            LoadingView.getInstance():show("正在恢复牌局")
            kLoginInfo:setIsLogin(false)
        end
    end

    --屏蔽掉当前UI事件,不然广告视图监听不到点击事件
    self.m_pWidget:setTouchEnabled(false);
    self.m_pWidget:setTouchSwallowEnabled(false);
    kLoginInfo:setIsLogin(false)

    if not self:checkInviteInfo() then
        Log.i("hall main onshow send CODE_SEND_YAOQING_INFO")
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_YAOQING_INFO, data);
    end
    local clubdatas = kSystemConfig:getMyClubsInfo()
    if not next(clubdatas) then
        SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_JOINEDCLUBLIST);
    end

    TurnEnterLayer:turn()
    -- self:joinRoomByScheme()
end

function HallMain:joinRoomByScheme()
    if SocketManager.getInstance():getNetWorkStatus() ~= NETWORK_NORMAL then
         Log.i("HallMain:joinRoomByScheme()2")
        return
    end

    Log.i("HallMain:joinRoomByScheme()")

    local data = {}
    data.cmd = NativeCall.CMD_PULL_SCHEMEDATA
    NativeCall.getInstance():callNative(data, function(scheme)

        if kFriendRoomInfo:getRoomId() then
            Toast.getInstance():show("您已进入房间", 3)
            return
        end
        Log.i("--------------获取 SchemeData 成功" , scheme)
        if scheme.model == "room" and tonumber(scheme.param) then
            self.m_enterRoomNum = scheme.param;
            local tmpData={}
            tmpData.pa = tonumber(self.m_enterRoomNum);
            FriendRoomSocketProcesser.sendRoomEnter(tmpData)
        end
    end)
end

function HallMain:JoinRoomByXianLaiScheme()
    if SocketManager.getInstance():getNetWorkStatus() ~= NETWORK_NORMAL then
         Log.i("HallMain:JoinRoomByXianLaiScheme()2")
        return
    end
    Log.i("HallMain:JoinRoomByXianLaiScheme()")
    local data = {}
    data.cmd = NativeCall.CMD_PULL_XIANLIAO_DATA
    NativeCall.getInstance():callNative(data, function(scheme)
        Log.i("==================== HallMainJoinRoomByXianLaiScheme")
        if kFriendRoomInfo:getRoomId() then
            Toast.getInstance():show("您已进入房间", 3)
            return
        end
        Log.i("--------------获取XianLaiScheme 成功2 :" , scheme)
        if tonumber(scheme.roomId) == 0 then
            Log.i("房间号为0不做加入房间处理")
            return
        end
        self.m_enterRoomNum = scheme.roomId;
        local tmpData={}
        tmpData.pa = tonumber(self.m_enterRoomNum);
        FriendRoomSocketProcesser.sendRoomEnter(tmpData)
    end)
end

-- 短线重连后拉取一次进入房间数据
function HallMain:onNetWorkReconnected()
    self:joinRoomByScheme()
    self:JoinRoomByXianLaiScheme()
end

function HallMain:showUnopenFuncTip(funcNameStr)
    local data = {}
    data.type = 1;
    data.content = (funcNameStr and funcNameStr or "") .. "功能暂未开放,敬请期待"
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

function HallMain:updateRound()
    self:checkNewUser()
    local num = tonumber(kLoginInfo:getRoundNum())
    if num < 5 or kLoginInfo:getIsNewer() then          --更换新的账号或是局数小于5的情况
        self.initRoundNum = true
        HallMain:sendPlayerInfo();
    end
end

--新手的判断情况会有一点延迟
function HallMain:initNewr()
    local num = tonumber(kLoginInfo:getRoundNum())     --玩家对局数
    if kLoginInfo:getIsNewer() and
        num < 1 and
        not IS_YINGYONGBAO then
        self.m_NewerType = 1;
        self:showNewer();
        kLoginInfo:setIsNewer(false);
        --UIManager.getInstance():pushWnd(NewerTipsWnd1);
    end
    self:ActivityPosition()
end
--判断是不是第一次记录的用户信息，如果是则默认标记为新手
function HallMain:checkNewUser()
    local id = tonumber(kLoginInfo:getUserId( kUserInfo:getUserId() ))
    if id < 0 then
        print("-----------------checkNewUser",id)
        -- kLoginInfo:setIsNewer(true);
        kLoginInfo:setIsNewer(false);
        kLoginInfo:setUserId(kUserInfo:getUserId())
    end
end

function HallMain:ActivityPosition()
    if tonumber(kLoginInfo:getRoundNum()) >= 5 then   --玩家对局数
        self.btn_newer:setVisible(false)
    else
        self.btn_newer:setVisible(true)
    end
    self.btn_newer:setVisible(false)
end

function HallMain:CreateRoomEffect()
    local stencil = display.newSprite(self.btn_new:getVirtualRenderer():getSprite():getSpriteFrame())
    local clipSize = stencil:getContentSize()
    self.spark = display.newSprite("real_res/1000818.png")
    self.spark:setOpacity(200)
    local clpNode = cc.ClippingNode:create()
    clpNode:setAlphaThreshold(0.05)
    clpNode:setStencil(stencil)                     --底板不会显示出来
    clpNode:addChild(self.spark,1)
    clpNode:addTo(self.btn_new:getParent())
    clpNode:setPosition(cc.p(self.btn_new:getPositionX()-1,self.btn_new:getPositionY()+2))
    local move = cc.MoveBy:create(1.8,cc.p(clipSize.width*2,0))
    local _moveback = cc.Place:create(cc.p(-clipSize.width,0))
    local visibleF  = cc.CallFunc:create(handler(clpNode,function(clpNode) clpNode:setVisible(false) end))
    local visibleT  = cc.CallFunc:create(handler(clpNode,function(clpNode) clpNode:setVisible(true) end))
    local delay = cc.DelayTime:create(3)
    self.spark:runAction(cc.RepeatForever:create(cc.Sequence:create(move,visibleF,delay,visibleT,_moveback)))
    self.spark:setVisible(false)
end

function HallMain:starEffect(pWidget,x,y)
    math.randomseed(os.time())
    local data  = {}
    data.widget = pWidget
    data.x      = x
    data.y      = y

    local romdomSet = cc.CallFunc:create(handler(data,function(data)
        local num = math.random(1,3)
        for i=1,num do
            local spark = display.newSprite("real_res/1000603.png")
            spark:setOpacity(0)
            local delay = cc.DelayTime:create(math.random(3,8)/10)
            local fadein = cc.FadeIn:create(0.5)
            local fadeout = cc.FadeOut:create(0.25)
            local removeself = cc.RemoveSelf:create()
            spark:setPosition(cc.p(math.random(10,data.x), math.random(10,data.y)))
            spark:setScale(math.random(3,8)/10)
            local act = cc.Sequence:create(delay,fadein,fadeout,removeself)
            spark:runAction(act)
            data.widget:addChild(spark)
        end
    end))
    pWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),romdomSet)))
end

function HallMain:moreBtnTips()
    self.btn_more.redIcon = display.newSprite("real_res/1000412.png")
    local hdCs = self.btn_more.redIcon:getContentSize()
    local freeCs = self.btn_more:getContentSize()
    if IsPortrait then -- TODO
        --修改 20171111 start 竖版换皮 更多按钮的红点 diyal.yin
        --修改为统一位置  wenda
        self.btn_more.redIcon:setPosition(cc.p(freeCs.width*hratio,freeCs.height*vratio))
        --修改 20171111 end
    else
        self.btn_more.redIcon:setPosition(cc.p(freeCs.width - 5,freeCs.height-hdCs.height/4))
    end
    self.btn_more.redIcon:setVisible(false)

    if not IsPortrait then -- TODO
        self.btn_more.redIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),visibleJudge)))
    end
    self.btn_more:addChild(self.btn_more.redIcon)
    function self.btn_more.redIcon:setRed(key, value)
        if tolua.isnull(self) then return end
        if self.redKv == nil then self.redKv = {} end
        self.redKv[key] = value
        for k,v in pairs(self.redKv) do
            if v then
                self:setVisible(v)
                return
            end
        end
        self:setVisible(false)
    end
end

function HallMain:InviteBtnTip()
    self.btn_yaoqing.redIcon = display.newSprite("real_res/1000412.png")
    local renderImg = ccui.Helper:seekWidgetByName(self.m_pWidget, "Img_mark")
    if IsPortrait then -- TODO
        renderImg = nil
    end
    if renderImg == nil then renderImg = self.btn_yaoqing end
    local hdCs = self.btn_yaoqing.redIcon:getContentSize()
    local freeCs = renderImg:getContentSize()
    if IsPortrait then -- TODO
        self.btn_yaoqing.redIcon:setPosition(cc.p(freeCs.width*hratio,freeCs.height*vratio))
    else
        self.btn_yaoqing.redIcon:setPosition(cc.p(freeCs.width- 10,freeCs.height-20))
    end
    self.btn_yaoqing.redIcon:setVisible(false)
    renderImg:addChild(self.btn_yaoqing.redIcon)

    local visibleJudge = cc.CallFunc:create(handler(self.btn_yaoqing.redIcon,function(redIcon)
        redIcon:setVisible(kUserInfo:canAwardInvite())
    end))
    self.btn_yaoqing.redIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),visibleJudge)))
end

function HallMain:MailTips()
    -- scheduler.unscheduleGlobal(self.m_getSpeakingThread);   --在离开场景的时候需要停掉它,否则计时器是全局的不会停
    local redIcon = display.newSprite("real_res/1000412.png")
    local hdCs = redIcon:getContentSize()
    local mailIcon = ccui.Helper:seekWidgetByName(self.btn_mail, "Image_mail")
    if IsPortrait then -- TODO
        local freeCs = self.btn_mail:getContentSize()
        redIcon:setPosition(cc.p(freeCs.width -50,freeCs.height-hdCs.height/2))
    else
        local freeCs = mailIcon:getContentSize()
        redIcon:setPosition(cc.p(freeCs.width + 25,freeCs.height-hdCs.height/4))
    end
    redIcon:setVisible(false)

    local visibleJudge = cc.CallFunc:create(handler(redIcon,function(redIcon)
        local _Data = kUserData_userExtInfo:getInstance():getEmailData()
        if IsPortrait then -- TODO
            self.clearDueMail()
        end
        local isvisible = false
        redIcon:setVisible(isvisible)
        for _,v in pairs(_Data) do
            if v.reS0 > 0  or v.reS == 0  then
                isvisible = true
                redIcon:setVisible(isvisible)
                break
            end
        end
        if self.btn_more and self.btn_more.redIcon and self.btn_more.redIcon.setRed then
            self.btn_more.redIcon:setRed("email", isvisible)
        end
        end))

    redIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),visibleJudge)))
    self.btn_mail:addChild(redIcon)
end
--免费红点显示
function HallMain:showFreeHongDian()
    local shareGiftInfo = kGiftData_logicInfo:getShareGift();
    if shareGiftInfo then
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(kUserInfo:getUserId() .. "-" .. shareGiftInfo.Id);
        --Log.i("userGiftInfo.....",userGiftInfo,userGiftInfo.status,self.m_hongdian)
        if userGiftInfo and userGiftInfo.status == 2 then
            --Log.i(".............")
            if self.m_hongdian then
                self.m_hongdian:setVisible(false);
            end
            self.btn_diamond:stopAllActions()
            self.btn_diamond:setVisible(true)
            self.btn_diamond:setScale(1)
            if self.btn_diamond.particleSys and not tolua.isnull(self.btn_diamond.particleSys) then
                self.btn_diamond.particleSys:removeFromParent()
            end
            if self.btn_diamond.mianfeiSprite and not tolua.isnull(self.btn_diamond.mianfeiSprite) then
                self.btn_diamond.mianfeiSprite:removeFromParent()
            end
            self.btn_diamond.particleSys = nil
            self.btn_diamond.mianfeiSprite = nil
            if IsPortrait then -- TODO
                self.btn_diamond:setOpacity(150)
            end
            return;
        else
            if IsPortrait then -- TODO
                self.btn_diamond:setOpacity(255)
            else
                self:showFreeEffect()
            end
        end
    end
end
--免费特效
function HallMain:showFreeEffect()
    if IsPortrait then -- TODO
        if IS_YINGYONGBAO or Util.debug_shield_value("share") then
            self.btn_diamond:setVisible(false)
            return
        end

        local pan_bottom = self.btn_diamond:getParent()
        local freeCs = self.btn_diamond:getContentSize()
        if self.m_hongdian ~= nil then
            self.m_hongdian:removeFromParent()
        end


        local res = "real_res/1000954.png"
        if not (kLoginInfo:isFreeGetDiamound()) then
            res = "real_res/1000118.png"
        end
        self.btn_diamond:loadTextureNormal(res)


        if not (kLoginInfo:isFreeGetDiamound()) then
            return
        end
        --加载特效图
        cc.SpriteFrameCache:getInstance():addSpriteFrames("real_res/1006038.plist")

        self.btn_diamond:stopAllActions()
        -- --红点
        -- self.m_hongdian = display.newSprite("real_res/1000412.png")
        -- local hdCs = self.m_hongdian:getContentSize()
        -- self.btn_diamond:addChild(self.m_hongdian)
        -- self.m_hongdian:setPosition(cc.p(freeCs.width*0.84, freeCs.height*0.84))
        local sequence = transition.sequence({
                        cc.ScaleTo:create(0.4, 0.9),
                        cc.ScaleTo:create(0.4, 1.2),
                        cc.ScaleTo:create(0.4, 1)
        });
        self.btn_diamond:runAction(cc.RepeatForever:create(sequence));

        local sequence_1 = transition.sequence({
            cc.DelayTime:create(2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(false) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(true) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(false) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(true) end),
        });
        self.btn_diamond:runAction(cc.RepeatForever:create(sequence_1))
        if self.btn_diamond.particleSys then
            self.btn_diamond.particleSys:removeFromParent()
            self.btn_diamond.particleSys = nil
        end
        --粒子效果
        self.btn_diamond.particleSys = cc.ParticleSystemQuad:create("real_res/1006029.plist");
        pan_bottom:addChild(self.btn_diamond.particleSys);
        self.btn_diamond.particleSys:setScale(0.7)
        self.btn_diamond.particleSys:setPosition(self.btn_diamond:getPositionX(),self.btn_diamond:getPositionY()+10);
        --动画特效
        local freeX,freeY = self.btn_diamond:getPosition()
        local set_x = 20
        if self.btn_diamond.mianfeiSprite then
            self.btn_diamond.mianfeiSprite:removeFromParent()
            self.btn_diamond.mianfeiSprite = nil
        end
        self.btn_diamond.mianfeiSprite = display.newSprite("#mfeivfx_01.png")
        pan_bottom:addChild(self.btn_diamond.mianfeiSprite,2)
        self.btn_diamond.mianfeiSprite:setPosition(cc.p(freeX + set_x,freeY+10))
        local name = "mfeivfx_"
        self:OnAction(self.btn_diamond.mianfeiSprite,name,30,0.4,0.8)

        self:showFreeHongDian()
    else
        if IS_YINGYONGBAO or Util.debug_shield_value("share") then
            self.btn_diamond:setVisible(false)
            return
        end

        if Util.debug_shield_value("share") then
            self.btn_diamond:setVisible(false)
            return
        end

        local pan_bottom = self.btn_diamond:getParent()
        local freeCs = self.btn_diamond:getContentSize()
        if self.m_hongdian ~= nil then
            self.m_hongdian:removeFromParent()
            self.m_hongdian = nil
        end

        local game_round_num = tonumber(kLoginInfo:getRoundNum())
        if game_round_num < GAME_ROUND_FLAG then
            return
        end
        --加载特效图
        cc.SpriteFrameCache:getInstance():addSpriteFrames("real_res/1006038.plist")
        self.btn_diamond:stopAllActions()

        --红点
        self.m_hongdian = display.newSprite("real_res/1000412.png")
        local hdCs = self.m_hongdian:getContentSize()
        self.btn_diamond:addChild(self.m_hongdian)
        self.m_hongdian:setPosition(cc.p(freeCs.width*0.84, freeCs.height*0.84))
        local sequence = transition.sequence({
                        cc.ScaleTo:create(0.4, 0.9),
                        cc.ScaleTo:create(0.4, 1.2),
                        cc.ScaleTo:create(0.4, 1)
        });
        self.btn_diamond:runAction(cc.RepeatForever:create(sequence));

        local sequence_1 = transition.sequence({
            cc.DelayTime:create(2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(false) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(true) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(false) end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function() self.btn_diamond:setVisible(true) end),
        });
        self.btn_diamond:runAction(cc.RepeatForever:create(sequence_1))

        --粒子效果
        self.btn_diamond.particleSys = cc.ParticleSystemQuad:create("real_res/1006029.plist");
        pan_bottom:addChild(self.btn_diamond.particleSys);
        self.btn_diamond.particleSys:setScale(0.7)
        self.btn_diamond.particleSys:setPosition(self.btn_diamond:getPositionX(),self.btn_diamond:getPositionY()+10);
        --动画特效
        local freeX,freeY = self.btn_diamond:getPosition()
        self.btn_diamond.mianfeiSprite = display.newSprite("#mfeivfx_01.png")
        pan_bottom:addChild(self.btn_diamond.mianfeiSprite,2)
        self.btn_diamond.mianfeiSprite:setPosition(cc.p(freeX,freeY+10))
        local name = "mfeivfx_"
        self:OnAction(self.btn_diamond.mianfeiSprite,name,30,0.4,0.8)
    end
end

function HallMain:OnAction(sprite,imageName,frame,delayTime,delay)
    local frames = display.newFrames(imageName.."%02d.png",0,frame)
    local animation = display.newAnimation(frames, delayTime / frame) -- 0.5s play 20 frames

    local animate = cc.Animate:create(animation)
    local action
    if type(delay) == "number" and delay > 0 then
        local sequence = transition.sequence({
            animate,
            cc.DelayTime:create(delay),
        })
        action = cc.RepeatForever:create(sequence)
    else
        action = cc.RepeatForever:create(animate)
    end
    sprite:runAction(action)
end

--跑马灯
function HallMain:showBrocast()
    local content  = kServerInfo:getPaoMaDengTxt(  )
    local time_interval = kServerInfo:getAdTimeInterval()
    self.lb_notice = ccui.Helper:seekWidgetByName(self.m_pWidget, "lab_notice");
    self.lb_notice:stopAllActions();
    self.lb_notice:setString(content);
    self.pan_notice:setVisible(content and content ~= "")

    self.lb_notice:setPosition(cc.p(display.width , self.lb_notice:getPositionY()));
    local moveX = - display.width - self.lb_notice:getContentSize().width;
    local showTime = -moveX/100;
    local sequence = transition.sequence({
    cc.MoveBy:create(showTime, cc.p(moveX, 0)),
    cc.CallFunc:create(function()
        self.pan_notice:setVisible(false);
    end),
    cc.DelayTime:create(time_interval),
    cc.CallFunc:create(function()
        self:showBrocast();
    end),
    })
    self.lb_notice:runAction(sequence)
end

--返回
function HallMain:keyBack()
    local data = {}
    data.type = 2;
    data.title = "提示";
    data.yesTitle  = "退出";
    data.cancelTitle = "取消";
    data.content = "确定要退出游戏吗？";
    data.yesCallback = function()
        if device.platform == "ios" then
            SocketManager.getInstance():closeSocket();
            kLoginInfo:clearAccountInfo();
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
        else
            MyAppInstance:exit();
        end
    end
    UIManager.getInstance():pushWnd(CommonDialog, data);
end

--获取链接传递的房间号
function HallMain:getEnterCode()
    Log.i("HallMain:getEnterCode() !!!!!!!!!!!!!!!!!!!!!!")
--     --不在房间内
-- --    if not UIManager.getInstance():getWnd(FriendRoomScene) then
--         local data = {};
--         data.cmd = NativeCall.CMD_GET_ENTERCODE;
--         NativeCall.getInstance():callNative(data, HallMain.getEnterCodeCallback, self);
-- --    end
end

function HallMain:getEnterCodeCallback(info)
    Log.i("------getEnterCodeCallback info", info);
    if info and info.enterCode then
        --直接进入房间
        if info.enterCode then
            self.m_enterRoomNum = info.enterCode;
            local tmpData={}
            tmpData.pa = tonumber(info.enterCode);
            FriendRoomSocketProcesser.sendRoomEnter(tmpData)
            -- LoadingView.getInstance():show("正在查找房间,请稍后......");
        end
    end
end

--个人基本信息
function HallMain:repUserInfo1(info)
    Log.i("HallMain:repUserInfo1...")
    if info.code == CODE_TYPE_INSERT then

    elseif info.code == CODE_TYPE_UPDATE then

    end
    self:updateUserInfo();
end

function HallMain:requestWhiteList(url, onFinish)
    local function onReponse(event)
        -- Log.i("onReponse event:",event)
        if not event or event.name ~= "completed" then
            if event.name == "failed" then
                onFinish(-1)
            end
            return;
        end
        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            Log.i("onReponse code:",code)
            onFinish(-1)
            return;
        end
        local responseString = request:getResponseString();
        local tData = json.decode(responseString);
        if not tData then
            Log.i("onReponse tData error appid:",tData)
            onFinish(-1)
            return
        end
        Log.i("onReponse tData:",tData)
        onFinish(0,tData)
    end
    Log.i("url.........",url)
    local request = network.createHTTPRequest(onReponse, url, "GET");
    request:start();
end

--返回网络图片
function HallMain:onResponseNetImg(fileName)
    if fileName == nil then return end
    if fileName == kUserInfo:getUserId() .. ".jpg" then
        self:updateHeadImage(fileName)
    else
        if(self.m_advertView) then  --广告图拉取完成
            self.m_advertView:onResponseNetImg(fileName)
        end
    end
end

function HallMain:updateHeadImage(fileName)
    local headFile = cc.FileUtils:getInstance():fullPathForFilename(fileName);
    if io.exists(headFile) and crypto.md5file(headFile) ~= INVALID_IMAGE_MD5 then
        local headIamge = CircleClippingNode.new(headFile, true , 98)
        headIamge:setPosition(self.img_head:getContentSize().width/2, self.img_head:getContentSize().height/2)
        self.img_head:addChild(headIamge);
    end
end

function HallMain:initHeadImage()
    local imgName = kUserInfo:getUserId() .. ".jpg";
    local headFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
    if io.exists(headFile) and crypto.md5file(headFile) ~= INVALID_IMAGE_MD5 then
        local headIamge = CircleClippingNode.new(headFile, true , 98)
        headIamge:setPosition(self.img_head:getContentSize().width/2, self.img_head:getContentSize().height/2)
        self.img_head:addChild(headIamge);
    else
        if string.len(kUserInfo:getHeadImg()) > 4 then
            HttpManager.getNetworkImage(kUserInfo:getHeadImg(), kUserInfo:getUserId() .. ".jpg");
        end
    end
end

--更新用户信息
function HallMain:updateUserInfo()
    if IsPortrait then -- TODO
        Util.updateNickName(self.nickName, ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 4, "..."), 20)

        --修改 20171114 start 竖版换皮 大厅钻石数字 diyal.yin
        -- self.money:setString("钻石x"..kUserInfo:getPrivateRoomDiamond());
        self.money:setString(""..kUserInfo:getPrivateRoomDiamond());
        --修改 20171114 start 竖版换皮 大厅钻石数字 diyal.yin
    else

    	Util.updateNickName(self.nickName, ToolKit.subUtfStrByCn(kUserInfo:getUserName(), 0, 6, "..."), 20)

        self.money:setString("钻石x"..kUserInfo:getPrivateRoomDiamond());
    end
    self.lb_id:setString("ID:"..kUserInfo:getUserId());
    self:initHeadImage()
    self:updateFreeActivityUI( )
end

function HallMain:updateFreeActivityUI( )
    if(kServerInfo:isFreeActivityOpen()) then --如果有活动
        self.active_img:setVisible(true)
        local free_activty_status = kServerInfo:getActivityStatus()
        self.activeLable:setVisible(free_activty_status == 2)
    else --"N"
        self.activeLable:setVisible(false)
        self.active_img:setVisible(false)
    end
end

--个人扩展信息
function HallMain:repUserInfo2(info)
    ---保存选择的城市id
    if info and info.content and info.content[1].preferredCity then
        local cityId = info.content[1].preferredCity
        SettingInfo.getInstance():setSelectAreaPlaceID(cityId)
        if cityId == 0 then
            SettingInfo.getInstance():setClubGuidance(true) -- 新用户不显示亲友圈提示
        else -- 选择过城市, 提示亲友圈
            self:addQinyouquan()
            self:joinRoomByScheme()
            self:JoinRoomByXianLaiScheme()
        end
    end

end

--个人账户信息
function HallMain:repUserInfo3(info)
    if IsPortrait then -- TODO
        --修改 20171114 start 竖版换皮 大厅钻石数字 diyal.yin
        -- self.money:setString("钻石x"..kUserInfo:getPrivateRoomDiamond());
        self.money:setString(""..kUserInfo:getPrivateRoomDiamond());
        --修改 20171114 start 竖版换皮 大厅钻石数字 diyal.yin
    else
        self.money:setString("钻石x"..kUserInfo:getPrivateRoomDiamond());
    end
    if info.code == CODE_TYPE_UPDATE then
        for k, v in pairs(info.content) do
            ---钻石获得
            if v.privateRoomDiamond then
                if kUserInfo:getPrivateRoomDiamondChange() > 0 then

                    CommonAnimManager.getInstance():showMoneyWinAnim();
                    if IsPortrait then -- TODO
                        self:pushCommonTips(kUserInfo:getPrivateRoomDiamondChange())
                    else
                        Toast.getInstance():show("获得" .. kUserInfo:getPrivateRoomDiamondChange() .. "钻石");
                    end
                end
            end

            ---元宝获得
            if v.paper then
                if kUserInfo:getScripChange() > 0 then
                    local is_yuanbao = true
                    CommonAnimManager.getInstance():showMoneyWinAnim(nil,is_yuanbao);
                    self:pushCommonTips(kUserInfo:getScripChange(), is_yuanbao)
                end
            end
        end
    end

    local payWnd = UIManager.getInstance():getWnd(quickpayment)
    if payWnd and payWnd.updateMyDiamond then
        payWnd:updateMyDiamond()
    end
end


function HallMain:pushCommonTips(diamondNum,is_yuanbao)
    if UIManager.getInstance():getWnd(ActivityDialog) then
        return
    end
    local data = {}
    data.type = 2;
    data.content = str;

    local label = display.newTTFLabel({
    text = "Hello, World",
    font = "Marker Felt",
    size = 64,
    align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
    })

    data.contentNode =  cc.Layer:create()
    local front_label = display.newTTFLabel({
    text = "恭喜成功获得：",
    font = "real_res/1010003.TTF",
    size = 30,
    align = cc.TEXT_ALIGNMENT_CENTER, -- 文字内部居中对齐
    color = cc.c3b(51,51,51),
    })

    local last_label = display.newTTFLabel({
    text = "x"..diamondNum,
    font = "real_res/1010003.TTF",
    size = 30,
    align = cc.TEXT_ALIGNMENT_LEFT, -- 文字内部居中对齐
    color = cc.c3b(51,51,51),
    })
    local img_diamond
    if is_yuanbao then
        img_diamond = cc.Sprite:create("#1000796.png")
    else
        img_diamond = cc.Sprite:create("#1000990.png")
    end

    front_label:setPositionX(front_label:getPositionX() - 150)
    last_label:setPositionX(last_label:getPositionX() + 120 )
    img_diamond:setPositionX(img_diamond:getPositionX() + 20)

    data.contentNode:addChild(front_label)
    data.contentNode:addChild(last_label)
    data.contentNode:addChild(img_diamond)

    UIManager.getInstance():pushWnd(CommonTips, data)

    LoadingView.getInstance():hide();

end

--新手
function HallMain:showNewer()
    if true then
        return
    end
    if not self.m_pan_newer then
        self.m_pan_newer = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_newer");
        self.btn_newer_over = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_over");
        self.btn_newer_enter = ccui.Helper:seekWidgetByName(self.m_pWidget, "pan_btn");
        self.btn_newer_over:addTouchEventListener(handler(self,self.onClickButtonNewer));
        self.btn_newer_enter:addTouchEventListener(handler(self,self.onClickButtonNewer));
        --self.btn_newer_over = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_over");
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
    if self.m_NewerType == 1 then
        self.btn_newer_over:setVisible(false);
    else
        self.btn_newer_over:setVisible(true);
    end
end

--显示排行榜ui
function HallMain:showRankingUI()
	self.btn_ranking = ccui.Helper:seekWidgetByName(self.m_pWidget, "btn_ranking");
	if(_isHaveRankingUI)then --当前游戏是否有排行榜功能

	    self.btn_ranking:addTouchEventListener(handler(self,self.onClickButtonRankingUI));

		local tmpRankingData = kRankingSystem:getRankingMainUIData()
		--##  roRB  int   是否显示主界面房主排行按钮(0:不显示 1:显示 -1:不修改状态)
		if(tmpRankingData~=nil and tmpRankingData.roRB~=nil) then
			Log.i("是否显示主界面房主排行按钮"..tmpRankingData.roRB);
			if(tmpRankingData.roRB==0)then
			  self.btn_ranking:setVisible(false);
			elseif(tmpRankingData.roRB==1)then
			  self.btn_ranking:setVisible(true);
			end
		else
		    self.btn_ranking:setVisible(false);
		end
	else
	    self.btn_ranking:setVisible(false);
	end
end

function HallMain:onClickButtonNewer(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_newer_over then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
                self.m_NewerType = nil;
            end
        elseif pWidget == self.btn_newer_enter then
            if self.m_pan_newer then
                self.m_pan_newer:setVisible(false);
                self:onClickNew();
            end
        end
    end
end

--点击排行榜ui响应方法
function HallMain:onClickButtonRankingUI(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
		RankingSocketProcesser.sendRoomGetRoomInfo();
    end
end

function HallMain:onClickNew()
    if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
        Toast.getInstance():show("服务器即将进行维护! ")
        return
    end
    if not IS_YINGYONGBAO and kLoginInfo:getIsReview() and not kLoginInfo:getLastAccount() then
        SocketManager.getInstance():closeSocket();
        local info = {};
        info.isExit = true;
        UIManager.getInstance():replaceWnd(HallLogin, info);
        Toast.getInstance():show("请用微信登录游戏");
        return;
    end
    if(kUserInfo:getPrivateRoomDiamond() < 1 and kServerInfo:isFreeActivityOpen()==false) then
        -- Toast.getInstance():show("您的钻石不足");
        local data = {}
        data.type = 1;
        local tips = kSystemConfig:getDataByKe("config_noDiamondTips")
		local content = _NoDiamondTips
		if tips and tips.va then
			content = tips.va
		end
        data.content = content; --kServerInfo:getRechargeInfo();
        UIManager.getInstance():pushWnd(CommonDialog, data);
    else
        local data = {};
        data.newerType = self.m_NewerType;
        self.m_NewerType = nil;
        kFriendRoomInfo:setRoomState(CreateRoomState.normal)
        kSystemConfig:cacheEnterData("enterid" , 2)
        UIManager:getInstance():pushWnd(FriendRoomCreate, data);
    end
end

function HallMain:closeMorePanel(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
        if self.morepanel == pWidget or self.btn_closeMorePanel == pWidget then
            self.morepanel:setVisible(false)
        end
    end
end

function HallMain:onClickButton(pWidget, EventType)
    ------------处理部分按钮的显示效果------------
    if pWidget == self.btn_yaoqing and pWidget ~= nil then
        local color = pWidget:isHighlighted() and ccGRAY or ccWHITE
        for i,v in ipairs(pWidget:getChildren()) do
            v:setColor(color)
        end
    end
    ----------------------------------------------
    if EventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn");
        if pWidget == self.btn_new then
            Util.disableNodeTouchWithinTime(pWidget)
            self:onClickNew();
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallCreateRoomButton)
		elseif pWidget == self.btn_join then
            if kServerInfo:getCantEnterRoom() then -- 即将维护, 禁止开局
                Toast.getInstance():show("服务器即将进行维护! ")
                return
            end
            if not IS_YINGYONGBAO and kLoginInfo:getIsReview() and not kLoginInfo:getLastAccount() then
                SocketManager.getInstance():closeSocket();
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);
                Toast.getInstance():show("请用微信登录游戏");
                return;
            end
            Log.i("加入游戏....")
		    UIManager:getInstance():pushWnd(FriendRoomCode);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.JoinRoomButton)
        elseif pWidget == self.btn_record then
            UIManager:getInstance():pushWnd(RecordDialog);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.Record)
        elseif pWidget == self.btn_help then
            local wnd = UIManager:getInstance():pushWnd(Contact_us)
            if self.btn_help and self.btn_help:getChildByName("hongdian") then
                wnd:setKfRed(self.btn_help:getChildByName("hongdian"):isVisible())
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreKeFu)
            --[[if IS_YINGYONGBAO then
                UIManager:getInstance():pushWnd(RuleDialog)
                return
            end

            local data = {};
            data.cmd = NativeCall.;
            data.uid = kUserInfo:getUserId();
            data.uname = kUserInfo:getUserName();
            NativeCall.getInstance():callNative(data, self.openKeFuCallBack, self);]]
        elseif pWidget == self.btn_share then
            if IsPortrait then -- TODO
                if not Util.debug_shield_value("share") then
                    UIManager:getInstance():pushWnd(ShareDialog);
                else
                    Toast.getInstance():show("暂未开放，敬请期待")
                end

                local data = {}
                data.wa = BackEndStatistics.HallShare
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallShareButton)
            else
                if Util.debug_shield_value("share") then
                    Toast.getInstance():show("暂未开放，敬请期待")
                else
                    UIManager:getInstance():pushWnd(ShareDialog);
                end
            end
        elseif pWidget == self.btn_setting then
            UIManager:getInstance():pushWnd(HallSetDialog, 1);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreSettingButton)
        elseif pWidget == self.btn_newer then
            -- UIManager.getInstance():pushWnd(NewerTipsWnd1);
            -- Toast.getInstance():show("暂未开放");
            self.m_NewerType = 2;
            self:showNewer();

        elseif pWidget == self.btn_back then
            UIManager:getInstance():pushWnd(HallBindPhone);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreChangeAccountButton)
        elseif pWidget == self.btn_room_match then
            self:showUnopenFuncTip("比赛场")
        elseif pWidget == self.btn_room_coin then
            self:showUnopenFuncTip("金币场")
        elseif pWidget == self.btn_more then
            self.morepanel:setVisible(not self.morepanel:isVisible())
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreButton)
        elseif pWidget == self.btn_exchange then
            -- self:showUnopenFuncTip("元宝兑换")
--             Toast.getInstance():show("暂未开放，敬请期待")
           if not Util.debug_shield_value("exchange") then
                LoadingView:getInstance():show("数据请求中,请稍候...");
                SocketManager:getInstance():send(CODE_TYPE_MALL,HallSocketCmd.CODE_SEND_MALLINFO,nil)
           else
                Toast.getInstance():show("暂未开放，敬请期待")
           end
           NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.RedPackageExchange)
        elseif pWidget == self.btn_box then
            -- self:showUnopenFuncTip("免费宝箱")
            if not IsPortrait then -- TODO
                UIManager:getInstance():pushWnd(RecruitDialog)
            end
        elseif pWidget == self.btn_task then
            self:showUnopenFuncTip("任务")
        elseif pWidget == self.btn_ruler then
            UIManager:getInstance():pushWnd(RuleDialog);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreRuleButton)
        elseif pWidget == self.btn_diamond_add then
            Log.i("pWidget == self.btn_diamond_add")
            if IS_YINGYONGBAO then return end
            --现在的逻辑就跟以前保持一致了。
            --只要是ios的审核版本就一定打开充值界面
            if IS_IOS then
                --没配置ios的充值列表则必然不打开充值界面
                if type(IosChargeList) == "table" and ChargeIdTool.checkIosLocalConfig() then
                    if not kLoginInfo:getIsReview() then --对于审核版本 一定打开充值界面，不考虑G_OPEN_CHARGE
                        UIManager.getInstance():pushWnd(quickpayment);
                    else
                        --正式版本则由G_OPEN_CHARGE控制是否打开充值界面
                        if G_OPEN_CHARGE and not Util.debug_shield_value("openpay") then
                            UIManager.getInstance():pushWnd(quickpayment);
                        else
                            UIManager.getInstance():pushWnd(Contact_us)
                        end
                    end
                else
                    UIManager.getInstance():pushWnd(Contact_us)
                end
            else
                if G_OPEN_CHARGE and not Util.debug_shield_value("openpay") then
                    UIManager.getInstance():pushWnd(quickpayment);
                else
                    UIManager.getInstance():pushWnd(Contact_us)
                end
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.ChargeButton)
            if not IsPortrait then -- TODO
                local data = {}
                data.wa = BackEndStatistics.DiamondButton
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
            end
        elseif pWidget == self.btn_ad then

        elseif pWidget == self.btn_diamond then
            Log.i("pWidget == self.btn_diamond") -- 免费钻石
            if not IS_YINGYONGBAO then
                UIManager:getInstance():pushWnd(FreeShareDialogDetail);
            else
                Toast.getInstance():show("暂未开放，敬请期待");
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.FreeDiamondCircle)
            if IsPortrait then -- TODO
                local data = {}
                data.wa = BackEndStatistics.DiamondButton
                SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
            end
        elseif pWidget == self.btn_recruit_agency then
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallDaiLiButton)
            if RecruitDialog.hasData() == true then
                UIManager:getInstance():pushWnd(RecruitDialog);
            else
                Toast.getInstance():show("暂未开放，敬请期待");
            end
        elseif pWidget == self.btn_notice then
            -- Toast.getInstance():show("暂未开放");

            local tmpInfo = kServerInfo:getPoAURL()
            if tmpInfo and tmpInfo ~= "" then
				self:openAdvertViewDialog()
			else
				local data = {}
				data.type = 1
				data.content = "暂无公告哦~"
				UIManager:getInstance():pushWnd(CommonDialog,data)
			end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreNoticeButton)
        elseif pWidget == self.btn_yaoqing then
            Log.i("pWidget == self.btn_yaoqing")
            if not IS_YINGYONGBAO and not Util.debug_shield_value("getdiamonds") then
                self.m_isWaitInviteInfo = true
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_YAOQING_INFO, data);
                LoadingView.getInstance():show();
            else
                Toast.getInstance():show("暂未开放，敬请期待");
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.GetDiamondButton)
            local data = {}
            data.wa = BackEndStatistics.HallGetDiamond
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)

        elseif pWidget == self.btn_activity then
            -- if not self:canOpenActivity() then
            --     self:showUnopenFuncTip("活动")
            -- end
            if not self:openAcitvityView() then
                self:showUnopenFuncTip("活动")
            end
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.ActivityButton)
            local data = {}
            data.wa = BackEndStatistics.GetNewShare
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)

        elseif pWidget == self.btn_mail then
            UIManager:getInstance():pushWnd(EmailPanel);
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.MoreMsgButton)
        elseif pWidget == self.img_head then
            if not next(kLoginInfo:getPlayerInfo()) then
                Toast.getInstance():show("正在获取个人信息, 请稍候")
                return
            end
            local agentInfo = kUserInfo:getAgentInfo();
            local agentUrl = kUserInfo:getAgentUrl();
            if agentUrl then
                local data = {};
                data.cmd = NativeCall.CMD_OPEN_URL;
                data.url = agentUrl;
                Log.d("self.img_head CMD_OPEN_URL data.url", data.url);
                NativeCall.getInstance():callNative(data);
            end
            UIManager:getInstance():pushWnd(PlayerPanel)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PersonalCenter)
        elseif pWidget == self.headPanel then
            if not next(kLoginInfo:getPlayerInfo()) then
                Toast.getInstance():show("正在获取个人信息, 请稍候")
                return
            end
            UIManager:getInstance():pushWnd(PlayerPanel)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.PersonalCenter)
        elseif pWidget == self.pan_notice then
            if IS_YINGYONGBAO then
                return
            else
                UIManager:getInstance():pushWnd(NoticeWnd);
            end
        elseif pWidget == self.btn_bag then
            self:showUnopenFuncTip("背包")
        elseif pWidget == self.btn_club then
--             Toast.getInstance():show("暂未开放，敬请期待")
            if IsPortrait then -- TODO
                if Util.debug_shield_value("club") or IS_YINGYONGBAO then
                    Toast.getInstance():show("暂未开放，敬请期待") return
                end
            else
                if Util.debug_shield_value("club") then Toast.getInstance():show("暂未开放，敬请期待") return end
            end

            self.m_isWaitClubInfo = true
            if kSystemConfig:IsClubOwner() then
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_QUERYCLUBINFO);
            else
                SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_JOINEDCLUBLIST);
            end
            LoadingView.getInstance():show();
            if IsPortrait then -- TODO
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.QinYouQuanButton)
            else
                NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.ClubButton)
            end
        end
    end
end

--进入游戏
function HallMain:enterGame(data)
    Log.i("HallMain:enterGame.....")
    local gameInfo = kGameManager:getGameInfo(data.gaI);
    ----------暂时用来测试---------------
    local pathName = gameInfo.clP;

    kLoginInfo:setIsLogin(false)

    local gameName = string.upper(pathName);

    local gameConfig = "package_src.games." .. pathName .. ".GameConfig";
    package.loaded[gameConfig] = nil;

    local isSuccess, errMsg = pcall(require, gameConfig);
    if not isSuccess then
        Toast.getInstance():show("请先下载此游戏！");
        return;
    end

    local gameConfig = "package_src.games." .. pathName .. "." .. gameName .. "Config";
    package.loaded[gameConfig] = nil;
    require(gameConfig);
    enterGame(data);
end

--进入房间结果
function HallMain:repGameStart(packetInfo)
    Log.i("repGameStart", packetInfo);

    LoadingView.getInstance():hide();
    if packetInfo.ty == 0 and packetInfo.re == 1 then
        self:enterGame(packetInfo);
    end
    kLoginInfo:setHasResumeRoom(0)
    kLoginInfo:setIsLogin(false)
end

--恢复游戏对局结果
function HallMain:repResumeGame(packetInfo)
    Log.i("repResumeGame", packetInfo);
    if not IsPortrait then -- TODO
        LoadingView.getInstance():hide();
    end
    if packetInfo.re == 1 then
        packetInfo.roI = self.m_roI;
        packetInfo.gaI = self.m_gaI
        packetInfo.isRusumeGame = true
		kGameManager:enterFriendRoomGame(packetInfo);
        --self:enterGame(data);
    else
        if IsPortrait then -- TODO
            LoadingView.getInstance():hide();
        end
        Toast.getInstance():show("恢复游戏对局失败");
    end

    kLoginInfo:setHasResumeRoom(0)
    kLoginInfo:setIsLogin(false)
end

--通知
function HallMain:repBrocast(packetInfo)
    Log.i("repBrocast", packetInfo);
    if packetInfo.ti == 3 then
        --修改昵称失败
        Toast.getInstance():show(packetInfo.co);
    elseif packetInfo.ti == 4 then
        LoadingView.getInstance():hide();
        SocketManager.getInstance():closeSocket();

        local data = {}
        data.type = 1;
        data.title = "提示";
        data.contentType = COMNONDIALOG_TYPE_KICKED;
        data.content = "您的账号在其它设备登录，您被迫下线。如果这不是您本人的操作，您的密码可能已泄露，建议您修改密码或联系客服处理";
        data.canKeyBack = false
        data.closeCallback = function ()
            if UIManager.getInstance():getWnd(HallMain) then
                -- 在大厅
                local info = {};
                info.isExit = true;
                UIManager.getInstance():replaceWnd(HallLogin, info);
            end
        end
        data.keyBackCallback = data.closeCallback
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif packetInfo.ti == 5 then
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.content = packetInfo.co;
        UIManager.getInstance():pushWnd(CommonDialog, data);
    end
end

function HallMain:repAdTxt(packetInfo)
    if not IS_YINGYONGBAO then
        kServerInfo:setAdTxt(packetInfo.co);
        self:showBrocast();
    end
end

--朋友开房
function HallMain:onClickFriendRoom(pWidget, EventType)
    if EventType == ccui.TouchEventType.ended then
	    self.m_startGameType=2;--标示点击了开始朋友开房游戏
		local tmpData={}
		HallSocketProcesser.sendPlayerGameState(tmpData)
    end
end

--接收朋友开房信息
function HallMain:recvFriendRoomStartGame(packetInfo)
 	Log.i("------HallMain recvFriendRoomStartGame", packetInfo);
	kFriendRoomInfo.m_isFriendRoom = StartGameType.FIRENDROOM --设置游戏是从朋友开房进入

	local data = {};
	data.plI = packetInfo.plI;
	SocketManager.getInstance():send(CODE_TYPE_GAME, HallSocketCmd.CODE_SEND_RESUMEGAME, data);
end

--充值结果
function HallMain:recChargeResult(info)
    LoadingView.getInstance():hide();
    --Toast.getInstance():show("购买成功");
    kChargeListInfo:dalateApplePayInfo(info.orI)
end

--获取订单号
function HallMain:recOrder(info)
    LoadingView.getInstance():hide();
    kGameManager:reCharge(info);
end

--恢复游戏对局
function HallMain:recvPlayerGameState(packetInfo)
    --##  gaT  int   游戏类型(0:大厅  1:朋友房 2:邀请房）
    Log.i("HallMain:recvPlayerGameState.....", packetInfo)
    if IsPortrait then -- TODO
        LoadingView.getInstance():hide("PlayerGameState");
    end
    if packetInfo.gaT == 0 then
        if not IsPortrait then -- TODO
            LoadingView.getInstance():hide();
        end
        -- return
    else
        LoadingView.getInstance():show("正在恢复牌局")
    end

    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        LoadingView.getInstance():hide();
        return;
    end

--[[
    if 4 == packetInfo.gaT then--房间内
        UIManager.getInstance():popToWnd(HallMain);
        LoadingView.getInstance():hide();
        loadGame(packetInfo.gaI)
        UIManager:getInstance():pushWnd(FriendRoomScene);
	elseif 5 == packetInfo.gaT then--游戏内
        UIManager.getInstance():popToWnd(HallMain);
	    self.m_gaI = packetInfo.gaI;
        self.m_roI = packetInfo.roI;
        self.m_plI = packetInfo.plI;
	    local tmpData = {};
        loadGame(packetInfo.gaI)
	    FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);
    else
        self:getEnterCode();
	end
    ]]

    if self.btn_new and self.btn_new.setHighlighted then self.btn_new:setHighlighted(false) end
    if self.btn_join and self.btn_join.setHighlighted then self.btn_join:setHighlighted(false) end

    if 1 == packetInfo.gaT or 4 == packetInfo.gaT or 5 == packetInfo.gaT then -- 4 5是为了兼容以前的逻辑 等4 5 有新的含义的时候要更改逻辑
        if packetInfo.plI == nil or packetInfo.plI == "" then--房间内
            UIManager.getInstance():popToWnd(HallMain);
            LoadingView.getInstance():hide();
            loadGame(packetInfo.gaI)
            UIManager:getInstance():pushWnd(FriendRoomScene);
        else
            UIManager.getInstance():popToWnd(HallMain);
            self.m_gaI = packetInfo.gaI;
            self.m_roI = packetInfo.roI;
            self.m_plI = packetInfo.plI;
            local tmpData = {};
            loadGame(packetInfo.gaI)
            FriendRoomSocketProcesser.sendFriendRoomStartGame(tmpData);
        end
    else
        self:getEnterCode();
    end
end

local function showCloseServerTime(info)
    local time = info.neSDT - info.syT          --计算出时间差
    --如果事件
    if time<=0 then
        return
    end

    local m = math.floor(time/1000/60)     --得到还剩多少分钟
    local h = math.floor(m/60)             --得到还剩多少小时

    if h < 1 and m>0 and m<60 then
        content = string.format("亲爱的玩家，您好！游戏将于%s分钟后停服维护，敬请提前下线",m)
    elseif h>=1 and m>=60 then
        local nesDTime = os.date("%H:%M",info.neSDT/1000)
        content = string.format("亲爱的玩家，您好！游戏将于%s停服维护，敬请提前下线",nesDTime)
    end

    local data = {}
    data.type = 1
    data.content = content
    UIManager.getInstance():pushWnd(CommonDialog,data)
end

-- 功能:       初始化广告面板
-- 返回:       无
function HallMain:initAdvertView()
    local imgName = kServerInfo:getMainAdUrl1();
    if ( not imgName or imgName == "") then return end
    --这里会创建多次,当广告图视窗已经存在的时候,先清掉以前的,再创建新的。
    if self.m_advertView ~= nil then
        self.m_advertView:removeFromParent()
        self.m_advertView = nil
    end

    self.m_advertView = AdvertView.new();
    self.m_advertView:setVisible(false)
    self.m_advertView:setFinishCallBack( function()
        self.btn_ad:setVisible(false)
        self.m_advertView:setVisible(true)
    end);

    self.m_advertView:initAdvert();
    -- debugDraw(self.m_pan_ad)
    self.m_pan_ad:addChild(self.m_advertView);

    local callBack = function()
        local AdvertViewDialog = UIManager.getInstance():getWnd(AdvertViewDialog)
        if  AdvertViewDialog then
            AdvertViewDialog:updateWechatId()
        end
        if not tolua.isnull(self.m_advertView) then
            self.m_advertView:updateWechatId()
        end
    end
    kUserData_userExtInfo:setAddWeChatID(callBack)
end

--服务器配置信息
function HallMain:repServerInfo(packetInfo)
    Log.i("HallMain:repServerInfo......",packetInfo)
    if IsPortrait then -- TODO
        ---initAdvertView不要放到return 后面
        self:initAdvertView()
        if not packetInfo then return end
        if packetInfo.syT then
            kSystemConfig:setTimeOffset(packetInfo.syT)
        end
        if packetInfo.neSDT and packetInfo.neSDT ~= 0 then
            showCloseServerTime(packetInfo)
        end

        self:openAdvertViewDialog(true)

        -- 下载与合成微信分享图片
        local info = kServerInfo:getDayShareInfo()
        info.shareType = "1" -- 暂时写死, 使用文本方式分享
        ShareToWX.getInstance():prepare(info)
    else
        local imgName = kServerInfo:getMainAdUrl1();
        if(imgName~=nil and imgName~="") then
            self.m_advertView = AdvertView.new();
            self.m_advertView:setFinishCallBack(handler(self,self.onCreatePageViewFinish));
            --开始拉取网络图片。等所有图片拉完毕才能创建相就视图。
            self.m_advertView:getAdvertFromServer();
            self.m_pan_ad:addChild(self.m_advertView);
        end
        if not packetInfo then return end
        if packetInfo.syT then
            kSystemConfig:setTimeOffset(packetInfo.syT)
        end

        if packetInfo.neSDT and packetInfo.neSDT ~= 0 then
            showCloseServerTime(packetInfo)
        end

        --刷新登录广告数据
        self:openAdvertViewDialog(true)

        -- 招募代理初始化数据
        if packetInfo.reS then
            RecruitDialog.initData(packetInfo.reS)
        end

        -- 下载与合成微信分享图片
        local info = kServerInfo:getDayShareInfo()
        ShareToWX.getInstance():prepare(info)
    end

    self:recvPHPActivityData()
end


--请求php数据
function HallMain:recvPHPActivityData()
    local phpVa = kSystemConfig:getPHPActivityList()


    local function onFinish(nErrorCode,tData)
        if nErrorCode == -1 or tData.status ~= 0 then
           return
        end
        self.m_activityData = tData
        Log.d("self.m_activityData....",self.m_activityData)
        self:initLiangYouInf(self.m_activityData)
    end
    if phpVa and phpVa.act_switch and tonumber(phpVa.act_switch) == 1 and phpVa.act_request and table.nums(phpVa.act_request) > 0 then
        local phpLogin = phpVa.act_request
        if phpLogin and phpLogin.login and phpLogin.login ~= "" then
            local url = string.format( "%s?user_id=%s&product_id=%s&user_token=%s",phpLogin.login,kUserInfo:getUserId(),PRODUCT_ID,kUserInfo:getUserToken())
            self:requestWhiteList(url, onFinish)
        end
    end
end

--拉取网络广告图片完成后，把默认的隐藏。
function HallMain:onCreatePageViewFinish()
   Log.i("onCreatePageViewFinish")
   self.btn_ad:setVisible(false)
end

--邀请房信息（创建成功， 回复已创建房间） -- 魔窗登录?
function HallMain:recvRoomSceneInfo(packetInfo)
    Log.i("HallMain:recvRoomSceneInfo",packetInfo)

    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        LoadingView.getInstance():hide();
        return;
    end

    if self.m_enterRoomNum then
        LoadingView.getInstance():hide();
        self.m_enterRoomNum = nil;
        local data = {};
        data.isFirstEnter = true;
        UIManager.getInstance():popToWnd(HallMain);
        Log.i("enter")
        loadGame(packetInfo.gaID)
        UIManager:getInstance():pushWnd(FriendRoomScene,data);
    else
        LoadingView.getInstance():show("正在进入房间，请稍后...");
    end
end

--邀请房配置
function HallMain:recvRoomConfig(packetInfo)
    self:updateFreeActivityUI( )

    --不是正在提审的包，强制切换到微信登录
    if kFriendRoomInfo:getReViewVersion() ~= VERSION then
        kLoginInfo:setIsReview();

        if not IS_YINGYONGBAO and not kLoginInfo:getLastAccount() then
            SocketManager.getInstance():closeSocket();
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
            Toast.getInstance():show("请用微信登录游戏");
            return;
        end
    end
end

function HallMain:recvGetRoomEnter(packetInfo)
    --## re  int  结果（-2 = 无可用房间，1 成功找到）
    if(-1 == packetInfo.re) then
        LoadingView.getInstance():hide();
        Toast.getInstance():show("人数已满");
    elseif(-2 == packetInfo.re) then
        LoadingView.getInstance():hide();
        local data = {}
        data.type = 1;
        data.title = "提示";
        data.closeTitle = "房间";
        data.content = "房间不存在";
        UIManager.getInstance():pushWnd(CommonDialog, data);
    elseif(-3 == packetInfo.re) then
        Toast.getInstance():show("钻石不足!")
    elseif(-4 == packetInfo.re) then
        Toast.getInstance():show("您不是该亲友圈亲友");
    elseif(-5 == packetInfo.re) then
        Toast.getInstance():show("已在其他房间中");
    elseif(-6 == packetInfo.re) then
        -- Toast.getInstance():show("重复加入相同房间");
    elseif (-7 == packetInfo.re) then
        Toast.getInstance():show("服务器关服倒计时中");
    elseif packetInfo.re == 1 then
        kFriendRoomInfo:saveNumber(self.m_enterRoomNum or packetInfo.pa);
    end
end

-- 礼包数据
function HallMain:onRecvGiftInfo(info)
    self:showFreeHongDian()
    self:initBindBtn()
    local commonDialog = UIManager.getInstance():getWnd(CommonDialog);
    if commonDialog and (commonDialog:getContentType() == COMNONDIALOG_TYPE_NETWORK
        or commonDialog:getContentType() == COMNONDIALOG_TYPE_KICKED) then
        LoadingView.getInstance():hide();
        return;
    end
    if info.code == CODE_TYPE_UPDATE then
        for k, v in pairs(info.content) do
            if v.status == 2 and v.keyID == kGiftData_logicInfo:getShareGiftKeyId() then
                UIManager.getInstance():popToWnd(HallMain);
            end
        end
    end
end

-- 客服回调
function HallMain:openKeFuCallBack(info)
    Log.i("openKeFuCallBack info", info);
    if info.errCode == 1 then
        -- Toast.getInstance():show("连接在线客服成功");
    else
        Toast.getInstance():show("无法连接在线客服");
        UIManager:getInstance():pushWnd(RuleDialog);
    end
end

--不断刷新客服红点显示内容
function HallMain:updateHelp()

    local hongdian = display.newSprite("real_res/1000412.png")
    local hdCs = hongdian:getContentSize()
    local kfCs = self.btn_help:getContentSize()
    if IsPortrait then -- TODO
        --修改 20171110 start 竖版换皮 客服红点
        -- self.btn_help:addChild(hongdian)
        -- hongdian:setPosition(cc.p(kfCs.width - 50, kfCs.height-hdCs.height/2 ))
        local node_Image_ruler = self.btn_help:getChildByName("Image_ruler")
        local node_Image_ruler_size = self.btn_help:getChildByName("Image_ruler"):getContentSize()
        node_Image_ruler:addChild(hongdian)
        hongdian:setPosition(cc.p(node_Image_ruler_size.width,
            node_Image_ruler_size.height-hdCs.height/2 ))
        --修改 20171110 end
    else
        self.btn_help:addChild(hongdian)
        hongdian:setPosition(cc.p(kfCs.width - 165, kfCs.height-hdCs.height - 1))
    end
    hongdian:setName("hongdian")
    hongdian:setVisible(false)

    local update = cc.CallFunc:create(function()
        local data = {}
        data.cmd = NativeCall.CMD_KE_FU_REFRESH
        NativeCall.getInstance():callNative(data, self.kefuCallBack, self)
    end)
    self.btn_help:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),update)))
    local listener = cc.EventListenerCustom:create(LocalEvent.HallCustomerService, handler(self, self.getKeFuHongDian))
    table.insert(self.Events,listener)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
end

function HallMain:kefuCallBack(result)
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = result
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end
-----------------
-- 客服红点提示
-- @Table result {cmd = NativeCall.CMD_KE_FU_REFRESH, count = @int}
function HallMain:getKeFuHongDian(event)
    local hongdianNum = math.floor(tonumber(event._userdata.count) or 0)
    local hongdian = self.btn_help:getChildByName("hongdian")
    if  hongdian then
        if hongdianNum > 0 then
            hongdian:setVisible(true)
        else
            hongdian:setVisible(false)
        end
    else
        -- print("[ ERROR ] HallMain:getKeFuHongDian by linxiancheng ")
    end
end

--接收排行榜UI数据
function HallMain:recvRankingData(packetInfo)
	local tmpui = UIManager.getInstance():getWnd(RankingMatchUI);
	if(tmpui~=nil)then
	   Log.i("更新排行榜UI");
	   tmpui:onShow();--更新Ui
	else
	   Log.i("打开排行榜UI");
	   UIManager:getInstance():pushWnd(RankingMatchUI,packetInfo);
	end
end

function HallMain:rankingDispose()
    local tmpRankingData = kRankingSystem:getRankingMainUIData()
    --##  raR  int   是否可领排行榜奖励(0:不可以领 1:可以领)
    if(tmpRankingData~=nil and tmpRankingData.raR~=nil and self.btn_ranking~=nil) then
        Log.i("是否可领排行榜奖励"..tmpRankingData.raR);
        local redPointPos=cc.p(85,95);
        if(tmpRankingData.raR==0) then
           Util.createRedPointTip(self.btn_ranking,false,redPointPos);
        else
           Util.createRedPointTip(self.btn_ranking,true,redPointPos);
        end
    end

    --##  roRB  int   是否显示主界面房主排行按钮(0:不显示 1:显示 -1:不修改状态)
    if(tmpRankingData~=nil and tmpRankingData.roRB~=nil and self.btn_ranking~=nil) then
        Log.i("是否显示主界面房主排行按钮"..tmpRankingData.roRB);
        if(tmpRankingData.roRB==0)then
          self.btn_ranking:setVisible(false);
            --检测玩家是否在排行榜内
            local tmpUI = UIManager.getInstance():getWnd(RankingMatchUI);
            if(tmpUI~=nil)then
                local data = {}
                data.type = 1;
                data.title = "提示";
                data.closeTitle = "关闭提示";
                data.content = "房主争霸活动已结束!"
                data.closeCallback = function()
                    UIManager.getInstance():popToWnd(HallMain)
                end
                UIManager.getInstance():pushWnd(CommonDialog, data);
            end

        elseif(tmpRankingData.roRB==1)then
          self.btn_ranking:setVisible(true);
        end
    end
end

function HallMain:repHallRefreshUI(info)
    local event = cc.EventCustom:new(LocalEvent.UpdateClubState)
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    if self.btn_focusDiamond and info.weF then
        if info.weF == 0 then
            self.btn_focusDiamond:setVisible(true)
        else
            self.btn_focusDiamond:setVisible(false)
        end
    end
    if info.frFS and info.frFMT then
        kServerInfo:setActivityStatus(info.frFS)
        kServerInfo:setActivityContent(info.frFMT)
    end
    self:updateFreeActivityUI( )

end

function HallMain:repClubRefreshUI(info)
    self:onInitClubBtn()
end

function HallMain:sendPlayerInfo()
    local data = {};
    data.recUserId = kUserInfo:getUserId();
    data.gaI = kFriendRoomInfo:getRoomBaseInfo().gameId;
    SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_USERDATA, data);
end
--接收到消息后再去创建ui
function HallMain:recPlayerInfo(packetInfo)
    kLoginInfo:setRoundNum(packetInfo.plA)
    kLoginInfo:setPlayerInfo(packetInfo)

    if IsPortrait then -- TODO
        LoadingView.getInstance():hide("PlayerInfo")

        self:showFreeEffect()
        if self.initRoundNum then
            self.initRoundNum = false
            self:initNewr()
            return
        end
        local tmpui = UIManager.getInstance():getWnd(PlayerPanel);
        if(tmpui~=nil)then
           Log.i("更新玩家信息UI");
           tmpui:onShow();--更新Ui
        -- else
        --    Log.i("打开玩家信息UI");
        --    UIManager:getInstance():pushWnd(PlayerPanel,packetInfo);
        end
    else
        local game_round_num = tonumber(kLoginInfo:getRoundNum())
        if game_round_num < GAME_ROUND_FLAG then
            self.btn_diamond:loadTextureNormal("hall/huanpi2/main/btn_free_2.png")
        else
            self.btn_diamond:loadTextureNormal("real_res/1000954.png")
        end
        -- 免费红点显示
        self:showFreeHongDian()

        if self.initRoundNum then
            self.initRoundNum = false
            self:initNewr()
            return
        end
    end
end

--[[function HallMain:openSelectCityUI(data)
    local data = data
    if data and data.ciL and #data.ciL > 0 then
        -- 增加对一些麻将不在选择地区中显示的控制
        for i = #data.ciL, 1, -1 do
            local tdhIdx = string.find(data.ciL[i].ciN, "推倒胡")
            local huanghuangIdx = string.find(data.ciL[i].ciN, "晃晃")
            local hongzhongIdx = string.find(data.ciL[i].ciN, "红中")
            if tdhIdx and NOT_DISPLAY_TUIDAOHU then
                table.remove(data.ciL, i)
            end
            if huanghuangIdx and NOT_DISPLAY_HUANGHUANG then
                table.remove(data.ciL, i)
            end
            if hongzhongIdx and NOT_DISPLAY_HONGZHONG then
                table.remove(data.ciL, i)
            end
        end

        -- 增加NOT_SELECT_CITY不弹出选择地区判断
        if #data.ciL == 1 or NOT_SELECT_CITY then
            SettingInfo.getInstance():setSelectAreaGameID(data.ciL[1].gaID)
            HallSocketProcesser.sendSelectCity({gaI = data.ciL[1].gaID})
        else
            UIManager:getInstance():pushWnd(SelectCityWnd, data)
        end
    end
end]]

function HallMain:openSelectCityUI(data)
    --if true then return end
    if not data.ciL or #data.ciL == 0 then
        return
    end

    for i=#data.ciL, 1, -1 do
        if not data.ciL[i].plL or #data.ciL[i].plL==0 then
            table.remove(data.ciL, i)
        end
    end

    if #data.ciL == 0 then
        return
    end

--    kLoginInfo:setIsNewer(true);
    -- 增加NOT_SELECT_CITY不弹出选择地区判断
    if (#data.ciL == 1 and #data.ciL[1].plL==1) or NOT_SELECT_CITY then
        HallSocketProcesser.sendSelectCity({ciI = data.ciL[1].plL[1].plID})
        SettingInfo.getInstance():setSelectAreaPlaceID(data.ciL[1].plL[1].plID)
    else
        if IsPortrait then -- TODO
            self:openAdvertViewDialog()
        end
        UIManager:getInstance():pushWnd(require("app.hall.wnds.selectCity.SelectProvinceCityWnd"), data)
    end
end

function HallMain:checkInviteInfo()
    return kUserInfo:getInviteInfo() ~= nil
end

function HallMain:clearDueMail()
    local _Data = kUserData_userExtInfo:getInstance():getEmailData()
    for i = #_Data,1,-1 do
        -- print(os.date("2-------------------------/%Y-%m-%d-/%H:%M:%S",_Data[i].enT))
        if _Data[i].enT ~= 0 and os.time() > _Data[i].enT then
            table.remove(_Data,i)     --_Data和单例中的table是同一份内存
        end
    end
end

function HallMain:recClubInfo()
    if Util.debug_shield_value("club") or not self.m_isWaitClubInfo then return end
    LoadingView.getInstance():hide();
    -- UIManager.getInstance():pushWnd(MyClub, nil);
    local ownerClubInfo = kSystemConfig:getOwnerClubInfo()
    if ownerClubInfo.clubID == 0 or ownerClubInfo.clubID == nil then
        if #kSystemConfig:getMyClubsInfo() > 0 then
            local ClubJoinedWnd = require("app.hall.wnds.club.clubJoinedWnd")
            UIManager.getInstance():pushWnd(ClubJoinedWnd);
        else
            UIManager.getInstance():pushWnd(Club);
        end
    else
        UIManager.getInstance():pushWnd(MyClub, ownerClubInfo);
    end
end

function HallMain:openInviteWnd()
    if UIManager:getInstance():getWnd(InviteFriendView) == nil then
        local inviteInfo = checktable(kUserInfo:getInviteInfo())
        if inviteInfo["reL"] == nil or #(inviteInfo["reL"]) <= 0 then
            Toast.getInstance():show("服务器数据为空");
            return
        end
        UIManager:getInstance():pushWnd(InviteFriendView, inviteInfo);
    end
end

-- 收到服务器数据返回创建兑换商城
function HallMain:recMallInfo(infoPacket)
    LoadingView.getInstance():hide();
    UIManager.getInstance():pushWnd(Mall,infoPacket)
end

function HallMain:onRepYaoingInfo(info)
    if self.m_isWaitInviteInfo then
        self.m_isWaitInviteInfo = false
        LoadingView.getInstance():hide();
        self:openInviteWnd()
    end
end

function HallMain:onRepLogin()
    HttpManager.getLocalNetworkIP()
end

function HallMain:recvRoomCreate(packetInfo)
    ------##  re  int  结果（-1 =钻石不足，-2 = 无可用房间，1 成功）
    local tmpData= packetInfo
    if(-1 == tmpData.re) then
        if tmpData.clI == nil or tmpData.clI == 0 then
            -- Toast.getInstance():show("您的钻石不足,请充值!");
        else
            Toast.getInstance():show("该亲友圈钻石不足！");
        end
        LoadingView.getInstance():hide();
    elseif(-2 == tmpData.re) then
        Toast.getInstance():show("无可用房间!");
        LoadingView.getInstance():hide();
    elseif(-3 == tmpData.re) then
        Toast.getInstance():show("数据错误,请联系在线客服!");
        LoadingView.getInstance():hide();
    elseif(-4 == tmpData.re) then
        Toast.getInstance():show("你还未加入该亲友圈!");
        LoadingView.getInstance():hide();
    elseif (-5 == tmpData.re) then
        Toast.getInstance():show("服务器即将进行维护!");
        LoadingView.getInstance():hide();
    elseif(1==tmpData.re) then
        Log.i("等待获取房间信息才能进入房间。。。。。")
    elseif (-6 == tmpData.re) then
        local data = {}
        data.type = 2;
        data.textSize = 30
        data.title = "提示";
        data.yesStr = "是"
        data.cancalStr = "联系客服"
        data.content = string.format("您的房间信息异常，您已在房间%s内登陆，是否重新登陆恢复。",tmpData.roI);
        data.subjoin = string.format( "您的游戏id为%s",kUserInfo:getUserId())
        data.handle = "(复制)"
        data.yesCallback = function()
            -- MyAppInstance:exit()
            SocketManager.getInstance():closeSocket()
            local info = {};
            info.isExit = true;
            UIManager.getInstance():replaceWnd(HallLogin, info);
            SocketManager.getInstance():openSocket()
        end
        data.cancalCallback = function ()
            self:onOpenKf()
        end
        UIManager.getInstance():pushWnd(CommonDialog, data);
        LoadingView.getInstance():hide()
    end
end

function HallMain:onOpenKf()

    -- local listener = cc.EventListenerCustom:create(LocalEvent.HallCustomerService, handler(self, self.getKeFuHongDian))
    -- table.insert(self.Events, listener)
    -- cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

    -- local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    -- event._userdata = {count = 0}
    -- cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    local data = {};
    data.cmd = NativeCall.CMD_KE_FU;
    data.uid, data.uname = self.getKfUserInfo()
    NativeCall.getInstance():callNative(data, self.kefuCallBack, self)
end

function HallMain:kefuCallBack(result)
    local event = cc.EventCustom:new(LocalEvent.HallCustomerService)
    event._userdata = result
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function HallMain:getKfUserInfo()
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

-- 可否开启活动并弹框
function HallMain:canOpenActivity()
    -- if not Util.debug_shield_value("openActivity") then return false end -- 是否开启活动
    local config = kSystemConfig:getDataByKe("config_activity_URL")
    local url
    if type(config) == "table" then
        if tostring(config.gaI) == "0" or tostring(config.gaI) == tostring(PRODUCT_ID) then -- 筛选自己省包的配置
            url = config.va
        end
    end
    Log.i("openActivity url", tostring(url))
    if type(url) == "string" and string.len(url) > 7 then
        self:openWebView(url, "活动")
        return true
    end
    return false
end

local function supportWebView()
    if device and (device.platform == "windows" or device.platform == "mac") then
        return true
    end
    if ccexp and ccexp.WebView then return true end
    return false
end

function HallMain:openWebView(url, title)
    if not supportWebView() then
        local data = {}
        data.cmd = NativeCall.CMD_OPEN_URL
        data.url = url
        NativeCall.getInstance():callNative(data)
        return
    end

    local data = {}
    data.url = url or _forceUpdateUrl
    data.title = title or "活动"
    data.callback = function()
        Log.i("HallMain:openWebView callback")
    end
    data.parent = self
    data.obj = self
    UIManager.getInstance():pushWnd(ActivityDialog, data)
end

function HallMain:initLiangYouInf(actTipsData)
    -- if kUserInfo:getActivityPub() == nil then
    --     return
    -- end
    if actTipsData.data ~= nil and table.nums(actTipsData.data) > 0 then
        local data = {}
        data = actTipsData.data
        data.parent = self
        UIManager:getInstance():pushWnd(LiangYouActivity,data,1)
        if data.act_tips_msg and data.act_tips_msg ~= "" then
            self:showActivionTips(data.act_tips_msg)
        else
            local activityTips_bg = self.btn_activity:getChildByName("activityTips_bg")
            if activityTips_bg then
                activityTips_bg:removeFromParent()
            end
        end
        if data.red_point and tonumber(data.red_point) == 1 then
            self:showActivionHongDian()
        else
            local redIcon = self.btn_activity:getChildByName("redIcon")
            if redIcon then
                redIcon:removeFromParent()
            end
        end
    end
end


function HallMain:shareActivity(atgTable)
    if not atgTable then
        return
    end
    LoadingView.getInstance():show("正在分享,请稍后...", 1);
    -- local activity = kSystemConfig:getDataByKe("php_activity")
    -- if not activity then
    --     return
    -- end
    -- local va = json.decode(activity.va)
    local data = {}
    data.url = _WeChatSharedBaseUrl
    data.shardMold = atgTable.activityType
    data.headUrl = kFriendRoomInfo:getRoomBaseInfo().dwShareTitle; --kUserInfo:getHeadImgSmall()
    WeChatShared.getWechatShareInfo(WeChatShared.ShareType.FRIENDS, WeChatShared.ShareContentType.PICTURE, WeChatShared.SourceType.CLUB_QR_FRIEND, handler(self, self.shareResult), ShareToWX.ClubQRShareFriend,data)
end

function HallMain:shareResult(info)
    Log.i("shard button:", info);
    LoadingView.getInstance():hide();
    if(info.errCode ==0) then --成功
        Toast.getInstance():show("分享成功");
    elseif (info.errCode == -8) then
        Toast.getInstance():show("您手机未安装微信");
    else
        Toast.getInstance():show("分享失败");
    end
end

--创建活动提示
function HallMain:showActivionTips(act_tips_msg)
    -- local activtyBtnPosX = self.m_actionBtn:getPositionX()
    -- local activtyBtnPosY = self.m_actionBtn:getPositionY()
    local activityTips_bg = self.btn_activity:getChildByName("activityTips_bg")
    if activityTips_bg then
        activityTips_bg:removeFromParent()
    end
    local labelString = act_tips_msg
    local label = display.newTTFLabel( {
        text = labelString,
        font = lFontFilePath,
        size = 30,
        color = cc.c3b(248,232,168),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
    } )

    local activitySize = self.btn_activity:getContentSize()
    -- local activtyTips_bg = display.newScale9Sprite("real_res/1000575.png",
    --                                                 activitySize.width/2, activitySize.height + 30,
    --                                                  cc.size(label:getContentSize().width + 30, 60),
    --                                                  cc.rect(30,20,10,1))
    local activityTips_bg = ccui.Scale9Sprite:create("real_res/1000575.png")
    activityTips_bg:setPosition(cc.p(activitySize.width/2, activitySize.height + 30))
    activityTips_bg:setContentSize(cc.size(label:getContentSize().width + 30, 60))
    activityTips_bg:setCapInsets(cc.rect(30,20,20,30))
    local tipsBgSize = activityTips_bg:getContentSize()

    local tishijiantou = display.newSprite("real_res/1000561.png")
    tishijiantou:addTo(activityTips_bg)
    tishijiantou:setPosition(cc.p(tipsBgSize.width/2,0))

    activityTips_bg:setName("activityTips_bg")
    activityTips_bg:addTo(self.btn_activity)
    label:addTo(activityTips_bg)

    label:setPosition(cc.p(tipsBgSize.width/2,tipsBgSize.height/2))

end
--显示活动红点
function HallMain:showActivionHongDian()
    local redIcon = self.btn_activity:getChildByName("redIcon")
    if redIcon then
        redIcon:removeFromParent()
    end
    local redIcon = display.newSprite("real_res/1000412.png")
    redIcon:addTo(self.btn_activity)
    redIcon:setName("redIcon")
    local activitySize = self.btn_activity:getContentSize()
    redIcon:setPosition(cc.p(activitySize.width*5/6,activitySize.height*7/8))
end

function HallMain:repSystemConfig()
    -- self:initActivityBtn()
    -- self:initLiangYouInf()
end


--网络接收接口定义
HallMain.s_socketCmdFuncMap = {
    [HallSocketCmd.CODE_USERDATA_USERINFO]      = HallMain.repUserInfo1;
    [HallSocketCmd.CODE_USERDATA_EXT]           = HallMain.repUserInfo2;
    [HallSocketCmd.CODE_USERDATA_POINT]         = HallMain.repUserInfo3;
    [HallSocketCmd.CODE_USERDATA_QUEST]         = HallMain.onRecvGiftInfo;
    [HallSocketCmd.CODE_REC_SERVERINFO]         = HallMain.repServerInfo;
    [HallSocketCmd.CODE_REC_QUERYCLUBINFO]      = HallMain.recClubInfo;
    [HallSocketCmd.CODE_REC_JOINEDCLUBLIST]     = HallMain.recClubInfo;
    [HallSocketCmd.CODE_REC_MALLINFO]           = HallMain.recMallInfo;

    [HallSocketCmd.CODE_REC_LOGIN]          = HallMain.onRepLogin;
    [HallSocketCmd.CODE_REC_USERDATA]       = HallMain.recPlayerInfo;
    [HallSocketCmd.CODE_REC_RESUMEGAME]     = HallMain.repResumeGame;
    [HallSocketCmd.CODE_REC_GAMESTART]      = HallMain.repGameStart;
    [HallSocketCmd.CODE_REC_BROCAST]        = HallMain.repBrocast;
    [HallSocketCmd.CODE_REC_AD_TXT]   = HallMain.repAdTxt;
    [HallSocketCmd.CODE_REC_CHARGERESULT]   = HallMain.recChargeResult;
    [HallSocketCmd.CODE_REC_GETORDER]       = HallMain.recOrder;
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_START]  = HallMain.recvFriendRoomStartGame;--接收朋友开房信息
	[HallSocketCmd.CODE_PLAYER_ROOM_STATE]       = HallMain.recvPlayerGameState;--有未完成对局,恢复游戏对局提示
    [HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO]  = HallMain.recvRoomSceneInfo; --InviteRoomInfo   邀请房信息
	[HallSocketCmd.CODE_RECV_FRIEND_ROOM_CONFIG] = HallMain.recvRoomConfig; 	--邀请房配置
    [HallSocketCmd.CODE_FRIEND_ROOM_ENTER] = HallMain.recvGetRoomEnter; --InviteRoomEnter  进入邀请房结果
	[HallSocketCmd.CODE_RECV_RANKING_GETRANKINGDATA] = HallMain.recvRankingData; --接收排行榜UI数据
    [HallSocketCmd.CODE_REC_HALL_REFRESH_UI]  = HallMain.repHallRefreshUI;
    [HallSocketCmd.CODE_REC_CLUB_REFRESH_UI]  = HallMain.repClubRefreshUI;
    [HallSocketCmd.CODE_REC_CITYLIST] = HallMain.openSelectCityUI;

    [HallSocketCmd.CODE_RECV_YAOQING_INFO] = HallMain.onRepYaoingInfo;

    [HallSocketCmd.CODE_FRIEND_ROOM_CREATE] = HallMain.recvRoomCreate;  --InviteRoomCreate   创建邀请房结果

    [HallSocketCmd.CODE_REC_SYSTEM_CONFIG]   = HallMain.repSystemConfig;   --50208系统活动消息

};



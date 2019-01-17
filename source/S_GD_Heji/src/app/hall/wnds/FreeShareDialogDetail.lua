--[[---------------------------------------- 
-- 修改： 徐松 
-- 日期： 2017.12.22
-- 摘要： 微信分享到好友/群，朋友圈。
]]-------------------------------------------


local ShareToWX = require "app.hall.common.ShareToWX"
local UmengClickEvent = require("app.common.UmengClickEvent")

FreeShareDialogDetail = class("FreeShareDialogDetail", UIWndBase)
local BackEndStatistics = require("app.common.BackEndStatistics")

local kRes = {
    share_diamond1_csb = "hall/share_diamond1.csb",
}

-- Widget里的子元素名字
local kCsbElement = {
    window_title = "Label_80",
    content_state1 = "pan_content1",
    cs1_panel = "panel_c2",
    cs1_text1 = "lb_des",
    cs1_text2 = "lab_des",
    cs1_diamond_num_text = "lb_content",
    img_tag = "Image_35",

    content_state2 = "pan_content2",
    cs2_text1 = "lb_des",

    content_select = "pan_select",

    btn_haoyou = "btn_share_0",
    btn_pengyouquan = "btn_share",
    btn_close = "btn_close",
}

local kWindowTitle = {
    state1 = "分享有礼",
    state2 = "分享",
}

if IsPortrait then -- TODO
kRes = {
    share_diamond1_csb = "hall/share_diamond2.csb",
}

-- Widget里的子元素名字
kCsbElement = {
    window_title = "Label_21",
    content_state1 = "pan_content1",
    cs1_text1 = "lb_des",
    cs1_text2 = "lb_des_0",
    cs1_diamond_num_text = "lb_content",
    img_tag = "Image_dianond",

    content_state2 = "pan_content2",
    cs2_text1 = "lb_des",

    content_select = "pan_select",

    btn_haoyou = "btn_share_0",
    btn_pengyouquan = "btn_share",
    btn_close = "btn_close",
}
end

local GAME_ROUND_FLAG = 0


function FreeShareDialogDetail:ctor()
    FreeShareDialogDetail.super.ctor(self, kRes.share_diamond1_csb)

    self.m_selectChild = 1
end

-- 功能： 初始化
-- 返回值： 无
function FreeShareDialogDetail:onInit()
    local function getWidget( name,pwidget )
        pwidget = pwidget or self.m_pWidget
        return ccui.Helper:seekWidgetByName(pwidget, name)
    end

    -- 窗口出现效果
    self.baseShowType = UIWndBase.BaseShowType.RTOL

    -- 窗口标题
    self.mWindowTitle = getWidget(kCsbElement.window_title)

    -- 关闭窗口按钮
    self.mCloseWindow = getWidget(kCsbElement.btn_close)
    self.mCloseWindow:addTouchEventListener(handler(self, self.onClickButton))

    -- 此窗口有两个版式，不能同时显示
    self.mContentPanel1 = getWidget(kCsbElement.content_state1)
    self.mContentPanel1:setVisible(false)
    self.mContentPanel2 = getWidget(kCsbElement.content_state2)
    self.mContentPanel2:setVisible(false)

    self.mContentSelect = getWidget(kCsbElement.content_select)

    -- 几个元素并排居中显示用的容器
    self.mCs1Panel = getWidget(kCsbElement.cs1_panel)
    -- Panel1 里面的提示字串
    self.mP2Text1 = getWidget(kCsbElement.cs2_text1,self.mContentPanel1)
    self.mP1Text2 = getWidget(kCsbElement.cs1_text2)
    -- 显示钻石数量
    self.mDiamondNumText = getWidget(kCsbElement.cs1_diamond_num_text)

    --钻石图标
    self.mDiamondNumImg = getWidget(kCsbElement.img_tag)

    -- Panel2 里面的提示字串
    self.mP2Text1 = getWidget(kCsbElement.cs2_text1)

    -- 分享到微信好友/群
    self.mShareToHaoyouQun = getWidget(kCsbElement.btn_haoyou)
    self.mShareToHaoyouQun:addTouchEventListener(handler(self, self.onClickButton))
    -- 分享到微信朋友圈
    self.mShareToPengyouquan = getWidget(kCsbElement.btn_pengyouquan)
    self.mShareToPengyouquan:addTouchEventListener(handler(self, self.onClickButton))


    -- 是否可以获得免费钻石
    local isFreeGetDiamound = self:isFreeGetDiamound()
    -- 设置对应的显示字串和版式
    if isFreeGetDiamound == true then
        self.mWindowTitle:setString(kWindowTitle.state1)
        self.mContentPanel1:setVisible(true)
    else
        self.mWindowTitle:setString(kWindowTitle.state2)
        self.mContentPanel2:setVisible(true)
    end

    -- 获取分享相关免费信息
    local shareGift = kGiftData_logicInfo:getShareGift()
    if shareGift.awL and shareGift.awL ~= "" then
        if shareGift.awL then
            local strs1 = string.split(shareGift.awL, "|")
            for i,v in pairs(strs1) do
                local strs2 = string.split(v, ":")
                if strs2[2] then
                    -- 显示字串，可以免费获取的钻石数量
                    self.img_tag = self.img_tag or {}
                    table.insert( self.img_tag,strs2)
                    -- self.mDiamondNumText:setString("x" .. strs2[2])
                    -- self.img_tag = strs2[1]
                end
            end
        end

        --去除零的情况
        for i = #self.img_tag,1,-1 do
            local value = self.img_tag[i]
            if value[2] == "0" then
                table.remove( self.img_tag, i)
            end
        end

        -- Panel1 里面的提示字串
        if self.img_tag  then
            if table.nums(self.img_tag) > 1 then
                self.mP1Text1 = getWidget(kCsbElement.cs1_text1,self.mContentSelect)
                self.mP1Text2 = getWidget(kCsbElement.cs1_text2,self.mContentSelect)
                self.mContentSelect:setVisible(true)
                self.mContentPanel1:setVisible(false)
                self:setPanelSelect()
            else
                self.mP1Text1 = getWidget(kCsbElement.cs1_text1,self.mContentPanel1)
                self.mP1Text2 = getWidget(kCsbElement.cs1_text2,self.mContentPanel1)
                self.mContentSelect:setVisible(false)
                self.mContentPanel1:setVisible(true)
                ---self.img_tag 10008 代表钻石，10009 代表元宝
                if self.img_tag[1][1] and self.img_tag[1][1] == "10009" then
                    self.mDiamondNumImg:loadTexture("hall/huanpi2/Common/yuanbao.png")
                    self.mDiamondNumImg:setScaleY(1.75)
                elseif  self.img_tag[1][1] == "10008" then
                    self.mDiamondNumImg:loadTexture("hall/huanpi2/Common/diamond.png")
                    self.mDiamondNumImg:setScale(1.5)
                end
                self.m_selectChild = self.img_tag[1][1]
                self.mDiamondNumText:setString("x" .. self.img_tag[1][2])
            end
        end
      
        if shareGift.de then
            self.mP2Text1:setString("每日分享朋友圈一次，即可获得:")
        end

        local keyid = kUserInfo:getUserId() .. "-" .. shareGift.Id
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(keyid)
        if userGiftInfo and userGiftInfo.status == 2 and self:isFreeGetDiamound() == true then
            if self.img_tag and table.nums(self.img_tag) < 2 then
                self.mP1Text1:setString("恭喜成功获得")
                if not IsPortrait then
                    self.mP1Text1:getLayoutParameter():setMargin({ left = 180, right = 0, top = 0, bottom = 0})
                end
            end
            self.mP1Text2:setString("今日已领取")
        end
    end
end


function FreeShareDialogDetail:setPanelSelect()
    self.m_btnGlod = ccui.Helper:seekWidgetByName(self.mContentSelect,"btn_glod")
    self.m_btnGlod:addTouchEventListener(handler(self, self.onClickSelectButton))
    local glodText = ccui.Helper:seekWidgetByName(self.m_btnGlod,"Label_text")
    glodText:setString(string.format( "x%s",self.img_tag[2][2]))
    local img_kuang = ccui.Helper:seekWidgetByName(self.mContentSelect,"img_kuang")
    

    self.m_btnDiamond = ccui.Helper:seekWidgetByName(self.mContentSelect,"btn_diamond")
    self.m_btnDiamond:addTouchEventListener(handler(self, self.onClickSelectButton))
    local diamondText = ccui.Helper:seekWidgetByName(self.m_btnDiamond,"Label_text")
    diamondText:setString(string.format( "x%s", self.img_tag[1][2]))

    self.gold_kuang = ccui.Helper:seekWidgetByName(self.m_btnGlod,"img_kuang")
    self.gold_kuang:setVisible(true)
    self.diamond_kuang = ccui.Helper:seekWidgetByName(self.m_btnDiamond,"img_kuang")
    self.diamond_kuang:setVisible(false)
    self.m_selectChild = self.img_tag[2][1] or self.img_tag[1][1]
end

-- 功能： 按钮回调函数
-- 返回值： 无
function FreeShareDialogDetail:onClickSelectButton( pWidget, eventType )
    if eventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        if pWidget == self.m_btnGlod then
            self.m_selectChild = self.img_tag[2][1]
            self.gold_kuang:setVisible(true)
            self.diamond_kuang:setVisible(false)
        elseif pWidget == self.m_btnDiamond then
            self.m_selectChild = self.img_tag[1][1]
            self.gold_kuang:setVisible(false)
            self.diamond_kuang:setVisible(true)
        end
    end
end


-- 功能： 按钮回调函数
-- 返回值： 无
function FreeShareDialogDetail:onClickButton( pWidget, eventType )
    if eventType == ccui.TouchEventType.ended then
        SoundManager.playEffect("btn")
        if pWidget == self.mShareToHaoyouQun then
            Util.disableNodeTouchWithinTime(pWidget)
            ShareToWX.getInstance():shareToHaoYouQun(self.shareResult, self)
        elseif pWidget == self.mShareToPengyouquan then
            Util.disableNodeTouchWithinTime(pWidget)
            -- ShareToWX.getInstance():shareToPengYouQuan(self.shareResult, self)
            LoadingView.getInstance():show("正在分享,请稍后...", 2);
            local shareData = {}
            shareData.shardMold = 5
            WeChatShared.getWechatShareInfo(WeChatShared.ShareType.TIMELINE, WeChatShared.ShareContentType.LINK, WeChatShared.SourceType.HALL_REWARD, handler(self, self.shareResult), ShareToWX.FreeShareFriendQuan,shareData)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.FreeShareFriendCircle)
            local data = {}
            
            data.wa = BackEndStatistics.DiamondShareMoments
            SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
        elseif pWidget == self.mCloseWindow then
            self:keyBack()
        end
    end
end

-- 功能： 接收分享操作后的结果
-- 返回值： 无
function FreeShareDialogDetail:shareResult(info)
    Log.i("shard button:", info)
    LoadingView.getInstance():hide()
    if info.errCode == 0 then
        Toast.getInstance():show("分享成功")
        self:getGift()
        local data = {
            wa = 1
        }
        SocketManager.getInstance():send(CODE_TYPE_USER,HallSocketCmd.CODE_SEND_RECORD_SHARE, data)
    elseif info.errCode == -8 then
        Toast.getInstance():show("您手机未安装微信")
    else
        Toast.getInstance():show("分享失败")
    end
end

-- 功能： 关闭窗口
-- 返回值： 无
function FreeShareDialogDetail:keyBack()
    UIManager:getInstance():popWnd(FreeShareDialogDetail)
end

-- 功能： 获得礼物
-- 返回值： 无
function FreeShareDialogDetail:getGift()
    local shareGift = kGiftData_logicInfo:getShareGift()
    if shareGift then 
        local keyid = kUserInfo:getUserId() .. "-" .. shareGift.Id
        local userGiftInfo = kGiftData_logicInfo:getUserDataByKeyID(keyid)
        if self:isFreeGetDiamound() == true and userGiftInfo.status ~= 2 then
            --reT 10008
            local data = {
                quI = shareGift.Id,
                reT = self.m_selectChild or "10009"
            }
            SocketManager.getInstance():send(CODE_TYPE_USER, HallSocketCmd.CODE_SEND_TASKFINISH, data)
        end
    end
end

-- 功能： 能否获得免费钻石
--      3.5横板里没有（kLoginInfo:isFreeGetDiamound()），这里包装一下
-- 返回值： True or False
function FreeShareDialogDetail:isFreeGetDiamound()
    if IsPortrait then -- TODO
        return kLoginInfo:isFreeGetDiamound()
    else
        local roundNum = tonumber(kLoginInfo:getRoundNum())
        return (roundNum >= GAME_ROUND_FLAG) and true or false
    end
end
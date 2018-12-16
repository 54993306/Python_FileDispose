--[[----------------------------------------
--作者：徐志军
--日期：2018.3.21
--摘要：EngineMgr
]]-------------------------------------------

local PrintConfiguration = class(PrintConfiguration)

function PrintConfiguration:ctor()

    self:showPrint()
    self:ShieldValue()
end
--[[
    @desc: 显示需要打印的配置信息
    author:徐志军
    time:2018-03-21 11:08:48
    return
]]
function PrintConfiguration:showPrint()
    Log.t("游戏包名：",PAGENAME or "")
    Log.t("玩家ID：",kUserInfo:getUserId() or "")
    Log.t("OPENID：",WX_OPENID or "");
    Log.t("头像地址：",WX_HEAD or "");
    Log.t("微信APPID：",WX_APP_ID or "");
    Log.t("PRODUCT_ID：",PRODUCT_ID or "");
    Log.t("版本号：",VERSION or "");
    Log.t("连接地址：",SERVER_IP or "");
    Log.t("连接端口：",SERVIER_PORT or "");
    Log.t("是否开启广告弹窗：",OPEN_ADVERTPAGEVIEW or false);
    Log.t("是否是预发布广告地址：",_isPreReleaseEnv or false);
    Log.t("白名单地址: ", _WhiteListConfigUrlRoot or "")
    Log.t("防屏蔽地址：",_WeChatSharedBaseUrl or "")
    Log.t("防屏蔽反馈地址：",_WeCharSHaredBaseFeedBackUrl or "")
    Log.t("渠道号：",_GameIdentification or 0)
    Log.t("微信分享获取的包名:",WeChatShared.package_name or "")
end
--[[
    @desc: 打印出屏蔽的功能
    author:徐志军
    time:2018-03-21 11:08:48
    return
]]
function PrintConfiguration:ShieldValue()
    local shieldValue = {["share"] = "分享",["club"] = "亲友圈",["openpay"]="支付",["getdiamonds"]="免费领取",["exchange"]="元宝兑换",["kefu"]="客服按钮"}
    if DEBUG_SHIELD_VALUE and #DEBUG_SHIELD_VALUE > 0 then
        for i,shield in pairs(DEBUG_SHIELD_VALUE) do
            Log.t("屏蔽功能：",shieldValue[shield]);
        end
    end
end
return PrintConfiguration
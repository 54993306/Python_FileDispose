-- display FPS stats on screen
DEBUG_FPS = false;

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true;

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 1280;
CONFIG_SCREEN_HEIGHT = 720;

INVALID_IMAGE_MD5 = "fee9458c29cdccf10af7ec01155dc7f0"

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH";

VERSION = "1.0.0"
IMEI = IMEI or "100000037";
MODEL = MODEL or "sengle-pc";
OS = OS or 4;-- 操作系统：2:ios, 1:android, 3:mac, 4:windows
SPID = SPID or 10000; -- 测试：10000， 应用宝:10001, ios：10002
NETMODE = NETMODE or 1;
WX_SEX = WX_SEX or 1;
WX_PR = WX_PR or "广东";
WX_CITY = WX_CITY or "深圳";
WX_CO = WX_CO or "中国";
WX_UID = WX_UID or "default_uid"
--微信头像测试
WX_HEAD = WX_HEAD or "http://wx.qlogo.cn/mmopen/w9vnwdyIABAibjKlvkSmpn6yQsnJoYZoiaeFZh542lwZTIVqKhAtm0G5ScVt8jibFXGSqbrgZblfT0tqmRzzEaH1S3tnMB1ZYCQ/0";

COMPATIBLE_VERSION = 0 -- 底层适配版本号

--提审标志，提审的时候打开，审核通过关闭
IS_YINGYONGBAO = false;
IS_IOS = false;

-- 调试配置--
DEBUG = 0
_isChooseServerForTest = false
_is18Server = false
_isPreReleaseEnv = false
GC_TestID = "test_login_id"
-- 快捷登陆服务器可选列表
TEST_SERVERS = {
    "192.168.7.6",          -- 06服务器
    "121.196.217.142",      -- 142服务器
    "120.78.199.18",        -- 18服务器
    "112.74.174.12"         -- 预发布服
}

-- 服务器列表置空, 请在config_package.lua文件中重写
G_Config = {}
SERVER_IP = ""
SERVIER_PORT = 0
_forceUpdateUrl = nil

-- 选择城市界面屏蔽不显示的名字
-- 暂时应该没用到,都是用PHP配置,先留在这里,以免报错
_gameHideSelectCitys = {
    --["宿州"] = true,
};

-- 版号相关,目前没有申请,先放这里不管
_gameName = "66商丘麻将："
_copyright = "著作权人：北京大圣掌游文化发展有限公司"
_publishcompany = "出版服务单位：上海雪鲤鱼计算机科技有限公司"
_AuditingFileNo = "审批文号：新广出审【2017】5079号"
_ISBN = "ISBN:978-7-7979-3591-3"
_gameSoftTitle = _copyright .. _publishcompany .. _AuditingFileNo .. _ISBN

--------------以下内容为不经常配置的全局变量-----------------
_isOpenWeiXin = true        -- 是否打开对局中的微信分享
G_CLOSE_CLUB = false        -- 是否打开亲友圈按钮
OPEN_ADVERTPAGEVIEW = true  -- 是否打开登录广告弹窗
_MALLWECHAT = "客服微信：majiang6620"

------------------以后用这个表来存放全局定义-----------------
GLOBAL_DEFINE = {}
GLOBAL_DEFINE.DDZID = 20011 -- 掼蛋游戏ID, 如有修改, 请在config_package.lua文件中重写
GLOBAL_DEFINE.HallLogo = "real_res/1004606.png" -- 登录/ 更新/ 大厅 界面的logo

--------------------------------下方加载包体配置-----------------------------------------
-- local FileTools = require("app.common.FileTools")
-- local config_package_path = "package_src.config.config_package"
-- FileTools.reloadFile(config_package_path)
GLOBAL_DEFINE._is18Server = {
    _WhiteListConfigUrlRoot = "http://192.168.7.105:8089",
    _WeChatSharedBaseUrl = "http://192.168.7.105:8099/Api/getConfig",    -- 请求微信分享数据后台链接
    _WeCharSHaredBaseFeedBackUrl = "http://192.168.7.105:8060/Api/shareFeeback",    -- 反馈分享结果链接
    _WechatSharedClicksNumberUrl = "http://192.168.7.105:8060/Api/shareLandFeeback",    -- 反馈分享结果链接
    _HotMoreLinkURL = "http://192.168.7.6:8080/versiondown",
}
GLOBAL_DEFINE._isPreReleaseEnv = {
    _WhiteListConfigUrlRoot = "http://pre-client-download-cdn.stevengame.com",
    _WeChatSharedBaseUrl = "http://pre-app75.stevengame.com/Api/getConfig",    -- 请求微信分享数据后台链接
    _WeCharSHaredBaseFeedBackUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareFeeback",    -- 反馈分享结果链接
    _WechatSharedClicksNumberUrl = "http://pre-client-sharedata-upload.stevengame.com/Api/shareLandFeeback",   ---预发布分享次数统计调用 
    _HotMoreLinkURL = "http://112.74.174.12:36999",
}
GLOBAL_DEFINE._zsf = {
    _WhiteListConfigUrlRoot = "http://client-download-cdn.stevengame.com",
    _WeChatSharedBaseUrl = "http://app75.stevengame.com/Api/getConfig",    -- 请求微信分享数据后台链接
    _WeCharSHaredBaseFeedBackUrl = "http://client-sharedata-upload.stevengame.com/Api/shareFeeback",    -- 反馈分享结果链接
    _WechatSharedClicksNumberUrl = "http://client-sharedata-upload.stevengame.com/Api/shareLandFeeback",   ---预发布分享次数统计调用
    _HotMoreLinkURL = "http://download.stevengame.com/client-data/project_1/regengxin",
}
package.loaded["package_src.config.config_package"] = nil
require("package_src.config.config_package")

local serverCfg = GLOBAL_DEFINE._zsf

if _is18Server then
    serverCfg = GLOBAL_DEFINE._is18Server
elseif _isPreReleaseEnv then
    serverCfg = GLOBAL_DEFINE._isPreReleaseEnv
end

_WhiteListConfigUrlRoot = serverCfg._WhiteListConfigUrlRoot;
_WeChatSharedBaseUrl = serverCfg._WeChatSharedBaseUrl;
_WeCharSHaredBaseFeedBackUrl = serverCfg._WeCharSHaredBaseFeedBackUrl;
_WechatSharedClicksNumberUrl = serverCfg._WechatSharedClicksNumberUrl;
_HotMoreLinkURL = serverCfg._HotMoreLinkURL;



DEBUG_MODE = type(DEBUG) == "number" and DEBUG >= 1

if IsPortrait then -- TODO
    -- screen orientation
    CONFIG_SCREEN_ORIENTATION = "portrait"
    -- design resolution
    CONFIG_SCREEN_WIDTH  = 720;
    CONFIG_SCREEN_HEIGHT = 1280;
    -- auto scale mode
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT";
    MAC  = "abcdedfff";
end





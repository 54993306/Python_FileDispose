-- 是否为竖版工程
-- modify by json IsPortrait
IsPortrait = true

-- 登陆帐号相关

WX_OPENID = WX_OPENID or "oR61xv2Wl4PigHNBOsl97TD2AL_k";

WX_NAME = WX_NAME or "從從從從從從";

-- 登录界面4个按钮的帐号id前缀
GC_TestID =  "wz_test_001";
-- GC_TestID =  "wz_test_002";

-- 无论是不是单个游戏还是合集, 都需要将自己的麻将加进来
GC_GameTypes = {
    [10023] = "suzhoumj",
    [10022] = "bengbumj",
    [10024] = "huaiyuanmj",
    [10033] = "pizhoumj",
    [10058] = "xinyangmj",
    [10061] = "xinxiangmj",
    [10083] = "xiaoxianmj",
    [10040] = "suqianmj",
    [10059] = "gushimj",
    [10060] = "huangchuanmj",
    [10062] = "sixianmj",
    [10063] = "lingbimj",
    [10086] = "qingyuanmj",
    [10087] = "yingdemj",
    [10089] = "zhanjiangmj",
    [10090] = "lianjiangmj",
    [10095] = "zhaoqingmj",
    [10096] = "huaijimj",
    [10097] = "yunfuduigangmj",
    [10098] = "yunfujiangmamj",
    [10099] = "luodinguipaimj",
    [10100] = "yangjiangdafanmj",
    [10101] = "yangjiangjihumj",
    [10102] = "shaoguanzpmj",
    [10103] = "shaoguantdhmj",
    [10105] = "huizhoumj",
    [10106] = "heyuanmj",
    [10107] = "jiangmenguipaimj",
    [10108] = "jiangmengangganghumj",
    [10109] = "kaipingmj",
    [10110] = "zhongshanmj",
    [10115] = "zhengzhoumj",
    [10116] = "zhuhaimj",
    [10117] = "shanweimj",
    [10118] = "chaozhoumj",
    [10119] = "anyangtuidaohumj",
    [10126] = "gaozhoumj",
    [10128] = "meizhoutuidaohumj",
    [10129] = "maomingmj",
    [10130] = "gaozhoumaimamj",
    [10135] = "meizhouhongzhongbaomj",
    [10136] = "shantoumj",
    -- [10156] = "hongzhongmj",
    -- [10158] = "hongzhongmj",
    -- [10160] = "hongzhongmj",
    -- [10158] = "hongzhongmj",
    [10172] = "guangdongjihumj",
    [10213] = "guangdongtuidaohumj",
    [10214] = "jieyangmj",
    [10217] = "guangdongyibaizhangmj",
    [10218] = "hongzhongmj",
    [10296] = "guangdongzptdhmj",

    [10070] = "henanshangqiumj",

    [10119] = "zhengzhoumj",
    [10023] = "suzhoumj",
    [10063] = "lingbimj",
    [10083] = "xiaoxianmj",
    [10061] = "xinxiangmj",
    [10058] = "xinyangmj",
    [20009] = "ddzpk",
    [20010] = "pdkpk",
    [20011] = "gdpk",
}


GC_GameName = "广东麻将大全" -- 游戏名称
DOCKER_NAME = "广东大全" -- Docker服务器列表拉取字段
WX_APP_ID = "wxfd0e620467a13b07" -- 微信APPID
MAGIC_WINDOWS_APP_NAME = "guangdongmjquanji" -- 魔窗功能的APP名字
CONFIG_GAEMID = 10105   -- 默认的麻将ID
PRODUCT_ID = 4444       -- 产品ID标志不同的包
SCHEME_HOST_NAME = "guangdongmjdaquan"

----------------------以下为配置一次正确后不需要配置项---------------------
G_OPEN_CHARGE = true        -- 是否打开商城    ios 关闭   android 打开
IS_OPEN_WEIXIN_QUICK = true
_OFFICIALWECHAT = "大圣广东游戏中心"    -- 红包领取微信号

-- 控制一些开关的table
DEBUG_SHIELD_VALUE = {
    "openActivity", -- 是否开启活动 (目前新老淮北，还有江苏，安徽，河南，广东的省包  需要开，其他的市包不需要)
    "openFileLog",
}

 -- 根据平台判定渠道号
 if device then
    if device.platform == "ios" then
        _GameIdentification = 20017;
    else
        _GameIdentification = 10017;
    end
end

 -- 根据平台设置强更包地址
 if device then
    if device.platform == "ios" then
        _forceUpdateUrl = "https://itunes.apple.com/cn/app/id1322313654"
    else
        -- _forceUpdateUrl = "http://s1.shuilangkill.top/downpage.php?gameid=4444"
        _forceUpdateUrl = "http://s1.eidneit.top/downpage.php?gameid=4444"

    end
end

-- 热更路径
APP_NAME_PATCH = "guangdong_region"
---------------------------------------------------------------------------

-- 正式发布前以下配置需要逐个检查
-- modify by jenkins debugMode
local DebugMode = false
DEBUG = DebugMode and 1 or 0

VERSION = "3.7.5.0.6"      -- 苹果版本

-- modify by jenkins testLogin
_isChooseServerForTest = false

-- modify by jenkins serverName
local _SERVER_CHOICE = "18服地方组"

if _SERVER_CHOICE == "18服地方组" then
    -- 18资源服
    _is18Server = true
    DEBUG = 1
    _isChooseServerForTest = true
    DEBUG = 1
    -- 18服务器
    G_Config = {}
    SERVER_IP = "120.78.199.18"
--    SERVIER_PORT = "30616" -- 地方组
	SERVIER_PORT = "41111" -- 地方组
elseif _SERVER_CHOICE == "后端" then
    -- 18资源服
    _is18Server = true
    _isChooseServerForTest = true
    DEBUG = 1
    -- 18服务器
    G_Config = {}
    SERVER_IP = "192.168.8.247"
    SERVIER_PORT = "5002" -- 中心组
    PRODUCT_ID = 4444       -- 产品ID标志不同的包
    WX_APP_ID = "wxfd0e620467a13b07" -- 微信APPID
    DEBUG_FPS = true
elseif _SERVER_CHOICE == "18服中心组" then
    -- 18资源服
    _is18Server = true
    _isChooseServerForTest = true
    DEBUG = 1
    -- 18服务器
    G_Config = {}
	SERVER_IP = "120.78.199.18"
	SERVIER_PORT = "30616" -- 中心组
elseif _SERVER_CHOICE == "预发布服" then
    -- 预发布资源服
    _isPreReleaseEnv = true    -- 预发布资源服
    DEBUG = 1
    -- 预发布服务器
    G_Config = {}
    -- SERVER_IP = "112.74.174.12"
    -- SERVIER_PORT = "30000"
	SERVER_IP = "120.78.28.242"
    SERVIER_PORT = "666"
    _isChooseServerForTest = true

elseif _SERVER_CHOICE == "正式服" then
    _isChooseServerForTest = false
    DEBUG = 0
    -- 全局配置
	G_Config = {
		-- 普通服务器(目前的逻辑中, 必须至少有一组配置)
		SLB_Servers = {
			{IP = "2d-dszy-login.stevengame.com", PORT = 65000, }, -- SLB-A
			{IP = "2d-dszy-login.stevengame.com", PORT = 65000, }, -- SLB-B
		},
		-- 高防服务器
		GF_Servers = {
			{IP = "2d-dszy-login.stevengame.com", PORT = 65000, }, -- 高防-C
		},
	}
    -- 默认服务器配置
    SERVER_IP = G_Config.SLB_Servers[1].IP
    SERVIER_PORT = G_Config.SLB_Servers[1].PORT
end


GLOBAL_DEFINE._is18Server = {
    _WhiteListConfigUrlRoot = "http://192.168.7.105:28094",
    _WeChatSharedBaseUrl = "http://192.168.7.105:28010/Api/getConfig",    -- 请求微信分享数据后台链接
    _WeCharSHaredBaseFeedBackUrl = "http://192.168.7.105:28010/Api/shareFeeback",    -- 反馈分享结果链接
    _WechatSharedClicksNumberUrl = "http://192.168.7.105:28010/Api/shareLandFeeback",    -- 反馈分享结果链接
    _HotMoreLinkURL = "http://192.168.7.105:28010/versiondown",
}

GLOBAL_DEFINE._isPreReleaseEnv._HotMoreLinkURL = "https://2d-resource-cdn.stevengame.com/prerelease/regengxin"

GLOBAL_DEFINE._zsf._HotMoreLinkURL = "https://2d-resource-cdn.stevengame.com/production/regengxin"

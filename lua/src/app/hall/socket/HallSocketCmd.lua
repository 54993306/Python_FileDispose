--大厅消息命令字

HallSocketCmd = {};

HallSocketCmd.CODE_USERDATA_USERINFO  = 1001; --用户基础信息
HallSocketCmd.CODE_USERDATA_EXT   = 1002; --用户扩展信息
HallSocketCmd.CODE_USERDATA_POINT = 1003; --用户账户信息
HallSocketCmd.CODE_USERDATA_RECORD_CODE= 1004; --用户对战记录
HallSocketCmd.CODE_USERDATA_QUEST = 1005; --用户任务信息
HallSocketCmd.CODE_USERDATA_MAIL  = 1006; -- 用户邮件信息

HallSocketCmd.CODE_REC_SERVERINFO = 10005;  --服务器参数配置
HallSocketCmd.CODE_SEND_REGISTER = 10007;  --注册
HallSocketCmd.CODE_REC_REGISTER  = 10010;  --注册返回
HallSocketCmd.CODE_SEND_LOGIN    = 10020;  --登录
HallSocketCmd.CODE_REC_LOGIN     = 10021;  --登陆消息返回
HallSocketCmd.CODE_SEN_GETPASSWORD  = 10028;  --找回密码
HallSocketCmd.CODE_REC_GETPASSWORD  = 10028;  --找回密码返回
HallSocketCmd.CODE_SEN_VERIFY     = 10029;  --获取验证码
HallSocketCmd.CODE_REC_VERIFY     = 10029;  --获取验证码返回
HallSocketCmd.CODE_SEN_CODEVERIFY    = 10030;  --发送验证码校验
HallSocketCmd.CODE_REC_CODEVERIFY    = 10030;  --接收验证码校验
HallSocketCmd.CODE_SEN_BINDWECHAT    = 10032;  --发送微信绑定
HallSocketCmd.CODE_REC_BINDWECHAT    = 10032;  --接收微信绑定

HallSocketCmd.CODE_SEN_CHANGE_PASSWORD  = 51203;  --修改密码
HallSocketCmd.CODE_REC_CHANGE_PASSWORD  = 51203;  --修改密码返回
HallSocketCmd.CODE_SEN_BINDPHONE  = 51204;  --绑定手机
HallSocketCmd.CODE_REC_BINDPHONE  = 51204;  --绑定手机返回

HallSocketCmd.CODE_REC_GAMELIST  = 10011;  --游戏列表
HallSocketCmd.CODE_SEND_SELCITY  = 50104;  --选择城市
--HallSocketCmd.CODE_REC_CHARGLIST  = 10015;  --充值列表
HallSocketCmd.CODE_REC_OPENGAMELIST  = 10016;  --游戏开放列表
HallSocketCmd.CODE_REC_CITYLIST = 10017; --服務器下發城市列表
HallSocketCmd.CODE_SEND_IP = 10027; --上行客户端IP给服务端
HallSocketCmd.CODE_SEND_LOCATION = 10031  -- 上行客户端定位给服务端
HallSocketCmd.CODE_REC_LOCATION = 10031  -- 下行服务端接收定位信息


HallSocketCmd.CODE_SEND_ROOMLIST  = 20001;  --房间列表
HallSocketCmd.CODE_REC_ROOMLIST  = 20002;  --房间列表
HallSocketCmd.CODE_SEND_GAMESTART = 20011;  --请求游戏开局
HallSocketCmd.CODE_REC_GAMESTART = 20011;  --游戏开局结果
HallSocketCmd.CODE_SEND_ExitRoom = 20014;  --请求退出房间
HallSocketCmd.CODE_REC_ExitRoom = 20014;  --接收退出房间

HallSocketCmd.CODE_SEND_RESUMEGAME = 30005; --请求恢复游戏对局
HallSocketCmd.CODE_REC_RESUMEGAME = 30005; --恢复游戏对局结果
HallSocketCmd.CODE_SEND_EXITGAME = 30004;   --退出游戏
HallSocketCmd.CODE_REC_EXITGAME = 30004;    --退出游戏结果

HallSocketCmd.CODE_SEND_GAMERANK = 50207;   --游戏每日排行榜
HallSocketCmd.CODE_REC_GAMERANK = 50207;    --检测附件是否可领取结果

HallSocketCmd.CODE_SEND_USERDATA  = 50221;  --用户信息
HallSocketCmd.CODE_REC_USERDATA  = 50222;  --用户信息

HallSocketCmd.CODE_SEND_USERINFO = 50001;    --玩家资料
HallSocketCmd.CODE_REC_USERINFO = 50002;    --玩家资料
HallSocketCmd.CODE_SEND_WINRATE = 50003;    --游戏胜率
HallSocketCmd.CODE_REC_WINRATE = 50004;    --游戏胜率
HallSocketCmd.CODE_SEND_GRADE = 50005;    --游戏等级
HallSocketCmd.CODE_REC_GRADE = 50006;    --游戏等级
HallSocketCmd.CODE_SEND_MODIFYUSERINFO = 50007;    --修改资料（包括绑定）
HallSocketCmd.CODE_REC_MODIFYUSERINFO = 50007;    --修改资料（包括绑定）
HallSocketCmd.CODE_REC_FEEDBACK = 50008;        --提交玩家反馈
HallSocketCmd.CODE_SEND_MOSTPOKERTYPE = 50009;    --最大牌型
HallSocketCmd.CODE_REC_MOSTPOKERTYPE = 50010;    --最大牌型
HallSocketCmd.CODE_SEND_FORTUNERANK = 50011;    --财富排行
HallSocketCmd.CODE_REC_FORTUNERANK = 50012;    --财富排行
HallSocketCmd.CODE_SEND_BROKEOTHER = 50201;    --使别人破产
HallSocketCmd.CODE_REC_BROKEOTHER = 50202;    --使别人破产
HallSocketCmd.CODE_SEND_BROKESELF = 50203;    --被破产
HallSocketCmd.CODE_REC_BROKESELF = 50204;    --被破产
HallSocketCmd.CODE_SEND_CHANGE_DEFAULT_HEAD = 50206;    --更改默认头像
HallSocketCmd.CODE_REC_CHANGE_DEFAULT_HEAD = 50206;    --更改默认头像
HallSocketCmd.CODE_REC_CHANGE_DEFAULT_HEAD = 50206;    --更改默认头像
HallSocketCmd.CODE_SEND_SYSTEM_CONFIG = 50208;    --系统配置数据
HallSocketCmd.CODE_REC_SYSTEM_CONFIG = 50208;    --系统配置数据


HallSocketCmd.CODE_REC_HALL_REFRESH_UI = 60001;   -- 游戏主界面刷新显示  Server->Client
HallSocketCmd.CODE_REC_CLUB_REFRESH_UI = 60002;   -- 亲友圈身份状态刷新显示  Server->Client
HallSocketCmd.CODE_REC_REDPOINT = 60003;   --红点通知协议
HallSocketCmd.CODE_REC_BROCAST = 60009;    --通知
HallSocketCmd.CODE_REC_SERVER_NOTIFY = 60010;    --游戏系统维护提示
HallSocketCmd.CODE_REC_AD_TXT = 60011;    --文字广告
HallSocketCmd.CODE_REC_PAOMADENG = 60012;    --跑马灯
-- 亲友圈
HallSocketCmd.CODE_SEND_QUERYCLUB          = 51101;    -- 查询亲友圈
HallSocketCmd.CODE_REC_QUERYCLUB           = 51101;    -- 查询亲友圈返回
HallSocketCmd.CODE_SEND_JOINCLUB           = 51102;    -- 加入亲友圈
HallSocketCmd.CODE_REC_JOINCLUB            = 51102;    -- 加入亲友圈返回
HallSocketCmd.CODE_SEND_QUERYCLUBINFO      = 51103;    -- 管理员查看我的亲友圈信息
HallSocketCmd.CODE_REC_QUERYCLUBINFO       = 51104;    -- 管理员查看我的亲友圈信息返回
HallSocketCmd.CODE_SEND_QUERYCLUBHEAD      = 51105;    -- 管理员查看我的亲友圈亲友头像
HallSocketCmd.CODE_REC_QUERYCLUBHEAD       = 51106;    -- 管理员查看我的亲友圈亲友头像返回
HallSocketCmd.CODE_SEND_CLUBROOMLIST       = 51107;    -- 查看某个亲友圈的房间列表
HallSocketCmd.CODE_REC_CLUBROOMLIST        = 51108;    -- 返回某个亲友圈房间列表
HallSocketCmd.CODE_SEND_QUITCLUB           = 51109;    -- 请求退出亲友圈
HallSocketCmd.CODE_REC_QUITCLUB            = 51109;    -- 请求退出亲友圈
HallSocketCmd.CODE_SEND_JOINEDCLUBLIST     = 51112;    -- 请求加入的亲友圈列表
HallSocketCmd.CODE_REC_JOINEDCLUBLIST      = 51113;    -- 返回加入的亲友圈列表
HallSocketCmd.CODE_SEND_CLUBAPPLYLIST      = 51114;    -- 请求亲友圈的申请信息
HallSocketCmd.CODE_REC_CLUBAPPLYLIST       = 51115;    -- 返回亲友圈的申请信息

HallSocketCmd.CODE_SEND_CREATECLUBMODEL     = 51117;    -- 创建亲友圈模版/重置亲友圈模版
HallSocketCmd.CODE_REC_CREATECLUBMODEL      = 51118;    -- 创建亲友圈模版返回
HallSocketCmd.CODE_SEND_CLUBMODEL           = 51119;    -- 请求模版信息
HallSocketCmd.CODE_REC_CLUBMODEL            = 51120;    -- 亲友圈模版信息返回
HallSocketCmd.CODE_SEND_DELETECLUBMODEL     = 51121;    -- 删除亲友圈模版
HallSocketCmd.CODE_REC_DELETECLUBMODEL      = 51121;    -- 删除亲友圈模版返回

-- 记录分享日志
HallSocketCmd.CODE_SEND_RECORD_SHARE       = 50101;    -- 记录分享日志

--邮件消息模块
HallSocketCmd.CODE_SEND_MSGLIST         = 50021;    --获取邮件列表  Client->Server
HallSocketCmd.CODE_REC_MSGLIST          = 50022;    --返回邮件列表  Server->Client
HallSocketCmd.CODE_SEND_CONTEXTINFO     = 50023;    --读邮件  Client->Server
HallSocketCmd.CODE_REC_CONTEXTINFO      = 50024;    --返回邮件读取  Server->Client
HallSocketCmd.CODE_REC_GETITEM          = 50025;    --提取附件  c<->s
HallSocketCmd.CODE_REC_NEWMAIL          = 50026;    --新增一条消息  s->c
HallSocketCmd.CODE_SEND_PICKUP          = 50027;    --删除邮件 c<->s
HallSocketCmd.CODE_REC_PICKUP           = 50028;    --
HallSocketCmd.CODE_REC_CLUB_APPLY      = 50020     --操作功能（同意或者不同意）c<->s

--兑换商城消息模块
HallSocketCmd.CODE_SEND_MALLINFO        = 70201;    -- 获取兑换商城数据请求
HallSocketCmd.CODE_REC_MALLINFO         = 70202;    -- 服务器兑换商城信息返回
HallSocketCmd.CODE_SEND_EXCHANGE        = 70203;    -- 兑换物品
HallSocketCmd.CODE_REC_EXCHANGE         = 70204;    -- 兑换物品返回
HallSocketCmd.CODE_SEND_MALLADD         = 70007;    -- 填写收货地址
HallSocketCmd.CODE_REC_MALLADD          = 70007;    -- 服务器数据返回

HallSocketCmd.CODE_SEND_PLAYERCARDINFO       = 50400;    -- 实名认证请求状态
HallSocketCmd.CODE_REC_PLAYERCARDINFO        = 50401;    -- 实名认证状态返回

--背包消息模块
HallSocketCmd.CODE_SEND_BAGSETPASWORD = 50032;         --设置密码
HallSocketCmd.CODE_REC_BAGSETPASWORD = 50032;          --设置密码
HallSocketCmd.CODE_SEND_BAGCANCELPASWORD  = 50039;    --取消密码
HallSocketCmd.CODE_REC_BAGCANCELPASWORD = 50039;      --取消密码
HallSocketCmd.CODE_SEND_BAGFINDPASWORD = 50104;    --忘记找回密码
HallSocketCmd.CODE_REC_BAGFINDPASWORD = 50105;     --忘记找回密码
HallSocketCmd.CODE_SEND_BAGGOLD = 50033;    --存取金豆
HallSocketCmd.CODE_REC_BAGGOLD = 50033;     --存取金豆

--密码找回模块
HallSocketCmd.CODE_SEND_BEGVERIFY = 50034;      --请求验证码
HallSocketCmd.CODE_REC_VERIFYBACK = 50035;      --验证码返回
HallSocketCmd.CODE_SEND_VERIFYCODE = 50036;     --验证code
HallSocketCmd.CODE_REC_VERIFYCODE = 50036;     --验证code
HallSocketCmd.CODE_SEND_RESETPASSWORD = 50037;   --重置密码
HallSocketCmd.CODE_REC_RESETPASSWORD = 50037;   --重置密码
HallSocketCmd.CODE_SEND_COMPLAINT = 50038;       --申述密码找回
HallSocketCmd.CODE_REC_COMPLAINT = 50038;       --申述密码找回

--礼包模块
HallSocketCmd.CODE_REC_GIFTLIST = 10014;    --礼包基本信息
HallSocketCmd.CODE_SEND_GETWARD = 50030;-- type = 5,code=50030, 领取任务奖励 Client -> Server
HallSocketCmd.CODE_SEND_TASKFINISH = 50031; -- type = 5,code=50031, 任务完成（针对部分客户端验证类型） Client -> Server
HallSocketCmd.CODE_SEND_EXCHANGE_CODE = 51004;  -- type = 5,code=51004, 领取兑换码 Client->Server
HallSocketCmd.CODE_REC_EXCHANGE_CODE  = 51004;  -- type = 5,code=51004, 领取兑换码 Client<-Server

--充值
-- HallSocketCmd.CODE_SEND_GETORDER = 90001;    --获取订单号
-- HallSocketCmd.CODE_REC_GETORDER = 90002;    --获取订单号
-- HallSocketCmd.CODE_REC_CHARGERESULT = 90003;    --支付成功
-- HallSocketCmd.CODE_SEND_IOSCHARGE = 90005;    --苹果支付
-- HallSocketCmd.CODE_REC_IOSCHARGE = 90005;    --苹果支付结果

HallSocketCmd.CODE_REC_CHARGLIST  = 90011;  --充值列表
HallSocketCmd.CODE_SEND_GETORDER = 90012;    --获取订单号
HallSocketCmd.CODE_REC_GETORDER = 90013;    --获取订单号
HallSocketCmd.CODE_SEND_IOSCHARGE = 90014;    --苹果支付
HallSocketCmd.CODE_REC_CHARGERESULT = 90015;    --支付成功
 
--开房请求
HallSocketCmd.CODE_RECV_FRIEND_ROOM_CONFIG = 22013	--InviteRoomConfigList	 邀请房配置
HallSocketCmd.CODE_SEND_FRIEND_ROOM_CONFIG = 22012	--InviteRoomConfigListReq	 邀请房列表请求（弃用）

HallSocketCmd.CODE_FRIEND_ROOM_CREATE = 22004	--InviteRoomCreate	 创建邀请房请求/结果
HallSocketCmd.CODE_RECV_FRIEND_ROOM_END = 22010	--InviteRoomEnd	 邀请房结束
--HallSocketCmd.CODE_FRIEND_ROOM_GETROOMINFO = 22015	--InviteRoomGetInfo	 获取邀请房信息
HallSocketCmd.CODE_FRIEND_ROOM_ENTER = 22005	--InviteRoomEnter	 进入邀请房请求/结果
HallSocketCmd.CODE_RECV_FRIEND_ROOM_INFO = 22006	--InviteRoomInfo	 邀请房信息
HallSocketCmd.CODE_FRIEND_ROOM_INFO_QUIT= 22007--type = 2,code=22007, 退出邀请房请求 Client <--> Server
HallSocketCmd.CODE_RECV_FRIEND_ROOM_REWARD = 22009	--InviteRoomRankAward	 邀请房排行奖励
HallSocketCmd.CODE_RECV_FRIEND_ROOM_START= 22016	--type = 2,code=20016, 接收服务端自己构造20016邀请房对局开始所要信息
HallSocketCmd.CODE_SEND_FRIEND_ROOM_START= 22016	--type = 2,code=20016, 邀请房对局开始
HallSocketCmd.CODE_RECV_FRIEND_ROOM_ADDPLAYER= 22017	--type = 2,code=20017, 新增玩家到房间
HallSocketCmd.CODE_RECV_FRIEND_ROOM_MONENY= 22018	--type = 2,code=22018, 请求房费数量 client  <-->server（弃用）
--
HallSocketCmd.CODE_PLAYER_ROOM_STATE= 20018	  --type = 2,code=20018,有未完成对局,恢复游戏对局提示
HallSocketCmd.CODE_FRIEND_ROOM_SAYMSG = 23000 --私有房聊天
HallSocketCmd.CODE_FRIEND_ROOM_LEAVE = 22020 --解散桌子信息
-- 战局信息请求
HallSocketCmd.CODE_SEND_RECORD_INFO = 50300 	-- type = 5 用户相关 code = 50300 战局信息
HallSocketCmd.CODE_RECV_RECORD_INFO = 50301 	-- type = 5 用户相关 code = 50300 战局信息
HallSocketCmd.CODE_SEND_MATCH_RECORD_INFO = 50302 	-- type = 5 用户相关 code = 50300 请求单局战绩
HallSocketCmd.CODE_RECV_MATCH_RECORD_INFO = 50303 	-- type = 5 用户相关 code = 50300 返回单局战绩

HallSocketCmd.CODE_RECV_AGENT_INFO = 50103;    --管理员信息

HallSocketCmd.CODE_SEND_YAOQING_INFO = 51001;  --邀请信息
HallSocketCmd.CODE_RECV_YAOQING_INFO = 51002;  --邀请信息
HallSocketCmd.CODE_RECV_YAOQING_REWARD = 51012;  --邀请好友奖励
HallSocketCmd.CODE_SEND_YAOQING_ID = 51003;    --输入邀请人
HallSocketCmd.CODE_RECV_YAOQING_ID = 51003;    --输入邀请人

--------------------------------------------------------------------------
--排行相关网络协议
----------------------------------------------------------------------------
--type = 5,code=51005, 获取排行入口界面数据  Client->Server
HallSocketCmd.CODE_SEND_RANKING_GETRANKINGDATA = 51005;
--type = 5,code=51006, 返回排行入口界面数据  Server->Client
HallSocketCmd.CODE_RECV_RANKING_GETRANKINGDATA = 51006;
--type = 5,code=51007,设置玩家地址 Client<->Server
HallSocketCmd.CODE_RANKING_SET_PALYERDATA = 51007;
--type = 5,code=51008, 获取排行界面数据  Client->Server
HallSocketCmd.CODE_SEND_RANKING_ALLDATA = 51008;
--type = 5,code=51009, 获取排行界面数据  Server->Client
HallSocketCmd.CODE_RECV_RANKING_ALLDATA = 51009;
--type = 5,code=51010, 获取排行界下一页面数据  Server->Client
HallSocketCmd.CODE_RECV_RANKING_ALLDATA_Next = 51010;
--type = 5,code=51011,领奖 Client<->Server
HallSocketCmd.CODE_RECV_RANKING_GETAWARDRESULT =51011;


--------------------------------------------------------------------------
--
----------------------------------------------------------------------------

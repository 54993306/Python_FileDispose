-- 
-- 友盟点击事件上报EventID 定义  
-- Author: Machine
-- Date: 2018-07-23
--

-- 横版

local UmengClickEvent = {}

UmengClickEvent.SignOffType = 1
UmengClickEvent.SignInType = 2
UmengClickEvent.CustomEvnetType = 3

if IsPortrait then -- TODO
-- UmengClickEvent.LoginKeFu                    = "LoginKeFu"                       -- 登录客服按钮
-- UmengClickEvent.LoginKeFuGongZhongHaoCopy    = "LoginKeFuGongZhongHaoCopy"       -- 登录客服公众号复制
-- UmengClickEvent.LoginKeFuDaiLiCopy           = "LoginKeFuDaiLiCopy"              -- 登录招募代理微信复制
-- UmengClickEvent.LoginKeFuOnline              = "LoginKeFuOnline"                 -- 登录在线客服

-- UmengClickEvent.MoreButton                   = "MoreButton"                      -- 更多菜单按钮
-- UmengClickEvent.MoreSettingButton            = "MoreSettingButton"               -- 更多设置按钮
-- UmengClickEvent.MoreRuleButton               = "MoreRuleButton"                  -- 更多规则按钮
-- UmengClickEvent.MoreMsgButton                = "MoreMsgButton"                   -- 更多消息按钮
-- UmengClickEvent.MoreNoticeButton         = "MoreNoticeButton"                -- 更多公告按钮
-- UmengClickEvent.MoreKeFu                 = "MoreKeFu"                        -- 更多客服按钮
-- UmengClickEvent.MoreKeFuGongZhongHaoCopy = "MoreKeFuGongZhongHaoCopy"        -- 更多客服公众号按钮
-- UmengClickEvent.MoreKeFuDaiLiCopy            = "MoreKeFuDaiLiCopy"               -- 更多招募代理微信复制按钮
UmengClickEvent.MoreKeFuOnline              = "MoreKeFuOnline"                  -- 更多在线客服
-- UmengClickEvent.MoreOpenWeChatButton     = "MoreOpenWeChatButton"            -- 更多打开微信按钮
-- UmengClickEvent.MoreChangeAccountButton      = "MoreChangeAccountButton"         -- 更多切换账号按钮

-- UmengClickEvent.ChargeButton             = "ChargeButton"                    -- 充值按钮
-- UmengClickEvent.Charge12Button               = "Charge12Button"                  -- 12元按钮
-- UmengClickEvent.Charge30Button               = "Charge30Button"                  -- 30元按钮
-- UmengClickEvent.Charge98Button               = "Charge98Button"                  -- 98元按钮

-- UmengClickEvent.HallDaiLiButton              = "HallDaiLiButton"                 -- 主界面招募代理按钮
UmengClickEvent.HallDaiLiWXCopyButton       = "HallDaiLiWXCopyButton"           -- 主界面招募代理复制微信按钮

-- UmengClickEvent.FreeDiamondCircle            = "FreeDiamondCircle"               -- 免费钻石按钮
-- UmengClickEvent.FreeShareFriendCircle        = "FreeShareFriendCircle" -- 免费钻石分享朋友圈按钮
-- UmengClickEvent.ClubButton                   = "ClubButton" -- 俱乐部按钮
-- UmengClickEvent.HallCreateRoomButton         = "HallCreateRoomButton" -- 创建房间按钮
-- UmengClickEvent.CreateClubButton         = "CreateClubButton" -- 创建俱乐部房间按钮
-- UmengClickEvent.CreateRoomButton         = "CreateRoomButton" -- 创建房间按钮
-- UmengClickEvent.JoinRoomButton               = "JoinRoomButton"-- 加入房间按钮

-- UmengClickEvent.PersonalCenter               = "PersonalCenter" -- 个人中心按钮
-- UmengClickEvent.DisclaimerButton         = "DisclaimerButton" -- 免责声明按钮
-- UmengClickEvent.JoinClubButton               = "JoinClubButton" -- 加入俱乐部按钮
-- UmengClickEvent.RealNameButton               = "RealNameButton"-- 实名认证按钮


-- UmengClickEvent.RedPackageExchange           = "RedPackageExchange" -- 红包兑换
-- UmengClickEvent.YB1000Button             = "YB1000Button" -- 1000元宝按钮
-- UmengClickEvent.YB2000Button             = "YB2000Button" -- 2000元宝按钮
-- UmengClickEvent.YB3000Button             = "YB3000Button" -- 3000元宝按钮
-- UmengClickEvent.ExchengeButton               = "ExchengeButton" -- 兑换记录切页按钮

-- UmengClickEvent.ActivityButton               = "ActivityButton" -- 活动按钮

-- UmengClickEvent.GetDiamondButton         = "GetDiamondButton" -- 领取钻石按钮
-- UmengClickEvent.GetGroupShareButton          = "GetGroupShareButton" -- 领取钻石好友群分享按钮
-- UmengClickEvent.GetShareFriendCircle     = "GetShareFriendCircle" -- 朋友圈分享按钮
-- UmengClickEvent.GetCanGetPage                = "GetCanGetPage" -- 可领取切页
-- UmengClickEvent.GetDiamondRightNow           = "GetDiamondRightNow" -- 立即领取按钮
-- UmengClickEvent.GetDiamondGet                = "GetDiamondGet" -- 领取按钮

-- UmengClickEvent.Record                       = "Record" -- 战绩按钮

        -- 牌局内
        UmengClickEvent.GameOpenWX                  = "GameOpenWX" -- 打开微信按钮
        UmengClickEvent.GameAskDismiss              = "GameAskDismiss" -- 申请解散
        UmengClickEvent.GameContinue                = "GameContinue" -- 继续游戏
        UmengClickEvent.GameAgree                   = "GameAgree" -- 同意
        UmengClickEvent.GameDisagree                = "GameDisagree" -- 不同意

        UmengClickEvent.GameBanVoice                = "GameBanVoice" -- 屏蔽玩家语音
        UmengClickEvent.GameVibrate                 = "GameVibrate" -- 震动
        UmengClickEvent.GameAdjustEffect            = "GameAdjustEffect" -- 调整音量-音效
        UmengClickEvent.GameAdjustMusic             = "GameAdjustMusic" -- 调整音量-音乐
        UmengClickEvent.GameCloseEffect             = "GameCloseEffect" -- 关闭音效
        UmengClickEvent.GameCloseMusic              = "GameCloseMusic" -- 关闭音乐

        UmengClickEvent.GameVoiceInput              = "GameVoiceInput" -- 语音输入按钮
        UmengClickEvent.GameChat1                   = "GameChat1" -- 快捷聊天1
        UmengClickEvent.GameChat2                   = "GameChat2" -- 快捷聊天2
        UmengClickEvent.GameChat3                   = "GameChat3" -- 快捷聊天3
        UmengClickEvent.GameChat4                   = "GameChat4" -- 快捷聊天4
        UmengClickEvent.GameChat5                   = "GameChat5" -- 快捷聊天5
        UmengClickEvent.GameChat6                   = "GameChat6" -- 快捷聊天6
        UmengClickEvent.GameChatText                = "GameChatText" -- 文字输入
        UmengClickEvent.GameChatSend                = "GameChatSend" -- 发送

        UmengClickEvent.GamePlayerHead              = "GamePlayerHead" -- 玩家头像
        UmengClickEvent.GameRuleButton              = "GameRuleButton" -- 规则按钮






-- 竖版
UmengClickEvent.LoginKeFu                   = "PLoginKeFu"                      -- 登录客服按钮
-- UmengClickEvent.LoginKeFuGongZhongHaoCopy    = "PLoginKeFuGongZhongHaoCopy"      -- 登录客服公众号复制
-- UmengClickEvent.LoginKeFuDaiLiCopy           = "PLoginKeFuDaiLiCopy"             -- 登录招募代理微信复制
-- UmengClickEvent.LoginKeFuOnline              = "PLoginKeFuOnline"                -- 登录在线客服
UmengClickEvent.GameCopyIdInfo              = "PCopyId"                     -- 复制ID
UmengClickEvent.MoreButton                  = "PMoreButton"                     -- 更多菜单按钮
UmengClickEvent.MoreSettingButton           = "PMoreSettingButton"              -- 更多设置按钮
UmengClickEvent.MoreRuleButton              = "PMoreRuleButton"                 -- 更多规则按钮
UmengClickEvent.MoreMsgButton               = "PMoreMsgButton"                  -- 更多消息按钮
UmengClickEvent.MoreNoticeButton            = "PMoreNoticeButton"               -- 更多公告按钮
UmengClickEvent.MoreKeFu                    = "PMoreKeFu"                       -- 更多客服按钮
UmengClickEvent.MoreKeFuGongZhongHaoCopy    = "PMoreKeFuGongZhongHaoCopy"       -- 更多客服公众号按钮
UmengClickEvent.MoreKeFuDaiLiCopy           = "PMoreKeFuDaiLiCopy"              -- 更多招募代理微信复制按钮
UmengClickEvent.MoreKeFuOnline              = "PMoreKeFuOnline"                 -- 更多在线客服
UmengClickEvent.MoreOpenWeChatButton        = "PMoreOpenWeChatButton"           -- 更多打开微信按钮
UmengClickEvent.MoreChangeAccountButton     = "PMoreChangeAccountButton"        -- 更多切换账号按钮
UmengClickEvent.MoreBackButton              = "PMoreBackButton"                 -- 更多返回按钮

UmengClickEvent.ChargeButton                = "PChargeButton"                   -- 充值按钮
UmengClickEvent.ContractButton              = "PContractButton"                 -- 联系客服按钮
UmengClickEvent.Charge12Button              = "PCharge12Button"                 -- 12元按钮
UmengClickEvent.Charge30Button              = "PCharge30Button"                 -- 30元按钮
UmengClickEvent.Charge98Button              = "PCharge98Button"                 -- 98元按钮

-- UmengClickEvent.HallDaiLiWXCopyButton        = "PHallDaiLiWXCopyButton"          -- 主界面招募代理复制微信按钮
UmengClickEvent.HallShareButton             = "PHallShareButton"            -- 主界面分享按钮
UmengClickEvent.HallShareGroupButton        = "PHallShareGroupButton"   -- 主界面分享好友按钮
UmengClickEvent.HallShareCircleButton       = "PHallShareCircleButton"  -- 主界面分享朋友圈按钮


UmengClickEvent.FreeDiamondCircle           = "PFreeDiamondCircle"      -- 免费钻石按钮
UmengClickEvent.FreeShareFriendCircle       = "PFreeShareFriendCircle"  -- 免费钻石分享朋友圈按钮

UmengClickEvent.HallADButton                = "PHallADButton"   -- 宣传图
UmengClickEvent.HallADButton1               = "PHallADButton1"  -- 宣传图1
UmengClickEvent.HallADButton2               = "PHallADButton2"  -- 宣传图2
UmengClickEvent.HallADButton3               = "PHallADButton3"  -- 宣传图3


UmengClickEvent.QinYouQuanButton                    = "PQinYouQuanButton" -- 亲友圈按钮
UmengClickEvent.QYQShareFriendsButton               = "PQYQShareFriendsButton" -- 亲友圈分享好友
UmengClickEvent.QYQShareFriendCircleButton          = "PQYQShareFriendCircleButton" -- 亲友圈分享朋友圈
UmengClickEvent.QYQShareQRCodeButton                = "PQYQShareQRCodeButton" -- 亲友圈分享二维码


UmengClickEvent.QYQClubList                         = "PQYQClubList"     -- 亲友圈列表 (俱乐部群主)
UmengClickEvent.QYQClubRoom                         = "PQYQClubRoom" -- 亲友圈分享二维码    (俱乐部群主)

            UmengClickEvent.ClubButton                  = "PClubButton" -- 俱乐部按钮
UmengClickEvent.HallCreateRoomButton        = "PHallCreateRoomButton" -- 创建房间按钮
UmengClickEvent.CreateClubButton            = "PCreateClubButton" -- 创建俱乐部房间按钮
UmengClickEvent.CreateRoomButton            = "PCreateRoomButton" -- 创建房间按钮
UmengClickEvent.JoinRoomButton              = "PJoinRoomButton"-- 加入房间按钮

UmengClickEvent.PersonalCenter              = "PPersonalCenter" -- 个人中心按钮
UmengClickEvent.DisclaimerButton            = "PDisclaimerButton" -- 免责声明按钮
-- UmengClickEvent.MyClubButton             = "PMyClubButton" -- 我的俱乐部按钮
UmengClickEvent.JoinClubButton              = "PJoinClubButton" -- 加入俱乐部按钮
UmengClickEvent.RealNameButton              = "PRealNameButton"-- 实名认证按钮

UmengClickEvent.RedPackageExchange          = "PRedPackageExchange" -- 红包兑换
UmengClickEvent.YBButton001                 = "YBButton001" -- 1000元宝按钮
UmengClickEvent.YBButton002                 = "YBButton002" -- 2000元宝按钮
UmengClickEvent.YBButton003                 = "YBButton003" -- 3000元宝按钮
UmengClickEvent.ExchengeButton              = "PExchengeButton" -- 兑换记录切页按钮

UmengClickEvent.ActivityButton              = "PActivityButton" -- 活动按钮

UmengClickEvent.GetDiamondButton            = "PGetDiamondButton" -- 领取钻石按钮
UmengClickEvent.GetGroupShareButton         = "PGetGroupShareButton" -- 领取钻石好友群分享按钮
UmengClickEvent.GetShareFriendCircle        = "PGetShareFriendCircle" -- 朋友圈分享按钮
UmengClickEvent.GetDiamondPage              = "PGetDiamondPage" -- 可领取切页
UmengClickEvent.GetCanGetPage               = "PGetCanGetPage" -- 可领取切页
UmengClickEvent.GetDiamondRightNow          = "PGetDiamondRightNow" -- 立即领取按钮
UmengClickEvent.GetDiamondGet               = "PGetDiamondGet" -- 领取按钮

UmengClickEvent.Record                      = "PRecord" -- 战绩按钮


-- 牌局内
UmengClickEvent.GameInviteFriend            = "PGameInviteFriend"  -- 邀请微信好友按钮
UmengClickEvent.GameCopyRoomInfo            = "PGameCopyRoomInfo"  -- 复制房间信息按钮
UmengClickEvent.GameDissmissRoom            = "PGameDissmissRoom"  -- 解散房间按钮
UmengClickEvent.GameCurPlayRule             = "PGameCurPlayRule"   -- 本场玩法按钮
UmengClickEvent.GameWaitVoice               = "PGameWaitVoice"     -- 按住发送语音按钮
UmengClickEvent.GameWaitChangeMode          = "PGameWaitChangeMode"-- 切换文字输入框按钮
UmengClickEvent.GameWaitInputText           = "PGameWaitInputText" -- 输入聊天内容
UmengClickEvent.GameWaitSendMsg             = "PGameWaitSendMsg"   -- 发送


UmengClickEvent.GameOpenWX                  = "PGameOpenWX"         -- 打开微信按钮
UmengClickEvent.GameAskDismiss              = "PGameAskDismiss"     -- 申请解散
UmengClickEvent.GameContinue                = "PGameContinue"       -- 继续游戏
UmengClickEvent.GameAgree                   = "PGameAgree"          -- 同意
UmengClickEvent.GameDisagree                = "PGameDisagree"       -- 不同意

UmengClickEvent.GameSetting                 = "PGameSetting"     -- 设置按钮
UmengClickEvent.GameBanVoice                = "PGameBanVoice"       -- 屏蔽玩家语音
UmengClickEvent.GameVibrate                 = "PGameVibrate"        -- 震动
UmengClickEvent.GameCloseEffect             = "PGameCloseEffect"    -- 关闭音效
UmengClickEvent.GameCloseMusic              = "GameCloseMusic"      -- 关闭音乐

UmengClickEvent.GameVoiceInput              = "PGameVoiceInput"     -- 语音输入按钮
UmengClickEvent.GameChat                    = "PGameChat"           -- 快捷聊天1-6
UmengClickEvent.GameChatText                = "PGameChatText"       -- 文字输入
UmengClickEvent.GameChatSend                = "PGameChatSend"       -- 发送
UmengClickEvent.GameChatFace                = "PGameChatFace"       -- 表情

UmengClickEvent.GamePlayerHead              = "PGamePlayerHead"     -- 玩家头像
UmengClickEvent.GameRuleButton              = "PGameRuleButton"     -- 规则按钮

else -- TODO
UmengClickEvent.LoginKeFu					= "LoginKeFu"						-- 登录客服按钮
-- UmengClickEvent.LoginKeFuGongZhongHaoCopy 	= "LoginKeFuGongZhongHaoCopy" 		-- 登录客服公众号复制
-- UmengClickEvent.LoginKeFuDaiLiCopy			= "LoginKeFuDaiLiCopy"				-- 登录招募代理微信复制
-- UmengClickEvent.LoginKeFuOnline				= "LoginKeFuOnline"					-- 登录在线客服
UmengClickEvent.GameCopyIdInfo 				= "PCopyId"							-- 复制ID
UmengClickEvent.MoreButton					= "MoreButton"						-- 更多菜单按钮
UmengClickEvent.MoreSettingButton			= "MoreSettingButton"				-- 更多设置按钮
UmengClickEvent.MoreRuleButton				= "MoreRuleButton"					-- 更多规则按钮
UmengClickEvent.MoreMsgButton				= "MoreMsgButton"					-- 更多消息按钮
UmengClickEvent.MoreNoticeButton			= "MoreNoticeButton"				-- 更多公告按钮
UmengClickEvent.MoreKeFu					= "MoreKeFu"						-- 更多客服按钮
UmengClickEvent.MoreKeFuGongZhongHaoCopy	= "MoreKeFuGongZhongHaoCopy"		-- 更多客服公众号按钮
UmengClickEvent.MoreKeFuDaiLiCopy			= "MoreKeFuDaiLiCopy"				-- 更多招募代理微信复制按钮
UmengClickEvent.MoreKeFuOnline				= "MoreKeFuOnline"					-- 更多在线客服
UmengClickEvent.MoreOpenWeChatButton		= "MoreOpenWeChatButton"			-- 更多打开微信按钮
UmengClickEvent.MoreChangeAccountButton		= "MoreChangeAccountButton"			-- 更多切换账号按钮

UmengClickEvent.ChargeButton				= "ChargeButton"					-- 充值按钮
UmengClickEvent.Charge12Button				= "Charge12Button"					-- 12元按钮
UmengClickEvent.Charge30Button				= "Charge30Button"					-- 30元按钮
UmengClickEvent.Charge98Button				= "Charge98Button"					-- 98元按钮

UmengClickEvent.HallDaiLiButton				= "HallDaiLiButton"					-- 主界面招募代理按钮
UmengClickEvent.HallDaiLiWXCopyButton		= "HallDaiLiWXCopyButton"			-- 主界面招募代理复制微信按钮

UmengClickEvent.FreeDiamondCircle 			= "FreeDiamondCircle" 				-- 免费钻石按钮
UmengClickEvent.FreeShareFriendCircle 		= "FreeShareFriendCircle" 			-- 免费钻石分享朋友圈按钮
UmengClickEvent.ClubButton 					= "ClubButton" -- 俱乐部按钮
UmengClickEvent.HallCreateRoomButton		= "HallCreateRoomButton" -- 创建房间按钮
UmengClickEvent.CreateClubButton			= "CreateClubButton" -- 创建俱乐部房间按钮
UmengClickEvent.CreateRoomButton			= "CreateRoomButton" -- 创建房间按钮
UmengClickEvent.JoinRoomButton 				= "JoinRoomButton"-- 加入房间按钮

UmengClickEvent.PersonalCenter				= "PersonalCenter" -- 个人中心按钮
UmengClickEvent.DisclaimerButton			= "DisclaimerButton" -- 免责声明按钮
UmengClickEvent.JoinClubButton				= "JoinClubButton" -- 加入俱乐部按钮
UmengClickEvent.RealNameButton				= "RealNameButton"-- 实名认证按钮


UmengClickEvent.RedPackageExchange			= "RedPackageExchange" -- 红包兑换
UmengClickEvent.YBButton001					= "YBButton001" -- 1000元宝按钮
UmengClickEvent.YBButton002					= "YBButton002" -- 2000元宝按钮
UmengClickEvent.YBButton003					= "YBButton003" -- 3000元宝按钮
UmengClickEvent.ExchengeButton				= "ExchengeButton" -- 兑换记录切页按钮

UmengClickEvent.ActivityButton				= "ActivityButton" -- 活动按钮

UmengClickEvent.GetDiamondButton			= "GetDiamondButton" -- 领取钻石按钮
UmengClickEvent.GetGroupShareButton			= "GetGroupShareButton" -- 领取钻石好友群分享按钮
UmengClickEvent.GetShareFriendCircle		= "GetShareFriendCircle" -- 朋友圈分享按钮
UmengClickEvent.GetDiamondPage				= "GetDiamondPage" -- 可领取切页
UmengClickEvent.GetCanGetPage				= "GetCanGetPage" -- 可领取切页
UmengClickEvent.GetDiamondRightNow			= "GetDiamondRightNow" -- 立即领取按钮
UmengClickEvent.GetDiamondGet				= "GetDiamondGet" -- 领取按钮

UmengClickEvent.Record						= "Record" -- 战绩按钮

-- 牌局内
UmengClickEvent.GameOpenWX					= "GameOpenWX" -- 打开微信按钮
UmengClickEvent.GameDismiss					= "GameDismiss" -- 解散按钮
UmengClickEvent.GameAskDismiss				= "GameAskDismiss" -- 申请解散
UmengClickEvent.GameContinue				= "GameContinue" -- 继续游戏
UmengClickEvent.GameAgree					= "GameAgree" -- 同意
UmengClickEvent.GameDisagree				= "GameDisagree" -- 不同意

UmengClickEvent.GameSetting					= "GameSetting" -- 设置
UmengClickEvent.GameBanVoice				= "GameBanVoice" -- 屏蔽玩家语音
UmengClickEvent.GameVibrate					= "GameVibrate" -- 震动
UmengClickEvent.GameAdjustEffect			= "GameAdjustEffect" -- 调整音量-音效
UmengClickEvent.GameAdjustMusic				= "GameAdjustMusic" -- 调整音量-音乐
UmengClickEvent.GameCloseEffect				= "GameCloseEffect" -- 关闭音效
UmengClickEvent.GameCloseMusic				= "GameCloseMusic" -- 关闭音乐

UmengClickEvent.GameVoiceInput				= "GameVoiceInput" -- 语音输入按钮
UmengClickEvent.GameChat					= "GameChat"  -- 聊天按钮

UmengClickEvent.GameChatText					= "GameChatText" -- 快捷聊天
UmengClickEvent.GameChatFace					= "GameChatFace" -- 快捷表情
UmengClickEvent.GameChatSend					= "GameChatSend"  -- 发送

UmengClickEvent.GamePlayerHead					= "GamePlayerHead" -- 玩家头像







-- -- 竖版
-- UmengClickEvent.LoginKeFu					= "PLoginKeFu"						-- 登录客服按钮
-- UmengClickEvent.LoginKeFuGongZhongHaoCopy 	= "PLoginKeFuGongZhongHaoCopy" 		-- 登录客服公众号复制
-- UmengClickEvent.LoginKeFuDaiLiCopy			= "PLoginKeFuDaiLiCopy"				-- 登录招募代理微信复制
-- UmengClickEvent.LoginKeFuOnline				= "PLoginKeFuOnline"				-- 登录在线客服


-- UmengClickEvent.MoreButton					= "PMoreButton"						-- 更多菜单按钮
-- UmengClickEvent.MoreSettingButton			= "PMoreSettingButton"				-- 更多设置按钮
-- UmengClickEvent.MoreRuleButton				= "PMoreRuleButton"					-- 更多规则按钮
-- UmengClickEvent.MoreMsgButton				= "PMoreMsgButton"					-- 更多消息按钮
-- UmengClickEvent.MoreNoticeButton			= "PMoreNoticeButton"				-- 更多公告按钮
-- 			UmengClickEvent.MoreKeFu					= "PMoreKeFu"						-- 更多客服按钮
-- 			UmengClickEvent.MoreKeFuGongZhongHaoCopy	= "PMoreKeFuGongZhongHaoCopy"		-- 更多客服公众号按钮
-- 			UmengClickEvent.MoreKeFuDaiLiCopy			= "PMoreKeFuDaiLiCopy"				-- 更多招募代理微信复制按钮
-- 			UmengClickEvent.MoreKeFuOnline				= "PMoreKeFuOnline"					-- 更多在线客服
-- 			UmengClickEvent.MoreOpenWeChatButton		= "PMoreOpenWeChatButton"			-- 更多打开微信按钮
-- 			UmengClickEvent.MoreChangeAccountButton		= "PMoreChangeAccountButton"		-- 更多切换账号按钮
-- 			UmengClickEvent.MoreBackButton				= "PMoreBackButton"					-- 更多返回按钮

-- 			UmengClickEvent.ChargeButton				= "PChargeButton"					-- 充值按钮
-- 			UmengClickEvent.ContractButton				= "PContractButton"					-- 联系客服按钮
-- 			UmengClickEvent.Charge12Button				= "PCharge12Button"					-- 12元按钮
-- 			UmengClickEvent.Charge30Button				= "PCharge30Button"					-- 30元按钮
-- 			UmengClickEvent.Charge98Button				= "PCharge98Button"					-- 98元按钮

-- -- UmengClickEvent.HallDaiLiWXCopyButton		= "PHallDaiLiWXCopyButton"			-- 主界面招募代理复制微信按钮
-- 			UmengClickEvent.HallShareButton				= "PHallShareButton"			-- 主界面分享按钮
-- 			UmengClickEvent.HallShareGroupButton		= "PHallShareGroupButton"	-- 主界面分享好友按钮
-- 			UmengClickEvent.HallShareCircleButton		= "PHallShareCircleButton"	-- 主界面分享朋友圈按钮


-- 			UmengClickEvent.FreeDiamondCircle 			= "PFreeDiamondCircle" 		-- 免费钻石按钮
-- 			UmengClickEvent.FreeShareFriendCircle 		= "PFreeShareFriendCircle" 	-- 免费钻石分享朋友圈按钮

-- 			UmengClickEvent.HallADButton 				= "PHallADButton"	-- 宣传图
-- 			UmengClickEvent.HallADButton1 				= "PHallADButton1"	-- 宣传图1
-- 			UmengClickEvent.HallADButton2 				= "PHallADButton2"	-- 宣传图2
-- 			UmengClickEvent.HallADButton3 				= "PHallADButton3"	-- 宣传图3


UmengClickEvent.QinYouQuanButton 					= "PQinYouQuanButton" -- 亲友圈按钮
UmengClickEvent.QYQShareFriendsButton 				= "PQYQShareFriendsButton" -- 亲友圈分享好友(俱乐部群主)
UmengClickEvent.QYQShareFriendCircleButton 			= "PQYQShareFriendCircleButton" -- 亲友圈分享朋友圈(俱乐部群主)
UmengClickEvent.QYQShareQRCodeButton 				= "PQYQShareQRCodeButton" -- 亲友圈分享二维码(俱乐部群主)

UmengClickEvent.QYQClubList 						= "PQYQClubList" 	 -- 亲友圈列表 (俱乐部群主)
UmengClickEvent.QYQClubRoom 						= "PQYQClubRoom" -- 亲友圈分享二维码	(俱乐部群主)

-- UmengClickEvent.HallCreateRoomButton		= "PHallCreateRoomButton" -- 创建房间按钮
-- 			UmengClickEvent.CreateClubButton			= "PCreateClubButton" -- 创建俱乐部房间按钮
-- 			UmengClickEvent.CreateRoomButton			= "PCreateRoomButton" -- 创建房间按钮
-- UmengClickEvent.JoinRoomButton 				= "PJoinRoomButton"-- 加入房间按钮

-- UmengClickEvent.PersonalCenter				= "PPersonalCenter" -- 个人中心按钮
-- UmengClickEvent.DisclaimerButton			= "PDisclaimerButton" -- 免责声明按钮
-- UmengClickEvent.MyClubButton				= "PMyClubButton" -- 我的俱乐部按钮
-- UmengClickEvent.RealNameButton				= "PRealNameButton"-- 实名认证按钮

-- 			UmengClickEvent.RedPackageExchange			= "PRedPackageExchange" -- 红包兑换
-- 			UmengClickEvent.YB1000Button				= "PYB1000Button" -- 1000元宝按钮
-- 			UmengClickEvent.YB2000Button				= "PYB2000Button" -- 2000元宝按钮
-- 			UmengClickEvent.YB3000Button				= "PYB3000Button" -- 3000元宝按钮
-- 			UmengClickEvent.ExchengeButton				= "PExchengeButton" -- 兑换记录切页按钮

-- UmengClickEvent.ActivityButton				= "PActivityButton" -- 活动按钮

-- 			UmengClickEvent.GetDiamond					= "PGetDiamond" -- 领取钻石按钮
-- 			UmengClickEvent.GetGroupShareButton			= "PGetGroupShareButton" -- 领取钻石好友群分享按钮
-- 			UmengClickEvent.GetShareFriendCircle		= "PGetShareFriendCircle" -- 朋友圈分享按钮
-- 			UmengClickEvent.GetCanGetPage				= "PGetCanGetPage" -- 可领取切页
-- 			UmengClickEvent.GetDiamondRightNow			= "PGetDiamondRightNow" -- 立即领取按钮
-- 			UmengClickEvent.GetDiamondGet				= "PGetDiamondGet" -- 领取按钮

-- UmengClickEvent.Record						= "PRecord" -- 战绩按钮


-- 			-- 牌局内
-- 			UmengClickEvent.GameInviteFriend			= "PGameInviteFriend"  -- 邀请微信好友按钮
-- 			UmengClickEvent.GameCopyRoomInfo			= "PGameCopyRoomInfo"  -- 复制房间信息按钮
-- 			UmengClickEvent.GameDissmissRoom			= "PGameDissmissRoom"  -- 解散房间按钮
-- 			UmengClickEvent.GameCurPlayRule				= "PGameCurPlayRule"   -- 本场玩法按钮
-- 			UmengClickEvent.GameWaitVoice				= "PGameWaitVoice"	   -- 按住发送语音按钮
-- 			UmengClickEvent.GameWaitChangeMode			= "PGameWaitChangeMode"-- 切换文字输入框按钮
-- 			UmengClickEvent.GameWaitInputText			= "PGameWaitInputText" -- 输入聊天内容
-- 			UmengClickEvent.GameWaitSendMsg				= "PGameWaitSendMsg"   -- 发送


-- 			UmengClickEvent.GameOpenWX					= "PGameOpenWX" -- 打开微信按钮
-- 			UmengClickEvent.GameDismiss					= "GameDismiss" -- 解散按钮
-- 			UmengClickEvent.GameAskDismiss				= "PGameAskDismiss" -- 申请解散
-- 			UmengClickEvent.GameContinue				= "PGameContinue" -- 继续游戏
-- 			UmengClickEvent.GameAgree					= "PGameAgree" -- 同意
-- 			UmengClickEvent.GameDisagree				= "PGameDisagree" -- 不同意

-- 			UmengClickEvent.GameSetting					= "PGameSetting" -- 设置
-- 			UmengClickEvent.GameBanVoice				= "PGameBanVoice" -- 屏蔽玩家语音
-- 			UmengClickEvent.GameVibrate					= "PGameVibrate" -- 震动
-- 			UmengClickEvent.GameAdjustEffect			= "PGameAdjustEffect" -- 调整音量-音效
-- 			UmengClickEvent.GameAdjustMusic				= "PGameAdjustMusic" -- 调整音量-音乐
-- 			UmengClickEvent.GameCloseEffect				= "PGameCloseEffect" -- 关闭音效
-- 			UmengClickEvent.GameCloseMusic				= "PGameCloseMusic" -- 关闭音乐

-- 			UmengClickEvent.GameVoiceInput				= "PGameVoiceInput" -- 语音输入按钮
-- 			UmengClickEvent.GameChat					= "PGameChat"  -- 聊天按钮
-- 			UmengClickEvent.GameChat1					= "PGameChat1" -- 快捷聊天1
-- 			UmengClickEvent.GameChat2					= "PGameChat2" -- 快捷聊天2
-- 			UmengClickEvent.GameChat3					= "PGameChat3" -- 快捷聊天3
-- 			UmengClickEvent.GameChat4					= "PGameChat4" -- 快捷聊天4
-- 			UmengClickEvent.GameChat5					= "PGameChat5" -- 快捷聊天5
-- 			UmengClickEvent.GameChat6					= "PGameChat6" -- 快捷聊天6
-- 			UmengClickEvent.GameChatText				= "PGameChatText" -- 文字输入
-- 			UmengClickEvent.GameChatSend				= "PGameChatSend" -- 发送

-- 			UmengClickEvent.GamePlayerHead				= "PGamePlayerHead" -- 玩家头像
-- 			UmengClickEvent.GameRuleButton				= "PGameRuleButton" -- 规则按钮
end

-- Poker类(斗地主)牌局
UmengClickEvent.DDZGameDissmissRoom			= "PDDZGameDissmissRoom"  	-- 斗地主解散按钮
UmengClickEvent.DDZGameAskDismiss				= "PDDZGameAskDismiss" 		-- 斗地主申请解散
UmengClickEvent.DDZGameContinue				= "PDDZGameContinue" 		-- 斗地主取消解散
UmengClickEvent.DDZGameAgree					= "PDDZGameAgree" 			-- 同意
UmengClickEvent.DDZGameDisagree				= "PDDZGameDisagree" 		-- 不同意

UmengClickEvent.DDZMoreButton					= "PDDZMoreButton"			-- 更多菜单按钮
UmengClickEvent.DDZGameSetting                 = "PDDZGameSetting"     	-- 设置按钮
UmengClickEvent.DDZGameRuleButton				= "PDDZGameRuleButton" 		-- 规则按钮
-- UmengClickEvent.DDZGameCloseEffect				= "PDDZGameCloseEffect" 	-- 关闭音效
-- UmengClickEvent.DDZGameCloseMusic				= "PDDZGameCloseMusic" 		-- 关闭音乐

UmengClickEvent.DDZGameVoiceInput				= "PDDZGameVoiceInput" 		-- 语音输入按钮

UmengClickEvent.DDZGameChatText				= "PDDZGameChatText" 	  	-- 文字输入
UmengClickEvent.DDZGameChat					= "PDDZGameChat" 	  		-- 快捷聊天1-6
UmengClickEvent.DDZGameChatSend				= "PDDZGameChatSend" 		-- 发送文字
UmengClickEvent.DDZGameChatFace				= "PDDZGameChatFace" 		-- 表情

UmengClickEvent.DDZGamePlayerHead				= "PDDZGamePlayerHead" 		-- 玩家头像
UmengClickEvent.DDZGameCopyRoomInfo			= "PDDZGameCopyRoomInfo"  	-- 复制房间信息按钮



-- Poker类(跑得快)牌局
UmengClickEvent.PDKGameDissmissRoom			= "PPDKGameDissmissRoom"  	-- 斗地主申请解散
UmengClickEvent.PDKGameAskDismiss				= "PPDKGameAskDismiss" 		-- 申请解散
UmengClickEvent.PDKGameContinue				= "PPDKGameContinue" 		-- 继续游戏
UmengClickEvent.PDKGameAgree					= "PPDKGameAgree" 			-- 同意
UmengClickEvent.PDKGameDisagree				= "PPDKGameDisagree" 		-- 不同意

UmengClickEvent.PDKMoreButton					= "PPDKMoreButton"			-- 更多菜单按钮
UmengClickEvent.PDKGameSetting                 = "PPDKGameSetting"     	-- 设置按钮
UmengClickEvent.PDKGameRuleButton				= "PPDKGameRuleButton" 		-- 规则按钮
-- UmengClickEvent.PDKGameCloseEffect				= "PPDKGameCloseEffect" 	-- 关闭音效
-- UmengClickEvent.PDKGameCloseMusic				= "PPDKGameCloseMusic" 		-- 关闭音乐

UmengClickEvent.PDKGameVoiceInput				= "PPDKGameVoiceInput" 		-- 语音输入按钮

UmengClickEvent.PDKGameChatText				= "PPDKGameChatText" 	  	-- 文字输入
UmengClickEvent.PDKGameChat					= "PPDKGameChat" 	  		-- 快捷聊天1-6
UmengClickEvent.PDKGameChatSend				= "PPDKGameChatSend" 		-- 发送文字
UmengClickEvent.PDKGameChatFace				= "PPDKGameChatFace" 		-- 表情

UmengClickEvent.PDKGamePlayerHead				= "PPDKGamePlayerHead" 		-- 玩家头像
UmengClickEvent.PDKGameCopyRoomInfo			= "PPDKGameCopyRoomInfo"  	-- 复制房间信息按钮

UmengClickEvent.PDKGameRecord			= "PPDKGameRecord"  	-- 复制房间信息按钮



-- Poker类(掼蛋)牌局
UmengClickEvent.GDGameDissmissRoom          = "PGDGameDissmissRoom"     -- 斗地主申请解散
UmengClickEvent.GDGameAskDismiss                = "PGDGameAskDismiss"       -- 申请解散
UmengClickEvent.GDGameContinue              = "PGDGameContinue"         -- 继续游戏
UmengClickEvent.GDGameAgree                 = "PGDGameAgree"            -- 同意
UmengClickEvent.GDGameDisagree              = "PGDGameDisagree"         -- 不同意

UmengClickEvent.GDMoreButton                    = "PGDMoreButton"           -- 更多菜单按钮
UmengClickEvent.GDGameSetting                 = "PGDGameSetting"        -- 设置按钮
UmengClickEvent.GDGameRuleButton                = "PGDGameRuleButton"       -- 规则按钮
-- UmengClickEvent.GDGameCloseEffect                = "PGDGameCloseEffect"  -- 关闭音效
-- UmengClickEvent.GDGameCloseMusic             = "PGDGameCloseMusic"       -- 关闭音乐

UmengClickEvent.GDGameVoiceInput                = "PGDGameVoiceInput"       -- 语音输入按钮

UmengClickEvent.GDGameChatText              = "PGDGameChatText"         -- 文字输入
UmengClickEvent.GDGameChat                  = "PGDGameChat"             -- 快捷聊天1-6
UmengClickEvent.GDGameChatSend              = "PGDGameChatSend"         -- 发送文字
UmengClickEvent.GDGameChatFace              = "PGDGameChatFace"         -- 表情

UmengClickEvent.GDGamePlayerHead                = "PGDGamePlayerHead"       -- 玩家头像
UmengClickEvent.GDGameCopyRoomInfo          = "PGDGameCopyRoomInfo"     -- 复制房间信息按钮

UmengClickEvent.GDGameRecord            = "PGDGameRecord"   -- 复制房间信息按钮

return UmengClickEvent
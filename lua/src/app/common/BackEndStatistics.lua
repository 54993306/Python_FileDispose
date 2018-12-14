--
-- 后台统计微信分享相关
-- Author: Machine
-- Date: 2018-07-27
-- 


local BackEndStatistics = {}

	BackEndStatistics.DiamondButton 			= 11	  	-- 点击钻石图标
	BackEndStatistics.DiamondShareMoments 		= 12		-- 点击分享领钻"分享朋友圈"按钮

BackEndStatistics.HallShare					= 13		-- 点击大厅分享按钮  --横版没有
BackEndStatistics.HallShareGroup			= 14		-- 点击大厅分享"好友/群"按钮 --横版没有
BackEndStatistics.HallShareMoments			= 15		-- 点击大厅分享"朋友圈"按钮 --横版没有

	BackEndStatistics.HallGetDiamond			= 16 		--领取钻石按钮
	BackEndStatistics.HallGetDiamondGroup		= 17		--领取钻石分享好友/群按钮
	BackEndStatistics.HallGetDiamondMoments		= 18 		--领取钻石分享朋友圈按钮

	BackEndStatistics.GetNewShare				= 19 		-- 点击活动按钮
BackEndStatistics.GetNewShareGroup			= 20 		-- 点击活动好友/群按钮   meiyou

	BackEndStatistics.QinyouGroup				= 21		-- 点击分享好友/群按钮
	BackEndStatistics.QinyouMoments				= 22		-- 点击分享朋友圈按钮
	BackEndStatistics.QinyouQRCode				= 23		-- 点击分享二维码按钮

BackEndStatistics.RoomInviteWXFriend		= 24		-- 创建房间后邀请（好友/群）

return BackEndStatistics
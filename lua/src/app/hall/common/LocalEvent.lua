
-- 本地消息定义

local LocalEvent = {}

LocalEvent.HallCustomerService      = 100
LocalEvent.GameUISignal             = 101
LocalEvent.GameUIBattery            = 102
LocalEvent.FriendRoomSignal         = 103
LocalEvent.FriendRoomBattery        = 104
LocalEvent.UpdateClubState          = 105
LocalEvent.RemoveHeadList           = 106
LocalEvent.ClubApplyRedChange       = 107
LocalEvent.PlayerIp                 = 108
LocalEvent.IosScheme                = 109

LocalEvent.CreateClubModel          = 120   -- 创建俱乐部模版成功

LocalEvent.ServerNotice             = 200
LocalEvent.TopTip                   = 201

LocalEvent.BindWechatSucceed        = 300    -- 绑定微信54
LocalEvent.RefreshToken             = 301    -- 刷新token成功

LocalEvent.PassCard                 = 1001
LocalEvent.CanPlayCard              = 1002

return LocalEvent

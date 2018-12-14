--[[---------------------------------------- 
-- 作者： 徐松
-- 时间： 2017.12.28
-- 摘要： 分享文字/图片到微信
]]-------------------------------------------


local SharePreset = require "app.hall.common.SharePreset"

local ShareToWX = class("ShareToWX")


local kCmdShareType = {
    toHaoYouQun_Text = 2,
    toPengYouQuan_Text = 1,
    toHaoYouQun_Image = 4,
    toPengYouQuan_Image = 5,
}

-- 服务器指定的分享模式
local kShareType = {
    Text = "1",   -- 文字模式
    Image = "2",  -- 图片模式
}

local kTipLater = "请稍后再试"

-- 单例持有
ShareToWX.mInstance = nil

--分享路径 1:大厅主界面分享，免费按钮分享路径 2：牌局等待界面分享路径

local str = "&source="

ShareToWX.ShareFriendQun            = str.."1" -- 大厅分享给好友（无奖励）竖版
ShareToWX.ShareFriendQuan           = str.."2" -- 大厅分享（无奖励）竖版
ShareToWX.FreeShareFriendQuan       = str.."3" -- 大厅分享（有奖励）
ShareToWX.PaijuShareFriend          = str.."4" -- 等待界面邀请好友
ShareToWX.ClubShareFriendQun        = str.."5" -- 亲友圈分享给好友房间
ShareToWX.ClubShareFriendQuan       = str.."6" -- 亲友圈分享
ShareToWX.DiamoundShareFriendQun    = str.."7" -- 领取钻石分享给好友
ShareToWX.DiamoundShareFriendQuan   = str.."8" -- 领取钻石
ShareToWX.ClubQRShareFriend         = str.."9" -- 分享俱乐部二维码给好友
-- 功能： [Static]获取一个实例
-- 返回值： ShareLink实例
function ShareToWX.getInstance()
	if not ShareToWX.mInstance then
		ShareToWX.mInstance = ShareToWX.new()
	end
	return ShareToWX.mInstance
end

-- 功能： 构造函数
-- 返回值： ShareLink实例
function ShareToWX:ctor()
	self.mSharePreset = SharePreset.getInstance()
	-- 存储接收到的分享数据
	self.mServerDayShareInfo = nil
	-- 字串标记
	self.mTag = nil
end

-- 功能： [Public] 预置操作，如果是图片分享模式，下载图片合成上二维码
-- 返回值： 无
function ShareToWX:prepare( serverDayShareInfo )
	self.mTag = "Share" .. os.time()
	self.mServerDayShareInfo = clone(serverDayShareInfo)
	if self.mServerDayShareInfo then
		if self.mServerDayShareInfo.shareType == kShareType.Image then
			local shareImageUrl = self.mServerDayShareInfo.shareImageUrl
			local appDownLoadUrl = self.mServerDayShareInfo.appDownLoadUrl
			local urlHead = self:getUrlHead()
			if shareImageUrl ~= "" then
				if string.find(shareImageUrl, "http") ~= 1 then
					shareImageUrl = urlHead .. shareImageUrl 
				end
			end
			if appDownLoadUrl ~= "" then
				if string.find(appDownLoadUrl, "http") ~= 1 then
					appDownLoadUrl = urlHead .. appDownLoadUrl
				end
			end
			self.mSharePreset:mkImageCell(self.mTag, shareImageUrl, appDownLoadUrl)
		end
	end
end

-- 功能： 获得资源地址头
-- 返回值： String
function ShareToWX:getUrlHead()
	local rurl = kSystemConfig:getDataByKe("resource_url")
	if rurl ~= false then
		return rurl.va or ""
	end
	return ""
end

-- 功能： [Public] 分享到微信好友\群
-- 返回值： 无
-- handler： 回调函数
-- target：	目标对象
function ShareToWX:shareToHaoYouQun( handler, target ,tag)
	if self.mServerDayShareInfo then
		local info = self.mServerDayShareInfo
		if info.shareType == kShareType.Text then
			tag = tag or "&source=0"
			local data = {
                cmd = NativeCall.CMD_WECHAT_SHARE,
                type = kCmdShareType.toHaoYouQun_Text,
                title = info.shareTitle,
                desc = info.shareDesc,
                url = info.shareLink..tag,
                headUrl = "",
            }

            TouchCaptureView.getInstance():showWithTime()
            NativeCall.getInstance():callNative(data, handler, target)
		elseif info.shareType == kShareType.Image then
			local imgPath = self.mSharePreset:getImageLocalByTag(self.mTag)
			if imgPath == false then
				Toast.getInstance():show(kTipLater)
			else
				local data = {
	                cmd = NativeCall.CMD_WECHAT_SHARE,
	                type = kCmdShareType.toHaoYouQun_Image,
	                path = imgPath
	            }
	            TouchCaptureView.getInstance():showWithTime()
	            NativeCall.getInstance():callNative(data, handler, target)
	        end
		end
	end 
end

-- 功能： [Public] 分享到微信朋友圈
-- 返回值： 无
-- handler： 回调函数
-- target：	目标对象
function ShareToWX:shareToPengYouQuan( handler, target )
	if self.mServerDayShareInfo then
		local info = self.mServerDayShareInfo
		if info.shareType == kShareType.Text then
			local data = {
                cmd = NativeCall.CMD_WECHAT_SHARE,
                type = kCmdShareType.toPengYouQuan_Text,
                title = info.shareTitle,
                desc = info.shareDesc,
                url = info.shareLink,
            }
            TouchCaptureView.getInstance():showWithTime()
            NativeCall.getInstance():callNative(data, handler, target)
		elseif info.shareType == kShareType.Image then
			local imgPath = self.mSharePreset:getImageLocalByTag(self.mTag)
			if imgPath == false then
				Toast.getInstance():show(kTipLater)
			else
				local data = {
	                cmd = NativeCall.CMD_WECHAT_SHARE,
	                type = kCmdShareType.toPengYouQuan_Image,
	                path = imgPath
	            }
	            TouchCaptureView.getInstance():showWithTime()
	            NativeCall.getInstance():callNative(data, handler, target)
	        end
		end
	end
end


return ShareToWX
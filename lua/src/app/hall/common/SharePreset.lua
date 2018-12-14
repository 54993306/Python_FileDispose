--[[---------------------------------------- 
-- 作者： 徐松
-- 时间： 2017.12.20
-- 摘要： 为分享功能生产图片，下载图片，再合成上二维码链接
]]-------------------------------------------


local SharePreset = class("SharePreset")

local ImageCell = class("ImageCell")
local Delay = class("Delay")

-- 背景图片大小
local kImageDefSize = {
	width = 1440,
	height = 1152,
}
-- 二维码填置区域
local kQrCodeDefRect = {
	x = 979,
	y = 89,
	width = 385,
	height = 385,
}

-- 单例持有
SharePreset.mInstance = nil

-- 功能： [Static]获取一个实例
-- 返回值： ShareLink实例
function SharePreset.getInstance()
	if not SharePreset.mInstance then
		SharePreset.mInstance = SharePreset.new()
	end
	return SharePreset.mInstance
end

-- 功能： 构造函数
-- 返回值： ShareLink实例
function SharePreset:ctor()
	-- 产生的资源存放目录
	self.mCacheDir = CACHEDIR .. "shareimg/"
	-- 存储Image对象
	self.mImageCells = {}
	-- 是否准备就绪
	self.mIsPrepare = false

	self:mkCache()
end

-- 功能： 先清理然后创建缓存文件夹
-- 返回值： 无
function SharePreset:mkCache()
	-- 删除文件夹操作失败后尝试次数
	local removeTry = Delay.new(3)
	-- 删除文件夹有延迟，设置等待尝试次数
	local removeListenTry = Delay.new(5)
	-- 创建文件夹操作失败后尝试次数
	local createTry = Delay.new(3)
	local fileUtils = cc.FileUtils:getInstance()

	local function initDir()
		self.mIsPrepare = false
		-- 创建文件夹
		local function createDir()
			-- 已存在此文件夹
			if fileUtils:isDirectoryExist(self.mCacheDir) == false then
				if fileUtils:createDirectory(self.mCacheDir) == true then
					self.mIsPrepare = true
					self:work()
				else
					createTry:wheel(createDir)
				end
			else
				removeListenTry:wheel(createDir)
			end
		end
		-- 如果存在此文件夹，删除掉
		if fileUtils:isDirectoryExist(self.mCacheDir) == true then
			if fileUtils:removeDirectory(self.mCacheDir) == true then
				createDir()
			else
				removeTry:wheel(initDir)
			end
		else
			createDir()
		end
	end
	initDir()
end

-- 功能： 创建一个图片处理单元
-- 返回值： 无
-- tag： 字串标记
-- imgUrl： 背景图片地址
-- linkUrl： 二维码链接
-- qrRect： 二维码填置区域
-- imgSize： 背景图片尺寸
function SharePreset:mkImageCell( tag, imgUrl, linkUrl, qrRect, imgSize )
	-- 不存储重复的Image，也可排除此函数的多次调用
	if not self.mImageCells[tag] then
		self.mImageCells[tag] = ImageCell.new(tag, imgUrl, imgSize, linkUrl, qrRect)
	end
	self:work()
end

function SharePreset:work()
	if self.mIsPrepare == true then
		for _, v in pairs(self.mImageCells) do
			if v then
				v:work()
			end
		end
	end
end

-- 功能： [Public] 获取本地图片地址
-- 返回值： String or false
function SharePreset:getImageLocalByTag( tag )
	if self.mImageCells[tag] then
		return self.mImageCells[tag]:getLocalPath()
	end
	return false
end


-- Class ImageCell --

function ImageCell:ctor( tag, imgUrl, imgSize, linkUrl, qrRect )
	self.mSp = SharePreset:getInstance()
	-- 以tag索引
	self.mTag = tag
	self.mImgUrl = imgUrl or ""
	self.mImgSize = imgSize or kImageDefSize
	self.mLinkUrl = linkUrl or ""
	self.mQrRect = qrRect or kQrCodeDefRect

	-- 背景图的文件名和后辍名
	self.mImgSuffix = ".png"
	-- self.mImgFileName = nil
	self.mImgFullPath = nil
	-- 背景图贴上二维码后的文件名和路径
	-- self.mCompImgFileName = nil
	self.mCompImgFullPath = nil
	-- 默认的合成图，当网络图片获取失败时或者来不及下载时使用
	self.mDefaultCompImgFullPath = nil

	-- 初始化操作标识
	self.mIsWork = false
	self.mRuning = false
	self.mLoading = false
	
	self:init()
end

function ImageCell:init()
	if self.mImgUrl ~= "" then
		self.mImgSuffix = "." .. self.mImgUrl:match(".+%.(%w+)$")
	end
	self.mImgFullPath = self.mSp.mCacheDir .. self.mTag .. "_bg" .. self.mImgSuffix
	self.mCompImgFullPath = self.mSp.mCacheDir .. self.mTag .. "_compound" .. self.mImgSuffix
	self.mDefaultCompImgFullPath = self.mSp.mCacheDir .. self.mTag .. "_def_compound" .. self.mImgSuffix
end

-- 功能： 获取产出图片的本地路径
-- 		优先返回下载好的网络图片合成图，
--		如果没有准备好图片，画一张默认的白底背景合成图，使用户点击第二次按钮可以返回默认合成图
-- 返回值： String or False
function ImageCell:getLocalPath()
	local fileUtils = cc.FileUtils:getInstance()
	if fileUtils:isFileExist(self.mCompImgFullPath) == true then
		return self.mCompImgFullPath
	elseif fileUtils:isFileExist(self.mDefaultCompImgFullPath) == true then
		-- 这里再次尝试下载网络图片并合成
		if self.mRuning == false then
			self:load()
		end
		return self.mDefaultCompImgFullPath
	elseif self.mRuning == false then
		-- 绘制默认合成图
		self:drawCompoundImg()
	end
	return false
end

function ImageCell:work()
	if self.mIsWork == false then
		self.mIsWork = true
		self:drawCompoundImg()
		self:load()
	end
end

-- 功能： [Private] 加载网络图片
-- 返回值： 无
function ImageCell:load()
	local function onRequestCallback( event )
		self.mLoading = false
		if event.name == "completed" then
			local code = event.request:getResponseStatusCode()
			-- 请求结束，但没有返回 200 响应代码
			if code ~= 200 then
				return
			end
			-- 写入磁盘
			event.request:saveResponseData(self.mImgFullPath)
			self:compound()
		elseif event.name == "failed" then
			return
		end
	end
	if self.mLoading == false and self.mImgUrl ~= "" then
		-- 添加字串检查
		if string.find(self.mImgUrl, "http") ~= 1 then return end
		self.mLoading = true
		network.createHTTPRequest(onRequestCallback, self.mImgUrl, "GET"):start()
	end
end

-- 功能： [Private]合成最终图片
-- 返回值： 无
function ImageCell:compound()
	self.mRuning = true
	local fileUtils = cc.FileUtils:getInstance()
	local findTry = Delay.new(20) -- 约2秒
	local function checkImg()
		-- 如果文件不存在，延时调用
		if fileUtils:isFileExist(self.mImgFullPath) == false then
			if findTry:wheel(checkImg) == Delay.FINISH then
				self:drawCompoundImg()
			end
		-- 文件都已存在，进行合成
		else
			local imgNode = display.newSprite(self.mImgFullPath)
			self:drawCompoundImg(imgNode)
		end
	end
	checkImg()
end


-- 功能： [Private]生成最终图片并保存至本地
-- 返回值： 无
-- imgNode： 创建好的背景图节点，如果不提供，将创建空白的背景合成图
function ImageCell:drawCompoundImg( imgNode )
	self.mRuning = true
	local savePath = imgNode and self.mCompImgFullPath or self.mDefaultCompImgFullPath
	-- 需要绘制的目标对象容器
	local drawNode = cc.DrawNode:create()
	drawNode:setContentSize(self.mImgSize)

	-- 如果没有传入背景图片，创建一个空白精灵
	if not imgNode then
		imgNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), self.mImgSize.width, self.mImgSize.height)
	end
	imgNode:setAnchorPoint(cc.p(0, 0))
	local imgSize = imgNode:getContentSize()
	-- 比例缩放
	imgNode:setScaleX(self.mImgSize.width / imgSize.width)
	imgNode:setScaleY(self.mImgSize.height / imgSize.height)
	imgNode:addTo(drawNode)

	local qrNode = self:mkQrCode(self.mLinkUrl)
	local qrSize = qrNode:getContentSize()
	qrNode:setAnchorPoint(cc.p(0, 0))
	qrNode:pos(self.mQrRect.x, self.mQrRect.y)
	-- 比例缩放
	qrNode:setScaleX(self.mQrRect.width / qrSize.width)
	qrNode:setScaleY(self.mQrRect.height / qrSize.height)
	qrNode:addTo(drawNode)

	-- 绘制节点后保存至本地文件
	self:drawNodeSaveToFile(drawNode, savePath)
end

-- 功能： [Private]将二维码画出来，如果生成二维码失败，创建一个空白精灵
-- 返回值： Node
function ImageCell:mkQrCode( url )
	local drawNode = cc.DrawNode:create()
	if url and url ~= "" then
		local qrencode = require("app.luaqrcode.qrencode.lua")
		local ok, QRCode = qrencode.qrcode(url)
		if ok == true then
			local gw = 11
			local size = cc.size((#QRCode[1] + 2) * gw, (#QRCode + 2) * gw)
			local border = gw / 2
			drawNode:drawSolidRect(cc.p(0 - border, 0 - border), cc.p(size.width + border, size.height + border), cc.c4f(1,1,1,1))
			for i, row in pairs(QRCode) do
				for j, v in pairs(row) do
					local color = (v > 0) and cc.c4f(0,0,0,1) or cc.c4f(1,1,1,1)
					drawNode:drawSolidRect(cc.p(i * gw, j * gw), cc.p(i * gw + gw, j * gw + gw), color)
				end
			end
			drawNode:setContentSize(size)
		else
			Log.i("绘制二维码失败")
		end
	end
	return drawNode
end

-- 功能： [Private]绘制显示对象节点到本地文件
-- 返回值： 无
function ImageCell:drawNodeSaveToFile( node, savePath )
	self.mRuning = true
	local size = node:getContentSize()
	local renderTexture = cc.RenderTexture:create(size.width, size.height)
	-- 渲染纹理
	renderTexture:begin()
	node:visit()
	renderTexture:endToLua()
	-- 这里需要延后一帧再作保存，不然图片纹理没有渲染完毕
	renderTexture:retain()
	scheduler.performWithDelayGlobal(function()
        renderTexture:newImage(true):saveToFile(savePath, false) 
        renderTexture:release()
        self.mRuning = false
    end, 0.01)
end


-- Class Delay --

Delay.FINISH = "finish"

function Delay:ctor( delayNum )
	-- 延时时间列表
	self.mDelayNums = {}
	self.mCount = 0
	-- 产生1~dalayNum的数字列表
	for i = 1, delayNum do
		self.mDelayNums[i] = math.floor(i / 60 * 100) / 100
	end
end

-- 功能： 循环延时调用callBack
-- 返回值： 无
-- callBack 回调函数
function Delay:wheel( callBack )
	self.mCount = self.mCount + 1
	if self.mCount <= #self.mDelayNums then
		scheduler.performWithDelayGlobal(callBack, self.mDelayNums[self.mCount])
	else
		return Delay.FINISH
	end
end


return SharePreset
local AdvertViewDialog = require("app.hall.wnds.advert.AdvertViewDialog")

--[[----------------------------------------
-- 作者： 林先成
-- 日期： 2018-01-16
-- 摘要： 广告视图ui类
]]-------------------------------------------

local PageViewWnd = require("app.hall.common.PageViewWnd")

local UmengClickEvent = require("app.common.UmengClickEvent")

local AdvertView = class("AdvertView", function()
    local node = ccui.Widget:create()
    node:setAnchorPoint(cc.p(0, 0))
    return node
end)

local updateInterval = 1                -- 判断是否要切换视图时间
local PanelWidth     = 650              -- 图片宽度
local PanelHeight    = 295              -- 面板宽度

-- 功能:       构造函数
-- 返回:       无
function AdvertView:ctor(params)
    self.m_PageView = nil                               -- PageView控件
    self.m_DelayTime = 1;                               -- 当前页面停留时间
    self.m_DownNum = 0;                                 -- 当前已经下载文件数
    self.createEndCallBack = nil                        -- 创建结束回调
    self.m_Data = {}                                    -- 广告信息列表

    if IsPortrait then -- TODO
        self.item_list = {}                                 -- 子项列表
        self:setPositionX((display.width*0.9 - PanelWidth)/2)
    else
        self:setContentSize(290,336)--设置视图大小
        self.content = cc.LayerColor:create(cc.c4b(125,0,125,250))
        self.content:setContentSize(self:getContentSize())
        self.content:setTouchSwallowEnabled(false)
        self.content:setAnchorPoint(cc.p(0,0));
    end
end

-- 功能:       析构函数
-- 返回:       无
function AdvertView:dtor()
    self:stopUpdate()
    self.m_PageView = nil
end

if IsPortrait then -- TODO
    -- 功能:       测试函数
    -- 返回:       无
    function AdvertView:testFun(tmpInfo)
        if not _isChooseServerForTest then return tmpInfo end
        if tmpInfo then
            table.insert(tmpInfo,1,{
                imgName = "screen.jpg",
                delay = 1,
                imgSmall = "screen.jpg",
            })
            table.insert(tmpInfo,1,{
                imgName = "screen2.jpg",
                delay = 1,
                imgSmall = "screen2.jpg",
            })
            table.insert(tmpInfo,1,{
                imgName = "screen.jpg",
                delay = 1,
                imgSmall = "screen.jpg",
            })
            table.insert(tmpInfo,1,{
                imgName = "screen2.jpg",
                delay = 1,
                imgSmall = "screen2.jpg",
            })
            return tmpInfo
        end
        return {
            {
                imgName = "screen.jpg",
                delay = 1,
                imgSmall = "screen.jpg",
            },{
                imgName = "screen2.jpg",
                delay = 1,
                imgSmall = "screen2.jpg",
            },
        }
    end

    -- 功能：      初始化广告界面
    -- 返回：      无
    function AdvertView:initAdvert()
        local tmpInfo = json.decode(kServerInfo:getMainAdUrl1());
        -- tmpInfo = self:testFun( tmpInfo )
        if tmpInfo == nil then return end
        Log.i("AdvertView:initAdvert 广告消息列表",tmpInfo)
        self.m_Data = tmpInfo;
        for i=1,#self.m_Data do
            self:downImageByName( self.m_Data[i].imgName )
        end
        self:checkCreate()
    end

    -- 功能:       根据图片名称下载图片
    -- 返回:       无
    function AdvertView:downImageByName(imgName)
        if not kLoginInfo:getIsReview() or not imgName then return end
        local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
        if io.exists(imgFile) then
            self.m_DownNum = self.m_DownNum + 1;
        else
            LoadingView.getInstance():hide("AdvertView")
            LoadingView.getInstance():show("图片正在加载中...",nil,nil, "AdvertView",0,300,true)
            HttpManager.getNetworkImage(kServerInfo:getImgUrl() .. imgName, imgName);
        end
    end
else
    function AdvertView:getAdvertFromServer()
        -- if device.platform == "windows" then
        --     --因为调试的时候后端通常是没有配置图片的所以这里会报空
        --     return 
        -- end
        local tmpInfo = json.decode(kServerInfo:getMainAdUrl1());
        local imgUrl = kServerInfo:getImgUrl()

        if (tmpInfo and imgUrl) then
            self.m_Data = tmpInfo;
            Log.i("广告信息:",self.m_Data)

            local tmpFileNum=0;
            for i=1,#self.m_Data do
                local tmpInfo = self.m_Data[i];
                Log.i("广告信息",tmpInfo)
                local imgName=tmpInfo.imgName;
                local delay=tmpInfo.delay;
                if kLoginInfo:getIsReview() and imgName and string.len(imgName) > 4 then
                    Log.i("loading advert image.....")
                    local imgFile = cc.FileUtils:getInstance():fullPathForFilename(imgName);
                    if io.exists(imgFile) then
                        self.m_DownNum = self.m_DownNum+1;
                        if(self.m_DownNum>=#self.m_Data) then
                            if IS_YINGYONGBAO == false then
                                Log.i("加载本地广告图完成")
                                self:createAdvertView();
                            end
                        end
                    else
                        HttpManager.getNetworkImage(imgUrl .. imgName, imgName)
                    end
                end
            end
        else
            Log.e("服务器广告数据格式错误", tmpInfo, imgUrl)
        end
    end
end

-- 功能:       检查图片下载完毕则创建广告界面控件
-- 返回:       无
function AdvertView:checkCreate()
    if self.m_DownNum >= #self.m_Data and IS_YINGYONGBAO == false then
        self:createAdvertView();
    end
end

-- 功能:       创建广告视图
-- 返回:       无
function AdvertView:createAdvertView()
    if IsPortrait and self.m_PageView then return end
    self:createPageView();              -- 创建PageView控件

    self:createSlider()                 -- 创建滑动点

    if self.createEndCallBack then      -- 执行创建结束回调
        self.createEndCallBack(self)
    end
end

-- 功能:       创建指示灯
-- 返回:       无
function AdvertView:createSlider()
    self.m_sliderWnd = SliderIndicatorWnd.new();
    self.m_sliderWnd :addTo(self)
    self.m_sliderWnd :addIndicator(#self.m_Data)
    if IsPortrait then -- TODO
        self.m_sliderWnd :setPosition(cc.p(PanelWidth*0.5,30));
    else
        self.m_sliderWnd :setPosition(cc.p(self:getContentSize().width*0.5,50))
    end
    self.m_sliderWnd :setAnchorPoint(cc.p(0.5,0.5));
end

-- 功能:       设置创建成功回调函数
-- 返回:       无
function AdvertView:setFinishCallBack(listener)
    self.createEndCallBack = listener
    return self
end

if IsPortrait then -- TODO
    -- 功能:       刷新广告页面上微信ID
    -- 返回:       无
    function AdvertView:updateWechatId()
        local wechat_1 ,wechat_2 = kUserData_userExtInfo:getAddWeChatID()
        if not self.item_list then return end
        if #self.item_list < 1 then return end
        for k,v in pairs(self.item_list) do
            if v.lab_Wechat then
                v.lab_Wechat:setString(wechat_1.." "..wechat_2)
            end
        end
    end
end

function AdvertView:onResponseNetImg(imgName)
    if not self.m_Data or #self.m_Data <= 0 then return end
    for i = 1, #self.m_Data do
        if imgName == self.m_Data[i].imgName then
            local fullPath = cc.FileUtils:getInstance():fullPathForFilename(imgName)
            if io.exists(fullPath) then
                self.m_DownNum = self.m_DownNum + 1;
                self:checkCreate()
                break
            end
        end
    end
end

-- 功能:       创建PageView对象
-- 返回:       无
function AdvertView:createPageView()
    LoadingView.getInstance():hide("AdvertView")

    if IsPortrait then -- TODO
        self.m_PageView = PageViewWnd.new({
            viewRect = cc.rect(0,0,PanelWidth,PanelHeight),                                  --行和列的间距
            })
    else
        self.m_PageView = PageViewWnd.new ({
            viewRect = cc.rect(0,0,self:getContentSize().width,self:getContentSize().height),
            column = 1, row = 1,
            padding = {left =0, right = 0, top = 0, bottom =0},
            columnSpace =0, rowSpace =0})
    end
    self.m_PageView:onTouch(handler(self, self.touchListener))
    self.m_PageView:addTo(self)

    for i = 1,#self.m_Data do
        local item = self.m_PageView:newItem()
        local fileName = self.m_Data[i].imgName;
        fileName = cc.FileUtils:getInstance():fullPathForFilename(fileName);
        local btnimage = ccui.Button:create(fileName,fileName,fileName,0)
        btnimage:setAnchorPoint(cc.p(0,0));
        btnimage:setTouchEnabled(false)

        if IsPortrait then -- TODO
            self.item_list[#self.item_list + 1]= item
            local wechat_1 ,wechat_2 = kUserData_userExtInfo:getAddWeChatID()
            local lab_Wechat = cc.Label:createWithTTF(wechat_1.." "..wechat_2, "hall/font/fangzhengcuyuan.TTF", 20)
            lab_Wechat:setPosition(cc.p(btnimage:getContentSize().width * 0.5 - 165 , 50 ))
            lab_Wechat:setColor(cc.c3b(255,253,87))
            lab_Wechat:setAnchorPoint(cc.p(0, 0.5))
            item.lab_Wechat = lab_Wechat
            btnimage:addChild(lab_Wechat, 1)
        end
        
        item:addChild(btnimage)
        self.m_PageView:addItem(item)
    end
    self.m_PageView:reload()
    self.m_DelayTime = self.m_Data[1].delay; -- 初始化时间
    self:startUpdate();
end

-- 功能:       广告页面的触摸回调
-- 返回:       无
function AdvertView:touchListener(event)
    local nIndex = self.m_PageView:getCurPageIdx();
    if not nIndex then -- 容错处理
        Log.e("nIndex is nil")
        return
    elseif not self.m_Data[nIndex] then
        Log.e("no nIndex in self.m_Data", nIndex, self.m_Data)
        return
    end
    self.m_DelayTime = self.m_Data[nIndex].delay; -- 被点击过则刷新停留时间
    if(event.name =="clicked") then
        local data = {}
        data.url = kServerInfo:getImgUrl();
        data.imageFileName =  self.m_Data[nIndex].imgSmall;
        UIManager:getInstance():pushWnd(AdvertViewDialog,data);
        if IsPortrait then -- TODO
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallADButton)
            NativeCall.getInstance():NativeCallUmengEvent(UmengClickEvent.HallADButton .. nIndex)
        end
    elseif(event.name =="pageChange") then
        self.m_sliderWnd:changeIndicator(nIndex)
    elseif(event.name =="touchBegan") then
        self:stopUpdate();
    elseif(event.name =="touchEnded") then
        self:startUpdate();
    end
end

if IsPortrait then -- TODO
    -- 功能:       开始刷新广告页面
    -- 返回:       无
    function AdvertView:startUpdate()
        self:stopUpdate()
        local updatePage = cc.CallFunc:create( function()
            if self.m_PageView:getIsMove() then -- 切换的过程中不做计时处理
                self.m_DelayTime = self.m_Data[self.m_PageView:getCurPageIdx()].delay;
            else
                self.m_DelayTime = self.m_DelayTime - updateInterval;
                if self.m_DelayTime >= 0 then return end
                local nextIndex = self.m_PageView:getCurPageIdx()+1;
                if self.m_PageView:getPageCount() < nextIndex then          -- 最后一页从头开始
                    self.m_PageView:gotoPage(1,true,true);
                else
                    self.m_PageView:gotoPage(nextIndex,true,true);
                end
            end
        end)
        self.m_PageView:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(updateInterval),updatePage)))
    end

    -- 功能:       停止刷新
    -- 返回:       无
    function AdvertView:stopUpdate()
        if not self.m_PageView then return end
        self.m_PageView:stopAllActions()
    end
else
    function AdvertView:startUpdate()
        if(self.m_update_hander==nil and #self.m_Data > 0 and self.m_PageView ) then
            self.m_update_hander = scheduler.scheduleGlobal(function()
                --Log.i("check is move....")
                if(self.m_PageView) then
                    if(self.m_PageView:getIsMove()==false) then
                        --Log.i("wait time....." .. self.m_DelayTime)
                        self.m_DelayTime = self.m_DelayTime-updateInterval
                        if(self.m_DelayTime<0) then
                            local nextIndex = self.m_PageView:getCurPageIdx()+1;
                            if(self.m_PageView:getPageCount()<nextIndex) then
                                self.m_PageView:gotoPage(1,true,true);
                                self.m_DelayTime = self.m_Data[1].delay; --设置当前视图轮播时间
                            else
                                self.m_PageView:gotoPage(nextIndex,true,true);
                                self.m_DelayTime = self.m_Data[nextIndex].delay; --设置当前视图轮播时间
                            end
                        end
                    else
                       --重设时间
                       self.m_DelayTime = self.m_Data[self.m_PageView:getCurPageIdx()].delay; --设置当前视图轮播时间
                    end
                end
            end, updateInterval);
        end
    end

    function AdvertView:stopUpdate()
        if(self.m_update_hander~=nil) then
            scheduler.unscheduleGlobal(self.m_update_hander)
            self.m_update_hander=nil
            Log.i("关闭定时器。。。。。")
        end
    end
end
return AdvertView

--服务端系统数据
local LocalEvent = require("app.hall.common.LocalEvent")
local FileLog = require("app.common.FileLog")

local testServerNotifyData = {
    ["gameAppId"]= "4156",
    ["gameVersion"]= {
        ["version"]= "",
        ["md5"]= "",
        ["url"]= ""
    },
    ["gameStatus"]= "reading",
    ["gameWhiteList"]= {},
    ["gameMessage"]= {
        ["messageRule"]= {"12", "2", "1.8", "1.6", "1.4", "1.2", "1", "0.8", "0.6", "0.4", "0.2"},
        ["defaultMessage"]= "测试1112221",
        ["updateMessage"]= "服务器将于%s分钟后进行维护，请各位玩家及时下线，避免造成不必要的损失。"
    },
    ["gameUpgradeTime"]= "1523353920",
    ["gameNotify"]= {
        ["notifyStatus"]= "close",
        ["notifyStartTime"]= "1523358000",
        ["notifyEndTime"]= "1523358000",
        ["notifyTitle"]= "温馨提示",
        ["notifyContent"]= "服务器将于%s分钟后进行维护！请及时下线避免不必要的损失！",
        ["cantEnterRoom"] = "15",
    },
    ['fileLogCfg'] = {
        ['lvl'] = 1,
        -- ['url'] = "http://192.168.7.26:18600/upload/logUpload",
        -- ['url'] = "http://112.74.174.12:8099/upload/logUpload",
        ['url'] = "http://client-log-gather.stevengame.com/upload/logUpload",
        ['white'] = 0, -- 0 不区分id
        ['uids'] = {'1400100165'},
    },
}

ServerInfo = class("ServerInfo");

ServerInfo.getInstance = function()
    if not ServerInfo.s_instance then
        ServerInfo.s_instance = ServerInfo.new();
    end

    return ServerInfo.s_instance;
end

ServerInfo.releaseInstance = function()
    if ServerInfo.s_instance then
        ServerInfo.s_instance:dtor();
    end
    ServerInfo.s_instance = nil;
end

function ServerInfo:ctor()
    self.m_data = {};
    self.freeActivtyStatus = 0
    self.freeActivtyContent = ""
    self.content_txt = ""
    self.ad_txt_tag = 0
    self.ad_txt_time_interval = 5

    self.m_serverTimeOff = 0
    self.m_cantEnter = false
    self.m_serverNotifyData = {}
    self:setFileLogData() -- 避免内网测试服采用4G登陆时未能获取到白名单文件
end

function ServerInfo:dtor()
    self.m_data = {};
    self.freeActivtyStatus = 0
    self.freeActivtyContent = ""
    self.content_txt = ""
    self.ad_txt_tag = 0
    self.ad_txt_time_interval = 5
end

function ServerInfo:showServerNotice(data)
    local TopTip = require("app.hall.wnds.tipDialog.TopTip")
    TopTip:getInstance():show(data)
end

function ServerInfo:setCantEnterRoom(data)
    self.m_cantEnter = data.cantEnter
    Log.i("ServerInfo:setCantEnterRoom", self.m_cantEnter)
end

function ServerInfo:getCantEnterRoom()
    return self.m_cantEnter
end

function ServerInfo:setServerNotifyData(data, stopTopTip)
    self.m_serverNotifyData = data -- testServerNotifyData -- 
    self:setFileLogData(data.fileLog)

    local TopTipScheduler = require("app.hall.wnds.tipDialog.TopTipScheduler")
    TopTipScheduler:getInstance():resetAllHandles(stopTopTip)
end

function ServerInfo:getServerNotifyData()
    return self.m_serverNotifyData
end

function ServerInfo:setFileLogData(data)
    data = testServerNotifyData.fileLogCfg
    self.m_fileLogData = data -- testServerNotifyData

    self.m_fileLogData.whiteUids = {}
    if self.m_fileLogData.white ~= 0 then
        for i = 1, #self.m_fileLogData.uids do
            self.m_fileLogData.whiteUids[self.m_fileLogData.uids[i]] = true
        end
    end
    FileLog.uploadAllLog()
end

function ServerInfo:getFileLogData()
    return self.m_fileLogData
end

function ServerInfo:getFileLogLvl()
    if type(self.m_fileLogData) == "table" then
        return self.m_fileLogData.lvl or FileLog.LogLevel.DEBUG
    end
    return FileLog.LogLevel.DEBUG
end

function ServerInfo:getNotifyMessage(serverData) -- 登录界面可能没有设置数据
    serverData = serverData or self.m_serverNotifyData
    if (serverData.gameNotify and serverData.gameNotify.notifyStatus == "open") then
        local notify = {}
        notify.title = serverData.gameNotify.notifyTitle
        notify.content = serverData.gameNotify.notifyContent
        return notify
    end
    return nil
end

function ServerInfo:setData(data)
    self.m_data = data;
    if self.m_data.reT then
        cc.UserDefault:getInstance():setStringForKey(PRODUCT_ID.."_ContactInfoCache", self.m_data.reT)
    end
    if self.m_data.syT then
        self.m_serverTimeOff = self.m_data.syT - os.time() * 1000
    end

    local TopTipScheduler = require("app.hall.wnds.tipDialog.TopTipScheduler")
    TopTipScheduler:getInstance():resetAllHandles() -- 重置提示时间
end

function ServerInfo:getChargeList()
    return self.m_data;
end

--服务器时间
function ServerInfo:getServerTime()
    return os.time() * 1000 + self.m_serverTimeOff
end

--头像地址前缀
function ServerInfo:getHeadUrl()
    return self.m_data.heIURL or "";
end

--图片地址前缀
function ServerInfo:getImgUrl()
    return self.m_data.imURL;
end

--更新包地址前缀
function ServerInfo:getZipUrl()
    return self.m_data.gaZURL;
end

--获取充值信息
function ServerInfo:getRechargeInfo()
    if self.m_data.reT then
        return self.m_data.reT
    else
        local str = cc.UserDefault:getInstance():getStringForKey(PRODUCT_ID.."_ContactInfoCache", "NONE_VALUE")
        if str ~= "NONE_VALUE" then
            return str
        else
            return _gameContactInfo and _gameContactInfo or ""
        end
    end
end

--首页广告url
function ServerInfo:getMainAdUrl()
    return self.m_data.adURL;
end
--首页广告url
function ServerInfo:getMainAdUrl1()
    if self.m_data.adURL then
        local urlTab = string.split(self.m_data.adURL, "|");
        return urlTab[1];
    end
end

--首页弹出广告url
function ServerInfo:getMainAdUrl2()
    if self.m_data.adURL then
        local urlTab = string.split(self.m_data.adURL, "|");
        return urlTab[2];
    end
end

--首页广告微信号
function ServerInfo:getMainAdWechatId()
    if self.m_data.adURL and self.m_data.adURL ~= "" then
        local urlTab = string.split(self.m_data.adURL, "|");
        if urlTab then
            local data = json.decode(urlTab[1])
            if type(data) ~= "table" or type(data[1]) ~= "table" then -- 容错处理
                Toast.getInstance():show("adURL 配置错误!!! from 10005, 内容: " .. tostring(self.m_data.adURL), 5)
                return
            end
            return data[1].wechat
        end
    end
end

--首页广告图片名称
function ServerInfo:getPoAURL()
    if self.m_data.poAURL then
        return self.m_data.poAURL
    end
end

function ServerInfo:isFreeActivityOpen(  )
    if self.freeActivtyStatus == 0 then
        return false
    else
        return true
    end
end

---限时活动的状态
--- 0:0:未开启 1:开启 2:即将结束
function ServerInfo:setActivityStatus(status)
    self.freeActivtyStatus = status
end

function ServerInfo:getActivityStatus(  )
    return self.freeActivtyStatus      
end

---限时活动的跑马灯内容
function ServerInfo:setActivityContent(Content)
    self.freeActivtyContent = Content
end

function ServerInfo:getActivityContent(  )
    return self.freeActivtyContent      
end


function ServerInfo:getPaoMaDengTxt(  )
    local content_txt = {}
    local ad_txt = self:getAdTxt()
    if ad_txt ~= "" and ad_txt ~= nil then 
        if type(ad_txt) == "table"  then
            for k,v in pairs(ad_txt) do
                table.insert(content_txt, v)
            end
        else
            table.insert(content_txt, ad_txt)
        end
    end
    local free_activty_content = self:getActivityContent()
    if free_activty_content ~= "" and free_activty_content ~= nil then
       table.insert(content_txt, free_activty_content) 
    end
       
    if self.ad_txt_tag >= #content_txt then
        self.ad_txt_tag = 0
    end

    if #content_txt > 0 then
        self.ad_txt_tag = self.ad_txt_tag + 1       
    end

    self.content_txt = content_txt[self.ad_txt_tag]
    --self.index = index 
    return self.content_txt
end

function ServerInfo:getContentTxt(  )
    return self.content_txt
end

--广告文字
function ServerInfo:getAdTxt()
    if self.m_adTxt == nil then return nil end

    if #self.m_adTxtInfo.wxs > 1 then
        --todo
        local curTime = os.time()
        if curTime - self.m_adTxtInfo.lastTime > self.m_adTxtInfo.interval then
            --去重
            local nidx = math.random(1, #self.m_adTxtInfo.wxs - 1)
            if nidx == self.m_adTxtInfo.idx then
                self.m_adTxtInfo.idx = #self.m_adTxtInfo.wxs
            else
                self.m_adTxtInfo.idx = nidx
            end
            self.m_adTxtInfo.lastTime = curTime
        end
        return string.format(self.m_adTxtInfo.fromatStr, self.m_adTxtInfo.wxs[self.m_adTxtInfo.idx])
    elseif #self.m_adTxtInfo.wxs > 0 then
        return string.format(self.m_adTxtInfo.fromatStr, self.m_adTxtInfo.wxs[1])
    else
        return self.m_adTxtInfo.fromatStr
    end
end

function ServerInfo:getAdTimeInterval()
    return tonumber(self.ad_txt_time_interval) or 5
end


--广告文字
---跑马灯文字格式为“6|将案件就安静安静安静啊|将案件就安静安静安静啊”    时间|跑马灯文字
function ServerInfo:setAdTxt(content)

    if not content then 
        self.m_adTxt = nil
        return 
    end

    local is_ok = string.find(content, "|")
    local ad_txt = nil 
    if is_ok then
        ad_txt = string.split(content, "|")
    end

    if ad_txt then
        self.ad_txt_time_interval = ad_txt[1]

        self.ad_txt_list = {}
        for k,v in pairs(ad_txt) do
            if k ~= 1 then
                self.ad_txt_list[#self.ad_txt_list + 1] = v
            end
        end

        self.m_adTxt = self.ad_txt_list;  
    else
        self.m_adTxt = content;
    end

    self:formatAdTxt()
end

function ServerInfo:formatAdTxt()
    self.m_adTxtInfo = { fromatStr = "", interval = 60, wxs = {}, lastTime = os.time(), idx = 1 }
    if self.m_adTxt == nil then
        return
    else
        self.m_adTxtInfo.fromatStr = self.m_adTxt --无格式的先赋值原型
    end

    repeat

        if type(self.m_adTxt) == "table" then
            break
        end
        local ps1 = string.find(self.m_adTxt, "<")
        if ps1 == nil then break end

        local ps2 = string.find(self.m_adTxt, ">", ps1)
        if ps2 == nil or ps2-ps1 < 1 then break end

        local strHead = string.sub(self.m_adTxt, 1, ps1-1)
        local strEnd = string.sub(self.m_adTxt, ps2+1, -1)

        local wxStr = string.sub(self.m_adTxt, ps1+1, ps2-1)
        local wechat_id_list = string.split(wxStr,",")
        if #wechat_id_list < 2 then break end

        self.m_adTxtInfo.interval =  tonumber(wechat_id_list[1]) or 60
        table.remove(wechat_id_list, 1)
        self.m_adTxtInfo.wxs = wechat_id_list
        self.m_adTxtInfo.fromatStr = strHead.."%s"..strEnd
        self.m_adTxtInfo.idx = math.random(1, #self.m_adTxtInfo.wxs)
    until( true )
end

-- 回放包url
function ServerInfo:getRecordUrl()
    return self.m_data.reURL;
end

function ServerInfo:getDayShareInfo()
    if type(self.m_data.daS) == "string" then
        local tab = json.decode(self.m_data.daS)
        return tab or {}
    end
    return {}
end

function ServerInfo:getInviteShareInfo()
    if type(self.m_data.inS) == "string" then
        local tab = json.decode(self.m_data.inS)
        return tab or {}
    end
    return {}
end

function ServerInfo:getClubShareInfo()
    if type(self.m_data.clS) == "string" then
        local tab = json.decode(self.m_data.clS)
        return tab or {}
    end
    return {}
end

kServerInfo = ServerInfo.getInstance();
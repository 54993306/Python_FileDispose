--玩家扩展数据

UserData_userExtInfo = class("UserData_userExtInfo", UserData_base);

UserData_userExtInfo.getInstance = function()
    if not UserData_userExtInfo.s_instance then
        UserData_userExtInfo.s_instance = UserData_userExtInfo.new();
    end

    return UserData_userExtInfo.s_instance;
end

UserData_userExtInfo.releaseInstance = function()
    if UserData_userExtInfo.s_instance then
        UserData_userExtInfo.s_instance:dtor();
    end
    UserData_userExtInfo.s_instance = nil;
end

function UserData_userExtInfo:ctor()
    self.super.ctor(self);
    self.EmailData = {}
    self.addWeChatID1,self.addWeChatID2 = "",""
    self.updateTime = 60
    self.marqueeTime = 60

end

function UserData_userExtInfo:dtor()
    self:releaseWxTimer()
end

function UserData_userExtInfo:release()
    self.super.release(self);
    self:releaseWxTimer()
end

function UserData_userExtInfo:releaseWxTimer()
    if(self.addWeChatID~=nil) then
        self.addWeChatID:finalizer()
        self.addWeChatID:removeTimer("wechatId_update_timer");
        self.addWeChatID=nil
    end

    if(self.m_timer_diamound_wechat~=nil) then
        self.m_timer_diamound_wechat:finalizer()
        self.m_timer_diamound_wechat:removeTimer("wechatId_update_timer");
        self.m_timer_diamound_wechat=nil
    end
end

function UserData_userExtInfo:setEmailData(pEmailData)
    self.EmailData = pEmailData
end

function UserData_userExtInfo:getEmailData()
    return self.EmailData
end


function UserData_userExtInfo:getAddWechatStr(callBack)
    local url = "http://app73.stevengame.com/dsqp_config66/webapi/adwechat/adimg.do?gameId="..PRODUCT_ID;
    if callBack == nil then callBack = function() end end
    HttpManager.getWechatIdData(url, callBack);
end

---刷新广告微信号
if IsPortrait then -- TODO

function UserData_userExtInfo:setAddWeChatID(callBack)
    local wechatData = kServerInfo:getMainAdWechatId()
    if not wechatData then return end
    local interval = wechatData.delay or 600
    local arr = wechatData.id or {}
    local function updateWechatId()
        --解析随机获取微信号组
        local index = math.random(#arr);
        if #arr > 1 then
            local common_num = 0
            for k,v in pairs(arr) do
                if (self.addWeChatID1.."&"..self.addWeChatID2) == v then
                    common_num = common_num + 1
                end
            end
            if common_num ~= #arr then
                while (self.addWeChatID1.."&"..self.addWeChatID2) == arr[index] do
                    index = math.random(#arr);
                end
            end
        end

        local retArr = Util.stringSplit(arr[index], "&");
        self.addWeChatID1 = retArr[1] or ""
        self.addWeChatID2 = retArr[2] or ""
        if callBack then
            callBack()
        end
        --Log.i("=================UserData_userExtInfo========广告微信号的update==",self.addWeChatID1,self.addWeChatID2)
    end

    if(self.addWeChatID == nil and arr and #arr > 0) then
       self.addWeChatID = require ("app.common.TimerProxy").new();
       self.addWeChatID:addTimer("wechatId_update_timer", updateWechatId, tonumber(interval), -1);
       updateWechatId();
    end
end

else

function UserData_userExtInfo:setAddWeChatID(arr, interval, callBack)
    local function updateWechatId()
        --解析随机获取微信号组
        local index = math.random(#arr);
        if #arr > 1 then
            while (self.addWeChatID1.."&"..self.addWeChatID2) == arr[index] do
                index = math.random(#arr);
            end
        end

        local retArr = Util.stringSplit(arr[index], "&");
        self.addWeChatID1 = retArr[1] or ""
        self.addWeChatID2 = retArr[2] or ""
        if callBack then
            callBack()
        end

        --Log.i("=================UserData_userExtInfo========广告微信号的update==",self.addWeChatID1,self.addWeChatID2)
    end
    --interval = 5
    if(self.addWeChatID == nil and arr and #arr > 0) then
       self.addWeChatID = require ("app.common.TimerProxy").new();
       self.addWeChatID:addTimer("wechatId_update_timer", updateWechatId, tonumber(interval), -1);
       updateWechatId();
    end
end

end

---获取广告微信号
function UserData_userExtInfo:getAddWeChatID()
    return self.addWeChatID1,self.addWeChatID2
end

---刷新钻石不足微信号
function UserData_userExtInfo:setDiamoundWechatID(  )
    local data = kUserData_userExtInfo:getWeChatIDStr()
    local updateTime = kUserData_userExtInfo:getKeFuWechatUpdateTime() or 60
    local function updateWechatId()
        data = kUserData_userExtInfo:getWeChatIDStr()
        updateTime = kUserData_userExtInfo:getKeFuWechatUpdateTime()
        --Log.i("=========钻石不足威信号==================",updateTime)
        local Contact_us = UIManager:getInstance():getWnd(Contact_us)
        if Contact_us then
            Contact_us:updateList(data.content)
        end
        self.diamond_wechat_data = data
    end

    self.diamond_wechat_data = nil
    updateWechatId();
    if not IsPortrait then -- TODO
        if(self.m_timer_diamound_wechat == nil) then
            self.m_timer_diamound_wechat = require ("app.common.TimerProxy").new();
            self.m_timer_diamound_wechat:addTimer("reachre_wechatId_update_timer", updateWechatId, tonumber(updateTime), -1);
        end
    end
end

---获取钻石不足微信号数据
function UserData_userExtInfo:getDiamoundWechatID()
     return self.diamond_wechat_data or self:getWeChatIDStr()
end

---处理钻石客服微信号
function UserData_userExtInfo:getWeChatIDStr( str_data )
    local data = {}
    --local aaa = "测试联系微信号微信号微：##mj1111|测试联系代理微信号：<5,suuzhoumj4,suuzhoumj5,suuzhoumj6>"
    local str = str_data or kServerInfo:getRechargeInfo()
    data.type = 1;
    data.content = "";
    local contentTab = string.split(str, "|");
    if not contentTab then
        return data
    end

    local str = {}
    for k,v in pairs(contentTab) do
        local value = self:resetWeChatID(v,k)
        str[#str + 1] = value
    end
    data.content = str
    return data
end

function UserData_userExtInfo:resetWeChatID(str,wechat_tag)
    local pos = string.find(str,"<")
    if not pos then
        return str
    end

    local strlist = string.split(str,"<")
    local weixinhao = strlist[#strlist]
    local weixinlist = string.split(weixinhao,",")
    if not weixinlist then return str end
    local weixinhao1 = weixinlist[#weixinlist]
    weixinhao1 = string.sub(weixinhao1,1,-2)
    weixinlist[#weixinlist] = weixinhao1

    self.updateTime = weixinlist[1] or 60
    local selectWechatId = math.random(2,#weixinlist)

    if wechat_tag == 1 then
        while self.keFuWechatId == selectWechatId and #weixinlist > 2 do
            selectWechatId = math.random(2,#weixinlist);
        end
        self.keFuWechatId = selectWechatId
    else
        while self.daiLiWechatId == selectWechatId and #weixinlist > 2 do
            selectWechatId = math.random(2,#weixinlist);
        end
        self.daiLiWechatId = selectWechatId
    end

    local wechat_id = weixinlist[selectWechatId] or ""
    return strlist[1].."##"..wechat_id
end

function UserData_userExtInfo:getKeFuWechatUpdateTime()
    return self.updateTime
end

function UserData_userExtInfo:getPaoMaWechatUpdataTimes(  )
    return self.marqueeTime
end

-- 是否显示手机注册界面
function UserData_userExtInfo:setPhoneRegist(regist)
    self.openRegist = regist
end

function UserData_userExtInfo:getPhoneRegist()
    return self.openRegist or false
end

kUserData_userExtInfo = UserData_userExtInfo.getInstance();

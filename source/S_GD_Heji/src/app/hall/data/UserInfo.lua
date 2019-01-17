--玩家数据

UserInfo = class("UserInfo");

UserInfo.getInstance = function()
    if not UserInfo.s_instance then
        UserInfo.s_instance = UserInfo.new();
    end

    return UserInfo.s_instance;
end

UserInfo.releaseInstance = function()
    if UserInfo.s_instance then
        UserInfo.s_instance:dtor();
    end
    UserInfo.s_instance = nil;
end

function UserInfo:ctor()
    self.m_UserInfo = {};
    self.user_new_ip = ""
end

function UserInfo:dtor()

end

function UserInfo:setUserId(userId)
    self.m_userId = userId;
end

function UserInfo:getUserId()
    return self.m_userId or 0;
end

function UserInfo:setUserToken(token)
    self.m_userToken = token
end
function UserInfo:getUserToken()
    return self.m_userToken or ""
end

function UserInfo:setActivityPub(pub)
    self.m_acitvitypub = pub
end

function UserInfo:getActivityPub()
    return self.m_acitvitypub or 0
end

function UserInfo:getUserName()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.nickName or "";
    else
        return "";
    end
end

function UserInfo:getUserIp()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.activeIP or "";
    else
        return "";
    end
end

function UserInfo:setUserNewIp(ip)
    self.user_new_ip = ip 
end

function UserInfo:getUserNewIp()
    return self.user_new_ip
end

function UserInfo:getUserSex()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.sex or 0;
    else
        return 0;
    end
end

function UserInfo:getMoney()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.takenCash or 0;
    else
        return 0;
    end
end

function UserInfo:getCity()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.city or 0;
    else
        return 0;
    end
end

--获取背包的金豆
function UserInfo:getBagMoney()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId())
    if userInfo then
        return userInfo.cash or 0
    else
        return 0
    end
end

--返回私人房钻石
function UserInfo:getPrivateRoomDiamond()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.privateRoomDiamond or 0;
    else
        return 0;
    end
end

--返回私人房钻石变化
function UserInfo:getPrivateRoomDiamondChange()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.privateRoomDiamond_change or 0;
    else
        return 0;
    end
end


--获取元宝数量
function UserInfo:getPoint()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.point or 0;
    else
        return 0;
    end
end


--获取金元宝数量变化(兑换商城)
function UserInfo:getScripChange()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.paper_change or 0;
    else
        return 0;
    end
end

--获取金元宝数量(兑换商城)
function UserInfo:getScrip()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.paper or 0;
    else
        return 0;
    end
end

--获取背包的消费卡数量
function UserInfo:getPrepaidCard()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.prepaidCard or 0;
    else
        return 0;
    end
end

--获取抽奖卡数量
function UserInfo:getGachaChard()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.gachaCard or 0;
    else
        return 0;
    end
end

--获取参赛卡数量
function UserInfo:getMatchEnterCard()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.matchEnterCard or 0;
    else
        return 0;
    end
end
--获取开放卡数量
function UserInfo:getRoomCard()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId())
    if userInfo then
        return userInfo.inviteRoomCard or 0
    else
        return 0
    end
end
function UserInfo:getCashGiftCard()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId())
    Log.i("UserInfo:getCashGiftCard...",userInfo)
    if userInfo then
        return userInfo.cashGiftCard or 0
    else
        return 0
    end
end

--获取金元宝数量
function UserInfo:getScrip()
    local userInfo = kUserData_userPointInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.paper or 0;
    else
        return 0;
    end
end

--头像（大640x640）
function UserInfo:getHeadImg()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.imgId or "1";
    else
        return "1";
    end
end

--头像（小46x46）
function UserInfo:getHeadImgSmall()
    if not self.m_headImgUrlSmall then
        local imgUrl = kUserInfo:getHeadImg();
        local imgUrlLen = string.len(imgUrl);
        if imgUrlLen > 4 then
            local preUrl = string.sub(imgUrl, 1, imgUrlLen - 1);
            Log.i("------preUrl", preUrl);
            self.m_headImgUrlSmall = preUrl .. "46";
        end
    end
    Log.i("------self.m_headImgUrlSmall", self.m_headImgUrlSmall);
    return self.m_headImgUrlSmall or "";
end

--背包密码
function UserInfo:getUserBagPas()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.bagPasswd or "";
    else
        return "";
    end
end

--获取背包密码填写时间
function UserInfo:getUserBagPasTime()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    Log.i("userInfo....",userInfo)
    if userInfo then
        return userInfo.pasTime or ""
    else
        return ""
    end
end

function UserInfo:getAccountName()
    local userInfo = kUserData_userInfo:getUserDataByKeyID(self:getUserId());
    if userInfo then
        return userInfo.accountName or "";
    else
        return "";
    end
end

function UserInfo:getAgentInfo()
    return self.m_agentInfo;
end

function UserInfo:setAgentInfo(infoContent)
    if infoContent and infoContent ~= nil then
        self.m_agentInfo = json.decode(infoContent);
    end
end

function UserInfo:getAgentUrl()
    return self.m_agentUrl;
end

function UserInfo:setAgentUrl(url)
    self.m_agentUrl = url;
end

function UserInfo:setInviteInfo(info)
    self.m_inviteInfo = info
end

function UserInfo:getInviteInfo()
    return self.m_inviteInfo
end

function UserInfo:getKfUserInfo()
    local uid = self:getUserId();
    local uname = self:getUserName();
    if uid == 0 then
        local lastAccount = kLoginInfo:getLastAccount();
        if lastAccount and lastAccount.usi then
            uid = lastAccount.usi
        end
    end

    if uname == "" or uname == nil then
        if uid == nil or uid == 0 then
            uname = "游客"
        else
            uname = "游客"..uid
        end
    end

    --此时uid需要传入字符串类型.否则ios那边解析会出问题.
    return ""..uid, uname
end

function UserInfo:canAwardInvite()
    if self.m_inviteInfo 
        and self.m_inviteInfo["reL"] ~= nil 
        and #(self.m_inviteInfo["reL"]) > 0 
        and self.m_inviteInfo["li"] ~= nil 
        and #(self.m_inviteInfo["li"]) > 0 then

        local curInviteNum = self.m_inviteInfo.inN1 or 0
        for i,v in ipairs(self.m_inviteInfo.reL) do
            if curInviteNum >= v.inN then --达到领取条件
                if v.isR == 0 then --未领取
                    return true
                end
            end
        end
    end
    return false
end

kUserInfo = UserInfo.getInstance();
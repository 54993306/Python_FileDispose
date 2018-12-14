--充值数据、主界面数据
local LocalEvent = require("app.hall.common.LocalEvent")
SystemConfig = class("SystemConfig");

SystemConfig.getInstance = function()
    if not SystemConfig.s_instance then
        SystemConfig.s_instance = SystemConfig.new();
    end

    return SystemConfig.s_instance;
end

SystemConfig.releaseInstance = function()
    if SystemConfig.s_instance then
        SystemConfig.s_instance:dtor();
    end
    SystemConfig.s_instance = nil;
end

function SystemConfig:ctor()
    self:resetData()
end

function SystemConfig:dtor()
    
end

--清理用户数据
function SystemConfig:release()
    self:resetData()
end

function SystemConfig:resetData()
    self.m_dataList = {};
    self.m_hallConfig = {}

    self.timeoffset = nil
    self.clubIdentity = 0
    self.clubID = 0
    self.clubName = ""
    self.clubJoinedNum = 0
    self.clubJoinLimitCount = 1

    self.ownerClubInfo = nil
    self.joinedClubsInfo = {}

    self.clubApplyChange = false

    self.m_isWifi = true -- 是否为wifi状态
    self.m_netStateInfo = {} -- 网络状态
end

function SystemConfig:setSystemConfigList(dataList)
    self.m_dataList = dataList;
    if kLoginInfo:getIsReview() then
        return;
    end
end

function SystemConfig:getSystemConfigList()
    return self.m_dataList;
end

-- 功能： 获取需要的数据单元
-- 返回值： Table or False
function SystemConfig:getDataByKe( ke )
    for _, i in pairs(self.m_dataList) do
        if i.ke and i.ke == ke then
            return i
        end
    end
    return false
end

function SystemConfig:setTimeOffset(servertime)
    if servertime then
        servertime = servertime / 1000
    else
        servertime = os.time()
    end
    self.timeoffset = os.difftime(servertime,os.time())
end

function SystemConfig:getTimeOffset()
    return self.timeoffset or 0
end
    
--[[
##  coB  int   是否显示兑换码按钮(0:不显示 1:显示 -1:不修改状态)
##  weFB  int   是否显示关注按钮(0:不显示 1:显示 -1:不修改状态)
##  weF  int   是否已关注微信公众号(0:未领取兑换码 1:已领取兑换码 -1:不修改状态)
##  raR  int   是否可领排行榜奖励(0:不可以领 1:可以领 -1:不修改状态)
##  roRB  int   是否显示主界面房主排行按钮(0:不显示 1:显示 -1:不修改状态)
##  frFS  int   限时免钻活动状态(0:未开启 1:开启 2:即将结束)
##  frFMT  String   限时免钻跑马灯内容
]]--
function SystemConfig:setHallConfig(data)
    self.m_hallConfig = data
end

--[[
--亲友圈部分
##  usCT  int   是否为亲友(0:非亲友 1:拥有者 2:亲友 3:亲友-已申请)
##  clI  long  亲友圈拥有者的亲友圈id
##  clN  String  亲友圈拥有者的亲友圈名称
##  usCC  int  亲友圈亲友的已加入亲友圈数量
##  usCMS  int  可加入亲友圈最大数量
--]]
function SystemConfig:setClubConfig(data)
    self.clubIdentity = data.usCT or 0
    self.clubID = data.clI or 0
    self.clubName = data.clN or ""
    self.clubJoinedNum = data.usCC or 0
    self.clubJoinLimitCount = data.usCMS or 1
    if self.clubIdentity ~= 1 then
        self.ownerClubInfo = nil
    end
end

function SystemConfig:getHallConfig()
    return self.m_hallConfig or {}
end

function SystemConfig:getClubJoinedNum()
    return self.clubJoinedNum
end

function SystemConfig:getClubJoinLimitCount()
    return self.clubJoinLimitCount
end

-- ##  clI  long  玩家所在亲友圈id，无亲友圈为0
function SystemConfig:getClubID()
    -- return 1
    return self.clubID or 0
end

function SystemConfig:getOwnerClubInfo()
    return self.ownerClubInfo or {}
end

--如果是拥有者则只返回自己的clubinfo
--如果不是拥有者则返回加入的clubs
function SystemConfig:getMyClubsInfo()
    local IsClubOwner = false
    if self.ownerClubInfo ~= nil then
        for k,v in pairs(self.ownerClubInfo) do
            IsClubOwner = true
            break
        end
    end
    if IsClubOwner then
        return {self.ownerClubInfo}
    else
        return self.joinedClubsInfo
    end
end

function SystemConfig:getClubJoinLimitCount()
    return self.clubJoinLimitCount or 1
end

function SystemConfig:setClubApplyChanged(value)
    self.clubApplyChange = value
    local event = cc.EventCustom:new(LocalEvent.ClubApplyRedChange)
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    Log.i("SystemConfig:setClubApplyChanged "..tostring(value))
end

function SystemConfig:isClubApplyChanged()
    return self.clubApplyChange and not self:IsClubOwner()
end

--是否申请加入过亲友圈 0 未申请过， 1 申请过
function SystemConfig:isClubNewer()
    return self.clubIdentity == 0 and #self.joinedClubsInfo == 0
end
-- ##  isCC  int   是否亲友圈创始人(1:是创始人 0:不是创始人)
function SystemConfig:IsClubOwner()
    -- return true
    if self.clubIdentity == 1 then
        return true
    else
        return false
    end
end
-- ##  clN  String  亲友圈名称
function SystemConfig:getClubName()
    return self.clubName or "管理员的亲友圈"
end
-- ##  clC  String  亲友圈创始人
function SystemConfig:getClubOwner()
    return self.clubOwnerName or "用户"
end
-- ##  clI  long  亲友圈id
-- ##  clN  String  亲友圈名称
-- ##  clC  String  亲友圈创始人
-- ##  crT  int  亲友圈创建时间
-- ##  chT  int  亲友圈创建后预审核阶段的时间（分钟）
-- ##  chMN int  审核转正的人数条件
-- ##  clS  int  亲友圈状态（0预审核，1正式，2未通过）
-- ##  meN  int  亲友圈人数
-- ##  clURL  String  亲友圈公众号url
function SystemConfig:updateOwnClubInfo(data)
    local clubInfo = nil
    if kUserInfo:getUserId() == data.prGUI then
        clubInfo = {}
        clubInfo = clone(data)
        clubInfo.clubID = data.clI
        clubInfo.clubName = data.clN
        clubInfo.clubOwnerName = data.clC
        clubInfo.clubOwnerID = data.prGUI
        --todo 
        clubInfo.clubOlNum   = data.clOMC
        clubInfo.clubMemNum  = data.meN
        clubInfo.diamondSt   = data.diRS
        clubInfo.diaNum = data.diR
        self.clubIdentity = 1
    end
    self.ownerClubInfo = clubInfo
end

--  ##  clI  long  亲友圈Id
--  ##  clN  String  亲友圈名称
--  ##  clOI  long  亲友圈拥有人
--  ##  clOMC  int  亲友圈在线人数(登录人数)
--  ##  clAMC  int  亲友圈总人数
--  ##  diRS  int  钻石剩余状态
function SystemConfig:updateJoinedClubInfo(data)
    local clubsInfo = {}
    for i,v in ipairs(data) do
        clubsInfo[#clubsInfo + 1] = {}
        clubsInfo[#clubsInfo].clubID      = v.clI
        clubsInfo[#clubsInfo].clubName    = v.clN
        clubsInfo[#clubsInfo].clubOwnerName = v.clON
        clubsInfo[#clubsInfo].clubOlNum   = v.clOMC
        clubsInfo[#clubsInfo].clubMemNum  = v.clAMC
        clubsInfo[#clubsInfo].diamondSt   = v.diRS
    end
    self.joinedClubsInfo = clubsInfo
    self.clubJoinedNum = #self.joinedClubsInfo
end

function SystemConfig:setNetStateInfo(info)
    if type(info) == 'table' then
        self.m_netStateInfo = info
        if self.m_netStateInfo.type == "Wi-Fi" then
            self.m_isWifi = true
        elseif self.m_netStateInfo.type == "无" or self.m_netStateInfo.type == "无网络" then -- 借用wifi的图标来表示无网络
            self.m_isWifi = true
            self.m_netStateInfo.rssi = 0
        else
            self.m_isWifi = false
        end
    end
end

function SystemConfig:getNetStateInfo()
    return self.m_netStateInfo
end

function SystemConfig:isWifi()
    return self.m_isWifi
end

kSystemConfig = SystemConfig.getInstance();
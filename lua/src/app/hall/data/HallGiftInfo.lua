--礼包数据
--礼包模板配置表数据 
        --任务ID Id
        --任务接取类型（1-普通  2链式  3 每日循环 ） ty
        --任务名称 quN
        --任务类型（16 类参加代码详细） quT
        --前置任务id（非必要 = 0） prQI
        --完成条件1 co
        --完成条件2 co0
        --完成条件3 co1
        --是否实时发放 awAS
        --type1=全部发放，2=随机一件，3=自选一件 awT
        --任务奖励（1：sum|2：sum 的格式） awL
        --任务描述 de
        --图标id icI
        --推荐类型（1 圈红闪烁  2 新手福利  3成长福利） re
        --是否显示任务链shQL 1:显示 0:不显示;
        --商家码diC="";
        --任务接取类型(1-注册接取  2 等级  3 链式接取)acT;
        --任务接取条件值acV;
        --分享标签，1-允许分享，0-不允许分享 shT;
        --分享奖励（1：sum|2：sum 的格式）shA="";
        --分享标题 shT2="";
        --分享描述shD="";
        --分享链接shL="";
        --显示排序 quO;

--逻辑表数据     
    --questId;
    --/**任务状态（0 未完成 1 完成 2 已领取奖励）**/ status;
    --achive1;
    --achive2;
    --achive3;
    --endTime;
    
HallGiftInfo = class("HallGiftInfo");

HallGiftInfo.getInstance = function()
    if not HallGiftInfo.s_instance then
        HallGiftInfo.s_instance = HallGiftInfo.new();
    end

    return HallGiftInfo.s_instance;
end

HallGiftInfo.releaseInstance = function()
    if HallGiftInfo.s_instance then
        HallGiftInfo.s_instance:dtor();
    end
    HallGiftInfo.s_instance = nil;
end

function HallGiftInfo:ctor()
    self.m_giftBaseInfo={};--模板配置数据
end

function HallGiftInfo:dtor()

end

function HallGiftInfo:setGiftBaseInfo(giftInfo)
    self.m_giftBaseInfo = giftInfo.quL;
end

function HallGiftInfo:getGiftBaseInfo()
    return self.m_giftBaseInfo or {};
end


function HallGiftInfo:getGiftBaseInfo(giftID)
    local giftInfo = {};
    for k, v in pairs(self.m_giftBaseInfo) do
        if v.Id == giftID then
            giftInfo = v;
            return giftInfo;
        end
    end
    return giftInfo;
end

--找列表前ID信息
function HallGiftInfo:getGiftFrontInfo(frontID)
    local giftInfo = nil;
    for k, v in pairs(self.m_giftBaseInfo) do
        if v.prQI == frontID then
            giftInfo = v;
            return giftInfo;
        end
    end
    return giftInfo;
end

kHallGiftInfo = HallGiftInfo.getInstance();
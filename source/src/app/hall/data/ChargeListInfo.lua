--充值数据

ChargeListInfo = class("ChargeListInfo");

ChargeListInfo.getInstance = function()
    if not ChargeListInfo.s_instance then
        ChargeListInfo.s_instance = ChargeListInfo.new();
    end

    return ChargeListInfo.s_instance;
end

ChargeListInfo.releaseInstance = function()
    if ChargeListInfo.s_instance then
        ChargeListInfo.s_instance:dtor();
    end
    ChargeListInfo.s_instance = nil;
end

function ChargeListInfo:ctor()
    self.m_dataList = {};
    self.apple_pay_order_id = {}
end

function ChargeListInfo:dtor()

end

--商品列表字段
--[[
    Id  int  商品Id
    na  String  商品名称
    pa  double  扣费金额(元)
    trI  String  交易物品(可以以字符串配置方式灵活变更)
    de  String  商品描述
    apI  String  APPid
    paW  String  支付途径(1.快充，2.商城充值,3.破产时弹出的充值页面)
    wxP  int  是否支持微信支付 0: 不支持   1：支持
    apP  int  是否支持apple支付 0: 不支持   1：支持
    alP  int  是否支持支付宝支付 0: 不支持   1：支持
    apCC  String  apple渠道号
    re  String  标记
    go  int  商品数量
    pr  int  赚送商品数量
--]]

function ChargeListInfo:setChargeList(dataList)
    self.m_dataList = dataList;
end

function ChargeListInfo:getChargeList()
    return self.m_dataList;
end

function ChargeListInfo:setOpenChargeList(openList)
    self.m_gameOpenList = openList;
end

function ChargeListInfo:getOpenChargeList()
    return self.m_gameOpenList;
end

function ChargeListInfo:getChargeInfo(chargeId)
    for k, v in pairs(self.m_dataList) do
        if v.Id == chargeId then
            return v;
        end
    end
end

function ChargeListInfo:setChargeEnvironment(path, gameId, roomId)
    self.m_path = path;
    self.m_gameId = gameId;
    self.m_roomId = roomId;
end

function ChargeListInfo:getChargePath()
    return self.m_path or RECHARGE_PATH_STORE;
end

function ChargeListInfo:getRoomId()
    return self.m_roomId or 0;
end

function ChargeListInfo:getGameId()
    return self.m_gameId or 0;
end

function ChargeListInfo:setApplePayOrderId(id)
    self.apple_pay_order_id[#self.apple_pay_order_id + 1] = id
end

function ChargeListInfo:getApplePayOrderId()
    local data = clone(self.apple_pay_order_id)

    if #data < 1 then return "" end
    local order_id = ""
    local new_order_id_list = {}
    for k,v in pairs(data) do
        if k == 1 then
            order_id = v 
        else
            new_order_id_list[#new_order_id_list + 1] = v
        end
    end
    self.apple_pay_order_id = new_order_id_list
    return order_id or "";
end

function ChargeListInfo:deletApplePayOrderId()
    
end

---支付前保存订单信息：is_before:是否是支付前保存数据，info:"订单id,商品id,校验码,"
function ChargeListInfo:saveApplePayInfo(is_before,info)
    local user_id = kUserInfo:getUserId()
    local pay_data = cc.UserDefault:getInstance():getStringForKey(user_id.."appleOrderInfo")
    local apple_pay_data = json.decode(pay_data) or {}
    --Log.i("==========apple_pay_data==================",apple_pay_data)

    if #apple_pay_data > 0 then
        local data_info = Util.stringSplit(info, ",")
        local dtId = data_info[1] or ""
        local good_id = data_info[2] or ""
        local code = data_info[3] or ""

        local function getInsertInfoKay(  )
            --local dtId = data_info[1] or ""
            --Log.i("==========dtId==================",dtId)
            for k,v in pairs(apple_pay_data) do
                local data = Util.stringSplit(v, ",")

                if data[1] == dtId then
                    return k
                end
            end

            return  #apple_pay_data + 1       
        end

        local function getEndInfo()
            for i=#apple_pay_data,1,-1 do
                local save_data = Util.stringSplit(apple_pay_data[i], ",")
                if save_data[2] == good_id then
                    if dtId == "" then
                        --Log.i("=====================111111111")
                        info = string.format("%s,%s,%s",save_data[1],good_id,code)
                        return i
                    else
                        if dtId == save_data[1] then
                            --Log.i("=====================222222")
                            return i
                        end
                    end
                end
            end
            return #apple_pay_data + 1
        end

        local key_id = is_before and getInsertInfoKay() or getEndInfo()
        apple_pay_data[key_id] = info
    else
        apple_pay_data[#apple_pay_data + 1] = info
    end

    --Log.i("===========new_pay_data==========",apple_pay_data)
    local data_code = json.encode(apple_pay_data)
    cc.UserDefault:getInstance():setStringForKey(user_id.."appleOrderInfo", data_code)  
end


function ChargeListInfo:getApplePayEndOrderInfo(good_id)
    local user_id = kUserInfo:getUserId()
    local pay_data = cc.UserDefault:getInstance():getStringForKey(user_id.."appleOrderInfo")
    local apple_pay_data = json.decode(pay_data) or {}

    if #apple_pay_data > 0 then
        for i=#apple_pay_data,1,-1 do
            local save_data = Util.stringSplit(apple_pay_data[i], ",")
            --Log.i("========save_data=============",save_data,good_id)
            if save_data[2] == tostring(good_id) then
                return save_data[1]
            end
        end        
    end
    return nil
end

---删除applePay订单记录：通过订单id 删除记录中的id和校验码
function ChargeListInfo:dalateApplePayInfo(id)
    --print("===================delete",debug.traceback())
    --print("================id===delete",id)
    local user_id = kUserInfo:getUserId()
    local pay_data = cc.UserDefault:getInstance():getStringForKey(user_id.."appleOrderInfo")
    local apple_pay_data = json.decode(pay_data) or {}

    local copy_data = {}
    if apple_pay_data and #apple_pay_data > 0 then
        for k,v in pairs(apple_pay_data) do
            if string.find(v,id) then
                local delete_str = v
            else
                copy_data[#copy_data + 1] = v
            end
        end
    end
    local data_code = json.encode(copy_data)
    cc.UserDefault:getInstance():setStringForKey(user_id.."appleOrderInfo", data_code)
end

function ChargeListInfo:repeatSendApplePay(  )
    local user_id = kUserInfo:getUserId()
    local pay_data = cc.UserDefault:getInstance():getStringForKey(user_id.."appleOrderInfo")
    if not IsPortrait then -- TODO
        if not pay_data or pay_data == "" then
            return
        end
    end
    local data = json.decode(pay_data) or {}
    if data then
        for k,v in pairs(data) do
            local data_info = Util.stringSplit(v, ",")

            local apple_pay_id  = data_info[1] or "" 
            local good_id = data_info[2] or ""
            local apple_pay_code  = data_info[3] or ""
            
            if apple_pay_code ~= "" and apple_pay_id ~= "" then
                --Log.i("=================sahngxing ")
                local data = {};
                data.boS = apple_pay_code;
                data.orI = apple_pay_id  
                data.stI = good_id          
                SocketManager.getInstance():send(CODE_TYPE_CHARGE, HallSocketCmd.CODE_SEND_IOSCHARGE, data)
            end
        end
    end
end

kChargeListInfo = ChargeListInfo.getInstance();